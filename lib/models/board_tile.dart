import 'game_enums.dart';

class BoardTile {
  final int id;
  final String title;
  final TileType type;
  final QuestionCategory? category;
  final Difficulty difficulty;

  const BoardTile({
    required this.id,
    required this.title,
    required this.type,
    this.category,
    this.difficulty = Difficulty.easy,
  });

  BoardTile copyWith({Difficulty? difficulty}) {
    return BoardTile(
      id: id,
      title: title,
      type: type,
      category: category,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoardTile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BoardTile(id: $id, title: $title, type: $type, category: $category, difficulty: $difficulty)';
  }
}
