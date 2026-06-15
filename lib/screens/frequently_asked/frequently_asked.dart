import 'package:flutter/material.dart';
import '../premium_effects.dart';

class FAQItem {
  final String question;
  final String answer;
  const FAQItem({required this.question, required this.answer});
}


class FrequentlyAskedScreen extends StatefulWidget {
  const FrequentlyAskedScreen({Key? key}) : super(key: key);

  @override
  State<FrequentlyAskedScreen> createState() => _FrequentlyAskedScreenState();
}

class _FrequentlyAskedScreenState extends State<FrequentlyAskedScreen>
    with TickerProviderStateMixin {
  int? _expandedIndex;
  late final AnimationController _bgController;
  late final AnimationController _entryController;
  late final Animation<double> _entryOpacity;
  late final Animation<Offset> _entrySlide;

  static const _faqs = <FAQItem>[
    FAQItem(
      question: 'What is QuantMessage and how does it work?',
      answer:
      'QuantMessage is an advanced, AI-powered messaging and agentic management platform '
          'built for fast, secure team communications and automated tool integration. '
          'It processes complex data flows and helps teams collaborate effortlessly '
          'with custom AI assistant workflows.\n\nYou can use QuantMessage to automate '
          'repetitive tasks or create specialized AI agents to coordinate your team\'s tasks. '
          'Learn more about QuantMessage.',
    ),
    FAQItem(
      question: 'What should I use QuantMessage for?',
      answer:
      'If you can imagine a task, QuantMessage can help you automate and execute it. '
          'Use QuantMessage to coordinate team threads, run background data tasks, draft '
          'secure project logs, build custom agent integrations, and simplify your daily '
          'operations so you can focus on high-impact work.',
    ),
    FAQItem(
      question: 'How much does it cost to use?',
      answer:
      'QuantMessage offers flexible plans to scale with your needs — from a '
          'free tier for individual conversations and basic bots, to Pro and '
          'Team plans that unlock longer context lengths, custom model selections, '
          'and advanced multi-agent executions.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _entryOpacity = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _toggle(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070709),
      body: PremiumBackgroundStack(
        bgController: _bgController,
        baseColor: const Color(0xFF070709),
        showMovingDots: true,
        showFluidMesh: true,
        child: SafeArea(
          child: FadeTransition(
            opacity: _entryOpacity,
            child: SlideTransition(
              position: _entrySlide,
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(28, 8, 28, 60),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 36),
                              // MODIFIED: Updated style to match "Coming Very Soon" image
                              const Text(
                                '< Frequently Asked Questions >',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter', // Changed from serif to modern sans-serif
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold, // Made bold
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 56),
                              ...List.generate(
                                _faqs.length,
                                    (i) => _buildFAQTile(i),
                              ),
                            ],
                          ),
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            splashRadius: 22,
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQTile(int index) {
    final isOpen = _expandedIndex == index;
    final faq = _faqs[index];

    // MODIFIED: Added Container with bottom border for separation
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1), // Subtle border line
            width: 1.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _toggle(index),
                splashColor: Colors.white.withOpacity(0.04),
                highlightColor: Colors.white.withOpacity(0.03),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          faq.question,
                          style: const TextStyle(
                            fontFamily: 'Inter', // Changed to sans-serif for consistency
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.2,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedOpacity(
                        opacity: isOpen ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: const SizedBox(
                          width: 28,
                          height: 28,
                          child: Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ClipRect(
              child: AnimatedAlign(
                alignment: Alignment.topLeft,
                heightFactor: isOpen ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: isOpen ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18, right: 56, top: 2),
                    child: _buildAnswerText(faq.answer),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerText(String answer) {
    const linkText = 'Learn more about QuantMessage.';
    if (answer.endsWith(linkText)) {
      final mainText = answer.substring(0, answer.length - linkText.length);
      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.5,
            color: Colors.white.withOpacity(0.72),
            height: 1.65,
            letterSpacing: 0.15,
          ),
          children: [
            TextSpan(text: mainText),
            TextSpan(
              text: linkText,
              style: const TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return Text(
      answer,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14.5,
        color: Colors.white.withOpacity(0.72),
        height: 1.65,
        letterSpacing: 0.15,
      ),
    );
  }
}
