// lib/screens/overlays/overlays_extended.dart

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../animations/animation_widget/desktop_animation.dart';
import '../transition_animations.dart';
import '../buttons/moving_icons_button.dart';

/// Selects which [PremiumTransitions] animation drives the overlay
/// when pushed as a route, and how it transitions internally when
/// the body content is swapped via [AnimatedSwitcher].
enum OverlayTransitionType {
  slideRight,
  zoomFade,
  slideUp,
  softFade,
}

class OverlaysExtended extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final String? description;
  final Widget? customContent;
  final bool showDesktop;
  final EdgeInsetsGeometry padding;
  final double? maxWidth;

  // ── Animation configuration ───────────────────────────────────────────────
  final bool animateOnScroll;
  final Duration animationDuration;
  final Duration animationDelay;
  final Curve animationCurve;
  final double slideOffset;
  final double visibilityThreshold;
  final ScrollController? scrollController;
  final AnimationController? controller;
  final VoidCallback? onAnimated;

  // ── Size configuration ────────────────────────────────────────────────────
  final double desktopWidthFactor;
  final double desktopAspectRatio;
  final double minDesktopHeight;
  final double maxDesktopHeight;
  final double compactScale;

  // ── Transition configuration ─────────────────────────────────────────
  final OverlayTransitionType transitionType;
  final bool animateContentSwap;
  final Key? contentKey; // change to trigger internal AnimatedSwitcher

  // ── NEW: Moving icons (segmented control) configuration ───────────────────
  /// Whether to show the [MovingIconsButton] segmented control in the header.
  final bool showSegmentedControl;

  /// Labels for the segmented control. Defaults to Desktop / Terminal / Web & iOS.
  final List<String> segmentLabels;

  /// Index initially selected in the segmented control.
  final int segmentInitialIndex;

  /// Called with (index, label) whenever the segmented control selection changes.
  final void Function(int index, String label)? onSegmentChanged;

  const OverlaysExtended({
    super.key,
    this.title,
    this.subtitle,
    this.description,
    this.customContent,
    this.showDesktop = true,
    this.padding = const EdgeInsets.all(20.0),
    this.maxWidth,
    // Animation defaults
    this.animateOnScroll     = true,
    this.animationDuration   = const Duration(milliseconds: 900),
    this.animationDelay      = Duration.zero,
    this.animationCurve      = Curves.easeOutCubic,
    this.slideOffset         = 0.08,
    this.visibilityThreshold = 0.85,
    this.scrollController,
    this.controller,
    this.onAnimated,
    // Size defaults
    this.desktopWidthFactor  = 0.85,
    this.desktopAspectRatio  = 1.6,
    this.minDesktopHeight    = 240,
    this.maxDesktopHeight    = 380,
    this.compactScale        = 1.0,
    // Transition defaults
    this.transitionType      = OverlayTransitionType.slideUp,
    this.animateContentSwap  = true,
    this.contentKey,
    // Segmented control defaults
    this.showSegmentedControl = true,
    this.segmentLabels = const ['Desktop', 'Terminal', 'Web & iOS'],
    this.segmentInitialIndex = 0,
    this.onSegmentChanged,
  });

  /// Pushes [overlay] as a full-screen route using the matching
  /// [PremiumTransitions] animation. If [transition] is omitted, the
  /// overlay's own [transitionType] is used.
  ///
  /// Example:
  /// ```dart
  /// OverlaysExtended.push(
  ///   context: context,
  ///   overlay: OverlaysExtended(
  ///     title: 'Hello',
  ///     description: 'World',
  ///     transitionType: OverlayTransitionType.zoomFade,
  ///   ),
  ///   transition: OverlayTransitionType.softFade, // overrides
  /// );
  /// ```
  static Future<T?> push<T>({
    required BuildContext context,
    required OverlaysExtended overlay,
    OverlayTransitionType? transition,
  }) {
    final type = transition ?? overlay.transitionType;
    switch (type) {
      case OverlayTransitionType.slideRight:
        return Navigator.of(context).push<T>(
          PremiumTransitions.slideRight(overlay) as Route<T>,
        );
      case OverlayTransitionType.zoomFade:
        return Navigator.of(context).push<T>(
          PremiumTransitions.zoomFade(overlay) as Route<T>,
        );
      case OverlayTransitionType.slideUp:
        return Navigator.of(context).push<T>(
          PremiumTransitions.slideUp(overlay) as Route<T>,
        );
      case OverlayTransitionType.softFade:
        return Navigator.of(context).push<T>(
          PremiumTransitions.softFade(overlay) as Route<T>,
        );
    }
  }

  @override
  State<OverlaysExtended> createState() => _OverlaysExtendedState();
}

class _OverlaysExtendedState extends State<OverlaysExtended>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double>   _fadeAnimation;
  late Animation<Offset>   _slideAnimation;
  final GlobalKey _widgetKey       = GlobalKey();
  ScrollPosition?    _scrollPosition;
  bool _hasAnimated      = false;
  bool _isListening      = false;
  bool _useExternalCtrl  = false;
  late int _segmentIndex;

  @override
  void initState() {
    super.initState();

    _segmentIndex = widget.segmentInitialIndex;

    _useExternalCtrl = widget.controller != null;
    _controller = widget.controller ??
        AnimationController(
          vsync: this,
          duration: widget.animationDuration,
        );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end:   Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    if (_useExternalCtrl) {
      widget.controller!.addStatusListener(_handleExternalStatus);
      return;
    }

    if (!widget.animateOnScroll) {
      _controller.value = 1.0;
      _hasAnimated = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _attachScrollListener();
      _checkInitialVisibility();
    });
  }

  void _handleExternalStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onAnimated?.call();
    }
  }

  void _handleSegmentChanged(int index, String label) {
    if (index == _segmentIndex) return;
    setState(() => _segmentIndex = index);
    widget.onSegmentChanged?.call(index, label);
  }

  void _attachScrollListener() {
    if (!mounted || _isListening) return;

    if (widget.scrollController != null &&
        widget.scrollController!.hasClients) {
      _scrollPosition = widget.scrollController!.position;
    } else {
      final scrollableState = Scrollable.maybeOf(context);
      _scrollPosition = scrollableState?.position;
    }

    if (_scrollPosition != null) {
      _scrollPosition!.addListener(_onScroll);
      _isListening = true;
    }
  }

  void _onScroll() => _checkVisibility();

  void _checkInitialVisibility() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  void _checkVisibility() {
    if (_hasAnimated || !mounted) return;

    final renderObject = _widgetKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) return;

    if (_scrollPosition == null || !_scrollPosition!.hasContentDimensions) {
      _triggerAnimation();
      return;
    }

    try {
      final viewport = RenderAbstractViewport.of(renderObject);
      final reveal   = viewport.getOffsetToReveal(renderObject, 0.0).offset;
      final pixels   = _scrollPosition!.pixels;
      final viewportHeight = _scrollPosition!.viewportDimension;
      final triggerPoint    = pixels + viewportHeight * widget.visibilityThreshold;

      if (reveal < triggerPoint) {
        _triggerAnimation();
      }
    } catch (_) {
      _triggerAnimation();
    }
  }

  void _triggerAnimation() {
    if (_hasAnimated) return;
    _hasAnimated = true;

    if (widget.animationDelay > Duration.zero) {
      Future.delayed(widget.animationDelay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimated?.call();
      }
    });
  }

  @override
  void didUpdateWidget(covariant OverlaysExtended oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animationCurve != widget.animationCurve ||
        oldWidget.slideOffset != widget.slideOffset) {
      _fadeAnimation = CurvedAnimation(
        parent: _controller,
        curve: widget.animationCurve,
      );
      _slideAnimation = Tween<Offset>(
        begin: Offset(0, widget.slideOffset),
        end:   Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.animationCurve,
      ));
    }
  }

  @override
  void dispose() {
    if (_isListening && _scrollPosition != null) {
      _scrollPosition!.removeListener(_onScroll);
    }
    if (_useExternalCtrl && widget.controller != null) {
      widget.controller!.removeStatusListener(_handleExternalStatus);
    }
    if (!_useExternalCtrl) {
      _controller.dispose();
    }
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          key: _widgetKey,
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: widget.maxWidth ?? 1200,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withOpacity(0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.title != null ||
                    widget.subtitle != null ||
                    widget.description != null ||
                    widget.showSegmentedControl)
                  _buildHeader(),

                _buildAnimatedBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Wraps the body in an [AnimatedSwitcher] so that swaps
  /// (e.g. desktop → customContent, or any rebuild with a new
  /// [OverlaysExtended.contentKey]) animate using the configured
  /// [OverlayTransitionType].
  Widget _buildAnimatedBody() {
    final body = widget.showDesktop
        ? _buildDesktopSection()
        : widget.customContent != null
        ? Padding(
      padding: widget.padding,
      child: widget.customContent!,
    )
        : const SizedBox.shrink();

    if (!widget.animateContentSwap) return body;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: widget.animationCurve,
      switchOutCurve: widget.animationCurve,
      layoutBuilder: _buildSwitcherLayout,
      transitionBuilder: _buildSwitcherTransition,
      child: KeyedSubtree(
        key: widget.contentKey ?? ValueKey('overlay_body_segment_$_segmentIndex'),
        child: body,
      ),
    );
  }

  /// Aligns incoming and outgoing children to the top, which is
  /// correct inside a top-aligned [Column].
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

  /// Mirrors the [PremiumTransitions] effect selected by
  /// [widget.transitionType] inside the [AnimatedSwitcher].
  Widget _buildSwitcherTransition(
      Widget child,
      Animation<double> animation,
      ) {
    switch (widget.transitionType) {
      case OverlayTransitionType.slideRight:
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

      case OverlayTransitionType.zoomFade:
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

      case OverlayTransitionType.slideUp:
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

      case OverlayTransitionType.softFade:
        return FadeTransition(opacity: animation, child: child);
    }
  }

  // ── Compact header ────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withOpacity(0.06),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.subtitle != null) ...[
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF8A50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.subtitle!,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (widget.title != null)
            Text(
              widget.title!,
              style: const TextStyle(
                color: Color(0xFF0A0A0A),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
          if (widget.description != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.description!,
              style: TextStyle(
                color: Colors.black.withOpacity(0.65),
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          if (widget.showSegmentedControl) ...[
            const SizedBox(height: 16),
            MovingIconsButton(
              labels: widget.segmentLabels,
              initialIndex: _segmentIndex,
              onChanged: _handleSegmentChanged,
              backgroundColor: const Color(0xFFF2F2F4),
              sliderColor: Colors.white,
              selectedTextColor: const Color(0xFF0A0A0A),
              unselectedTextColor: Colors.black.withOpacity(0.45),
            ),
          ],
        ],
      ),
    );
  }

  // ── Compact desktop section ──────────────────────────────────────────────

  Widget _buildDesktopSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withOpacity(0.06),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth * widget.desktopWidthFactor;
            double height = width / widget.desktopAspectRatio;

            // Clamp height
            height = height.clamp(widget.minDesktopHeight, widget.maxDesktopHeight);

            // Mobile adjustments
            if (constraints.maxWidth < 600) {
              width = constraints.maxWidth * 0.95;
              height = width / 1.4; // slightly taller on mobile
              height = height.clamp(220.0, 340.0);
            }

            // Apply global scale
            if (widget.compactScale != 1.0) {
              width  *= widget.compactScale;
              height *= widget.compactScale;
            }

            return DesktopAnimation(
              width: width,
              height: height,
            );
          },
        ),
      ),
    );
  }
}