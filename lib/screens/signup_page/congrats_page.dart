import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../premium_effects.dart';
import '../transition_animations.dart';

class CongratsPage extends StatefulWidget {
  final String authMethod; // "Google", "GitHub", "Email"
  final String authAction; // "created", "logged in", "signed in"

  const CongratsPage({
    super.key,
    required this.authMethod,
    required this.authAction,
  });

  @override
  State<CongratsPage> createState() => _CongratsPageState();
}

class _CongratsPageState extends State<CongratsPage> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _textController;

  // NEW: GUARD VARIABLE AUTH STATUS TO TRACK DOWN KAREGA
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // YE VARIABLE STATE GUARD KA ENTRY POINT HAI
    _verifySession();
  }

  /// This method ensures the user is actually logged in before showing the UI
  Future<void> _verifySession() async {
    // 1. CHECK KARO KI SUPABSE KA SESSION SACH ME EXIA=ST KARTA HAI YA NAHI ????????
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      // 2. AGAR SESSION NAHI MILA TOH USER LOGIN HE NAHI HAI BC
      // SALO KO FATFAT SE LOGIN PAGE PE BHEJO
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
        // ENSURE KARO KI MAIN.DART ME LOGIN KE ROUTES DEFINED HAIN BECAUSE USKE BINA LOGIN SESSION INITALISE KAHA SE HOGGA
      }
    } else {
      // 3. SESSION EXXIST KARTA HAI TOH ANIMATIONS KO TRIGGER KAOR AND AAGE PROCEED KARO
      setState(() {
        _isVerified = true;
      });
      _textController.forward();
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _textController.dispose();
    super.dispose();
  }

  String _buildPremiumMessage() {
    switch (widget.authAction) {
      case "created":
        return "Welcome to the fold! Your secure account has been successfully initialized via ${widget.authMethod}.";
      case "logged in":
        return "Welcome back! Your session has been successfully restored via ${widget.authMethod}.";
      case "signed in":
        return "Identity verified. You have successfully signed in using your ${widget.authMethod} credentials.";
      default:
        return "Access granted. You have successfully connected via ${widget.authMethod}.";
    }
  }

  @override
  Widget build(BuildContext context) {
    // PREVENT PREMATURE UI RENDERING
    // If the session hasn't been verified yet, show a loading screen
    // instead of the "Success" message.
    if (!_isVerified) {
      return Scaffold(
        backgroundColor: const Color(0xFF070709),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      );
    }

    // tabhi verify hoga jab ki  _isVerified == true
    return Scaffold(
      body: PremiumBackgroundStack(
        bgController: _bgController,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AuraHeadline(
                  controller: _textController,
                  fullText: "Success!",
                  highlightPart: "Success!",
                  auraController: _bgController,
                  borderRadius: 25,
                ),
                const SizedBox(height: 30),
                TypingTextAnimation(
                  controller: _textController,
                  fullText: _buildPremiumMessage(),
                  highlightPart: "",
                ),
                const SizedBox(height: 60),
                AuraButton(
                  auraController: _bgController,
                  borderRadius: 30,
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  },
                  child: const Text(
                    "Continue to Home",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
