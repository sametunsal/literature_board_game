import '../models/board_tile.dart';
import '../models/tile_type.dart';
import '../models/difficulty.dart';
import '../models/game_enums.dart';
import '../core/utils/board_topology.dart';
import '../core/utils/logger.dart';
import 'book_config.dart';

class BoardConfig {
  /// GEOMETRY SETTINGS — single source of truth for the perimeter shape.
  /// Standard topology: 7 middle tiles bottom/top, 4 left/right → 26 tiles,
  /// landscape aspect 10:7.
  static const BoardTopology topology = BoardTopology.standard;

  /// Width: 9 tiles (7 middle + 2 corners)
  static int get boardWidth => topology.horizontalMiddleCount + 2;

  /// Height: 6 tiles (4 middle + 2 corners)
  static int get boardHeight => topology.verticalMiddleCount + 2;

  static int get boardSize => topology.boardSize;

  /// CRITICAL: CORNER INDICES (Symmetric Rectangle)
  static int get startPosition => topology.bottomRightCorner; // 0
  static int get signingDayPosition => topology.bottomLeftCorner; // 8
  static int get shopPosition => topology.topLeftCorner; // 13
  static int get libraryPosition => topology.topRightCorner; // 21

  static List<int> get cornerIndices => topology.cornerIndices;

  /// SPECIAL TILES
  /// Şans sits at the center of each horizontal run (1..7 → 4, 14..20 → 17).
  /// Kader sits second-from-bottom on each vertical run (9..12 → 10,
  /// 22..25 → 24), mirror-symmetric across the board's vertical axis.
  static const int chancePosition1 = 4; // Bottom middle center
  static const int fatePosition1 = 10; // Left column, lower half
  static const int chancePosition2 = 17; // Top middle center
  static const int fatePosition2 = 24; // Right column, lower half

  /// Bonus-question tiles: one per non-bottom side (left, top, right), as on
  /// the pre-redesign board. Short single-word label tolerates rotated side
  /// tiles, freeing horizontal tiles for long book titles.
  static const List<int> tesvikPositions = [11, 16, 25];

  /// Question difficulty per category (book) tile. Preserves each book's
  /// pre-redesign tile difficulty so rewards and question selection keep
  /// their balance: 8–10 akçe starters easy, mid-cost books medium, the four
  /// 16-akçe books hard.
  static const Map<int, Difficulty> _categoryTileDifficulty = {
    1: Difficulty.easy, // İntibah
    2: Difficulty.easy, // Araba Sevdası
    3: Difficulty.easy, // Aşk-ı Memnu
    5: Difficulty.easy, // Sinekli Bakkal
    6: Difficulty.medium, // Kuyucaklı Yusuf
    7: Difficulty.medium, // Fatih-Harbiye
    9: Difficulty.medium, // Çalıkuşu
    12: Difficulty.medium, // Dokuzuncu Hariciye Koğuşu
    14: Difficulty.medium, // Tehlikeli Oyunlar
    15: Difficulty.medium, // İnce Memed
    18: Difficulty.medium, // Saatleri Ayarlama Enstitüsü
    19: Difficulty.hard, // Kiralık Konak
    20: Difficulty.hard, // Mai ve Siyah
    22: Difficulty.hard, // Huzur
    23: Difficulty.hard, // Yaban
  };

  static const Map<int, Difficulty> _tesvikDifficulty = {
    11: Difficulty.medium, // Left column
    16: Difficulty.medium, // Top row
    25: Difficulty.hard, // Right column
  };

  static List<BoardTile> get tiles {
    return _generateTiles();
  }

  static List<BoardTile> _generateTiles() =>
      List<BoardTile>.generate(boardSize, _tileAt);

  static BoardTile _tileAt(int position) {
    if (position == startPosition) {
      return BoardTile(
        id: '$position',
        name: 'BAŞLANGIÇ',
        position: position,
        type: TileType.start,
        category: '',
        difficulty: Difficulty.easy,
      );
    }
    if (position == signingDayPosition) {
      return BoardTile(
        id: '$position',
        name: 'İMZA GÜNÜ',
        position: position,
        type: TileType.signingDay,
        category: '',
        difficulty: Difficulty.medium,
      );
    }
    if (position == shopPosition) {
      return BoardTile(
        id: '$position',
        name: 'KIRAATHANE',
        position: position,
        type: TileType.shop,
        category: '',
        difficulty: Difficulty.medium,
      );
    }
    if (position == libraryPosition) {
      return BoardTile(
        id: '$position',
        name: 'KÜTÜPHANE',
        position: position,
        type: TileType.library,
        category: '',
        difficulty: Difficulty.hard,
      );
    }
    if (position == chancePosition1 || position == chancePosition2) {
      return BoardTile(
        id: '$position',
        name: 'ŞANS',
        position: position,
        type: TileType.chance,
        category: '',
        difficulty: Difficulty.medium,
      );
    }
    if (position == fatePosition1 || position == fatePosition2) {
      return BoardTile(
        id: '$position',
        name: 'KADER',
        position: position,
        type: TileType.fate,
        category: '',
        difficulty: Difficulty.medium,
      );
    }
    if (tesvikPositions.contains(position)) {
      return BoardTile(
        id: '$position',
        name: 'Teşvik',
        position: position,
        type: TileType.tesvik,
        category: QuestionCategory.tesvik.name,
        difficulty: _tesvikDifficulty[position]!,
      );
    }

    // Every remaining perimeter tile is a category tile carrying a book; the
    // tile's category and label derive from that book so they can never
    // drift apart.
    final book = BookConfig.getByTilePosition(position);
    assert(
      book != null,
      'Category tile $position has no book mapped in BookConfig',
    );
    if (book == null) {
      safePrint('⚠️ ERROR: Category tile $position has no book in BookConfig');
      return BoardTile(
        id: '$position',
        name: 'KATEGORİ',
        position: position,
        type: TileType.category,
        category: '',
        difficulty: Difficulty.medium,
      );
    }
    return BoardTile(
      id: '$position',
      name: book.category.displayName,
      position: position,
      type: TileType.category,
      category: book.category.name,
      bookId: book.id,
      difficulty: _categoryTileDifficulty[position] ?? Difficulty.medium,
    );
  }

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

  static List<BoardTile> getCornerTiles() =>
      cornerIndices.map(getTile).toList();
  static bool isCorner(int id) => topology.isCorner(id);
  static List<BoardTile> getSpecialTiles() => [
    tiles[chancePosition1],
    tiles[fatePosition1],
    tiles[chancePosition2],
    tiles[fatePosition2],
  ];
  static bool isSpecialTile(int id) =>
      id == chancePosition1 ||
      id == fatePosition1 ||
      id == chancePosition2 ||
      id == fatePosition2;
  static TilePosition? getTilePosition(int id) {
    // Logic layer fallback (Visual layer handles exact placement)
    if (!topology.isValidTile(id)) return null;
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
