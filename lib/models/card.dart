enum CardType {
  sans, // Chance cards (personal effects)
  kader, // Fate cards (global effects)
}

enum CardEffect {
  // Sans card effects (personal)
  gainStars,
  loseStars,
  skipNextTax,
  freeTurn,
  easyQuestionNext,

  // Kader card effects (global)
  allPlayersGainStars,
  allPlayersLoseStars,
  publisherOwnersLose,
  taxWaiver,
  richPlayerPays,
  allPlayersEasyQuestion,
}

class Card {
  final String id;
  final CardType type;
  final String description;
  final CardEffect effect;
  final int? starAmount; // Amount for gain/lose effects
  final int? tileId; // For tile-specific effects (e.g., publisher)

  const Card({
    required this.id,
    required this.type,
    required this.description,
    required this.effect,
    this.starAmount,
    this.tileId,
  });

  // Check if card affects all players
  bool get affectsAllPlayers {
    return effect == CardEffect.allPlayersGainStars ||
        effect == CardEffect.allPlayersLoseStars ||
        effect == CardEffect.taxWaiver ||
        effect == CardEffect.allPlayersEasyQuestion;
  }

  // Check if card affects only current player
  bool get affectsCurrentPlayerOnly {
    return effect == CardEffect.gainStars ||
        effect == CardEffect.loseStars ||
        effect == CardEffect.skipNextTax ||
        effect == CardEffect.freeTurn ||
        effect == CardEffect.easyQuestionNext;
  }

  // Check if card affects specific tile owners
  bool get affectsTileOwners {
    return effect == CardEffect.publisherOwnersLose;
  }

  // Check if card affects richest player
  bool get affectsRichestPlayer {
    return effect == CardEffect.richPlayerPays;
  }

  // Check if effect is positive for player
  bool get isPositiveForPlayer {
    return effect == CardEffect.gainStars ||
        effect == CardEffect.skipNextTax ||
        effect == CardEffect.freeTurn ||
        effect == CardEffect.easyQuestionNext ||
        effect == CardEffect.allPlayersGainStars ||
        effect == CardEffect.taxWaiver;
  }

  // Check if effect is negative for player
  bool get isNegativeForPlayer {
    return effect == CardEffect.loseStars ||
        effect == CardEffect.allPlayersLoseStars ||
        effect == CardEffect.publisherOwnersLose ||
        effect == CardEffect.richPlayerPays;
  }
}
