import '../core/constants/game_constants.dart';
import '../models/board_tile.dart';
import '../models/tile_type.dart';
import '../models/difficulty.dart';
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
  static final List<QuestionCategory> _categoryOrder = [
    QuestionCategory.turkEdebiyatindaIlkler, // 1st: Türk Edebiyatında İlkler
    QuestionCategory.edebiSanatlar, // 2nd: Edebi Sanatlar
    QuestionCategory.eserKarakter, // 3rd: Eser-Karakter
    QuestionCategory.edebiyatAkimlari, // 4th: Edebiyat Akımları
    QuestionCategory.benKimim, // 5th: Ben Kimim?
    QuestionCategory.tesvik, // 6th: Teşvik
  ];

  /// Board geometry
  static const int boardWidth = 6; // Tiles across
  static const int boardHeight = 7; // Tiles down
  static const int boardSize = 22; // Total perimeter tiles

  /// Corner positions (now using GameConstants)
  static const int startPosition = GameConstants.startPosition;
  static const int libraryPosition = GameConstants.libraryPosition;
  static const int shopPosition = GameConstants.shopPosition;
  static const int signingDayPosition = GameConstants.signingDayPosition;

  /// Helper to get category at position (cycles through 6 categories)
  static QuestionCategory _getCategoryAt(int categoryIndex) {
    return _categoryOrder[categoryIndex % 6];
  }

  static List<BoardTile> get tiles {
    return _generateTiles();
  }

  static List<BoardTile> _generateTiles() {
    final tiles = <BoardTile>[];

    // Position 0: START (Başlangıç)
    tiles.add(
      BoardTile(
        id: '0',
        name: 'BAŞLANGIÇ',
        position: 0,
        type: TileType.start,
        category: '',
        difficulty: Difficulty.easy,
      ),
    );

    // Positions 1-4: Category tiles (bottom row, going left)
    for (int i = 0; i < 4; i++) {
      final category = _getCategoryAt(i);
      tiles.add(
        BoardTile(
          id: '${i + 1}',
          name: category.displayName,
          position: i + 1,
          type: TileType.category,
          category: category.name,
          difficulty: Difficulty.easy,
        ),
      );
    }

    // Position 5: İMZA GÜNÜ (Signing Day)
    tiles.add(
      BoardTile(
        id: '5',
        name: 'İMZA GÜNÜ',
        position: 5,
        type: TileType.corner,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );

    // Positions 6-10: Category tiles (left column, going up)
    for (int i = 0; i < 5; i++) {
      final category = _getCategoryAt(i + 4);
      tiles.add(
        BoardTile(
          id: '${i + 6}',
          name: category.displayName,
          position: i + 6,
          type: TileType.category,
          category: category.name,
          difficulty: Difficulty.medium,
        ),
      );
    }

    // Position 11: KIRAATHANE (Shop)
    tiles.add(
      BoardTile(
        id: '11',
        name: 'KIRAATHANE',
        position: 11,
        type: TileType.shop,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );

    // Positions 12-15: Category tiles (top row, going right)
    for (int i = 0; i < 4; i++) {
      final category = _getCategoryAt(i + 9);
      tiles.add(
        BoardTile(
          id: '${i + 12}',
          name: category.displayName,
          position: i + 12,
          type: TileType.category,
          category: category.name,
          difficulty: Difficulty.medium,
        ),
      );
    }

    // Position 16: KÜTÜPHANE (Library)
    tiles.add(
      BoardTile(
        id: '16',
        name: 'KÜTÜPHANE',
        position: 16,
        type: TileType.corner,
        category: '',
        difficulty: Difficulty.hard,
      ),
    );

    // Positions 17-21: Category tiles (right column, going down)
    for (int i = 0; i < 5; i++) {
      final category = _getCategoryAt(i + 13);
      tiles.add(
        BoardTile(
          id: '${i + 17}',
          name: category.displayName,
          position: i + 17,
          type: TileType.category,
          category: category.name,
          difficulty: Difficulty.hard,
        ),
      );
    }

    return tiles;
  }

  /// Get list of category names for debugging
  static List<String> getCategoryNames() {
    return tiles.map((t) => t.category ?? '').toList();
  }

  /// Get tile by ID
  static BoardTile getTile(int id) {
    if (id < 0 || id >= tiles.length) return tiles[0];
    return tiles[id];
  }

  /// Get all tiles for a specific category
  static List<BoardTile> getTilesByCategory(QuestionCategory category) {
    return tiles.where((t) => t.category == category.name).toList();
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
    if (id == 0) {
      return TilePosition(row: 6, col: 5, isCorner: true); // Bottom-Right
    }
    if (id == 5) {
      return TilePosition(row: 6, col: 0, isCorner: true); // Bottom-Left
    }
    if (id == 11) {
      return TilePosition(row: 0, col: 0, isCorner: true); // Top-Left
    }
    if (id == 16) {
      return TilePosition(row: 0, col: 5, isCorner: true); // Top-Right
    }

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
