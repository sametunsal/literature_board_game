import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Pulsating glow controller
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Movement state
  bool _isMoving = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation - subtle scale up when moving
    _pulseController = AnimationController(
      duration: MotionDurations.pawn.safe,
      vsync: this,
    );

    // Simple scale pulse: 1.0 → 1.1 → 1.0
    _pulseAnimation = TweenSequence<double>([
      // Scale up quickly (pickup)
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      // Hold at peak while sliding
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
      // Scale back down (place)
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_pulseController);

    // Pulse controller listener for movement state
    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() => _isMoving = false);
        }
      }
    });

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
      if (mounted) {
        setState(() => _isMoving = true);
      }
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

        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: _buildPawnToken(),
    );
  }

  Widget _buildPawnToken() {
    final size = widget.size;
    final isCurrentTurn = widget.isCurrentTurn;
    final isActive = widget.isActive;
    final color = widget.player.color;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowIntensity = isCurrentTurn ? _glowAnimation.value : 0.0;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            // 2D gradient for polished appearance
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.3),
              radius: 0.8,
              colors: [
                Color.lerp(color, Colors.white, 0.35)!,
                color,
                Color.lerp(color, Colors.black, 0.15)!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentTurn
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.85),
              width: isCurrentTurn ? 3.0 : 2.5,
            ),
            boxShadow: [
              // Drop shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(2, 3),
              ),
              // Movement glow - enhanced while moving
              if (_isMoving)
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              // Pulsating glow for current turn
              if (isCurrentTurn)
                BoxShadow(
                  color: color.withValues(alpha: 0.25 + (glowIntensity * 0.5)),
                  blurRadius: 14 + (glowIntensity * 10),
                  spreadRadius: 3 + (glowIntensity * 5),
                ),
              if (isCurrentTurn)
                BoxShadow(
                  color: Colors.white.withValues(alpha: glowIntensity * 0.35),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              if (isActive && !isCurrentTurn)
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Highlight shine
              Positioned(
                top: size * 0.1,
                left: size * 0.15,
                child: Container(
                  width: size * 0.25,
                  height: size * 0.15,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(size),
                  ),
                ),
              ),
              // Player icon - using custom avatar images
              ClipOval(
                child: Image.asset(
                  GameConstants.getAvatarPath(widget.player.iconIndex),
                  width: size * 0.55,
                  height: size * 0.55,
                  fit: BoxFit.contain,
                  color: widget.player.color,
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: size * 0.5,
                      color: Colors.white.withValues(alpha: 0.9),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Container that smoothly moves pawn groups across the board
/// Uses flutter_animate for natural sliding feel
class AnimatedPawnContainer extends StatefulWidget {
  final Offset center;
  final double areaSize;
  final List<Player> players;
  final String currentPlayerId;
  final double pawnSize;

  const AnimatedPawnContainer({
    super.key,
    required this.center,
    required this.areaSize,
    required this.players,
    required this.currentPlayerId,
    required this.pawnSize,
  });

  @override
  State<AnimatedPawnContainer> createState() => _AnimatedPawnContainerState();
}

class _AnimatedPawnContainerState extends State<AnimatedPawnContainer> {
  Offset? _previousCenter;
  bool _justMoved = false;
  Timer? _moveResetTimer;

  @override
  void didUpdateWidget(AnimatedPawnContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect position change
    if (oldWidget.center != widget.center) {
      _previousCenter = oldWidget.center;
      _justMoved = true;

      // Reset "just moved" flag after animation completes
      _moveResetTimer?.cancel();
      _moveResetTimer = Timer(
        MotionDurations.pawn + MotionDurations.medium,
        () {
          if (mounted) {
            setState(() {
              _justMoved = false;
            });
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.center.dx - (widget.areaSize / 2);
    final top = widget.center.dy - (widget.areaSize / 2);

    Widget pawnContainer = Positioned(
      left: left,
      top: top,
      child: SizedBox(
        width: widget.areaSize,
        height: widget.areaSize,
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: widget.players
                .map(
                  (p) => PawnWidget(
                    key: ValueKey(p.id),
                    player: p,
                    size: widget.pawnSize,
                    isActive: p.id == widget.currentPlayerId,
                    isCurrentTurn: p.id == widget.currentPlayerId,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );

    // Apply smooth slide animation when position changes
    if (_justMoved && _previousCenter != null) {
      final dx = left - (_previousCenter!.dx - (widget.areaSize / 2));
      final dy = top - (_previousCenter!.dy - (widget.areaSize / 2));

      return pawnContainer
          .animate(key: ValueKey('${widget.center.dx}_${widget.center.dy}'))
          .move(
            begin: Offset(-dx, -dy),
            end: Offset.zero,
            duration: MotionDurations.pawn.safe,
            curve: Curves.easeInOutCubic,
          );
    }

    return pawnContainer;
  }

  @override
  void dispose() {
    _moveResetTimer?.cancel();
    super.dispose();
  }
}
