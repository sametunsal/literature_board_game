import '../models/board_tile.dart';
import '../models/game_enums.dart';

/// Board configuration with 22 tiles for RPG-style Literature Board Game
///
/// 6x7 RECTANGULAR GRID LAYOUT (22 tiles on perimeter):
///
///   Width: 6 tiles | Height: 7 tiles
///
///   Grid Visual (indices shown):
///
///   [11-SHOP] [10-Cat]  [9-Cat]   [8-Cat]   [7-Cat]   [6-Cat]   -- Top row (going right from left corner)
///   [10-Cat ]                                          [17-Cat]
///   [9-Cat  ]                                          [18-Cat]
///   [8-Cat  ]           CENTER AREA                    [19-Cat]
///   [7-Cat  ]           (empty)                        [20-Cat]
///   [6-Cat  ]                                          [21-Cat]
///   [5-ŞANS ] [4-Cat]   [3-Cat]   [2-Cat]   [1-Cat]   [0-START] -- Bottom row (going left from start)
///
/// Tile Mapping (Clockwise from Bottom-Right):
///   - Index 0 (Bottom-Right): START (Başlangıç)
///   - Indices 1-4 (Bottom row, right to left): 4 Category tiles
///   - Index 5 (Bottom-Left): ŞANS (Chance)
///   - Indices 6-10 (Left column, bottom to top): 5 Category tiles
///   - Index 11 (Top-Left): KIRAATHANe (Shop)
///   - Indices 12-15 (Top row, left to right): 4 Category tiles
///   - Index 16 (Top-Right): KADER (Fate)
///   - Indices 17-21 (Right column, top to bottom): 5 Category tiles
///
/// Categories repeat 3 times each (18 category tiles total)
class BoardConfig {
  /// The 6 question categories in specified order (repeats 3x on board)
  static const List<QuestionCategory> _categoryOrder = [
    QuestionCategory.turkEdebiyatindaIlkler, // 1st
    QuestionCategory.edebiSanatlar, // 2nd
    QuestionCategory.eserKarakter, // 3rd
    QuestionCategory.edebiyatAkimlari, // 4th
    QuestionCategory.benKimim, // 5th
    QuestionCategory.tesvik, // 6th
  ];

  /// Get category display name in full Turkish
  static String getCategoryDisplayName(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.turkEdebiyatindaIlkler:
        return 'Türk Edebiyatında İlkler';
      case QuestionCategory.edebiSanatlar:
        return 'Edebi Sanatlar';
      case QuestionCategory.eserKarakter:
        return 'Eser-Karakter';
      case QuestionCategory.edebiyatAkimlari:
        return 'Edebiyat Akımları';
      case QuestionCategory.benKimim:
        return 'Ben Kimim?';
      case QuestionCategory.tesvik:
        return 'Teşvik';
    }
  }

  /// Board geometry
  static const int boardWidth = 6; // Tiles across
  static const int boardHeight = 7; // Tiles down
  static const int boardSize = 22; // Total perimeter tiles

  /// Corner positions
  static const int startPosition = 0; // Bottom-Right
  static const int chancePosition = 5; // Bottom-Left (Şans)
  static const int shopPosition = 11; // Top-Left (Kıraathane)
  static const int fatePosition = 16; // Top-Right (Kader)

  /// Helper to get category at position (cycles through 6 categories)
  static QuestionCategory _getCategoryAt(int categoryIndex) {
    return _categoryOrder[categoryIndex % 6];
  }

  static List<BoardTile> tiles = [
    // ═══════════════════════════════════════════════════════════════════════════
    // INDEX 0: START (Bottom-Right Corner)
    // ═══════════════════════════════════════════════════════════════════════════
    const BoardTile(id: 0, title: 'BAŞLANGIÇ', type: TileType.start),

    // ═══════════════════════════════════════════════════════════════════════════
    // INDICES 1-4: Bottom Row (Right to Left) - 4 Category Tiles
    // ═══════════════════════════════════════════════════════════════════════════
    BoardTile(
      id: 1,
      title: getCategoryDisplayName(_getCategoryAt(0)),
      type: TileType.property,
      category: _getCategoryAt(0), // benKimim
      difficulty: Difficulty.easy,
    ),
    BoardTile(
      id: 2,
      title: getCategoryDisplayName(_getCategoryAt(1)),
      type: TileType.property,
      category: _getCategoryAt(1), // turkEdebiyatindaIlkler
      difficulty: Difficulty.easy,
    ),
    BoardTile(
      id: 3,
      title: getCategoryDisplayName(_getCategoryAt(2)),
      type: TileType.property,
      category: _getCategoryAt(2), // edebiyatAkimlari
      difficulty: Difficulty.medium,
    ),
    BoardTile(
      id: 4,
      title: getCategoryDisplayName(_getCategoryAt(3)),
      type: TileType.property,
      category: _getCategoryAt(3), // edebiSanatlar
      difficulty: Difficulty.medium,
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // INDEX 5: ŞANS (Bottom-Left Corner) - Chance
    // ═══════════════════════════════════════════════════════════════════════════
    const BoardTile(id: 5, title: 'ŞANS', type: TileType.chance),

    // ═══════════════════════════════════════════════════════════════════════════
    // INDICES 6-10: Left Column (Bottom to Top) - 5 Category Tiles
    // ═══════════════════════════════════════════════════════════════════════════
    BoardTile(
      id: 6,
      title: getCategoryDisplayName(_getCategoryAt(4)),
      type: TileType.property,
      category: _getCategoryAt(4), // eserKarakter
      difficulty: Difficulty.hard,
    ),
    BoardTile(
      id: 7,
      title: getCategoryDisplayName(_getCategoryAt(5)),
      type: TileType.property,
      category: _getCategoryAt(5), // tesvik
      difficulty: Difficulty.easy,
    ),
    BoardTile(
      id: 8,
      title: getCategoryDisplayName(_getCategoryAt(0)),
      type: TileType.property,
      category: _getCategoryAt(0), // benKimim (2nd)
      difficulty: Difficulty.medium,
    ),
    BoardTile(
      id: 9,
      title: getCategoryDisplayName(_getCategoryAt(1)),
      type: TileType.property,
      category: _getCategoryAt(1), // turkEdebiyatindaIlkler (2nd)
      difficulty: Difficulty.medium,
    ),
    BoardTile(
      id: 10,
      title: getCategoryDisplayName(_getCategoryAt(2)),
      type: TileType.property,
      category: _getCategoryAt(2), // edebiyatAkimlari (2nd)
      difficulty: Difficulty.hard,
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // INDEX 11: KIRAATHANe (Top-Left Corner) - SHOP
    // ═══════════════════════════════════════════════════════════════════════════
    const BoardTile(id: 11, title: 'KIRAATHANe', type: TileType.kiraathane),

    // ═══════════════════════════════════════════════════════════════════════════
    // INDICES 12-15: Top Row (Left to Right) - 4 Category Tiles
    // ═══════════════════════════════════════════════════════════════════════════
    BoardTile(
      id: 12,
      title: getCategoryDisplayName(_getCategoryAt(3)),
      type: TileType.property,
      category: _getCategoryAt(3), // edebiSanatlar (2nd)
      difficulty: Difficulty.hard,
    ),
    BoardTile(
      id: 13,
      title: getCategoryDisplayName(_getCategoryAt(4)),
      type: TileType.property,
      category: _getCategoryAt(4), // eserKarakter (2nd)
      difficulty: Difficulty.easy,
    ),
    BoardTile(
      id: 14,
      title: getCategoryDisplayName(_getCategoryAt(5)),
      type: TileType.property,
      category: _getCategoryAt(5), // tesvik (2nd)
      difficulty: Difficulty.medium,
    ),
    BoardTile(
      id: 15,
      title: getCategoryDisplayName(_getCategoryAt(0)),
      type: TileType.property,
      category: _getCategoryAt(0), // benKimim (3rd)
      difficulty: Difficulty.hard,
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // INDEX 16: KADER (Top-Right Corner) - Fate
    // ═══════════════════════════════════════════════════════════════════════════
    const BoardTile(id: 16, title: 'KADER', type: TileType.fate),

    // ═══════════════════════════════════════════════════════════════════════════
    // INDICES 17-21: Right Column (Top to Bottom) - 5 Category Tiles
    // ═══════════════════════════════════════════════════════════════════════════
    BoardTile(
      id: 17,
      title: getCategoryDisplayName(_getCategoryAt(1)),
      type: TileType.property,
      category: _getCategoryAt(1), // turkEdebiyatindaIlkler (3rd)
      difficulty: Difficulty.hard,
    ),
    BoardTile(
      id: 18,
      title: getCategoryDisplayName(_getCategoryAt(2)),
      type: TileType.property,
      category: _getCategoryAt(2), // edebiyatAkimlari (3rd)
      difficulty: Difficulty.easy,
    ),
    BoardTile(
      id: 19,
      title: getCategoryDisplayName(_getCategoryAt(3)),
      type: TileType.property,
      category: _getCategoryAt(3), // edebiSanatlar (3rd)
      difficulty: Difficulty.medium,
    ),
    BoardTile(
      id: 20,
      title: getCategoryDisplayName(_getCategoryAt(4)),
      type: TileType.property,
      category: _getCategoryAt(4), // eserKarakter (3rd)
      difficulty: Difficulty.medium,
    ),
    BoardTile(
      id: 21,
      title: getCategoryDisplayName(_getCategoryAt(5)),
      type: TileType.property,
      category: _getCategoryAt(5), // tesvik (3rd)
      difficulty: Difficulty.hard,
    ),
  ];

  /// Get tile by ID
  static BoardTile getTile(int id) {
    if (id < 0 || id >= tiles.length) return tiles[0];
    return tiles[id];
  }

  /// Get all tiles for a specific category
  static List<BoardTile> getTilesByCategory(QuestionCategory category) {
    return tiles.where((t) => t.category == category).toList();
  }

  /// Get all corner tiles
  static List<BoardTile> getCornerTiles() {
    return [tiles[0], tiles[5], tiles[11], tiles[16]];
  }

  /// Check if tile is a corner
  static bool isCorner(int id) {
    return id == 0 || id == 5 || id == 11 || id == 16;
  }

  /// Get position info for a tile (row, column, isCorner)
  /// Returns null for invalid IDs
  static TilePosition? getTilePosition(int id) {
    if (id < 0 || id >= 22) return null;

    // Corners
    if (id == 0)
      return TilePosition(row: 6, col: 5, isCorner: true); // Bottom-Right
    if (id == 5)
      return TilePosition(row: 6, col: 0, isCorner: true); // Bottom-Left
    if (id == 11)
      return TilePosition(row: 0, col: 0, isCorner: true); // Top-Left
    if (id == 16)
      return TilePosition(row: 0, col: 5, isCorner: true); // Top-Right

    // Bottom row (indices 1-4, going left from position 0)
    if (id >= 1 && id <= 4) {
      return TilePosition(row: 6, col: 5 - id, isCorner: false);
    }

    // Left column (indices 6-10, going up from position 5)
    if (id >= 6 && id <= 10) {
      return TilePosition(row: 6 - (id - 5), col: 0, isCorner: false);
    }

    // Top row (indices 12-15, going right from position 11)
    if (id >= 12 && id <= 15) {
      return TilePosition(row: 0, col: id - 11, isCorner: false);
    }

    // Right column (indices 17-21, going down from position 16)
    if (id >= 17 && id <= 21) {
      return TilePosition(row: id - 16, col: 5, isCorner: false);
    }

    return null;
  }
}

/// Position of a tile in the grid
class TilePosition {
  final int row; // 0-6 (top to bottom)
  final int col; // 0-5 (left to right)
  final bool isCorner;

  const TilePosition({
    required this.row,
    required this.col,
    required this.isCorner,
  });
}
