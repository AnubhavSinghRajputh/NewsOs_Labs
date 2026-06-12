import 'package:flutter/material.dart';

class PremiumTransitions {
  /// 1. SLIDE RIGHT TO LEFT
  static Route slideRight(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Curve for a "snappy" yet smooth feel
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutQuint);

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0), // Starts from the right
            end: Offset.zero,
          ).animate(curve),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// 2. YE ZOOM & FADE EFFECT KE LIYE
  static Route zoomFade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 800),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  /// 3. isse aap SLIDE UP (The "Panel" Entry) kar saktev hain
  /// Use this for: Settings, Profile, or special "Quant" Insight popups
  static Route slideUp(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0), // Starts from the bottom
            end: Offset.zero,
          ).animate(curve),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// 4. YE SOFT CROSS-FADE effect
  static Route softFade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
