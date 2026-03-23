import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'common/star_shape.dart';

/// Flying star animation widget for correct answers
/// Stars fly from center upward with celebratory effect
class FlyingStar extends StatelessWidget {
  final int starCount;
  final VoidCallback onComplete;
  final Offset? startOffset;
  final Offset? endOffset;

  const FlyingStar({
    super.key,
    required this.starCount,
    required this.onComplete,
    this.startOffset,
    this.endOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Central text showing star count
        Center(
          child: _buildStarCountText(),
        ),
        // Flying stars effect
        ...List.generate(
          math.min(starCount, 8),
          (index) => _buildFlyingStar(index),
        ),
      ],
    );
  }

  Widget _buildStarCountText() {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.shade600,
              Colors.orange.shade700,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.6),
              blurRadius: 20,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_rounded,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: 8),
            Text(
              '+$starCount',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
                shadows: [
                  Shadow(
                    blurRadius: 8,
                    color: Colors.black38,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate(onComplete: (_) => onComplete())
          .scale(
            begin: const Offset(0.3, 0.3),
            end: const Offset(1.2, 1.2),
            duration: 300.ms,
            curve: Curves.elasticOut,
          )
          .then()
          .scale(
            begin: const Offset(1.2, 1.2),
            end: const Offset(1.0, 1.0),
            duration: 200.ms,
            curve: Curves.easeOut,
          )
          .then()
          .shimmer(
            duration: 600.ms,
            color: Colors.white.withValues(alpha: 0.4),
          )
          .then(delay: 400.ms)
          .moveY(
            begin: 0,
            end: -100,
            duration: 800.ms,
            curve: Curves.easeIn,
          )
          .fadeOut(duration: 500.ms),
    );
  }

  Widget _buildFlyingStar(int index) {
    final random = math.Random(index * 42);
    final angle = (index / 8) * 2 * math.pi - (math.pi / 2);
    final distance = 120.0 + random.nextDouble() * 80;
    final size = 16.0 + random.nextDouble() * 12;
    final delay = index * 50;

    final endX = math.cos(angle) * distance;
    final endY = math.sin(angle) * distance - 60;

    return Center(
      child: StarShape(
        size: size,
        color: Color.lerp(
          Colors.amber.shade400,
          Colors.orange.shade600,
          random.nextDouble(),
        ),
        rotation: random.nextDouble() * math.pi,
      )
          .animate(delay: delay.ms)
          .scale(
            begin: const Offset(0, 0),
            end: const Offset(1.5, 1.5),
            duration: 250.ms,
            curve: Curves.easeOutBack,
          )
          .then()
          .move(
            begin: Offset.zero,
            end: Offset(endX, endY),
            duration: 700.ms,
            curve: Curves.easeOutCubic,
          )
          .scale(
            begin: const Offset(1.5, 1.5),
            end: const Offset(0.3, 0.3),
            duration: 700.ms,
          )
          .rotate(
            begin: 0,
            end: random.nextDouble() * 2 - 1,
            duration: 700.ms,
          )
          .fadeOut(delay: 400.ms, duration: 300.ms),
    );
  }
}

/// Flying star that travels from one point to another (panel effect)
class FlyingStarToPanel extends StatelessWidget {
  final int starCount;
  final Offset from;
  final Offset to;
  final VoidCallback onComplete;

  const FlyingStarToPanel({
    super.key,
    required this.starCount,
    required this.from,
    required this.to,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;

    return Stack(
      children: List.generate(
        math.min(starCount, 5),
        (index) => _buildTravelingStar(index, dx, dy),
      ),
    );
  }

  Widget _buildTravelingStar(int index, double dx, double dy) {
    final random = math.Random(index * 31);
    final delay = index * 80;
    final size = 20.0 + random.nextDouble() * 8;
    final offsetX = (random.nextDouble() - 0.5) * 30;
    final offsetY = (random.nextDouble() - 0.5) * 30;

    return Positioned(
      left: from.dx - size / 2 + offsetX,
      top: from.dy - size / 2 + offsetY,
      child: StarShape(
        size: size,
        color: Colors.amber.shade500,
      )
          .animate(
            delay: delay.ms,
            onComplete: index == 0 ? (_) => onComplete() : null,
          )
          .scale(
            begin: const Offset(0.2, 0.2),
            end: const Offset(1.2, 1.2),
            duration: 150.ms,
            curve: Curves.easeOut,
          )
          .then()
          .move(
            begin: Offset.zero,
            end: Offset(dx - offsetX, dy - offsetY),
            duration: 500.ms,
            curve: Curves.easeInOutCubic,
          )
          .scale(
            begin: const Offset(1.2, 1.2),
            end: const Offset(0.4, 0.4),
            duration: 500.ms,
          )
          .rotate(
            begin: 0,
            end: 1.5,
            duration: 500.ms,
          )
          .fadeOut(delay: 350.ms, duration: 150.ms),
    );
  }
}
