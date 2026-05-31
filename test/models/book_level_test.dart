import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/models/book_level.dart';

void main() {
  group('BookLevel', () {
    test('maps levels to progression values', () {
      expect(BookLevel.none.value, 0);
      expect(BookLevel.telif.value, 1);
      expect(BookLevel.baski.value, 2);
      expect(BookLevel.cilt.value, 3);
    });

    test('exposes display names', () {
      expect(BookLevel.none.displayName, 'Yok');
      expect(BookLevel.telif.displayName, 'Telif');
      expect(BookLevel.baski.displayName, 'Baski');
      expect(BookLevel.cilt.displayName, 'Cilt');
    });

    test('advances to the next level and clamps at cilt', () {
      expect(BookLevel.none.nextLevel, BookLevel.telif);
      expect(BookLevel.telif.nextLevel, BookLevel.baski);
      expect(BookLevel.baski.nextLevel, BookLevel.cilt);
      expect(BookLevel.cilt.nextLevel, BookLevel.cilt);
      expect(BookLevel.cilt.isMaxLevel, isTrue);
      expect(BookLevel.baski.isMaxLevel, isFalse);
    });
  });
}
