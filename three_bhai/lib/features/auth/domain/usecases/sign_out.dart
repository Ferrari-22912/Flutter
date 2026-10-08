import 'package:three_bhai/core/usecase/usecase.dart';
import 'package:three_bhai/features/auth/domain/repositories/auth_repository.dart';

class SignOut implements UseCase<void, NoParams> {
  const SignOut(this._repository);
  final AuthRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.signOut();
}
