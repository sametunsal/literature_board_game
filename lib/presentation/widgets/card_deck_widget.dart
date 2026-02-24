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

    return Transform.rotate(
      angle: rotation,
      child: SizedBox(
        width: size,
        height: size * 1.1,
        // No decoration/shadows for clean sharp look
        child: Image.asset(
          isSans
              ? 'assets/images/decks/sans_deck.png'
              : 'assets/images/decks/kader_deck.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to simpler placeholder if asset missing
            return Container(
              decoration: BoxDecoration(
                color: isSans
                    ? Colors.blue.withValues(alpha: 0.3)
                    : Colors.purple.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              ),
              child: Center(
                child: Icon(
                  isSans ? Icons.auto_awesome : Icons.menu_book,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
