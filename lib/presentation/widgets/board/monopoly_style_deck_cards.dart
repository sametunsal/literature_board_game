import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/game_enums.dart';
import '../../theme/card_visual_theme.dart';

/// Textless deck card for the board center. The two decks read through
/// iconography alone: Şans is a warm gold card with a radiant fortune star,
/// Kader a midnight card with a crescent moon and a ring of inevitability.
class MonopolyStyleDeckCard extends StatelessWidget {
  const MonopolyStyleDeckCard({
    super.key,
    required this.type,
    required this.width,
    required this.height,
  });

  final CardType type;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final visualTheme = CardVisualTheme.forType(type);
    final size = math.min(width, height);
    final radius = BorderRadius.circular(size * 0.09);

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: visualTheme.shadow.withValues(alpha: 0.42),
              blurRadius: size * 0.14,
              offset: Offset(0, size * 0.07),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: size * 0.07,
              offset: Offset(0, size * 0.035),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: visualTheme.background,
                    stops: const [0, 0.58, 1],
                  ),
                ),
              ),
              CustomPaint(
                painter: _DeckPatternPainter(
                  type: type,
                  color: visualTheme.metallic,
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(size * 0.055),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size * 0.055),
                      border: Border.all(
                        color: visualTheme.metallic.withValues(alpha: 0.78),
                        width: math.max(1, size * 0.015),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size * 0.13,
                  vertical: size * 0.16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Ornament(color: visualTheme.metallic, size: size),
                    SizedBox(
                      width: size * 0.62,
                      height: size * 0.62,
                      child: CustomPaint(
                        painter: type == CardType.sans
                            ? _FortuneStarPainter(theme: visualTheme)
                            : _FateMoonPainter(theme: visualTheme),
                      ),
                    ),
                    _Ornament(color: visualTheme.metallic, size: size),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ornament extends StatelessWidget {
  const _Ornament({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: size * 0.12, height: 1, color: color),
        SizedBox(width: size * 0.035),
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: size * 0.045,
            height: size * 0.045,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(size * 0.008),
            ),
          ),
        ),
        SizedBox(width: size * 0.035),
        Container(width: size * 0.12, height: 1, color: color),
      ],
    );
  }
}

/// Şans emblem: an eight-point radiant star — fortune, opportunity, light.
/// Warm gold on ivory, with a soft glow and small corner sparkles.
class _FortuneStarPainter extends CustomPainter {
  const _FortuneStarPainter({required this.theme});

  final CardVisualTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;

    // Soft radial glow behind the star.
    canvas.drawCircle(
      center,
      r * 0.72,
      Paint()
        ..color = theme.accent.withValues(alpha: 0.30)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.28),
    );

    // Eight-point star.
    final star = _starPath(center, r * 0.92, r * 0.38, 8, -math.pi / 2);
    canvas.drawPath(
      star,
      Paint()
        ..shader = RadialGradient(
          colors: [theme.surface, theme.accent],
          stops: const [0.25, 1],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
    canvas.drawPath(
      star,
      Paint()
        ..color = theme.metallic
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.8, r * 0.06),
    );

    // Inner four-point twinkle.
    canvas.drawPath(
      _starPath(center, r * 0.34, r * 0.10, 4, -math.pi / 2),
      Paint()..color = theme.foreground.withValues(alpha: 0.85),
    );

    // Small sparkles orbiting the star: scattered luck.
    final sparklePaint = Paint()..color = theme.accent.withValues(alpha: 0.9);
    for (final (angle, dist, scale) in const [
      (-math.pi / 3, 1.02, 0.14),
      (2.4, 0.98, 0.11),
      (0.9, 1.05, 0.09),
    ]) {
      final p = center + Offset(math.cos(angle), math.sin(angle)) * r * dist;
      canvas.drawPath(
        _starPath(p, r * scale, r * scale * 0.36, 4, -math.pi / 2),
        sparklePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FortuneStarPainter oldDelegate) =>
      oldDelegate.theme != theme;
}

/// Kader emblem: a crescent moon inside a thin ring — fate, night,
/// inevitability. Pale gold on midnight, with faint distant stars.
class _FateMoonPainter extends CustomPainter {
  const _FateMoonPainter({required this.theme});

  final CardVisualTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;

    // The ring of inevitability: a thin closed circle around the moon.
    canvas.drawCircle(
      center,
      r * 0.94,
      Paint()
        ..color = theme.metallic.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.8, r * 0.045),
    );

    // Crescent: full disc minus an offset disc.
    final moonRadius = r * 0.60;
    final crescent = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: center, radius: moonRadius)),
      Path()
        ..addOval(
          Rect.fromCircle(
            center: center + Offset(moonRadius * 0.52, -moonRadius * 0.28),
            radius: moonRadius * 0.86,
          ),
        ),
    );
    canvas.drawPath(
      crescent,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.foreground, theme.metallic],
        ).createShader(Rect.fromCircle(center: center, radius: moonRadius)),
    );
    canvas.drawPath(
      crescent,
      Paint()
        ..color = theme.metallic
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.6, r * 0.03),
    );

    // Distant fixed stars: fate already written in the sky.
    final starPaint = Paint()
      ..color = theme.foreground.withValues(alpha: 0.75);
    for (final (angle, dist, scale) in const [
      (0.55, 0.62, 0.11),
      (0.15, 0.74, 0.08),
      (1.05, 0.70, 0.07),
    ]) {
      final p = center + Offset(math.cos(angle), math.sin(angle)) * r * dist;
      canvas.drawPath(
        _starPath(p, r * scale, r * scale * 0.38, 4, -math.pi / 2),
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FateMoonPainter oldDelegate) =>
      oldDelegate.theme != theme;
}

/// Builds a closed star polygon with [points] outer points.
Path _starPath(
  Offset center,
  double outerRadius,
  double innerRadius,
  int points,
  double startAngle,
) {
  final path = Path();
  final step = math.pi / points;
  for (var i = 0; i < points * 2; i++) {
    final radius = i.isEven ? outerRadius : innerRadius;
    final angle = startAngle + i * step;
    final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  path.close();
  return path;
}

class _DeckPatternPainter extends CustomPainter {
  const _DeckPatternPainter({required this.type, required this.color});

  final CardType type;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.48);
    final paint = Paint()
      ..color = color.withValues(alpha: type == CardType.sans ? 0.13 : 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.7, size.shortestSide * 0.008);

    if (type == CardType.sans) {
      for (var i = 0; i < 12; i++) {
        final angle = i * math.pi / 6;
        final start = size.shortestSide * 0.27;
        final end = size.longestSide * 0.72;
        canvas.drawLine(
          center + Offset(math.cos(angle), math.sin(angle)) * start,
          center + Offset(math.cos(angle), math.sin(angle)) * end,
          paint,
        );
      }
    } else {
      final radius = size.shortestSide * 0.32;
      canvas.drawCircle(center, radius, paint);
      canvas.drawCircle(center, radius * 0.68, paint);
      for (var i = 0; i < 8; i++) {
        final angle = i * math.pi / 4;
        final point =
            center + Offset(math.cos(angle), math.sin(angle)) * radius;
        canvas.drawCircle(point, size.shortestSide * 0.018, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DeckPatternPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.color != color;
}
