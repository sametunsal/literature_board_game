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
    final bool isLongMessage = text.length > 10;
    final double endY = isLongMessage ? -24 : (isPositive ? -140 : 80);
    final double fontSize = isLongMessage ? 24 : 64;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                blurRadius: 16,
                color: Colors.black.withValues(alpha: 0.5),
                offset: const Offset(0, 4),
              ),
              Shadow(
                blurRadius: 24,
                color: color.withValues(alpha: 0.6),
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: _buildText(isLongMessage)
              .animate(onComplete: (c) => onComplete())
              .scale(
                begin: const Offset(0.5, 0.5),
                end: isLongMessage
                    ? const Offset(1.05, 1.05)
                    : const Offset(1.3, 1.3),
                duration: 250.ms,
                curve: Curves.elasticOut,
              )
              .then()
              .scale(
                begin: isLongMessage
                    ? const Offset(1.05, 1.05)
                    : const Offset(1.3, 1.3),
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

  Widget _buildText(bool isLongMessage) {
    if (!isLongMessage) {
      return Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: color),
      );
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: SizedBox(
        width: 250,
        child: Text(
          text,
          maxLines: 2,
          softWrap: true,
          textAlign: TextAlign.center,
          style: TextStyle(color: color),
        ),
      ),
    );
  }
}
