import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:three_bhai/core/error/failures.dart';
import 'package:three_bhai/core/usecase/usecase.dart';
import 'package:three_bhai/features/chat/domain/entities/chat_message.dart';
import 'package:three_bhai/features/chat/domain/usecases/chat_usecases.dart';

enum ChatStatus { loading, ready, failure }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.loading,
    this.messages = const [],
    this.isSending = false,
    this.errorMessage,
    this.failedText,
  });

  final ChatStatus status;
  final List<ChatMessage> messages;
  final bool isSending;

  /// Shown once as a snackbar, then cleared.
  final String? errorMessage;

  /// The text that failed to send, so the input box can be refilled.
  final String? failedText;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    bool? isSending,
    String? errorMessage,
    String? failedText,
    bool clearError = false,
  }) =>
      ChatState(
        status: status ?? this.status,
        messages: messages ?? this.messages,
        isSending: isSending ?? this.isSending,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        failedText: clearError ? null : (failedText ?? this.failedText),
      );

  @override
  List<Object?> get props =>
      [status, messages, isSending, errorMessage, failedText];
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required LoadChat load,
    required SendChatMessage send,
    required ClearChat clear,
  })  : _load = load,
        _send = send,
        _clear = clear,
        super(const ChatState());

  final LoadChat _load;
  final SendChatMessage _send;
  final ClearChat _clear;

  Future<void> load() async {
    emit(const ChatState());
    try {
      emit(ChatState(
        status: ChatStatus.ready,
        messages: await _load(const NoParams()),
      ));
    } on Failure catch (e) {
      emit(ChatState(status: ChatStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(const ChatState(
        status: ChatStatus.failure,
        errorMessage: 'Could not load your chat.',
      ));
    }
  }

  Future<void> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || text.length > 500 || state.isSending) return;

    final pending = ChatMessage(
      id: 'pending-${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.user,
      text: text,
      createdAt: DateTime.now(),
    );
    emit(state.copyWith(
      messages: [...state.messages, pending],
      isSending: true,
      clearError: true,
    ));

    try {
      final reply = await _send(text);
      emit(state.copyWith(
        messages: [...state.messages, reply],
        isSending: false,
      ));
    } on Failure catch (e) {
      _fail(pending, text, e.message);
    } catch (_) {
      _fail(pending, text, 'Something went wrong. Please try again.');
    }
  }

  void _fail(ChatMessage pending, String text, String message) {
    emit(state.copyWith(
      messages: state.messages.where((m) => m.id != pending.id).toList(),
      isSending: false,
      errorMessage: message,
      failedText: text,
    ));
  }

  void errorShown() => emit(state.copyWith(clearError: true));

  Future<void> clear() async {
    final before = state.messages;
    emit(state.copyWith(messages: const [], clearError: true));
    try {
      await _clear(const NoParams());
    } catch (_) {
      emit(state.copyWith(
        messages: before,
        errorMessage: 'Could not clear your chat.',
      ));
    }
  }
}
