import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tile.dart';
import '../models/player.dart';
import '../models/dice_roll.dart';
import '../providers/game_provider.dart';

// Enhanced visual board strip to show player positions with animated movement
class BoardStripWidget extends ConsumerStatefulWidget {
  const BoardStripWidget({super.key});

  @override
  ConsumerState<BoardStripWidget> createState() => _BoardStripWidgetState();
}

class _BoardStripWidgetState extends ConsumerState<BoardStripWidget> {
  // Store global keys for each tile to get their positions
  final Map<int, GlobalKey> _tileKeys = {};

  // Store animated token positions
  final Map<String, TokenPosition> _tokenPositions = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final currentPlayer = ref.watch(currentPlayerProvider);

    final tiles = gameState.tiles;
    final currentPos = currentPlayer?.position;
    final lastDiceRoll = ref.watch(lastDiceRollProvider);
    final turnPhase = ref.watch(turnPhaseProvider);

    // Update token positions when game state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTokenPositions(gameState, turnPhase);
    });

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        border: Border.all(color: Colors.brown.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Board tiles layer
          SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: tiles.map((tile) {
                final isActive = tile.id == currentPos;
                final playersOnTile = gameState.players
                    .where((p) => p.position == tile.id)
                    .toList();

                // Ensure key exists for this tile
                _tileKeys.putIfAbsent(tile.id, () => GlobalKey());

                return _buildTile(
                  key: _tileKeys[tile.id] as Key,
                  tile: tile,
                  isActive: isActive,
                  playersOnTile: playersOnTile,
                  lastDiceRoll: isActive ? lastDiceRoll : null,
                  showStaticTokens: turnPhase != TurnPhase.moving,
                );
              }).toList(),
            ),
          ),

          // Animated tokens layer - overlay for smooth movement
          if (turnPhase == TurnPhase.moving) ..._buildAnimatedTokens(gameState),
        ],
      ),
    );
  }

  // Update token positions based on game state
  void _updateTokenPositions(GameState gameState, TurnPhase turnPhase) {
    if (turnPhase != TurnPhase.moving || gameState.currentPlayer == null) {
      return;
    }

    final currentPlayer = gameState.currentPlayer!;

    // Get old and new tile positions
    final oldKey = _tileKeys[gameState.oldPosition];
    final newKey = _tileKeys[gameState.newPosition];

    if (oldKey != null && newKey != null) {
      final oldContext = oldKey.currentContext;
      final newContext = newKey.currentContext;

      if (oldContext != null && newContext != null) {
        final oldRenderBox = oldContext.findRenderObject() as RenderBox?;
        final newRenderBox = newContext.findRenderObject() as RenderBox?;

        if (oldRenderBox != null && newRenderBox != null) {
          // Get positions relative to the board container
          final oldPosition = oldRenderBox.localToGlobal(Offset.zero);
          final newPosition = newRenderBox.localToGlobal(Offset.zero);

          // Get the board container's position
          final boardContext = context;
          final boardRenderBox = boardContext.findRenderObject() as RenderBox?;

          if (boardRenderBox != null) {
            final boardPosition = boardRenderBox.localToGlobal(Offset.zero);

            // Calculate relative positions
            final startOffset = Offset(
              oldPosition.dx -
                  boardPosition.dx +
                  50, // +50 for center of tile (100/2)
              oldPosition.dy -
                  boardPosition.dy +
                  60, // +60 for center of tile (120/2)
            );

            final endOffset = Offset(
              newPosition.dx - boardPosition.dx + 50,
              newPosition.dy - boardPosition.dy + 60,
            );

            setState(() {
              _tokenPositions[currentPlayer.id] = TokenPosition(
                start: startOffset,
                end: endOffset,
                current: startOffset,
                player: currentPlayer,
              );
            });
          }
        }
      }
    }
  }

  // Build animated tokens for the moving player
  List<Widget> _buildAnimatedTokens(GameState gameState) {
    final animatedTokens = <Widget>[];

    _tokenPositions.forEach((playerId, tokenPos) {
      animatedTokens.add(
        AnimatedPositioned(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          left: tokenPos.end.dx - 16, // Center the token (32/2)
          top: tokenPos.end.dy - 16,
          child: _buildPlayerToken(tokenPos.player),
        ),
      );
    });

    return animatedTokens;
  }

  Widget _buildTile({
    required Key key,
    required Tile tile,
    required bool isActive,
    required List<Player> playersOnTile,
    required DiceRoll? lastDiceRoll,
    required bool showStaticTokens,
  }) {
    final tileColor = _getTileColor(tile.type);
    final isYellowHighlight = isActive;

    return Container(
      key: key,
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: isYellowHighlight ? Colors.yellow.shade200 : tileColor,
        border: Border.all(
          color: isYellowHighlight
              ? Colors.yellow.shade700
              : Colors.brown.shade400,
          width: isYellowHighlight ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isYellowHighlight
            ? [
                BoxShadow(
                  color: Colors.yellow.shade700.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Tile content
          Card(
            elevation: isYellowHighlight ? 4 : 1,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tile number and name
                  Column(
                    children: [
                      Text(
                        '${tile.id}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tile.name,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Colors.brown.shade800,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  // Last dice roll if this is active tile
                  if (lastDiceRoll != null) ...[
                    const SizedBox(height: 4),
                    _buildDiceRoll(lastDiceRoll),
                  ],
                ],
              ),
            ),
          ),

          // Player tokens stacked on top of tile
          // Only show static tokens when not animating
          if (showStaticTokens && playersOnTile.isNotEmpty)
            Positioned(
              top: -8,
              right: -8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: playersOnTile.asMap().entries.map((entry) {
                  final index = entry.key;
                  final player = entry.value;
                  return Transform.translate(
                    offset: Offset(0.0, index * -12.0),
                    child: _buildPlayerToken(player),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerToken(Player player) {
    final playerColor = player.color.startsWith('#')
        ? int.parse(player.color.substring(1), radix: 16)
        : 0xFF888888;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(playerColor),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          player.name.length > 2 ? player.name.substring(0, 2) : player.name,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDiceRoll(DiceRoll diceRoll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${diceRoll.die1}+${diceRoll.die2}=${diceRoll.total}',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade800,
          ),
        ),
      ],
    );
  }

  Color _getTileColor(TileType type) {
    switch (type) {
      case TileType.corner:
        return Colors.orange.shade100;
      case TileType.book:
        return Colors.blueAccent.shade100;
      case TileType.publisher:
        return Colors.green.shade100;
      case TileType.chance:
        return Colors.purple.shade100;
      case TileType.fate:
        return Colors.redAccent.shade100;
      case TileType.tax:
        return Colors.grey.shade200;
      case TileType.special:
        return Colors.teal.shade100;
    }
  }
}

// Class to store token position information
class TokenPosition {
  final Offset start;
  final Offset end;
  Offset current;
  final Player player;

  TokenPosition({
    required this.start,
    required this.end,
    required this.current,
    required this.player,
  });
}
