import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/game_enums.dart';
import '../../theme/card_visual_theme.dart';
import 'board_visual_constants.dart';

/// Textless deck for the board centre, styled as a luxury tabletop card stack.
///
/// The two decks are told apart by material and iconography alone — no labels:
/// * **Şans** — warm ivory-and-gold, a radiant fortune sunburst, light rising
///   from the centre. Reads as luck / opportunity / positive.
/// * **Kader** — midnight navy, a crescent inside a closed ring of
///   inevitability, distant fixed stars. Reads as fate / night / mystery.
///
/// Both are drawn entirely with gradients and [CustomPainter]s (no assets):
/// a foil-gradient double frame with corner ornaments, a fine guilloché
/// ground, an embossed emblem, and a lacquer sheen. Two backing layers behind
/// the face card give the stack physical depth *inside* the same layout box,
/// so the centre area geometry is unchanged.
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
    final step = size * kDeckStackOffsetRatio;
    final inset = step * kDeckStackLayers;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Backing cards, furthest first: each peeks out at the top-right.
          for (var layer = kDeckStackLayers; layer >= 1; layer--)
            Positioned(
              left: inset - (kDeckStackLayers - layer) * step,
              top: (kDeckStackLayers - layer) * step,
              right: (kDeckStackLayers - layer) * step,
              bottom: inset - (kDeckStackLayers - layer) * step,
              child: _DeckBackingLayer(theme: visualTheme, size: size),
            ),
          Positioned(
            left: 0,
            top: inset,
            right: inset,
            bottom: 0,
            child: _DeckFace(type: type, theme: visualTheme, size: size),
          ),
        ],
      ),
    );
  }
}

/// A card sitting under the top one: only its edge is visible, so it needs
/// just the deep body tone plus a foil hairline along the cut edge.
class _DeckBackingLayer extends StatelessWidget {
  const _DeckBackingLayer({required this.theme, required this.size});

  final CardVisualTheme theme;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.09),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _shade(theme.background.last, -0.06),
            _shade(theme.background.last, -0.14),
          ],
        ),
        border: Border.all(
          color: theme.metallic.withValues(alpha: 0.55),
          width: math.max(0.6, size * 0.008),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withValues(alpha: 0.30),
            blurRadius: size * 0.06,
            offset: Offset(0, size * 0.02),
          ),
        ],
      ),
    );
  }
}

/// The visible top card: frame, ground pattern, emblem and lacquer sheen.
class _DeckFace extends StatelessWidget {
  const _DeckFace({
    required this.type,
    required this.theme,
    required this.size,
  });

  final CardType type;
  final CardVisualTheme theme;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.09);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withValues(alpha: 0.42),
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
                  colors: theme.background,
                  stops: const [0, 0.58, 1],
                ),
              ),
            ),
            CustomPaint(painter: _DeckGroundPainter(type: type, theme: theme)),
            Center(
              child: SizedBox(
                width: size * 0.58,
                height: size * 0.58,
                child: CustomPaint(
                  painter: type == CardType.sans
                      ? _FortuneStarPainter(theme: theme)
                      : _FateMoonPainter(theme: theme),
                ),
              ),
            ),
            CustomPaint(painter: _DeckFramePainter(theme: theme)),
            // Lacquer sheen: a single soft diagonal band over everything, the
            // finishing pass that makes the card read as coated stock.
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.18),
                      Colors.white.withValues(alpha: 0.04),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.10),
                    ],
                    stops: const [0.0, 0.22, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Painters ────────────────────────────────────────────────────────────────

/// Foil-like stroke: a metallic gradient sweeping across the card so the
/// frame catches "light" the way stamped foil does, instead of sitting at one
/// flat gold tone.
Paint _foilPaint(
  Rect rect,
  Color metallic, {
  required double strokeWidth,
  double alpha = 1.0,
}) {
  return Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _shade(metallic, 0.20).withValues(alpha: alpha),
        metallic.withValues(alpha: alpha),
        _shade(metallic, -0.18).withValues(alpha: alpha),
        _shade(metallic, 0.14).withValues(alpha: alpha),
      ],
      stops: const [0.0, 0.34, 0.66, 1.0],
    ).createShader(rect);
}

Color _shade(Color color, double delta) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
}

/// The printed ground under the frame: a vignette plus a fine guilloché
/// pattern that differs per deck (radiating light for Şans, celestial orbits
/// for Kader). Deliberately low-contrast so the emblem stays the focal point.
class _DeckGroundPainter extends CustomPainter {
  const _DeckGroundPainter({required this.type, required this.theme});

  final CardType type;
  final CardVisualTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height * 0.5);
    final s = size.shortestSide;

    // Vignette: edges fall off so the card feels lit from its centre.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 0.85,
          colors: [
            Colors.transparent,
            theme.shadow.withValues(alpha: type == CardType.sans ? 0.10 : 0.34),
          ],
          stops: const [0.55, 1.0],
        ).createShader(rect),
    );

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.6, s * 0.007)
      ..color = theme.metallic.withValues(
        alpha: type == CardType.sans ? 0.15 : 0.20,
      );

    if (type == CardType.sans) {
      // Sunburst: alternating long and short rays radiating from the emblem.
      for (var i = 0; i < 24; i++) {
        final angle = i * math.pi / 12;
        final start = s * 0.34;
        final end = size.longestSide * (i.isEven ? 0.74 : 0.56);
        canvas.drawLine(
          center + Offset(math.cos(angle), math.sin(angle)) * start,
          center + Offset(math.cos(angle), math.sin(angle)) * end,
          line,
        );
      }
      // Two concentric guilloché rings tie the rays together.
      for (final k in const [0.40, 0.455]) {
        canvas.drawCircle(center, s * k, line);
      }
    } else {
      // Celestial orbits: nested rings with fixed points along them.
      for (final k in const [0.34, 0.44, 0.50]) {
        canvas.drawCircle(center, s * k, line);
      }
      final dot = Paint()
        ..color = theme.metallic.withValues(alpha: 0.26)
        ..style = PaintingStyle.fill;
      for (var i = 0; i < 12; i++) {
        final angle = i * math.pi / 6;
        canvas.drawCircle(
          center + Offset(math.cos(angle), math.sin(angle)) * s * 0.44,
          s * (i.isEven ? 0.016 : 0.010),
          dot,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DeckGroundPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.theme != theme;
}

/// The layered border: an outer foil keyline, an inner hairline, four corner
/// brackets with diamond studs, and a rule above and below the emblem — the
/// vocabulary of an engraved luxury card back.
class _DeckFramePainter extends CustomPainter {
  const _DeckFramePainter({required this.theme});

  final CardVisualTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final rect = Offset.zero & size;

    final outer = RRect.fromRectAndRadius(
      rect.deflate(s * 0.055),
      Radius.circular(s * 0.055),
    );
    canvas.drawRRect(
      outer,
      _foilPaint(rect, theme.metallic, strokeWidth: math.max(1, s * 0.018)),
    );

    final inner = RRect.fromRectAndRadius(
      rect.deflate(s * 0.095),
      Radius.circular(s * 0.035),
    );
    canvas.drawRRect(
      inner,
      _foilPaint(
        rect,
        theme.metallic,
        strokeWidth: math.max(0.6, s * 0.008),
        alpha: 0.7,
      ),
    );

    _paintCorners(canvas, size, s, rect);
    _paintRules(canvas, size, s, rect);
  }

  /// Bracket + stud at each inner corner.
  void _paintCorners(Canvas canvas, Size size, double s, Rect rect) {
    final pad = s * 0.135;
    final arm = s * 0.10;
    final stroke = _foilPaint(
      rect,
      theme.metallic,
      strokeWidth: math.max(0.6, s * 0.011),
      alpha: 0.85,
    );
    final stud = Paint()..color = theme.metallic.withValues(alpha: 0.9);

    for (final (dx, dy) in const [(1, 1), (-1, 1), (1, -1), (-1, -1)]) {
      final x = dx > 0 ? pad : size.width - pad;
      final y = dy > 0 ? pad : size.height - pad;
      canvas.drawLine(Offset(x, y), Offset(x + dx * arm, y), stroke);
      canvas.drawLine(Offset(x, y), Offset(x, y + dy * arm), stroke);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(math.pi / 4);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: s * 0.036,
          height: s * 0.036,
        ),
        stud,
      );
      canvas.restore();
    }
  }

  /// Symmetrical rules above and below the emblem.
  void _paintRules(Canvas canvas, Size size, double s, Rect rect) {
    final stroke = _foilPaint(
      rect,
      theme.metallic,
      strokeWidth: math.max(0.6, s * 0.010),
      alpha: 0.9,
    );
    final stud = Paint()..color = theme.metallic.withValues(alpha: 0.9);

    for (final y in [size.height * 0.235, size.height * 0.765]) {
      final cx = size.width / 2;
      final half = s * 0.16;
      final gap = s * 0.05;
      canvas.drawLine(Offset(cx - half, y), Offset(cx - gap, y), stroke);
      canvas.drawLine(Offset(cx + gap, y), Offset(cx + half, y), stroke);

      canvas.save();
      canvas.translate(cx, y);
      canvas.rotate(math.pi / 4);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: s * 0.042,
          height: s * 0.042,
        ),
        stud,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _DeckFramePainter oldDelegate) =>
      oldDelegate.theme != theme;
}

/// Şans emblem: an eight-point radiant star — fortune, opportunity, light.
/// Warm gold on ivory, embossed, with a soft glow and orbiting sparkles.
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
        ..color = theme.accent.withValues(alpha: 0.28)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.26),
    );

    final star = _starPath(center, r * 0.92, r * 0.36, 8, -math.pi / 2);
    _emboss(canvas, star, r);
    canvas.drawPath(
      star,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [theme.surface, theme.metallic, theme.accent],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
    canvas.drawPath(
      star,
      _foilPaint(
        Rect.fromCircle(center: center, radius: r),
        theme.metallic,
        strokeWidth: math.max(0.8, r * 0.06),
      ),
    );

    // Bright core: the heart of the star is the light source, not a hole.
    canvas.drawCircle(
      center,
      r * 0.22,
      Paint()
        ..color = theme.surface.withValues(alpha: 0.95)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.10),
    );
    canvas.drawPath(
      _starPath(center, r * 0.32, r * 0.09, 4, -math.pi / 2),
      Paint()..color = theme.surface,
    );
    canvas.drawPath(
      _starPath(center, r * 0.32, r * 0.09, 4, -math.pi / 2),
      Paint()
        ..color = theme.accent.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.5, r * 0.02),
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
/// inevitability. Pale gold on midnight, embossed, with faint fixed stars.
class _FateMoonPainter extends CustomPainter {
  const _FateMoonPainter({required this.theme});

  final CardVisualTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    final bounds = Rect.fromCircle(center: center, radius: r);

    // Night bloom behind the moon: depth without lifting the card's darkness.
    canvas.drawCircle(
      center,
      r * 0.70,
      Paint()
        ..color = theme.accent.withValues(alpha: 0.34)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.30),
    );

    // The ring of inevitability: a closed foil circle around the moon,
    // doubled by a hairline for an engraved feel.
    canvas.drawCircle(
      center,
      r * 0.94,
      _foilPaint(bounds, theme.metallic, strokeWidth: math.max(0.8, r * 0.05)),
    );
    canvas.drawCircle(
      center,
      r * 0.82,
      Paint()
        ..color = theme.metallic.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.5, r * 0.018),
    );

    // Crescent: full disc minus an offset disc.
    final moonRadius = r * 0.58;
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
    _emboss(canvas, crescent, r);
    canvas.drawPath(
      crescent,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.foreground, theme.metallic, theme.accent],
          stops: const [0.0, 0.6, 1.0],
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

/// Stamps a soft dark offset under [path] so the emblem reads as pressed into
/// the card stock rather than printed flat on top of it.
void _emboss(Canvas canvas, Path path, double r) {
  canvas.drawPath(
    path.shift(Offset(0, r * 0.05)),
    Paint()
      ..color = Colors.black.withValues(alpha: 0.32)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.05),
  );
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
