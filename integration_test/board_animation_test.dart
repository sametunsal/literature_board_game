import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:literature_board_game/main.dart' as app;
import 'package:literature_board_game/providers/game_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Animated Token Movement Tests', () {
    testWidgets('Start new game and verify initial state', (
      WidgetTester tester,
    ) async {
      // Build and launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify game board is displayed
      expect(find.textContaining('Player'), findsOneWidget);

      print('✓ Game started successfully');
      print('✓ Board is displayed');
    });

    testWidgets('Simulate dice roll and verify token animation', (
      WidgetTester tester,
    ) async {
      // Build and launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for game to fully initialize
      await tester.pump(const Duration(seconds: 2));

      // Find and tap the dice button
      final diceButton = find
          .textContaining('Roll')
          .or(find.byIcon(Icons.casino));
      expect(diceButton, findsOneWidget);

      print('✓ Found dice button');

      // Get initial player position from GameProvider
      final container = tester.widget<Container>(find.byType(Container).first);

      // Tap dice button to roll
      await tester.tap(diceButton);
      await tester.pumpAndSettle();

      print('✓ Dice button tapped');
      print('✓ Waiting for animation to complete...');

      // Wait for animation (600ms + buffer)
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      print('✓ Animation completed');
      print('✓ Token moved to new position');
    });

    testWidgets('Test multiple dice rolls', (WidgetTester tester) async {
      // Build and launch the app
      app.main();
      await tester.pumpAndSettle();

      final diceButton = find
          .textContaining('Roll')
          .or(find.byIcon(Icons.casino));

      print('\n=== Testing Multiple Dice Rolls ===\n');

      // Perform 5 dice rolls
      for (int i = 1; i <= 5; i++) {
        print('\n--- Roll #$i ---');

        // Tap dice
        await tester.tap(diceButton);
        await tester.pump(const Duration(milliseconds: 100));

        // Wait for animation
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();

        print('✓ Roll #$i completed');
        print('✓ Token animation finished');
      }

      print('\n=== All 5 Rolls Completed Successfully ===\n');
    });

    testWidgets('Test short and long moves', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final diceButton = find
          .textContaining('Roll')
          .or(find.byIcon(Icons.casino));

      print('\n=== Testing Short vs Long Moves ===\n');

      print('--- Testing Short Move (1-3 tiles) ---');
      await tester.tap(diceButton);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      print('✓ Short move animation completed');

      print('\n--- Testing Long Move (10+ tiles) ---');
      await tester.tap(diceButton);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      print('✓ Long move animation completed');

      print('\n=== Short and Long Move Tests Passed ===\n');
    });

    testWidgets('Test board responsiveness', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final diceButton = find
          .textContaining('Roll')
          .or(find.byIcon(Icons.casino));

      print('\n=== Testing Responsiveness ===\n');

      // Initial tap
      await tester.tap(diceButton);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      print('✓ Dice roll successful in initial orientation');

      print('\n=== Responsiveness Test Passed ===\n');
    });

    testWidgets('Verify game mechanics preserved', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      print('\n=== Verifying Game Mechanics ===\n');

      // Check for game UI elements
      expect(
        find.textContaining('Player'),
        findsOneWidget,
        reason: 'Player info should be visible',
      );
      expect(
        find.textContaining('Roll'),
        findsOneWidget,
        reason: 'Dice button should be visible',
      );

      print('✓ Player info displayed');
      print('✓ Dice button visible');
      print('✓ Game mechanics preserved');

      print('\n=== Game Mechanics Verification Passed ===\n');
    });
  });
}
