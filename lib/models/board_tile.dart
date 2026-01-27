import 'difficulty.dart';
import 'tile_type.dart';

/// Model representing a tile on the Literature Quiz RPG game board
class BoardTile {
  /// Unique identifier for the tile
  final String id;

  /// Display name/title of the tile
  final String name;

  /// Position on the board (0-21 for 22 tiles)
  final int position;

  /// Type of tile (Corner, Category, Start, Shop, Collection)
  final TileType type;

  /// Category for category tiles (one of the 6 categories)
  final String? category;

  /// Difficulty level for category tiles
  final Difficulty difficulty;

  const BoardTile({
    required this.id,
    required this.name,
    required this.position,
    required this.type,
    this.category,
    this.difficulty = Difficulty.medium,
  });

  /// Creates a copy of this tile with optional new values
  BoardTile copyWith({
    String? id,
    String? name,
    int? position,
    TileType? type,
    String? category,
    Difficulty? difficulty,
  }) {
    return BoardTile(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      type: type ?? this.type,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  /// Creates a BoardTile from JSON
  factory BoardTile.fromJson(Map<String, dynamic> json) {
    return BoardTile(
      id: json['id'] as String,
      name: json['name'] as String,
      position: json['position'] as int,
      type: TileType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TileType.category,
      ),
      category: json['category'] as String?,
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => Difficulty.medium,
      ),
    );
  }

  /// Converts this BoardTile to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'type': type.name,
      'category': category,
      'difficulty': difficulty.name,
    };
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
    return 'BoardTile(id: $id, name: $name, position: $position, type: $type, category: $category, difficulty: $difficulty)';
  }
}
