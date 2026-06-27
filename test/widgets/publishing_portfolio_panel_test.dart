import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/data/book_config.dart';
import 'package:literature_board_game/models/book.dart';
import 'package:literature_board_game/models/book_level.dart';
import 'package:literature_board_game/models/book_ownership.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/presentation/widgets/board/game_controls_overlay.dart';
import 'package:literature_board_game/presentation/widgets/publishing_portfolio_panel.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

void main() {
  testWidgets('portfolio groups books by player and shows assets', (
    tester,
  ) async {
    final books = BookConfig.books;
    final ownerships = {
      books[0].id: BookOwnership(
        bookId: books[0].id,
        ownerPlayerId: 'p1',
        level: BookLevel.telif,
      ),
      books[1].id: BookOwnership(
        bookId: books[1].id,
        ownerPlayerId: 'p1',
        level: BookLevel.baski,
      ),
      books[2].id: BookOwnership(
        bookId: books[2].id,
        ownerPlayerId: 'p1',
        level: BookLevel.cilt,
      ),
      books[3].id: BookOwnership(
        bookId: books[3].id,
        ownerPlayerId: 'p2',
        level: BookLevel.cilt,
      ),
    };

    await tester.pumpWidget(_panelApp(ownerships));

    expect(find.text('Player 1'), findsWidgets);
    expect(find.text('Player 2'), findsWidgets);
    expect(find.text('Player 1 Akce: 24'), findsNothing);
    expect(find.text('24 Ak\u00e7e'), findsWidgets);
    expect(find.text('7 Ak\u00e7e'), findsWidgets);

    expect(find.text('Telif 1'), findsOneWidget);
    expect(find.text('Bask\u0131 1'), findsOneWidget);
    expect(find.text('Cilt 1'), findsWidgets);

    expect(find.text(books[0].title), findsOneWidget);
    expect(find.text(books[1].title), findsOneWidget);
    expect(find.text(books[2].title), findsOneWidget);
    expect(find.text(books[3].title), findsOneWidget);

    expect(find.text('Telif'), findsOneWidget);
    expect(find.text('Bask\u0131'), findsOneWidget);
    expect(find.text('Cilt'), findsNWidgets(2));
    expect(
      find.text('Kategori: ${books[0].category.displayName}'),
      findsOneWidget,
    );
    expect(find.text('Telif 2'), findsOneWidget);
    expect(find.text('Telif 4'), findsOneWidget);
    expect(find.text('Telif 6'), findsNWidgets(2));
    expect(find.text('Hen\u00fcz kitap yok'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('portfolio stays within compact landscape constraints', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 280);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final books = BookConfig.books;
    final ownerships = {
      for (var i = 0; i < 8; i++)
        books[i].id: BookOwnership(
          bookId: books[i].id,
          ownerPlayerId: i.isEven ? 'p1' : 'p2',
          level: BookLevel.values[(i % 3) + 1],
        ),
    };

    await tester.pumpWidget(_panelApp(ownerships));

    expect(find.byType(PublishingPortfolioPanel), findsOneWidget);
    expect(find.byType(ListView), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('GameControlsOverlay button opens portfolio modal', (
    tester,
  ) async {
    final book = BookConfig.books.first;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          _gameOverride({book.id: _ownership(book, 'p1')}),
        ],
        child: const MaterialApp(home: Scaffold(body: GameControlsOverlay())),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Publishing portfolio'));
    await tester.pumpAndSettle();

    expect(find.text('Yay\u0131n Portf\u00f6y\u00fc'), findsOneWidget);
    expect(find.text(book.title), findsOneWidget);
    expect(find.text('24 Ak\u00e7e'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

Widget _panelApp(Map<String, BookOwnership> ownerships) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: PublishingPortfolioPanel(
            players: _players,
            bookOwnerships: ownerships,
          ),
        ),
      ),
    ),
  );
}

Override _gameOverride(Map<String, BookOwnership> ownerships) {
  return gameProvider.overrideWith((ref) {
    final notifier = GameNotifier(ref);
    notifier.updateState(
      GameState(
        players: _players,
        tiles: BoardConfig.tiles,
        phase: GamePhase.playerTurn,
        bookOwnerships: ownerships,
      ),
    );
    return notifier;
  });
}

BookOwnership _ownership(Book book, String playerId) {
  return BookOwnership(
    bookId: book.id,
    ownerPlayerId: playerId,
    level: BookLevel.telif,
  );
}

const _players = [
  Player(
    id: 'p1',
    name: 'Player 1',
    color: Colors.red,
    iconIndex: 0,
    stars: 24,
  ),
  Player(
    id: 'p2',
    name: 'Player 2',
    color: Colors.blue,
    iconIndex: 1,
    stars: 7,
  ),
  Player(
    id: 'p3',
    name: 'Player 3',
    color: Colors.green,
    iconIndex: 2,
    stars: 0,
  ),
];
