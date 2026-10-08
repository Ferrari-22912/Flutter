import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_bhai/core/error/failures.dart';
import 'package:three_bhai/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:three_bhai/features/chat/data/repositories/local_chat_repository.dart';
import 'package:three_bhai/features/chat/domain/entities/chat_message.dart';
import 'package:three_bhai/features/chat/domain/repositories/chat_repository.dart';
import 'package:three_bhai/features/chat/domain/usecases/chat_usecases.dart';
import 'package:three_bhai/features/chat/presentation/bloc/chat_cubit.dart';

class _FailingChat implements ChatRepository {
  @override
  Future<List<ChatMessage>> loadMessages() async => [];
  @override
  Future<ChatMessage> send(String text) async =>
      throw const Failure('Too many messages');
  @override
  Future<void> clear() async {}
}

ChatCubit _cubit(ChatRepository repo) => ChatCubit(
      load: LoadChat(repo),
      send: SendChatMessage(repo),
      clear: ClearChat(repo),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('failed send removes the pending bubble and keeps the text', () async {
    final cubit = _cubit(_FailingChat());
    await cubit.load();
    await cubit.send('How do I boil eggs?');
    expect(cubit.state.messages, isEmpty);
    expect(cubit.state.failedText, 'How do I boil eggs?');
    expect(cubit.state.errorMessage, 'Too many messages');
    await cubit.close();
  });

  test('each user has a separate chat', () async {
    SharedPreferences.setMockInitialValues({});
    final auth = MockAuthRepository();
    final repo = LocalChatRepository(auth);

    await auth.signIn(email: 'asha@3bhai.app', password: 'x');
    await repo.send('Hello chef');
    expect((await repo.loadMessages()).length, 2);

    await auth.signOut();
    await auth.signIn(email: 'bilal@3bhai.app', password: 'x');
    expect(await repo.loadMessages(), isEmpty);
  });

  test('ignores empty and oversized messages', () async {
    final cubit = _cubit(_FailingChat());
    await cubit.load();
    await cubit.send('   ');
    await cubit.send('x' * 501);
    expect(cubit.state.messages, isEmpty);
    expect(cubit.state.errorMessage, isNull);
    await cubit.close();
  });
}
