import 'package:equatable/equatable.dart';

enum ChatRole { user, assistant }

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.onTopic = true,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime createdAt;

  /// False when the assistant politely refused an out-of-scope question.
  final bool onTopic;

  @override
  List<Object?> get props => [id, role, text, createdAt, onTopic];
}
