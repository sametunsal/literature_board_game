import 'game_enums.dart';

/// Static board-property definition for the Publishing Tycoon MVP.
class Book {
  final String id;
  final String title;
  final String author;
  final String? boardLabel;
  final QuestionCategory category;
  final int tilePosition;
  final int telifRewardAkce;
  final int baskiCostAkce;
  final int ciltCostAkce;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.boardLabel,
    required this.category,
    required this.tilePosition,
    this.telifRewardAkce = 0,
    this.baskiCostAkce = 0,
    this.ciltCostAkce = 0,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? boardLabel,
    QuestionCategory? category,
    int? tilePosition,
    int? telifRewardAkce,
    int? baskiCostAkce,
    int? ciltCostAkce,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      boardLabel: boardLabel ?? this.boardLabel,
      category: category ?? this.category,
      tilePosition: tilePosition ?? this.tilePosition,
      telifRewardAkce: telifRewardAkce ?? this.telifRewardAkce,
      baskiCostAkce: baskiCostAkce ?? this.baskiCostAkce,
      ciltCostAkce: ciltCostAkce ?? this.ciltCostAkce,
    );
  }
}
