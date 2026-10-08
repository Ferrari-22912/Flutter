import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:three_bhai/core/error/failures.dart';
import 'package:three_bhai/features/chat/domain/entities/chat_message.dart';
import 'package:three_bhai/features/chat/domain/repositories/chat_repository.dart';

/// Reads the user's own rows from `chat_messages` (RLS) and sends new messages
/// through the `chef-chat` Edge Function, which holds the Gemini key and
/// enforces the cooking-only rule on the server.
class SupabaseChatRepository implements ChatRepository {
  SupabaseChatRepository(this._client);

  final SupabaseClient _client;
  static const _table = 'chat_messages';

  @override
  Future<List<ChatMessage>> loadMessages() async {
    try {
      final rows = await _client
          .from(_table)
          .select('id, role, content, on_topic, created_at')
          .order('created_at', ascending: false)
          .limit(100);
      return rows.reversed.map<ChatMessage>(_fromRow).toList();
    } on PostgrestException {
      throw const ServerFailure('Could not load your chat.');
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  @override
  Future<ChatMessage> send(String text) async {
    try {
      final response = await _client.functions.invoke(
        'chef-chat',
        body: {'message': text},
      );
      final data = response.data;
      if (data is! Map<String, dynamic> || data['reply'] is! String) {
        throw const ServerFailure('The chef sent an unexpected reply.');
      }
      return ChatMessage(
        id: (data['id'] ?? DateTime.now().microsecondsSinceEpoch).toString(),
        role: ChatRole.assistant,
        text: data['reply'] as String,
        onTopic: data['onTopic'] != false,
        createdAt:
            DateTime.tryParse((data['createdAt'] ?? '').toString())?.toLocal() ??
                DateTime.now(),
      );
    } on Failure {
      rethrow;
    } on FunctionException catch (e) {
      switch (e.status) {
        case 401:
          throw const AuthenticationFailure(
            'Your session expired. Please log in again.',
          );
        case 429:
          throw const Failure(
            'You are sending messages too fast. Wait a moment and try again.',
          );
        case 503:
          throw const Failure(
            'Chef chat is not set up yet. The developer needs to add the Gemini key.',
          );
        case 502:
          throw const ServerFailure('The chef is busy right now. Try again soon.');
        case 400:
          throw const Failure('Keep your message between 1 and 500 characters.');
        default:
          throw const ServerFailure();
      }
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  @override
  Future<void> clear() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _client.from(_table).delete().eq('user_id', userId);
    } catch (_) {
      throw const ServerFailure('Could not clear your chat.');
    }
  }

  ChatMessage _fromRow(Map<String, dynamic> row) => ChatMessage(
        id: row['id'].toString(),
        role: row['role'] == 'assistant' ? ChatRole.assistant : ChatRole.user,
        text: (row['content'] ?? '').toString(),
        onTopic: row['on_topic'] != false,
        createdAt: DateTime.tryParse((row['created_at'] ?? '').toString())
                ?.toLocal() ??
            DateTime.now(),
      );
}
