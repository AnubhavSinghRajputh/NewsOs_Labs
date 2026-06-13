import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A premium, Claude-inspired bottom information/footer panel for QuantMessage.
/// Drop this widget into any scrollable column to show it when the user scrolls down.
class BottomInfoPanel extends StatelessWidget {
  const BottomInfoPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
        color: Color(0xFF080810),
    border: Border(
    top: BorderSide(color: Color(0x14FFFFFF), width: 1),
    ),
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    // ── FEATURE HIGHLIGHTS STRIP
    _FeatureStrip(isMobile: isMobile),

    // ── MAIN FOOTER BODY
    Padding(
    padding: EdgeInsets.symmetric(
    vertical: isMobile ? 48 : 72,
    horizontal: isMobile ? 24 : 72,
    ),
    child: isMobile
    ? Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    _BrandSection(),
    const SizedBox(height: 48),
    _FooterLinksGrid(isMobile: true),
    ],
    )
        : Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    SizedBox(width: screenWidth * 0.28, child: _BrandSection()),
    const SizedBox(width: 48),
    const Expanded(child: _FooterLinksGrid(isMobile: false)),
    ],
    ),
    ),

    // ── DIVIDER ────────────────────────────────────────────────────────
    Container(
    margin: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 72),
    height: 1,
    color: const Color(0x0DFFFFFF),
    ),

    // ── BOTTOM BAR ─────────────────────────────────────────────────────
    _BottomBar(isMobile: isMobile),
    ],
    ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FEATURE HIGHLIGHT STRIP
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureStrip extends StatelessWidget {
  final bool isMobile;
  const _FeatureStrip({required this.isMobile});

  static const _features = [
    (Icons.lock_outline_rounded, 'End-to-End Encrypted'),
    (Icons.speed_rounded, 'Ultra-Low Latency'),
    (Icons.psychology_alt_outlined, 'AI-Native Pipelines'),
    (Icons.shield_moon_outlined, 'Zero-Knowledge Architecture'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0AFFFFFF), width: 1)),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: isMobile ? 16 : 72,
      ),
      child: isMobile
          ? Wrap(
        spacing: 24,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: _features
            .map((f) => _FeaturePill(icon: f.$1, label: f.$2))
            .toList(),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _features
            .map((f) => _FeaturePill(icon: f.$1, label: f.$2))
            .toList(),
      ),
    );
  }
}

class _FeaturePill extends StatefulWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  State<_FeaturePill> createState() => _FeaturePillState();
}

class _FeaturePillState extends State<_FeaturePill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: _hovered
              ? const Color(0x14FFFFFF)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: 15,
              color: _hovered
                  ? const Color(0xFF9B8FFF)
                  : const Color(0x66FFFFFF),
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                color: _hovered
                    ? Colors.white.withOpacity(0.85)
                    : Colors.white.withOpacity(0.4),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BRAND SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _BrandSection extends StatelessWidget {
  const _BrandSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo row
        Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CustomPaint(painter: _QMLogoPainter()),
            ),
            const SizedBox(width: 10),
            const Text(
              'QuantMessage',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Next-generation secure agent messaging platform. Built for quant analysis, autonomous pipelines, and high-frequency communication.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.38),
            fontSize: 13,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 28),
        // Social links
        Row(
          children: [
            _SocialButton(
              icon: _GithubIcon(),
              tooltip: 'GitHub',
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _SocialButton(
              icon: const Icon(Icons.alternate_email_rounded,
                  size: 16, color: Color(0x80FFFFFF)),
              tooltip: 'Twitter / X',
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _SocialButton(
              icon: const Icon(Icons.language_rounded,
                  size: 16, color: Color(0x80FFFFFF)),
              tooltip: 'Website',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 28),
        // Status badge
        _StatusBadge(),
      ],
    );
  }
}

class _SocialButton extends StatefulWidget {
  final Widget icon;
  final String tooltip;
  final VoidCallback onTap;
  const _SocialButton(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _hovered
                  ? const Color(0x1AFFFFFF)
                  : const Color(0x0AFFFFFF),
              border: Border.all(
                color: _hovered
                    ? const Color(0x33FFFFFF)
                    : const Color(0x14FFFFFF),
              ),
            ),
            child: Center(child: widget.icon),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0x0A4ADE80),
        border: Border.all(color: const Color(0x204ADE80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing dot
          _PulsingDot(),
          const SizedBox(width: 8),
          const Text(
            'All systems operational',
            style: TextStyle(
              color: Color(0xFF4ADE80),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
          const Color(0xFF4ADE80).withOpacity(_pulse.value),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4ADE80)
                  .withOpacity(_pulse.value * 0.5),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FOOTER LINKS GRID
// ─────────────────────────────────────────────────────────────────────────────

class _FooterLinksGrid extends StatelessWidget {
  final bool isMobile;
  const _FooterLinksGrid({required this.isMobile});

  static const _sections = [
    {
      'title': 'Product',
      'links': [
        'QuantMessage Pro',
        'Enterprise Plan',
        'AI Agent Hub',
        'Developer APIs',
        'Pricing',
      ],
    },
    {
      'title': 'Solutions',
      'links': [
        'Quantitative Trading',
        'High-Speed Pipelines',
        'Autonomous Agents',
        'Secure Comms',
        'Data Analytics',
      ],
    },
    {
      'title': 'Resources',
      'links': [
        'Documentation',
        'GitHub Org',
        'Developer Docs',
        'System Status',
        'Community Blog',
      ],
    },
    {
      'title': 'Company',
      'links': [
        'About Us',
        'Careers',
        'Security',
        'GDPR & Trust',
        'Contact Sales',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Wrap(
        spacing: 40,
        runSpacing: 36,
        children: _sections
            .map((s) => SizedBox(
          width: 130,
          child: _FooterColumn(
            title: s['title'] as String,
            links: s['links'] as List<String>,
          ),
        ))
            .toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _sections
          .map((s) => Expanded(
        child: _FooterColumn(
          title: s['title'] as String,
          links: s['links'] as List<String>,
        ),
      ))
          .toList(),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> links;
  const _FooterColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xCCFFFFFF),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 18),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 13),
          child: _FooterLink(text: link),
        )),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String text;
  const _FooterLink({required this.text});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 160),
          style: TextStyle(
            color: _hovered
                ? Colors.white.withOpacity(0.85)
                : Colors.white.withOpacity(0.38),
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            height: 1.2,
            decoration:
            _hovered ? TextDecoration.none : TextDecoration.none,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.text),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: _hovered ? 14 : 0,
                child: _hovered
                    ? const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.arrow_forward_rounded,
                      size: 11, color: Color(0xFF9B8FFF)),
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM BAR
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final bool isMobile;
  const _BottomBar({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;

    final copyright = Text(
      '© $year QuantMessage, Inc. All rights reserved.',
      style: TextStyle(
        color: Colors.white.withOpacity(0.25),
        fontSize: 12,
      ),
    );

    final legalLinks = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegalLink(text: 'Terms'),
        _dot(),
        _LegalLink(text: 'Privacy'),
        _dot(),
        _LegalLink(text: 'Security'),
        _dot(),
        _LegalLink(text: 'Responsible Disclosure'),
      ],
    );

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            copyright,
            const SizedBox(height: 14),
            Wrap(
              spacing: 0,
              runSpacing: 8,
              children: [
                _LegalLink(text: 'Terms'),
                _dot(),
                _LegalLink(text: 'Privacy'),
                _dot(),
                _LegalLink(text: 'Security'),
                _dot(),
                _LegalLink(text: 'Responsible Disclosure'),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 24),
      child: Row(
        children: [
          copyright,
          const Spacer(),
          legalLinks,
        ],
      ),
    );
  }

  Widget _dot() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Text('·',
        style: TextStyle(
            color: Colors.white.withOpacity(0.2), fontSize: 12)),
  );
}

class _LegalLink extends StatefulWidget {
  final String text;
  const _LegalLink({required this.text});

  @override
  State<_LegalLink> createState() => _LegalLinkState();
}

class _LegalLinkState extends State<_LegalLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            color: _hovered
                ? Colors.white.withOpacity(0.7)
                : Colors.white.withOpacity(0.25),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUPPORTING WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// A minimal GitHub-style octacat icon drawn as a custom painter.
class _GithubIcon extends StatelessWidget {
  const _GithubIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16, 16),
      painter: _GithubIconPainter(),
    );
  }
}

class _GithubIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x80FFFFFF)
      ..style = PaintingStyle.fill;
    // Draw a simplified circle (stylized GitHub mark)
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawCircle(Offset(cx, cy), size.width / 2.2, paint);
    // Cut out inner circle for ring effect
    paint.color = const Color(0xFF080810);
    canvas.drawCircle(Offset(cx, cy), size.width / 3.8, paint);
    // Bottom notch to hint at octocat silhouette
    paint.color = const Color(0x80FFFFFF);
    final path = Path()
      ..moveTo(cx - 3, cy + 4)
      ..quadraticBezierTo(cx, cy + 7.5, cx + 3, cy + 4);
    canvas.drawPath(path, paint..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The QuantMessage logo — a stylized Q/quantum node with radiating lines.
class _QMLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Outer glow ring
    final glowPaint = Paint()
      ..color = const Color(0x409B8FFF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(cx, cy), r * 0.8, glowPaint);

    // Main ring
    final ringPaint = Paint()
      ..color = const Color(0xFF9B8FFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(Offset(cx, cy), r * 0.72, ringPaint);

    // Inner dot
    final dotPaint = Paint()..color = const Color(0xFFD4CFFF);
    canvas.drawCircle(Offset(cx, cy), r * 0.18, dotPaint);

    // 6 radiating spokes
    final spokePaint = Paint()
      ..color = const Color(0x99A89CFF)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 - math.pi / 6;
      final innerR = r * 0.22;
      final outerR = r * 0.65;//
      canvas.drawLine(
        Offset(cx + innerR * math.cos(angle), cy + innerR * math.sin(angle)),
        Offset(cx + outerR * math.cos(angle), cy + outerR * math.sin(angle)),
        spokePaint,
      );
      // Outer node dots
      canvas.drawCircle(
        Offset(cx + outerR * math.cos(angle), cy + outerR * math.sin(angle)),
        r * 0.08,
        dotPaint..color = const Color(0xFFD4CFFF),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QMLogoPainter oldDelegate) => false;
}
