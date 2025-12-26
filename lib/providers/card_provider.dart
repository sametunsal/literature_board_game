import '../models/card.dart';

// ŞANS cards provider
List<Card> generateSansCards() {
  return [
    Card(
      id: 'sans1',
      type: CardType.sans,
      description: 'Bankadan 50 yıldız ödül aldın!',
      effect: CardEffect.gainStars,
      starAmount: 50,
    ),
    Card(
      id: 'sans2',
      type: CardType.sans,
      description: 'Edebiyat yarışmasında birinci oldun! +80 yıldız',
      effect: CardEffect.gainStars,
      starAmount: 80,
    ),
    Card(
      id: 'sans3',
      type: CardType.sans,
      description: 'Kitap fuarında satış rekoru kırdın! +100 yıldız',
      effect: CardEffect.gainStars,
      starAmount: 100,
    ),
    Card(
      id: 'sans4',
      type: CardType.sans,
      description: 'Yazın ödülü kazandın! +60 yıldız',
      effect: CardEffect.gainStars,
      starAmount: 60,
    ),
    Card(
      id: 'sans5',
      type: CardType.sans,
      description: 'En çok satan yazar oldun! +90 yıldız',
      effect: CardEffect.gainStars,
      starAmount: 90,
    ),
    Card(
      id: 'sans6',
      type: CardType.sans,
      description: 'Kitabına dizi çekildi! +70 yıldız',
      effect: CardEffect.gainStars,
      starAmount: 70,
    ),
    Card(
      id: 'sans7',
      type: CardType.sans,
      description: 'Yabancı dile çeviri yapıldı! +55 yıldız',
      effect: CardEffect.gainStars,
      starAmount: 55,
    ),
    Card(
      id: 'sans8',
      type: CardType.sans,
      description: 'Sırada sıra yok! Bir sonraki soru kolay olacak.',
      effect: CardEffect.easyQuestionNext,
    ),
    Card(
      id: 'sans9',
      type: CardType.sans,
      description: 'Yazın festivaline davet edildin! Ücretsiz tur.',
      effect: CardEffect.freeTurn,
    ),
    Card(
      id: 'sans10',
      type: CardType.sans,
      description: 'Vergi indirim kartı aldın. Sonraki vergi ödemeyi atla.',
      effect: CardEffect.skipNextTax,
    ),
  ];
}

// KADER cards provider
List<Card> generateKaderCards() {
  return [
    Card(
      id: 'kader1',
      type: CardType.kader,
      description: 'Küresel ekonomik kriz! Tüm oyuncular 30 yıldız kaybeder.',
      effect: CardEffect.allPlayersLoseStars,
      starAmount: 30,
    ),
    Card(
      id: 'kader2',
      type: CardType.kader,
      description: 'Yazın destek fonu! Tüm oyuncular 40 yıldız kazanır.',
      effect: CardEffect.allPlayersGainStars,
      starAmount: 40,
    ),
    Card(
      id: 'kader3',
      type: CardType.kader,
      description: 'Piracy krizi! Tüm yayınevi sahipleri 50 yıldız kaybeder.',
      effect: CardEffect.publisherOwnersLose,
      starAmount: 50,
      tileId: 1, // Placeholder - affects all publishers
    ),
    Card(
      id: 'kader4',
      type: CardType.kader,
      description: 'Yazın bakanlığı desteği! Tüm oyuncular 60 yıldız kazanır.',
      effect: CardEffect.allPlayersGainStars,
      starAmount: 60,
    ),
    Card(
      id: 'kader5',
      type: CardType.kader,
      description: 'Siber saldırı! Tüm oyuncular 20 yıldız kaybeder.',
      effect: CardEffect.allPlayersLoseStars,
      starAmount: 20,
    ),
    Card(
      id: 'kader6',
      type: CardType.kader,
      description: 'En zengin yazar, diğerlerini desteklemeye karar verdi! Herkese 25 yıldız dağıtır.',
      effect: CardEffect.richPlayerPays,
      starAmount: 25,
    ),
    Card(
      id: 'kader7',
      type: CardType.kader,
      description: 'Vergi affı! Tüm oyuncular vergi ödemelerini atlar.',
      effect: CardEffect.taxWaiver,
    ),
    Card(
      id: 'kader8',
      type: CardType.kader,
      description: 'Edebiyat eğitimi kampanyası! Bir sonraki soru kolay olacak.',
      effect: CardEffect.allPlayersEasyQuestion,
    ),
    Card(
      id: 'kader9',
      type: CardType.kader,
      description: 'Pandemi! Tüm oyuncular 35 yıldız kaybeder.',
      effect: CardEffect.allPlayersLoseStars,
      starAmount: 35,
    ),
    Card(
      id: 'kader10',
      type: CardType.kader,
      description: 'Kitap okuma seferberliği! Tüm oyuncular 45 yıldız kazanır.',
      effect: CardEffect.allPlayersGainStars,
      starAmount: 45,
    ),
  ];
}
