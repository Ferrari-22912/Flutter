import 'package:equatable/equatable.dart';
import 'package:three_bhai/core/usecase/usecase.dart';
import 'package:three_bhai/features/auth/domain/entities/auth_user.dart';
import 'package:three_bhai/features/auth/domain/repositories/auth_repository.dart';

class SignIn implements UseCase<AuthUser, SignInParams> {
  const SignIn(this._repository);
  final AuthRepository _repository;

  @override
  Future<AuthUser> call(SignInParams params) =>
      _repository.signIn(email: params.email, password: params.password);
}

class SignInParams extends Equatable {
  const SignInParams({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
