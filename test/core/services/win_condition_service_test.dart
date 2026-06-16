import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/services/win_condition_service.dart';
import 'package:literature_board_game/models/book_level.dart';
import 'package:literature_board_game/models/book_ownership.dart';

void main() {
  const service = WinConditionService();

  group('WinConditionService', () {
    test('no ownerships = no Cilt books', () {
      expect(service.ciltBookCount(playerId: 'p1', ownerships: {}), 0);
    });

    test('counts only current player Cilt books', () {
      final ownerships = {
        'book_1': const BookOwnership(
          bookId: 'book_1',
          ownerPlayerId: 'p1',
          level: BookLevel.cilt,
        ),
        'book_2': const BookOwnership(
          bookId: 'book_2',
          ownerPlayerId: 'p1',
          level: BookLevel.baski,
        ),
        'book_3': const BookOwnership(
          bookId: 'book_3',
          ownerPlayerId: 'p2',
          level: BookLevel.cilt,
        ),
        'book_4': const BookOwnership(
          bookId: 'book_4',
          ownerPlayerId: 'p1',
          level: BookLevel.cilt,
        ),
      };

      expect(service.ciltBookCount(playerId: 'p1', ownerships: ownerships), 2);
      expect(service.ciltBookCount(playerId: 'p2', ownerships: ownerships), 1);
    });
  });
}
