import '../models/game_card.dart';
import '../models/game_enums.dart';

class GameCards {
  // --- ŞANS KARTLARI (Kişisel Olaylar) ---
  static const List<GameCard> sansCards = [
    GameCard(
      description:
          "Romanın 'En Çok Satanlar' listesine girdi! 150 Yıldız telif kazandın.",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: 150,
    ),
    GameCard(
      description:
          "İlham perilerin kaçtı, yazamıyorsun. Moral düzeltmek için 50 Yıldız harcadın.",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: -50,
    ),
    GameCard(
      description:
          "Edebiyat dergisine yazdığın makale ödül aldı. 100 Yıldız kazandın.",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: 100,
    ),
    GameCard(
      description:
          "Kıraathanede çok gürültü yaptın! Doğruca Kıraathane Nöbetine git (Başlangıçtan geçsen bile para alamazsın).",
      type: CardType.sans,
      effectType: CardEffectType.jail,
    ),
    GameCard(
      description:
          "Yayınevi seni acil toplantıya çağırdı. 1. Yayınevi (5. Kare) kutusuna ilerle.",
      type: CardType.sans,
      effectType: CardEffectType.move,
      value: 5,
    ),
    GameCard(
      description: "Başlangıç noktasına ilerle.",
      type: CardType.sans,
      effectType: CardEffectType.move,
      value: 0,
    ),
    GameCard(
      description:
          "Kitap fuarına davetlisin. İmza Günü (20. Kare) kutusuna ilerle.",
      type: CardType.sans,
      effectType: CardEffectType.move,
      value: 20,
    ),
    GameCard(
      description:
          "Bilgisayarın bozuldu, yazdığın son bölüm silindi. Tamir masrafı: 80 Yıldız.",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: -80,
    ),
  ];

  // --- KADER KARTLARI (Global/Toplumsal Olaylar) ---
  static const List<GameCard> kaderCards = [
    GameCard(
      description:
          "Kağıt fiyatlarına zam geldi! Matbaa masrafları için herkese 20 Yıldız öde.",
      type: CardType.kader,
      effectType: CardEffectType.globalMoney, // Herkese öde
      value: -20,
    ),
    GameCard(
      description:
          "Tüm yazarların kalemleri kırıldı, sadece senin kalemin sağlam. Her oyuncu sana 30 Yıldız öder.",
      type: CardType.kader,
      effectType: CardEffectType.globalMoney, // Herkesten al
      value: 30,
    ),
    GameCard(
      description:
          "Korsan kitap baskını! Korsan kitapların toplatıldı. 100 Yıldız ceza öde.",
      type: CardType.kader,
      effectType: CardEffectType.moneyChange,
      value: -100,
    ),
    GameCard(
      description:
          "Kültür Bakanlığı'ndan teşvik fonu çıktı. 200 Yıldız hibe aldın.",
      type: CardType.kader,
      effectType: CardEffectType.moneyChange,
      value: 200,
    ),
    GameCard(
      description: "Edebiyat Vakfı'na bağış yapman gerekiyor. 50 Yıldız öde.",
      type: CardType.kader,
      effectType: CardEffectType.moneyChange,
      value: -50,
    ),
    GameCard(
      description:
          "Yılın Yazarı seçildin! Her oyuncu seni tebrik etmek için 10 Yıldız verir.",
      type: CardType.kader,
      effectType: CardEffectType.globalMoney,
      value: 10,
    ),
  ];
}
