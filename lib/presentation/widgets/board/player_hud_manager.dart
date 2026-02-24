import 'package:flutter/material.dart';
import '../../../providers/game_notifier.dart';
import 'player_hud.dart';

/// Manages the placement of PlayerHUDs around the perimeter of the game board.
class PlayerHudManager extends StatelessWidget {
  final GameState state;

  const PlayerHudManager({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.players.isEmpty) return const SizedBox.shrink();

    final players = state.players;
    final isMoreThanFour = players.length > 4;
    final currentPlayerId = state.players.isNotEmpty
        ? state.players[state.currentPlayerIndex].id
        : '';
    final nextIndex = (state.currentPlayerIndex + 1) % state.players.length;
    final nextPlayerId = state.players.isNotEmpty
        ? state.players[nextIndex].id
        : '';

    return Stack(
      children: List.generate(players.length, (index) {
        final player = players[index];
        final isCurrent = player.id == currentPlayerId;
        final isNext = player.id == nextPlayerId;

        // Determine Position based on Rules
        double? top, bottom, left, right;

        // Default corner logic (Index 0-3)
        // 0: TL, 1: TR, 2: BR/MR, 3: BL/BR

        if (!isMoreThanFour) {
          // STANDARD CORNER LAYOUT (<= 4 Players)
          switch (index) {
            case 0: // Top-Left
              top = 0;
              left = 0;
              break;
            case 1: // Top-Right
              top = 0;
              right = 0;
              break;
            case 2: // Bottom-Right
              bottom = 0;
              right = 0;
              break;
            case 3: // Bottom-Left
              bottom = 0;
              left = 0;
              break;
          }
        } else {
          // PERIMETER 6-POINT LAYOUT (> 4 Players)
          switch (index) {
            case 0: // Top-Left
              top = 0;
              left = 0;
              break;
            case 1: // Top-Right
              top = 0;
              right = 0;
              break;
            case 2: // Middle-Right
              // Vertical centering handled via Alignment in Positioned.fill/Align combo below
              top = 0;
              bottom = 0;
              right = 0;
              break;
            case 3: // Bottom-Right
              bottom = 0;
              right = 0;
              break;
            case 4: // Bottom-Left
              bottom = 0;
              left = 0;
              break;
            case 5: // Middle-Left
              // Vertical centering handled via Alignment below
              top = 0;
              bottom = 0;
              left = 0;
              break;
          }
        }

        // Safe Area flags
        bool safeTop = (top == 0 && bottom == 0) ? false : (top == 0);
        bool safeBottom = (top == 0 && bottom == 0) ? false : (bottom == 0);

        // Special handling for Middle slots (Index 2 & 5 when > 4)
        if (isMoreThanFour && (index == 2 || index == 5)) {
          return Positioned(
            top: 0,
            bottom: 0,
            left: index == 5 ? 0 : null,
            right: index == 2 ? 0 : null,
            child: Align(
              alignment: index == 2
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Padding(
                // Add vertical offset to Middle-Right (Index 2) to avoid PAUSE buttons if needed
                // Pushing down by 80px to clear the top-right button area
                padding: EdgeInsets.only(top: index == 2 ? 100 : 0),
                child: PlayerHud(
                  player: player,
                  isCurrentPlayer: isCurrent,
                  isNextPlayer: isNext,
                ),
              ),
            ),
          );
        }

        // Standard Corner Positioning
        return Positioned(
          top: top,
          bottom: bottom,
          left: left,
          right: right,
          child: SafeArea(
            top: safeTop,
            bottom: safeBottom,
            child: PlayerHud(
              player: player,
              isCurrentPlayer: isCurrent,
              isNextPlayer: isNext,
            ),
          ),
        );
      }),
    );
  }
}
