/// Domain entity representing a game card (Chance/Fate).
/// Pure Dart - no Flutter dependencies.

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameCard &&
        other.description == description &&
        other.type == type &&
        other.effectType == effectType &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(description, type, effectType, value);

  @override
  String toString() {
    return 'GameCard(description: $description, type: $type, effectType: $effectType, value: $value)';
  }
}
