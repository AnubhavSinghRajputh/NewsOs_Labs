import 'package:flutter/material.dart';

import 'app_bar.dart';
import 'premium_effects.dart';
import 'signup_page/login_page.dart';
import 'signup_page/signup_page.dart';
import 'signup_page/google_login_page.dart';
import 'signup_page/github_regis_page.dart';
import 'transition_animations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _textController;

  final TextEditingController _accessCodeController = TextEditingController();

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
    _accessCodeController.dispose();
    super.dispose();
  }

  // --- NAVIGATION FLOWS ---
  // These use slideRight to enter the auth portal

  void _goToLoginPage() {
    Navigator.of(context).push(
      PremiumTransitions.slideRight(const LoginPage()),
    );
  }

  void _goToSignupPage() {
    Navigator.of(context).push(
      PremiumTransitions.slideRight(const SignupPage()),
    );
  }

  void _goToGoogleLoginPage() {
    Navigator.of(context).push(
      PremiumTransitions.slideRight(const GoogleLoginPage()),
    );
  }

  void _goToGitHubPage() {
    Navigator.of(context).push(
      PremiumTransitions.slideRight(const GitHubRegisPage()),
    );
  }

  void _handleAccessCode() {
    final code = _accessCodeController.text.trim();
    if (code.isEmpty) {
      _showErrorSnackBar('Please enter an access code');
    } else {
      // Assuming valid code takes them to login
      _goToLoginPage();
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
      appBar: const PremiumAppBar(),
      body: PremiumBackgroundStack(
        bgController: _bgController,
        showMovingDots: true,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // System Status Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Text(
                      'SYSTEM ONLINE',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Animated Headline
                  AuraHeadline(
                    controller: _textController,
                    fullText: '< coming soon > stay tuned',
                    highlightPart: '< coming soon >',
                    auraController: _bgController,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: Text(
                      'We are crafting something extraordinary. Enter your key to pre-register. built by Anubhav Singh Rajput',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Access Code Field
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: Container(
                      width: 320,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _accessCodeController,
                              style: const TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 1.0),
                              decoration: InputDecoration(
                                hintText: 'Enter access code...',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward, color: Colors.black, size: 18),
                              onPressed: _handleAccessCode,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 1. PRIMARY SIGN IN BUTTON
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: AuraButton(
                      onPressed: _goToLoginPage,
                      auraController: _bgController,
                      child: _buildButtonContent('sign in', Icons.arrow_forward),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. SECONDARY CREATE BUTTON
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: AuraButton(
                      onPressed: _goToSignupPage,
                      outlined: true,
                      auraController: _bgController,
                      child: _buildButtonContent('create', Icons.person_add_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Glassy Grey Divider
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.2),
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. GITHUB AUTH BUTTON
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: AuraButton(
                      onPressed: _goToGitHubPage,
                      auraController: _bgController,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.code, size: 18, color: Colors.black),
                          const SizedBox(width: 8),
                          const Text(
                            'continue with github',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4. GOOGLE AUTH BUTTON
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: AuraButton(
                      onPressed: _goToGoogleLoginPage,
                      outlined: true,
                      auraController: _bgController,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[300],
                        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.g_mobiledata, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          const Text(
                            'continue with google',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(String text, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.0),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 18),
      ],
    );
  }
}
