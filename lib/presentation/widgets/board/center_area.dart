import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/game_theme.dart';
import '../../../models/game_enums.dart';
import '../../../providers/game_notifier.dart';
import '../../../core/utils/board_layout_config.dart';
import '../card_deck_widget.dart';
import '../dice_roller.dart';

/// Center area widget containing card decks and HUD
class CenterArea extends StatelessWidget {
  final GameState state;
  final BoardLayoutConfig layout;

  const CenterArea({super.key, required this.state, required this.layout});

  @override
  Widget build(BuildContext context) {
    final T = layout.tileSize;
    // Center area: inside the perimeter tiles
    // Width: 4 inner columns, Height: 5 inner rows
    final centerWidth = T * 4; // 6 - 2 edge tiles
    final centerHeight = T * 5; // 7 - 2 edge tiles
    final deckSize = math.min(centerWidth, centerHeight) * 0.20;

    return Positioned(
      top: T, // Below top edge
      left: T, // Right of left edge
      width: centerWidth,
      height: centerHeight,
      child: Container(
        decoration: BoxDecoration(
          // Pure white for modern, clean look
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ═══════════════════════════════════════════════════════════════
            // ŞANS CARD DECK (Top-Left, rotated)
            // ═══════════════════════════════════════════════════════════════
            Positioned(
              top: centerHeight * 0.08,
              left: centerWidth * 0.08,
              child: CardDeckWidget(
                type: CardType.sans,
                size: deckSize,
                rotation: 0.35,
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // KADER CARD DECK (Bottom-Right, rotated)
            // ═══════════════════════════════════════════════════════════════
            Positioned(
              bottom: centerHeight * 0.08,
              right: centerWidth * 0.08,
              child: CardDeckWidget(
                type: CardType.kader,
                size: deckSize,
                rotation: 0.35,
              ),
            ),

            // HUD content (center)
            Center(child: _buildHUD(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildHUD(GameState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Game title with modern amber accent
        Text(
          'EDEBİNA',
          style: GameTheme.hudTitleStyle.copyWith(color: GameTheme.goldAccent),
        ),
        const SizedBox(height: 12),
        const DiceRoller(),
      ],
    );
  }
}
