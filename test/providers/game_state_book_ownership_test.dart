import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/models/book_level.dart';
import 'package:literature_board_game/models/book_ownership.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

void main() {
  group('GameState bookOwnerships', () {
    test('defaults to empty', () {
      final state = GameState(players: const []);

      expect(state.bookOwnerships, isEmpty);
    });

    test('copyWith preserves existing book ownerships by default', () {
      const ownership = BookOwnership(
        bookId: 'intibah',
        ownerPlayerId: 'p1',
        level: BookLevel.telif,
      );
      final state = GameState(
        players: const [],
        bookOwnerships: const {'intibah': ownership},
      );

      final updated = state.copyWith(diceTotal: 7);

      expect(updated.diceTotal, 7);
      expect(updated.bookOwnerships, same(state.bookOwnerships));
    });

    test('copyWith can replace book ownerships', () {
      const original = BookOwnership(
        bookId: 'intibah',
        ownerPlayerId: 'p1',
        level: BookLevel.telif,
      );
      const replacement = BookOwnership(
        bookId: 'calikusu',
        ownerPlayerId: 'p2',
        level: BookLevel.cilt,
      );
      final state = GameState(
        players: const [],
        bookOwnerships: const {'intibah': original},
      );

      final updated = state.copyWith(
        bookOwnerships: const {'calikusu': replacement},
      );

      expect(updated.bookOwnerships, containsPair('calikusu', replacement));
      expect(updated.bookOwnerships, isNot(contains('intibah')));
    });
  });
}
