import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:literature_board_game/presentation/dialogs/how_to_play_dialog.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('HowToPlayDialog keeps title visible with scrollable content', (
    tester,
  ) async {
    await tester.pumpWidget(_dialogApp());
    await tester.pump();

    expect(find.text('OYUN REHBERİ'), findsOneWidget);
    expect(find.text('GİRİŞ'), findsOneWidget);
    expect(find.text('← Kaydır'), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);
    expect(find.text('Kaydır →'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('how_to_play_card_scroll_view')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'HowToPlayDialog long page can be scrolled without hiding title',
    (tester) async {
      tester.view.physicalSize = const Size(360, 520);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_dialogApp());
      await tester.pump();

      await tester.tap(find.text('İLERİ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('İLERİ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('İLERİ'));
      await tester.pumpAndSettle();

      expect(find.text('KARELER'), findsOneWidget);
      expect(find.text('OYUN REHBERİ'), findsOneWidget);
      expect(find.text('4 / 5'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('how_to_play_card_scroll_view')),
        findsOneWidget,
      );

      await tester.drag(
        find.byKey(const ValueKey('how_to_play_card_scroll_view')),
        const Offset(0, -90),
      );
      await tester.pump();

      expect(find.text('KARELER'), findsOneWidget);
      expect(find.text('OYUN REHBERİ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('HowToPlayDialog avoids overflow in compact landscape', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 280);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_dialogApp());
    await tester.pump();

    expect(find.text('OYUN REHBERİ'), findsOneWidget);
    expect(find.text('GİRİŞ'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);
    expect(
      find.byKey(const ValueKey('how_to_play_card_scroll_view')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

Widget _dialogApp() {
  return const MaterialApp(
    home: Scaffold(body: Center(child: HowToPlayDialog())),
  );
}
