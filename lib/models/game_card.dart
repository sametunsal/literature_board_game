import 'game_enums.dart';

enum CardEffectType {
  moneyChange, // Para kazan/kaybet
  move, // Bir yere git (pozitif: ileri, negatif: geri)
  moveRelative, // Göreceli hareket (örn: 2 kare ileri/geri)
  jail, // Kütüphane nöbetine git (tur atla)
  skipTurn, // Bir tur bekle
  rollAgain, // Tekrar zar at
  loseStarsPercentage, // Mevcut yıldızların yüzdesini kaybet
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
