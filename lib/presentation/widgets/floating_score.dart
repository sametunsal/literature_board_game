import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FloatingScore extends StatelessWidget {
  final String text;
  final Color color;
  final bool isPositive;
  final VoidCallback onComplete;

  const FloatingScore({
    super.key,
    required this.text,
    required this.color,
    required this.isPositive,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final double endY = isPositive ? -140 : 80;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                blurRadius: 16,
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(0, 4),
              ),
              Shadow(
                blurRadius: 24,
                color: color.withOpacity(0.6),
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Text(text, style: TextStyle(color: color))
              .animate(onComplete: (c) => onComplete())
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.3, 1.3),
                duration: 250.ms,
                curve: Curves.elasticOut,
              )
              .then()
              .scale(
                begin: const Offset(1.3, 1.3),
                end: const Offset(1.0, 1.0),
                duration: 200.ms,
                curve: Curves.easeOut,
              )
              .then()
              .moveY(
                begin: 0,
                end: endY,
                duration: 1500.ms,
                curve: Curves.easeOut,
              )
              .fadeOut(delay: 800.ms, duration: 700.ms),
        ),
      ),
    );
  }
}
