import '../models/player.dart';
import '../models/board_tile.dart';
import '../models/tile_type.dart';
import '../data/board_config.dart';

class GameEngine {
  /// Zar atma simülasyonu (2 zar)
  static Map<String, dynamic> rollDice() {
    // Burada basit random kullanımı, Riverpod tarafında Random sınıfı ile yapılabilir
    // Şimdilik motor sadece kural döndürür.
    return {};
  }

  /// Yeni pozisyonu hesaplar
  static int calculateNewPosition(int currentPos, int diceTotal) {
    return (currentPos + diceTotal) % BoardConfig.tiles.length;
  }

  /// Başlangıç noktasından geçip geçmediğini kontrol eder
  static bool passedStart(int oldPos, int newPos) {
    return newPos < oldPos;
  }

  /// Bir kutucuğa gelindiğinde ne olacağını belirler
  static String resolveTileEffect(BoardTile tile, Player player) {
    switch (tile.type) {
      case TileType.shop:
        return 'KIRAATHANe: Edebi sözler satın alabilirsin.';
      case TileType.corner:
        return 'KÖŞE: Özel bir kareye geldin.';
      case TileType.start:
        return 'BAŞLANGIÇ: Yazın yolculuğu başlıyor!';
      case TileType.category:
        return 'SORU: ${tile.name} hakkındaki soruyu bil, yıldızları kap!';
      case TileType.collection:
        return 'KOLEKSİYON: Eserlerini burada inceleyebilirsin.';
      case TileType.library:
        return 'KÜTÜPHANE: Sessizlik lazım! 2 tur bekle.';
      case TileType.signingDay:
        return 'İMZA GÜNÜ: Okurlarınla bir araya geldin!';
    }
  }
}
