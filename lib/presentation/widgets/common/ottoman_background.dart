import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/game_theme.dart';

/// Ottoman Scholar-themed background with aged paper texture
/// Creates a subtle vignette and paper grain effect
class OttomanBackground extends StatelessWidget {
  final Widget child;
  final Color? customColor;
  final double vignetteStrength;
  final bool showPattern;

  const OttomanBackground({
    super.key,
    required this.child,
    this.customColor,
    this.vignetteStrength = 0.6,
    this.showPattern = true,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = customColor ?? GameTheme.ottomanBackground;

    return Container(
      color: baseColor,
      child: Stack(
        children: [
          // Paper texture pattern
          if (showPattern)
            Positioned.fill(
              child: CustomPaint(
                painter: _OttomanPaperPainter(
                  baseColor: baseColor,
                ),
              ),
            ),

          // Vignette effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.transparent,
                    baseColor.withValues(alpha: vignetteStrength * 0.5),
                    baseColor.withValues(alpha: vignetteStrength),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // Content
          child,
        ],
      ),
    );
  }
}

/// Custom painter for Ottoman paper texture effect
class _OttomanPaperPainter extends CustomPainter {
  final Color baseColor;

  _OttomanPaperPainter({required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Paper grain noise
    final random = math.Random(42);
    final grainPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 500; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2;
      canvas.drawCircle(Offset(x, y), radius, grainPaint);
    }

    // Subtle aged spots (foxing effect)
    final spotPaint = Paint()
      ..color = const Color(0xFFD4C4A8).withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 20 + random.nextDouble() * 60;
      canvas.drawCircle(Offset(x, y), radius, spotPaint);
    }

    // Corner flourishes (subtle Tughra-inspired curves)
    final flourishPaint = Paint()
      ..color = GameTheme.ottomanAccent.withValues(alpha: 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Top-left flourish
    _drawCornerFlourish(canvas, const Offset(30, 80), flourishPaint);
    // Bottom-right flourish
    _drawCornerFlourish(
      canvas,
      Offset(size.width - 30, size.height - 80),
      flourishPaint,
      mirror: true,
    );
  }

  void _drawCornerFlourish(Canvas canvas, Offset center, Paint paint,
      {bool mirror = false}) {
    final path = Path();

    for (int i = 0; i < 3; i++) {
      final radius = 30.0 + i * 15;
      final startAngle = mirror ? math.pi : 0.0;
      final sweepAngle = (math.pi / 2) * (mirror ? -1 : 1);

      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Glassmorphic overlay for Ottoman-themed dialogs
class OttomanGlassOverlay extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double blur;

  const OttomanGlassOverlay({
    super.key,
    required this.child,
    this.opacity = 0.85,
    this.blur = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GameTheme.ottomanBackground.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GameTheme.ottomanBorder.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
