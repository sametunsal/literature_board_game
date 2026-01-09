import 'dart:math';
import 'game_random.dart';
import '../models/question.dart';
import '../models/tile.dart';
import '../models/player.dart';
import 'game_rules_engine.dart';
import '../constants/game_constants.dart';

/// Bot karar mekanizması ve stratejisi
class BotAIController {
  final GameRulesEngine rulesEngine;
  final Random random;

  BotAIController({required this.rulesEngine, Random? random})
    : random = random ?? GameRandom.instance.random;

  /// Bot doğru cevap vermeli mi?
  bool shouldAnswerCorrectly(Question question) {
    // Botlar %30 ihtimalle doğru bilir (Zorluk seviyesine göre ayarlanabilir)
    return random.nextDouble() < GameConstants.botCorrectProbability;
  }

  /// Telif satın alma kararı
  bool shouldPurchaseCopyright(Tile tile, Player player) {
    final price = tile.purchasePrice ?? 0;
    final rentIncome = tile.copyrightFee ?? 0;

    // Bot zekası: Akıllı satın alma kararı
    // 1. Parası yetiyor mu? (Güvenlik marjı ile)
    // 2. Yatırım mantıklı mı? (Kira getirisi iyi mi)
    // 3. Kenarda parası kalıyor mu?
    final canAfford =
        player.stars >=
        (price * GameConstants.botAffordabilityMultiplier).toInt();
    final goodROI =
        rentIncome >= (price * GameConstants.botRoiThreshold).toInt();
    final keepsReserve =
        (player.stars - price) >= GameConstants.botReserveAmount;

    return canAfford && goodROI && keepsReserve;
  }
}
