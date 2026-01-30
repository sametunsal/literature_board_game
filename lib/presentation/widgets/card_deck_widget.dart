import 'package:flutter/material.dart';
import '../../models/game_enums.dart';

/// Visual representation of a card deck (Şans or Kader)
/// Displays a stack of cards with themed back design
class CardDeckWidget extends StatelessWidget {
  final CardType type;
  final double size;
  final double rotation; // Radians

  const CardDeckWidget({
    super.key,
    required this.type,
    this.size = 80,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isSans = type == CardType.sans;

    // Theme colors
    // primaryColor is now determined inside the loop for depth effect

    final accentColor = isSans
        ? const Color(0xFF64B5F6) // Light blue
        : const Color(0xFFBA68C8); // Light purple

    final iconData = isSans ? Icons.auto_awesome : Icons.menu_book;
    final label = isSans ? 'ŞANS' : 'KADER';

    return Transform.rotate(
      angle: rotation,
      child: SizedBox(
        width: size,
        height: size * 1.4, // Card aspect ratio
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none, // Allow stack to overflow container
          children: [
            // Bottom cards (stack effect) - Enhanced for depth
            for (int i = 4; i >= 0; i--)
              Positioned(
                left: i * 4.0, // Significant offset for 3D look
                top: i * 4.0,
                child: _buildCardBack(
                  size: size,
                  // Darker sides, lighter top
                  primaryColor: isSans
                      ? (i == 0
                            ? const Color(0xFF1976D2)
                            : const Color(0xFF0D47A1))
                      : (i == 0
                            ? const Color(0xFF7B1FA2)
                            : const Color(0xFF4A148C)),
                  accentColor: accentColor,
                  iconData: iconData,
                  label: label,
                  isTop: i == 0,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack({
    required double size,
    required Color primaryColor,
    required Color accentColor,
    required IconData iconData,
    required String label,
    required bool isTop,
  }) {
    return Container(
      width: size,
      height: size * 1.4,
      decoration: BoxDecoration(
        // Gradient background
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, Color.lerp(primaryColor, Colors.black, 0.3)!],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 2),
        boxShadow: isTop
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(2, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(3, 5),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(2, 3),
                ),
              ],
      ),
      child: isTop
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decorative border pattern
                Container(
                  width: size * 0.85,
                  height: size * 1.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Theme icon
                      Icon(iconData, size: size * 0.35, color: accentColor),
                      const SizedBox(height: 6),
                      // Label
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: size * 0.12,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : null,
    );
  }
}
