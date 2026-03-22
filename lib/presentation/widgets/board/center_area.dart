import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/game_theme.dart';
import '../../../models/game_enums.dart';
import '../../../providers/game_notifier.dart';
import '../../../core/utils/board_layout_config.dart';
import 'center_dice_roll_overlay.dart';
import 'monopoly_style_deck_cards.dart';
import '../dice_roller.dart';

/// Center area widget containing card decks and HUD
class CenterArea extends StatelessWidget {
  final GameState state;
  final BoardLayoutConfig layout;

  const CenterArea({super.key, required this.state, required this.layout});

  @override
  Widget build(BuildContext context) {
    final kL = layout.kLongSide;
    final centerWidth = layout.actualWidth - 2 * kL;
    final centerHeight = layout.actualHeight - 2 * kL;

    final deckSize = math.min(centerWidth, centerHeight) * 0.21;
    final minCenterSide = math.min(centerWidth, centerHeight);
    final showDiceRollOverlay = state.isDiceRolling;

    return Positioned(
      top: kL,
      left: kL,
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
        clipBehavior: Clip.hardEdge,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // ŞANS — üst sol
            Positioned(
              top: 10 + minCenterSide * 0.025,
              left: 10 + centerWidth * 0.045,
              child: _buildElevatedCard(CardType.sans, deckSize),
            ),
            // KADER — alt sağ
            Positioned(
              bottom: 10 + minCenterSide * 0.025,
              right: 10 + centerWidth * 0.045,
              child: _buildElevatedCard(CardType.kader, deckSize),
            ),
            // HUD — FittedBox ile sığdır; layout taşmasını önle
            if (!showDiceRollOverlay)
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: centerWidth * 0.18,
                    vertical: centerHeight * 0.08,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _buildHUD(state),
                  ),
                ),
              ),
            // Zar animasyonu
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
    final kWidth = size;
    final kHeight = size * 1.4;
    final baseW = kWidth;
    final baseH = kHeight;

    return MonopolyStyleDeckCard(
      type: type,
      width: baseW,
      height: baseH,
    );
  }

  Widget _buildHUD(GameState state) {
    return Column(
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
    );
  }
}
