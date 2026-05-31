import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/services/book_progression_service.dart';
import 'package:literature_board_game/models/book.dart';
import 'package:literature_board_game/models/book_level.dart';
import 'package:literature_board_game/models/book_ownership.dart';
import 'package:literature_board_game/models/difficulty.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';

void main() {
  const service = BookProgressionService();
  const book = Book(
    id: 'intibah',
    title: 'Intibah',
    author: 'Namik Kemal',
    category: QuestionCategory.turkEdebiyatindaIlkler,
    tilePosition: 1,
    baskiCostAkce: 5,
    ciltCostAkce: 10,
  );

  Player makePlayer({
    required String id,
    int akce = 0,
    MasteryLevel masteryLevel = MasteryLevel.novice,
  }) {
    return Player(
      id: id,
      name: 'Player $id',
      color: Colors.blue,
      iconIndex: 0,
      stars: akce,
      categoryLevels: {book.category.name: masteryLevel.value},
    );
  }

  Map<String, BookOwnership> ownedBy({
    required String playerId,
    required BookLevel level,
  }) {
    return {
      book.id: BookOwnership(
        bookId: book.id,
        ownerPlayerId: playerId,
        level: level,
      ),
    };
  }

  group('BookProgressionService', () {
    test('unowned book + correct answer acquires Telif', () {
      final player = makePlayer(id: 'p1');

      final result = service.apply(
        book: book,
        players: [player],
        currentPlayerId: player.id,
        ownerships: const {},
        isCorrect: true,
        difficulty: Difficulty.easy,
      );

      expect(result.actionType, BookProgressionActionType.acquiredTelif);
      expect(result.updatedOwnerships[book.id]?.ownerPlayerId, player.id);
      expect(result.updatedOwnerships[book.id]?.level, BookLevel.telif);
      expect(result.updatedPlayers.single.akce, player.akce);
      expect(result.akceDelta, 0);
    });

    test('unowned book + wrong answer does not acquire Telif', () {
      final player = makePlayer(id: 'p1');

      final result = service.apply(
        book: book,
        players: [player],
        currentPlayerId: player.id,
        ownerships: const {},
        isCorrect: false,
        difficulty: Difficulty.easy,
      );

      expect(result.actionType, BookProgressionActionType.noAction);
      expect(result.updatedOwnerships, isEmpty);
      expect(result.updatedPlayers.single.akce, player.akce);
    });

    test('own Telif + enough Akce + correct answer upgrades to Baski', () {
      final player = makePlayer(id: 'p1', akce: 5);

      final result = service.apply(
        book: book,
        players: [player],
        currentPlayerId: player.id,
        ownerships: ownedBy(playerId: player.id, level: BookLevel.telif),
        isCorrect: true,
        difficulty: Difficulty.medium,
      );

      expect(result.actionType, BookProgressionActionType.upgradedToBaski);
      expect(result.updatedOwnerships[book.id]?.level, BookLevel.baski);
      expect(result.updatedPlayers.single.akce, 0);
      expect(result.akceDelta, -5);
    });

    test('own Telif + enough Akce + wrong answer spends but stays Telif', () {
      final player = makePlayer(id: 'p1', akce: 7);

      final result = service.apply(
        book: book,
        players: [player],
        currentPlayerId: player.id,
        ownerships: ownedBy(playerId: player.id, level: BookLevel.telif),
        isCorrect: false,
        difficulty: Difficulty.medium,
      );

      expect(result.actionType, BookProgressionActionType.failedUpgrade);
      expect(result.updatedOwnerships[book.id]?.level, BookLevel.telif);
      expect(result.updatedPlayers.single.akce, 2);
      expect(result.akceDelta, -5);
    });

    test('own Baski + enough Akce + Kalfa + correct Hard upgrades to Cilt', () {
      final player = makePlayer(
        id: 'p1',
        akce: 10,
        masteryLevel: MasteryLevel.kalfa,
      );

      final result = service.apply(
        book: book,
        players: [player],
        currentPlayerId: player.id,
        ownerships: ownedBy(playerId: player.id, level: BookLevel.baski),
        isCorrect: true,
        difficulty: Difficulty.hard,
      );

      expect(result.actionType, BookProgressionActionType.upgradedToCilt);
      expect(result.updatedOwnerships[book.id]?.level, BookLevel.cilt);
      expect(result.updatedPlayers.single.akce, 0);
      expect(result.akceDelta, -10);
    });

    test('own Baski + enough Akce + Usta + correct Hard upgrades to Cilt', () {
      final player = makePlayer(
        id: 'p1',
        akce: 12,
        masteryLevel: MasteryLevel.usta,
      );

      final result = service.apply(
        book: book,
        players: [player],
        currentPlayerId: player.id,
        ownerships: ownedBy(playerId: player.id, level: BookLevel.baski),
        isCorrect: true,
        difficulty: Difficulty.hard,
      );

      expect(result.actionType, BookProgressionActionType.upgradedToCilt);
      expect(result.updatedOwnerships[book.id]?.level, BookLevel.cilt);
      expect(result.updatedPlayers.single.akce, 2);
    });

    test(
      'own Baski + enough Akce + non-Hard answer spends but stays Baski',
      () {
        final player = makePlayer(
          id: 'p1',
          akce: 12,
          masteryLevel: MasteryLevel.kalfa,
        );

        final result = service.apply(
          book: book,
          players: [player],
          currentPlayerId: player.id,
          ownerships: ownedBy(playerId: player.id, level: BookLevel.baski),
          isCorrect: true,
          difficulty: Difficulty.medium,
        );

        expect(result.actionType, BookProgressionActionType.failedUpgrade);
        expect(result.updatedOwnerships[book.id]?.level, BookLevel.baski);
        expect(result.updatedPlayers.single.akce, 2);
        expect(result.akceDelta, -10);
      },
    );

    test('own Baski + enough Akce + below Kalfa spends but stays Baski', () {
      final player = makePlayer(
        id: 'p1',
        akce: 12,
        masteryLevel: MasteryLevel.cirak,
      );

      final result = service.apply(
        book: book,
        players: [player],
        currentPlayerId: player.id,
        ownerships: ownedBy(playerId: player.id, level: BookLevel.baski),
        isCorrect: true,
        difficulty: Difficulty.hard,
      );

      expect(result.actionType, BookProgressionActionType.failedUpgrade);
      expect(result.updatedOwnerships[book.id]?.level, BookLevel.baski);
      expect(result.updatedPlayers.single.akce, 2);
      expect(result.akceDelta, -10);
    });

    test('insufficient Akce causes no attempt, no spend, and no upgrade', () {
      final player = makePlayer(id: 'p1', akce: 4);

      final result = service.apply(
        book: book,
        players: [player],
        currentPlayerId: player.id,
        ownerships: ownedBy(playerId: player.id, level: BookLevel.telif),
        isCorrect: true,
        difficulty: Difficulty.medium,
      );

      expect(result.actionType, BookProgressionActionType.insufficientAkce);
      expect(result.updatedOwnerships[book.id]?.level, BookLevel.telif);
      expect(result.updatedPlayers.single.akce, 4);
      expect(result.akceDelta, 0);
    });

    test('already Cilt causes no upgrade or spend', () {
      final player = makePlayer(
        id: 'p1',
        akce: 20,
        masteryLevel: MasteryLevel.usta,
      );

      final result = service.apply(
        book: book,
        players: [player],
        currentPlayerId: player.id,
        ownerships: ownedBy(playerId: player.id, level: BookLevel.cilt),
        isCorrect: true,
        difficulty: Difficulty.hard,
      );

      expect(result.actionType, BookProgressionActionType.alreadyCilt);
      expect(result.updatedOwnerships[book.id]?.level, BookLevel.cilt);
      expect(result.updatedPlayers.single.akce, 20);
      expect(result.akceDelta, 0);
    });

    test('opponent-owned book + correct answer causes no payment', () {
      final current = makePlayer(id: 'p1', akce: 5);
      final owner = makePlayer(id: 'p2', akce: 10);

      final result = service.apply(
        book: book,
        players: [current, owner],
        currentPlayerId: current.id,
        ownerships: ownedBy(playerId: owner.id, level: BookLevel.cilt),
        isCorrect: true,
        difficulty: Difficulty.hard,
      );

      expect(
        result.actionType,
        BookProgressionActionType.opponentCorrectNoPayment,
      );
      expect(result.updatedPlayers[0].akce, 5);
      expect(result.updatedPlayers[1].akce, 10);
      expect(result.royaltyPaid, 0);
    });

    test('wrong answer on opponent Telif pays royalty 1 to owner', () {
      final current = makePlayer(id: 'p1', akce: 5);
      final owner = makePlayer(id: 'p2', akce: 10);

      final result = service.apply(
        book: book,
        players: [current, owner],
        currentPlayerId: current.id,
        ownerships: ownedBy(playerId: owner.id, level: BookLevel.telif),
        isCorrect: false,
        difficulty: Difficulty.easy,
      );

      expect(result.actionType, BookProgressionActionType.royaltyPaid);
      expect(result.updatedPlayers[0].akce, 4);
      expect(result.updatedPlayers[1].akce, 11);
      expect(result.royaltyPaid, 1);
      expect(result.akceDelta, -1);
    });

    test('wrong answer on opponent Baski pays royalty 2 to owner', () {
      final current = makePlayer(id: 'p1', akce: 5);
      final owner = makePlayer(id: 'p2', akce: 10);

      final result = service.apply(
        book: book,
        players: [current, owner],
        currentPlayerId: current.id,
        ownerships: ownedBy(playerId: owner.id, level: BookLevel.baski),
        isCorrect: false,
        difficulty: Difficulty.medium,
      );

      expect(result.updatedPlayers[0].akce, 3);
      expect(result.updatedPlayers[1].akce, 12);
      expect(result.royaltyPaid, 2);
    });

    test('wrong answer on opponent Cilt pays royalty 3 to owner', () {
      final current = makePlayer(id: 'p1', akce: 5);
      final owner = makePlayer(id: 'p2', akce: 10);

      final result = service.apply(
        book: book,
        players: [current, owner],
        currentPlayerId: current.id,
        ownerships: ownedBy(playerId: owner.id, level: BookLevel.cilt),
        isCorrect: false,
        difficulty: Difficulty.hard,
      );

      expect(result.updatedPlayers[0].akce, 2);
      expect(result.updatedPlayers[1].akce, 13);
      expect(result.royaltyPaid, 3);
    });

    test('royalty payment cannot make current player negative', () {
      final current = makePlayer(id: 'p1', akce: 1);
      final owner = makePlayer(id: 'p2', akce: 10);

      final result = service.apply(
        book: book,
        players: [current, owner],
        currentPlayerId: current.id,
        ownerships: ownedBy(playerId: owner.id, level: BookLevel.cilt),
        isCorrect: false,
        difficulty: Difficulty.hard,
      );

      expect(result.updatedPlayers[0].akce, 0);
      expect(result.updatedPlayers[1].akce, 11);
      expect(result.royaltyPaid, 1);
      expect(result.akceDelta, -1);
    });
  });
}
