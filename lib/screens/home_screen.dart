import 'package:flutter/material.dart';

import 'app_bar.dart';
import 'premium_effects.dart';
import 'signup_page/login_page.dart';
import 'signup_page/signup_page.dart';
import 'signup_page/google_login_page.dart';
import 'signup_page/github_regis_page.dart';
import 'transition_animations.dart';
import 'button_buldge.dart';
import 'home_animation.dart';
import 'frequently_asked/frequently_asked.dart';

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
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
    _textController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textController.forward();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _textController.dispose();
    _accessCodeController.dispose();
    super.dispose();
  }

  void _goToLoginPage() => Navigator.of(context).push(PremiumTransitions.slideRight(const LoginPage()));
  void _goToSignupPage() => Navigator.of(context).push(PremiumTransitions.slideRight(const SignupPage()));
  void _goToGoogleLoginPage() => Navigator.of(context).push(PremiumTransitions.slideRight(const GoogleLoginPage()));
  void _goToGitHubPage() => Navigator.of(context).push(PremiumTransitions.slideRight(const GitHubRegisPage()));
  void _goToFAQPage() => Navigator.of(context).push(PremiumTransitions.slideRight(const FrequentlyAskedScreen()));

  void _handleAccessCode() {
    if (_accessCodeController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter an access code');
    } else {
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
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800;
    double headlineSize = isMobile ? 40 : 72;
    double subHeadlineSize = isMobile ? 14 : 18;
    double sectionTitleSize = isMobile ? 40 : 72;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PremiumAppBar(),
      body: Stack(
        children: [
          const HomeAnimation(),
          PremiumBackgroundStack(
            bgController: _bgController,
            showMovingDots: true,
            baseColor: Colors.transparent,
            child: const SizedBox.expand(),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- HERO SECTION ---
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: Center(
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
                                'SYSTEM ONLINE',
                                style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                              ),
                            ),
                            const SizedBox(height: 32),
                            FadeInOnTextAnimation(
                              controller: _textController,
                              child: Text(
                                '< Coming very soon >\n< stay tuned >',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: '__copernicus_669e4a',
                                  color: Colors.white,
                                  fontSize: headlineSize,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                  letterSpacing: -1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            FadeInOnTextAnimation(
                              controller: _textController,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 40),
                                child: Text(
                                  'We are crafting something extraordinary. Join the next-gen agent platform built by Anubhav Singh Rajput.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: subHeadlineSize,
                                    fontWeight: FontWeight.w300,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.center,
                              children: [
                                ButtonBulge(
                                  child: AuraButton(
                                    onPressed: _goToLoginPage,
                                    auraController: _bgController,
                                    width: 150,
                                    height: 40,
                                    child: _buildButtonContent('sign in', Icons.arrow_forward),
                                  ),
                                ),
                                ButtonBulge(
                                  child: AuraButton(
                                    onPressed: _goToSignupPage,
                                    outlined: true,
                                    auraController: _bgController,
                                    width: 150,
                                    height: 40,
                                    child: _buildButtonContent('create', Icons.person_add_outlined),
                                  ),
                                ),
                                ButtonBulge(
                                  child: AuraButton(
                                    onPressed: _goToFAQPage,
                                    outlined: true,
                                    auraController: _bgController,
                                    width: 150,
                                    height: 40,
                                    child: _buildButtonContent('F.A.Q.s', Icons.help_outline_rounded),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- SECOND SECTION: ACCESS CODE ---
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                      child: Column(
                        children: [
                          Text(
                            "< Early Access >",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: sectionTitleSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: '__copernicus_669e4a'
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Register to receive Beta version updates.",
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                          ),
                          const SizedBox(height: 30),
                          FadeInOnTextAnimation(
                            controller: _textController,
                            child: Container(
                              width: isMobile ? screenWidth * 0.8 : 320,
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
                                      style: const TextStyle(color: Colors.white, fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: 'Enter access code...',
                                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  ButtonBulge(
                                    child: Container(
                                      margin: const EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                      child: IconButton(
                                        icon: const Icon(Icons.arrow_forward, color: Colors.black, size: 18),
                                        onPressed: _handleAccessCode,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              ButtonBulge(
                                child: AuraButton(
                                  onPressed: _goToGitHubPage,
                                  auraController: _bgController,
                                  width: 150,
                                  height: 40,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.code, size: 18, color: Colors.black),
                                      const SizedBox(width: 8),
                                      const Text('GitHub', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15))
                                    ],
                                  ),
                                ),
                              ),
                              ButtonBulge(
                                child: AuraButton(
                                  onPressed: _goToGoogleLoginPage,
                                  outlined: true,
                                  auraController: _bgController,
                                  width: 150,
                                  height: 40,
                                  style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.grey[300],
                                      side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.g_mobiledata, size: 20, color: Colors.white),
                                      const SizedBox(width: 8),
                                      const Text('Google', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15))
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          GestureDetector(
                            onTap: _goToFAQPage,
                            child: Text(
                              "Frequently Asked Questions",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonContent(String text, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 16),
      ],
    );
  }
}
