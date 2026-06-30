import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/game_constants.dart';
import '../../core/services/book_progression_service.dart';
import '../../data/book_config.dart';
import '../../models/book.dart';
import '../../models/book_level.dart';
import '../../models/book_ownership.dart';
import '../../models/game_enums.dart';
import '../../models/player.dart';

class PublishingPortfolioPanel extends StatelessWidget {
  const PublishingPortfolioPanel({
    super.key,
    required this.players,
    required this.bookOwnerships,
    required this.currentPlayerIndex,
  });

  final List<Player> players;
  final Map<String, BookOwnership> bookOwnerships;
  final int currentPlayerIndex;

  @override
  Widget build(BuildContext context) {
    final groups = [
      for (var index = 0; index < players.length; index++)
        _PlayerPortfolioGroup(
          player: players[index],
          books: _ownedBooksFor(players[index].id),
          isCurrentPlayer: index == currentPlayerIndex,
        ),
    ];
    final hasOwnedBooks = groups.any((group) => group.books.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: groups.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) =>
                _PlayerSummaryTile(group: groups[index]),
          ),
        ),
        const SizedBox(height: 12),
        if (!hasOwnedBooks) ...[
          const _EmptyPortfolioNotice(),
          const SizedBox(height: 10),
        ],
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: groups.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _PlayerBookGroupCard(group: groups[index]),
          ),
        ),
      ],
    );
  }

  List<_OwnedBookView> _ownedBooksFor(String playerId) {
    final ownedBooks = <_OwnedBookView>[];
    for (final ownership in bookOwnerships.values) {
      if (ownership.ownerPlayerId != playerId) continue;
      final book = BookConfig.getById(ownership.bookId);
      if (book == null) continue;
      ownedBooks.add(_OwnedBookView(book: book, ownership: ownership));
    }
    ownedBooks.sort(
      (a, b) => a.book.tilePosition.compareTo(b.book.tilePosition),
    );
    return ownedBooks;
  }
}

class _PlayerPortfolioGroup {
  const _PlayerPortfolioGroup({
    required this.player,
    required this.books,
    required this.isCurrentPlayer,
  });

  final Player player;
  final List<_OwnedBookView> books;
  final bool isCurrentPlayer;

  int count(BookLevel level) =>
      books.where((book) => book.ownership.level == level).length;
}

class _OwnedBookView {
  const _OwnedBookView({required this.book, required this.ownership});

  final Book book;
  final BookOwnership ownership;
}

class _PlayerSummaryTile extends StatelessWidget {
  const _PlayerSummaryTile({required this.group});

  final _PlayerPortfolioGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 176,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: group.isCurrentPlayer ? const Color(0xFFEAF3EE) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: group.isCurrentPlayer
              ? const Color(0xFF1A4D42).withValues(alpha: 0.45)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PlayerDot(color: group.player.color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  group.player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF24312D),
                  ),
                ),
              ),
              Text(
                '${group.player.akce} Ak\u00e7e',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8A5A12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (group.isCurrentPlayer) ...[
                const _CurrentPlayerBadge(),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: _ProgressChip(ciltCount: group.count(BookLevel.cilt)),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _CountChip(label: 'Telif', value: group.count(BookLevel.telif)),
              const SizedBox(width: 4),
              _CountChip(
                label: 'Bask\u0131',
                value: group.count(BookLevel.baski),
              ),
              const SizedBox(width: 4),
              _CountChip(label: 'Cilt', value: group.count(BookLevel.cilt)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayerBookGroupCard extends StatelessWidget {
  const _PlayerBookGroupCard({required this.group});

  final _PlayerPortfolioGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: group.isCurrentPlayer
            ? const Color(0xFFEFF6F1)
            : const Color(0xFFF8F6F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: group.isCurrentPlayer
              ? const Color(0xFF1A4D42).withValues(alpha: 0.4)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PlayerDot(color: group.player.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  group.player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF24312D),
                  ),
                ),
              ),
              if (group.isCurrentPlayer) ...[
                const SizedBox(width: 6),
                const _CurrentPlayerBadge(),
              ],
              const SizedBox(width: 8),
              _ProgressChip(ciltCount: group.count(BookLevel.cilt)),
              const SizedBox(width: 8),
              Text(
                '${group.player.akce} Ak\u00e7e',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8A5A12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (group.books.isEmpty)
            Text(
              'Hen\u00fcz kitap yok',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            )
          else
            Column(
              children: [
                for (final ownedBook in group.books)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _OwnedBookRow(ownedBook: ownedBook),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _OwnedBookRow extends StatelessWidget {
  const _OwnedBookRow({required this.ownedBook});

  final _OwnedBookView ownedBook;

  @override
  Widget build(BuildContext context) {
    final level = ownedBook.ownership.level;
    final royalty = BookProgressionService.royaltyForLevel(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ownedBook.book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kategori: ${ownedBook.book.category.displayName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _LevelChip(level: level),
          const SizedBox(width: 6),
          Text(
            'Gelir: $royalty Ak\u00e7e',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5F4A1B),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPortfolioNotice extends StatelessWidget {
  const _EmptyPortfolioNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4C4A8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hen\u00fcz yay\u0131n portf\u00f6y\u00fc olu\u015fmad\u0131.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF24312D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Kitap sat\u0131n al\u0131nd\u0131\u011f\u0131nda burada g\u00f6r\u00fcnecek.',
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _CurrentPlayerBadge extends StatelessWidget {
  const _CurrentPlayerBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4D42),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        'S\u0131ra',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  const _ProgressChip({required this.ciltCount});

  final int ciltCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE6D4),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        'Cilt: $ciltCount/${GameConstants.publishingCiltBooksToWin}',
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF4A3B22),
        ),
      ),
    );
  }
}

class _PlayerDot extends StatelessWidget {
  const _PlayerDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 5),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE6D4),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          '$label $value',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4A3B22),
          ),
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level});

  final BookLevel level;

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      BookLevel.none => Colors.grey,
      BookLevel.telif => const Color(0xFF607D8B),
      BookLevel.baski => const Color(0xFF1976D2),
      BookLevel.cilt => const Color(0xFF7B1FA2),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        _levelLabel(level),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  String _levelLabel(BookLevel level) {
    return switch (level) {
      BookLevel.none => 'Yok',
      BookLevel.telif => 'Telif',
      BookLevel.baski => 'Bask\u0131',
      BookLevel.cilt => 'Cilt',
    };
  }
}
