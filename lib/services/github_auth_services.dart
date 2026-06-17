import 'package:supabase_flutter/supabase_flutter.dart';

class GitHubAuthService {

  static final GitHubAuthService _instance = GitHubAuthService._internal();
  factory GitHubAuthService() => _instance;
  GitHubAuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Trigger karta hai github auth flow
  Future<void> signInWithGitHub() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.github,
        // Change this to your actual deployed domain (e.g., https://quantnews.vercel.app)
        redirectTo: 'http://localhost:3000',
      );
    } on AuthException catch (e) {
      throw Exception('Supabase Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }


  bool get isSignedIn => _supabase.auth.currentSession != null;


  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
