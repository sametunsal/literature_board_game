import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/services/win_condition_service.dart';
import 'package:literature_board_game/models/book_level.dart';
import 'package:literature_board_game/models/book_ownership.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';

void main() {
  const service = WinConditionService();

  Player makePlayer({String id = 'p1', int ustaCategories = 0}) {
    final levels = <String, int>{};
    for (final category in QuestionCategory.values.take(ustaCategories)) {
      levels[category.name] = MasteryLevel.usta.value;
    }

    return Player(
      id: id,
      name: 'Player $id',
      color: Colors.blue,
      iconIndex: 0,
      categoryLevels: levels,
    );
  }

  Map<String, BookOwnership> makeOwnerships({
    required String ownerPlayerId,
    required int ownedBooks,
    required int ciltBooks,
    int otherPlayerBooks = 0,
  }) {
    final ownerships = <String, BookOwnership>{};

    for (var i = 0; i < ownedBooks; i++) {
      final level = i < ciltBooks ? BookLevel.cilt : BookLevel.telif;
      final bookId = 'book_$i';
      ownerships[bookId] = BookOwnership(
        bookId: bookId,
        ownerPlayerId: ownerPlayerId,
        level: level,
      );
    }

    for (var i = 0; i < otherPlayerBooks; i++) {
      final bookId = 'other_book_$i';
      ownerships[bookId] = BookOwnership(
        bookId: bookId,
        ownerPlayerId: 'p2',
        level: BookLevel.cilt,
      );
    }

    return ownerships;
  }

  group('WinConditionService', () {
    test('no ownerships = no win', () {
      final player = makePlayer(ustaCategories: 2);

      expect(service.ownedBookCount(playerId: player.id, ownerships: {}), 0);
      expect(service.ciltBookCount(playerId: player.id, ownerships: {}), 0);
      expect(service.ustaCategoryCount(player), 2);
      expect(service.hasWon(player: player, ownerships: {}), isFalse);
    });

    test('enough books but not enough cilt = no win', () {
      final player = makePlayer(ustaCategories: 2);
      final ownerships = makeOwnerships(
        ownerPlayerId: player.id,
        ownedBooks: 5,
        ciltBooks: 1,
      );

      expect(
        service.ownedBookCount(playerId: player.id, ownerships: ownerships),
        5,
      );
      expect(
        service.ciltBookCount(playerId: player.id, ownerships: ownerships),
        1,
      );
      expect(service.hasWon(player: player, ownerships: ownerships), isFalse);
    });

    test('enough cilt but not enough usta = no win', () {
      final player = makePlayer(ustaCategories: 1);
      final ownerships = makeOwnerships(
        ownerPlayerId: player.id,
        ownedBooks: 5,
        ciltBooks: 2,
      );

      expect(
        service.ciltBookCount(playerId: player.id, ownerships: ownerships),
        2,
      );
      expect(service.ustaCategoryCount(player), 1);
      expect(service.hasWon(player: player, ownerships: ownerships), isFalse);
    });

    test('exact threshold wins', () {
      final player = makePlayer(ustaCategories: 2);
      final ownerships = makeOwnerships(
        ownerPlayerId: player.id,
        ownedBooks: 5,
        ciltBooks: 2,
      );

      expect(
        service.ownedBookCount(playerId: player.id, ownerships: ownerships),
        5,
      );
      expect(
        service.ciltBookCount(playerId: player.id, ownerships: ownerships),
        2,
      );
      expect(service.ustaCategoryCount(player), 2);
      expect(service.hasWon(player: player, ownerships: ownerships), isTrue);
    });

    test('above threshold wins', () {
      final player = makePlayer(ustaCategories: 3);
      final ownerships = makeOwnerships(
        ownerPlayerId: player.id,
        ownedBooks: 7,
        ciltBooks: 4,
      );

      expect(service.hasWon(player: player, ownerships: ownerships), isTrue);
    });

    test('ownerships belonging to other players do not count', () {
      final player = makePlayer(ustaCategories: 2);
      final ownerships = makeOwnerships(
        ownerPlayerId: player.id,
        ownedBooks: 4,
        ciltBooks: 2,
        otherPlayerBooks: 3,
      );

      expect(
        service.ownedBookCount(playerId: player.id, ownerships: ownerships),
        4,
      );
      expect(
        service.ciltBookCount(playerId: player.id, ownerships: ownerships),
        2,
      );
      expect(service.hasWon(player: player, ownerships: ownerships), isFalse);
    });
  });
}
