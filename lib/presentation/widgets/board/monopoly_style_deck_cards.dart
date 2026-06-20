import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/game_enums.dart';
import '../../theme/card_visual_theme.dart';

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
                    Container(
                      width: size * 0.48,
                      height: size * 0.48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: visualTheme.surface.withValues(
                          alpha: type == CardType.sans ? 0.78 : 0.34,
                        ),
                        border: Border.all(
                          color: visualTheme.metallic,
                          width: math.max(1, size * 0.018),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: visualTheme.accent.withValues(alpha: 0.38),
                            blurRadius: size * 0.12,
                            spreadRadius: size * 0.01,
                          ),
                        ],
                      ),
                      child: Icon(
                        visualTheme.icon,
                        size: size * 0.25,
                        color: type == CardType.sans
                            ? visualTheme.accent
                            : visualTheme.metallic,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        type == CardType.sans ? 'ŞANS' : 'KADER',
                        maxLines: 1,
                        style: GoogleFonts.playfairDisplay(
                          color: visualTheme.foreground,
                          fontSize: size * 0.16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: size * 0.015,
                        ),
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
