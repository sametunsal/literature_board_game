import '../../data/board_config.dart';
import '../../data/book_config.dart';
import '../../models/board_tile.dart';
import '../../models/book.dart';
import '../../models/tile_type.dart';

/// Read-only Publishing MVP lookup helpers for board/book metadata.
class BoardBookLookupService {
  const BoardBookLookupService._();

  static Book? bookForTile(BoardTile tile) {
    if (!isBookTile(tile)) return null;
    return BookConfig.getById(tile.bookId!);
  }

  static Book? bookAtPosition(int position, {List<BoardTile>? tiles}) {
    final tile = _tileAtPosition(position, tiles ?? BoardConfig.tiles);
    if (tile == null) return null;
    return bookForTile(tile);
  }

  static bool isBookTile(BoardTile tile) {
    final bookId = tile.bookId;
    if (tile.type != TileType.category || bookId == null) return false;

    final book = BookConfig.getById(bookId);
    return book != null && book.tilePosition == tile.position;
  }

  static List<BoardTile> bookTiles({List<BoardTile>? tiles}) {
    return (tiles ?? BoardConfig.tiles).where(isBookTile).toList();
  }

  static BoardTile? _tileAtPosition(int position, List<BoardTile> tiles) {
    for (final tile in tiles) {
      if (tile.position == position) return tile;
    }
    return null;
  }
}
