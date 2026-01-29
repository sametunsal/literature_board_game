/// Data Transfer Object for BoardTile entity.
/// Used for JSON serialization and persistence.
/// Pure Dart - no Flutter dependencies.
library;

enum DifficultyModel { easy, medium, hard }

enum TileTypeModel {
  start,
  property,
  chance,
  fate,
  kiraathane, // Shop corner tile
}

enum QuestionCategoryModel {
  benKimim,
  turkEdebiyatindaIlkler,
  edebiyatAkimlari,
  edebiSanatlar,
  eserKarakter,
  tesvik,
}

class BoardTileModel {
  final int id;
  final String title;
  final TileTypeModel type;
  final QuestionCategoryModel? category;
  final DifficultyModel difficulty;

  BoardTileModel({
    required this.id,
    required this.title,
    required this.type,
    this.category,
    this.difficulty = DifficultyModel.easy,
  });

  factory BoardTileModel.fromJson(Map<String, dynamic> json) {
    return BoardTileModel(
      id: json['id'] as int,
      title: json['title'] as String,
      type: TileTypeModel.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TileTypeModel.start,
      ),
      category: json['category'] != null
          ? QuestionCategoryModel.values.firstWhere(
              (e) => e.name == json['category'],
              orElse: () => QuestionCategoryModel.benKimim,
            )
          : null,
      difficulty: json['difficulty'] != null
          ? DifficultyModel.values.firstWhere(
              (e) => e.name == json['difficulty'],
              orElse: () => DifficultyModel.easy,
            )
          : DifficultyModel.easy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'category': category?.name,
      'difficulty': difficulty.name,
    };
  }

  BoardTileModel copyWith({DifficultyModel? difficulty}) {
    return BoardTileModel(
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
    return other is BoardTileModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BoardTileModel(id: $id, title: $title, type: $type, category: $category, difficulty: $difficulty)';
  }
}
