import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/data/book_config.dart';
import 'package:literature_board_game/models/book_level.dart';
import 'package:literature_board_game/models/book_ownership.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/presentation/widgets/board/game_controls_overlay.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

void main() {
  testWidgets('publishing debug panel shows Akce and owned books', (
    tester,
  ) async {
    final book = BookConfig.books.first;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameProvider.overrideWith((ref) {
            final notifier = GameNotifier(ref);
            notifier.updateState(
              GameState(
                players: const [
                  Player(
                    id: 'p1',
                    name: 'Player 1',
                    color: Colors.red,
                    iconIndex: 0,
                    stars: 12,
                  ),
                ],
                tiles: BoardConfig.tiles,
                phase: GamePhase.playerTurn,
                bookOwnerships: {
                  book.id: BookOwnership(
                    bookId: book.id,
                    ownerPlayerId: 'p1',
                    level: BookLevel.baski,
                  ),
                },
              ),
            );
            return notifier;
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: GameControlsOverlay())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Publishing Debug'), findsOneWidget);
    expect(find.text('Player 1 Akce: 12'), findsOneWidget);
    expect(
      find.text('${book.title}: ${BookLevel.baski.displayName}'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Publishing debug'));
    await tester.pumpAndSettle();

    expect(
      find.text('Jump + Ask: ${book.title} (${book.tilePosition})'),
      findsOneWidget,
    );
    expect(
      find.text('Prep Cilt: ${book.title} (${book.tilePosition})'),
      findsOneWidget,
    );
  });
}
