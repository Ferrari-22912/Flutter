import 'package:three_bhai/features/auth/domain/entities/auth_user.dart';

/// Contract implemented in the data layer (Supabase Auth in Phase 2).
/// Implementations throw [Failure] subclasses on error.
abstract interface class AuthRepository {
  /// The signed-in user, or null. Restored automatically after app restarts.
  AuthUser? get currentUser;

  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();
}
