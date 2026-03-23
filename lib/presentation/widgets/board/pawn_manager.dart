import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/player.dart';
import '../../../../core/utils/board_layout_config.dart';
import '../../../../core/utils/board_layout_helper.dart';
import '../../../../core/motion/motion_constants.dart';
import '../../../providers/game_notifier.dart';
import '../pawn_widget.dart';

/// Manages the rendering and animation state of all pawns on the board.
/// Each player gets a dedicated `AnimatedPositioned` so that the widget
/// identity stays the same when the player moves between tiles, allowing
/// Flutter to smoothly interpolate left/top across positions.
class PawnManager extends StatefulWidget {
  final GameState state;
  final BoardLayoutConfig layout;

  const PawnManager({super.key, required this.state, required this.layout});

  @override
  State<PawnManager> createState() => _PawnManagerState();
}

class _PawnManagerState extends State<PawnManager> {
  final Map<String, int> _lastPlayerPositions = {};

  @override
  void didUpdateWidget(covariant PawnManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleLandingHaptic(widget.state);
  }

  void _handleLandingHaptic(GameState state) {
    for (final player in state.players) {
      final lastPos = _lastPlayerPositions[player.id];
      final currentPos = player.position;

      if (lastPos != null && lastPos != currentPos) {
        HapticFeedback.mediumImpact();
      }
      _lastPlayerPositions[player.id] = currentPos;
    }
  }

  @override
  Widget build(BuildContext context) {
    final players = widget.state.players;
    final layout = widget.layout;
    final currentPlayerId = players.isNotEmpty
        ? players[widget.state.currentPlayerIndex].id
        : '';

    // Group players by tile to compute per-tile slot offsets
    final Map<int, List<Player>> groupMap = {};
    for (final player in players) {
      groupMap.putIfAbsent(player.position, () => []).add(player);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: players.map((player) {
        final tileIndex = player.position;
        final center = BoardLayoutHelper.getTileCenter(tileIndex, layout);
        final tileSize = BoardLayoutHelper.getTileSize(tileIndex, layout);

        // Slot within the tile's 2x3 grid
        final tilePlayers = groupMap[tileIndex] ?? [player];
        final slotIndex = tilePlayers.indexOf(player).clamp(0, 5);

        final double colWidth = tileSize.width / 2;
        final double rowHeight = tileSize.height / 3;
        final double minDim = math.min(colWidth, rowHeight);
        final double safePawnSize = minDim * 0.8;
        final double offsetX = (colWidth - safePawnSize) / 2;
        final double offsetY = (rowHeight - safePawnSize) / 2;

        double slotLeft = (slotIndex % 2 == 0) ? 0 : colWidth;
        double slotTop;
        if (slotIndex < 2) {
          slotTop = 0;
        } else if (slotIndex < 4) {
          slotTop = rowHeight;
        } else {
          slotTop = rowHeight * 2;
        }

        // Center the pawn within its slot by subtracting half its size
        final left = center.dx - (tileSize.width / 2) + slotLeft + offsetX - (safePawnSize / 2);
        final top = center.dy - (tileSize.height / 2) + slotTop + offsetY - (safePawnSize / 2);

        return AnimatedPositioned(
          key: ValueKey('pawn_${player.id}'),
          duration: MotionDurations.pawn.safe,
          curve: MotionCurves.pawnMove,
          left: left,
          top: top,
          child: PawnWidget(
            player: player,
            size: safePawnSize,
            isActive: player.id == currentPlayerId,
            isCurrentTurn: player.id == currentPlayerId,
          ),
        );
      }).toList(),
    );
  }
}
