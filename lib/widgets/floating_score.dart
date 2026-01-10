import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FloatingScore extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onComplete;

  const FloatingScore({
    super.key,
    required this.text,
    required this.color,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center allows generic positioning, modify via Stack Positioned in parent if needed
      child: Material(
        color: Colors.transparent,
        child:
            Text(
                  text,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: color,
                    shadows: const [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                )
                .animate(onComplete: (c) => onComplete())
                .moveY(
                  begin: 0,
                  end: -100,
                  duration: 1200.ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(duration: 200.ms)
                .fadeOut(delay: 800.ms, duration: 400.ms),
      ),
    );
  }
}
