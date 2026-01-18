import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/player.dart';
import '../core/constants/game_constants.dart';
import '../core/motion/motion_constants.dart';
// import 'game_log.dart' show literatureIcons; // Removed unused import

/// Animated pawn widget with premium 3D appearance
/// Features improved hopping animation with parabolic arc and pulsating glow
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
  late AnimationController _hopController;
  late Animation<double> _verticalArc;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  // Pulsating glow controller
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Movement juice states
  bool _isMoving = false;
  bool _showImpactFlash = false;
  Timer? _impactFlashTimer;

  @override
  void initState() {
    super.initState();

    // Hop animation - uses MotionDurations.pawn for consistent timing
    _hopController = AnimationController(
      duration: MotionDurations.pawn.safe,
      vsync: this,
    );

    // Parabolic arc - smooth up and down with bounce at landing
    _verticalArc = TweenSequence<double>([
      // Quick rise
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: -18,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 35,
      ),
      // Peak hang time
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -18,
          end: -16,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      // Fall with gravity
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -16,
          end: 0,
        ).chain(CurveTween(curve: MotionCurves.decelerate)),
        weight: 35,
      ),
      // Small bounce
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: -4,
        ).chain(CurveTween(curve: MotionCurves.standard)),
        weight: 10,
      ),
      // Settle
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -4,
          end: 0,
        ).chain(CurveTween(curve: MotionCurves.decelerate)),
        weight: 10,
      ),
    ]).animate(_hopController);

    // Scale squash/stretch effect
    _scaleAnimation = TweenSequence<double>([
      // Stretch on rise
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.12),
        weight: 30,
      ),
      // Normal at peak
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.12, end: 1.05),
        weight: 20,
      ),
      // Squash on land
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 0.92),
        weight: 25,
      ),
      // Recover with spring
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.92,
          end: 1.0,
        ).chain(CurveTween(curve: MotionCurves.spring)),
        weight: 25,
      ),
    ]).animate(_hopController);

    // Slight rotation during jump
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 0.08), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 0.08, end: 0), weight: 50),
    ]).animate(_hopController);

    // Pulsating glow animation - uses slow duration for gentle effect
    _glowController = AnimationController(
      duration: MotionDurations.slow * 2, // 1000ms
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: MotionCurves.standard),
    );

    // Hop controller listener for movement juice
    _hopController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Landing impact flash
        setState(() {
          _isMoving = false;
          _showImpactFlash = true;
        });

        // Reset impact flash after brief display
        _impactFlashTimer?.cancel();
        _impactFlashTimer = Timer(MotionDurations.fast, () {
          if (mounted) {
            setState(() => _showImpactFlash = false);
          }
        });
      }
    });

    if (widget.isCurrentTurn) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PawnWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger hop on position change with movement juice
    if (oldWidget.player.position != widget.player.position) {
      setState(() {
        _isMoving = true;
        _showImpactFlash = false;
      });
      _hopController.forward(from: 0);
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
    _impactFlashTimer?.cancel();
    _hopController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_hopController, _glowController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _verticalArc.value),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scaleByDouble(
                _scaleAnimation.value,
                1.0 / _scaleAnimation.value * 1.0,
                1.0,
                1.0,
              )
              ..rotateZ(_rotationAnimation.value),
            child: child,
          ),
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
            // 3D gradient
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(color, Colors.white, 0.35)!,
                color,
                Color.lerp(color, Colors.black, 0.25)!,
              ],
              stops: const [0.0, 0.45, 1.0],
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
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(2, 5),
              ),
              // Movement glow - soft shadow under pawn while moving
              if (_isMoving)
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              // Impact flash glow on landing
              if (_showImpactFlash)
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 20,
                  spreadRadius: 6,
                ),
              if (_showImpactFlash)
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              // Pulsating glow - NO clamp, values are constant
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
                top: size * 0.08,
                left: size * 0.12,
                child: Container(
                  width: size * 0.28,
                  height: size * 0.16,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(size),
                  ),
                ),
              ),
              // Player icon - using custom avatar images
              ClipOval(
                child: Image.asset(
                  GameConstants.getAvatarPath(widget.player.iconIndex),
                  width: size * 0.6,
                  height: size * 0.6,
                  fit: BoxFit.contain,
                  color: widget.player.color,
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: size * 0.52,
                      color: Colors.white,
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
/// Uses flutter_animate for natural sliding and bouncing feel
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
      // Uses pawn + medium durations for full settle time
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

    // Apply flutter_animate effects when position changes
    if (_justMoved && _previousCenter != null) {
      // Calculate offset from previous to current position
      final dx = left - (_previousCenter!.dx - (widget.areaSize / 2));
      final dy = top - (_previousCenter!.dy - (widget.areaSize / 2));

      return pawnContainer
          .animate(key: ValueKey('${widget.center.dx}_${widget.center.dy}'))
          // Smooth slide from previous position
          .move(
            begin: Offset(-dx, -dy),
            end: Offset.zero,
            duration: MotionDurations.pawn.safe,
            curve: MotionCurves.standard,
          )
          // Bounce effect on landing
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.15, 1.15),
            duration: MotionDurations.fast.safe,
            delay: MotionDurations.pawn.safe,
            curve: MotionCurves.standard,
          )
          .then()
          .scale(
            begin: const Offset(1.15, 1.15),
            end: const Offset(1.0, 1.0),
            duration: MotionDurations.fast.safe,
            curve: MotionCurves.decelerate,
          );
    }

    // No animation on first render or when position hasn't changed
    return pawnContainer;
  }

  @override
  void dispose() {
    _moveResetTimer?.cancel();
    super.dispose();
  }
}
