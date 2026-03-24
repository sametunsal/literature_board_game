import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/services/economy_service.dart';

void main() {
  group('EconomyService', () {
    final service = EconomyService();

    test('applyUnderdogBonus returns minimum bonus for trailing player', () {
      final bonus = service.applyUnderdogBonus(
        baseStars: 3,
        currentStars: 10,
        leaderStars: 30,
      );

      expect(bonus, 3);
    });

    test('applyUnderdogBonus returns 0 when player is not underdog', () {
      final bonus = service.applyUnderdogBonus(
        baseStars: 8,
        currentStars: 20,
        leaderStars: 30,
      );

      expect(bonus, 0);
    });

    test('applyLeadCompression boosts reward when lead gap is large', () {
      final reward = service.applyLeadCompression(
        reward: 10,
        currentStars: 10,
        leaderStars: 30,
      );

      expect(reward, 12);
    });

    test('applyLeadCompression keeps reward same under threshold', () {
      final reward = service.applyLeadCompression(
        reward: 10,
        currentStars: 20,
        leaderStars: 30,
      );

      expect(reward, 10);
    });

    test('applyDoubleRewardDecay halves reward on second+ doubles', () {
      final reward = service.applyDoubleRewardDecay(
        reward: 10,
        consecutiveDoubles: 2,
      );

      expect(reward, 5);
    });

    test('applyDoubleRewardDecay does not change first reward', () {
      final reward = service.applyDoubleRewardDecay(
        reward: 10,
        consecutiveDoubles: 1,
      );

      expect(reward, 10);
    });

    test('applyPercentLossCap clamps excessive percentage to max', () {
      final capped = service.applyPercentLossCap(requestedPercent: 90);

      expect(capped, 40);
    });

    test('normalizeTransferFloor never returns negative stars', () {
      final stars = service.normalizeTransferFloor(
        currentStars: 5,
        delta: -20,
      );

      expect(stars, 0);
    });
  });
}
