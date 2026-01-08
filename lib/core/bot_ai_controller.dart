import 'dart:math';
import '../models/question.dart';
import '../models/tile.dart';
import '../models/player.dart';
import 'game_rules_engine.dart';

/// Bot karar mekanizması ve stratejisi
class BotAIController {
  final GameRulesEngine rulesEngine;
  final Random random;

  BotAIController({required this.rulesEngine, Random? random})
    : random = random ?? Random();

  /// Bot doğru cevap vermeli mi?
  bool shouldAnswerCorrectly(Question question) {
    // Botlar %30 ihtimalle doğru bilir (Zorluk seviyesine göre ayarlanabilir)
    const correctProbability = 0.30;
    return random.nextDouble() < correctProbability;
  }

  /// Telif satın alma kararı
  bool shouldPurchaseCopyright(Tile tile, Player player) {
    final price = tile.purchasePrice ?? 0;
    final rentIncome = tile.copyrightFee ?? 0;

    // Bot zekası: Akıllı satın alma kararı
    // 1. Parası yetiyor mu? (Güvenlik marjı ile)
    // 2. Yatırım mantıklı mı? (Kira getirisi iyi mi)
    // 3. Kenarda parası kalıyor mu?
    final canAfford = player.stars >= (price * 1.5).toInt();
    final goodROI = rentIncome >= (price * 0.1).toInt();
    final keepsReserve = (player.stars - price) >= 50;

    return canAfford && goodROI && keepsReserve;
  }
}
