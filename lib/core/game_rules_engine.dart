import 'dart:math';
import 'game_random.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../models/dice_roll.dart';
import '../models/question.dart';
import '../repositories/question_repository.dart';
import '../constants/game_constants.dart';

/// Temel oyun mantığı ve kuralları (Saf fonksiyonlar)
class GameRulesEngine {
  final Random random;

  GameRulesEngine({Random? random})
    : random = random ?? GameRandom.instance.random;

  // Hareket Hesaplamaları
  int calculateNewPosition(int currentPosition, int diceTotal, int boardSize) {
    return (currentPosition + diceTotal) % boardSize;
  }

  bool passedStart(int oldPosition, int diceTotal, int boardSize) {
    return (oldPosition + diceTotal) >= boardSize;
  }

  // Zar İşlemleri
  DiceRoll rollDice() {
    return DiceRoll.random();
  }

  bool isTripleDouble(int doubleDiceCount) {
    return doubleDiceCount >= 3;
  }

  // Vergi Hesaplamaları
  int calculateTax(int stars, int percentage) {
    final percentageTax = (stars * percentage) ~/ 100;
    final minTax = percentage == GameConstants.incomeTaxRate
        ? GameConstants.incomeTaxMin
        : GameConstants.authorTaxMin;
    return percentageTax > minTax ? percentageTax : minTax;
  }

  // İflas ve Oyun Sonu Kontrolleri
  bool isBankrupt(Player player, int bankruptcyThreshold) {
    return player.stars <= bankruptcyThreshold;
  }

  bool isGameOver(List<Player> players) {
    final activePlayers = players.where((p) => !p.isBankrupt).length;
    return activePlayers <= 1;
  }

  // Soru Seçimi
  Question selectQuestion(List<Question> pool, {bool easyMode = false}) {
    if (pool.isEmpty) {
      return Question(
        id: 'default',
        category: QuestionCategory.benKimim,
        difficulty: Difficulty.easy,
        question: 'Soru havuzu boş!',
        answer: 'Boş',
      );
    }

    if (easyMode) {
      final easyQuestions = pool
          .where((q) => q.difficulty == Difficulty.easy)
          .toList();
      if (easyQuestions.isNotEmpty) {
        return easyQuestions[random.nextInt(easyQuestions.length)];
      }
    }

    return pool[random.nextInt(pool.length)];
  }
}
