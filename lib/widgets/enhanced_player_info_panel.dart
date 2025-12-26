import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';

/// Enhanced player info panel with animated star/point increments
/// Shows current player with smooth animations when values change
class EnhancedPlayerInfoPanel extends ConsumerWidget {
  const EnhancedPlayerInfoPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    // Find current player
    if (gameState.players.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentPlayer = gameState.players[gameState.currentPlayerIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player name with color indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(int.parse(currentPlayer.color.substring(1))),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                currentPlayer.name,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade900,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stars display with animated increment
          _AnimatedStarsDisplay(stars: currentPlayer.stars),

          const SizedBox(height: 20),

          // Position display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: Colors.brown.shade700, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Kutucuk: ${currentPlayer.position}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.brown.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated stars display with smooth increment animation
/// Uses AnimatedBuilder to animate star count changes
class _AnimatedStarsDisplay extends StatelessWidget {
  final int stars;

  const _AnimatedStarsDisplay({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated star icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.2),
            duration: const Duration(milliseconds: 300),
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: const Icon(Icons.star, color: Colors.amber, size: 28),
          ),
          const SizedBox(width: 8),
          // Animated star count
          _AnimatedNumber(
            value: stars,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated number display with count-up effect
/// Provides smooth animation when value changes
class _AnimatedNumber extends StatelessWidget {
  final int value;
  final TextStyle style;

  const _AnimatedNumber({required this.value, required this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: value, end: value),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Text(
          '$value',
          key: ValueKey(value),
          style: style,
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
