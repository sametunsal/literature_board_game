import '../models/card.dart';

/// Static card data for Sans (Chance) and Kader (Fate) cards
/// Total: 20 cards (10 Sans, 10 Kader)

class GameCards {
  static const List<Card> sansCards = [
    // Positive effects
    Card(
      id: 'sans_1',
      type: CardType.sans,
      description: 'Yazın çok sattı! +300 Puan kazan.',
      effect: CardEffect.gainStars,
      starAmount: 300,
    ),
    Card(
      id: 'sans_2',
      type: CardType.sans,
      description: 'Kitap fuarına başarıyla katıldın! +200 Puan.',
      effect: CardEffect.gainStars,
      starAmount: 200,
    ),
    Card(
      id: 'sans_3',
      type: CardType.sans,
      description: 'Edebiyat ödülü aldın! +150 Puan.',
      effect: CardEffect.gainStars,
      starAmount: 150,
    ),
    Card(
      id: 'sans_4',
      type: CardType.sans,
      description: 'Bir sonraki vergiyi ödememe hakkı kazandın!',
      effect: CardEffect.skipNextTax,
    ),
    Card(
      id: 'sans_5',
      type: CardType.sans,
      description: 'Ücretsiz tur hakkı kazandın! Bir sonraki turunu atla.',
      effect: CardEffect.freeTurn,
    ),
    Card(
      id: 'sans_6',
      type: CardType.sans,
      description: 'Bir sonraki soru kolay olacak!',
      effect: CardEffect.easyQuestionNext,
    ),
    Card(
      id: 'sans_7',
      type: CardType.sans,
      description: 'Yayınevi toplantısına geç kaldın! 3 kare ileri git.',
      effect: CardEffect.loseStars,
      starAmount: 100, // Penalty
    ),

    // Negative effects
    Card(
      id: 'sans_8',
      type: CardType.sans,
      description: 'Telif hakkı ihlali! -500 Puan öde.',
      effect: CardEffect.loseStars,
      starAmount: -500,
    ),
    Card(
      id: 'sans_9',
      type: CardType.sans,
      description: 'Kitap hırsızlığı! -300 Puan kaybettin.',
      effect: CardEffect.loseStars,
      starAmount: -300,
    ),
    Card(
      id: 'sans_10',
      type: CardType.sans,
      description: 'Kütüphaneye (Başlangıç) geri dön.',
      effect: CardEffect.loseStars,
      starAmount: 0, // No star change, just movement
    ),
  ];

  static const List<Card> kaderCards = [
    // Positive effects (global)
    Card(
      id: 'kader_1',
      type: CardType.kader,
      description: 'Tüm oyunculara +100 Puan!',
      effect: CardEffect.allPlayersGainStars,
      starAmount: 100,
    ),
    Card(
      id: 'kader_2',
      type: CardType.kader,
      description: 'Tüm oyunculara bir sonraki soru kolay olacak!',
      effect: CardEffect.allPlayersEasyQuestion,
    ),
    Card(
      id: 'kader_3',
      type: CardType.kader,
      description: 'Bir sonraki vergi ödemesi herkese geçerli!',
      effect: CardEffect.taxWaiver,
    ),
    Card(
      id: 'kader_4',
      type: CardType.kader,
      description: 'En zengin oyuncu -200 Puan öde!',
      effect: CardEffect.richPlayerPays,
      starAmount: -200,
    ),
    Card(
      id: 'kader_5',
      type: CardType.kader,
      description: 'Yayınevi sahiplerine -150 Puan kaybettin!',
      effect: CardEffect.publisherOwnersLose,
      starAmount: -150,
    ),

    // Negative effects (global)
    Card(
      id: 'kader_6',
      type: CardType.kader,
      description: 'Tüm oyunculardan -100 Puan alındı!',
      effect: CardEffect.allPlayersLoseStars,
      starAmount: -100,
    ),
    Card(
      id: 'kader_7',
      type: CardType.kader,
      description: 'İlham perilerin kaçtı! 1 tur bekle.',
      effect: CardEffect.loseStars,
      starAmount: 0, // No star change, turn skip
    ),
    Card(
      id: 'kader_8',
      type: CardType.kader,
      description: 'Tüm oyunculara kitap fuarına davet! +50 Puan.',
      effect: CardEffect.allPlayersGainStars,
      starAmount: 50,
    ),
    Card(
      id: 'kader_9',
      type: CardType.kader,
      description: 'Yayınevi toplantısına geç kaldın! 3 kare ileri git.',
      effect: CardEffect.loseStars,
      starAmount: 0, // Movement penalty
    ),
    Card(
      id: 'kader_10',
      type: CardType.kader,
      description: 'Kütüphaneye (Başlangıç) geri dön.',
      effect: CardEffect.loseStars,
      starAmount: 0, // Movement penalty
    ),
  ];

  /// Get cards by type
  static List<Card> getCardsByType(CardType type) {
    switch (type) {
      case CardType.sans:
        return sansCards;
      case CardType.kader:
        return kaderCards;
    }
  }
}
