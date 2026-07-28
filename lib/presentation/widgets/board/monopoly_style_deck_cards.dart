import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/game_enums.dart';
import '../../theme/card_visual_theme.dart';
import 'board_visual_constants.dart';

/// Deck faces for the board centre, composed like a pair of matched
/// letterpress cards.
///
/// The centre deck is drawn between roughly 49dp wide (phone landscape) and
/// 158dp (1080p), so the composition is built for the *small* end and simply
/// gains fine detail as it grows. Three elements, in strict order of weight:
///
///   1. the **title cartouche** — a solid plate carrying ŞANS / KADER, the
///      highest-contrast element on the card;
///   2. the **rondel emblem** — one symbol, no satellites;
///   3. the **frame** — a single delicate keyline.
///
/// The plate is inverted between the decks — ink on ivory for Şans, brass on
/// midnight for Kader — so the two are told apart instantly, even in
/// silhouette, and each title sits on maximum local contrast.
///
/// Everything is drawn with gradients and [CustomPainter]s (no assets). Two
/// backing layers behind the face give the stack physical depth *inside* the
/// same layout box, so the centre area geometry is unchanged.
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

// ─── Composition ─────────────────────────────────────────────────────────────

/// Rondel diameter as a fraction of the face's short side.
const double _kRondelSizeRatio = 0.50;

/// Rondel centre, as a fraction of the face height.
const double _kRondelCenterFrac = 0.375;

/// Title cartouche, as fractions of the face box. Sized so five tracked
/// capitals ("KADER") still clear the plate's inner padding at phone scale.
const double _kPlateCenterFrac = 0.775;
const double _kPlateWidthFrac = 0.78;
const double _kPlateHeightFrac = 0.155;

/// The cartouche, in face coordinates.
///
/// Single source of truth: the painter fills this rect and the title widget is
/// positioned into the same one. Placing the title with an [Alignment] instead
/// silently drifts — alignment resolves against *free* space, not the face, so
/// the word creeps off the plate as the plate's height fraction changes.
Rect _plateRect(Size face) => Rect.fromCenter(
  center: Offset(face.width / 2, face.height * _kPlateCenterFrac),
  width: face.width * _kPlateWidthFrac,
  height: face.height * _kPlateHeightFrac,
);

/// The emblem rondel, in face coordinates. Sized off the short side so the
/// symbol keeps its proportions whatever aspect the deck is given.
Rect _rondelRect(Size face, double size) => Rect.fromCenter(
  center: Offset(face.width / 2, face.height * _kRondelCenterFrac),
  width: size * _kRondelSizeRatio,
  height: size * _kRondelSizeRatio,
);

/// Below this face short side the card drops its hairline and paper mottle.
///
/// At 49dp those details land under a pixel and stop being texture: the
/// hairline muddies the keyline and the mottle greys the plate's surround.
/// Small decks are better served by frame, emblem and title alone.
const double _kFineDetailMinSide = 70.0;

/// Title size as a fraction of the plate height, then clamped. A [FittedBox]
/// inside the plate shrinks it further if a word would still crowd the edges,
/// so this is a ceiling rather than an exact size.
const double _kTitleSizeRatio = 0.58;
const double _kTitleSizeMin = 6.0;
const double _kTitleSizeMax = 24.0;

/// Deck name shown on the card face — just the word, not the full
/// "ŞANS KARTI" title used by the drawn-card dialog.
String _deckLabel(CardType type) => switch (type) {
  CardType.sans => 'ŞANS',
  CardType.kader => 'KADER',
};

// ─── Deck palette ────────────────────────────────────────────────────────────

/// Tones the deck face needs that the shared [CardVisualTheme] does not carry.
///
/// Kept local to the deck rather than pushed into [CardVisualTheme]: that theme
/// is also the drawn-card dialog's palette, and these are answers to the deck's
/// own problem — holding contrast on a 49dp card face.
@immutable
class _DeckPalette {
  const _DeckPalette({
    required this.plateLight,
    required this.plateDark,
    required this.plateText,
    required this.plateEdge,
    required this.emblemLight,
    required this.emblemDark,
    required this.rondelRing,
  });

  /// Cartouche fill, lit from the top.
  final Color plateLight;
  final Color plateDark;

  /// Letterforms on the cartouche.
  final Color plateText;

  /// Hairline framing the cartouche.
  final Color plateEdge;

  final Color emblemLight;
  final Color emblemDark;
  final Color rondelRing;

  static _DeckPalette forType(CardType type) => switch (type) {
    // Şans: warm ivory stock. The old face inked emblem *and* title in gold
    // on cream, which left the whole card inside one narrow luminance band.
    // The plate goes dark sepia and the emblem bronze, so both read against
    // the parchment; the ring keeps a muted green-gold for warmth.
    CardType.sans => const _DeckPalette(
      plateLight: Color(0xFF4A3617),
      plateDark: Color(0xFF2E2009),
      plateText: Color(0xFFF8EFD8),
      plateEdge: Color(0xFFC8A55E),
      emblemLight: Color(0xFF8A6524),
      emblemDark: Color(0xFF3E2B0E),
      rondelRing: Color(0xFF8A7A38),
    ),
    // Kader: midnight stock, so the plate inverts to muted brass with
    // midnight letterforms — restrained rather than bright, but still the
    // strongest value step on the card.
    CardType.kader => const _DeckPalette(
      plateLight: Color(0xFFD3BA84),
      plateDark: Color(0xFFA98F55),
      plateText: Color(0xFF11121F),
      plateEdge: Color(0xFF6E5C34),
      emblemLight: Color(0xFFF2E4BC),
      emblemDark: Color(0xFFB89A5C),
      rondelRing: Color(0xFFC2A66B),
    ),
  };
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

/// The visible top card: stock, rondel, frame + cartouche, title, sheen.
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
    final palette = _DeckPalette.forType(type);
    final fineDetail = size >= _kFineDetailMinSide;

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final face = constraints.biggest;
            return Stack(
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
                CustomPaint(
                  painter: _DeckStockPainter(
                    type: type,
                    theme: theme,
                    fineDetail: fineDetail,
                  ),
                ),
                Positioned.fromRect(
                  rect: _rondelRect(face, size),
                  child: CustomPaint(
                    painter: type == CardType.sans
                        ? _QuillRondelPainter(theme: theme, palette: palette)
                        : _CrescentRondelPainter(
                            theme: theme,
                            palette: palette,
                          ),
                  ),
                ),
                CustomPaint(
                  painter: _DeckFramePainter(
                    theme: theme,
                    palette: palette,
                    fineDetail: fineDetail,
                  ),
                ),
                Positioned.fromRect(
                  rect: _plateRect(face),
                  child: _DeckTitle(type: type, palette: palette),
                ),
                // Print sheen: one soft diagonal band, the finishing pass that
                // makes the card read as coated stock. Deliberately weak — on
                // Şans a stronger sheen washes straight over the cartouche.
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.10),
                          Colors.white.withValues(alpha: 0.02),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.07),
                        ],
                        stops: const [0.0, 0.22, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The deck's name, set in inscriptional Roman capitals on the cartouche.
///
/// Cinzel over a higher-contrast face such as Playfair on purpose: at the
/// 6–8pt this lands at on a phone-sized deck, a didone's hairlines drop out
/// and the word turns to lace, while Cinzel's near-uniform stroke survives.
class _DeckTitle extends StatelessWidget {
  const _DeckTitle({required this.type, required this.palette});

  final CardType type;
  final _DeckPalette palette;

  @override
  Widget build(BuildContext context) {
    // Sized and placed by the caller onto the cartouche rect, so this only has
    // to fit the word into the plate it has been handed.
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = (constraints.maxHeight * _kTitleSizeRatio).clamp(
          _kTitleSizeMin,
          _kTitleSizeMax,
        );
        return Padding(
          // Inner margin of the plate, plus a leading pad equal to the
          // tracking: letter spacing is applied after the final glyph too,
          // which otherwise drags tracked type left of centre.
          padding: EdgeInsets.only(
            left: fontSize * 0.22 + constraints.maxWidth * 0.07,
            right: constraints.maxWidth * 0.07,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _deckLabel(type),
              maxLines: 1,
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: fontSize * 0.22,
                height: 1.0,
                color: palette.plateText,
              ),
            ),
          ),
        );
      },
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

/// The stock the card is printed on: a centre-weighted vignette, plus — only
/// where there are pixels to spend it on — two soft blooms standing in for the
/// mottle of pressed paper.
///
/// The previous face laid a woven line pattern here. At phone scale its lines
/// fell under 4px apart and read as moiré, which is exactly the pattern
/// density that competes with the emblem, so it is gone.
class _DeckStockPainter extends CustomPainter {
  const _DeckStockPainter({
    required this.type,
    required this.theme,
    required this.fineDetail,
  });

  final CardType type;
  final CardVisualTheme theme;
  final bool fineDetail;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final s = size.shortestSide;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 0.85,
          colors: [
            Colors.transparent,
            theme.shadow.withValues(alpha: type == CardType.sans ? 0.12 : 0.36),
          ],
          stops: const [0.55, 1.0],
        ).createShader(rect),
    );

    if (!fineDetail) return;

    final mottle = Paint()
      ..color = theme.metallic.withValues(alpha: 0.05)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.22);
    canvas.drawCircle(
      Offset(size.width * 0.26, size.height * 0.20),
      s * 0.30,
      mottle,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.62),
      s * 0.26,
      mottle,
    );
  }

  @override
  bool shouldRepaint(covariant _DeckStockPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.theme != theme ||
      oldDelegate.fineDetail != fineDetail;
}

/// The frame and the title cartouche.
///
/// One foil keyline carries the border; the companion hairline inside it is
/// drawn only on decks large enough to resolve it. The cartouche is a filled
/// plate with a foil edge and a soft drop under it, so the title sits *on*
/// the card rather than floating in the stock.
class _DeckFramePainter extends CustomPainter {
  const _DeckFramePainter({
    required this.theme,
    required this.palette,
    required this.fineDetail,
  });

  final CardVisualTheme theme;
  final _DeckPalette palette;
  final bool fineDetail;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final rect = Offset.zero & size;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(s * 0.070),
        Radius.circular(s * 0.048),
      ),
      _foilPaint(rect, theme.metallic, strokeWidth: math.max(0.8, s * 0.015)),
    );

    if (fineDetail) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.deflate(s * 0.105),
          Radius.circular(s * 0.032),
        ),
        _foilPaint(
          rect,
          theme.metallic,
          strokeWidth: math.max(0.5, s * 0.006),
          alpha: 0.5,
        ),
      );
    }

    _paintCartouche(canvas, size, s);
  }

  void _paintCartouche(Canvas canvas, Size size, double s) {
    final plate = _plateRect(size);
    final rrect = RRect.fromRectAndRadius(plate, Radius.circular(s * 0.028));

    // Seated, not floating: a soft shadow under the plate edge.
    canvas.drawRRect(
      rrect.shift(Offset(0, s * 0.012)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.018),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.plateLight, palette.plateDark],
        ).createShader(plate),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.5, s * 0.009)
        ..color = palette.plateEdge,
    );
  }

  @override
  bool shouldRepaint(covariant _DeckFramePainter oldDelegate) =>
      oldDelegate.theme != theme ||
      oldDelegate.palette != palette ||
      oldDelegate.fineDetail != fineDetail;
}

/// Draws the rondel every deck emblem sits in: one ring on a soft bloom of the
/// deck's accent. Shared, so the two cards read as a set.
void _paintRondel(
  Canvas canvas,
  Offset center,
  double r,
  Rect bounds,
  CardVisualTheme theme,
  _DeckPalette palette,
  double bloomAlpha,
) {
  canvas.drawCircle(
    center,
    r * 0.72,
    Paint()
      ..color = theme.accent.withValues(alpha: bloomAlpha)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.28),
  );
  canvas.drawCircle(
    center,
    r * 0.92,
    _foilPaint(
      bounds,
      palette.rondelRing,
      strokeWidth: math.max(0.9, r * 0.06),
    ),
  );
}

/// Şans emblem: a writing nib — the tool that fills a fortunate page.
///
/// Inked in bronze rather than gold. On ivory stock a gold nib sat only a
/// shade off its background and vanished below about 60dp; bronze holds a real
/// value step against the parchment at every size the deck is drawn at.
class _QuillRondelPainter extends CustomPainter {
  const _QuillRondelPainter({required this.theme, required this.palette});

  final CardVisualTheme theme;
  final _DeckPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    if (r <= 0) return;
    final bounds = Rect.fromCircle(center: center, radius: r);

    _paintRondel(canvas, center, r, bounds, theme, palette, 0.22);

    final nib = _nibPath(center, r);
    _emboss(canvas, nib, r);
    canvas.drawPath(
      nib,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.emblemLight, palette.emblemDark],
        ).createShader(bounds),
    );

    // The slit running from the vent down to the writing point, cut back
    // through the nib in the stock's own colour so it reads as an opening.
    canvas.drawLine(
      center + Offset(0, -r * 0.04),
      center + Offset(0, r * 0.62),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.6, r * 0.05)
        ..strokeCap = StrokeCap.round
        ..color = theme.surface.withValues(alpha: 0.85),
    );
  }

  /// Asymmetric on purpose: a broad rounded shoulder at the top tapering to a
  /// single writing point. Pointed at *both* ends it reads as a leaf.
  Path _nibPath(Offset center, double r) {
    Offset p(double x, double y) => center + Offset(x * r, y * r);

    final body = Path()
      ..moveTo(p(0, 0.70).dx, p(0, 0.70).dy)
      ..quadraticBezierTo(
        p(0.15, 0.30).dx,
        p(0.15, 0.30).dy,
        p(0.24, -0.12).dx,
        p(0.24, -0.12).dy,
      )
      ..quadraticBezierTo(
        p(0.30, -0.46).dx,
        p(0.30, -0.46).dy,
        p(0, -0.60).dx,
        p(0, -0.60).dy,
      )
      ..quadraticBezierTo(
        p(-0.30, -0.46).dx,
        p(-0.30, -0.46).dy,
        p(-0.24, -0.12).dx,
        p(-0.24, -0.12).dy,
      )
      ..quadraticBezierTo(
        p(-0.15, 0.30).dx,
        p(-0.15, 0.30).dy,
        p(0, 0.70).dx,
        p(0, 0.70).dy,
      )
      ..close();

    // Vent hole punched through, the way a real nib is.
    return Path.combine(
      PathOperation.difference,
      body,
      Path()..addOval(Rect.fromCircle(center: p(0, -0.18), radius: r * 0.10)),
    );
  }

  @override
  bool shouldRepaint(covariant _QuillRondelPainter oldDelegate) =>
      oldDelegate.theme != theme || oldDelegate.palette != palette;
}

/// Kader emblem: a crescent inside its ring — fate already written, waiting in
/// a closed volume. Pale gold on midnight, the card's second value step after
/// the cartouche.
class _CrescentRondelPainter extends CustomPainter {
  const _CrescentRondelPainter({required this.theme, required this.palette});

  final CardVisualTheme theme;
  final _DeckPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    if (r <= 0) return;
    final bounds = Rect.fromCircle(center: center, radius: r);

    _paintRondel(canvas, center, r, bounds, theme, palette, 0.32);

    // Crescent: full disc minus an offset disc. Sized to fill the ring, so it
    // still reads as a moon rather than a dot on a phone-sized deck.
    final moonRadius = r * 0.62;
    final crescent = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: center, radius: moonRadius)),
      Path()..addOval(
        Rect.fromCircle(
          center: center + Offset(moonRadius * 0.56, -moonRadius * 0.24),
          radius: moonRadius * 0.88,
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
          colors: [palette.emblemLight, palette.emblemDark],
        ).createShader(Rect.fromCircle(center: center, radius: moonRadius)),
    );
  }

  @override
  bool shouldRepaint(covariant _CrescentRondelPainter oldDelegate) =>
      oldDelegate.theme != theme || oldDelegate.palette != palette;
}

/// Stamps a soft dark offset under [path] so the emblem reads as pressed into
/// the card stock rather than printed flat on top of it.
void _emboss(Canvas canvas, Path path, double r) {
  canvas.drawPath(
    path.shift(Offset(0, r * 0.05)),
    Paint()
      ..color = Colors.black.withValues(alpha: 0.26)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.05),
  );
}
