import 'package:three_bhai/core/usecase/usecase.dart';
import 'package:three_bhai/features/chat/domain/entities/chat_message.dart';
import 'package:three_bhai/features/chat/domain/repositories/chat_repository.dart';

class LoadChat implements UseCase<List<ChatMessage>, NoParams> {
  const LoadChat(this._repository);
  final ChatRepository _repository;

  @override
  Future<List<ChatMessage>> call(NoParams params) =>
      _repository.loadMessages();
}

class SendChatMessage implements UseCase<ChatMessage, String> {
  const SendChatMessage(this._repository);
  final ChatRepository _repository;

  @override
  Future<ChatMessage> call(String params) => _repository.send(params);
}

class ClearChat implements UseCase<void, NoParams> {
  const ClearChat(this._repository);
  final ChatRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.clear();
}
