import '../models/player.dart';
import '../models/board_tile.dart';
import '../models/game_enums.dart';
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
      case TileType.kiraathane:
        return 'KIRAATHANe: Edebi sözler satın alabilirsin.';
      case TileType.chance:
        return 'ŞANS: Bir şans kartı çektin.';
      case TileType.fate:
        return 'KADER: Kaderin seni bekliyor.';
      case TileType.start:
        return 'BAŞLANGIÇ: Yazın yolculuğu başlıyor!';
      case TileType.property:
        return 'SORU: ${tile.title} hakkındaki soruyu bil, telifi kap!';
    }
  }
}
