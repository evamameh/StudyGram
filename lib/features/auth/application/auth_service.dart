import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pulso/features/auth/data/auth_operations.dart';

/// Wraps signup/login/logout for Supabase auth.
class AuthService {
  AuthService({required AuthOperations authOperations}) : _auth = authOperations;

  final AuthOperations _auth;

  Session? get currentSession => _auth.currentSession;

  Stream<Session?> authSessionChanges() =>
      _auth.onAuthStateChange.map((event) => event.session);

  /// Returns the auth response so callers can show "confirm email" when session is null.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final displayName = '$firstName $lastName'.trim();
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'full_name': displayName,
      },
    );
    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> signOut() => _auth.signOut();
}
