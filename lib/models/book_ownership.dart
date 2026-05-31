import 'book_level.dart';

/// Mutable session state for a book property's current owner and level.
class BookOwnership {
  final String bookId;
  final String ownerPlayerId;
  final BookLevel level;

  const BookOwnership({
    required this.bookId,
    required this.ownerPlayerId,
    required this.level,
  });

  BookOwnership copyWith({
    String? bookId,
    String? ownerPlayerId,
    BookLevel? level,
  }) {
    return BookOwnership(
      bookId: bookId ?? this.bookId,
      ownerPlayerId: ownerPlayerId ?? this.ownerPlayerId,
      level: level ?? this.level,
    );
  }
}
