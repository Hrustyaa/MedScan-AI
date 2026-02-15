import 'package:flutter/material.dart';

class RouteTransitions {
  static PageRoute<T> slideFadeScale<T>(Widget page, {Offset begin = const Offset(0, 0.06)}) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 520),
      reverseTransitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        final fade = Tween<double>(begin: 0, end: 1).animate(curved);
        final slide = Tween<Offset>(begin: begin, end: Offset.zero).animate(curved);
        final scale = Tween<double>(begin: 0.98, end: 1).animate(curved);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(scale: scale, child: child),
          ),
        );
      },
    );
  }

  static PageRoute<T> fadeWithScrim<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.15),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }
}
