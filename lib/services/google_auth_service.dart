import 'package:supabase_flutter/supabase_flutter.dart';


class GoogleAuthService {
  final SupabaseClient _client;


  GoogleAuthService(this._client);


  User? get currentUser => _client.auth.currentUser;


  bool get isLoggedIn => currentUser != null;


  Future<void> signInWithGoogle() async {
    try {

      await _client.auth.signInWithOAuth(
        OAuthProvider.google,

        // redirectTo: 'http://localhost:XXXXX',
      );
    } on AuthException catch (e) {

      rethrow;
    } catch (e) {

      throw AuthException('An unexpected error occurred during Web Google Auth: ${e.toString()}');
    }
  }


  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AuthException('Unable to sign out: ${e.toString()}');
    }
  }
}
