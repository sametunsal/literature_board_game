import '../models/game_card.dart';
import '../models/game_enums.dart';

class GameCards {
  static const List<GameCard> sansCards = [
    GameCard(
      description: "Roman yarışmasında birinci oldun! 200 Yıldız kazandın.",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: 200,
    ),
    GameCard(
      description: "İlham perilerin kaçtı, yazamıyorsun. 50 Yıldız kaybettin.",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: -50,
    ),
    GameCard(
      description: "Çok satanlar listesine girdin! 100 Yıldız telif kazandın.",
      type: CardType.sans,
      effectType: CardEffectType.moneyChange,
      value: 100,
    ),
    GameCard(
      description: "Başlangıç noktasına ilerle.",
      type: CardType.sans,
      effectType: CardEffectType.move,
      value: 0,
    ),
    GameCard(
      description: "Kütüphanede gürültü yaptın! Kütüphane Nöbetine git.",
      type: CardType.sans,
      effectType: CardEffectType.jail,
    ),
  ];

  static const List<GameCard> kaderCards = [
    GameCard(
      description:
          "Tüm yazarların kalemleri kırıldı. Her oyuncu sana 50 Yıldız öder.",
      type: CardType.kader,
      effectType: CardEffectType.globalMoney,
      value: 50,
    ),
    GameCard(
      description:
          "Matbaa makineleri bozuldu. Tamir için herkese 20 Yıldız öde.",
      type: CardType.kader,
      effectType: CardEffectType.globalMoney,
      value: -20,
    ),
    GameCard(
      description:
          "Edebiyat festivaline davetlisin. İmza Gününe (20. Kare) ilerle.",
      type: CardType.kader,
      effectType: CardEffectType.move,
      value: 20,
    ),
    GameCard(
      description: "Vergi memurları kapıda! 100 Yıldız vergi öde.",
      type: CardType.kader,
      effectType: CardEffectType.moneyChange,
      value: -100,
    ),
  ];
}
