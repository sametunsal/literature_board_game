import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reusable star shape widget for confetti and decorations
/// Extracted from board_view.dart and modern_question_dialog.dart to eliminate duplication
class StarShape extends StatelessWidget {
  final double size;
  final Color? color;
  final int points;
  final double rotation;

  const StarShape({
    super.key,
    this.size = 20,
    this.color,
    this.points = 5,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StarPainter(
        color: color ?? Colors.amber,
        points: points,
        rotation: rotation,
        size: size,
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;
  final int points;
  final double rotation;
  final double size;

  _StarPainter({
    required this.color,
    this.points = 5,
    this.rotation = 0,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = _drawStar(
      size.width / 2,
      size.height / 2,
      size.width / 4,
      points,
      rotation,
    );

    canvas.drawPath(path, paint);
  }

  Path _drawStar(
    double centerX,
    double centerY,
    double outerRadius,
    int points,
    double rotation,
  ) {
    final path = Path();
    final innerRadius = outerRadius / 2;
    final angleStep = (math.pi * 2) / points;

    final startAngle = rotation - math.pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final double radius = i.isEven ? outerRadius : innerRadius;
      final double angle = startAngle + i * angleStep;
      final double x = centerX + radius * math.cos(angle);
      final double y = centerY + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.size != size ||
        oldDelegate.points != points ||
        oldDelegate.rotation != rotation;
  }
}
