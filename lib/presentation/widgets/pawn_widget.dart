import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../core/constants/game_constants.dart';
import '../../core/motion/motion_constants.dart';

/// Animated pawn widget: a premium enamel-and-metal board-game token.
///
/// The token is painted in a single [CustomPainter] pass rather than stacked
/// [Container]s so that the lacquered read (metal rim, enamel dome, bounce
/// light, specular sheen) can use arcs and shaders that box decorations can't
/// express — and so each pawn costs one paint layer instead of six blurred
/// ones. Only the player glyph stays a widget, so it keeps text/icon rendering
/// and remains crisp at small sizes.
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

/// Vertical centre of the token dome inside the size×size layout box. The
/// token sits slightly high so the contact shadow has room beneath it.
const double _kBodyCenterY = 0.455;

/// Outer radius of the token (rim included), as a fraction of the box size.
const double _kTokenRadius = 0.42;

/// Enamel dome radius as a fraction of the outer radius; the difference is
/// the visible metal rim.
const double _kDomeRatio = 0.855;

/// Player glyph size as a fraction of the box size.
const double _kGlyphSize = 0.46;

class _PawnWidgetState extends State<PawnWidget> with TickerProviderStateMixin {
  /// Glow halo diameter relative to the pawn size. Purely decorative — it
  /// paints beyond the pawn's layout bounds without affecting them.
  static const double _glowExtent = 1.5;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Pulsating glow controller
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation - subtle scale up when moving
    _pulseController = AnimationController(
      duration: MotionDurations.pawn.safe,
      vsync: this,
    );

    // Smooth scale pulse: 1.0 → 1.12 → 1.0 with polished curves
    _pulseAnimation = TweenSequence<double>([
      // Scale up with overshoot effect (pickup feel)
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.12,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 18,
      ),
      // Subtle breathing at peak while sliding
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.12,
          end: 1.10,
        ).chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 64,
      ),
      // Gentle scale back down with settling bounce (place)
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.10,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 18,
      ),
    ]).animate(_pulseController);

    // Pulsating glow animation - uses slow duration for gentle effect
    _glowController = AnimationController(
      duration: MotionDurations.slow * 2,
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: MotionCurves.standard),
    );

    if (widget.isCurrentTurn) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PawnWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger pulse on position change
    if (oldWidget.player.position != widget.player.position) {
      _pulseController.forward(from: 0);
    }

    // Handle glow
    if (widget.isCurrentTurn && !oldWidget.isCurrentTurn) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isCurrentTurn && oldWidget.isCurrentTurn) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _pulseAnimation.value, child: child);
      },
      child: _buildPawnToken(),
    );
  }

  Widget _buildPawnToken() {
    final size = widget.size;
    final palette = PawnPalette.from(widget.player.color);

    // Token + glyph never change with the glow, so they are hoisted into the
    // AnimatedBuilder's `child` and rebuilt only when the player does.
    final token = Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _PawnTokenPainter(palette: palette)),
        ),
        Positioned(
          left: size * (0.5 - _kGlyphSize / 2),
          top: size * (_kBodyCenterY - _kGlyphSize / 2),
          child: Icon(
            GameConstants.iconPalette[widget.player.iconIndex %
                GameConstants.iconPalette.length],
            size: size * _kGlyphSize,
            color: Colors.white,
            shadows: [
              Shadow(
                color: palette.deep.withValues(alpha: 0.55),
                offset: Offset(0, size * 0.03),
                blurRadius: size * 0.05,
              ),
            ],
          ),
        ),
      ],
    );

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowIntensity = widget.isCurrentTurn ? _glowAnimation.value : 0.0;

        // The layout box must always be exactly size x size: PawnManager
        // positions this widget by that assumption. The glow is larger than
        // the pawn, so it renders through an OverflowBox (painted outside
        // the bounds via clipBehavior none) instead of inflating the Stack.
        return SizedBox(
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
                        intensity: glowIntensity,
                      ),
                    ),
                  ),
                ),
              ?child,
            ],
          ),
        );
      },
      child: token,
    );
  }
}

/// Material shades derived from a single player colour. Keeping the derivation
/// in one place guarantees the rim, dome, bounce light and glow all read as
/// the *same* material, and keeps player identity unmistakable.
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

  /// The player's own colour — the dome's mid-tone.
  final Color base;

  /// Brightest enamel tint, where the key light hits.
  final Color sheen;

  /// Light tint used for the bounce light on the lower edge.
  final Color light;

  /// Shaded enamel at the far side of the dome.
  final Color deep;

  /// Darkest tone — the turned metal rim in shadow.
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
      sheen: shift(0.26, -0.08),
      light: shift(0.14, -0.04),
      deep: shift(-0.20, 0.02),
      rim: shift(-0.34, 0.04),
      rimLight: shift(-0.06, -0.02),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PawnPalette && other.base == base;

  @override
  int get hashCode => base.hashCode;
}

/// Paints the token: contact shadow, metal rim, enamel dome, inner shading,
/// bounce light and specular highlight. Everything is drawn strictly inside
/// the size×size canvas so the pawn never overflows its layout slot.
class _PawnTokenPainter extends CustomPainter {
  const _PawnTokenPainter({required this.palette});

  final PawnPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    if (s <= 0) return;

    final center = Offset(size.width / 2, size.height * _kBodyCenterY);
    final r = s * _kTokenRadius;
    final domeR = r * _kDomeRatio;

    _paintContactShadow(canvas, size, s);
    _paintRim(canvas, center, r, s);
    _paintDome(canvas, center, domeR);
    _paintInnerShading(canvas, center, domeR, s);
    _paintSpecular(canvas, center, domeR);
  }

  /// A soft flattened ellipse under the token: the contact point that makes
  /// the piece read as sitting *on* the board rather than floating over it.
  void _paintContactShadow(Canvas canvas, Size size, double s) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.86),
        width: s * 0.66,
        height: s * 0.10,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.025),
    );
  }

  /// The turned metal edge of the token: a dark base ring with a lit sweep on
  /// the upper-left and a cooler bounce on the lower-right.
  void _paintRim(Canvas canvas, Offset center, double r, double s) {
    final rimRect = Rect.fromCircle(center: center, radius: r);

    // Drop shadow that separates the token from the tile beneath it.
    canvas.drawCircle(
      center.translate(0, s * 0.03),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.30)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.03),
    );

    // Rim body: a sweep so the metal turns from lit to shadowed around the
    // circumference instead of sitting at one flat tone.
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: math.pi * 2,
          transform: const GradientRotation(-math.pi * 0.75),
          colors: [
            palette.rimLight,
            palette.rim,
            palette.rim,
            palette.rimLight,
            palette.rimLight,
          ],
          stops: const [0.0, 0.30, 0.52, 0.78, 1.0],
        ).createShader(rimRect),
    );

    // Crisp outer keyline: keeps the silhouette clean over busy tile art.
    canvas.drawCircle(
      center,
      r - math.max(0.25, s * 0.006),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.5, s * 0.012),
    );
  }

  /// The lacquered enamel dome carrying the player colour.
  void _paintDome(Canvas canvas, Offset center, double domeR) {
    final domeRect = Rect.fromCircle(center: center, radius: domeR);
    canvas.drawCircle(
      center,
      domeR,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.38, -0.48),
          radius: 1.15,
          colors: [palette.sheen, palette.base, palette.deep],
          stops: const [0.0, 0.52, 1.0],
        ).createShader(domeRect),
    );
  }

  /// Inner shadow along the top edge plus a bounce light along the bottom —
  /// the pair that sells a glossy, thickly-lacquered surface.
  void _paintInnerShading(
    Canvas canvas,
    Offset center,
    double domeR,
    double s,
  ) {
    final inset = domeR * 0.06;
    final arcRect = Rect.fromCircle(center: center, radius: domeR - inset);

    // Shadow cast by the rim onto the enamel at the top of the dome.
    canvas.drawArc(
      arcRect,
      math.pi * 0.95,
      math.pi * 1.1,
      false,
      Paint()
        ..color = palette.rim.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.6, domeR * 0.16)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(0.4, s * 0.02)),
    );

    // Bounce light: reflected board light along the lower-right edge.
    canvas.drawArc(
      arcRect,
      math.pi * 0.08,
      math.pi * 0.72,
      false,
      Paint()
        ..color = palette.light.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.5, domeR * 0.11)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(0.4, s * 0.018)),
    );
  }

  /// Specular highlight: a soft gloss ellipse on the upper-left of the dome.
  void _paintSpecular(Canvas canvas, Offset center, double domeR) {
    final highlight = Rect.fromCenter(
      center: center.translate(-domeR * 0.30, -domeR * 0.46),
      width: domeR * 0.78,
      height: domeR * 0.46,
    );
    canvas.drawOval(
      highlight,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.72),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(highlight),
    );
  }

  @override
  bool shouldRepaint(covariant _PawnTokenPainter oldDelegate) =>
      oldDelegate.palette != palette;
}

/// Active-turn halo: a soft coloured bloom plus a thin ring, both breathing
/// with [intensity]. Painted behind the token, inside its own oversized box.
class _PawnGlowPainter extends CustomPainter {
  const _PawnGlowPainter({required this.palette, required this.intensity});

  final PawnPalette palette;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;
    if (maxR <= 0) return;

    final bloomR = maxR * (0.82 + 0.14 * intensity);
    canvas.drawCircle(
      center,
      bloomR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            palette.base.withValues(alpha: 0.42 + 0.26 * intensity),
            palette.base.withValues(alpha: 0.16 + 0.12 * intensity),
            palette.base.withValues(alpha: 0.0),
          ],
          stops: const [0.30, 0.62, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: bloomR)),
    );

    // Thin containment ring — reads as a spotlight on the active piece and
    // keeps the halo from looking like a generic blur.
    canvas.drawCircle(
      center,
      maxR * 0.70,
      Paint()
        ..color = palette.sheen.withValues(alpha: 0.30 + 0.35 * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.6, maxR * 0.035),
    );
  }

  @override
  bool shouldRepaint(covariant _PawnGlowPainter oldDelegate) =>
      oldDelegate.intensity != intensity || oldDelegate.palette != palette;
}
