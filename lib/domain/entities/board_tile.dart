/// Domain entity representing a tile on the game board.
/// Pure Dart - no Flutter dependencies.

import 'game_enums.dart';

class BoardTile {
  final int id;
  final String title;
  final TileType type;
  final int? price;
  final int? baseRent;
  final QuestionCategory? category;
  final bool isUtility;
  final int upgradeLevel;
  final PropertyColorGroup? colorGroup;

  const BoardTile({
    required this.id,
    required this.title,
    required this.type,
    this.price,
    this.baseRent,
    this.category,
    this.isUtility = false,
    this.upgradeLevel = 0,
    this.colorGroup,
  });

  BoardTile copyWith({int? upgradeLevel}) {
    return BoardTile(
      id: id,
      title: title,
      type: type,
      price: price,
      baseRent: baseRent,
      category: category,
      isUtility: isUtility,
      upgradeLevel: upgradeLevel ?? this.upgradeLevel,
      colorGroup: colorGroup,
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
    return 'BoardTile(id: $id, title: $title, type: $type, price: $price, '
        'baseRent: $baseRent, category: $category, isUtility: $isUtility, '
        'upgradeLevel: $upgradeLevel, colorGroup: $colorGroup)';
  }
}
