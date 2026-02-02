import '../models/game_card.dart';
import '../models/game_enums.dart';

class GameCards {
  // --- ŞANS KARTLARI (Ödül Odaklı - Start-from-Zero Economy) ---
  static const List<GameCard> sansCards = [
    // Telif ödülleri (düşük miktarlarda, 0'dan başlayan oyuncular için)
    GameCard(
      description:
          "Telif hakkı ödemesi aldın! +10 Yıldız kazandın.",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: 10,
    ),
    GameCard(
      description:
          "Küçük bir edebi ödül kazandın. +15 Yıldız!",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: 15,
    ),
    GameCard(
      description:
          "Makalen dergide yayınlandı. +20 Yıldız kazandın.",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: 20,
    ),
    GameCard(
      description:
          "İlham perisi geldi! 2 kare ileri git.",
      type: CardType.sans,
      effectType: CardEffectType.moveRelative,
      value: 2,
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
      value: 10,
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
          "Yayınevi送nden küçük bir avans geldi. +15 Yıldız!",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: 15,
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
      value: -2,
    ),
    GameCard(
      description:
          "Eserin eleştirildi. 3 kare geri çekil.",
      type: CardType.kader,
      effectType: CardEffectType.moveRelative,
      value: -3,
    ),

    // Yüzdeli kayıplar (0 olduğunda güvenli)
    GameCard(
      description:
          "Cüzdanını düşürdün. Mevcut yıldızlarının yarısını kaybettin.",
      type: CardType.kader,
      effectType: CardEffectType.loseStarsPercentage,
      value: 50, // 50% kayıp
    ),
    GameCard(
      description:
          "Kötü bir yatırım yaptın. Yıldızlarının %40'ını kaybettin.",
      type: CardType.kader,
      effectType: CardEffectType.loseStarsPercentage,
      value: 40, // 40% kayıp
    ),

    // Küçük düz cezalar (minimum 0 koruması ile)
    GameCard(
      description:
          "Kahve faturası öde. 5 Yıldız. (Yıldızın yoksa 0 olur)",
      type: CardType.kader,
      effectType: CardEffectType.moneyChange,
      value: -5,
    ),
    GameCard(
      description:
          "Kırtasiye masrafı. 8 Yıldız öde. (Yetersiz bakiyede 0 olur)",
      type: CardType.kader,
      effectType: CardEffectType.moneyChange,
      value: -8,
    ),
    GameCard(
      description:
          "Kütüphane cezası. 10 Yıldız öde. (Yetersiz bakiyede 0 olur)",
      type: CardType.kader,
      effectType: CardEffectType.moneyChange,
      value: -10,
    ),
  ];
}
