import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/book_level.dart';

/// Enamel identity of one publishing step, themed on what the step *is*:
/// Telif = bronze quill, Baskı = printer's ink blue, Cilt = bound-volume
/// purple. Presentation only — the level itself lives in [BookLevel].
@immutable
class PublicationLevelStyle {
  const PublicationLevelStyle({
    required this.letter,
    required this.enamelLight,
    required this.enamelDark,
  });

  /// Single-glyph mark stamped into the medallion: T / B / C.
  final String letter;

  final Color enamelLight;
  final Color enamelDark;

  /// `null` for [BookLevel.none] — an owned-but-unpublished book has no
  /// publication step to name, so it wears the owner's colour alone.
  static PublicationLevelStyle? forLevel(BookLevel level) => switch (level) {
    BookLevel.none => null,
    BookLevel.telif => const PublicationLevelStyle(
      letter: 'T',
      enamelLight: Color(0xFFD8A05C),
      enamelDark: Color(0xFF8C5A24),
    ),
    BookLevel.baski => const PublicationLevelStyle(
      letter: 'B',
      enamelLight: Color(0xFF4F94DC),
      enamelDark: Color(0xFF1D4F8C),
    ),
    BookLevel.cilt => const PublicationLevelStyle(
      letter: 'C',
      enamelLight: Color(0xFFA476DC),
      enamelDark: Color(0xFF5B2E91),
    ),
  };
}

/// Foil hairline separating the owner ring from the enamel core.
const Color _kFoil = Color(0xFFE7CB93);

/// Outer keyline. Board tiles sit on saturated category strips, so the badge
/// needs its own dark edge or the owner ring bleeds into the strip behind it.
const Color _kInk = Color(0xFF1B1208);

const Color _kIvory = Color(0xFFFFF6E6);

/// The one medallion used everywhere a Telif / Baskı / Cilt is shown — tile
/// ownership markers and acquisition toasts alike.
///
/// Two concentric bands carry two different facts, so neither hides the other:
///
/// * the **outer ring** is the receiving player's colour, drawn as lacquer
///   (light-to-dark sweep) with a soft halo of the same colour — roughly 45%
///   of the badge area, so *who got it* reads at a glance even at 11dp;
/// * the **enamel core** is the publication step's own colour, lit from the
///   top-left and shaded along its lower inner edge so it sits in the ring
///   like a set stone, with the T / B / C letter stamped into it.
///
/// Scales purely by [size]: every dimension is a fraction of the diameter, so
/// the 11dp tile badge and the 34dp toast badge are the same object.
class PublicationBadge extends StatelessWidget {
  const PublicationBadge({
    super.key,
    required this.level,
    required this.ownerColor,
    required this.size,
    this.fallbackLabel,
  });

  final BookLevel level;

  /// Colour of the player who holds the book. Carried by the outer ring.
  final Color ownerColor;

  /// Badge diameter.
  final double size;

  /// Shown when [level] is [BookLevel.none] — typically the owner's seat
  /// number, since there is no publication letter to stamp yet.
  final String? fallbackLabel;

  @override
  Widget build(BuildContext context) {
    final style = PublicationLevelStyle.forLevel(level);
    final label = style?.letter ?? fallbackLabel ?? '';

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        key: const ValueKey('publication-badge'),
        painter: _PublicationBadgePainter(style: style, ownerColor: ownerColor),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: size * 0.50,
              fontWeight: FontWeight.w800,
              height: 1.0,
              color: _kIvory,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  offset: Offset(0, size * 0.045),
                  blurRadius: size * 0.07,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PublicationBadgePainter extends CustomPainter {
  const _PublicationBadgePainter({
    required this.style,
    required this.ownerColor,
  });

  final PublicationLevelStyle? style;
  final Color ownerColor;

  /// Outer edge of the owner ring, as a fraction of the radius.
  static const double _ringOuter = 0.97;

  /// Where the owner ring stops and the enamel core begins.
  static const double _coreEdge = 0.68;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    if (r <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final bounds = Rect.fromCircle(center: center, radius: r);

    // Halo: the owner's colour spilling past the rim, so the badge separates
    // from whatever it sits on and the ownership colour reads first.
    canvas.drawCircle(
      center,
      r * _ringOuter,
      Paint()
        ..color = ownerColor.withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.18),
    );

    // Owner ring, lacquered: lit top-left, falling to a deep tone bottom-right.
    canvas.drawCircle(
      center,
      r * _ringOuter,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _shade(ownerColor, 0.20),
            ownerColor,
            _shade(ownerColor, -0.16),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds),
    );

    // Outer keyline.
    canvas.drawCircle(
      center,
      r * _ringOuter,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.5, r * 0.09)
        ..color = _kInk.withValues(alpha: 0.55),
    );

    _paintCore(canvas, center, r);
  }

  /// The set stone: enamel disc, foil bezel, specular highlight and a shaded
  /// lower inner edge. For an owned-but-unpublished book there is no level
  /// enamel, so the core is a deeper cut of the owner's own colour.
  void _paintCore(Canvas canvas, Offset center, double r) {
    final coreRadius = r * _coreEdge;
    final coreBounds = Rect.fromCircle(center: center, radius: coreRadius);
    final light = style?.enamelLight ?? _shade(ownerColor, -0.10);
    final dark = style?.enamelDark ?? _shade(ownerColor, -0.30);

    canvas.drawCircle(
      center,
      coreRadius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 0.95,
          colors: [_shade(light, 0.16), light, dark],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(coreBounds),
    );

    // Inner shading: a blurred ring pushed upwards, so only its lower arc
    // lands inside the core and the stone reads as domed.
    canvas.save();
    canvas.clipPath(Path()..addOval(coreBounds));
    canvas.drawCircle(
      center - Offset(0, coreRadius * 0.16),
      coreRadius * 0.96,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.6, coreRadius * 0.30)
        ..color = Colors.black.withValues(alpha: 0.26)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, coreRadius * 0.16),
    );
    canvas.restore();

    // Foil bezel between the two bands.
    canvas.drawCircle(
      center,
      coreRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.5, r * 0.07)
        ..color = _kFoil.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _PublicationBadgePainter oldDelegate) =>
      oldDelegate.ownerColor != ownerColor || oldDelegate.style != style;
}

Color _shade(Color color, double delta) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
}
