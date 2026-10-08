import 'package:flutter_test/flutter_test.dart';
import 'package:three_bhai/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:three_bhai/features/auth/domain/usecases/sign_in.dart';
import 'package:three_bhai/features/auth/domain/usecases/sign_out.dart';
import 'package:three_bhai/features/auth/domain/usecases/sign_up.dart';
import 'package:three_bhai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:three_bhai/features/auth/presentation/bloc/auth_state.dart';

void main() {
  AuthCubit build() {
    final repo = MockAuthRepository();
    return AuthCubit(
      signIn: SignIn(repo),
      signUp: SignUp(repo),
      signOut: SignOut(repo),
    );
  }

  test('sign in emits loading then success', () async {
    final cubit = build();
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([isA<AuthLoading>(), isA<AuthSuccess>()]),
    );
    await cubit.signIn(email: 'chef@3bhai.app', password: 'secret123');
    await expectation;
    await cubit.close();
  });

  test('sign in emits loading then failure', () async {
    final cubit = build();
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([isA<AuthLoading>(), isA<AuthFailure>()]),
    );
    await cubit.signIn(email: 'fail@3bhai.app', password: 'secret123');
    await expectation;
    await cubit.close();
  });

  test('sign out returns to initial state', () async {
    final cubit = build();
    await cubit.signIn(email: 'chef@3bhai.app', password: 'secret123');
    expect(cubit.state, isA<AuthSuccess>());
    await cubit.signOut();
    expect(cubit.state, isA<AuthInitial>());
    await cubit.close();
  });
}
