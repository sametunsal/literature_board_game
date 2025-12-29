import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tile.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';

/// Square Board Widget - 40 tiles (10 per side)
/// Counter-clockwise layout starting from Bottom-Left (START - tile 0)
/// Corner tiles have flex ratio 1.5, regular tiles have flex ratio 1.0
class SquareBoardWidget extends ConsumerWidget {
  const SquareBoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final tiles = gameState.tiles;
    final currentPlayer = gameState.currentPlayer;

    return Container(
      decoration: BoxDecoration(
        color: Colors.brown.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown.shade400, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          children: [
            // Board tiles
            _buildBoardLayout(tiles),

            // Center area
            _buildCenterArea(),

            // Player tokens
            ..._buildPlayerTokens(gameState.players, currentPlayer),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardLayout(List<Tile> tiles) {
    return Column(
      children: [
        // Top Row (Left to Right: tiles 20-29)
        Expanded(
          child: Row(
            children: [
              // Corner 20 (Top-Left - SIGNING DAY)
              Expanded(flex: 15, child: _buildTile(tiles[20])),
              // Tiles 21-29
              for (int i = 21; i <= 29; i++)
                Expanded(flex: 10, child: _buildTile(tiles[i])),
            ],
          ),
        ),

        // Middle section
        Expanded(
          child: Row(
            children: [
              // Left Column (Bottom to Top: tiles 10-19)
              Expanded(
                child: Column(
                  children: [
                    for (int i = 19; i >= 10; i--)
                      Expanded(flex: 10, child: _buildTile(tiles[i])),
                  ],
                ),
              ),

              // Center empty space
              const Expanded(flex: 70, child: SizedBox.shrink()),

              // Right Column (Top to Bottom: tiles 30-39)
              Expanded(
                child: Column(
                  children: [
                    for (int i = 30; i <= 39; i++)
                      Expanded(flex: 10, child: _buildTile(tiles[i])),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom Row (Right to Left: tiles 0-9)
        Expanded(
          child: Row(
            children: [
              // Tiles 9-1
              for (int i = 9; i >= 1; i--)
                Expanded(flex: 10, child: _buildTile(tiles[i])),
              // Corner 0 (Bottom-Left - START)
              Expanded(flex: 15, child: _buildTile(tiles[0])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTile(Tile tile) {
    final tileColor = _getTileColor(tile.type);
    final isCorner = tile.id % 10 == 0;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: tileColor,
        border: Border.all(
          color: tile.type == TileType.corner
              ? Colors.brown.shade700
              : Colors.brown.shade400,
          width: isCorner ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(isCorner ? 12 : 6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tile number
          Text(
            '${tile.id}',
            style: GoogleFonts.poppins(
              fontSize: isCorner ? 16 : 12,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade900,
            ),
          ),
          const SizedBox(height: 4),
          // Tile name
          Text(
            tile.name,
            style: GoogleFonts.poppins(
              fontSize: isCorner ? 10 : 8,
              fontWeight: FontWeight.w600,
              color: Colors.brown.shade800,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // Show purchase price or fee if applicable
          if (tile.purchasePrice != null || tile.copyrightFee != null) ...[
            const SizedBox(height: 2),
            Text(
              tile.purchasePrice != null
                  ? '${tile.purchasePrice}★'
                  : '${tile.copyrightFee}★',
              style: GoogleFonts.poppins(
                fontSize: isCorner ? 9 : 7,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCenterArea() {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.brown.shade800,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 56, color: Colors.amber),
            const SizedBox(height: 12),
            Text(
              'EDEBİYAT',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'OYUNU',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPlayerTokens(List<Player> players, Player? currentPlayer) {
    final tokens = <Widget>[];

    for (int i = 0; i < players.length; i++) {
      final player = players[i];
      final position = player.position;
      final isCurrentPlayer = currentPlayer?.id == player.id;

      tokens.add(
        Positioned(
          left: _calculateTokenX(position),
          top: _calculateTokenY(position),
          child: _buildPlayerToken(player, isCurrentPlayer, i),
        ),
      );
    }

    return tokens;
  }

  double _calculateTokenX(int position) {
    // Calculate X position based on tile index (0-39)
    // Counter-clockwise from Bottom-Left
    if (position >= 0 && position <= 9) {
      // Bottom row (0-9): Right to Left
      return 0.5 - (position * 0.1); // Start at 0.5, move left
    } else if (position >= 10 && position <= 19) {
      // Left column (10-19): Bottom to Top
      return 0.5; // Left edge
    } else if (position >= 20 && position <= 29) {
      // Top row (20-29): Left to Right
      return 0.5 + ((position - 20) * 0.1); // Start at 0.5, move right
    } else {
      // Right column (30-39): Top to Bottom
      return 0.5; // Right edge
    }
  }

  double _calculateTokenY(int position) {
    // Calculate Y position based on tile index (0-39)
    // Counter-clockwise from Bottom-Left
    if (position >= 0 && position <= 9) {
      // Bottom row (0-9): Right to Left
      return 0.5; // Bottom edge
    } else if (position >= 10 && position <= 19) {
      // Left column (10-19): Bottom to Top
      return 0.5 - ((position - 10) * 0.1); // Start at 0.5, move up
    } else if (position >= 20 && position <= 29) {
      // Top row (20-29): Left to Right
      return 0.5; // Top edge
    } else {
      // Right column (30-39): Top to Bottom
      return 0.5 + ((position - 30) * 0.1); // Start at 0.5, move down
    }
  }

  Widget _buildPlayerToken(Player player, bool isCurrentPlayer, int index) {
    final playerColor = player.color.startsWith('#')
        ? int.parse(player.color.substring(1), radix: 16)
        : 0xFF888888;

    // Add slight offset for multiple players on same tile
    final offsetX = (index % 3) * 8.0 - 8.0;
    final offsetY = (index ~/ 3) * 8.0 - 8.0;

    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(playerColor),
          border: Border.all(
            color: isCurrentPlayer ? Colors.amber : Colors.white,
            width: isCurrentPlayer ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
            if (isCurrentPlayer)
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Center(
          child: Text(
            player.name.length > 2
                ? player.name.substring(0, 2).toUpperCase()
                : player.name.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Color _getTileColor(TileType type) {
    switch (type) {
      case TileType.corner:
        return Colors.orange.shade200;
      case TileType.book:
        return Colors.blue.shade100;
      case TileType.publisher:
        return Colors.green.shade200;
      case TileType.chance:
        return Colors.purple.shade200;
      case TileType.fate:
        return Colors.red.shade200;
      case TileType.tax:
        return Colors.grey.shade300;
      case TileType.special:
        return Colors.teal.shade200;
    }
  }
}
