import 'dart:math'; // min fonksiyonu için gerekli
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

    // 12.6x12.6 Grid System
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.biggest.shortestSide;

        // Çerçeve (Border) Hesaplaması
        final borderWidth = 4.0;
        final innerSize = boardSize - (borderWidth * 2);
        final u = innerSize / 12.6; // Unit size

        return Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
            color: const Color(0xFFD7CCC8),
            border: Border.all(
              color: const Color(0xFF5D4037),
              width: borderWidth,
            ),
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
                child: CenterArea(u: u),
              ),

              // --- PLAYER TOKENS ---
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

  /// METİN BOYUTU HESAPLAYICI (GÜNCELLENDİ)
  /// Hem toplam karakter sayısına hem de EN UZUN KELİMEYE bakar.
  /// Böylece "Kuyucaklı" gibi uzun kelimeler bölünmez.
  double _calculateFontSize(String text, double u) {
    // 1. En uzun kelimeyi bul
    List<String> words = text.split(' ');
    int maxWordLength = 0;
    for (var word in words) {
      if (word.length > maxWordLength) {
        maxWordLength = word.length;
      }
    }

    // Eğer metin tek bir uzun kelimeden oluşmuyorsa (ör: "Kürk Mantolu Madonna")
    // en uzun kelime "Madonna" (7 harf) olur.

    // MATEMATİKSEL HESAP:
    // Poppins fontunun ortalama karakter genişliği 0.6 * fontSize civarındadır.
    // Kutucuk genişliği padding düşünce yaklaşık 0.9 * u.
    // Denklem: (maxWordLength * 0.6 * fontSize) <= 0.9 * u
    // fontSize <= (1.5 * u) / maxWordLength

    // Biraz daha güvenli olsun diye 1.4 katsayısını kullanıyoruz:
    double wordBasedMaxSize =
        (1.4 * u) / (maxWordLength > 0 ? maxWordLength : 1);

    // Tavan değer: 0.19u'dan büyük olmasın
    wordBasedMaxSize = wordBasedMaxSize.clamp(0.08 * u, 0.19 * u);

    // 2. Toplam uzunluk kontrolü (Eski mantık, genel yoğunluk için)
    double lengthBasedSize = u * 0.18;
    int len = text.length;
    if (len > 40)
      lengthBasedSize = u * 0.11;
    else if (len > 30)
      lengthBasedSize = u * 0.12;
    else if (len > 20)
      lengthBasedSize = u * 0.14;
    else if (len > 12)
      lengthBasedSize = u * 0.16;

    // İki kriterden hangisi daha küçük (daha kısıtlayıcı) ise onu seç
    return min(wordBasedMaxSize, lengthBasedSize);
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

    // AKILLI FONT HESAPLAMA
    final fontSize = _calculateFontSize(tile.name, u);

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
        padding: EdgeInsets.symmetric(horizontal: u * 0.05),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCorner)
                  Icon(
                    _getIconForCorner(id),
                    size: u * 0.4,
                    color: Colors.black54,
                  ),
                Expanded(
                  child: Center(
                    child: Text(
                      tile.name,
                      textAlign: TextAlign.center,
                      // Satır sayısını maksimize et
                      maxLines: isCorner ? 2 : 4,
                      // Kelime bütünlüğü için ellipsis kullan, ama wrap normal davranır
                      overflow: TextOverflow.visible,
                      style: GoogleFonts.poppins(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        height: 1.05, // Satırları hafif açtık, okunaklılık için
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (hasOwner)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: u * 0.25,
                  height: u * 0.25,
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

  List<Widget> _buildPlayerTokens(List<Player> players, double u) {
    List<Widget> tokenWidgets = [];
    double tokenSize = u * 0.45;

    final Map<int, List<Player>> groups = {};
    for (var p in players) {
      groups.putIfAbsent(p.position, () => []).add(p);
    }

    for (var player in players) {
      final group = groups[player.position]!;
      group.sort((a, b) => a.id.compareTo(b.id));
      final indexInGroup = group.indexWhere((p) => p.id == player.id);

      final rect = _getTileRect(player.position, u);
      double cx = rect.left + (rect.width / 2);
      double cy = rect.top + (rect.height / 2);

      double off = tokenSize * 0.20;
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

      Color playerColor;
      try {
        playerColor = Color(int.parse(player.color.replaceFirst('#', '0xFF')));
      } catch (e) {
        playerColor = Colors.blue;
      }

      String initialLetter = player.name.isNotEmpty ? player.name[0] : '?';

      tokenWidgets.add(
        AnimatedPositioned(
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
  final double u;
  const CenterArea({super.key, required this.u});

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
            child: Icon(Icons.school, size: u * 1.5, color: Colors.amber),
          ),
          SizedBox(height: u * 0.2),
          Text(
            "EDEBINGO",
            style: GoogleFonts.titanOne(
              fontSize: u * 0.7,
              color: Colors.brown.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
