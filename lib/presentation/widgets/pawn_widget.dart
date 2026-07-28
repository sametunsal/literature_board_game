import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../core/motion/motion_constants.dart';

/// Animated pawn widget: a small cast-metal literary figurine standing on the
/// board.
///
/// The pawn is not a token with a decal on it — it is a modelled object. Four
/// distinct pieces (open book, quill and inkwell, typewriter, lantern) each
/// have their own silhouette, in the same way a Monopoly car is recognisable
/// from its outline alone. All four stand on a shared enamel-and-brass plinth,
/// which is what carries the player colour and what makes the piece read as
/// *standing on* the board rather than *printed on* it.
///
/// The camera is a slightly top-down three-quarter view: horizontal planes are
/// foreshortened to [_kIso], verticals are not. That single rule is applied to
/// every disc, deck and collar in the file, so the four pieces look like they
/// were photographed on the same table under the same top-left key light.
///
/// Rendering is three layers: the ground spotlight (active player only), the
/// cast shadow — which stays welded to the board — and the figurine itself,
/// which is lifted off that shadow by the idle bob and the movement hop. The
/// separation between those two layers is the whole illusion of height.
///
/// The layout box is always exactly `size × size`; `PawnManager` positions
/// pawns by that contract and all depth is painted inside it.
class PawnWidget extends StatefulWidget {
  final Player player;
  final double size;
  final bool isActive;
  final bool isCurrentTurn;

  /// Which figurine this player is. Defaults to a stable choice derived from
  /// the player's icon index; `PawnManager` passes the seat index instead, so
  /// a four-player table always shows four *different* pieces.
  final PawnFigurine? figurine;

  const PawnWidget({
    super.key,
    required this.player,
    required this.size,
    this.isActive = false,
    this.isCurrentTurn = false,
    this.figurine,
  });

  /// Key on the moving part of the pawn. The outer box never moves — this
  /// marks the body that bobs, hops and lands, so tests can assert on motion
  /// without reaching into the painter.
  static const Key bodyKey = ValueKey('pawn_body');

  PawnFigurine get resolvedFigurine =>
      figurine ??
      PawnFigurine.values[player.iconIndex.abs() % PawnFigurine.values.length];

  @override
  State<PawnWidget> createState() => _PawnWidgetState();
}

/// The four collectible pieces. Ordered so that consecutive seats get pieces
/// whose outlines are as unlike each other as possible: wide-and-low, then
/// tall-and-thin, then boxy, then tall-and-round.
enum PawnFigurine {
  /// Open book resting on its covers, pages fanned into a wide V.
  book,

  /// Squat inkwell with a feather quill standing in it.
  quill,

  /// Portable typewriter with a sheet rolled into the carriage.
  typewriter,

  /// Reading lantern with a lit candle and a carry handle.
  lantern,
}

// ─── Stage geometry ──────────────────────────────────────────────────────────
// Fractions of the pawn's box size, measured from the box's top-left. Every
// figurine is authored against this one stage so the four pieces share a
// horizon, a light direction and a footprint.

/// Where the board surface is. The cast shadow lives here and never moves.
const double _kGroundY = 0.885;

/// Centre of the plinth's top face — the origin every figurine is built
/// around. Figurines extend *upwards* from here, in negative local Y.
const double _kStandY = 0.790;

/// Foreshortening applied to every horizontal plane: `ry = rx * _kIso`. This
/// is the camera. The previous token used 0.78, which is an almost-overhead
/// view of a flat disc; at 0.40 the eye reads a table seen from a player's
/// chair, and vertical extent starts to mean height instead of width.
const double _kIso = 0.40;

/// Radius of the plinth's top face.
const double _kPlinthRx = 0.285;

/// Visible height of the plinth wall.
const double _kPlinthH = 0.072;

/// Below this pixel size hairline detail (page text, typewriter keys, feather
/// barbs) is skipped — at small sizes it collapses into noise, and the
/// silhouette is doing all the work anyway.
const double _kDetailMinSize = 30.0;

/// Peak height of the idle bob on the active pawn, as a fraction of the box.
const double _kIdleBob = 0.026;

/// Peak height of the hop played when a pawn changes tile.
const double _kHopHeight = 0.115;

/// Pivot for the hop's lean and landing squash: the pawn's contact point with
/// the board, not the centre of its layout box.
const Alignment _kGroundPivot = Alignment(0, _kGroundY * 2 - 1);

class _PawnWidgetState extends State<PawnWidget> with TickerProviderStateMixin {
  /// Glow halo diameter relative to the pawn size. Purely decorative — it
  /// paints beyond the pawn's layout bounds without affecting them.
  static const double _glowExtent = 1.5;

  /// One full breathe/bob/shimmer cycle for the active pawn.
  static const Duration _aliveCycle = Duration(milliseconds: 2600);

  /// Fraction of the alive cycle during which the gloss sweep crosses the
  /// piece. Short, so the shimmer reads as an occasional catch of light rather
  /// than a permanently travelling stripe.
  static const double _shimmerWindow = 0.30;

  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _hopAnimation;
  late Animation<double> _leanAnimation;
  late Animation<double> _squashAnimation;

  /// Drives everything that makes the *active* pawn feel alive: the bob, the
  /// halo breathing and the gloss sweep. One controller for all three keeps
  /// them phase-coherent (the piece catches the light at the top of its bob)
  /// and costs a single ticker even across a long turn.
  late AnimationController _aliveController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: MotionDurations.pawn.safe,
      vsync: this,
    );

    // Movement reads as a hop, so the scale pulse only has to sell the
    // "closer to camera" part — a small overshoot.
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
    // tile with an accelerating fall. The shadow stays on the board while this
    // runs, so the piece genuinely leaves the surface.
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
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: _kHopHeight * 0.88,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 34,
      ),
    ]).animate(_pulseController);

    // A heavy piece does not travel bolt upright: it tips into the hop and
    // rights itself as it lands. Small enough (~2.5°) to read as weight rather
    // than as a cartoon wobble.
    _leanAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: -0.045,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -0.045,
          end: 0.018,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 44,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.018,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 26,
      ),
    ]).animate(_pulseController);

    // Vertical scale about the contact point: a slight stretch as the piece
    // leaves the board, a compression as it takes its own weight again. This
    // is the cue that reads as mass; without it a hop looks like a floating
    // sprite.
    _squashAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.035,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.035, end: 1.0),
        weight: 46,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.945,
        ).chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.945,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 20,
      ),
    ]).animate(_pulseController);

    _aliveController = AnimationController(vsync: this, duration: _aliveCycle);

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

  /// Gloss-sweep progress across the piece, or 0 when no sweep is in flight.
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
    final figurine = widget.resolvedFigurine;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _aliveController]),
      builder: (context, child) {
        // A single lift channel feeds both the idle bob and the movement hop.
        // The shadow painter reads the same value but stays on the ground.
        final lift = _hopAnimation.value + _breathe * _kIdleBob;
        final breathe = _breathe;
        final squash = _squashAnimation.value;

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
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: CustomPaint(painter: _PawnShadowPainter(lift: lift)),
                ),
                // Body: lifted, leaned and squashed about the contact point.
                // The shadow above is outside this stack on purpose.
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(0, -lift * size),
                    child: Transform.rotate(
                      angle: _leanAnimation.value,
                      alignment: _kGroundPivot,
                      child: Transform(
                        alignment: _kGroundPivot,
                        transform: Matrix4.diagonal3Values(
                          1 / squash,
                          squash,
                          1,
                        ),
                        child: SizedBox.expand(
                          key: PawnWidget.bodyKey,
                          child: CustomPaint(
                            painter: _PawnFigurinePainter(
                              palette: palette,
                              figurine: figurine,
                              shimmer: _shimmer,
                              breathe: breathe,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Material shades derived from a single player colour. Keeping the derivation
/// in one place guarantees every enamel surface on a piece reads as the *same*
/// lacquer, and keeps player identity unmistakable across four object shapes.
///
/// The player colour is deliberately confined to enamel — the plinth top, the
/// book covers, the lantern cap, the typewriter body. Brass, paper, ink and
/// glass are shared across all players, which is what stops a pawn from
/// becoming a monochrome blob.
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

  /// The player's own colour — the enamel mid-tone.
  final Color base;

  /// Brightest enamel tint, where the key light hits.
  final Color sheen;

  /// Light tint used for the bounce light on lower edges.
  final Color light;

  /// Shaded enamel on surfaces turned away from the key light.
  final Color deep;

  /// Darkest tone — enamel in full shadow and the contact edges.
  final Color rim;

  /// A half-shaded tone, used where enamel meets metal.
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
      identical(this, other) || other is PawnPalette && other.base == base;

  @override
  int get hashCode => base.hashCode;
}

/// Non-player materials. These are constant across the table: four pieces cast
/// from the same brass, printed on the same paper, glazed with the same amber.
/// Shared materials are what make the set look like a set.
abstract final class _Mat {
  static const brassShadow = Color(0xFF463317);
  static const brassDeep = Color(0xFF6E5528);
  static const brass = Color(0xFF9C7B3A);
  static const brassMid = Color(0xFFC09A4E);
  static const brassLight = Color(0xFFE6C980);
  static const brassSheen = Color(0xFFFAEFC6);

  static const paper = Color(0xFFFCF7EB);
  static const paperMid = Color(0xFFEADFC7);
  static const paperEdge = Color(0xFFC8B994);
  static const paperDeep = Color(0xFF9B8A64);

  static const ink = Color(0xFF171331);
  static const inkSheen = Color(0xFF554A8C);

  static const glassDeep = Color(0xFF7E4A16);
  static const glassMid = Color(0xFFE0983A);
  static const glassLight = Color(0xFFFFD892);

  static const flameCore = Color(0xFFFFF6D2);
  static const flameMid = Color(0xFFFFC65A);
  static const flameEdge = Color(0xFFF07A24);
}

/// Paints the cast shadow on the board surface. It lives in its own painter —
/// and deliberately *outside* the transform stack that lifts the body — so it
/// cannot follow the piece into the air. As [lift] grows the pair of shadows
/// shrinks, fades and blurs, which is the cue that tells the eye the piece has
/// left the board.
class _PawnShadowPainter extends CustomPainter {
  const _PawnShadowPainter({required this.lift});

  /// Height of the body above the board, as a fraction of the box size.
  final double lift;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    if (s <= 0) return;

    final t = (lift / _kHopHeight).clamp(0.0, 1.0);
    final shrink = 1.0 - 0.24 * t;
    final center = Offset(size.width * 0.515, size.height * _kGroundY);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: s * 0.78 * shrink,
        height: s * 0.20 * shrink,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.20 - 0.10 * t)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          s * (0.030 + 0.022 * t),
        ),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: s * 0.52 * shrink,
        height: s * 0.115 * shrink,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.46 - 0.24 * t)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          s * (0.012 + 0.016 * t),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _PawnShadowPainter oldDelegate) =>
      oldDelegate.lift != lift;
}

/// Drawing context handed to each figurine.
///
/// Everything is authored in *stand space*: `(0, 0)` is the centre of the
/// plinth's top face and negative Y is up. That lets each piece be written as
/// a sculpture standing on a table, independent of the pawn's pixel size, and
/// it is why the same source reads correctly at 8px and at 120px.
class _Stage {
  _Stage({
    required this.canvas,
    required this.s,
    required this.stand,
    required this.palette,
  }) : detail = s >= _kDetailMinSize;

  final Canvas canvas;

  /// The pawn box size in logical pixels — the unit of stand space.
  final double s;

  /// Canvas position of stand-space origin.
  final Offset stand;

  final PawnPalette palette;

  /// Whether hairline detail is legible at this size.
  final bool detail;

  /// Stand space → canvas.
  Offset p(double x, double y) => Offset(stand.dx + x * s, stand.dy + y * s);

  /// A length in stand space → pixels.
  double u(double v) => v * s;

  /// A stroke width in stand space, floored so hairlines never vanish.
  double w(double v) => math.max(0.5, v * s);

  /// A blur radius in stand space, floored to stay a valid mask filter.
  double b(double v) => math.max(0.3, v * s);

  /// A horizontal disc at height [y], seen under the stage camera.
  Rect disc(double y, double rx) => Rect.fromCenter(
    center: p(0, y),
    width: u(rx) * 2,
    height: u(rx) * _kIso * 2,
  );

  /// The dark keyline that separates a piece from busy tile art beneath it —
  /// and, just as importantly, separates two pieces sharing one tile.
  Paint get keyline => Paint()
    ..color = Colors.black.withValues(alpha: 0.34)
    ..style = PaintingStyle.stroke
    ..strokeWidth = w(0.011)
    ..strokeJoin = StrokeJoin.round;

  /// Fills a flat face with a linear ramp across its own bounds, then outlines
  /// it. Gradient-per-face rather than one gradient over the whole piece is
  /// what makes adjacent planes read as planes meeting at an angle.
  void face(
    List<Offset> points,
    List<Color> colors, {
    Alignment from = Alignment.topLeft,
    Alignment to = Alignment.bottomRight,
    List<double>? stops,
    bool outline = true,
  }) {
    final path = Path()..addPolygon(points, true);
    fillPath(path, colors, from: from, to: to, stops: stops, outline: outline);
  }

  void fillPath(
    Path path,
    List<Color> colors, {
    Alignment from = Alignment.topLeft,
    Alignment to = Alignment.bottomRight,
    List<double>? stops,
    bool outline = true,
  }) {
    final r = path.getBounds();
    if (r.width <= 0 || r.height <= 0) {
      canvas.drawPath(path, Paint()..color = colors.first);
    } else {
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: from,
            end: to,
            colors: colors,
            stops: stops,
          ).createShader(r),
      );
    }
    if (outline) canvas.drawPath(path, keyline);
  }

  void fillOval(
    Rect rect,
    List<Color> colors, {
    Alignment from = Alignment.topLeft,
    Alignment to = Alignment.bottomRight,
    List<double>? stops,
    bool outline = true,
  }) {
    fillPath(
      Path()..addOval(rect),
      colors,
      from: from,
      to: to,
      stops: stops,
      outline: outline,
    );
  }

  /// A soft bright arc along an edge: the catch of light on a turned metal rim.
  void sheenArc(
    Rect rect,
    double start,
    double sweep, {
    Color color = _Mat.brassSheen,
    double alpha = 0.60,
    double width = 0.014,
  }) {
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w(width)
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, b(0.008)),
    );
  }

  /// An upright cylinder: a wall between two discs plus the lit top face.
  /// Used for the plinth, the lantern's collars and the typewriter's roller.
  void column(
    double topY,
    double bottomY,
    double rx,
    List<Color> wallColors,
  ) {
    final top = disc(topY, rx);
    final bottom = disc(bottomY, rx);
    final wall = Path()
      ..moveTo(top.right, top.center.dy)
      ..arcTo(top, 0, math.pi, false)
      ..lineTo(bottom.left, bottom.center.dy)
      ..arcTo(bottom, math.pi, -math.pi, false)
      ..close();
    fillPath(wall, wallColors, from: Alignment.centerLeft, to: Alignment.centerRight);
  }
}

/// Paints the figurine itself — plinth, object, materials and gloss. Never the
/// ground shadow: that belongs to [_PawnShadowPainter], which does not move.
class _PawnFigurinePainter extends CustomPainter {
  const _PawnFigurinePainter({
    required this.palette,
    required this.figurine,
    required this.shimmer,
    required this.breathe,
  });

  final PawnPalette palette;
  final PawnFigurine figurine;

  /// Gloss sweep progress across the piece in 0..1; 0 means no sweep.
  final double shimmer;

  /// Active-turn breathing in 0..1. Only the lantern uses it, to make its
  /// flame swell — a piece-specific idle that costs nothing extra.
  final double breathe;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    if (s <= 0) return;

    final stage = _Stage(
      canvas: canvas,
      s: s,
      stand: Offset(size.width / 2, size.height * _kStandY),
      palette: palette,
    );

    // The gloss sweep is masked to the piece's own alpha, so it can travel
    // across a book or a typewriter without ever bleeding onto the tile. One
    // layer, and only while a sweep is actually in flight.
    final sweeping = shimmer > 0 && shimmer < 1;
    if (sweeping) canvas.saveLayer(Offset.zero & size, Paint());

    _paintPlinth(stage);
    switch (figurine) {
      case PawnFigurine.book:
        _paintBook(stage);
      case PawnFigurine.quill:
        _paintQuill(stage);
      case PawnFigurine.typewriter:
        _paintTypewriter(stage);
      case PawnFigurine.lantern:
        _paintLantern(stage, breathe);
    }

    if (sweeping) {
      _paintShimmer(canvas, size);
      canvas.restore();
    }
  }

  // ─── Shared plinth ─────────────────────────────────────────────────────────

  /// The base every piece stands on: a brass wall, a brass bevel and an enamel
  /// top in the player's colour. This is the only part of the pawn that is
  /// identical between players, which is exactly why it is the right place to
  /// carry identity — the colour always appears at the same size, in the same
  /// spot, whichever object is above it.
  void _paintPlinth(_Stage g) {
    g.column(0, _kPlinthH, _kPlinthRx, const [
      _Mat.brassShadow,
      _Mat.brassMid,
      _Mat.brass,
      _Mat.brassShadow,
    ]);

    final top = g.disc(0, _kPlinthRx);
    g.fillOval(
      top,
      const [_Mat.brassLight, _Mat.brass, _Mat.brassDeep],
      stops: const [0.0, 0.55, 1.0],
    );

    // Enamel inlay, inset far enough to leave a visible metal bezel.
    final inlay = g.disc(0, _kPlinthRx * 0.78);
    g.fillOval(
      inlay,
      [palette.sheen, palette.base, palette.deep],
      stops: const [0.0, 0.52, 1.0],
      outline: false,
    );
    g.canvas.drawOval(
      inlay,
      Paint()
        ..color = _Mat.brassShadow.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = g.w(0.008),
    );

    // Key light on the far-left of the bezel, bounce on the near-right foot.
    g.sheenArc(top, math.pi * 1.02, math.pi * 0.62);
    final foot = g.disc(_kPlinthH, _kPlinthRx);
    g.sheenArc(
      foot,
      math.pi * 0.10,
      math.pi * 0.80,
      color: _Mat.brassLight,
      alpha: 0.45,
      width: 0.012,
    );
  }

  // ─── 1. Open book ──────────────────────────────────────────────────────────

  /// Wide, low and unmistakable: a butterfly outline no other piece here can
  /// be confused with. Built as two page blocks with real thickness — top
  /// face, near edge, outer edge — plus an enamel cover slab below and a
  /// ribbon marker draped over the front, which is where the player colour
  /// lands at eye height.
  void _paintBook(_Stage g) {
    // The spine sits low enough that the cover's near corner touches the
    // plinth's enamel inlay. An open book balanced on its spine tip reads as
    // hovering; one whose binding is bedded into the base reads as resting.
    const spineNear = Offset(0, -0.055);
    const spineFar = Offset(0, -0.300);
    const leftNear = Offset(-0.405, -0.315);
    const leftFar = Offset(-0.345, -0.545);
    const pageT = 0.062; // page-block thickness
    const coverT = 0.030; // cover thickness below the pages

    for (final side in const [-1.0, 1.0]) {
      final lit = side < 0; // key light comes from the upper left
      Offset m(Offset o) => Offset(o.dx * side, o.dy);

      final sn = m(spineNear);
      final sf = m(spineFar);
      final on = m(leftNear);
      final of = m(leftFar);
      Offset down(Offset o, double d) => Offset(o.dx, o.dy + d);

      // Outer edge of the page block, seen almost edge-on.
      g.face(
        [
          g.p(on.dx, on.dy),
          g.p(of.dx, of.dy),
          g.p(of.dx, of.dy + pageT),
          g.p(on.dx, on.dy + pageT),
        ],
        const [_Mat.paperEdge, _Mat.paperDeep],
        from: Alignment.topCenter,
        to: Alignment.bottomCenter,
      );

      // Enamel cover, peeking out below the paper — the book's "binding".
      final coverOut = down(on, pageT);
      final coverIn = down(sn, pageT);
      g.face(
        [
          g.p(coverIn.dx, coverIn.dy),
          g.p(coverOut.dx * 1.03, coverOut.dy),
          g.p(coverOut.dx * 1.03, coverOut.dy + coverT),
          g.p(coverIn.dx, coverIn.dy + coverT),
        ],
        lit
            ? [palette.base, palette.rim]
            : [palette.deep, palette.rim],
        from: Alignment.topCenter,
        to: Alignment.bottomCenter,
      );

      // Near edge: the stack of page ends. The single most "book" surface on
      // the piece, so it gets the brightest paper and, when legible, the fine
      // striations of individual leaves.
      final nearEdge = [
        g.p(sn.dx, sn.dy),
        g.p(on.dx, on.dy),
        g.p(on.dx, on.dy + pageT),
        g.p(sn.dx, sn.dy + pageT),
      ];
      g.face(
        nearEdge,
        const [_Mat.paper, _Mat.paperMid, _Mat.paperEdge],
        from: Alignment.topCenter,
        to: Alignment.bottomCenter,
        stops: const [0.0, 0.5, 1.0],
      );
      if (g.detail) {
        final striation = Paint()
          ..color = _Mat.paperDeep.withValues(alpha: 0.35)
          ..strokeWidth = g.w(0.005);
        for (final f in const [0.35, 0.62]) {
          g.canvas.drawLine(
            g.p(sn.dx, sn.dy + pageT * f),
            g.p(on.dx, on.dy + pageT * f),
            striation,
          );
        }
      }

      // Top face: the open page, tilted up towards the reader.
      final top = [
        g.p(sn.dx, sn.dy),
        g.p(on.dx, on.dy),
        g.p(of.dx, of.dy),
        g.p(sf.dx, sf.dy),
      ];
      g.face(
        top,
        lit
            ? const [_Mat.paper, _Mat.paperMid]
            : const [_Mat.paperMid, _Mat.paperEdge],
        from: Alignment.topLeft,
        to: Alignment.bottomRight,
      );

      if (g.detail) {
        // Lines of type, running parallel to the spine.
        final type = Paint()
          ..color = _Mat.paperDeep.withValues(alpha: lit ? 0.42 : 0.30)
          ..strokeWidth = g.w(0.006)
          ..strokeCap = StrokeCap.round;
        for (final t in const [0.30, 0.52, 0.74]) {
          final a = Offset.lerp(sn, on, t)!;
          final b = Offset.lerp(sf, of, t)!;
          final inset = Offset.lerp(a, b, 0.18)!;
          final outset = Offset.lerp(a, b, 0.86)!;
          g.canvas.drawLine(
            g.p(inset.dx, inset.dy),
            g.p(outset.dx, outset.dy),
            type,
          );
        }
      }
    }

    // Brass hinge running down the spine, and the shadow in the gutter.
    g.face(
      [
        g.p(-0.036, -0.050),
        g.p(0.036, -0.050),
        g.p(0.030, -0.302),
        g.p(-0.030, -0.302),
      ],
      const [_Mat.brassLight, _Mat.brass, _Mat.brassDeep],
      from: Alignment.centerLeft,
      to: Alignment.centerRight,
    );

    // Enamel ribbon marker, draped over the near edge with a notched tail.
    g.face(
      [
        g.p(-0.024, -0.095),
        g.p(0.024, -0.095),
        g.p(0.024, 0.054),
        g.p(0.000, 0.018),
        g.p(-0.024, 0.054),
      ],
      [palette.sheen, palette.base, palette.deep],
      from: Alignment.topLeft,
      to: Alignment.bottomRight,
    );
  }

  // ─── 2. Quill and inkwell ──────────────────────────────────────────────────

  /// Tall and diagonal against the book's low horizontal — the feather reads
  /// from across the table. The shaft is a cubic that the vane and the barbs
  /// are both sampled from, so the feather always hugs its own spine no
  /// matter the size.
  void _paintQuill(_Stage g) {
    // Inkwell: a squat pot with a bulged shoulder.
    final bottom = g.disc(-0.015, 0.205);
    final pot = Path()
      ..moveTo(g.p(-0.205, -0.015).dx, g.p(-0.205, -0.015).dy)
      ..cubicTo(
        g.p(-0.238, -0.095).dx, g.p(-0.238, -0.095).dy,
        g.p(-0.228, -0.170).dx, g.p(-0.228, -0.170).dy,
        g.p(-0.150, -0.212).dx, g.p(-0.150, -0.212).dy,
      )
      ..lineTo(g.p(0.150, -0.212).dx, g.p(0.150, -0.212).dy)
      ..cubicTo(
        g.p(0.228, -0.170).dx, g.p(0.228, -0.170).dy,
        g.p(0.238, -0.095).dx, g.p(0.238, -0.095).dy,
        g.p(0.205, -0.015).dx, g.p(0.205, -0.015).dy,
      )
      ..arcTo(bottom, 0, math.pi, false)
      ..close();
    g.fillPath(
      pot,
      [palette.sheen, palette.base, palette.deep, palette.rim],
      from: Alignment.topLeft,
      to: Alignment.bottomRight,
      stops: const [0.0, 0.34, 0.72, 1.0],
    );

    // Brass collar and the ink surface inside it. The dark ellipse is what
    // makes the pot read as *open* rather than as a solid bead.
    final collar = g.disc(-0.212, 0.152);
    g.fillOval(
      collar,
      const [_Mat.brassLight, _Mat.brass, _Mat.brassDeep],
      stops: const [0.0, 0.5, 1.0],
    );
    final ink = collar.deflate(g.u(0.030));
    if (ink.width > 0 && ink.height > 0) {
      g.fillOval(
        ink,
        const [_Mat.inkSheen, _Mat.ink],
        stops: const [0.0, 0.7],
        outline: false,
      );
    }
    g.sheenArc(collar, math.pi * 1.00, math.pi * 0.66);
    g.sheenArc(
      bottom,
      math.pi * 0.12,
      math.pi * 0.76,
      color: palette.light,
      alpha: 0.50,
      width: 0.012,
    );

    // The shaft, as a cubic in stand space. Everything else on the feather is
    // derived from it.
    const p0 = Offset(0.045, -0.235);
    const p1 = Offset(0.015, -0.420);
    const p2 = Offset(0.105, -0.580);
    const p3 = Offset(0.215, -0.645);
    Offset at(double t) => _cubicAt(p0, p1, p2, p3, t);
    Offset normalAt(double t) {
      final d = _cubicTangent(p0, p1, p2, p3, t);
      final len = d.distance;
      if (len < 1e-6) return const Offset(0, 0);
      return Offset(-d.dy / len, d.dx / len);
    }

    // Vane: sampled either side of the shaft, wider on the lit side. A vane
    // that is symmetric, short and fat reads as a leaf; a quill needs one that
    // starts low on the shaft, is asymmetric about it, and tapers to nothing
    // well before the tip.
    const vaneStart = 0.14;
    const samples = 16;
    double width(double t, double amp) {
      final v = ((t - vaneStart) / (1 - vaneStart)).clamp(0.0, 1.0);
      // Peak biased towards the base, then a long run-out to the tip.
      return amp * math.pow(math.sin(math.pi * math.pow(v, 1.25)), 0.62)
          .toDouble();
    }

    for (final side in const [1.0, -1.0]) {
      final amp = side > 0 ? 0.104 : 0.066;
      final pts = <Offset>[];
      for (var i = 0; i <= samples; i++) {
        final t = vaneStart + (1 - vaneStart) * i / samples;
        final c = at(t);
        final n = normalAt(t);
        final wgt = width(t, amp) * side;
        pts.add(g.p(c.dx + n.dx * wgt, c.dy + n.dy * wgt));
      }
      for (var i = samples; i >= 0; i--) {
        final t = vaneStart + (1 - vaneStart) * i / samples;
        final c = at(t);
        pts.add(g.p(c.dx, c.dy));
      }
      g.face(
        pts,
        side > 0
            ? [palette.sheen, palette.base, palette.deep]
            : [palette.base, palette.deep, palette.rim],
        from: Alignment.topRight,
        to: Alignment.bottomLeft,
        stops: const [0.0, 0.5, 1.0],
      );

      if (g.detail) {
        final barb = Paint()
          ..color = Colors.white.withValues(alpha: side > 0 ? 0.46 : 0.26)
          ..strokeWidth = g.w(0.005)
          ..strokeCap = StrokeCap.round;
        for (final t in const [0.28, 0.40, 0.52, 0.64, 0.76, 0.88]) {
          final c = at(t);
          final n = normalAt(t);
          final wgt = width(t, amp) * side * 0.86;
          g.canvas.drawLine(
            g.p(c.dx, c.dy),
            g.p(c.dx + n.dx * wgt, c.dy + n.dy * wgt),
            barb,
          );
        }
      }
    }

    // Shaft over the vane, then its highlight — a quill's rachis is visible
    // through the barbs and this is what sells "feather" over "flame".
    final shaft = Path()
      ..moveTo(g.p(p0.dx, p0.dy).dx, g.p(p0.dx, p0.dy).dy)
      ..cubicTo(
        g.p(p1.dx, p1.dy).dx, g.p(p1.dx, p1.dy).dy,
        g.p(p2.dx, p2.dy).dx, g.p(p2.dx, p2.dy).dy,
        g.p(p3.dx, p3.dy).dx, g.p(p3.dx, p3.dy).dy,
      );
    g.canvas.drawPath(
      shaft,
      Paint()
        ..color = _Mat.brassDeep
        ..style = PaintingStyle.stroke
        ..strokeWidth = g.w(0.030)
        ..strokeCap = StrokeCap.round,
    );
    g.canvas.drawPath(
      shaft,
      Paint()
        ..color = _Mat.brassLight.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = g.w(0.013)
        ..strokeCap = StrokeCap.round,
    );

    // Nib, dipped into the ink.
    g.face(
      [
        g.p(0.012, -0.255),
        g.p(0.080, -0.255),
        g.p(0.046, -0.185),
      ],
      const [_Mat.brassSheen, _Mat.brass],
      from: Alignment.topLeft,
      to: Alignment.bottomRight,
    );
  }

  // ─── 3. Typewriter ─────────────────────────────────────────────────────────

  /// The boxy piece of the set. Its whole read comes from the stepped
  /// silhouette — body, sloping deck, roller, paper — so the geometry is kept
  /// blunt and the detail (keys, platen knobs) is decoration on top of an
  /// outline that already works.
  void _paintTypewriter(_Stage g) {
    // Sheet first, so the roller can occlude its lower edge.
    g.face(
      [
        g.p(-0.145, -0.325),
        g.p(0.155, -0.325),
        g.p(0.180, -0.610),
        g.p(-0.112, -0.625),
      ],
      const [_Mat.paper, _Mat.paperMid, _Mat.paperEdge],
      from: Alignment.topLeft,
      to: Alignment.bottomRight,
      stops: const [0.0, 0.6, 1.0],
    );
    if (g.detail) {
      final type = Paint()
        ..color = _Mat.paperDeep.withValues(alpha: 0.45)
        ..strokeWidth = g.w(0.006)
        ..strokeCap = StrokeCap.round;
      for (final y in const [-0.400, -0.455, -0.510]) {
        g.canvas.drawLine(g.p(-0.085, y), g.p(0.115, y), type);
      }
    }

    // Platen roller: an upright cylinder laid on its side, so it gets a
    // horizontal ramp rather than the stage's usual vertical one.
    final roller = RRect.fromRectAndRadius(
      Rect.fromPoints(g.p(-0.300, -0.348), g.p(0.300, -0.258)),
      Radius.circular(g.u(0.045)),
    );
    g.canvas.drawRRect(
      roller,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            _Mat.brassMid,
            _Mat.brassShadow,
            _Mat.brassDeep,
          ],
          stops: const [0.0, 0.62, 1.0],
        ).createShader(roller.outerRect),
    );
    g.canvas.drawRRect(roller, g.keyline);
    g.canvas.drawLine(
      g.p(-0.270, -0.333),
      g.p(0.270, -0.333),
      Paint()
        ..color = _Mat.brassSheen.withValues(alpha: 0.55)
        ..strokeWidth = g.w(0.012)
        ..strokeCap = StrokeCap.round,
    );

    // Platen knobs, in enamel — the piece's colour accent up at the top.
    for (final side in const [-1.0, 1.0]) {
      final knob = Rect.fromCircle(
        center: g.p(0.315 * side, -0.303),
        radius: g.u(0.050),
      );
      g.fillOval(
        knob,
        [palette.sheen, palette.base, palette.deep],
        stops: const [0.0, 0.5, 1.0],
      );
    }

    // Keyboard deck, narrowing towards the back under the stage camera.
    g.face(
      [
        g.p(-0.330, -0.135),
        g.p(0.330, -0.135),
        g.p(0.272, -0.265),
        g.p(-0.272, -0.265),
      ],
      const [_Mat.brassLight, _Mat.brass, _Mat.brassDeep],
      from: Alignment.topLeft,
      to: Alignment.bottomRight,
      stops: const [0.0, 0.45, 1.0],
    );

    if (g.detail) {
      final key = Paint()..color = _Mat.paperMid.withValues(alpha: 0.92);
      final keyRim = Paint()
        ..color = _Mat.brassShadow.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = g.w(0.005);
      for (var row = 0; row < 3; row++) {
        final y = -0.163 - row * 0.036;
        final half = 0.225 - row * 0.015;
        for (var i = 0; i < 5; i++) {
          final x = -half + (half * 2) * i / 4;
          final dot = Rect.fromCenter(
            center: g.p(x, y),
            width: g.u(0.040),
            height: g.u(0.024),
          );
          g.canvas.drawOval(dot, key);
          g.canvas.drawOval(dot, keyRim);
        }
      }
    }

    // Enamel body front — the largest colour field on this piece.
    g.face(
      [
        g.p(-0.330, -0.135),
        g.p(0.330, -0.135),
        g.p(0.330, -0.020),
        g.p(0.300, 0.006),
        g.p(-0.300, 0.006),
        g.p(-0.330, -0.020),
      ],
      [palette.sheen, palette.base, palette.deep, palette.rim],
      from: Alignment.topLeft,
      to: Alignment.bottomRight,
      stops: const [0.0, 0.30, 0.74, 1.0],
    );

    // Brass nameplate strip across the body.
    g.canvas.drawLine(
      g.p(-0.180, -0.072),
      g.p(0.180, -0.072),
      Paint()
        ..color = _Mat.brassLight.withValues(alpha: 0.80)
        ..strokeWidth = g.w(0.016)
        ..strokeCap = StrokeCap.round,
    );
  }

  // ─── 4. Lantern ────────────────────────────────────────────────────────────

  /// Tall, round-shouldered and the only lit piece in the set. The flame is
  /// the point: a warm core inside a cool board is instantly readable even at
  /// tile scale, and it gives the active player a second, piece-specific idle
  /// that costs one extra oval.
  void _paintLantern(_Stage g, double breathe) {
    // Foot.
    g.column(-0.075, -0.005, 0.195, const [
      _Mat.brassShadow,
      _Mat.brassMid,
      _Mat.brass,
      _Mat.brassShadow,
    ]);
    g.fillOval(
      g.disc(-0.075, 0.195),
      const [_Mat.brassLight, _Mat.brass, _Mat.brassDeep],
      stops: const [0.0, 0.5, 1.0],
    );

    // Glass chamber, slightly barrelled.
    final glass = Path()
      ..moveTo(g.p(-0.152, -0.088).dx, g.p(-0.152, -0.088).dy)
      ..cubicTo(
        g.p(-0.170, -0.190).dx, g.p(-0.170, -0.190).dy,
        g.p(-0.166, -0.290).dx, g.p(-0.166, -0.290).dy,
        g.p(-0.148, -0.378).dx, g.p(-0.148, -0.378).dy,
      )
      ..lineTo(g.p(0.148, -0.378).dx, g.p(0.148, -0.378).dy)
      ..cubicTo(
        g.p(0.166, -0.290).dx, g.p(0.166, -0.290).dy,
        g.p(0.170, -0.190).dx, g.p(0.170, -0.190).dy,
        g.p(0.152, -0.088).dx, g.p(0.152, -0.088).dy,
      )
      ..close();
    g.fillPath(
      glass,
      const [_Mat.glassLight, _Mat.glassMid, _Mat.glassDeep],
      from: Alignment.topLeft,
      to: Alignment.bottomRight,
      stops: const [0.0, 0.48, 1.0],
    );

    // Flame: a bloom plus a teardrop. The bloom swells with the active-turn
    // breathing; on an idle pawn it is a steady, quiet light.
    final swell = 1.0 + 0.16 * breathe;
    final bloomR = g.u(0.150) * swell;
    final bloomCenter = g.p(0, -0.235);
    g.canvas.drawCircle(
      bloomCenter,
      bloomR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _Mat.flameCore.withValues(alpha: 0.85),
            _Mat.flameMid.withValues(alpha: 0.35),
            _Mat.flameMid.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(
          Rect.fromCircle(center: bloomCenter, radius: bloomR),
        ),
    );
    final flame = Path()
      ..moveTo(g.p(0, -0.318).dx, g.p(0, -0.318).dy)
      ..quadraticBezierTo(
        g.p(0.052, -0.245).dx, g.p(0.052, -0.245).dy,
        g.p(0.020, -0.176).dx, g.p(0.020, -0.176).dy,
      )
      ..quadraticBezierTo(
        g.p(-0.006, -0.150).dx, g.p(-0.006, -0.150).dy,
        g.p(-0.034, -0.190).dx, g.p(-0.034, -0.190).dy,
      )
      ..quadraticBezierTo(
        g.p(-0.056, -0.250).dx, g.p(-0.056, -0.250).dy,
        g.p(0, -0.318).dx, g.p(0, -0.318).dy,
      )
      ..close();
    g.fillPath(
      flame,
      const [_Mat.flameCore, _Mat.flameMid, _Mat.flameEdge],
      from: Alignment.topCenter,
      to: Alignment.bottomCenter,
      stops: const [0.0, 0.45, 1.0],
      outline: false,
    );

    // Corner posts in enamel: the colour reads as a lacquered frame around
    // the glass rather than as a tint over it.
    for (final side in const [-1.0, 1.0]) {
      g.face(
        [
          g.p(0.152 * side, -0.086),
          g.p(0.118 * side, -0.086),
          g.p(0.114 * side, -0.380),
          g.p(0.148 * side, -0.380),
        ],
        side < 0
            ? [palette.sheen, palette.base]
            : [palette.base, palette.rim],
        from: Alignment.centerLeft,
        to: Alignment.centerRight,
      );
    }

    // Collars top and bottom.
    g.column(-0.100, -0.072, 0.178, const [
      _Mat.brassShadow,
      _Mat.brassMid,
      _Mat.brassDeep,
    ]);
    g.column(-0.400, -0.372, 0.182, const [
      _Mat.brassShadow,
      _Mat.brassMid,
      _Mat.brassDeep,
    ]);

    // Pagoda cap in enamel, brass finial on top.
    g.face(
      [
        g.p(-0.212, -0.396),
        g.p(0.212, -0.396),
        g.p(0.074, -0.502),
        g.p(-0.074, -0.502),
      ],
      [palette.sheen, palette.base, palette.deep],
      from: Alignment.topLeft,
      to: Alignment.bottomRight,
      stops: const [0.0, 0.48, 1.0],
    );
    g.fillOval(
      g.disc(-0.502, 0.074),
      const [_Mat.brassLight, _Mat.brass, _Mat.brassDeep],
      stops: const [0.0, 0.5, 1.0],
    );

    // Carry handle — the detail that names the object from ten feet away.
    final handle = Path()
      ..moveTo(g.p(-0.086, -0.518).dx, g.p(-0.086, -0.518).dy)
      ..cubicTo(
        g.p(-0.118, -0.660).dx, g.p(-0.118, -0.660).dy,
        g.p(0.118, -0.660).dx, g.p(0.118, -0.660).dy,
        g.p(0.086, -0.518).dx, g.p(0.086, -0.518).dy,
      );
    g.canvas.drawPath(
      handle,
      Paint()
        ..color = _Mat.brassDeep
        ..style = PaintingStyle.stroke
        ..strokeWidth = g.w(0.032)
        ..strokeCap = StrokeCap.round,
    );
    g.canvas.drawPath(
      handle,
      Paint()
        ..color = _Mat.brassLight.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = g.w(0.013)
        ..strokeCap = StrokeCap.round,
    );

    // Glass highlight last, so it sits over the posts like a reflection.
    if (g.detail) {
      g.canvas.drawPath(
        Path()
          ..moveTo(g.p(-0.096, -0.130).dx, g.p(-0.096, -0.130).dy)
          ..lineTo(g.p(-0.096, -0.336).dx, g.p(-0.096, -0.336).dy),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.42)
          ..style = PaintingStyle.stroke
          ..strokeWidth = g.w(0.018)
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  // ─── Gloss sweep ───────────────────────────────────────────────────────────

  /// A narrow diagonal band of light travelling across the whole piece.
  /// [BlendMode.srcATop] confines it to what has already been painted inside
  /// the layer — that is, to the figurine's own silhouette — so a highlight
  /// can cross a typewriter or a feather without ever spilling onto the tile.
  void _paintShimmer(Canvas canvas, Size size) {
    final travel = size.width * 1.9;
    final x = -size.width * 0.45 + shimmer * travel;
    final band = Rect.fromCenter(
      center: Offset(x, size.height * 0.45),
      width: size.width * 0.30,
      height: size.height * 2.4,
    );

    canvas.save();
    canvas.translate(band.center.dx, band.center.dy);
    canvas.rotate(-0.34);
    canvas.translate(-band.center.dx, -band.center.dy);
    canvas.drawRect(
      band,
      Paint()
        ..blendMode = BlendMode.srcATop
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.34),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(band),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PawnFigurinePainter oldDelegate) =>
      oldDelegate.shimmer != shimmer ||
      oldDelegate.breathe != breathe ||
      oldDelegate.figurine != figurine ||
      oldDelegate.palette != palette;
}

/// Point on a cubic Bézier at [t].
Offset _cubicAt(Offset a, Offset b, Offset c, Offset d, double t) {
  final mt = 1 - t;
  final w0 = mt * mt * mt;
  final w1 = 3 * mt * mt * t;
  final w2 = 3 * mt * t * t;
  final w3 = t * t * t;
  return Offset(
    a.dx * w0 + b.dx * w1 + c.dx * w2 + d.dx * w3,
    a.dy * w0 + b.dy * w1 + c.dy * w2 + d.dy * w3,
  );
}

/// Derivative of a cubic Bézier at [t] — the shaft direction, from which the
/// feather's normals are taken.
Offset _cubicTangent(Offset a, Offset b, Offset c, Offset d, double t) {
  final mt = 1 - t;
  return Offset(
    3 * mt * mt * (b.dx - a.dx) +
        6 * mt * t * (c.dx - b.dx) +
        3 * t * t * (d.dx - c.dx),
    3 * mt * mt * (b.dy - a.dy) +
        6 * mt * t * (c.dy - b.dy) +
        3 * t * t * (d.dy - c.dy),
  );
}

/// Active-turn halo: a soft coloured bloom on the board plus a thin ellipse of
/// containment, both breathing with [intensity]. Both stay on the ground plane
/// while the piece bobs above them, so the effect reads as a pool of light
/// under a figurine rather than as a sticker attached to it.
class _PawnGlowPainter extends CustomPainter {
  const _PawnGlowPainter({required this.palette, required this.intensity});

  final PawnPalette palette;
  final double intensity;

  /// Where the board plane sits inside the oversized glow box. The glow box is
  /// centred on the pawn box, so the ground offset has to be rescaled by the
  /// glow's extent to land on the same line as the cast shadow.
  static const double _groundOffset = (_kGroundY - 0.5) / 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final maxR = size.shortestSide / 2;
    if (maxR <= 0) return;

    final ground = size.center(Offset(0, size.height * _groundOffset));

    final bloomR = maxR * (0.72 + 0.14 * intensity);
    canvas.drawCircle(
      ground,
      bloomR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            palette.base.withValues(alpha: 0.40 + 0.26 * intensity),
            palette.base.withValues(alpha: 0.15 + 0.12 * intensity),
            palette.base.withValues(alpha: 0.0),
          ],
          stops: const [0.30, 0.62, 1.0],
        ).createShader(Rect.fromCircle(center: ground, radius: bloomR)),
    );

    // Containment ring, foreshortened by the stage camera so it reads as a
    // spotlight ellipse lying on the table.
    canvas.drawOval(
      Rect.fromCenter(
        center: ground,
        width: maxR * 1.24,
        height: maxR * 1.24 * _kIso,
      ),
      Paint()
        ..color = palette.sheen.withValues(alpha: 0.26 + 0.34 * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.6, maxR * 0.030),
    );
  }

  @override
  bool shouldRepaint(covariant _PawnGlowPainter oldDelegate) =>
      oldDelegate.intensity != intensity || oldDelegate.palette != palette;
}
