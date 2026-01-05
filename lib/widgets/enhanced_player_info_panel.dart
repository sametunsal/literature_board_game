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
    final isBankrupt = currentPlayer.isBankrupt;

    // Safe color parsing with replaceFirst
    Color parsePlayerColor(String hexColor) {
      try {
        final colorString = hexColor.replaceFirst('#', '0xFF');
        return Color(int.parse(colorString));
      } catch (e) {
        debugPrint('Error parsing color: $hexColor');
        return Colors.blue; // Fallback color
      }
    }

    // Main panel content
    final panelContent = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Gray background for bankrupt players, white for active players
        color: isBankrupt ? Colors.grey.shade300 : Colors.white,
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
                  color: parsePlayerColor(currentPlayer.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                currentPlayer.name,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isBankrupt
                      ? Colors.grey.shade600 // Faded color for bankrupt
                      : Colors.brown.shade900,
                  decoration: isBankrupt
                      ? TextDecoration.lineThrough // Strikethrough for bankrupt
                      : null,
                  decorationColor: Colors.red.shade700,
                  decorationThickness: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stars display with animated increment
          _AnimatedStarsDisplay(
            stars: currentPlayer.stars,
            isBankrupt: isBankrupt,
          ),

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

    // Wrap in Stack with bankruptcy stamp if player is bankrupt
    if (isBankrupt) {
      return Opacity(
        opacity: 0.6, // Fade out bankrupt players
        child: Stack(
          children: [
            panelContent,
            // Center "İFLAS" stamp with rotation
            Center(
              child: Transform.rotate(
                angle: -0.15, // Slight diagonal rotation
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red.shade900,
                      width: 5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.red.shade700.withValues(alpha: 0.85),
                  ),
                  child: Text(
                    'İFLAS',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Return normal panel for active players
    return panelContent;
  }
}

/// Animated stars display with smooth increment animation
/// Uses AnimatedBuilder to animate star count changes
class _AnimatedStarsDisplay extends StatelessWidget {
  final int stars;
  final bool isBankrupt;

  const _AnimatedStarsDisplay({
    required this.stars,
    this.isBankrupt = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Gray tones for bankrupt players, amber for active players
        color: isBankrupt ? Colors.grey.shade200 : Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBankrupt ? Colors.grey.shade600 : Colors.amber,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isBankrupt
                ? Colors.black.withValues(alpha: 0.1)
                : Colors.amber.withValues(alpha: 0.3),
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
            child: Icon(
              Icons.star,
              // Gray for bankrupt, amber for active
              color: isBankrupt ? Colors.grey.shade700 : Colors.amber,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
          // Animated star count
          _AnimatedNumber(
            value: stars,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              // Black/gray tones for bankrupt, brown for active
              color: isBankrupt ? Colors.black87 : Colors.brown.shade900,
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
