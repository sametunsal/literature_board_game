import '../models/board_tile.dart';
import '../models/tile_type.dart';
import '../models/difficulty.dart';
import '../models/game_enums.dart';
import '../core/utils/logger.dart';

class BoardConfig {
  static final List<QuestionCategory> _categoryOrder = [
    QuestionCategory.turkEdebiyatindaIlkler,
    QuestionCategory.edebiSanatlar,
    QuestionCategory.eserKarakter,
    QuestionCategory.edebiyatAkimlari,
    QuestionCategory.benKimim,
    QuestionCategory.tesvik,
  ];

  /// GEOMETRY SETTINGS
  /// Width: 7 tiles (5 middle + 2 corners)
  /// Height: 8 tiles (6 middle + 2 corners)
  static const int boardWidth = 7;
  static const int boardHeight = 8;
  static const int boardSize = 26;

  /// CRITICAL: CORNER INDICES (Symmetric Rectangle)
  static const int startPosition = 0; // Bottom-Right
  static const int signingDayPosition = 6; // Bottom-Left Corner
  static const int shopPosition = 13; // Top-Left Corner
  static const int libraryPosition = 19; // Top-Right Corner

  static const List<int> cornerIndices = [0, 6, 13, 19];

  /// SPECIAL TILES (Centered in their rows/cols)
  static const int chancePosition1 = 3; // Bottom Middle
  static const int fatePosition1 = 10; // Left Middle
  static const int chancePosition2 = 16; // Top Middle
  static const int fatePosition2 = 22; // Right Middle

  static List<BoardTile> get tiles {
    return _generateTiles();
  }

  static List<BoardTile> _generateTiles() {
    final tiles = <BoardTile>[];

    // --- BOTTOM ROW (Indices 0-6) ---
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
    tiles.add(
      BoardTile(
        id: '1',
        name: _getCategoryAt(0).displayName,
        position: 1,
        type: TileType.category,
        category: _getCategoryAt(0).name,
        difficulty: Difficulty.easy,
      ),
    );
    tiles.add(
      BoardTile(
        id: '2',
        name: _getCategoryAt(1).displayName,
        position: 2,
        type: TileType.category,
        category: _getCategoryAt(1).name,
        difficulty: Difficulty.easy,
      ),
    );
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
    tiles.add(
      BoardTile(
        id: '4',
        name: _getCategoryAt(2).displayName,
        position: 4,
        type: TileType.category,
        category: _getCategoryAt(2).name,
        difficulty: Difficulty.easy,
      ),
    );
    tiles.add(
      BoardTile(
        id: '5',
        name: _getCategoryAt(3).displayName,
        position: 5,
        type: TileType.category,
        category: _getCategoryAt(3).name,
        difficulty: Difficulty.easy,
      ),
    );
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

    // --- LEFT COLUMN (Indices 7-13) ---
    tiles.add(
      BoardTile(
        id: '7',
        name: _getCategoryAt(4).displayName,
        position: 7,
        type: TileType.category,
        category: _getCategoryAt(4).name,
        difficulty: Difficulty.medium,
      ),
    );
    tiles.add(
      BoardTile(
        id: '8',
        name: 'Teşvik',
        position: 8,
        type: TileType.tesvik,
        category: QuestionCategory.tesvik.name,
        difficulty: Difficulty.medium,
      ),
    );
    tiles.add(
      BoardTile(
        id: '9',
        name: _getCategoryAt(0).displayName,
        position: 9,
        type: TileType.category,
        category: _getCategoryAt(0).name,
        difficulty: Difficulty.medium,
      ),
    );
    tiles.add(
      BoardTile(
        id: '10',
        name: 'KADER',
        position: 10,
        type: TileType.fate,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );
    tiles.add(
      BoardTile(
        id: '11',
        name: _getCategoryAt(1).displayName,
        position: 11,
        type: TileType.category,
        category: _getCategoryAt(1).name,
        difficulty: Difficulty.medium,
      ),
    );
    tiles.add(
      BoardTile(
        id: '12',
        name: _getCategoryAt(2).displayName,
        position: 12,
        type: TileType.category,
        category: _getCategoryAt(2).name,
        difficulty: Difficulty.medium,
      ),
    );
    tiles.add(
      BoardTile(
        id: '13',
        name: 'KIRAATHANE',
        position: 13,
        type: TileType.shop,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );

    // --- TOP ROW (Indices 14-19) ---
    tiles.add(
      BoardTile(
        id: '14',
        name: _getCategoryAt(3).displayName,
        position: 14,
        type: TileType.category,
        category: _getCategoryAt(3).name,
        difficulty: Difficulty.medium,
      ),
    );
    tiles.add(
      BoardTile(
        id: '15',
        name: _getCategoryAt(4).displayName,
        position: 15,
        type: TileType.category,
        category: _getCategoryAt(4).name,
        difficulty: Difficulty.medium,
      ),
    );
    tiles.add(
      BoardTile(
        id: '16',
        name: 'ŞANS',
        position: 16,
        type: TileType.chance,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );
    tiles.add(
      BoardTile(
        id: '17',
        name: 'Teşvik',
        position: 17,
        type: TileType.tesvik,
        category: QuestionCategory.tesvik.name,
        difficulty: Difficulty.medium,
      ),
    );
    tiles.add(
      BoardTile(
        id: '18',
        name: _getCategoryAt(0).displayName,
        position: 18,
        type: TileType.category,
        category: _getCategoryAt(0).name,
        difficulty: Difficulty.medium,
      ),
    );
    tiles.add(
      BoardTile(
        id: '19',
        name: 'KÜTÜPHANE',
        position: 19,
        type: TileType.library,
        category: '',
        difficulty: Difficulty.hard,
      ),
    );

    // --- RIGHT COLUMN (Indices 20-25) ---
    tiles.add(
      BoardTile(
        id: '20',
        name: _getCategoryAt(1).displayName,
        position: 20,
        type: TileType.category,
        category: _getCategoryAt(1).name,
        difficulty: Difficulty.hard,
      ),
    );
    tiles.add(
      BoardTile(
        id: '21',
        name: _getCategoryAt(2).displayName,
        position: 21,
        type: TileType.category,
        category: _getCategoryAt(2).name,
        difficulty: Difficulty.hard,
      ),
    );
    tiles.add(
      BoardTile(
        id: '22',
        name: 'KADER',
        position: 22,
        type: TileType.fate,
        category: '',
        difficulty: Difficulty.medium,
      ),
    );
    tiles.add(
      BoardTile(
        id: '23',
        name: _getCategoryAt(3).displayName,
        position: 23,
        type: TileType.category,
        category: _getCategoryAt(3).name,
        difficulty: Difficulty.hard,
      ),
    );
    tiles.add(
      BoardTile(
        id: '24',
        name: _getCategoryAt(4).displayName,
        position: 24,
        type: TileType.category,
        category: _getCategoryAt(4).name,
        difficulty: Difficulty.hard,
      ),
    );
    tiles.add(
      BoardTile(
        id: '25',
        name: 'Teşvik',
        position: 25,
        type: TileType.tesvik,
        category: QuestionCategory.tesvik.name,
        difficulty: Difficulty.hard,
      ),
    );

    return tiles;
  }

  static QuestionCategory _getCategoryAt(int index) =>
      _categoryOrder[index % 6];
  static List<String> getCategoryNames() =>
      tiles.map((t) => t.category ?? '').toList();
  static BoardTile getTile(int id) {
    if (id < 0 || id >= tiles.length) {
      safePrint(
        '⚠️ ERROR: OOB Tile Access in BoardConfig.getTile! Requested index: $id, Max: ${tiles.length - 1}',
      );
      return tiles[0];
    }
    return tiles[id];
  }

  static List<BoardTile> getCornerTiles() => [
    tiles[0],
    tiles[6],
    tiles[13],
    tiles[19],
  ];
  static bool isCorner(int id) => cornerIndices.contains(id);
  static List<BoardTile> getSpecialTiles() => [
    tiles[3],
    tiles[10],
    tiles[16],
    tiles[22],
  ];
  static bool isSpecialTile(int id) => [3, 10, 16, 22].contains(id);
  static TilePosition? getTilePosition(int id) {
    // Logic layer fallback (Visual layer handles exact placement)
    if (id < 0 || id >= 26) return null;
    return TilePosition(row: 0, col: 0, isCorner: isCorner(id));
  }
}

class TilePosition {
  final int row;
  final int col;
  final bool isCorner;
  const TilePosition({
    required this.row,
    required this.col,
    required this.isCorner,
  });
}
