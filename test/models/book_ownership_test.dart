import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/models/book_level.dart';
import 'package:literature_board_game/models/book_ownership.dart';

void main() {
  group('BookOwnership', () {
    test('copyWith updates selected fields and preserves the rest', () {
      const ownership = BookOwnership(
        bookId: 'intibah',
        ownerPlayerId: 'p1',
        level: BookLevel.telif,
      );

      final updated = ownership.copyWith(level: BookLevel.baski);

      expect(updated.bookId, 'intibah');
      expect(updated.ownerPlayerId, 'p1');
      expect(updated.level, BookLevel.baski);
    });
  });
}
