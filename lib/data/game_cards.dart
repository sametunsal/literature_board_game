import '../models/game_card.dart';
import '../models/game_enums.dart';

class GameCards {
  // --- ŞANS KARTLARI (Ödül Odaklı - Start-from-Zero Economy) ---
  static const List<GameCard> sansCards = [
    // Telif ödülleri (düşük miktarlarda, 0'dan başlayan oyuncular için)
    GameCard(
      description:
          "Telif hakkı ödemesi aldın! +8 Yıldız kazandın.",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: 8,
    ),
    GameCard(
      description:
          "Küçük bir edebi ödül kazandın. +10 Yıldız!",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: 10,
    ),
    GameCard(
      description:
          "Makalen dergide yayınlandı. +12 Yıldız kazandın.",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: 12,
    ),
    GameCard(
      description:
          "İlham perisi geldi! 2 kare ileri git.",
      type: CardType.sans,
      effectType: CardEffectType.moveRelative,
      value: 1,
    ),
    GameCard(
      description:
          "Vakit nakittir! Tekrar zar at.",
      type: CardType.sans,
      effectType: CardEffectType.rollAgain,
      value: 0,
    ),
    GameCard(
      description:
          "Eleştirmenlere karşı geçici bağışıklık kazandın. (Bir sonraki cezadan korunursun)",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: 5, // Small bonus as placeholder for protect effect
    ),
    GameCard(
      description:
          "Okuyucularından güzel mektuplar aldın. +10 Yıldız motivasyon!",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: 8,
    ),
    GameCard(
      description:
          "Kütüphanede kıymetli bir eser buldun. 1 kare ileri!",
      type: CardType.sans,
      effectType: CardEffectType.moveRelative,
      value: 1,
    ),
    GameCard(
      description:
          "Yayınevinden küçük bir avans geldi. +10 Yıldız!",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: 10,
    ),
  ];

  // --- KADER KARTLARI (Durum ve Risk Odaklı - Start-from-Zero Economy) ---
  static const List<GameCard> kaderCards = [
    // Tur cezaları (para yerine)
    GameCard(
      description:
          "Mürekkepin bitti. Bir tur bekle.",
      type: CardType.kader,
      effectType: CardEffectType.skipTurn,
      value: 1,
    ),
    GameCard(
      description:
          "Yazıcı tıkandı! Bir tur beklemek zorundasın.",
      type: CardType.kader,
      effectType: CardEffectType.skipTurn,
      value: 1,
    ),

    // Geri hareket (konum kaybı)
    GameCard(
      description:
          "Yanlış anlaşılma yüzünden tekzip yayınladın. 2 kare geri git.",
      type: CardType.kader,
      effectType: CardEffectType.moveRelative,
      value: -1,
    ),
    GameCard(
      description:
          "Eserin eleştirildi. 3 kare geri çekil.",
      type: CardType.kader,
      effectType: CardEffectType.moveRelative,
      value: -2,
    ),

    // Yüzdeli kayıplar (0 olduğunda güvenli)
    GameCard(
      description:
          "Cüzdanını düşürdün. Mevcut yıldızlarının %40'ını kaybettin.",
      type: CardType.kader,
      effectType: CardEffectType.loseStarsPercentage,
      value: 40, // cap ile uyumlu üst sınır
    ),
    GameCard(
      description:
          "Kötü bir yatırım yaptın. Yıldızlarının %30'unu kaybettin.",
      type: CardType.kader,
      effectType: CardEffectType.loseStarsPercentage,
      value: 30,
    ),

    // Küçük düz cezalar (minimum 0 koruması ile)
    GameCard(
      description:
          "Kahve faturası öde. 4 Yıldız. (Yıldızın yoksa 0 olur)",
      type: CardType.kader,
      effectType: CardEffectType.moneyChange,
      value: -4,
    ),
    GameCard(
      description:
          "Kırtasiye masrafı. 6 Yıldız öde. (Yetersiz bakiyede 0 olur)",
      type: CardType.kader,
      effectType: CardEffectType.moneyChange,
      value: -6,
    ),
    GameCard(
      description:
          "Kütüphane cezası. 8 Yıldız öde. (Yetersiz bakiyede 0 olur)",
      type: CardType.kader,
      effectType: CardEffectType.moneyChange,
      value: -8,
    ),
  ];
}
