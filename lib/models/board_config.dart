import 'board_tile.dart';
import 'tile_type.dart';
import 'difficulty.dart';

/// Configuration for the game board layout
/// Generates exactly 22 tiles: 4 corners + 18 category tiles (6 categories × 3)
class BoardConfig {
  /// The 6 question categories in order
  static const List<String> categories = [
    'Türk Edebiyatında İlkler',
    'Edebi Sanatlar',
    'Eser-Karakter',
    'Edebiyat Akımları',
    'Ben Kimim?',
    'Teşvik',
  ];

  /// Category IDs corresponding to the display names
  static const List<String> categoryIds = [
    'turkEdebiyatindaIlkler',
    'edebiSanatlar',
    'eserKarakter',
    'edebiyatAkimlari',
    'benKimim',
    'tesvik',
  ];

  /// Generate the complete board layout with 22 tiles
  /// Layout: 4 corners + 18 category tiles (6 categories repeated 3 times)
  static List<BoardTile> generateBoard() {
    final List<BoardTile> tiles = [];

    // Position 0: Start corner
    tiles.add(
      BoardTile(id: '0', name: 'BAŞLANGIÇ', position: 0, type: TileType.start),
    );

    // Positions 1-4: First set of categories (4 tiles)
    tiles.addAll(_generateCategoryTiles(1, 4, 0));

    // Position 5: Chance corner
    tiles.add(
      BoardTile(id: '5', name: 'ŞANS', position: 5, type: TileType.corner),
    );

    // Positions 6-10: Second set of categories (5 tiles)
    tiles.addAll(_generateCategoryTiles(6, 5, 4));

    // Position 11: Shop corner (Kıraathane)
    tiles.add(
      BoardTile(
        id: '11',
        name: 'KIRAATHANE',
        position: 11,
        type: TileType.shop,
      ),
    );

    // Positions 12-16: Third set of categories (5 tiles)
    tiles.addAll(_generateCategoryTiles(12, 5, 9));

    // Position 17: Fate corner
    tiles.add(
      BoardTile(id: '17', name: 'KADER', position: 17, type: TileType.corner),
    );

    // Positions 18-21: Fourth set of categories (4 tiles)
    tiles.addAll(_generateCategoryTiles(18, 4, 14));

    return tiles;
  }

  /// Generate category tiles for a range of positions
  /// [startPos] is the starting position
  /// [count] is the number of tiles to generate
  /// [categoryIndex] is the starting index in the categories list
  static List<BoardTile> _generateCategoryTiles(
    int startPos,
    int count,
    int categoryIndex,
  ) {
    final List<BoardTile> tiles = [];
    for (int i = 0; i < count; i++) {
      final pos = startPos + i;
      final catIndex = (categoryIndex + i) % 6;
      final difficulty = _getDifficultyForPosition(pos);

      tiles.add(
        BoardTile(
          id: pos.toString(),
          name: categories[catIndex],
          position: pos,
          type: TileType.category,
          category: categoryIds[catIndex],
          difficulty: difficulty,
        ),
      );
    }
    return tiles;
  }

  /// Get difficulty based on position
  /// Positions 1-4, 6-9: Easy
  /// Positions 10-13, 15-18: Medium
  /// Positions 14, 19-21: Hard
  static Difficulty _getDifficultyForPosition(int position) {
    if (position <= 9) {
      return Difficulty.easy;
    } else if (position <= 18) {
      return Difficulty.medium;
    } else {
      return Difficulty.hard;
    }
  }

  /// Get category at a specific position index (0-17 for category tiles only)
  static String getCategoryAt(int index) {
    return categoryIds[index % 6];
  }

  /// Get display name for a category
  static String getCategoryDisplayName(String categoryId) {
    final index = categoryIds.indexOf(categoryId);
    if (index >= 0 && index < categories.length) {
      return categories[index];
    }
    return categoryId;
  }

  /// Check if a position is a corner tile
  static bool isCorner(int position) {
    return position == 0 || position == 5 || position == 11 || position == 17;
  }

  /// Check if a position is a category tile
  static bool isCategoryTile(int position) {
    return !isCorner(position);
  }

  /// Get total number of tiles on the board
  static int get totalTiles => 22;

  /// Get total number of category tiles
  static int get totalCategoryTiles => 18;

  /// Get total number of corner tiles
  static int get totalCornerTiles => 4;
}
