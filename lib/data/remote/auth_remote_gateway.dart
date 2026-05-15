import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Auth only — used from [CloudSyncController], not from feature UI.
class AuthRemoteGateway {
  User? get currentUser => Supabase.instance.client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange =>
      Supabase.instance.client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithPassword({
    required String email,
    required String password,
  }) {
    return Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() => Supabase.instance.client.auth.signOut();
}
