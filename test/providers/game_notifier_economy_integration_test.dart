import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

void main() {
  group('GameNotifier + EconomyService integration', () {
    test('computeAdjustedReward applies compression and underdog bonus', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      final reward = notifier.computeAdjustedReward(
        baseStars: 10,
        promotionReward: 5,
        currentStars: 10,
        leaderStars: 30,
        consecutiveDoubles: 0,
      );

      expect(reward, 23);
    });

    test('computeAdjustedReward applies double decay from second double', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      final reward = notifier.computeAdjustedReward(
        baseStars: 10,
        promotionReward: 0,
        currentStars: 30,
        leaderStars: 30,
        consecutiveDoubles: 2,
      );

      expect(reward, 5);
    });

    test('computeLeadCompressionTurnBonus returns bonus when gap is high', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      final bonus = notifier.computeLeadCompressionTurnBonus(
        currentStars: 10,
        leaderStars: 30,
        isSkipped: false,
      );

      expect(bonus, greaterThan(0));
    });

    test('computeLeadCompressionTurnBonus returns zero under threshold', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      final bonus = notifier.computeLeadCompressionTurnBonus(
        currentStars: 22,
        leaderStars: 30,
        isSkipped: false,
      );

      expect(bonus, 0);
    });

    test('computeLeadCompressionTurnBonus returns zero for skipped turns', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      final bonus = notifier.computeLeadCompressionTurnBonus(
        currentStars: 0,
        leaderStars: 50,
        isSkipped: true,
      );

      expect(bonus, 0);
    });
  });
}
