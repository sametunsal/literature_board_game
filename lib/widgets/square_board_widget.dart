import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tile.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';

class SquareBoardWidget extends ConsumerWidget {
  const SquareBoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final tiles = gameState.tiles;

    if (tiles.isEmpty) return const SizedBox();

    // 12.6x12.6 Grid System (Thicker Ring for Larger Tiles)
    // Corners: 1.8 units. Edges: 9 tiles * 1.0 units. Total = 12.6 units.
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.biggest.shortestSide;
        final u = boardSize / 12.6; // Unit size

        return Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
            color: const Color(0xFFD7CCC8),
            border: Border.all(color: const Color(0xFF5D4037), width: 4),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [const BoxShadow(blurRadius: 12, color: Colors.black54)],
          ),
          child: Stack(
            children: [
              // --- DRAW TILES ---
              for (int i = 0; i < 40; i++)
                _buildPositionedTile(tiles, gameState.players, i, u),

              // --- CENTER LOGO ---
              Positioned(
                left: 1.8 * u,
                top: 1.8 * u,
                width: 9 * u,
                height: 9 * u,
                child: const CenterArea(),
              ),

              // --- PLAYER TOKENS ---
              ..._buildPlayerTokens(gameState.players, u),
            ],
          ),
        );
      },
    );
  }

  // Visual Rect Calculator (0,0 is Top-Left of Screen)
  Rect _getTileRect(int id, double u) {
    // Bounds checking: valid tile IDs are 0-39
    if (id < 0 || id > 39) {
      debugPrint(
        '⚠️ Invalid tile ID: $id (valid range: 0-39), returning zero rect',
      );
      return Rect.zero;
    }

    final c = 1.8 * u; // Corner size (thicker ring)
    final total = 12.6 * u; // Total size

    // 0: Bottom-Left Corner (START)
    if (id == 0) return Rect.fromLTWH(0, total - c, c, c);

    // 1-9: Left Side (Bottom -> Top)
    if (id >= 1 && id <= 9) {
      // id 1 is directly above corner (0).
      // index 1..9
      double bottomY = total - c; // Top of BL corner
      double myY = bottomY - (id * u);
      return Rect.fromLTWH(
        0,
        myY,
        c,
        u,
      ); // Use 'c' width for left column visual consistency
    }

    // 10: Top-Left Corner
    if (id == 10) return Rect.fromLTWH(0, 0, c, c);

    // 11-19: Top Side (Left -> Right)
    if (id >= 11 && id <= 19) {
      int idx = id - 10; // 1..9
      double myX = c + ((idx - 1) * u);
      return Rect.fromLTWH(myX, 0, u, c);
    }

    // 20: Top-Right Corner
    if (id == 20) return Rect.fromLTWH(total - c, 0, c, c);

    // 21-29: Right Side (Top -> Bottom)
    if (id >= 21 && id <= 29) {
      int idx = id - 20; // 1..9
      double myY = c + ((idx - 1) * u);
      return Rect.fromLTWH(total - c, myY, c, u);
    }

    // 30: Bottom-Right Corner
    if (id == 30) return Rect.fromLTWH(total - c, total - c, c, c);

    // 31-39: Bottom Side (Right -> Left)
    if (id >= 31 && id <= 39) {
      int idx = id - 30; // 1..9
      // Moving left from BR corner
      double rightX = total - c;
      double myX = rightX - (idx * u);
      return Rect.fromLTWH(myX, total - c, u, c);
    }

    // This should never be reached due to bounds check above
    debugPrint('⚠️ Unhandled tile ID: $id, returning zero rect');
    return Rect.zero;
  }

  Widget _buildPositionedTile(
    List<Tile> allTiles,
    List<Player> players,
    int id,
    double u,
  ) {
    final tile = allTiles.firstWhere(
      (t) => t.id == id,
      orElse: () => Tile(
        id: id,
        name: '',
        type: TileType.book,
        purchasePrice: 0,
        copyrightFee: 0,
      ),
    );
    final rect = _getTileRect(id, u);
    final isCorner = id % 10 == 0;
    final hasOwner = tile.owner != null;

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Container(
        decoration: BoxDecoration(
          color: _getTileColor(tile.type),
          border: Border.all(
            color: hasOwner ? Colors.black87 : Colors.black26,
            width: hasOwner ? 2.0 : 0.5,
          ),
        ),
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCorner)
                  Icon(
                    _getIconForCorner(id),
                    size: u * 0.3,
                    color: Colors.black54,
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.5),
                    child: Center(
                      child: Text(
                        tile.name,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: u * 0.125,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.5,
                          height: 1.0,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Owner indicator (small colored dot in corner)
            if (hasOwner)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: u * 0.2,
                  height: u * 0.2,
                  decoration: BoxDecoration(
                    color: _getOwnerColor(tile.owner, allTiles, players),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Get owner color based on player ID
  Color _getOwnerColor(
    String? ownerId,
    List<Tile> allTiles,
    List<Player> players,
  ) {
    if (ownerId == null) return Colors.transparent;

    // Find player by ID
    final player = players.firstWhere(
      (p) => p.id == ownerId,
      orElse: () => Player(id: '', name: '', color: '#000000', stars: 0),
    );

    // Parse player color with error handling
    try {
      return Color(int.parse(player.color.replaceFirst('#', '0xFF')));
    } catch (e) {
      debugPrint(
        '⚠️ Error parsing player color "${player.color}": $e, using default gray',
      );
      return Colors.grey;
    }
  }

  List<Widget> _buildPlayerTokens(List<Player> players, double u) {
    final Map<int, List<Player>> groups = {};
    for (var p in players) {
      groups.putIfAbsent(p.position, () => []).add(p);
    }

    List<Widget> tokens = [];
    double tokenSize = u * 0.45; // Token is 45% of a unit size

    groups.forEach((tileId, group) {
      final rect = _getTileRect(tileId, u);
      // Center of the tile
      double cx = rect.left + (rect.width / 2);
      double cy = rect.top + (rect.height / 2);

      // 2x2 Grid Offsets (Pixel values) - Tighter for better centering
      double off = tokenSize * 0.15;
      List<Offset> offsets = [
        Offset(-off, -off),
        Offset(off, -off),
        Offset(-off, off),
        Offset(off, off),
      ];

      for (int i = 0; i < group.length; i++) {
        final p = group[i];
        final o = i < 4 ? offsets[i] : Offset.zero;

        // Final position: Center + Offset - (Half Token Size to center the widget itself)
        final double left = cx + o.dx - (tokenSize / 2);
        final double top = cy + o.dy - (tokenSize / 2);

        // Parse player color with error handling
        Color playerColor;
        try {
          playerColor = Color(int.parse(p.color.replaceFirst('#', '0xFF')));
        } catch (e) {
          debugPrint(
            '⚠️ Error parsing player color "${p.color}": $e, using default blue',
          );
          playerColor = Colors.blue;
        }

        // Get first letter safely
        String initialLetter = '?';
        if (p.name.isNotEmpty) {
          initialLetter = p.name[0];
        }

        tokens.add(
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            left: left,
            top: top,
            child: Container(
              width: tokenSize,
              height: tokenSize,
              decoration: BoxDecoration(
                color: playerColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  const BoxShadow(color: Colors.black45, blurRadius: 3),
                ],
              ),
              child: Center(
                child: Text(
                  initialLetter,
                  style: TextStyle(
                    fontSize: tokenSize * 0.6,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    });
    return tokens;
  }

  Color _getTileColor(TileType type) {
    switch (type) {
      case TileType.corner:
        return const Color(0xFFFFCC80);
      case TileType.book:
        return const Color(0xFFE3F2FD);
      case TileType.publisher:
        return const Color(0xFFC8E6C9);
      case TileType.chance:
        return const Color(0xFFF3E5F5);
      case TileType.fate:
        return const Color(0xFFFFEBEE);
      case TileType.tax:
        return const Color(0xFFCFD8DC);
      default:
        return Colors.white;
    }
  }

  IconData _getIconForCorner(int id) {
    switch (id) {
      case 0:
        return Icons.flag;
      case 10:
        return Icons.local_library;
      case 20:
        return Icons.edit_note;
      case 30:
        return Icons.warning_amber;
      default:
        return Icons.circle;
    }
  }
}

class CenterArea extends StatelessWidget {
  const CenterArea({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFEBE9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.rotate(
            angle: -0.1,
            child: const Icon(Icons.school, size: 48, color: Colors.amber),
          ),
          const SizedBox(height: 8),
          Text(
            "EDEBINGO",
            style: GoogleFonts.titanOne(
              fontSize: 28,
              color: Colors.brown.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
