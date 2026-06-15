// lib/screens/overlays/overlays_extended.dart

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../animations/animation_widget/desktop_animation.dart';

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

  // ── NEW: Size configuration ───────────────────────────────────────────────
  final double desktopWidthFactor;  // % of container width (default 0.85)
  final double desktopAspectRatio;  // width/height ratio
  final double minDesktopHeight;
  final double maxDesktopHeight;
  final double compactScale;        // Global scale-down multiplier (0.0 - 1.0)

  const OverlaysExtended({
    super.key,
    this.title,
    this.subtitle,
    this.description,
    this.customContent,
    this.showDesktop = true,
    this.padding = const EdgeInsets.all(20.0), // ← reduced from 32
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
    // Size defaults (more compact)
    this.desktopWidthFactor  = 0.85,  // ← smaller (was 0.95)
    this.desktopAspectRatio  = 1.6,   // ← wider/shorter ratio
    this.minDesktopHeight    = 240,   // ← reduced from 300
    this.maxDesktopHeight    = 380,   // ← reduced from 500
    this.compactScale        = 1.0,
  });

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

  @override
  void initState() {
    super.initState();

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
              mainAxisSize: MainAxisSize.min, // ← tightens layout
              children: [
                if (widget.title != null ||
                    widget.subtitle != null ||
                    widget.description != null)
                  _buildHeader(),

                if (widget.showDesktop)
                  _buildDesktopSection()
                else if (widget.customContent != null)
                  Padding(
                    padding: widget.padding,
                    child: widget.customContent!,
                  ),
                // ❌ Key Features section removed
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Compact header ────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 18), // ← reduced
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
                fontSize: 24, // ← reduced from 28
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
          if (widget.description != null) ...[
            const SizedBox(height: 8), // ← reduced from 12
            Text(
              widget.description!,
              style: TextStyle(
                color: Colors.black.withOpacity(0.65),
                fontSize: 14, // ← reduced from 15
                height: 1.4,  // ← reduced from 1.5
                fontWeight: FontWeight.w400,
              ),
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24), // ← reduced
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
