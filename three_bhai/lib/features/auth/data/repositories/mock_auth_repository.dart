import 'package:three_bhai/core/error/failures.dart';
import 'package:three_bhai/features/auth/domain/entities/auth_user.dart';
import 'package:three_bhai/features/auth/domain/repositories/auth_repository.dart';

/// DEMO MODE ONLY (used when Supabase keys are not configured).
/// Each email gets its own user id, so local history stays separate per user.
/// Tip: an email containing "fail" previews the error state.
class MockAuthRepository implements AuthRepository {
  AuthUser? _current;

  @override
  AuthUser? get currentUser => _current;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (email.contains('fail')) throw const AuthenticationFailure();
    return _current = _user(email, 'Chef');
  }

  @override
  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (email.contains('fail')) {
      throw const Failure('An account with this email already exists.');
    }
    return _current = _user(email, name);
  }

  @override
  Future<void> signOut() async => _current = null;

  AuthUser _user(String email, String name) => AuthUser(
        id: 'demo-${email.trim().toLowerCase()}',
        email: email.trim(),
        displayName: name,
      );
}
