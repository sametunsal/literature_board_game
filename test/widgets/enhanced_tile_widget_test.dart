import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

    expect(find.text(book.title), findsOneWidget);
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

    expect(find.text(book.title), findsOneWidget);
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

  testWidgets('long book title stays within two lines with ellipsis', (
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
    expect(textWidget.overflow, TextOverflow.ellipsis);
    expect(textWidget.softWrap, true);
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

    expect(find.text('Saatler Enstitüsü'), findsOneWidget);
    expect(find.text('Saatleri Ayarlama Enstitüsü'), findsNothing);
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
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: EnhancedTileWidget(
          tile: tile,
          players: players,
          bookOwnerships: bookOwnerships,
          width: 100,
          height: 60,
        ),
      ),
    ),
  );
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
