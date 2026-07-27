import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../core/constants/game_constants.dart';
import '../../core/motion/motion_constants.dart';

/// Animated pawn widget: a premium enamel-and-metal board-game token.
///
/// The pawn is a genuinely *extruded* piece rather than a painted circle. It
/// is drawn as a token seen from slightly above: an elliptical cap sitting on
/// a visible side wall that flares into a base flange, with the cast shadow on
/// the ground plane beneath it. That silhouette — cap, wall, foot, shadow — is
/// what makes a token read as having height; a single shaded circle never can.
///
/// Everything is one [CustomPainter] pass so each pawn costs one paint layer,
/// and only the player glyph stays a widget so it renders crisply at small
/// sizes. Public API is unchanged and the layout box is always exactly
/// `size × size` — [PawnManager] positions pawns by that contract.
class PawnWidget extends StatefulWidget {
  final Player player;
  final double size;
  final bool isActive;
  final bool isCurrentTurn;

  const PawnWidget({
    super.key,
    required this.player,
    required this.size,
    this.isActive = false,
    this.isCurrentTurn = false,
  });

  @override
  State<PawnWidget> createState() => _PawnWidgetState();
}

// ─── Token geometry ──────────────────────────────────────────────────────────
// All fractions of the pawn's box size. The piece is tuned to sit inside the
// box with the cap near the top and the ground plane near the bottom, so a
// lifted pawn reveals the shadow beneath it without leaving its slot.

/// Vertical centre of the cap ellipse.
const double _kCapCenterY = 0.355;

/// Cap radius on the X axis.
const double _kCapRadiusX = 0.385;

/// Foreshortening of the cap: ry = rx * flatten. This sets how steeply the
/// board is "viewed". Enough tilt that the top face reads as a plate lying on
/// the table, not enough to squash the player glyph.
const double _kCapFlatten = 0.78;

/// Height of the visible side wall between cap and base. Tall enough that the
/// straight section dominates the rounded ends of the silhouette — that ratio
/// is what makes the eye read "chip with height" instead of "ball".
const double _kWallHeight = 0.18;

/// Width of the base relative to the cap. Kept at 1.0 so the sides are a
/// straight machined cylinder — a flared foot reads as a lumpy mushroom at
/// pawn sizes, a chip-straight wall reads as a manufactured token.
const double _kBaseSpread = 1.0;

/// Enamel dome radius as a fraction of the cap radius; the difference is the
/// visible polished metal rim. Narrow, so the rim reads as a jewelled band
/// rather than a second disc stacked on the first.
const double _kDomeRatio = 0.87;

/// Below this pixel size the machined groove around the wall is skipped —
/// at small sizes it collapses into noise instead of detail.
const double _kGrooveMinSize = 22.0;

/// Player glyph size as a fraction of the box size. Sized to sit inside the
/// foreshortened dome without crowding the rim.
const double _kGlyphSize = 0.38;

/// Peak height of the idle bob on the active pawn, as a fraction of the box.
const double _kIdleBob = 0.028;

/// Peak height of the hop played when a pawn changes tile.
const double _kHopHeight = 0.10;

class _PawnWidgetState extends State<PawnWidget> with TickerProviderStateMixin {
  /// Glow halo diameter relative to the pawn size. Purely decorative — it
  /// paints beyond the pawn's layout bounds without affecting them.
  static const double _glowExtent = 1.5;

  /// One full breathe/bob/shimmer cycle for the active pawn.
  static const Duration _aliveCycle = Duration(milliseconds: 2600);

  /// Fraction of the alive cycle during which the gloss sweep crosses the cap.
  /// Short, so the shimmer reads as an occasional catch of light rather than a
  /// constantly moving stripe.
  static const double _shimmerWindow = 0.30;

  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _hopAnimation;

  /// Drives everything that makes the *active* pawn feel alive: the bob, the
  /// halo breathing and the gloss sweep. One controller for all three keeps
  /// them phase-coherent (the pawn glows brightest at the top of its bob) and
  /// costs a single ticker even when a pawn is on screen for a long turn.
  late AnimationController _aliveController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: MotionDurations.pawn.safe,
      vsync: this,
    );

    // Movement now reads as a hop, so the scale pulse only has to sell the
    // "closer to camera" part — a small overshoot instead of the old 1.12.
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.06,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.06,
          end: 1.05,
        ).chain(CurveTween(curve: MotionCurves.breathe)),
        weight: 56,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.05,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 22,
      ),
    ]).animate(_pulseController);

    // The hop: lifted quickly, carried while sliding, then dropped onto the
    // tile with a decelerating landing. The painter keeps the cast shadow on
    // the ground while this runs, so the piece genuinely leaves the board.
    _hopAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: _kHopHeight,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 26,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: _kHopHeight,
          end: _kHopHeight * 0.88,
        ).chain(CurveTween(curve: MotionCurves.breathe)),
        weight: 44,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: _kHopHeight * 0.88,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 30,
      ),
    ]).animate(_pulseController);

    _aliveController = AnimationController(
      vsync: this,
      duration: _aliveCycle,
    );

    if (widget.isCurrentTurn) {
      _startAlive();
    }
  }

  /// Repeats forward (never reversing) so the gloss sweep always travels the
  /// same direction; the bob and glow use a cosine of the phase, which is
  /// continuous across the wrap.
  void _startAlive() {
    if (reduceMotion) return;
    _aliveController.repeat();
  }

  @override
  void didUpdateWidget(PawnWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.player.position != widget.player.position) {
      _pulseController.forward(from: 0);
    }

    if (widget.isCurrentTurn && !oldWidget.isCurrentTurn) {
      _startAlive();
    } else if (!widget.isCurrentTurn && oldWidget.isCurrentTurn) {
      _aliveController.stop();
      _aliveController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _aliveController.dispose();
    super.dispose();
  }

  /// Breathing value in 0..1 derived from the alive phase. Cosine-based so it
  /// is smooth and seamless where the cycle wraps.
  double get _breathe {
    if (!widget.isCurrentTurn) return 0.0;
    if (reduceMotion) return 0.55; // steady presence, no motion
    return 0.5 - 0.5 * math.cos(_aliveController.value * 2 * math.pi);
  }

  /// Gloss-sweep progress across the cap, or 0 when no sweep is in flight.
  double get _shimmer {
    if (!widget.isCurrentTurn || reduceMotion) return 0.0;
    final t = _aliveController.value;
    if (t >= _shimmerWindow) return 0.0;
    return Curves.easeInOut.transform(t / _shimmerWindow);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final palette = PawnPalette.from(widget.player.color);
    final glyph = Icon(
      GameConstants.iconPalette[widget.player.iconIndex %
          GameConstants.iconPalette.length],
      size: size * _kGlyphSize,
      color: Colors.white,
      shadows: [
        Shadow(
          color: palette.deep.withValues(alpha: 0.60),
          offset: Offset(0, size * 0.028),
          blurRadius: size * 0.05,
        ),
      ],
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _aliveController]),
      builder: (context, child) {
        // A single lift channel feeds both the idle bob and the movement hop.
        // The painter offsets the token body by it while leaving the cast
        // shadow on the ground plane — that separation is the whole illusion.
        final lift = _hopAnimation.value + _breathe * _kIdleBob;
        final breathe = _breathe;

        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (widget.isCurrentTurn)
                  OverflowBox(
                    maxWidth: size * _glowExtent,
                    maxHeight: size * _glowExtent,
                    child: SizedBox(
                      width: size * _glowExtent,
                      height: size * _glowExtent,
                      child: CustomPaint(
                        painter: _PawnGlowPainter(
                          palette: palette,
                          intensity: breathe,
                          lift: lift,
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PawnTokenPainter(
                      palette: palette,
                      lift: lift,
                      shimmer: _shimmer,
                    ),
                  ),
                ),
                // The glyph rides the cap, so it lifts with the token body.
                Positioned(
                  left: size * (0.5 - _kGlyphSize / 2),
                  top: size * (_kCapCenterY - lift - _kGlyphSize / 2),
                  child: child!,
                ),
              ],
            ),
          ),
        );
      },
      child: glyph,
    );
  }
}

/// Material shades derived from a single player colour. Keeping the derivation
/// in one place guarantees the cap, wall, rim, bounce light and glow all read
/// as the *same* material, and keeps player identity unmistakable.
@immutable
class PawnPalette {
  const PawnPalette({
    required this.base,
    required this.sheen,
    required this.light,
    required this.deep,
    required this.rim,
    required this.rimLight,
  });

  /// The player's own colour — the cap's mid-tone.
  final Color base;

  /// Brightest enamel tint, where the key light hits.
  final Color sheen;

  /// Light tint used for the bounce light on the lower edges.
  final Color light;

  /// Shaded enamel at the far side of the dome and down the wall.
  final Color deep;

  /// Darkest tone — the turned metal rim and the foot in shadow.
  final Color rim;

  /// Lit side of the metal rim.
  final Color rimLight;

  factory PawnPalette.from(Color color) {
    final hsl = HSLColor.fromColor(color);
    Color shift(double lightness, [double saturation = 0]) => hsl
        .withLightness((hsl.lightness + lightness).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + saturation).clamp(0.0, 1.0))
        .toColor();

    return PawnPalette(
      base: color,
      sheen: shift(0.28, -0.10),
      light: shift(0.15, -0.04),
      deep: shift(-0.20, 0.02),
      rim: shift(-0.34, 0.04),
      rimLight: shift(-0.04, -0.02),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PawnPalette && other.base == base;

  @override
  int get hashCode => base.hashCode;
}

/// Paints the whole token: ground shadow, base flange, side wall, metal rim,
/// enamel cap, inner shading, specular highlights and the optional gloss
/// sweep. [lift] raises the body off the ground plane (idle bob or hop) while
/// the shadow stays put and tightens, which is what sells the height.
class _PawnTokenPainter extends CustomPainter {
  const _PawnTokenPainter({
    required this.palette,
    required this.lift,
    required this.shimmer,
  });

  final PawnPalette palette;

  /// Height above the ground plane, as a fraction of the box size.
  final double lift;

  /// Gloss sweep progress across the cap in 0..1; 0 means no sweep.
  final double shimmer;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    if (s <= 0) return;

    final cx = size.width / 2;
    final dy = -lift * s;

    final capCenter = Offset(cx, size.height * _kCapCenterY + dy);
    final rxCap = s * _kCapRadiusX;
    final ryCap = rxCap * _kCapFlatten;

    final baseCenter = Offset(cx, capCenter.dy + s * _kWallHeight);
    final rxBase = rxCap * _kBaseSpread;
    final ryBase = ryCap * _kBaseSpread;

    final capRect = Rect.fromCenter(
      center: capCenter,
      width: rxCap * 2,
      height: ryCap * 2,
    );
    final baseRect = Rect.fromCenter(
      center: baseCenter,
      width: rxBase * 2,
      height: ryBase * 2,
    );

    _paintGroundShadow(canvas, size, s);
    final body = _bodyPath(capRect, baseRect);
    _paintWall(canvas, body, capRect, baseRect, s);
    _paintCap(canvas, capRect, s);
    _paintSilhouette(canvas, body, capRect, s);
  }

  /// The silhouette of the extruded body: the front half of the cap ellipse,
  /// down the sides, around the front half of the base flange.
  Path _bodyPath(Rect capRect, Rect baseRect) {
    return Path()
      ..moveTo(capRect.right, capRect.center.dy)
      // Cap: right → bottom → left (angles run clockwise, y down).
      ..arcTo(capRect, 0, math.pi, false)
      ..lineTo(baseRect.left, baseRect.center.dy)
      // Base flange: left → bottom → right.
      ..arcTo(baseRect, math.pi, -math.pi, false)
      ..close();
  }

  /// Soft ambient shadow plus a tight contact shadow, both on the ground
  /// plane. As [lift] grows the pair shrinks, fades and blurs — the cue that
  /// tells the eye the piece is off the board rather than just moving.
  void _paintGroundShadow(Canvas canvas, Size size, double s) {
    final t = (lift / _kHopHeight).clamp(0.0, 1.0);
    final shrink = 1.0 - 0.20 * t;
    final center = Offset(size.width * 0.515, size.height * 0.862);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: s * 0.74 * shrink,
        height: s * 0.13 * shrink,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18 - 0.09 * t)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          s * (0.028 + 0.020 * t),
        ),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: s * 0.50 * shrink,
        height: s * 0.085 * shrink,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.44 - 0.22 * t)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          s * (0.012 + 0.014 * t),
        ),
    );
  }

  /// The side of the piece. Shaded twice: a vertical pass for the light
  /// falling down the wall into the contact darkness, then a horizontal pass
  /// for the cylindrical falloff at the left and right edges. Without the
  /// second pass the wall reads as a flat band and the piece looks pasted on.
  void _paintWall(
    Canvas canvas,
    Path body,
    Rect capRect,
    Rect baseRect,
    double s,
  ) {
    final bounds = Rect.fromLTRB(
      baseRect.left,
      capRect.center.dy,
      baseRect.right,
      baseRect.bottom,
    );

    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.rim,
            palette.deep,
            palette.deep,
            palette.light,
            palette.rim,
          ],
          stops: const [0.0, 0.26, 0.64, 0.88, 1.0],
        ).createShader(bounds),
    );

    // Cylindrical falloff: dark at both edges, a soft lit band left of centre
    // where the key light wraps around.
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.black.withValues(alpha: 0.38),
            Colors.white.withValues(alpha: 0.12),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.42),
          ],
          stops: const [0.0, 0.32, 0.56, 1.0],
        ).createShader(bounds),
    );

    // Machined groove: a single hairline running around the wall, the detail
    // that separates a moulded token from an extruded blob. Skipped on tiny
    // pawns where it would only add noise.
    if (s >= _kGrooveMinSize) {
      final groove = Rect.fromCenter(
        center: capRect.center.translate(0, (baseRect.center.dy - capRect.center.dy) * 0.52),
        width: capRect.width,
        height: capRect.height,
      ).deflate(s * 0.012);
      canvas.drawArc(
        groove,
        math.pi * 0.06,
        math.pi * 0.88,
        false,
        Paint()
          ..color = palette.light.withValues(alpha: 0.30)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.5, s * 0.012),
      );
    }

    // Bounce light riding the front edge of the foot.
    canvas.drawArc(
      baseRect.deflate(math.max(0.3, s * 0.010)),
      math.pi * 0.14,
      math.pi * 0.72,
      false,
      Paint()
        ..color = palette.light.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.5, s * 0.018)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          math.max(0.3, s * 0.012),
        ),
    );
  }

  /// The top face: polished metal rim, enamel dome, inner shading, gloss.
  void _paintCap(Canvas canvas, Rect capRect, double s) {
    // Polished metal rim, lit from the top-left and picking up a bounce at the
    // bottom-right. A linear ramp along the light axis is used rather than a
    // sweep so the lit side lands exactly where the dome's highlight is.
    canvas.drawOval(
      capRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.rimLight,
            palette.rim,
            palette.rim,
            palette.light,
          ],
          stops: const [0.0, 0.38, 0.74, 1.0],
        ).createShader(capRect),
    );

    // Bevel catch: a bright arc on the upper-left of the rim, where a real
    // polished edge picks up the key light.
    canvas.drawArc(
      capRect.deflate(math.max(0.3, s * 0.010)),
      math.pi * 1.06,
      math.pi * 0.54,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.5, s * 0.014)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          math.max(0.3, s * 0.008),
        ),
    );

    final domeRect = Rect.fromCenter(
      center: capRect.center,
      width: capRect.width * _kDomeRatio,
      height: capRect.height * _kDomeRatio,
    );

    // Enamel top face. Deliberately flatter than a sphere would be — on a real
    // token the height lives in the wall, and an over-domed top makes the piece
    // read as a marble.
    canvas.drawOval(
      domeRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.34, -0.46),
          radius: 1.18,
          colors: [palette.sheen, palette.base, palette.base, palette.deep],
          stops: const [0.0, 0.44, 0.74, 1.0],
        ).createShader(domeRect),
    );

    // Shadow cast by the rim onto the enamel at the top of the dome, and the
    // reflected bounce along the lower-right. The pair is what makes a glossy
    // surface look thick rather than printed.
    canvas.drawArc(
      domeRect.deflate(domeRect.height * 0.05),
      math.pi * 0.96,
      math.pi * 1.06,
      false,
      Paint()
        ..color = palette.rim.withValues(alpha: 0.50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.6, domeRect.height * 0.15)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(0.4, s * 0.018)),
    );
    canvas.drawArc(
      domeRect.deflate(domeRect.height * 0.05),
      math.pi * 0.06,
      math.pi * 0.70,
      false,
      Paint()
        ..color = palette.light.withValues(alpha: 0.58)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.5, domeRect.height * 0.11)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(0.4, s * 0.016)),
    );

    _paintSpecular(canvas, domeRect);
    _paintShimmer(canvas, domeRect);
  }

  /// Two-part gloss: a broad soft highlight for the wet-lacquer sheen and a
  /// small tight hotspot for the hard specular. One alone reads as fog or as
  /// a sticker; together they read as a coated surface.
  void _paintSpecular(Canvas canvas, Rect domeRect) {
    final soft = Rect.fromCenter(
      center: domeRect.center.translate(
        -domeRect.width * 0.15,
        -domeRect.height * 0.24,
      ),
      width: domeRect.width * 0.72,
      height: domeRect.height * 0.46,
    );
    canvas.drawOval(
      soft,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.60),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(soft),
    );

    final hot = Rect.fromCenter(
      center: domeRect.center.translate(
        -domeRect.width * 0.22,
        -domeRect.height * 0.30,
      ),
      width: domeRect.width * 0.28,
      height: domeRect.height * 0.20,
    );
    canvas.drawOval(
      hot,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.92),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.15, 1.0],
        ).createShader(hot),
    );
  }

  /// A narrow diagonal band of light travelling across the cap. Clipped to the
  /// dome so it never bleeds onto the tile, and only drawn while a sweep is in
  /// flight — the active pawn catches the light once per cycle instead of
  /// carrying a permanently moving stripe.
  void _paintShimmer(Canvas canvas, Rect domeRect) {
    if (shimmer <= 0 || shimmer >= 1) return;

    canvas.save();
    canvas.clipPath(Path()..addOval(domeRect));

    final travel = domeRect.width * 2.0;
    final x = domeRect.center.dx - travel / 2 + shimmer * travel;
    final band = Rect.fromCenter(
      center: Offset(x, domeRect.center.dy),
      width: domeRect.width * 0.42,
      height: domeRect.height * 2.6,
    );

    canvas.translate(band.center.dx, band.center.dy);
    canvas.rotate(-0.42);
    canvas.translate(-band.center.dx, -band.center.dy);

    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.38),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(band),
    );
    canvas.restore();
  }

  /// Crisp dark keyline around the whole piece so it separates from busy tile
  /// art, plus a hairline under the cap that reads as the seam between the
  /// enamel top and the metal wall.
  void _paintSilhouette(Canvas canvas, Path body, Rect capRect, double s) {
    final keyline = Paint()
      ..color = Colors.black.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.5, s * 0.014);

    canvas.drawPath(body, keyline);
    canvas.drawOval(capRect.deflate(math.max(0.25, s * 0.006)), keyline);
  }

  @override
  bool shouldRepaint(covariant _PawnTokenPainter oldDelegate) =>
      oldDelegate.lift != lift ||
      oldDelegate.shimmer != shimmer ||
      oldDelegate.palette != palette;
}

/// Active-turn halo: a soft coloured bloom on the ground plane plus a thin
/// containment ring, both breathing with [intensity]. The bloom stays on the
/// ground while the token bobs, so it reads as a pool of light under the piece
/// rather than a sticker attached to it.
class _PawnGlowPainter extends CustomPainter {
  const _PawnGlowPainter({
    required this.palette,
    required this.intensity,
    required this.lift,
  });

  final PawnPalette palette;
  final double intensity;
  final double lift;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;
    if (maxR <= 0) return;

    final bloomR = maxR * (0.80 + 0.14 * intensity);
    canvas.drawCircle(
      center,
      bloomR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            palette.base.withValues(alpha: 0.40 + 0.26 * intensity),
            palette.base.withValues(alpha: 0.15 + 0.12 * intensity),
            palette.base.withValues(alpha: 0.0),
          ],
          stops: const [0.30, 0.62, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: bloomR)),
    );

    // Containment ring, flattened to the board plane so it reads as a
    // spotlight ellipse on the table rather than a flat sticker ring.
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, size.height * 0.10),
        width: maxR * 1.32,
        height: maxR * 1.32 * _kCapFlatten * 0.72,
      ),
      Paint()
        ..color = palette.sheen.withValues(alpha: 0.26 + 0.34 * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.6, maxR * 0.032),
    );
  }

  @override
  bool shouldRepaint(covariant _PawnGlowPainter oldDelegate) =>
      oldDelegate.intensity != intensity ||
      oldDelegate.lift != lift ||
      oldDelegate.palette != palette;
}
