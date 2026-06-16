import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable animated segmented control with a sliding pill indicator.
///
/// The slider automatically adapts its look based on [sliderColor]:
/// - If [sliderColor] is black (or any solid dark color), it renders as a
///   solid filled pill.
/// - If [sliderColor] is white (or any light color), it renders as a
///   translucent "glass" pill (semi-transparent + blurred + subtle border)
///   instead of a flat white block.
///
/// Usage:
/// ```dart
/// MovingIconsButton(
///   labels: const ['Desktop', 'Terminal', 'Web & iOS'],
///   initialIndex: 0,
///   onChanged: (index, label) {
///     // handle selection
///   },
/// )
/// ```
class MovingIconsButton extends StatefulWidget {
  const MovingIconsButton({
    super.key,
    required this.labels,
    this.initialIndex = 0,
    this.onChanged,
    this.height = 48,
    this.backgroundColor = const Color(0xFF1C1C1E),
    this.sliderColor = Colors.black,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = const Color(0xFF8E8E93),
    this.textStyle,
    this.animationDuration = const Duration(milliseconds: 450),
    this.animationCurve = Curves.easeOutQuint,
    this.padding = const EdgeInsets.all(4),
    this.glassBlurSigma = 12,
  });

  /// Labels shown on each segment, e.g. ['Desktop', 'Terminal', 'Web & iOS'].
  final List<String> labels;

  /// Index selected by default.
  final int initialIndex;

  /// Called with (selectedIndex, selectedLabel) whenever the selection changes.
  final void Function(int index, String label)? onChanged;

  final double height;
  final Color backgroundColor;

  /// Color of the sliding indicator. Black/dark colors render as a solid
  /// pill; white/light colors automatically render as a translucent,
  /// frosted-glass pill instead.
  final Color sliderColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final TextStyle? textStyle;
  final Duration animationDuration;
  final Curve animationCurve;
  final EdgeInsets padding;

  /// Blur strength applied to the slider when it renders in glass mode.
  final double glassBlurSigma;

  @override
  State<MovingIconsButton> createState() => _MovingIconsButtonState();
}

class _MovingIconsButtonState extends State<MovingIconsButton> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant MovingIconsButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep in sync if the parent drives selection externally (e.g. its own
    // state) and initialIndex changes after first build.
    if (widget.initialIndex != oldWidget.initialIndex &&
        widget.initialIndex != _selectedIndex) {
      setState(() => _selectedIndex = widget.initialIndex);
    }
  }

  void _select(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    widget.onChanged?.call(index, widget.labels[index]);
  }

  /// Treats colors close to white as "light" → glass slider.
  /// Everything else (black, brand colors, etc.) → solid slider.
  bool get _isLightSlider {
    final c = widget.sliderColor;
    final luminance = c.computeLuminance();
    return luminance > 0.6;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double innerWidth = totalWidth - widget.padding.horizontal;
        final double segmentWidth = innerWidth / widget.labels.length;
        final double sliderRadius = widget.height - widget.padding.vertical;
        final bool isLight = _isLightSlider;

        return Container(
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.height),
          ),
          child: Stack(
            children: [
              // Sliding pill indicator
              AnimatedPositioned(
                duration: widget.animationDuration,
                curve: widget.animationCurve,
                left: segmentWidth * _selectedIndex,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: AnimatedContainer(
                  duration: widget.animationDuration,
                  curve: widget.animationCurve,
                  decoration: BoxDecoration(
                    color: isLight
                        ? widget.sliderColor.withOpacity(0.18)
                        : widget.sliderColor,
                    borderRadius: BorderRadius.circular(sliderRadius),
                    border: isLight
                        ? Border.all(
                      color: widget.sliderColor.withOpacity(0.45),
                      width: 1,
                    )
                        : null,
                    boxShadow: isLight
                        ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : [
                      BoxShadow(
                        color: widget.sliderColor.withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isLight
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(sliderRadius),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: widget.glassBlurSigma,
                        sigmaY: widget.glassBlurSigma,
                      ),
                      child: Container(
                        color: widget.sliderColor.withOpacity(0.12),
                      ),
                    ),
                  )
                      : null,
                ),
              ),
              // Tappable labels
              Row(
                children: List.generate(widget.labels.length, (index) {
                  final bool isSelected = index == _selectedIndex;
                  return SizedBox(
                    width: segmentWidth,
                    height: double.infinity,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _select(index),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: widget.animationDuration,
                          curve: widget.animationCurve,
                          style: (widget.textStyle ?? const TextStyle(fontSize: 15)).copyWith(
                            color: isSelected
                                ? widget.selectedTextColor
                                : widget.unselectedTextColor,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          child: Text(
                            widget.labels[index],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}