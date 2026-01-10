import 'package:flutter/material.dart';
import '../models/board_tile.dart';
import '../models/game_enums.dart';
import '../core/theme/game_theme.dart';

class EnhancedTileWidget extends StatelessWidget {
  final BoardTile tile;
  final double width;
  final double height;

  const EnhancedTileWidget({
    super.key,
    required this.tile,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    bool isCorner = tile.id % 10 == 0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: GameTheme.parchment,
        border: Border.all(color: Colors.black87, width: 0.8),
      ),
      child: isCorner ? _buildCornerContent() : _buildPropertyContent(),
    );
  }

  Widget _buildPropertyContent() {
    // Dikey mi Yatay mı? (Kenara göre karar verilir ama burada basit tutuyoruz, dışarıdan rotated box ile çevrilecek)
    return Column(
      children: [
        // RENK ŞERİDİ (Üst %25)
        Container(
          height: height * 0.25,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _getGroupColor(tile.id),
            border: Border(
              bottom: BorderSide(color: Colors.black87, width: 0.5),
            ),
          ),
          child: _buildUpgradeIcons(), // Yıldızlar
        ),
        // İÇERİK
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tile.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8, // Küçük ama okunaklı
                    fontWeight: FontWeight.w700,
                    color: GameTheme.textPrimary,
                    fontFamily:
                        'RobotoCondensed', // Sıkışık font daha iyi sığar
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tile.price != null && !tile.isUtility)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.black.withOpacity(0.05),
                    ),
                    child: Text(
                      "${tile.price}₺",
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCornerContent() {
    // Köşeler için özel, ikon odaklı tasarım
    IconData icon;
    String label;
    Color bg;

    switch (tile.type) {
      case TileType.start:
        icon = Icons.start;
        label = "BAŞLANGIÇ";
        bg = Color(0xFFE8F5E9);
        break;
      case TileType.libraryWatch:
        icon = Icons.local_library;
        label = "NÖBET";
        bg = Color(0xFFFFF3E0);
        break;
      case TileType.autographDay:
        icon = Icons.campaign;
        label = "İMZA GÜNÜ";
        bg = Color(0xFFF3E5F5);
        break;
      case TileType.bankruptcyRisk:
        icon = Icons.gavel;
        label = "İFLAS RİSKİ";
        bg = Color(0xFFFFEBEE);
        break;
      default:
        icon = Icons.help;
        label = "";
        bg = Colors.white;
    }

    return Container(
      color: bg,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plan ikonu (büyük ve soluk)
          Opacity(opacity: 0.1, child: Icon(icon, size: width * 0.8)),
          // Ön plan
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: width * 0.4, color: Colors.black87),
              SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeIcons() {
    if (tile.upgradeLevel == 0) return SizedBox();
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          tile.upgradeLevel,
          (i) => Icon(Icons.star, size: 8, color: Colors.white),
        ),
      ),
    );
  }

  Color _getGroupColor(int id) {
    if (id > 0 && id < 5) return Color(0xFF7B1FA2); // Mor
    if (id > 5 && id < 10) return Color(0xFF1976D2); // Mavi
    if (id > 10 && id < 15) return Color(0xFFC2185B); // Pembe
    if (id > 15 && id < 20) return Color(0xFFF57C00); // Turuncu
    if (id > 20 && id < 25) return Color(0xFFD32F2F); // Kırmızı
    if (id > 25 && id < 30) return Color(0xFFFBC02D); // Sarı
    if (id > 30 && id < 35) return Color(0xFF388E3C); // Yeşil
    if (id > 35 && id < 40) return Color(0xFF0288D1); // Açık Mavi
    return Colors.grey[400]!;
  }
}
