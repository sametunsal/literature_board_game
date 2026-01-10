import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/player.dart';

/// Animated pawn widget that looks like a premium game token
/// Features smooth movement, hop animation, and 3D appearance
class PawnWidget extends StatefulWidget {
  final Player player;
  final double size;
  final bool isActive;

  const PawnWidget({
    super.key,
    required this.player,
    required this.size,
    this.isActive = false,
  });

  @override
  State<PawnWidget> createState() => _PawnWidgetState();
}

class _PawnWidgetState extends State<PawnWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _hopController;
  late Animation<double> _hopAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hopController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Hop up animation
    _hopAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(
        parent: _hopController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Scale animation for bounce effect
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_hopController);
  }

  @override
  void didUpdateWidget(PawnWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger hop animation when position changes
    if (oldWidget.player.position != widget.player.position) {
      _hopController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _hopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hopController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _hopAnimation.value),
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: _buildPawnToken(),
    );
  }

  Widget _buildPawnToken() {
    final size = widget.size;
    final isActive = widget.isActive;
    final color = widget.player.color;

    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            // Base gradient for 3D effect
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(color, Colors.white, 0.3)!,
                color,
                Color.lerp(color, Colors.black, 0.2)!,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
            shape: BoxShape.circle,
            // White border ring
            border: Border.all(color: Colors.white, width: 2.5),
            // Multiple shadows for depth
            boxShadow: [
              // Main drop shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
              // Active glow effect
              if (isActive)
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              // Subtle ambient shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                spreadRadius: -1,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Inner highlight (top-left shine)
              Positioned(
                top: size * 0.1,
                left: size * 0.15,
                child: Container(
                  width: size * 0.25,
                  height: size * 0.15,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
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
                size: size * 0.55,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ],
          ),
        )
        // Pulse animation for active player
        .animate(target: isActive ? 1 : 0)
        .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3));
  }
}

/// Positioned pawn container with smooth movement animation
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
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
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
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
