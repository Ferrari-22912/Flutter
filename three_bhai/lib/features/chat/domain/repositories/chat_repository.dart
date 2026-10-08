import 'package:three_bhai/features/chat/domain/entities/chat_message.dart';

/// One private thread per signed-in user.
abstract interface class ChatRepository {
  Future<List<ChatMessage>> loadMessages();

  /// Sends [text] and returns the assistant's reply. The server stores both
  /// turns. Throws a [Failure] on errors.
  Future<ChatMessage> send(String text);

  Future<void> clear();
}
