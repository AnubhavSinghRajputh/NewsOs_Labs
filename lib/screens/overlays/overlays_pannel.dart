// lib/screens/overlays/overlays_pannel.dart
//
// WHITE-background overlay panel.
// Superimposed on home_screen via a SliverPersistentHeader so it scrolls
// in naturally as a "second section" with a visible lined partition between
// the dark home content and this white panel.

import 'package:flutter/material.dart';
import '../animations/pendulum_animation.dart';
import '../transition_animations.dart';

// Re-export so call-sites only need to import this file.
typedef PremiumTransitionType = OverlayRouteType; // see below

/// Re-declared here so this file is self-contained. Matches the
/// enum inside [PremiumTransitions] 1-to-1.
enum OverlayRouteType {
  slideRight,
  zoomFade,
  slideUp,
  softFade,
}

extension _PremiumRoute on OverlayRouteType {
  Route<dynamic> _toRoute(Widget child) {
    switch (this) {
      case OverlayRouteType.slideRight:
        return PremiumTransitions.slideRight(child);
      case OverlayRouteType.zoomFade:
        return PremiumTransitions.zoomFade(child);
      case OverlayRouteType.slideUp:
        return PremiumTransitions.slideUp(child);
      case OverlayRouteType.softFade:
        return PremiumTransitions.softFade(child);
    }
  }
}

// ─── Feature model ────────────────────────────────────────────────────────────

class _Feature {
  final String title;
  final String description;
  const _Feature({required this.title, required this.description});
}

const _features = <_Feature>[
  _Feature(title: 'QuantMessage Managed Agents',  description: 'A suite of composable APIs for building and deploying agents at scale.'),
  _Feature(title: 'Prompt caching',               description: 'Give QuantMessage more background knowledge and example outputs to reduce costs and latency.'),
  _Feature(title: 'Web search and fetch',          description: "Augment QuantMessage's knowledge with current, real-world data from across the web."),
  _Feature(title: 'Advanced tool use',             description: 'Allow QuantMessage to interact with hundreds of external tools and APIs so it can perform a wider range of tasks.'),
  _Feature(title: 'Batch processing',              description: 'Process large volumes of requests asynchronously and save 50% on costs.'),
  _Feature(title: 'Memory',                        description: 'Let QuantMessage store and consult information from a dedicated memory file.'),
  _Feature(title: 'Context editing',               description: 'Automatically clear less relevant tool calls and results from the context window when approaching token limits.'),
  _Feature(title: 'MCP connector',                 description: 'Connect QuantMessage to any remote MCP server without writing client code.'),
  _Feature(title: 'Code execution',                description: 'Run Python code, create visualizations, and analyze data directly within API calls.'),
  _Feature(title: 'Citations',                     description: 'Get detailed references to the exact sentences and passages QuantMessage uses to generate responses, leading to more verifiable, trustworthy outputs.'),
  _Feature(title: 'Files API',                     description: 'Upload documents once and reference them repeatedly across conversations.'),
  _Feature(title: 'Skills',                        description: 'Teach QuantMessage your expertise, procedures, and best practices so it delivers consistent, expert-level results.'),
];

// ─── Main widget ──────────────────────────────────────────────────────────────

class OverlaysPanel extends StatefulWidget {
  /// Which [PremiumTransitions] animation drives this panel:
  ///  • as a route (see [OverlaysPanel.push])
  ///  • as an internal content-swap transition (see [animateContentSwap])
  final OverlayRouteType transitionType;

  /// Wraps the body in an [AnimatedSwitcher] using the chosen transition.
  /// Set false for static, no-flicker rebuilds.
  final bool animateContentSwap;

  /// Change this to trigger a body swap (any object that's != previous).
  /// Examples: [ValueKey], [ObjectKey], [UniqueKey].
  final Key? contentKey;

  /// Optional `onTap` for the "See developer docs" button. If null, the
  /// button is rendered but does nothing (matching original behavior).
  final VoidCallback? onDocsTap;

  const OverlaysPanel({
    Key? key,
    this.transitionType   = OverlayRouteType.slideUp,
    this.animateContentSwap = true,
    this.contentKey,
    this.onDocsTap,
  }) : super(key: key);

  /// Pushes [panel] as a full-screen route using the matching
  /// [PremiumTransitions] animation. If [transition] is omitted,
  /// [panel.transitionType] is used.
  ///
  /// Example:
  /// ```dart
  /// OverlaysPanel.push(
  ///   context: context,
  ///   panel: const OverlaysPanel(
  ///     transitionType: OverlayRouteType.zoomFade,
  ///   ),
  /// );
  /// ```
  static Future<T?> push<T>({
    required BuildContext context,
    required OverlaysPanel panel,
    OverlayRouteType? transition,
  }) {
    final type = transition ?? panel.transitionType;
    final route = type._toRoute(panel) as Route<T>;
    return Navigator.of(context).push<T>(route);
  }

  @override
  State<OverlaysPanel> createState() => _OverlaysPanelState();
}

class _OverlaysPanelState extends State<OverlaysPanel>
    with SingleTickerProviderStateMixin {
  // Hero entry animation
  late final AnimationController _heroCtrl;
  late final Animation<double>   _heroFade;
  late final Animation<Offset>   _heroSlide;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _heroFade  = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));

    // Start hero animation as soon as the panel appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _heroCtrl.forward();
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    super.dispose();
  }

  // Called by home_screen when the outer scroll position passes the panel
  void onBecameVisible() {
    if (!_heroCtrl.isCompleted) _heroCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenW  = MediaQuery.of(context).size.width;
    final isMobile = screenW < 700;

    // The "body" we want to animate if [animateContentSwap] is on.
    final body = Column(
      children: [
        _buildPartition(),
        FadeTransition(
          opacity: _heroFade,
          child: SlideTransition(
            position: _heroSlide,
            child: _buildHero(isMobile),
          ),
        ),
        _buildFeaturesGrid(isMobile),
        const SizedBox(height: 100),
      ],
    );

    return Container(
      color: const Color(0xFFF7F7F5),
      child: widget.animateContentSwap
          ? AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve:  Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        layoutBuilder: _buildSwitcherLayout,
        transitionBuilder: _buildSwitcherTransition,
        child: KeyedSubtree(
          key: widget.contentKey ?? const ValueKey('overlays_panel_default'),
          child: body,
        ),
      )
          : body,
    );
  }

  // ── AnimatedSwitcher plumbing ─────────────────────────────────────────────

  Widget _buildSwitcherLayout(
      Widget? currentChild,
      List<Widget> previousChildren,
      ) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        ...previousChildren,
        if (currentChild != null) currentChild,
      ],
    );
  }

  Widget _buildSwitcherTransition(
      Widget child,
      Animation<double> animation,
      ) {
    switch (widget.transitionType) {
      case OverlayRouteType.slideRight:
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuint,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curve),
          child: FadeTransition(opacity: animation, child: child),
        );

      case OverlayRouteType.zoomFade:
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(curve),
            child: child,
          ),
        );

      case OverlayRouteType.slideUp:
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curve),
          child: FadeTransition(opacity: animation, child: child),
        );

      case OverlayRouteType.softFade:
        return FadeTransition(opacity: animation, child: child);
    }
  }

  // ── Partition ─────────────────────────────────────────────────────────────
  // Three lines: a bold dark line flanked by two hairlines — gives a clean
  // "superimposed panel" look matching the screenshot transition zone.

  Widget _buildPartition() {
    return Column(
      children: [
        Container(height: 1, color: const Color(0xFF1A1A1A).withOpacity(0.08)),
        const SizedBox(height: 2),
        Container(height: 2, color: const Color(0xFF1A1A1A).withOpacity(0.18)),
        const SizedBox(height: 2),
        Container(height: 1, color: const Color(0xFF1A1A1A).withOpacity(0.08)),
      ],
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  Widget _buildHero(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 28 : 80,
        vertical:   60,
      ),
      child: Column(
        children: [
          const PendulumAnimation(size: 80, color: Color(0xFF1A1A1A)),
          const SizedBox(height: 36),
          Text(
            ' < One Platform For Everything >',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily:    '__copernicus_669e4a',
              fontSize:      isMobile ? 30 : 52,
              fontWeight:    FontWeight.w800,
              color:         const Color(0xFF0D0D0D),
              height:        1.1,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 32),
          _DocsButton(onTap: widget.onDocsTap),
        ],
      ),
    );
  }

  // ── Feature grid ──────────────────────────────────────────────────────────

  Widget _buildFeaturesGrid(bool isMobile) {
    final rows = <List<_Feature>>[];
    for (int i = 0; i < _features.length; i += 2) {
      rows.add([
        _features[i],
        if (i + 1 < _features.length) _features[i + 1],
      ]);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 64),
      child: Column(
        children: List.generate(rows.length, (rowIdx) {
          return _AnimatedRow(
            revealed: true,
            delay:    Duration(milliseconds: 120 + rowIdx * 80),
            child: Column(
              children: [
                _buildRowDivider(),
                isMobile
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: rows[rowIdx]
                      .map((f) => _FeatureCard(feature: f))
                      .toList(),
                )
                    : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _FeatureCard(feature: rows[rowIdx][0]),
                      ),
                      if (rows[rowIdx].length > 1) ...[
                        Container(
                          width: 1,
                          color: const Color(0xFF1A1A1A)
                              .withOpacity(0.08),
                        ),
                        Expanded(
                          child: _FeatureCard(feature: rows[rowIdx][1]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRowDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF1A1A1A).withOpacity(0.12),
            const Color(0xFF1A1A1A).withOpacity(0.12),
            Colors.transparent,
          ],
          stops: const [0.0, 0.12, 0.88, 1.0],
        ),
      ),
    );
  }
}

// ─── Animated row reveal ──────────────────────────────────────────────────────

class _AnimatedRow extends StatefulWidget {
  final bool     revealed;
  final Duration delay;
  final Widget   child;
  const _AnimatedRow({
    required this.revealed,
    required this.delay,
    required this.child,
  });
  @override
  State<_AnimatedRow> createState() => _AnimatedRowState();
}

class _AnimatedRowState extends State<_AnimatedRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide   = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    if (widget.revealed) _scheduleForward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedRow old) {
    super.didUpdateWidget(old);
    if (widget.revealed && !old.revealed) _scheduleForward();
  }

  void _scheduleForward() {
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ─── Feature card ─────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width:  26,
            height: 26,
            margin: const EdgeInsets.only(top: 1, right: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF0D0D0D),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontFamily:    '__copernicus_669e4a',
                    fontSize:      17,
                    fontWeight:    FontWeight.w600,
                    color:         Color(0xFF0D0D0D),
                    height:        1.3,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  feature.description,
                  style: TextStyle(
                    fontFamily:  'Inter',
                    fontSize:    14,
                    fontWeight:  FontWeight.w400,
                    color:       const Color(0xFF0D0D0D).withOpacity(0.52),
                    height:      1.65,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── "See developer docs" button ─────────────────────────────────────────────

class _DocsButton extends StatefulWidget {
  final VoidCallback? onTap;
  const _DocsButton({this.onTap});
  @override
  State<_DocsButton> createState() => _DocsButtonState();
}

class _DocsButtonState extends State<_DocsButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFF0D0D0D) : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: const Color(0xFF0D0D0D).withOpacity(_hovered ? 1.0 : 0.28),
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: widget.onTap ?? () {},
            splashColor: Colors.black.withOpacity(0.06),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 26, vertical: 13,
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily:  'Inter',
                  fontSize:    14,
                  fontWeight:  FontWeight.w500,
                  color: _hovered ? Colors.white : const Color(0xFF0D0D0D),
                  letterSpacing: 0.2,
                ),
                child: const Text('See developer docs'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
