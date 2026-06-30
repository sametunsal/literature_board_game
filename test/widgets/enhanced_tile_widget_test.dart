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
      final size = _realTileSize(tile.position);

      await tester.pumpWidget(
        _tileApp(
          tile,
          players: players,
          width: size.width,
          height: size.height,
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

      // The label measures against the longer side of the (wide-short) tile.
      final longAxisBox = tester.getSize(
        find.byKey(const ValueKey('side-book-label-long-axis-box')),
      );
      expect(longAxisBox.width, greaterThan(longAxisBox.height));

      final textWidget = tester.widget<Text>(find.text(label));
      // Single words stay whole on one rotated line, never fragmented.
      expect(textWidget.maxLines, 1, reason: bookId);
      expect(textWidget.data, isNot(contains('\n')), reason: bookId);
      expect(textWidget.overflow, isNot(TextOverflow.ellipsis));
      final fontSize = textWidget.style!.fontSize!;
      expect(fontSize, greaterThanOrEqualTo(5.0), reason: bookId);
      expect(fontSize, lessThanOrEqualTo(11.0), reason: bookId);
    }
  });

  testWidgets('side book labels are capped below the normal max font size', (
    tester,
  ) async {
    // Side labels measure against the tile long axis, so on a generous tile a
    // short title would otherwise grow to the full 14.0 cap. Verify the
    // orientation-aware cap keeps them at or below 11.0 while the top/bottom
    // label of the same content on the same dimensions is allowed to grow
    // larger — proving the cap is side-specific, not a global shrink. A
    // generous tablet-shaped tile is used so both orientations reach their cap;
    // the side tile keeps the production wide-short shape (width > height).
    final book = BookConfig.books.singleWhere((book) => book.id == 'huzur');
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );
    final label = book.boardLabel ?? book.title;

    await tester.pumpWidget(
      _tileApp(
        tile,
        players: players,
        width: 240,
        height: 160,
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
        height: 160,
        quarterTurns: 0,
      ),
    );
    final topFont = tester.widget<Text>(find.text(label)).style!.fontSize!;
    expect(topFont, greaterThan(sideFont));
  });

  testWidgets('side label collapses an explicit break to one line when it fits', (
    tester,
  ) async {
    // On a large/tablet-scale side tile the rotated long axis is roomy enough to
    // hold the whole title on one real-word line, so Fatih-Harbiye renders
    // "Fatih Harbiye" instead of the blocky two-line "Fatih\nHarbiye". (At phone
    // scale the long axis is far too short — see the fallback test below.)
    final fatih = BookConfig.books.singleWhere(
      (book) => book.id == 'fatih_harbiye',
    );
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == fatih.tilePosition,
    );

    await tester.pumpWidget(
      _tileApp(
        tile,
        players: players,
        width: 240,
        height: 120,
        quarterTurns: 3,
      ),
    );

    expect(find.text('Fatih Harbiye'), findsOneWidget);
    expect(find.text('Fatih\nHarbiye'), findsNothing);
    final textWidget = tester.widget<Text>(find.text('Fatih Harbiye'));
    expect(textWidget.maxLines, 1);
    expect(textWidget.data, isNot(contains('\n')));
    expect(textWidget.overflow, isNot(TextOverflow.ellipsis));
  });

  testWidgets('multi-word side label collapses when the long axis fits it', (
    tester,
  ) async {
    final book = BookConfig.books.singleWhere(
      (book) => book.id == 'kuyucakli_yusuf',
    );
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );

    await tester.pumpWidget(
      _tileApp(
        tile,
        players: players,
        width: 240,
        height: 120,
        quarterTurns: 3,
      ),
    );

    expect(find.text('Kuyucaklı Yusuf'), findsOneWidget);
    expect(find.text(book.boardLabel!), findsNothing);
    expect(tester.widget<Text>(find.text('Kuyucaklı Yusuf')).maxLines, 1);
  });

  testWidgets('multi-word side labels stay two clean lines at phone scale', (
    tester,
  ) async {
    // At real phone geometry the rotated long axis (~45px) cannot hold these
    // titles on one readable line, so they keep their explicit word break
    // ("Fatih\nHarbiye", "Kuyucaklı\nYusuf") — never fragmented, never
    // abbreviated, never ellipsised — using the tighter multi-line side cap.
    for (final bookId in ['fatih_harbiye', 'kuyucakli_yusuf']) {
      final book = BookConfig.books.singleWhere((book) => book.id == bookId);
      final tile = BoardConfig.tiles.singleWhere(
        (tile) => tile.position == book.tilePosition,
      );
      final size = _realTileSize(tile.position);

      await tester.pumpWidget(
        _tileApp(
          tile,
          players: players,
          width: size.width,
          height: size.height,
          quarterTurns: _rotationQuarter(tile.position),
        ),
      );

      expect(find.text(book.boardLabel!), findsOneWidget, reason: bookId);
      final textWidget = tester.widget<Text>(find.text(book.boardLabel!));
      expect(textWidget.maxLines, 2, reason: bookId);
      expect(textWidget.style!.fontSize, lessThanOrEqualTo(10.5), reason: bookId);
      expect(textWidget.overflow, isNot(TextOverflow.ellipsis), reason: bookId);
      // Each line is a whole word — no mid-word fragment.
      for (final line in book.boardLabel!.split('\n')) {
        expect(line.trim(), isNotEmpty, reason: bookId);
      }
    }
  });

  testWidgets('single-word side labels never split into fragments at phone scale', (
    tester,
  ) async {
    // Regression for the real bug: at production phone geometry the rotated long
    // axis is only ~45px, so without the lower single-line side floor an
    // 8-letter word like "Çalıkuşu" fragmented into "Çalık/uşu". It must stay
    // whole on one line.
    for (final bookId in ['calikusu', 'huzur', 'yaban']) {
      final book = BookConfig.books.singleWhere((book) => book.id == bookId);
      final tile = BoardConfig.tiles.singleWhere(
        (tile) => tile.position == book.tilePosition,
      );
      final label = book.boardLabel ?? book.title;
      final size = _realTileSize(tile.position);

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
        textWidget.maxLines,
        1,
        reason: '$bookId side label should stay on one rotated line',
      );
      expect(textWidget.data, isNot(contains('\n')), reason: bookId);
      expect(
        textWidget.overflow,
        isNot(TextOverflow.ellipsis),
        reason: bookId,
      );
      expect(
        textWidget.style!.fontSize,
        greaterThanOrEqualTo(5.0),
        reason: bookId,
      );
    }
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

      await tester.pumpWidget(
        _tileApp(
          tile,
          players: players,
          width: size.width,
          height: size.height,
          quarterTurns: _rotationQuarter(tile.position),
        ),
      );

      // The exact rendered string may differ from the configured boardLabel
      // (side tiles can collapse an explicit break to a single line), so assert
      // against the single label Text the tile actually renders.
      final labelFinder = find.byType(Text);
      expect(labelFinder, findsOneWidget, reason: book.id);
      final textWidget = tester.widget<Text>(labelFinder);
      expect(
        textWidget.overflow,
        isNot(TextOverflow.ellipsis),
        reason: '${book.id} should render without ellipsis',
      );
      expect(textWidget.softWrap, true);
      expect(
        textWidget.data,
        isNot(contains('-\n')),
        reason: '${book.id} must not fragment with a hyphenated break',
      );
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

  testWidgets('Fatih-Harbiye renders as a clean two-word break', (tester) async {
    final book = BookConfig.books.singleWhere(
      (book) => book.id == 'fatih_harbiye',
    );
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );

    await tester.pumpWidget(_tileApp(tile, players: players));

    expect(find.text('Fatih\nHarbiye'), findsOneWidget);
    final textWidget = tester.widget<Text>(find.text('Fatih\nHarbiye'));
    expect(textWidget.data, isNot(contains('-')));
    expect(textWidget.overflow, isNot(TextOverflow.ellipsis));
  });

  testWidgets('Tehlikeli Oyunlar replaces the former tile 14 book', (
    tester,
  ) async {
    final book = BookConfig.books.singleWhere(
      (book) => book.id == 'tehlikeli_oyunlar',
    );
    expect(book.tilePosition, 14);
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );

    await tester.pumpWidget(_tileApp(tile, players: players));

    expect(find.text('Tehlikeli\nOyunlar'), findsOneWidget);
    expect(find.textContaining('Tutuna'), findsNothing);
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

/// Real production tile size for [position] at a given phone [screen]. Side
/// (left/right) tiles are wide-and-short (kLongSide × kShortSide), so the
/// rotated long axis is only ~45–55px at phone scale. Tests must use this
/// geometry — an oversized fake side tile (e.g. 60×240) inverts the long axis
/// and hides what actually renders on a phone.
Size _realTileSize(int position, {Size screen = const Size(360, 800)}) {
  final layout = BoardLayoutConfig(
    screenWidth: screen.width,
    screenHeight: screen.height,
  );
  return BoardLayoutHelper.getTileSize(position, layout);
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
