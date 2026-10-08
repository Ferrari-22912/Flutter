import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:three_bhai/core/error/failures.dart';
import 'package:three_bhai/core/usecase/usecase.dart';
import 'package:three_bhai/features/auth/domain/entities/auth_user.dart';
import 'package:three_bhai/features/auth/domain/usecases/sign_in.dart';
import 'package:three_bhai/features/auth/domain/usecases/sign_out.dart';
import 'package:three_bhai/features/auth/domain/usecases/sign_up.dart';
import 'package:three_bhai/features/auth/presentation/bloc/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required SignIn signIn,
    required SignUp signUp,
    required SignOut signOut,
  })  : _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        super(const AuthInitial());

  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;

  Future<void> signIn({required String email, required String password}) =>
      _run(() => _signIn(SignInParams(email: email, password: password)));

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) =>
      _run(() => _signUp(
            SignUpParams(name: name, email: email, password: password),
          ));

  /// Always ends in [AuthInitial] so the login screen starts clean,
  /// even if the remote sign-out call fails.
  Future<void> signOut() async {
    try {
      await _signOut(const NoParams());
    } catch (_) {
      // Local session is cleared regardless.
    }
    emit(const AuthInitial());
  }

  Future<void> _run(Future<AuthUser> Function() action) async {
    if (state is AuthLoading) return;
    emit(const AuthLoading());
    try {
      emit(AuthSuccess(await action()));
    } on Failure catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(const AuthFailure('Something went wrong. Please try again.'));
    }
  }
}
