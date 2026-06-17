import 'dart:async';
import 'package:flutter/material.dart';
import '../premium_effects.dart';

class ComputingAnimation extends StatefulWidget {
  const ComputingAnimation({Key? key}) : super(key: key);

  @override
  State<ComputingAnimation> createState() => _ComputingAnimationState();
}

class _ComputingAnimationState extends State<ComputingAnimation>
    with TickerProviderStateMixin {

  late AnimationController _auraController;

  final List<String> _targetWords = [
    "#People",
    "#Coders",
    "#Teams",
    "#Hustlers",
    "#Students",
  ];

  String _currentWord = "";
  int _wordIndex = 0;

  final List<String> _statuses = [
    "synthesising",
    "analysing",
    "reviewing",
    "sending",
    "receiving",
    "managing",
  ];
  int _statusIndex = 0;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _startTypingCycle();
    _startStatusRotation();
  }

  void _startTypingCycle() async {
    while (mounted) {
      String target = _targetWords[_wordIndex];
      for (int i = 0; i <= target.length; i++) {
        if (!mounted) return;
        setState(() => _currentWord = target.substring(0, i));
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await Future.delayed(const Duration(milliseconds: 1500));
      for (int i = target.length; i >= 0; i--) {
        if (!mounted) return;
        setState(() => _currentWord = target.substring(0, i));
        await Future.delayed(const Duration(milliseconds: 50));
      }
      setState(() => _wordIndex = (_wordIndex + 1) % _targetWords.length);
    }
  }

  void _startStatusRotation() {
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() => _statusIndex = (_statusIndex + 1) % _statuses.length);
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _auraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 650,
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          children: [


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CirculatingAura(
                  controller: _auraController,
                  borderRadius: 30,
                  glowColor: Colors.greenAccent.withOpacity(0.3),
                  accentColor: Colors.greenAccent,
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0C),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 4)],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "${_statuses[_statusIndex]}...",
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 15,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            // TEXT SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text(
                  "    Built for  > ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    letterSpacing: -2.0,
                  ),
                ),


                SizedBox(
                  width: 300,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Text(
                        _currentWord,
                        style: const TextStyle(
                          color: Color(0xFFB87333),
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          letterSpacing: -2.0,
                        ),
                      ),
                      Positioned(
                        left: _calculateTextWidth(_currentWord),
                        child: _buildBlinkingCursor(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  double _calculateTextWidth(String text) {
    //Approximate width per character for Inter Bold 64px
    //In a real production app, use TextPainter for exact pixels
    return text.length * 32.0;
  }

  Widget _buildBlinkingCursor() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 3,
            height: 55,
            color: Colors.white.withOpacity(0.8),
          ),
        );
      },
    );
  }
}
