import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../core/constants/game_constants.dart';
import '../../core/motion/motion_constants.dart';

/// Animated pawn widget with polished 2D appearance
/// Features smooth slide animation with subtle scale pulse
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
      animation: Listenable.merge([_pulseController, _glowController]),
      builder: (context, child) {
        final scale = _pulseAnimation.value;

        return Transform.scale(scale: scale, child: child);
      },
      child: _buildPawnToken(),
    );
  }

  Widget _buildPawnToken() {
    final size = widget.size;
    final isCurrentTurn = widget.isCurrentTurn;
    final color = widget.player.color;

    // Derived shades for the token body: light catches the top-left,
    // the rim reads as the piece's turned edge.
    final hsl = HSLColor.fromColor(color);
    final lightShade = hsl
        .withLightness((hsl.lightness + 0.18).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation - 0.05).clamp(0.0, 1.0))
        .toColor();
    final darkShade = hsl
        .withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0))
        .toColor();
    final rimShade = hsl
        .withLightness((hsl.lightness - 0.32).clamp(0.0, 1.0))
        .toColor();

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowIntensity = isCurrentTurn ? _glowAnimation.value : 0.0;

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
              // Active turn glow (behind the token)
              if (isCurrentTurn)
                OverflowBox(
                  maxWidth: size * _glowExtent,
                  maxHeight: size * _glowExtent,
                  child: Container(
                    width: size * _glowExtent,
                    height: size * _glowExtent,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(
                            alpha: 0.4 + (glowIntensity * 0.4),
                          ),
                          blurRadius: 10 + (glowIntensity * 10),
                          spreadRadius: 2 + (glowIntensity * 4),
                        ),
                      ],
                    ),
                  ),
                ),

              // Ground shadow: a flattened ellipse under the token gives it
              // the "sitting on the board" contact point of a real piece.
              Positioned(
                bottom: 0,
                child: Container(
                  width: size * 0.72,
                  height: size * 0.18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(size * 0.36, size * 0.09),
                    ),
                    color: Colors.black.withValues(alpha: 0.30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: size * 0.08,
                      ),
                    ],
                  ),
                ),
              ),

              // Token body: radial gradient lit from the top-left with a
              // darker rim border, like a lacquered game piece.
              Positioned(
                top: size * 0.02,
                child: Container(
                  width: size * 0.90,
                  height: size * 0.90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.35, -0.45),
                      radius: 1.15,
                      colors: [lightShade, color, darkShade],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                    border: Border.all(
                      color: rimShade,
                      width: (size * 0.05).clamp(0.8, 2.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: size * 0.10,
                        offset: Offset(0, size * 0.06),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Inner highlight ring: subtle bevel inside the rim.
                      Container(
                        margin: EdgeInsets.all(size * 0.045),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.30),
                            width: (size * 0.03).clamp(0.5, 1.2),
                          ),
                        ),
                      ),

                      // Player icon, embossed with a soft drop shadow.
                      Icon(
                        GameConstants.iconPalette[widget.player.iconIndex %
                            GameConstants.iconPalette.length],
                        size: size * 0.50,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.40),
                            offset: Offset(0, size * 0.035),
                            blurRadius: size * 0.06,
                          ),
                        ],
                      ),

                      // Top sheen: small specular highlight on the upper-left.
                      Positioned(
                        top: size * 0.09,
                        left: size * 0.18,
                        child: Container(
                          width: size * 0.26,
                          height: size * 0.14,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.elliptical(size * 0.13, size * 0.07),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.55),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

