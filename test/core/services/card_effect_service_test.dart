import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/constants/game_constants.dart';
import 'package:literature_board_game/core/services/card_effect_service.dart';
import 'package:literature_board_game/core/services/economy_service.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/models/game_card.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';

void main() {
  late CardEffectService service;

  setUp(() {
    service = const CardEffectService(EconomyService());
  });

  Player makePlayer({
    String id = 'p1',
    String name = 'Alice',
    int stars = 20,
    int position = 5,
    int turnsToSkip = 0,
  }) {
    return Player(
      id: id,
      name: name,
      color: Colors.blue,
      iconIndex: 1,
      stars: stars,
      position: position,
      turnsToSkip: turnsToSkip,
    );
  }

  List<Player> twoPlayers({
    int p1Stars = 20,
    int p2Stars = 20,
    int p1Position = 5,
  }) {
    return [
      makePlayer(id: 'p1', name: 'Alice', stars: p1Stars, position: p1Position),
      makePlayer(id: 'p2', name: 'Bob', stars: p2Stars, position: 10),
    ];
  }

  const sansCard = GameCard(
    description: 'Test card',
    type: CardType.sans,
    effectType: CardEffectType.moneyChange,
    value: 10,
  );

  // ═══════════════════════════════════════════════════════════════
  // moneyChange
  // ═══════════════════════════════════════════════════════════════

  group('moneyChange', () {
    test('positive value adds stars', () {
      final players = [makePlayer(stars: 20)];
      final card = sansCard; // +10
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].stars, 30);
      expect(result.movementOccurred, false);
      expect(result.rollAgain, false);
      expect(result.starsDelta, 10);
      expect(result.logs.first.type, 'success');
    });

    test('negative value subtracts stars when sufficient balance', () {
      final players = [makePlayer(stars: 20)];
      final card = GameCard(
        description: 'Pay',
        type: CardType.kader,
        effectType: CardEffectType.moneyChange,
        value: -8,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].stars, 12);
      expect(result.starsDelta, -8);
      expect(result.logs.first.type, 'error');
    });

    test('debt protection clamps to 0 and adds 1 turn penalty', () {
      final players = [makePlayer(stars: 5)];
      final card = GameCard(
        description: 'Big loss',
        type: CardType.kader,
        effectType: CardEffectType.moneyChange,
        value: -20,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].stars, 0);
      expect(result.updatedPlayers[0].turnsToSkip, 1);
      expect(result.starsDelta, -5);
      expect(result.logs.first.type, 'error');
      expect(result.logs.first.message, contains('ödeyemedi'));
    });

    test('debt protection with existing turnsToSkip stacks', () {
      final players = [makePlayer(stars: 3, turnsToSkip: 2)];
      final card = GameCard(
        description: 'Loss',
        type: CardType.kader,
        effectType: CardEffectType.moneyChange,
        value: -10,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].stars, 0);
      expect(result.updatedPlayers[0].turnsToSkip, 3);
    });

    test('negative value exactly equal to balance — no penalty', () {
      final players = [makePlayer(stars: 10)];
      final card = GameCard(
        description: 'Exact',
        type: CardType.kader,
        effectType: CardEffectType.moneyChange,
        value: -10,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].stars, 0);
      expect(result.updatedPlayers[0].turnsToSkip, 0);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // move (absolute)
  // ═══════════════════════════════════════════════════════════════

  group('move (absolute)', () {
    test('moves to target position', () {
      final players = [makePlayer(position: 5)];
      final card = GameCard(
        description: 'Go to 15',
        type: CardType.sans,
        effectType: CardEffectType.move,
        value: 15,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].position, 15);
      expect(result.movementOccurred, true);
      expect(result.starsDelta, 0);
    });

    test('passes start awards bonus when target < current', () {
      final players = [makePlayer(position: 20, stars: 10)];
      final card = GameCard(
        description: 'Go to 3',
        type: CardType.sans,
        effectType: CardEffectType.move,
        value: 3,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].position, 3);
      expect(result.updatedPlayers[0].stars, 10 + GameConstants.passingStartBonus);
      expect(result.movementOccurred, true);
      expect(result.logs.any((l) => l.message.contains('Başlangıçtan')), true);
    });

    test('moving TO start position does not award bonus', () {
      final players = [makePlayer(position: 20, stars: 10)];
      final card = GameCard(
        description: 'Go to start',
        type: CardType.sans,
        effectType: CardEffectType.move,
        value: 0,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].position, 0);
      expect(result.updatedPlayers[0].stars, 10);
      expect(result.starsDelta, 0);
    });

    test('value larger than board wraps via modulo', () {
      final players = [makePlayer(position: 5)];
      final card = GameCard(
        description: 'Big move',
        type: CardType.sans,
        effectType: CardEffectType.move,
        value: BoardConfig.boardSize + 3,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].position, 3);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // moveRelative
  // ═══════════════════════════════════════════════════════════════

  group('moveRelative', () {
    test('positive value moves forward', () {
      final players = [makePlayer(position: 5)];
      final card = GameCard(
        description: 'Forward 3',
        type: CardType.sans,
        effectType: CardEffectType.moveRelative,
        value: 3,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].position, 8);
      expect(result.movementOccurred, true);
      expect(result.logs.first.message, contains('ilerledi'));
    });

    test('negative value moves backward', () {
      final players = [makePlayer(position: 5)];
      final card = GameCard(
        description: 'Back 2',
        type: CardType.kader,
        effectType: CardEffectType.moveRelative,
        value: -2,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].position, 3);
      expect(result.movementOccurred, true);
      expect(result.logs.first.message, contains('geri gitti'));
    });

    test('forward wrap around passes start and awards bonus', () {
      final players = [makePlayer(position: 24, stars: 10)];
      final card = GameCard(
        description: 'Forward 5',
        type: CardType.sans,
        effectType: CardEffectType.moveRelative,
        value: 5,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      final expectedPos = (24 + 5) % BoardConfig.boardSize;
      expect(result.updatedPlayers[0].position, expectedPos);
      expect(result.updatedPlayers[0].stars, 10 + GameConstants.passingStartBonus);
    });

    test('backward wrap handles negative modulo correctly', () {
      final players = [makePlayer(position: 1)];
      final card = GameCard(
        description: 'Back 3',
        type: CardType.kader,
        effectType: CardEffectType.moveRelative,
        value: -3,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      final expectedPos = (1 - 3) % BoardConfig.boardSize + BoardConfig.boardSize;
      final normalizedPos = expectedPos % BoardConfig.boardSize;
      expect(result.updatedPlayers[0].position, normalizedPos);
      expect(result.movementOccurred, true);
    });

    test('backward move does not award start bonus', () {
      final players = [makePlayer(position: 1, stars: 10)];
      final card = GameCard(
        description: 'Back 3',
        type: CardType.kader,
        effectType: CardEffectType.moveRelative,
        value: -3,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].stars, 10);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // jail
  // ═══════════════════════════════════════════════════════════════

  group('jail', () {
    test('sends player to shopPosition with jailTurns skip', () {
      final players = [makePlayer(position: 5)];
      final card = GameCard(
        description: 'Go to jail',
        type: CardType.kader,
        effectType: CardEffectType.jail,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].position, BoardConfig.shopPosition);
      expect(result.updatedPlayers[0].turnsToSkip, GameConstants.jailTurns);
      expect(result.movementOccurred, true);
      expect(result.logs.first.type, 'error');
      expect(result.logs.first.message, contains('kütüphane nöbetine'));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // skipTurn
  // ═══════════════════════════════════════════════════════════════

  group('skipTurn', () {
    test('normal skip adds turnsToSkip', () {
      final players = [makePlayer(turnsToSkip: 0)];
      final card = GameCard(
        description: 'Bir tur bekle',
        type: CardType.kader,
        effectType: CardEffectType.skipTurn,
        value: 1,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].turnsToSkip, 1);
      expect(result.showPrinterIssue, false);
      expect(result.logs.first.message, contains('tur ceza'));
    });

    test('printer issue card (Mürekkep) sets showPrinterIssue flag', () {
      final players = [makePlayer(turnsToSkip: 0)];
      final card = GameCard(
        description: 'Mürekkepin bitti. Bir tur bekle.',
        type: CardType.kader,
        effectType: CardEffectType.skipTurn,
        value: 1,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.showPrinterIssue, true);
      expect(result.updatedPlayers[0].turnsToSkip, 0);
      expect(result.logs.first.message, contains('yazıcı sorunuyla'));
    });

    test('printer issue card (Yazıcı) sets showPrinterIssue flag', () {
      final players = [makePlayer(turnsToSkip: 0)];
      final card = GameCard(
        description: 'Yazıcı tıkandı! Bir tur beklemek zorundasın.',
        type: CardType.kader,
        effectType: CardEffectType.skipTurn,
        value: 1,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.showPrinterIssue, true);
      expect(result.updatedPlayers[0].turnsToSkip, 0);
    });

    test('skip stacks on existing turnsToSkip', () {
      final players = [makePlayer(turnsToSkip: 1)];
      final card = GameCard(
        description: 'Bekle',
        type: CardType.kader,
        effectType: CardEffectType.skipTurn,
        value: 2,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].turnsToSkip, 3);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // rollAgain
  // ═══════════════════════════════════════════════════════════════

  group('rollAgain', () {
    test('sets rollAgain flag and does not modify player state', () {
      final players = [makePlayer(stars: 20, position: 5)];
      final card = GameCard(
        description: 'Roll again',
        type: CardType.sans,
        effectType: CardEffectType.rollAgain,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.rollAgain, true);
      expect(result.movementOccurred, false);
      expect(result.updatedPlayers[0].stars, 20);
      expect(result.updatedPlayers[0].position, 5);
      expect(result.logs.first.type, 'info');
      expect(result.logs.first.message, contains('tekrar zar'));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // loseStarsPercentage
  // ═══════════════════════════════════════════════════════════════

  group('loseStarsPercentage', () {
    test('loses correct percentage of stars', () {
      final players = [makePlayer(stars: 100)];
      final card = GameCard(
        description: 'Lose 10%',
        type: CardType.kader,
        effectType: CardEffectType.loseStarsPercentage,
        value: 10,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].stars, 90);
      expect(result.starsDelta, -10);
    });

    test('percentage is capped by economy service maxPercentLoss', () {
      final players = [makePlayer(stars: 100)];
      final card = GameCard(
        description: 'Lose 80%',
        type: CardType.kader,
        effectType: CardEffectType.loseStarsPercentage,
        value: 80,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      final cappedPercent = 80.clamp(0, GameConstants.maxPercentLoss);
      final expectedLoss = (100 * cappedPercent / 100).round();
      expect(result.updatedPlayers[0].stars, 100 - expectedLoss);
    });

    test('zero stars loses nothing', () {
      final players = [makePlayer(stars: 0)];
      final card = GameCard(
        description: 'Lose 50%',
        type: CardType.kader,
        effectType: CardEffectType.loseStarsPercentage,
        value: 50,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].stars, 0);
      expect(result.starsDelta, 0);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // globalMoney
  // ═══════════════════════════════════════════════════════════════

  group('globalMoney', () {
    test('positive value takes from others', () {
      final players = twoPlayers(p1Stars: 10, p2Stars: 20);
      final card = GameCard(
        description: 'Collect',
        type: CardType.kader,
        effectType: CardEffectType.globalMoney,
        value: 5,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].stars, 15); // 10 + 5
      expect(result.updatedPlayers[1].stars, 15); // 20 - 5
      expect(result.logs.first.type, 'success');
      expect(result.logs.first.message, contains('herkesten'));
    });

    test('negative value gives to others', () {
      final players = twoPlayers(p1Stars: 20, p2Stars: 10);
      final card = GameCard(
        description: 'Pay all',
        type: CardType.kader,
        effectType: CardEffectType.globalMoney,
        value: -5,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].stars, 15); // 20 - 5
      expect(result.updatedPlayers[1].stars, 15); // 10 + 5
      expect(result.logs.first.type, 'error');
      expect(result.logs.first.message, contains('ödedi'));
    });

    test('other player insufficient stars — takes what they have', () {
      final players = twoPlayers(p1Stars: 10, p2Stars: 2);
      final card = GameCard(
        description: 'Collect 5 from each',
        type: CardType.kader,
        effectType: CardEffectType.globalMoney,
        value: 5,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[1].stars, 0);
      expect(result.updatedPlayers[0].stars, 12); // 10 + 2
    });

    test('other player has zero stars — transfers nothing', () {
      final players = twoPlayers(p1Stars: 10, p2Stars: 0);
      final card = GameCard(
        description: 'Collect',
        type: CardType.kader,
        effectType: CardEffectType.globalMoney,
        value: 5,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].stars, 10); // unchanged
      expect(result.updatedPlayers[1].stars, 0);
    });

    test('multiple other players all contribute', () {
      final players = [
        makePlayer(id: 'p1', name: 'Alice', stars: 10, position: 0),
        makePlayer(id: 'p2', name: 'Bob', stars: 20, position: 5),
        makePlayer(id: 'p3', name: 'Carol', stars: 15, position: 10),
      ];
      final card = GameCard(
        description: 'Collect 3 each',
        type: CardType.kader,
        effectType: CardEffectType.globalMoney,
        value: 3,
      );
      final result = service.apply(
        card: card,
        players: players,
        currentPlayerIndex: 0,
      );

      expect(result.updatedPlayers[0].stars, 16); // 10 + 3 + 3
      expect(result.updatedPlayers[1].stars, 17); // 20 - 3
      expect(result.updatedPlayers[2].stars, 12); // 15 - 3
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // isBot log prefix
  // ═══════════════════════════════════════════════════════════════

  group('bot prefix', () {
    test('human logs have no bot prefix', () {
      final players = [makePlayer(stars: 20)];
      final result = service.apply(
        card: sansCard,
        players: players,
        currentPlayerIndex: 0,
        isBot: false,
      );

      expect(result.logs.first.message.startsWith('🤖 Bot:'), false);
    });

    test('bot logs have bot prefix', () {
      final players = [makePlayer(stars: 20)];
      final result = service.apply(
        card: sansCard,
        players: players,
        currentPlayerIndex: 0,
        isBot: true,
      );

      expect(result.logs.first.message, startsWith('🤖 Bot:'));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // does not mutate input
  // ═══════════════════════════════════════════════════════════════

  group('immutability', () {
    test('input players list is not mutated', () {
      final original = [makePlayer(stars: 20)];
      final originalStars = original[0].stars;
      service.apply(
        card: sansCard,
        players: original,
        currentPlayerIndex: 0,
      );

      expect(original[0].stars, originalStars);
    });
  });
}
