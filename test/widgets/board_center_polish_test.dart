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
