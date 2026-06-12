import 'package:flutter/material.dart';
import '../premium_effects.dart';
import '../transition_animations.dart';
import '../../services/github_auth_services.dart';
import 'congrats_page.dart';

class GitHubRegisPage extends StatefulWidget {
  const GitHubRegisPage({super.key});

  @override
  State<GitHubRegisPage> createState() => _GitHubRegisPageState();
}

class _GitHubRegisPageState extends State<GitHubRegisPage> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _textController;

  // YE  Loading state make usre karti hai ki premature opening and immature clicks ke karan usri screens render na hon
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

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

  // guthub authentication service ko trigger karna
  Future<void> _handleGitHubAuth() async {
    // 1. Immediately lock the UI to prevent double-clicks or premature logic
    setState(() => _isSubmitting = true);

    try {
      // 2. Await karna hai actual authentication proccess ka
      await GitHubAuthService().signInWithGitHub();

      // tabhi navigate kareha jab widget still cue ya tree me hai
      // and the await above completed without throwing an error.
      if (!mounted) return;

      // SUCCESS: then congrats page pe redirect kar dega
      Navigator.of(context).pushReplacement(
        PremiumTransitions.zoomFade(
          CongratsPage(
            authMethod: "GitHub",
            authAction: "signed in",
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      // 4.sare ui ko unlock kar dega regardless of success or failure
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
      body: PremiumBackgroundStack(
        bgController: _bgController,
        showMovingDots: true,
        showFluidMesh: true,
        baseColor: const Color(0xFF070709),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Text(
                      'SECURE ACCESS',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuraHeadline(
                    controller: _textController,
                    fullText: 'Authorize QuantMessage via GitHub',
                    highlightPart: 'GitHub',
                    auraController: _bgController,
                  ),
                  const SizedBox(height: 16),
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: Text(
                      'Connect your developer profile to access institutional grade financial data and QuantNews premium tools.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  //  AUTHORIZATION BUTTON
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: AuraButton(
                      // button ko disable karna to avoaid multiple clicks
                      onPressed: _isSubmitting ? null : _handleGitHubAuth,
                      auraController: _bgController,
                      child: _isSubmitting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.code, size: 20, color: Colors.white),
                          const SizedBox(width: 12),
                          const Text(
                            'Continue with GitHub',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Back to Registration',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
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
