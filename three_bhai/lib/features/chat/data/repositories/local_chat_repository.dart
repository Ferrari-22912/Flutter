import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_bhai/features/auth/domain/repositories/auth_repository.dart';
import 'package:three_bhai/features/chat/domain/entities/chat_message.dart';
import 'package:three_bhai/features/chat/domain/repositories/chat_repository.dart';

/// DEMO MODE: no AI is available without Supabase + Gemini, so the assistant
/// explains how to switch it on. Messages are still kept per user on-device.
class LocalChatRepository implements ChatRepository {
  LocalChatRepository(this._auth);

  final AuthRepository _auth;
  static const _maxItems = 100;

  String get _key => 'chat_v1_${_auth.currentUser?.id ?? 'signed_out'}';

  static const _demoReply =
      'Chef chat is in demo mode. To talk to the real Chef Bhai, connect '
      'Supabase and add your Gemini key (see SETUP_SUPABASE_GEMINI.md). '
      'Your own private chat will then work here.';

  Future<List<Map<String, dynamic>>> _rows() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _write(List<Map<String, dynamic>> rows) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = rows.length > _maxItems
        ? rows.sublist(rows.length - _maxItems)
        : rows;
    await prefs.setString(_key, jsonEncode(trimmed));
  }

  @override
  Future<List<ChatMessage>> loadMessages() async => (await _rows())
      .map((r) => ChatMessage(
            id: r['id'].toString(),
            role: r['role'] == 'assistant' ? ChatRole.assistant : ChatRole.user,
            text: r['text'].toString(),
            createdAt: DateTime.parse(r['at'].toString()),
          ))
      .toList();

  @override
  Future<ChatMessage> send(String text) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final now = DateTime.now();
    final reply = ChatMessage(
      id: 'a${now.microsecondsSinceEpoch}',
      role: ChatRole.assistant,
      text: _demoReply,
      createdAt: now,
    );
    final rows = await _rows();
    rows
      ..add({
        'id': 'u${now.microsecondsSinceEpoch}',
        'role': 'user',
        'text': text,
        'at': now.toIso8601String(),
      })
      ..add({
        'id': reply.id,
        'role': 'assistant',
        'text': reply.text,
        'at': now.add(const Duration(milliseconds: 1)).toIso8601String(),
      });
    await _write(rows);
    return reply;
  }

  @override
  Future<void> clear() => _write([]);
}
