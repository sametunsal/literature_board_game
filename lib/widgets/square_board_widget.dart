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
            clipBehavior: Clip.none,
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
              // Bu metod her oyuncu için bir AnimatedPositioned döndürür
              ..._buildPlayerTokens(gameState.players, u),
            ],
          ),
        );
      },
    );
  }

  // Visual Rect Calculator
  Rect _getTileRect(int id, double u) {
    if (id < 0 || id > 39) return Rect.zero;

    final c = 1.8 * u;
    final total = 12.6 * u;

    // 0: Bottom-Left Corner (START)
    if (id == 0) return Rect.fromLTWH(0, total - c, c, c);

    // 1-9: Left Side
    if (id >= 1 && id <= 9) {
      double bottomY = total - c;
      double myY = bottomY - (id * u);
      return Rect.fromLTWH(0, myY, c, u);
    }

    // 10: Top-Left Corner
    if (id == 10) return Rect.fromLTWH(0, 0, c, c);

    // 11-19: Top Side
    if (id >= 11 && id <= 19) {
      int idx = id - 10;
      double myX = c + ((idx - 1) * u);
      return Rect.fromLTWH(myX, 0, u, c);
    }

    // 20: Top-Right Corner
    if (id == 20) return Rect.fromLTWH(total - c, 0, c, c);

    // 21-29: Right Side
    if (id >= 21 && id <= 29) {
      int idx = id - 20;
      double myY = c + ((idx - 1) * u);
      return Rect.fromLTWH(total - c, myY, c, u);
    }

    // 30: Bottom-Right Corner
    if (id == 30) return Rect.fromLTWH(total - c, total - c, c, c);

    // 31-39: Bottom Side
    if (id >= 31 && id <= 39) {
      int idx = id - 30;
      double rightX = total - c;
      double myX = rightX - (idx * u);
      return Rect.fromLTWH(myX, total - c, u, c);
    }

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
                // Tile text...
              ],
            ),
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

  // Get owner color
  Color _getOwnerColor(
    String? ownerId,
    List<Tile> allTiles,
    List<Player> players,
  ) {
    if (ownerId == null) return Colors.transparent;
    final player = players.firstWhere(
      (p) => p.id == ownerId,
      orElse: () => Player(id: '', name: '', color: '#000000', stars: 0),
    );
    try {
      return Color(int.parse(player.color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  // --- OYUNCU TOKEN MANTIĞI ---
  List<Widget> _buildPlayerTokens(List<Player> players, double u) {
    List<Widget> tokenWidgets = [];
    double tokenSize = u * 0.45;

    // 1. Gruplama mantığı
    final Map<int, List<Player>> groups = {};
    for (var p in players) {
      groups.putIfAbsent(p.position, () => []).add(p);
    }

    // 2. Oyuncu listesini sırayla dönerek token üret
    for (var player in players) {
      final group = groups[player.position]!;
      // Grup içinde ID'ye göre sabit sıralama yap (titremeyi önler)
      group.sort((a, b) => a.id.compareTo(b.id));
      final indexInGroup = group.indexWhere((p) => p.id == player.id);

      // Konum hesaplama
      final rect = _getTileRect(player.position, u);
      double cx = rect.left + (rect.width / 2);
      double cy = rect.top + (rect.height / 2);

      // Ofsetler
      double off = tokenSize * 0.15;
      List<Offset> offsets = [
        Offset(-off, -off),
        Offset(off, -off),
        Offset(-off, off),
        Offset(off, off),
      ];

      final safeIndex = indexInGroup != -1 && indexInGroup < 4
          ? indexInGroup
          : 0;
      final o = offsets[safeIndex];

      final double left = cx + o.dx - (tokenSize / 2);
      final double top = cy + o.dy - (tokenSize / 2);

      // DEBUG: Konsola konum bilgisini yaz
      // Bu sayede State'in güncellenip güncellenmediğini görebiliriz
      debugPrint(
        '[BOARD DEBUG] Player: ${player.name} (ID:${player.id}) -> Pos: ${player.position}, L:$left, T:$top',
      );

      Color playerColor;
      try {
        playerColor = Color(int.parse(player.color.replaceFirst('#', '0xFF')));
      } catch (e) {
        playerColor = Colors.blue;
      }

      String initialLetter = player.name.isNotEmpty ? player.name[0] : '?';

      tokenWidgets.add(
        AnimatedPositioned(
          // KESİN ÇÖZÜM: ID tabanlı benzersiz anahtar
          key: ValueKey("TOKEN_${player.id}"),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
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
                const BoxShadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
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

    return tokenWidgets;
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
