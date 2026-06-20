import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/data/book_config.dart';
import 'package:literature_board_game/models/game_enums.dart';

void main() {
  group('BookConfig', () {
    test('has the expected book count', () {
      expect(BookConfig.books, hasLength(BookConfig.expectedBookCount));
    });

    test('has unique book ids', () {
      final ids = BookConfig.books.map((book) => book.id).toSet();

      expect(ids, hasLength(BookConfig.books.length));
    });

    test('has unique tile positions', () {
      final positions = BookConfig.books
          .map((book) => book.tilePosition)
          .toSet();

      expect(positions, hasLength(BookConfig.books.length));
    });

    test('uses valid publishing categories', () {
      const validCategories = {
        QuestionCategory.turkEdebiyatindaIlkler,
        QuestionCategory.edebiSanatlar,
        QuestionCategory.eserKarakter,
        QuestionCategory.edebiyatAkimlari,
        QuestionCategory.benKimim,
      };

      for (final book in BookConfig.books) {
        expect(validCategories, contains(book.category));
      }
    });

    test('has positive upgrade costs', () {
      for (final book in BookConfig.books) {
        expect(book.baskiCostAkce, greaterThan(0));
        expect(book.ciltCostAkce, greaterThan(0));
        expect(book.ciltCostAkce, greaterThan(book.baskiCostAkce));
      }
    });

    test('uses Phase 14A configured upgrade cost tiers', () {
      const expectedCosts = [
        (baski: 8, cilt: 18),
        (baski: 8, cilt: 18),
        (baski: 10, cilt: 22),
        (baski: 10, cilt: 22),
        (baski: 10, cilt: 22),
        (baski: 12, cilt: 26),
        (baski: 12, cilt: 26),
        (baski: 12, cilt: 26),
        (baski: 14, cilt: 30),
        (baski: 14, cilt: 30),
        (baski: 14, cilt: 30),
        (baski: 16, cilt: 34),
        (baski: 16, cilt: 34),
        (baski: 16, cilt: 34),
        (baski: 16, cilt: 34),
      ];

      for (var i = 0; i < BookConfig.books.length; i++) {
        expect(BookConfig.books[i].baskiCostAkce, expectedCosts[i].baski);
        expect(BookConfig.books[i].ciltCostAkce, expectedCosts[i].cilt);
      }
    });

    test('looks up books by id and tile position', () {
      final byId = BookConfig.getById('intibah');
      final byTile = BookConfig.getByTilePosition(1);

      expect(byId, isNotNull);
      expect(byTile, isNotNull);
      expect(byId, same(byTile));
      expect(BookConfig.getById('missing'), isNull);
      expect(BookConfig.getByTilePosition(99), isNull);
    });
  });
}
