import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_bar.dart';
import '../premium_effects.dart';
import '../transition_animations.dart';
import '../../services/google_auth_service.dart';
import 'congrats_page.dart';

class GoogleLoginPage extends StatefulWidget {
  const GoogleLoginPage({Key? key}) : super(key: key);

  @override
  State<GoogleLoginPage> createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _textController;
  late final GoogleAuthService _googleAuthService;

  // loading state hai jo ki premature triggers ko stop karta hai

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _googleAuthService = GoogleAuthService(Supabase.instance.client);

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    // 1. LOCK the UI immediately.
    // This prevents the user from clicking again and ensures the app knows it's "working"
    setState(() => _isSubmitting = true);

    try {
      // 2. WAIT for the Google Auth Service to fully resolve.
      // If this method fails, it will jump straight to the 'catch' block.
      await _googleAuthService.signInWithGoogle();

      // 3. SAFETY CHECK: Ensure the user is still on this page after the await.
      if (!mounted) return;

      // 4. SUCCESS: tab  sirf congrats peage  pe navigate karega
      // pushReplacement ensures they can't go back to this login screen.
      Navigator.of(context).pushReplacement(
        PremiumTransitions.zoomFade(
          CongratsPage(
            authMethod: "Google",
            authAction: "logged in",
          ),
        ),
      );
    } on AuthException catch (e) {
      if (mounted) _showErrorSnackBar(e.message);
    } catch (e) {
      if (mounted) _showErrorSnackBar('An unexpected error occurred during Google Auth.');
    } finally {
      // 5. UNLOCK the UI so the user can try again if they failed.
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A1F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PremiumAppBar(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.white.withOpacity(0.8), size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 12),
            const Text(
              'GOOGLE AUTH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
      body: PremiumBackgroundStack(
        bgController: _bgController,
        showMovingDots: true,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Text(
                      'AUTHORIZATION PROTOCOL',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AuraHeadline(
                    controller: _textController,
                    fullText: '< /connecting > google_auth',
                    highlightPart: '< /connecting >',
                  ),
                  const SizedBox(height: 16),
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: Text(
                      'Securely synchronize your Google identity with QuantMessage to access your personalized workspace.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.05),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.g_mobiledata,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: AuraButton(
                      // DISABLE button while submitting
                      onPressed: _isSubmitting ? null : _handleGoogleSignIn,
                      child: _isSubmitting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black, // Keeping consistent with AuraButton style
                        ),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'authorize account',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.lock_open, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
