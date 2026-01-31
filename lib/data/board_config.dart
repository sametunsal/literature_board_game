import '../core/constants/game_constants.dart';
import '../models/board_tile.dart';
import '../models/tile_type.dart';
import '../models/difficulty.dart';
import '../models/game_enums.dart';

/// Board configuration with 26 tiles for RPG-style Literature Board Game
///
/// 6x7 RECTANGULAR GRID LAYOUT (26 tiles on perimeter):
///
///   Width: 6 tiles | Height: 7 tiles
///
///   Grid Visual (indices shown):
///
///   [12-SHOP] [11-Cat] [10-Cat] [9-KADER] [8-Cat]  [7-Cat]   -- Top row (going right from left corner)
///   [23-Cat ]                                         [18-Cat]
///   [24-Cat ]                                         [19-Cat]
///   [25-Cat ]           CENTER AREA                    [20-Cat]
///   [0-START]           (empty)                        [21-KADER]
///   [1-Cat  ]                                         [22-Cat]
///   [2-Cat  ] [3-SANS] [4-Cat]  [5-Cat]  [6-IMZA]  [7-Cat]   -- Bottom row (going left from start)
///
/// Tile Mapping (Clockwise from Bottom-Right):
///   - Index 0 (Bottom-Right): START (Başlangıç)
///   - Indices 1-2 (Bottom row): 2 Category tiles
///   - Index 3 (Bottom row): ŞANS (Chance) - SPECIAL TILE
///   - Indices 4-5 (Bottom row): 2 Category tiles
///   - Index 6 (Bottom-Left): İMZA GÜNÜ (Signing Day) - Corner
///   - Indices 7-8 (Left column): 2 Category tiles
///   - Index 9 (Left column): KADER (Fate) - SPECIAL TILE
///   - Indices 10-11 (Left column): 2 Category tiles
///   - Index 12 (Top-Left): KIRAATHANE (Shop) - Corner
///   - Indices 13-14 (Top row): 2 Category tiles
///   - Index 15 (Top row): ŞANS (Chance) - SPECIAL TILE
///   - Indices 16-17 (Top row): 2 Category tiles
///   - Index 18 (Top-Right): KÜTÜPHANE (Library) - Corner
///   - Indices 19-20 (Right column): 2 Category tiles
///   - Index 21 (Right column): KADER (Fate) - SPECIAL TILE
///   - Indices 22-25 (Right column): 3 Category tiles back to start
///
/// Categories repeat 3+ times each (18 category tiles + 4 special tiles + 4 corners = 26 total)
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
  static const int boardSize = 26; // Total perimeter tiles (was 22, now 26)

  /// Corner positions (updated for 26-tile board)
  static const int startPosition = GameConstants.startPosition;
  static const int libraryPosition = GameConstants.libraryPosition;
  static const int shopPosition = GameConstants.shopPosition;
  static const int signingDayPosition = GameConstants.signingDayPosition;

  /// Special tile positions (Şans and Kader)
  static const int sansBottomEdge = 3; // ŞANS on bottom edge
  static const int sansTopEdge = 15; // ŞANS on top edge
  static const int kaderLeftEdge = 9; // KADER on left edge
  static const int kaderRightEdge = 21; // KADER on right edge

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

    // Positions 1-2: Category tiles (bottom row, first half)
    for (int i = 0; i < 2; i++) {
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

    // Position 3: ŞANS (Chance) - NEW SPECIAL TILE
    tiles.add(
      BoardTile(
        id: '3',
        name: 'ŞANS',
        position: 3,
        type: TileType.chance,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );

    // Positions 4-5: Category tiles (bottom row, second half)
    for (int i = 0; i < 2; i++) {
      final category = _getCategoryAt(i + 2);
      tiles.add(
        BoardTile(
          id: '${i + 4}',
          name: category.displayName,
          position: i + 4,
          type: TileType.category,
          category: category.name,
          difficulty: Difficulty.easy,
        ),
      );
    }

    // Position 6: İMZA GÜNÜ (Signing Day) - Corner
    tiles.add(
      BoardTile(
        id: '6',
        name: 'İMZA GÜNÜ',
        position: 6,
        type: TileType.corner,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );

    // Positions 7-8: Category tiles (left column, first half)
    for (int i = 0; i < 2; i++) {
      final category = _getCategoryAt(i + 4);
      tiles.add(
        BoardTile(
          id: '${i + 7}',
          name: category.displayName,
          position: i + 7,
          type: TileType.category,
          category: category.name,
          difficulty: Difficulty.medium,
        ),
      );
    }

    // Position 9: KADER (Fate) - NEW SPECIAL TILE
    tiles.add(
      BoardTile(
        id: '9',
        name: 'KADER',
        position: 9,
        type: TileType.fate,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );

    // Positions 10-11: Category tiles (left column, second half)
    for (int i = 0; i < 2; i++) {
      final category = _getCategoryAt(i + 6);
      tiles.add(
        BoardTile(
          id: '${i + 10}',
          name: category.displayName,
          position: i + 10,
          type: TileType.category,
          category: category.name,
          difficulty: Difficulty.medium,
        ),
      );
    }

    // Position 12: KIRAATHANE (Shop) - Corner
    tiles.add(
      BoardTile(
        id: '12',
        name: 'KIRAATHANE',
        position: 12,
        type: TileType.shop,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );

    // Positions 13-14: Category tiles (top row, first half)
    for (int i = 0; i < 2; i++) {
      final category = _getCategoryAt(i + 8);
      tiles.add(
        BoardTile(
          id: '${i + 13}',
          name: category.displayName,
          position: i + 13,
          type: TileType.category,
          category: category.name,
          difficulty: Difficulty.medium,
        ),
      );
    }

    // Position 15: ŞANS (Chance) - NEW SPECIAL TILE
    tiles.add(
      BoardTile(
        id: '15',
        name: 'ŞANS',
        position: 15,
        type: TileType.chance,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );

    // Positions 16-17: Category tiles (top row, second half)
    for (int i = 0; i < 2; i++) {
      final category = _getCategoryAt(i + 10);
      tiles.add(
        BoardTile(
          id: '${i + 16}',
          name: category.displayName,
          position: i + 16,
          type: TileType.category,
          category: category.name,
          difficulty: Difficulty.medium,
        ),
      );
    }

    // Position 18: KÜTÜPHANE (Library) - Corner
    tiles.add(
      BoardTile(
        id: '18',
        name: 'KÜTÜPHANE',
        position: 18,
        type: TileType.corner,
        category: '',
        difficulty: Difficulty.hard,
      ),
    );

    // Positions 19-20: Category tiles (right column, first half)
    for (int i = 0; i < 2; i++) {
      final category = _getCategoryAt(i + 12);
      tiles.add(
        BoardTile(
          id: '${i + 19}',
          name: category.displayName,
          position: i + 19,
          type: TileType.category,
          category: category.name,
          difficulty: Difficulty.hard,
        ),
      );
    }

    // Position 21: KADER (Fate) - NEW SPECIAL TILE
    tiles.add(
      BoardTile(
        id: '21',
        name: 'KADER',
        position: 21,
        type: TileType.fate,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );

    // Positions 22-25: Category tiles (right column, back to start)
    for (int i = 0; i < 4; i++) {
      final category = _getCategoryAt(i + 14);
      tiles.add(
        BoardTile(
          id: '${i + 22}',
          name: category.displayName,
          position: i + 22,
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

  /// Get all corner tiles (updated positions for 26-tile board)
  static List<BoardTile> getCornerTiles() {
    return [tiles[0], tiles[6], tiles[12], tiles[18]];
  }

  /// Check if tile is a corner (updated positions for 26-tile board)
  static bool isCorner(int id) {
    return id == 0 || id == 6 || id == 12 || id == 18;
  }

  /// Get all special tiles (Şans and Kader)
  static List<BoardTile> getSpecialTiles() {
    return [tiles[3], tiles[9], tiles[15], tiles[21]];
  }

  /// Check if tile is a special Şans/Kader tile
  static bool isSpecialTile(int id) {
    return id == 3 || id == 9 || id == 15 || id == 21;
  }

  /// Get position info for a tile (row, column, isCorner)
  /// Returns null for invalid IDs (updated for 26-tile board)
  static TilePosition? getTilePosition(int id) {
    if (id < 0 || id >= 26) return null;

    // Corners
    if (id == 0) {
      return TilePosition(row: 6, col: 5, isCorner: true); // Bottom-Right (START)
    }
    if (id == 6) {
      return TilePosition(row: 6, col: 0, isCorner: true); // Bottom-Left (İMZA GÜNÜ)
    }
    if (id == 12) {
      return TilePosition(row: 0, col: 0, isCorner: true); // Top-Left (KIRAATHANE)
    }
    if (id == 18) {
      return TilePosition(row: 0, col: 5, isCorner: true); // Top-Right (KÜTÜPHANE)
    }

    // Bottom row (indices 1-5, going left from position 0)
    if (id >= 1 && id <= 5) {
      return TilePosition(row: 6, col: 5 - id, isCorner: false);
    }

    // Left column (indices 7-11, going up from position 6)
    if (id >= 7 && id <= 11) {
      return TilePosition(row: 6 - (id - 6), col: 0, isCorner: false);
    }

    // Top row (indices 13-17, going right from position 12)
    if (id >= 13 && id <= 17) {
      return TilePosition(row: 0, col: id - 12, isCorner: false);
    }

    // Right column (indices 19-25, going down from position 18)
    if (id >= 19 && id <= 25) {
      return TilePosition(row: id - 18, col: 5, isCorner: false);
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
