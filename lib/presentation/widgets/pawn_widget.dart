import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../core/constants/game_constants.dart';
import '../../core/motion/motion_constants.dart';
import 'isometric_icon.dart';

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

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowIntensity = isCurrentTurn ? _glowAnimation.value : 0.0;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Active turn glow (behind icon)
            if (isCurrentTurn)
              Container(
                width: size * 1.5,
                height: size * 1.5,
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

            Center(
              child: IsometricIcon(
                icon:
                    GameConstants.iconPalette[widget.player.iconIndex %
                        GameConstants.iconPalette.length],
                color: color,
                size: size,
                depth: 5.0, // Fixed depth
              ),
            ),
          ],
        );
      },
    );
  }
}

