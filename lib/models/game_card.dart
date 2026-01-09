import 'game_enums.dart';

enum CardEffectType {
  moneyChange, // Para kazan/kaybet
  move, // Bir yere git
  jail, // Kütüphane nöbetine git
  globalMoney, // Diğer oyunculardan para al/ver (Kader kartı özelliği)
}

class GameCard {
  final String description;
  final CardType type; // Şans veya Kader
  final CardEffectType effectType;
  final int value; // Para miktarı veya Gidilecek Tile ID'si

  const GameCard({
    required this.description,
    required this.type,
    required this.effectType,
    this.value = 0,
  });
}
