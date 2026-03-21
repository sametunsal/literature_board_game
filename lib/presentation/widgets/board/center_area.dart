import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/game_theme.dart';
import '../../../models/game_enums.dart';
import '../../../providers/game_notifier.dart';
import '../../../core/utils/board_layout_config.dart';
import 'center_dice_roll_overlay.dart';
import '../isometric_game_card.dart';
import '../dice_roller.dart';

/// Center area widget containing card decks and HUD
///
/// **HYBRID LAYOUT:**
/// Uses kLongSide for edge offsets as corners are kLong × kLong
class CenterArea extends StatelessWidget {
  final GameState state;
  final BoardLayoutConfig layout;

  const CenterArea({super.key, required this.state, required this.layout});

  @override
  Widget build(BuildContext context) {
    final kL = layout.kLongSide;

    // Center area: inside the perimeter tiles
    // Width: between left corner and right corner
    final centerWidth = layout.actualWidth - 2 * kL;
    // Height: between top corner and bottom corner
    final centerHeight = layout.actualHeight - 2 * kL;

    // Deste boyutu — Şans biraz büyük; HUD / zar ile çakışmayı sınırla
    final deckSize =
        math.min(centerWidth, centerHeight) * 0.175;
    final minCenterSide = math.min(centerWidth, centerHeight);
    // Sıra belirleme (rollingForOrder / tie-break) dahil: state.dice1/dice2 tek kaynak
    final showDiceRollOverlay = state.isDiceRolling;

    return Positioned(
      top: kL, // Below top corners
      left: kL, // Right of left corners
      width: centerWidth,
      height: centerHeight,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.98),
              Colors.grey.shade50.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ŞANS CARD DECK (Top-Left)
            // ŞANS CARD DECK (Top-Left)
            Positioned(
              top: 6,
              left: 0.055 * centerWidth,
              child: _buildElevatedCard(CardType.sans, deckSize),
            ),

            // KADER (alt sağ) — zar HUD ile çakışmayacak boşluk
            Positioned(
              bottom: 6,
              right: 0.018 * centerWidth,
              child: _buildElevatedCard(CardType.kader, deckSize),
            ),

            // HUD content (center)
            Center(child: _buildHUD(state)),

            // Zar animasyonu en üstte — HUD’daki küçük durum kartının üzerinde görünsün
            if (showDiceRollOverlay)
              Positioned.fill(
                child: CenterDiceRollOverlay(
                  state: state,
                  minSide: minCenterSide,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildElevatedCard(CardType type, double size) {
    // Note: size here essentially sets the bounding box, IsometricGameCard manages internal proportions
    // We adjust scale slightly if needed, but IsometricGameCard has default width/height logic.
    // If we want it to react to 'size', we should pass size as width/height reference.

    final kWidth = size;
    final kHeight = size * 1.35;

    // Şans destesini biraz büyüt; Kader biraz daha geniş (sadece genişlik ×1.06)
    final scaleMultiplier = type == CardType.sans ? 1.02 : 0.90;
    final baseW = kWidth * scaleMultiplier;
    final baseH = kHeight * scaleMultiplier;
    final w = type == CardType.kader ? baseW * 1.06 : baseW;

    return IsometricGameCard(
      type: type,
      width: w,
      height: baseH,
    );
  }

  Widget _buildHUD(GameState state) {
    return Transform.scale(
      scale: 0.60, // Reduced by ~25% from 0.81 to make it less obtrusive
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.amber.shade100.withValues(alpha: 0.25),
                  Colors.amber.shade50.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.25),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'EDEBİNA',
              style: GameTheme.hudTitleStyle.copyWith(
                color: GameTheme.goldAccent,
                fontSize: 18,
                shadows: [
                  Shadow(
                    color: Colors.amber.withValues(alpha: 0.4),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const DiceRoller(),
          ),
        ],
      ),
    );
  }
}
