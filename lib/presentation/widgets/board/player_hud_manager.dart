import 'package:flutter/material.dart';
import '../../../providers/game_notifier.dart';
import 'board_visual_constants.dart';
import 'player_hud.dart';

/// Manages the placement of PlayerHUDs around the perimeter of the game board.
class PlayerHudManager extends StatelessWidget {
  final GameState state;

  /// Uniform gap between every HUD card and the screen edge (applied on all
  /// sides in addition to SafeArea), so corner cards never touch the device
  /// frame on landscape phones. Shared with the edge menu buttons so cards
  /// and buttons sit on the same edge line.
  static const double _hudInset = kEdgeControlsInset;

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
              top = _hudInset;
              left = _hudInset;
              break;
            case 1: // Top-Right
              top = _hudInset;
              right = _hudInset;
              break;
            case 2: // Bottom-Right
              bottom = _hudInset;
              right = _hudInset;
              break;
            case 3: // Bottom-Left
              bottom = _hudInset;
              left = _hudInset;
              break;
          }
        } else {
          // PERIMETER 6-POINT LAYOUT (> 4 Players)
          switch (index) {
            case 0: // Top-Left
              top = _hudInset;
              left = _hudInset;
              break;
            case 1: // Top-Right
              top = _hudInset;
              right = _hudInset;
              break;
            case 2: // Middle-Right (anchored above BR card; handled below)
              break;
            case 3: // Bottom-Right
              bottom = _hudInset;
              right = _hudInset;
              break;
            case 4: // Bottom-Left
              bottom = _hudInset;
              left = _hudInset;
              break;
            case 5: // Middle-Left (anchored above BL card; handled below)
              break;
          }
        }

        // Safe Area flags: pad only the edge the card is anchored to
        // (middle slots anchor both edges and handle placement themselves).
        final safeTop = top != null && bottom == null;
        final safeBottom = bottom != null && top == null;

        // Special handling for Middle slots (Index 2 & 5 when > 4): anchored
        // just above the bottom corner cards. This keeps the middle-right
        // card clear of the menu button column (which stacks downward from
        // below the top-right card) and the middle-left card clear of the
        // centered mobile log button.
        if (isMoreThanFour && (index == 2 || index == 5)) {
          return Positioned(
            bottom: kHudEdgeClearance,
            left: index == 5 ? _hudInset : null,
            right: index == 2 ? _hudInset : null,
            child: SafeArea(
              top: false,
              child: PlayerHud(
                player: player,
                isCurrentPlayer: isCurrent,
                isNextPlayer: isNext,
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
