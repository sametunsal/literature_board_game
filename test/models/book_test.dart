import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/models/book.dart';
import 'package:literature_board_game/models/game_enums.dart';

void main() {
  group('Book', () {
    test('stores static board property metadata', () {
      const book = Book(
        id: 'intibah',
        title: 'İntibah',
        author: 'Namık Kemal',
        boardLabel: 'İntibah',
        category: QuestionCategory.turkEdebiyatindaIlkler,
        tilePosition: 1,
        telifRewardAkce: 3,
        baskiCostAkce: 5,
        ciltCostAkce: 8,
      );

      expect(book.id, 'intibah');
      expect(book.title, 'İntibah');
      expect(book.author, 'Namık Kemal');
      expect(book.boardLabel, 'İntibah');
      expect(book.category, QuestionCategory.turkEdebiyatindaIlkler);
      expect(book.tilePosition, 1);
      expect(book.telifRewardAkce, 3);
      expect(book.baskiCostAkce, 5);
      expect(book.ciltCostAkce, 8);
    });

    test('copyWith updates selected fields and preserves the rest', () {
      const book = Book(
        id: 'intibah',
        title: 'İntibah',
        author: 'Namık Kemal',
        boardLabel: 'İntibah',
        category: QuestionCategory.turkEdebiyatindaIlkler,
        tilePosition: 1,
      );

      final updated = book.copyWith(
        boardLabel: 'Kısa İntibah',
        tilePosition: 4,
        baskiCostAkce: 7,
      );

      expect(updated.id, book.id);
      expect(updated.title, book.title);
      expect(updated.author, book.author);
      expect(updated.boardLabel, 'Kısa İntibah');
      expect(updated.category, book.category);
      expect(updated.tilePosition, 4);
      expect(updated.baskiCostAkce, 7);
    });
  });
}
