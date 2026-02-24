import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/player.dart';
import '../../../../core/utils/board_layout_config.dart';
import '../../../../core/utils/board_layout_helper.dart';
import '../../../providers/game_notifier.dart';
import '../pawn_widget.dart';

/// Manages the rendering and animation state (pulse) of all pawns on the board
class PawnManager extends StatefulWidget {
  final GameState state;
  final BoardLayoutConfig layout;

  const PawnManager({super.key, required this.state, required this.layout});

  @override
  State<PawnManager> createState() => _PawnManagerState();
}

class _PawnManagerState extends State<PawnManager> {
  final Map<String, int> _lastPlayerPositions = {};
  int? _pulsingTileId;

  @override
  void didUpdateWidget(covariant PawnManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleLandingPulse(widget.state);
  }

  /// Check for player position changes and trigger landing pulse
  void _handleLandingPulse(GameState state) {
    for (final player in state.players) {
      final lastPos = _lastPlayerPositions[player.id];
      final currentPos = player.position;

      // If position changed and player has moved (not first detection)
      if (lastPos != null && lastPos != currentPos) {
        // Only pulse if not already pulsing another tile
        if (_pulsingTileId == null) {
          // Haptic feedback for tile landing
          HapticFeedback.mediumImpact();

          // Schedule pulse on next frame to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _pulsingTileId = currentPos);
            }
          });
        }
      }

      _lastPlayerPositions[player.id] = currentPos;
    }
  }

  /// Build positioned pawns for all players using AnimatedPawnContainer
  List<Widget> _buildPlayers() {
    final players = widget.state.players;
    final layout = widget.layout;

    // Group players by position (Tile ID)
    final Map<int, List<Player>> groupMap = {};
    for (final player in players) {
      groupMap.putIfAbsent(player.position, () => []).add(player);
    }

    final currentPlayerId = widget.state.players.isNotEmpty
        ? widget.state.players[widget.state.currentPlayerIndex].id
        : '';

    final List<Widget> widgets = [];

    // Create ONE container per Tile Position
    groupMap.forEach((tileIndex, tilePlayers) {
      final center = BoardLayoutHelper.getTileCenter(tileIndex, layout);

      // Get exact dimensions for this tile (Standard, Corner, or Rectangular)
      final tileSize = BoardLayoutHelper.getTileSize(tileIndex, layout);

      widgets.add(
        AnimatedPawnContainer(
          // Use Tile Index in Key to keep container stable for that tile
          // Players will animate "into" this container's layout
          key: ValueKey('pawn_group_$tileIndex'),
          center: center,
          width: tileSize.width,
          height: tileSize.height,
          players: tilePlayers, // Pass ALL players on this tile
          currentPlayerId: currentPlayerId,
          pawnSize: layout.normalSize * 0.45,
        ),
      );
    });

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: _buildPlayers());
  }
}
