import 'package:equatable/equatable.dart';
import 'package:three_bhai/core/usecase/usecase.dart';
import 'package:three_bhai/features/auth/domain/entities/auth_user.dart';
import 'package:three_bhai/features/auth/domain/repositories/auth_repository.dart';

class SignUp implements UseCase<AuthUser, SignUpParams> {
  const SignUp(this._repository);
  final AuthRepository _repository;

  @override
  Future<AuthUser> call(SignUpParams params) => _repository.signUp(
        name: params.name,
        email: params.email,
        password: params.password,
      );
}

class SignUpParams extends Equatable {
  const SignUpParams({
    required this.name,
    required this.email,
    required this.password,
  });
  final String name;
  final String email;
  final String password;

  @override
  List<Object?> get props => [name, email, password];
}
