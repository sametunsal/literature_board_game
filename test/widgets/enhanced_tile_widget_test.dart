import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/utils/board_layout_config.dart';
import 'package:literature_board_game/core/utils/board_layout_helper.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/data/book_config.dart';
import 'package:literature_board_game/models/book_level.dart';
import 'package:literature_board_game/models/book_ownership.dart';
import 'package:literature_board_game/models/board_tile.dart';
import 'package:literature_board_game/models/difficulty.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/models/tile_type.dart';
import 'package:literature_board_game/presentation/widgets/board/tile_widget.dart';
import 'package:literature_board_game/presentation/widgets/enhanced_tile_widget.dart';

void main() {
  final players = [
    const Player(id: 'p1', name: 'Player 1', color: Colors.red, iconIndex: 1),
    const Player(id: 'p2', name: 'Player 2', color: Colors.blue, iconIndex: 2),
  ];

  testWidgets('book tile without ownership shows no chips', (tester) async {
    final book = BookConfig.books.first;
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );

    await tester.pumpWidget(_tileApp(tile, players: players));

    expect(find.text(book.title), findsOneWidget);
    expect(find.text('T'), findsNothing);
    expect(find.text('B'), findsNothing);
    expect(find.text('C'), findsNothing);
  });

  testWidgets('owned Telif book shows owner marker and T chip', (tester) async {
    final book = BookConfig.books.first;
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );

    await tester.pumpWidget(
      _tileApp(
        tile,
        players: players,
        bookOwnerships: {
          book.id: BookOwnership(
            bookId: book.id,
            ownerPlayerId: players.first.id,
            level: BookLevel.telif,
          ),
        },
      ),
    );

    expect(find.text(book.title), findsOneWidget);
    expect(find.text('T'), findsOneWidget);
    expect(find.text('B'), findsNothing);
    expect(find.text('C'), findsNothing);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('owned book with no level shows player number', (tester) async {
    final book = BookConfig.books.first;
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );

    await tester.pumpWidget(
      _tileApp(
        tile,
        players: players,
        bookOwnerships: {
          book.id: BookOwnership(
            bookId: book.id,
            ownerPlayerId: players.first.id,
            level: BookLevel.none,
          ),
        },
      ),
    );

    expect(find.text(book.title), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('T'), findsNothing);
    expect(find.text('B'), findsNothing);
    expect(find.text('C'), findsNothing);
  });

  testWidgets('owned Baski book shows B chip', (tester) async {
    final book = BookConfig.books[1];
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );

    await tester.pumpWidget(
      _tileApp(
        tile,
        players: players,
        bookOwnerships: {
          book.id: BookOwnership(
            bookId: book.id,
            ownerPlayerId: players[1].id,
            level: BookLevel.baski,
          ),
        },
      ),
    );

    expect(find.text(book.boardLabel ?? book.title), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('T'), findsNothing);
    expect(find.text('C'), findsNothing);
    expect(find.text('2'), findsNothing);
  });

  testWidgets('owned Cilt book shows C chip', (tester) async {
    final book = BookConfig.books[2];
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );

    await tester.pumpWidget(
      _tileApp(
        tile,
        players: players,
        bookOwnerships: {
          book.id: BookOwnership(
            bookId: book.id,
            ownerPlayerId: players.first.id,
            level: BookLevel.cilt,
          ),
        },
      ),
    );

    expect(find.text(book.boardLabel ?? book.title), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('T'), findsNothing);
    expect(find.text('B'), findsNothing);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('special tile label remains unchanged', (tester) async {
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.type == TileType.shop,
    );

    await tester.pumpWidget(_tileApp(tile));

    expect(find.text('KIRAATHANE'), findsOneWidget);
    expect(find.text('T'), findsNothing);
    expect(find.text('B'), findsNothing);
    expect(find.text('C'), findsNothing);
  });

  testWidgets('category tile without book falls back to tile name', (
    tester,
  ) async {
    const tile = BoardTile(
      id: 'fallback',
      name: 'Fallback Category',
      position: 99,
      type: TileType.category,
      category: 'benKimim',
      difficulty: Difficulty.easy,
    );

    await tester.pumpWidget(_tileApp(tile));

    expect(find.text('Fallback Category'), findsOneWidget);
  });

  testWidgets('book title has no FittedBox ancestor', (tester) async {
    final book = BookConfig.books.first;
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );

    await tester.pumpWidget(_tileApp(tile, players: players));

    expect(find.text(book.title), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text(book.title),
        matching: find.byType(FittedBox),
      ),
      findsNothing,
    );
  });

  testWidgets('long book title uses compact board label without ellipsis', (
    tester,
  ) async {
    final book = BookConfig.books.singleWhere(
      (book) => book.id == 'dokuzuncu_hariciye_kogusu',
    );
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );

    await tester.pumpWidget(_tileApp(tile, players: players));

    expect(find.text(book.title), findsNothing);
    expect(find.text(book.boardLabel!), findsOneWidget);

    final textWidget = tester.widget<Text>(find.text(book.boardLabel!));
    expect(textWidget.maxLines, 2);
    expect(textWidget.overflow, isNot(TextOverflow.ellipsis));
    expect(textWidget.softWrap, true);
  });

  testWidgets('label grows past the old 9pt cap on a generous tile', (
    tester,
  ) async {
    final book = BookConfig.books.singleWhere((book) => book.id == 'huzur');
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );

    await tester.pumpWidget(
      _tileApp(tile, players: players, width: 240, height: 150),
    );

    final label = book.boardLabel ?? book.title;
    final textWidget = tester.widget<Text>(find.text(label));
    // Old behavior pinned every label at 9.0; it should now scale up.
    expect(textWidget.style!.fontSize, greaterThan(9.0));
    expect(textWidget.style!.letterSpacing, 0);
    expect(textWidget.strutStyle, isNotNull);
  });

  testWidgets('board tile prefers boardLabel for long book titles', (
    tester,
  ) async {
    final book = BookConfig.books.singleWhere(
      (book) => book.id == 'saatleri_ayarlama_enstitusu',
    );
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );

    await tester.pumpWidget(_tileApp(tile, players: players));

    expect(find.text('Saatleri\nAyarlama\nEnstitüsü'), findsOneWidget);
    expect(find.text('Saatleri Ayarlama Enstitüsü'), findsNothing);
  });

  testWidgets('three-line board label renders with maxLines 3', (tester) async {
    final book = BookConfig.books.singleWhere(
      (book) => book.id == 'saatleri_ayarlama_enstitusu',
    );
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );

    await tester.pumpWidget(_tileApp(tile, players: players));

    final textWidget = tester.widget<Text>(find.text(book.boardLabel!));
    expect(textWidget.maxLines, 3);
    expect(textWidget.overflow, isNot(TextOverflow.ellipsis));
    expect(textWidget.softWrap, true);
    expect('\n'.allMatches(textWidget.data!).length, 2);
  });

  testWidgets('two-line board label renders with maxLines 2', (tester) async {
    final book = BookConfig.books.singleWhere(
      (book) => book.id == 'araba_sevdasi',
    );
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );

    await tester.pumpWidget(_tileApp(tile, players: players));

    expect(find.text(book.title), findsNothing);
    final textWidget = tester.widget<Text>(find.text(book.boardLabel!));
    expect(textWidget.maxLines, 2);
    expect(textWidget.overflow, isNot(TextOverflow.ellipsis));
  });

  testWidgets('side book tile labels rotate using the long-axis constraint', (
    tester,
  ) async {
    for (final bookId in ['calikusu', 'huzur', 'yaban']) {
      final book = BookConfig.books.singleWhere((book) => book.id == bookId);
      final tile = BoardConfig.tiles.singleWhere(
        (tile) => tile.position == book.tilePosition,
      );
      final label = book.boardLabel ?? book.title;

      await tester.pumpWidget(
        _tileApp(
          tile,
          players: players,
          width: 60,
          height: 150,
          quarterTurns: _rotationQuarter(tile.position),
        ),
      );

      expect(find.text(label), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text(label),
          matching: find.byKey(const ValueKey('side-book-label-long-axis-box')),
        ),
        findsOneWidget,
        reason: '$bookId should be laid out in the side long-axis box',
      );

      final longAxisBox = tester.getSize(
        find.byKey(const ValueKey('side-book-label-long-axis-box')),
      );
      expect(longAxisBox.width, greaterThan(longAxisBox.height));
      expect(longAxisBox.width, greaterThanOrEqualTo(130));

      final textWidget = tester.widget<Text>(find.text(label));
      expect(textWidget.style!.fontSize, greaterThan(9));
      expect(textWidget.overflow, isNot(TextOverflow.ellipsis));
      expect(label, isNot(contains('\n')));
    }
  });

  testWidgets('side book labels are capped below the normal max font size', (
    tester,
  ) async {
    // Side labels measure against the tile long axis, so on a generous tile a
    // short title would otherwise grow to the full 14.0 cap. Verify the
    // orientation-aware cap keeps them at or below 11.0 while the top/bottom
    // label of the same content on the same dimensions is allowed to grow
    // larger — proving the cap is side-specific, not a global shrink.
    final book = BookConfig.books.singleWhere((book) => book.id == 'huzur');
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );
    final label = book.boardLabel ?? book.title;

    await tester.pumpWidget(
      _tileApp(
        tile,
        players: players,
        width: 60,
        height: 240,
        quarterTurns: 1,
      ),
    );
    final sideFont = tester.widget<Text>(find.text(label)).style!.fontSize!;
    expect(sideFont, lessThanOrEqualTo(11.0));
    expect(sideFont, greaterThan(9.0));

    await tester.pumpWidget(
      _tileApp(
        tile,
        players: players,
        width: 240,
        height: 240,
        quarterTurns: 0,
      ),
    );
    final topFont = tester.widget<Text>(find.text(label)).style!.fontSize!;
    expect(topFont, greaterThan(sideFont));
  });

  testWidgets('multi-line side labels use a tighter cap than single-line ones', (
    tester,
  ) async {
    // Both rendered on the same generous side tile. The single-word label can
    // reach the normal 11.0 side cap, while the two-line label is held to the
    // tighter 10.5 multi-line cap so it does not read larger/bolder than its
    // single-line neighbours.
    final huzur = BookConfig.books.singleWhere((book) => book.id == 'huzur');
    final huzurTile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == huzur.tilePosition,
    );
    await tester.pumpWidget(
      _tileApp(
        huzurTile,
        players: players,
        width: 60,
        height: 240,
        quarterTurns: 1,
      ),
    );
    final singleLineFont = tester
        .widget<Text>(find.text(huzur.boardLabel ?? huzur.title))
        .style!
        .fontSize!;

    final fatih = BookConfig.books.singleWhere(
      (book) => book.id == 'fatih_harbiye',
    );
    final fatihTile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == fatih.tilePosition,
    );
    await tester.pumpWidget(
      _tileApp(
        fatihTile,
        players: players,
        width: 60,
        height: 240,
        quarterTurns: 3,
      ),
    );
    final multiLineLabel = fatih.boardLabel!;
    expect(multiLineLabel, contains('\n'));
    final multiLineFont = tester
        .widget<Text>(find.text(multiLineLabel))
        .style!
        .fontSize!;

    expect(multiLineFont, lessThanOrEqualTo(10.5));
    expect(multiLineFont, greaterThan(9.0));
    expect(multiLineFont, lessThan(singleLineFont));
  });

  testWidgets('top and bottom book labels render normally without rotation', (
    tester,
  ) async {
    for (final bookId in ['intibah', 'ince_memed']) {
      final book = BookConfig.books.singleWhere((book) => book.id == bookId);
      final tile = BoardConfig.tiles.singleWhere(
        (tile) => tile.position == book.tilePosition,
      );
      final label = book.boardLabel ?? book.title;

      await tester.pumpWidget(
        _tileApp(
          tile,
          players: players,
          width: 60,
          height: 150,
          quarterTurns: _rotationQuarter(tile.position),
        ),
      );

      expect(find.text(label), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text(label),
          matching: find.byKey(const ValueKey('side-book-label-long-axis-box')),
        ),
        findsNothing,
      );
    }
  });

  testWidgets('all rendered board book labels avoid ellipsis at board scale', (
    tester,
  ) async {
    final layout = BoardLayoutConfig(screenWidth: 1920, screenHeight: 1080);

    for (final book in BookConfig.books) {
      final tile = BoardConfig.tiles.singleWhere(
        (tile) => tile.position == book.tilePosition,
      );
      final size = BoardLayoutHelper.getTileSize(tile.position, layout);
      final label = book.boardLabel ?? book.title;

      await tester.pumpWidget(
        _tileApp(
          tile,
          players: players,
          width: size.width,
          height: size.height,
          quarterTurns: _rotationQuarter(tile.position),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(label));
      expect(
        textWidget.overflow,
        isNot(TextOverflow.ellipsis),
        reason: '${book.id} should render without ellipsis',
      );
      expect(textWidget.softWrap, true);
    }
  });

  testWidgets('tile widget forwards ownership data to the tile renderer', (
    tester,
  ) async {
    final book = BookConfig.books.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox.expand(
            child: Stack(
              children: [
                TileWidget(
                  id: book.tilePosition,
                  left: 0,
                  top: 0,
                  width: 100,
                  height: 60,
                  rotation: 0,
                  players: players,
                  bookOwnerships: {
                    book.id: BookOwnership(
                      bookId: book.id,
                      ownerPlayerId: players.first.id,
                      level: BookLevel.telif,
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text(book.title), findsOneWidget);
    expect(find.text('T'), findsOneWidget);
  });

  testWidgets('short single-word title stays on one line on a roomy tile', (
    tester,
  ) async {
    for (final bookId in ['calikusu', 'intibah', 'huzur', 'yaban']) {
      final book = BookConfig.books.singleWhere((book) => book.id == bookId);
      final tile = BoardConfig.tiles.singleWhere(
        (tile) => tile.position == book.tilePosition,
      );
      final label = book.boardLabel ?? book.title;

      await tester.pumpWidget(
        _tileApp(tile, players: players, width: 240, height: 150),
      );

      final textWidget = tester.widget<Text>(find.text(label));
      expect(
        textWidget.maxLines,
        1,
        reason: '$bookId should prefer a single line by shrinking the font',
      );
      expect(textWidget.data, isNot(contains('\n')), reason: bookId);
      expect(textWidget.overflow, isNot(TextOverflow.ellipsis), reason: bookId);
    }
  });

  testWidgets('single word breaks only when it cannot fit on one line', (
    tester,
  ) async {
    final book = BookConfig.books.singleWhere((book) => book.id == 'calikusu');
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );
    final label = book.boardLabel ?? book.title;

    // A very narrow, short tile cannot hold the word on one line even at the
    // minimum font size, so a controlled wrap (not an ellipsis) is allowed.
    await tester.pumpWidget(
      _tileApp(tile, players: players, width: 24, height: 44),
    );

    final textWidget = tester.widget<Text>(find.text(label));
    expect(textWidget.maxLines, greaterThan(1));
    expect(textWidget.overflow, isNot(TextOverflow.ellipsis));
  });

  testWidgets('Teşvik label is readable but capped below book labels', (
    tester,
  ) async {
    final tesvikTile = BoardConfig.tiles.firstWhere(
      (tile) => tile.type == TileType.tesvik,
    );

    await tester.pumpWidget(
      _tileApp(tesvikTile, players: players, width: 240, height: 240),
    );
    final tesvikFont = tester
        .widget<Text>(find.text(tesvikTile.name))
        .style!
        .fontSize!;
    // Readable, but reduced so it does not dwarf neighbouring labels.
    expect(tesvikFont, greaterThan(8.0));
    expect(tesvikFont, lessThanOrEqualTo(10.5));

    // The same generous tile lets a single-word book label grow larger,
    // proving the cap is specific to short action tiles.
    final book = BookConfig.books.singleWhere((book) => book.id == 'huzur');
    final bookTile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );
    await tester.pumpWidget(
      _tileApp(bookTile, players: players, width: 240, height: 240),
    );
    final bookFont = tester
        .widget<Text>(find.text(book.boardLabel ?? book.title))
        .style!
        .fontSize!;
    expect(bookFont, greaterThan(tesvikFont));
  });

  testWidgets('book strip thickness is 12.0', (tester) async {
    final book = BookConfig.books.first;
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );

    await tester.pumpWidget(_tileApp(tile, players: players));

    final stripFinder = find.byWidgetPredicate(
      (widget) => widget is Container && widget.color == _tileColor(tile),
    );

    expect(stripFinder, findsOneWidget);
    expect(tester.getSize(stripFinder).height, 12.0);
  });
}

Widget _tileApp(
  BoardTile tile, {
  List<Player> players = const [],
  Map<String, BookOwnership> bookOwnerships = const {},
  double width = 100,
  double height = 60,
  int quarterTurns = 0,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: EnhancedTileWidget(
          tile: tile,
          players: players,
          bookOwnerships: bookOwnerships,
          width: width,
          height: height,
          quarterTurns: quarterTurns,
        ),
      ),
    ),
  );
}

int _rotationQuarter(int id) {
  if ([0, 6, 13, 19].contains(id)) return 0;
  if (id >= 1 && id <= 5) return 0;
  if (id >= 7 && id <= 12) return 3;
  if (id >= 14 && id <= 18) return 2;
  return 1;
}

Color _tileColor(BoardTile tile) {
  switch (tile.category) {
    case 'turkEdebiyatindaIlkler':
      return const Color(0xFF2196F3);
    case 'edebiSanatlar':
      return const Color(0xFF9C27B0);
    case 'eserKarakter':
      return const Color(0xFFE65100);
    case 'edebiyatAkimlari':
      return const Color(0xFF2E7D32);
    case 'benKimim':
      return const Color(0xFFD32F2F);
    case 'tesvik':
      return const Color(0xFF00838F);
    default:
      return Colors.grey;
  }
}
