import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/presentation/widgets/board/flapping_deck_card.dart';
import 'package:literature_board_game/presentation/widgets/board/monopoly_style_deck_cards.dart';

void main() {
  testWidgets('FlappingDeckCard animates deck cards with fixed-duration pumps '
      'and disposes cleanly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              FlappingDeckCard(
                child: MonopolyStyleDeckCard(
                  type: CardType.sans,
                  width: 64,
                  height: 90,
                ),
              ),
              SizedBox(width: 24),
              FlappingDeckCard(
                phase: 0.5,
                child: MonopolyStyleDeckCard(
                  type: CardType.kader,
                  width: 64,
                  height: 90,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(FlappingDeckCard), findsNWidgets(2));

    // The idle flap repeats forever, so advance time explicitly instead of
    // pumpAndSettle. Several pumps across the 2s cycle must not throw.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);

    // Tearing down the tree must dispose both controllers without errors.
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
