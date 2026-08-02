import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

void main() {
  group('Dice animation skip', () {
    test('skipDiceAnimation resolves the human dice wait early', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      // A delay that would never complete inside the test window on its own.
      final wait = notifier.waitForDiceAnimation(const Duration(seconds: 30));
      var completed = false;
      unawaited(wait.then((_) => completed = true));

      await Future.delayed(const Duration(milliseconds: 5));
      expect(completed, isFalse);

      notifier.skipDiceAnimation();

      await Future.delayed(const Duration(milliseconds: 5));
      expect(completed, isTrue);
    });

    test('skipDiceAnimation is a no-op when no animation is running', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      // No animation in progress — must not throw.
      notifier.skipDiceAnimation();
    });

    test('dice wait still resolves on its own after the full delay', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      var completed = false;
      unawaited(
        notifier
            .waitForDiceAnimation(const Duration(milliseconds: 60))
            .then((_) => completed = true),
      );

      await Future.delayed(const Duration(milliseconds: 10));
      expect(completed, isFalse);

      await Future.delayed(const Duration(milliseconds: 80));
      expect(completed, isTrue);
    });
  });
}
