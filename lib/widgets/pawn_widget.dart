import 'package:flutter/material.dart';
import '../models/player.dart';

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

  @override
  void initState() {
    super.initState();

    // Hop animation - quick 400ms for snappy feel
    _hopController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
        ).chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 35,
      ),
      // Small bounce
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: -4,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      // Settle
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -4,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeIn)),
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
      // Recover
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.92,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 25,
      ),
    ]).animate(_hopController);

    // Slight rotation during jump
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 0.08), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 0.08, end: 0), weight: 50),
    ]).animate(_hopController);

    // Pulsating glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.isCurrentTurn) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PawnWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger hop on position change
    if (oldWidget.player.position != widget.player.position) {
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
              ..scale(_scaleAnimation.value, 1.0 / _scaleAnimation.value * 1.0)
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
              // Pulsating glow
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
              // Player icon
              Icon(
                IconData(
                  0xe000 + widget.player.iconIndex,
                  fontFamily: 'MaterialIcons',
                ),
                size: size * 0.52,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 3,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Container that smoothly moves pawn groups across the board
/// Uses a bounce curve for natural hopping feel
class AnimatedPawnContainer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack, // Slight overshoot for energy
      left: center.dx - (areaSize / 2),
      top: center.dy - (areaSize / 2),
      child: SizedBox(
        width: areaSize,
        height: areaSize,
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: players
                .map(
                  (p) => PawnWidget(
                    key: ValueKey(p.id),
                    player: p,
                    size: pawnSize,
                    isActive: p.id == currentPlayerId,
                    isCurrentTurn: p.id == currentPlayerId,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
