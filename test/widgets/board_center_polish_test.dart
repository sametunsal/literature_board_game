import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:literature_board_game/models/game_card.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/presentation/dialogs/card_dialog.dart';
import 'package:literature_board_game/presentation/widgets/board/board_visual_constants.dart';
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
      // Deck identity is carried by the emblem *and* a named wordmark.
      expect(
        find.descendant(
          of: find.byType(MonopolyStyleDeckCard),
          matching: find.text(type == CardType.sans ? 'ŞANS' : 'KADER'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('${type.name} wordmark stays legible and unclipped across the '
        'deck size range', (tester) async {
      // Deck widths seen from a 800x360 phone up to a 1080p screen.
      for (final width in const [44.0, 52.0, 84.0, 150.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: MonopolyStyleDeckCard(
                  type: type,
                  width: width,
                  height: width * 1.4,
                ),
              ),
            ),
          ),
        );

        final label = find.text(type == CardType.sans ? 'ŞANS' : 'KADER');
        expect(label, findsOneWidget);

        // The wordmark must stay inside the card face at every size.
        final card = tester.getRect(find.byType(MonopolyStyleDeckCard));
        final text = tester.getRect(label);
        expect(text.left, greaterThanOrEqualTo(card.left));
        expect(text.right, lessThanOrEqualTo(card.right));
        expect(text.top, greaterThanOrEqualTo(card.top));
        expect(text.bottom, lessThanOrEqualTo(card.bottom));
        expect(tester.takeException(), isNull);
      }
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

    testWidgets('${type.name} title stays inside its cartouche at every '
        'gameplay deck size', (tester) async {
      // The real centre deck spans ~49dp wide on a phone-landscape board up to
      // ~158dp on 1080p. The title is the top of the visual hierarchy, so it
      // has to sit *on* the plate at all of them — a word that overhangs the
      // cartouche loses the contrast the plate exists to give it.
      for (final width in const [49.0, 85.0, 102.0, 158.0]) {
        final height = width * 1.4;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: MonopolyStyleDeckCard(
                  type: type,
                  width: width,
                  height: height,
                ),
              ),
            ),
          ),
        );

        final card = tester.getRect(find.byType(MonopolyStyleDeckCard));
        // The face is inset by the backing stack; mirror that geometry here.
        final inset =
            math.min(width, height) * kDeckStackOffsetRatio * kDeckStackLayers;
        final face = Rect.fromLTRB(
          card.left,
          card.top + inset,
          card.right - inset,
          card.bottom,
        );
        final plate = Rect.fromCenter(
          center: Offset(face.center.dx, face.top + face.height * 0.775),
          width: face.width * 0.78,
          height: face.height * 0.155,
        );

        final title = tester.getRect(
          find.text(type == CardType.sans ? 'ŞANS' : 'KADER'),
        );
        final reason = '${type.name} @ $width';
        expect(title.left, greaterThanOrEqualTo(plate.left), reason: reason);
        expect(title.right, lessThanOrEqualTo(plate.right), reason: reason);
        expect(title.top, greaterThanOrEqualTo(plate.top), reason: reason);
        expect(title.bottom, lessThanOrEqualTo(plate.bottom), reason: reason);
        expect(tester.takeException(), isNull, reason: reason);
      }
    });
  }

  testWidgets('the two decks share a skeleton but never the same emblem', (
    tester,
  ) async {
    // Both faces are built from the same layer count (ground / emblem / frame)
    // so they read as one set; the emblem painter is the only thing that may
    // differ, and it must, or Şans and Kader become interchangeable.
    Future<List<Type>> paintersFor(CardType type) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MonopolyStyleDeckCard(type: type, width: 80, height: 112),
            ),
          ),
        ),
      );
      return tester
          .widgetList<CustomPaint>(
            find.descendant(
              of: find.byType(MonopolyStyleDeckCard),
              matching: find.byType(CustomPaint),
            ),
          )
          .map((paint) => paint.painter.runtimeType)
          .toList();
    }

    final sans = await paintersFor(CardType.sans);
    final kader = await paintersFor(CardType.kader);

    expect(sans, hasLength(kader.length));
    // Ground and frame are shared; exactly one layer — the emblem — differs.
    final differing = [
      for (var i = 0; i < sans.length; i++)
        if (sans[i] != kader[i]) i,
    ];
    expect(differing, hasLength(1));
    expect(tester.takeException(), isNull);
  });

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
