import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/game_enums.dart';

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
    if (type == CardType.sans) {
      return _SansCard(width: width, height: height);
    }
    return _KaderCard(width: width, height: height);
  }
}

/// ŞANS (Chance) — warm gold/amber card with sunburst motif
class _SansCard extends StatelessWidget {
  final double width;
  final double height;
  const _SansCard({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final s = math.min(width, height);
    final borderRadius = BorderRadius.circular(s * 0.08);

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8F00).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Base gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFF8E1),
                      Color(0xFFFFECB3),
                      Color(0xFFFFD54F),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Decorative rays
              CustomPaint(painter: _SunburstPainter()),

              // Inner card border (classic card feel)
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.all(s * 0.06),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(s * 0.05),
                    border: Border.all(
                      color: const Color(0xFFE65100).withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(s * 0.1),
                child: Column(
                  children: [
                    // Top ornament
                    _CardOrnament(
                      color: const Color(0xFFE65100),
                      width: s * 0.3,
                    ),
                    const Spacer(flex: 2),

                    // Central question mark emblem
                    Container(
                      width: s * 0.42,
                      height: s * 0.42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
                        ),
                        border: Border.all(
                          color: const Color(0xFFE65100),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFFF8F00).withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '?',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: s * 0.28,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFBF360C),
                            height: 1,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Icon-only plaque (no text to avoid tiny-font artifacts)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          vertical: s * 0.04, horizontal: s * 0.06),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE65100), Color(0xFFBF360C)],
                        ),
                        borderRadius: BorderRadius.circular(s * 0.03),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFBF360C)
                                .withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: s * 0.17,
                          height: s * 0.17,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFF8E1).withValues(alpha: 0.18),
                            border: Border.all(
                              color: const Color(0xFFFFF8E1).withValues(alpha: 0.6),
                              width: 1.2,
                            ),
                          ),
                          child: const Icon(
                            Icons.wb_sunny_rounded,
                            color: Color(0xFFFFF8E1),
                            size: 16,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Bottom ornament
                    _CardOrnament(
                      color: const Color(0xFFE65100),
                      width: s * 0.3,
                    ),
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

/// KADER (Fate) — deep teal/mystical card with cosmic motif
class _KaderCard extends StatelessWidget {
  final double width;
  final double height;
  const _KaderCard({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final s = math.min(width, height);
    final borderRadius = BorderRadius.circular(s * 0.08);

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF004D40).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Base gradient — deep teal to dark
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF00695C),
                      Color(0xFF004D40),
                      Color(0xFF00332C),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Star field
              CustomPaint(painter: _StarFieldPainter()),

              // Inner card border
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.all(s * 0.06),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(s * 0.05),
                    border: Border.all(
                      color: const Color(0xFF80CBC4).withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(s * 0.1),
                child: Column(
                  children: [
                    // Top ornament
                    _CardOrnament(
                      color: const Color(0xFF80CBC4),
                      width: s * 0.3,
                    ),
                    const Spacer(flex: 2),

                    // Central crystal ball / eye emblem
                    Container(
                      width: s * 0.42,
                      height: s * 0.42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          center: Alignment(-0.2, -0.2),
                          colors: [
                            Color(0xFF80CBC4),
                            Color(0xFF26A69A),
                            Color(0xFF00695C),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                        border: Border.all(
                          color: const Color(0xFFB2DFDB),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF26A69A)
                                .withValues(alpha: 0.5),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_awesome,
                          size: s * 0.22,
                          color: const Color(0xFFE0F2F1),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Icon-only plaque (no text to avoid tiny-font artifacts)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          vertical: s * 0.04, horizontal: s * 0.06),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF26A69A), Color(0xFF00695C)],
                        ),
                        borderRadius: BorderRadius.circular(s * 0.03),
                        border: Border.all(
                          color:
                              const Color(0xFFB2DFDB).withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF004D40)
                                .withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: s * 0.17,
                          height: s * 0.17,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE0F2F1).withValues(alpha: 0.14),
                            border: Border.all(
                              color: const Color(0xFFE0F2F1).withValues(alpha: 0.55),
                              width: 1.2,
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Color(0xFFE0F2F1),
                            size: 16,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Bottom ornament
                    _CardOrnament(
                      color: const Color(0xFF80CBC4),
                      width: s * 0.3,
                    ),
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

/// Small decorative line ornament for card tops/bottoms
class _CardOrnament extends StatelessWidget {
  final Color color;
  final double width;
  const _CardOrnament({required this.color, required this.width});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: width * 0.25,
          height: 1,
          color: color.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 4),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: width * 0.25,
          height: 1,
          color: color.withValues(alpha: 0.4),
        ),
      ],
    );
  }
}

/// Subtle sunburst rays for ŞANS card background
class _SunburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.42;
    final maxR = math.max(size.width, size.height) * 0.7;
    final paint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    const rayCount = 12;
    const halfAngle = math.pi / rayCount / 2.5;

    for (int i = 0; i < rayCount; i++) {
      final angle = (2 * math.pi / rayCount) * i;
      final path = Path()
        ..moveTo(cx, cy)
        ..lineTo(
          cx + math.cos(angle - halfAngle) * maxR,
          cy + math.sin(angle - halfAngle) * maxR,
        )
        ..lineTo(
          cx + math.cos(angle + halfAngle) * maxR,
          cy + math.sin(angle + halfAngle) * maxR,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Tiny decorative stars for KADER card background
class _StarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 0.4 + rng.nextDouble() * 1.0;
      paint.color = const Color(0xFFB2DFDB)
          .withValues(alpha: 0.1 + rng.nextDouble() * 0.2);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
