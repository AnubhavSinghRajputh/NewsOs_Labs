import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_bar.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _textController;
  @override
  void initState() {
    super.initState();
    // Background animation: continuous loop
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    // Text typing animation controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    // Start typing after a short delay
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PremiumAppBar(title: 'QUANTNEWS'),
      body: Stack(
        children: [
          // 1. Constant Premium Background Animation (Fluid Mesh/Aurora Painter)
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return CustomPaint(
                painter: FluidBackgroundPainter(animationValue: _bgController.value),
                child: Container(),
              );
            },
          ),

          // Subtle Dark Vignette Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // 2. Foreground Typing Animated Text
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Small decorative tag
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
                          color: Colors.grey,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Typing Animation widget
                    TypingTextAnimation(
                      controller: _textController,
                      fullText: "coming soon stay tuned",
                    ),
                    const SizedBox(height: 16),
                    // Ambient subtitle indicating progress
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: Curves.easeIn.transform(_textController.value),
                          child: child,
                        );
                      },
                      child: Text(
                        'We are crafting something extraordinary. Enter your key to pre-register.',
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
                    // Interactive glassmorphic text field
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: Curves.easeIn.transform(_textController.value),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 320,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  letterSpacing: 1.0,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter access code...',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.2),
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward, color: Colors.black, size: 18),
                                onPressed: () {},
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
        ],
      ),
    );
  }
}
/// A Custom Painter that draws smooth, organic moving gradient blobs for a premium background.
class FluidBackgroundPainter extends CustomPainter {
  final double animationValue;
  FluidBackgroundPainter({required this.animationValue});
  @override
  void paint(Canvas canvas, Size size) {
    final paintBlob1 = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
    final paintBlob2 = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 140);
    final paintBlob3 = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    // Center coordinates
    final cx = size.width / 2;
    final cy = size.height / 2;
    // Background base
    final basePaint = Paint()..color = const Color(0xFF070709);
    canvas.drawRect(Offset.zero & size, basePaint);
    // Calculate motion paths using trigonometry
    final angle = animationValue * 2 * math.pi;
    // Blob 1: Moving in a circular path in top-right area (Cold White/Grey glow)
    final b1x = cx + math.cos(angle) * (size.width * 0.25) + 60;
    final b1y = cy + math.sin(angle) * (size.height * 0.15) - 100;
    final radius1 = size.width * 0.45;
    paintBlob1.shader = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.06),
        Colors.white.withOpacity(0.005),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(b1x, b1y), radius: radius1));
    canvas.drawCircle(Offset(b1x, b1y), radius1, paintBlob1);
    // Blob 2: Moving in an oval path in bottom-left area (Deep Slate Grey glow)
    final b2x = cx - math.sin(angle + math.pi / 3) * (size.width * 0.3) - 40;
    final b2y = cy - math.cos(angle + math.pi / 3) * (size.height * 0.2) + 120;
    final radius2 = size.width * 0.5;
    paintBlob2.shader = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.04),
        Colors.white.withOpacity(0.002),
        Colors.transparent,
      ],
      stops: const [0.0, 0.6, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(b2x, b2y), radius: radius2));
    canvas.drawCircle(Offset(b2x, b2y), radius2, paintBlob2);
    // Blob 3: Center-ish slow breathing glow
    final breathScale = 1.0 + 0.1 * math.sin(angle * 2);
    final radius3 = size.width * 0.35 * breathScale;
    paintBlob3.shader = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.03),
        Colors.white.withOpacity(0.001),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius3));
    canvas.drawCircle(Offset(cx, cy), radius3, paintBlob3);
  }
  @override
  bool shouldRepaint(covariant FluidBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
/// Typing animation widget that reveals text letter by letter,
/// with customized white/grey styling and a blinking cursor.
class TypingTextAnimation extends StatefulWidget {
  final AnimationController controller;
  final String fullText;
  const TypingTextAnimation({
    Key? key,
    required this.controller,
    required this.fullText,
  }) : super(key: key);
  @override
  State<TypingTextAnimation> createState() => _TypingTextAnimationState();
}
class _TypingTextAnimationState extends State<TypingTextAnimation> with SingleTickerProviderStateMixin {
  late Animation<int> _characterCount;
  late AnimationController _cursorController;
  bool _showCursor = true;
  @override
  void initState() {
    super.initState();
    // Mapping character reveal to the animation controller
    _characterCount = StepTween(
      begin: 0,
      end: widget.fullText.length,
    ).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.9, curve: Curves.linear),
      ),
    );
    // Cursor blink controller
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showCursor = !_showCursor;
        });
        _cursorController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _showCursor = !_showCursor;
        });
        _cursorController.forward();
      }
    });
    _cursorController.forward();
  }
  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final count = _characterCount.value;
        final visibleText = widget.fullText.substring(0, count);
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 38,
              height: 1.3,
              letterSpacing: -0.5,
            ),
            children: [
              ..._buildStyledSpans(visibleText),
              // Blinking cursor span
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Opacity(
                  opacity: _showCursor ? 1.0 : 0.0,
                  child: Container(
                    width: 2.5,
                    height: 36,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  /// Splitting text to apply a premium color logic (Dynamic white & grey combination)
  /// "coming soon" -> Bold White
  /// "stay tuned" -> Sleek Slate Grey
  List<TextSpan> _buildStyledSpans(String typedText) {
    const part1 = "coming soon";
    const part2 = " stay tuned";

    List<TextSpan> spans = [];
    if (typedText.length <= part1.length) {
      // Still typing part 1: all in white
      spans.add(
        TextSpan(
          text: typedText,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(
                color: Colors.white30,
                blurRadius: 15,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      );
    } else {
      // Part 1 is fully typed, typing part 2
      spans.add(
        const TextSpan(
          text: part1,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(
                color: Colors.white30,
                blurRadius: 15,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      );

      final part2Typed = typedText.substring(part1.length);
      spans.add(
        TextSpan(
          text: part2Typed,
          style: const TextStyle(
            color: Color(0xFF7E7E86), // Premium Slate Grey
            fontWeight: FontWeight.w300,
          ),
        ),
      );
    }
    return spans;
  }
}
