import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FloatingScore extends StatelessWidget {
  final String text;
  final Color color;
  final bool
  isPositive; // Determines direction: up for positive, down for negative
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
    // Determine vertical movement based on positive/negative
    final double endY = isPositive ? -120 : 80; // Up for +, Down for -

    return Center(
      child: Material(
        color: Colors.transparent,
        child:
            Text(
                  text,
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: color,
                    shadows: const [
                      Shadow(
                        blurRadius: 12,
                        color: Colors.black87,
                        offset: Offset(3, 3),
                      ),
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black54,
                        offset: Offset(-1, -1),
                      ),
                    ],
                  ),
                )
                .animate(onComplete: (c) => onComplete())
                .moveY(
                  begin: 0,
                  end: endY,
                  duration: 1400.ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(duration: 200.ms)
                .fadeOut(delay: 1000.ms, duration: 400.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 300.ms,
                  curve: Curves.easeOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(1.0, 1.0),
                  duration: 200.ms,
                ),
      ),
    );
  }
}
