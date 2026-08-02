import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/services/win_condition_service.dart';
import '../../../core/theme/game_theme.dart';
import '../../../models/game_enums.dart';
import '../../../providers/game_notifier.dart';
import '../../../core/utils/board_layout_config.dart';
import 'center_dice_roll_overlay.dart';
import 'board_visual_constants.dart';
import 'flapping_deck_card.dart';
import 'monopoly_style_deck_cards.dart';
import '../dice_roller.dart';

/// Center area widget containing card decks and HUD.
class CenterArea extends StatelessWidget {
  final GameState state;
  final BoardLayoutConfig layout;

  const CenterArea({super.key, required this.state, required this.layout});

  @override
  Widget build(BuildContext context) {
    final kL = layout.kLongSide;
    final centerWidth = layout.actualWidth - 2 * kL;
    final centerHeight = layout.actualHeight - 2 * kL;

    final deckSize =
        math.min(centerWidth, centerHeight) * 0.21 * kCenterDeckVisualScale;
    final minCenterSide = math.min(centerWidth, centerHeight);
    final watermarkFontSize = math.min(
      math.max(minCenterSide * 0.16, 36.0),
      72.0,
    );
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
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Text(
                    'EDEBİNA',
                    textAlign: TextAlign.center,
                    style: GameTheme.hudTitleStyle.copyWith(
                      color: GameTheme.ottomanGold.withValues(alpha: 0.10),
                      fontSize: watermarkFontSize,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.22),
                          blurRadius: 2,
                          offset: const Offset(0, -1),
                        ),
                        Shadow(
                          color: GameTheme.ottomanGoldShadow.withValues(
                            alpha: 0.10,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10 + minCenterSide * 0.025,
              left: 10 + centerWidth * 0.045,
              child: FlappingDeckCard(
                child: _buildElevatedCard(CardType.sans, deckSize),
              ),
            ),
            Positioned(
              bottom: 10 + minCenterSide * 0.025,
              right: 10 + centerWidth * 0.045,
              child: FlappingDeckCard(
                phase: 0.5,
                child: _buildElevatedCard(CardType.kader, deckSize),
              ),
            ),
            if (!showDiceRollOverlay)
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: centerWidth * 0.18,
                    vertical: centerHeight * 0.08,
                  ),
                  child: FittedBox(fit: BoxFit.scaleDown, child: _buildHUD()),
                ),
              ),
            if (showDiceRollOverlay)
              Positioned.fill(
                child: CenterDiceRollOverlay(
                  state: state,
                  minSide: minCenterSide,
                  visualScale: kCenterDiceVisualScale,
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

    return MonopolyStyleDeckCard(type: type, width: baseW, height: baseH);
  }

  Widget _buildHUD() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCiltObjective(),
        const SizedBox(height: 10),
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
          child: const DiceRoller(visualScale: kCenterControlsVisualScale),
        ),
      ],
    );
  }

  /// Persistent victory-path objective for the current player: how many Cilt
  /// (Volume) books they hold out of the 3 needed to win. Always visible,
  /// updates live as ownership changes.
  Widget _buildCiltObjective() {
    const service = WinConditionService();
    final player = state.currentPlayer;
    final count = service.ciltBookCount(
      playerId: player.id,
      ownerships: state.bookOwnerships,
    );
    final target = GameConstants.publishingCiltBooksToWin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: GameTheme.ottomanGold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GameTheme.ottomanGold.withValues(alpha: 0.7),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_rounded,
            color: GameTheme.ottomanGold,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            'Cilt',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: GameTheme.tableBackgroundColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count / $target',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: GameTheme.ottomanGold,
            ),
          ),
        ],
      ),
    );
  }
}
