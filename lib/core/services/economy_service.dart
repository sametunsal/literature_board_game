import '../constants/game_constants.dart';

class EconomyService {
  const EconomyService();

  int applyUnderdogBonus({
    required int baseStars,
    required int currentStars,
    required int leaderStars,
  }) {
    if (leaderStars <= 0) return 0;
    final isUnderdog = currentStars < (leaderStars * GameConstants.underdogThreshold);
    if (!isUnderdog) return 0;

    return (baseStars * (GameConstants.underdogMultiplier - 1))
        .round()
        .clamp(GameConstants.underdogBonusStars, baseStars);
  }

  int applyLeadCompression({
    required int reward,
    required int currentStars,
    required int leaderStars,
  }) {
    final leadGap = leaderStars - currentStars;
    if (leadGap < GameConstants.leadCompressionThreshold) {
      return reward;
    }
    return (reward * GameConstants.trailingBoostScale).round();
  }

  int applyDoubleRewardDecay({
    required int reward,
    required int consecutiveDoubles,
  }) {
    if (consecutiveDoubles < GameConstants.maxConsecutiveDoubles) {
      return reward;
    }
    return (reward * GameConstants.doubleDecayAfterSecond).round();
  }

  int applyPercentLossCap({
    required int requestedPercent,
  }) {
    return requestedPercent.clamp(0, GameConstants.maxPercentLoss);
  }

  int normalizeTransferFloor({
    required int currentStars,
    required int delta,
  }) {
    final next = currentStars + delta;
    return next.clamp(0, double.infinity).toInt();
  }
}
