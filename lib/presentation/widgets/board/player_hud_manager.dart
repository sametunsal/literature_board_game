import 'package:flutter/material.dart';
import '../../../providers/game_notifier.dart';
import 'board_visual_constants.dart';
import 'player_hud.dart';

/// How [PlayerHudManager] arranges the player panels.
enum PlayerHudLayoutMode {
  /// Panels are absolutely positioned around the screen perimeter. The root
  /// widget is a [Stack]; it expects to fill the viewport.
  perimeter,

  /// Panels are stacked top-to-bottom in a scrollable list, sized to whatever
  /// box the parent gives it. Used by the right-side HUD column so the panels
  /// never float over the board.
  column,
}

/// Manages the placement of PlayerHUDs around the perimeter of the game board,
/// or — in [PlayerHudLayoutMode.column] — as a vertical list inside the
/// right-side HUD column.
class PlayerHudManager extends StatelessWidget {
  final GameState state;

  /// Arrangement of the panels. Defaults to the perimeter stack so the widget
  /// stays pumpable on its own exactly as before.
  final PlayerHudLayoutMode mode;

  /// Uniform gap between every HUD card and the screen edge (applied on all
  /// sides in addition to SafeArea), so corner cards never touch the device
  /// frame on landscape phones. Shared with the edge menu buttons so cards
  /// and buttons sit on the same edge line.
  static const double _hudInset = kEdgeControlsInset;

  const PlayerHudManager({
    super.key,
    required this.state,
    this.mode = PlayerHudLayoutMode.perimeter,
  });

  @override
  Widget build(BuildContext context) {
    if (state.players.isEmpty) return const SizedBox.shrink();

    if (mode == PlayerHudLayoutMode.column) {
      return _buildColumn();
    }

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

  /// Vertical list of panels for the right-side HUD column.
  ///
  /// Scrollable so six players still fit a 360dp-tall landscape viewport, and
  /// each panel is scaled down rather than overflowing if the column is
  /// narrower than the panel's fixed width.
  Widget _buildColumn() {
    final players = state.players;
    final currentPlayerId = players[state.currentPlayerIndex].id;
    final nextIndex = (state.currentPlayerIndex + 1) % players.length;
    final nextPlayerId = players[nextIndex].id;

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < players.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == players.length - 1
                    ? 0
                    : kHudColumnItemSpacing,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: PlayerHud(
                    player: players[index],
                    isCurrentPlayer: players[index].id == currentPlayerId,
                    isNextPlayer: players[index].id == nextPlayerId,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
