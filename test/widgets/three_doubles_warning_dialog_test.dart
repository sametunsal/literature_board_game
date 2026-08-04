import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:literature_board_game/presentation/dialogs/notification_dialogs.dart';

void main() {
  testWidgets('ThreeDoublesWarningDialog renders the rule explanation', (
    tester,
  ) async {
    // ThemeNotifier reads SharedPreferences on construction.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: const Center(child: ThreeDoublesWarningDialog()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Üç Çift Zar!'), findsOneWidget);
    expect(find.textContaining('Kütüphaneye gönderildin'), findsOneWidget);
    expect(find.textContaining('2 tur bekleyeceksin'), findsOneWidget);
    expect(find.text('Tamam'), findsOneWidget);
  });
}
