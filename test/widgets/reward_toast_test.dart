import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:literature_board_game/presentation/widgets/reward_toast.dart';

void main() {
  Future<void> pumpToast(
    WidgetTester tester, {
    required String text,
    String? title,
    IconData? icon,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 72,
              child: RewardToast(
                text: text,
                color: Colors.amber,
                title: title,
                icon: icon,
                onComplete: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders title, text, and icon without overflow', (
    tester,
  ) async {
    // Both tested landscape phone viewports.
    for (final size in const [Size(800, 360), Size(914, 411)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpToast(
        tester,
        text: '+3 Akçe',
        title: 'DOĞRU CEVAP',
        icon: Icons.paid_rounded,
      );

      expect(find.text('DOĞRU CEVAP'), findsOneWidget, reason: '$size');
      expect(find.text('+3 Akçe'), findsOneWidget, reason: '$size');
      expect(find.byIcon(Icons.paid_rounded), findsOneWidget, reason: '$size');

      // Drive the intro/hold/outro animation to completion.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull, reason: '$size');
    }
  });

  testWidgets('renders text-only toast and long book titles without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpToast(
      tester,
      text: 'Telif: Saatleri Ayarlama Enstitüsü',
      title: 'TELİF ALINDI',
      icon: Icons.history_edu_rounded,
    );
    expect(find.text('Telif: Saatleri Ayarlama Enstitüsü'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);

    // No title/icon still renders (legacy call sites).
    await pumpToast(tester, text: '+5 ⭐');
    expect(find.text('+5 ⭐'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });
}
