import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:three_bhai/core/error/failures.dart';
import 'package:three_bhai/features/auth/domain/entities/auth_user.dart';
import 'package:three_bhai/features/auth/domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final supabase.SupabaseClient _client;

  @override
  AuthUser? get currentUser {
    final user = _client.auth.currentUser;
    return user == null ? null : _map(user);
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth
          .signInWithPassword(email: email.trim(), password: password);
      final user = res.user;
      if (user == null) throw const AuthenticationFailure();
      return _map(user);
    } on Failure {
      rethrow;
    } on supabase.AuthException catch (e) {
      throw _fromAuth(e);
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  @override
  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name},
      );
      final user = res.user;
      if (user == null) throw const Failure('Could not create the account.');
      if (res.session == null) {
        // Email confirmation is switched on in the Supabase project.
        throw const Failure(
          'Account created. Confirm your email, then log in.',
        );
      }
      return _map(user);
    } on Failure {
      rethrow;
    } on supabase.AuthException catch (e) {
      throw _fromAuth(e);
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  AuthUser _map(supabase.User user) => AuthUser(
        id: user.id,
        email: user.email ?? '',
        displayName: user.userMetadata?['name'] as String?,
      );

  Failure _fromAuth(supabase.AuthException e) {
    final m = e.message.toLowerCase();
    if (m.contains('invalid login')) return const AuthenticationFailure();
    if (m.contains('already registered')) {
      return const Failure('An account with this email already exists.');
    }
    if (m.contains('email not confirmed')) {
      return const Failure('Confirm your email first, then log in.');
    }
    return Failure(e.message);
  }
}
