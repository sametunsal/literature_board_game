import '../core/constants/game_constants.dart';
import '../models/board_tile.dart';
import '../models/tile_type.dart';
import '../models/difficulty.dart';
import '../models/game_enums.dart';

/// Board configuration with 26 tiles for RPG-style Literature Board Game
///
/// RECTANGULAR GRID LAYOUT (26 tiles on perimeter):
///
///   Tile Mapping (Clockwise from Bottom-Right):
///
///   BOTTOM ROW (7 tiles): Index 0-6
///   - Index 0: BAŞLANGIÇ (Start)
///   - Indices 1-4: 4 Category tiles
///   - Index 5: ŞANS (Chance) - SPECIAL TILE
///   - Index 6: İMZA GÜNÜ (Signing Day) - CORNER
///
///   LEFT COLUMN (6 tiles, excluding shared corner): Index 7-12
///   - Indices 7-10: 4 Category tiles
///   - Index 11: KADER (Fate) - SPECIAL TILE
///   - Index 12: KIRAATHANE (Shop) - CORNER
///
///   TOP ROW (6 tiles, excluding shared corner): Index 13-18
///   - Indices 13-16: 4 Category tiles
///   - Index 17: ŞANS (Chance) - SPECIAL TILE
///   - Index 18: KÜTÜPHANE (Library) - CORNER
///
///   RIGHT COLUMN (7 tiles, excluding shared corner): Index 19-25
///   - Indices 19-22: 4 Category tiles
///   - Index 23: KADER (Fate) - SPECIAL TILE
///   - Indices 24-25: 2 Category tiles back to start
///
///   Total: 26 tiles (18 category + 4 special + 3 corners + 1 start = 26)
class BoardConfig {
  /// The 6 question categories in specified order
  static final List<QuestionCategory> _categoryOrder = [
    QuestionCategory.turkEdebiyatindaIlkler, // 1st: Türk Edebiyatında İlkler
    QuestionCategory.edebiSanatlar, // 2nd: Edebi Sanatlar
    QuestionCategory.eserKarakter, // 3rd: Eser-Karakter
    QuestionCategory.edebiyatAkimlari, // 4th: Edebiyat Akımları
    QuestionCategory.benKimim, // 5th: Ben Kimim?
    QuestionCategory.tesvik, // 6th: Teşvik
  ];

  /// Board geometry
  static const int boardWidth = 7; // Tiles across (increased for 26-tile board)
  static const int boardHeight = 7; // Tiles down
  static const int boardSize = 26; // Total perimeter tiles

  /// Corner positions (updated for 26-tile board)
  static const int startPosition = 0;
  static const int signingDayPosition = 6; // İMZA GÜNÜ (Bottom-Left corner)
  static const int shopPosition = 12; // KIRAATHANE (Top-Left corner)
  static const int libraryPosition = 18; // KÜTÜPHANE (Top-Right corner)

  /// Special tile positions (Şans and Kader)
  static const int chancePosition1 = 5; // ŞANS on bottom edge
  static const int chancePosition2 = 17; // ŞANS on top edge
  static const int fatePosition1 = 11; // KADER on left edge
  static const int fatePosition2 = 23; // KADER on right edge

  /// All corner indices for easy reference
  static const List<int> cornerIndices = [0, 6, 12, 18];

  /// Helper to get category at position (cycles through 6 categories)
  static QuestionCategory _getCategoryAt(int categoryIndex) {
    return _categoryOrder[categoryIndex % 6];
  }

  static List<BoardTile> get tiles {
    return _generateTiles();
  }

  static List<BoardTile> _generateTiles() {
    final tiles = <BoardTile>[];

    // ═══════════════════════════════════════════════════════════════
    // BOTTOM ROW (7 tiles): Indices 0-6
    // ═══════════════════════════════════════════════════════════════

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

    // Positions 1-4: 4 Category tiles
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

    // Position 5: ŞANS (Chance) - SPECIAL TILE
    tiles.add(
      BoardTile(
        id: '5',
        name: 'ŞANS',
        position: 5,
        type: TileType.chance,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );

    // Position 6: İMZA GÜNÜ (Signing Day) - CORNER
    tiles.add(
      BoardTile(
        id: '6',
        name: 'İMZA GÜNÜ',
        position: 6,
        type: TileType.signingDay,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );

    // ═══════════════════════════════════════════════════════════════
    // LEFT COLUMN (6 tiles, excluding shared corner): Indices 7-12
    // ═══════════════════════════════════════════════════════════════

    // Positions 7-10: 4 Category tiles
    for (int i = 0; i < 4; i++) {
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

    // Position 11: KADER (Fate) - SPECIAL TILE
    tiles.add(
      BoardTile(
        id: '11',
        name: 'KADER',
        position: 11,
        type: TileType.fate,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );

    // Position 12: KIRAATHANE (Shop) - CORNER
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

    // ═══════════════════════════════════════════════════════════════
    // TOP ROW (6 tiles, excluding shared corner): Indices 13-18
    // ═══════════════════════════════════════════════════════════════

    // Positions 13-16: 4 Category tiles
    for (int i = 0; i < 4; i++) {
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

    // Position 17: ŞANS (Chance) - SPECIAL TILE
    tiles.add(
      BoardTile(
        id: '17',
        name: 'ŞANS',
        position: 17,
        type: TileType.chance,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );

    // Position 18: KÜTÜPHANE (Library) - CORNER
    tiles.add(
      BoardTile(
        id: '18',
        name: 'KÜTÜPHANE',
        position: 18,
        type: TileType.library,
        category: '',
        difficulty: Difficulty.hard,
      ),
    );

    // ═══════════════════════════════════════════════════════════════
    // RIGHT COLUMN (7 tiles, excluding shared corner): Indices 19-25
    // ═══════════════════════════════════════════════════════════════

    // Positions 19-22: 4 Category tiles
    for (int i = 0; i < 4; i++) {
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

    // Position 23: KADER (Fate) - SPECIAL TILE
    tiles.add(
      BoardTile(
        id: '23',
        name: 'KADER',
        position: 23,
        type: TileType.fate,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );

    // Positions 24-25: 2 Category tiles back to start
    for (int i = 0; i < 2; i++) {
      final category = _getCategoryAt(i + 16);
      tiles.add(
        BoardTile(
          id: '${i + 24}',
          name: category.displayName,
          position: i + 24,
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
    return [tiles[0], tiles[6], tiles[12], tiles[18]];
  }

  /// Check if tile is a corner
  static bool isCorner(int id) {
    return cornerIndices.contains(id);
  }

  /// Get all special tiles (Şans and Kader)
  static List<BoardTile> getSpecialTiles() {
    return [tiles[5], tiles[11], tiles[17], tiles[23]];
  }

  /// Check if tile is a special Şans/Kader tile
  static bool isSpecialTile(int id) {
    return id == 5 || id == 11 || id == 17 || id == 23;
  }

  /// Get position info for a tile (row, column, isCorner)
  /// Returns null for invalid IDs
  static TilePosition? getTilePosition(int id) {
    if (id < 0 || id >= 26) return null;

    // Corners
    if (id == 0) {
      return TilePosition(row: 6, col: 6, isCorner: true); // Bottom-Right (START)
    }
    if (id == 6) {
      return TilePosition(row: 6, col: 0, isCorner: true); // Bottom-Left (İMZA GÜNÜ)
    }
    if (id == 12) {
      return TilePosition(row: 0, col: 0, isCorner: true); // Top-Left (KIRAATHANE)
    }
    if (id == 18) {
      return TilePosition(row: 0, col: 6, isCorner: true); // Top-Right (KÜTÜPHANE)
    }

    // Bottom row (indices 1-5, going left from position 0)
    if (id >= 1 && id <= 5) {
      return TilePosition(row: 6, col: 6 - id, isCorner: false);
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
      return TilePosition(row: id - 18, col: 6, isCorner: false);
    }

    return null;
  }
}

/// Position of a tile in the grid
class TilePosition {
  final int row; // 0-6 (top to bottom)
  final int col; // 0-6 (left to right)
  final bool isCorner;

  const TilePosition({
    required this.row,
    required this.col,
    required this.isCorner,
  });
}
