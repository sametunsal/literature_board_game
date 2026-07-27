import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:literature_board_game/models/game_card.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/presentation/dialogs/card_dialog.dart';
import 'package:literature_board_game/presentation/widgets/board/monopoly_style_deck_cards.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  for (final type in CardType.values) {
    testWidgets('${type.name} deck renders at compact size without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MonopolyStyleDeckCard(type: type, width: 64, height: 90),
            ),
          ),
        ),
      );

      expect(find.byType(MonopolyStyleDeckCard), findsOneWidget);
      // Deck identity is conveyed by iconography alone — no text labels.
      expect(
        find.descendant(
          of: find.byType(MonopolyStyleDeckCard),
          matching: find.byType(Text),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('${type.name} deck stack stays inside its layout box', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MonopolyStyleDeckCard(type: type, width: 64, height: 90),
            ),
          ),
        ),
      );

      // Backing layers add depth *within* the given box — the centre area
      // positions decks by this exact size, so it must not grow.
      expect(
        tester.getSize(find.byType(MonopolyStyleDeckCard)),
        const Size(64, 90),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('${type.name} deck paints ground, frame and emblem', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MonopolyStyleDeckCard(type: type, width: 64, height: 90),
            ),
          ),
        ),
      );

      // Ground pattern + emblem + frame are three distinct painter layers.
      expect(
        find.descendant(
          of: find.byType(MonopolyStyleDeckCard),
          matching: find.byType(CustomPaint),
        ),
        findsNWidgets(3),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('${type.name} CardDialog renders without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(_dialogApp(_card(type, 'Kart açıklaması.')));

      expect(
        find.text(type == CardType.sans ? 'ŞANS KARTI' : 'KADER KARTI'),
        findsOneWidget,
      );
      expect(find.text('Kart açıklaması.'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets(
    'long CardDialog description remains scrollable without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(360, 520);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final description = List.filled(
        18,
        'Kaderin sayfaları çevrilirken seçimlerin yeni bir yol açıyor.',
      ).join(' ');
      await tester.pumpWidget(_dialogApp(_card(CardType.kader, description)));

      expect(find.text(description), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final type in CardType.values) {
    testWidgets(
      '${type.name} CardDialog handles compact landscape with long text',
      (tester) async {
        tester.view.physicalSize = const Size(640, 280);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final description = _longDescription(type);
        await tester.pumpWidget(_dialogApp(_card(type, description)));

        expect(find.textContaining('KARTI'), findsOneWidget);
        expect(find.text(description), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.byType(SingleChildScrollView), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('tapping CardDialog requests dismissal', (tester) async {
    var dismissCount = 0;
    await tester.pumpWidget(
      _dialogApp(
        _card(CardType.sans, 'Dokunarak kapat.'),
        onDismiss: () => dismissCount++,
      ),
    );

    await tester.tap(find.text('Dokunarak kapat.'));
    await tester.pump();

    expect(dismissCount, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

String _longDescription(CardType type) {
  final sentence = type == CardType.sans
      ? 'Åans kapÄ±sÄ± aÃ§Ä±ldÄ± ve beklenmedik bir edebi fÄ±rsat doÄŸdu.'
      : 'Kaderin sayfalarÄ± Ã§evrilirken seÃ§imlerin yeni bir yol aÃ§Ä±yor.';
  return List.filled(20, sentence).join(' ');
}

GameCard _card(CardType type, String description) => GameCard(
  description: description,
  type: type,
  effectType: CardEffectType.moneyChange,
);

Widget _dialogApp(GameCard card, {VoidCallback? onDismiss}) {
  return ProviderScope(
    child: MaterialApp(
      home: CardDialog(card: card, onDismiss: onDismiss),
    ),
  );
}
