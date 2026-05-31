import 'dart:math';

import '../../models/question.dart';
import '../../models/player.dart';
import '../../models/board_tile.dart';
import '../../models/tile_type.dart';
import '../../models/difficulty.dart';
import '../../core/constants/game_constants.dart';
import '../../core/utils/question_line_estimator.dart';
import 'economy_service.dart';
import 'card_effect_service.dart';

class QuestionSelectionResult {
  final Question? question;
  final bool shouldResetAskedIds;
  final bool isTesivkBonusFallback;
  final bool noQuestionsFound;
  final List<LogEntry> logs;

  const QuestionSelectionResult({
    this.question,
    this.shouldResetAskedIds = false,
    this.isTesivkBonusFallback = false,
    this.noQuestionsFound = false,
    this.logs = const [],
  });
}

class AnswerResult {
  final Player updatedPlayer;
  final List<LogEntry> logs;
  final int baseStars;
  final int totalStars;
  final bool promoted;
  final MasteryLevel? newMastery;
  final int promotionReward;
  final bool quoteDrop;
  final String? quoteId;
  final bool wasCorrect;
  final bool checkWinCondition;

  const AnswerResult({
    required this.updatedPlayer,
    this.logs = const [],
    this.baseStars = 0,
    this.totalStars = 0,
    this.promoted = false,
    this.newMastery,
    this.promotionReward = 0,
    this.quoteDrop = false,
    this.quoteId,
    this.wasCorrect = false,
    this.checkWinCondition = false,
  });
}

class QuestionFlowService {
  final EconomyService _economyService;

  const QuestionFlowService(this._economyService);

  static Difficulty getDifficultyForMastery(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.novice:
        return Difficulty.easy;
      case MasteryLevel.cirak:
        return Difficulty.medium;
      case MasteryLevel.kalfa:
      case MasteryLevel.usta:
        return Difficulty.hard;
    }
  }

  static String getCategoryDisplayName(String categoryId) {
    switch (categoryId) {
      case 'turkEdebiyatindaIlkler':
        return 'Türk Edebiyatında İlkler';
      case 'edebiSanatlar':
        return 'Edebi Sanatlar';
      case 'eserKarakter':
        return 'Eser-Karakter';
      case 'edebiyatAkimlari':
        return 'Edebiyat Akımları';
      case 'benKimim':
        return 'Ben Kimim?';
      case 'tesvik':
        return 'Teşvik';
      case 'bonusBilgiler':
        return 'Bonus Bilgi';
      default:
        return categoryId;
    }
  }

  int computeAdjustedReward({
    required int baseStars,
    required int promotionReward,
    required int currentStars,
    required int leaderStars,
    required int consecutiveDoubles,
  }) {
    final compressedBase = _economyService.applyLeadCompression(
      reward: baseStars,
      currentStars: currentStars,
      leaderStars: leaderStars,
    );
    final decayedBase = _economyService.applyDoubleRewardDecay(
      reward: compressedBase,
      consecutiveDoubles: consecutiveDoubles,
    );
    final underdogBonus = _economyService.applyUnderdogBonus(
      baseStars: decayedBase,
      currentStars: currentStars,
      leaderStars: leaderStars,
    );
    return decayedBase + promotionReward + underdogBonus;
  }

  QuestionSelectionResult selectQuestion({
    required BoardTile tile,
    required Player player,
    required List<Question> questionPool,
    required Set<String> askedQuestionIds,
    required Random random,
    bool useLineEstimation = true,
  }) {
    final logs = <LogEntry>[];

    List<String> categoryNames = [];
    if (tile.type == TileType.tesvik) {
      categoryNames = ['bonusBilgiler'];
    } else if (tile.category != null && tile.category!.isNotEmpty) {
      categoryNames = [tile.category!];
    }

    if (categoryNames.isEmpty) {
      return QuestionSelectionResult(
        noQuestionsFound: true,
        logs: [LogEntry('Bu karoda soru yok.', type: 'info')],
      );
    }

    final masteryCategoryName = tile.type == TileType.tesvik
        ? 'bonusBilgiler'
        : categoryNames.first;
    final masteryLevel = player.getMasteryLevel(masteryCategoryName);
    final targetDifficulty = getDifficultyForMastery(masteryLevel);
    final difficultyFilter = switch (targetDifficulty) {
      Difficulty.easy => 'easy',
      Difficulty.medium => 'medium',
      Difficulty.hard => 'hard',
    };

    final masteryName = masteryLevel.displayName;
    final categoryDisplay = tile.type == TileType.tesvik
        ? 'Teşvik'
        : getCategoryDisplayName(categoryNames.first);
    logs.add(
      LogEntry(
        '$categoryDisplay kategorisinde $masteryName seviyesi: $difficultyFilter soru seçildi.',
        type: 'info',
      ),
    );

    final filteredQuestions = questionPool.where((q) {
      final matchesCategory = categoryNames.contains(q.category.name);
      final matchesDifficulty = q.difficulty == difficultyFilter;
      final notAskedBefore = !askedQuestionIds.contains(q.text);
      return matchesCategory && matchesDifficulty && notAskedBefore;
    }).toList();
    filteredQuestions.shuffle(random);

    Question? selectedQuestion;
    bool shouldResetAskedIds = false;

    if (filteredQuestions.isEmpty) {
      logs.add(
        LogEntry(
          '⚠ Bu kategorideki tüm sorular soruldu. Liste sıfırlanıyor...',
          type: 'info',
        ),
      );
      shouldResetAskedIds = true;

      final allCategoryQuestions = questionPool.where((q) {
        final matchesCategory = categoryNames.contains(q.category.name);
        final matchesDifficulty = q.difficulty == difficultyFilter;
        return matchesCategory && matchesDifficulty;
      }).toList();
      allCategoryQuestions.shuffle(random);

      if (allCategoryQuestions.isEmpty) {
        final anyCategoryQuestions = questionPool
            .where((q) => categoryNames.contains(q.category.name))
            .toList();
        anyCategoryQuestions.shuffle(random);

        if (anyCategoryQuestions.isEmpty) {
          if (tile.type == TileType.tesvik) {
            logs.add(
              LogEntry(
                '🎁 Teşvik karesi - Bonus ödülü kazandınız!',
                type: 'success',
              ),
            );
            return QuestionSelectionResult(
              shouldResetAskedIds: shouldResetAskedIds,
              isTesivkBonusFallback: true,
              logs: logs,
            );
          }

          logs.add(LogEntry('Bu kategoride soru bulunamadı!', type: 'error'));
          return QuestionSelectionResult(noQuestionsFound: true, logs: logs);
        }

        selectedQuestion = _pickQuestionPreferringShortLines(
          anyCategoryQuestions,
          random,
          useLineEstimation: useLineEstimation,
        );
        logs.add(
          LogEntry(
            '⚠ $difficultyFilter zorlu soru bulunamadı, rastgele soru seçildi.',
            type: 'info',
          ),
        );
      } else {
        selectedQuestion = _pickQuestionPreferringShortLines(
          allCategoryQuestions,
          random,
          useLineEstimation: useLineEstimation,
        );
        logs.add(
          LogEntry(
            '🔄 Soru havuzu yenilendi, yeni soru seçiliyor.',
            type: 'info',
          ),
        );
      }
    } else {
      selectedQuestion = _pickQuestionPreferringShortLines(
        filteredQuestions,
        random,
        useLineEstimation: useLineEstimation,
      );
    }

    return QuestionSelectionResult(
      question: selectedQuestion,
      shouldResetAskedIds: shouldResetAskedIds,
      logs: logs,
    );
  }

  AnswerResult processAnswer({
    required bool isCorrect,
    required Player player,
    required String? categoryName,
    required Difficulty difficulty,
    required List<Player> allPlayers,
    required int currentPlayerIndex,
    required int consecutiveDoubles,
    required Random random,
    bool isBot = false,
  }) {
    final logs = <LogEntry>[];

    if (!isCorrect) {
      if (isBot) {
        logs.add(
          LogEntry('🤖 Bot: Yanlış cevap. Yıldız kazanamadın.', type: 'error'),
        );
      } else {
        logs.add(LogEntry('Yanlış cevap. Yıldız kazanamadın.', type: 'error'));
      }
      return AnswerResult(updatedPlayer: player, logs: logs);
    }

    if (categoryName == null) {
      return AnswerResult(updatedPlayer: player, logs: logs);
    }

    final currentCount = player.getCorrectAnswerCount(categoryName, difficulty);
    final newAnswerCount = currentCount + 1;
    final currentMastery = player.getMasteryLevel(categoryName);

    int baseStars = switch (difficulty) {
      Difficulty.easy => GameConstants.rewardEasy,
      Difficulty.medium => GameConstants.rewardMedium,
      Difficulty.hard => GameConstants.rewardHard,
    };

    String difficultyName = difficulty.displayName;
    MasteryLevel? newMastery;
    int promotionReward = 0;
    String promotionMessage = '';

    if (currentMastery == MasteryLevel.novice &&
        difficulty == Difficulty.easy &&
        newAnswerCount >= GameConstants.answersRequiredForPromotion) {
      newMastery = MasteryLevel.cirak;
      promotionReward = GameConstants.promotionBaseReward * 1;
      promotionMessage =
          '🏆 ${getCategoryDisplayName(categoryName)} kategorisinde Çırak oldun!';
    } else if (currentMastery == MasteryLevel.cirak &&
        difficulty == Difficulty.medium &&
        newAnswerCount >= GameConstants.answersRequiredForPromotion) {
      newMastery = MasteryLevel.kalfa;
      promotionReward = GameConstants.promotionBaseReward * 2;
      promotionMessage =
          '🏆 ${getCategoryDisplayName(categoryName)} kategorisinde Kalfa oldun!';
    } else if (currentMastery == MasteryLevel.kalfa &&
        difficulty == Difficulty.hard &&
        newAnswerCount >= GameConstants.answersRequiredForPromotion) {
      newMastery = MasteryLevel.usta;
      promotionReward = GameConstants.promotionBaseReward * 3;
      promotionMessage =
          '🏆 ${getCategoryDisplayName(categoryName)} kategorisinde Usta oldun!';
    }

    final leaderStars = allPlayers
        .map((p) => p.stars)
        .reduce((a, b) => a > b ? a : b);
    final totalStars = computeAdjustedReward(
      baseStars: baseStars,
      promotionReward: promotionReward,
      currentStars: player.stars,
      leaderStars: leaderStars,
      consecutiveDoubles: consecutiveDoubles,
    );

    final derivedBonus = totalStars - baseStars - promotionReward;
    if (derivedBonus > 0) {
      if (isBot) {
        logs.add(
          LogEntry('🔥 Bot: Denge Bonusu! +$derivedBonus ⭐', type: 'success'),
        );
      } else {
        logs.add(
          LogEntry(
            '🔥 Denge Bonusu! +$derivedBonus ⭐ (Geriden gelme bonusu)',
            type: 'success',
          ),
        );
      }
    }

    var updatedPlayer = player;
    bool quoteDrop = false;
    String? quoteId;
    if (difficulty == Difficulty.hard &&
        random.nextDouble() < GameConstants.hardQuestionQuoteDropRate) {
      quoteId = 'quote_${random.nextInt(100)}';
      updatedPlayer = updatedPlayer.collectQuote(quoteId);
      quoteDrop = true;
      if (isBot) {
        logs.add(
          LogEntry(
            '📜 Bot: Zor soru bonusu! Söz kartı kazandı!',
            type: 'success',
          ),
        );
      } else {
        logs.add(
          LogEntry(
            '📜 Zor soru bonusu! Rastgele bir söz kartı kazandın!',
            type: 'success',
          ),
        );
      }
    }

    final newProgress = Map<String, Map<String, int>>.from(
      player.categoryProgress,
    );
    if (!newProgress.containsKey(categoryName)) {
      newProgress[categoryName] = {};
    }
    final categoryMap = Map<String, int>.from(newProgress[categoryName]!);
    categoryMap[difficulty.name] = newAnswerCount;
    newProgress[categoryName] = categoryMap;

    updatedPlayer = updatedPlayer.copyWith(categoryProgress: newProgress);

    if (newMastery != null) {
      final newLevels = Map<String, int>.from(player.categoryLevels);
      newLevels[categoryName] = newMastery.value;
      updatedPlayer = updatedPlayer.copyWith(categoryLevels: newLevels);
    }

    updatedPlayer = updatedPlayer.copyWith(
      stars: updatedPlayer.stars + totalStars,
    );

    if (isBot) {
      logs.add(
        LogEntry(
          '🤖 Bot: Doğru cevap! +$baseStars ⭐ ($difficultyName)',
          type: 'success',
        ),
      );
    } else {
      logs.add(
        LogEntry(
          'Doğru cevap! +$baseStars ⭐ ($difficultyName)',
          type: 'success',
        ),
      );
    }

    if (promotionMessage.isNotEmpty) {
      if (isBot) {
        logs.add(
          LogEntry(
            '🤖 Bot: $promotionMessage (+$promotionReward ⭐ bonus)',
            type: 'success',
          ),
        );
      } else {
        logs.add(
          LogEntry(
            '$promotionMessage (+$promotionReward ⭐ bonus)',
            type: 'success',
          ),
        );
      }
    }

    return AnswerResult(
      updatedPlayer: updatedPlayer,
      logs: logs,
      baseStars: baseStars,
      totalStars: totalStars,
      promoted: newMastery != null,
      newMastery: newMastery,
      promotionReward: promotionReward,
      quoteDrop: quoteDrop,
      quoteId: quoteId,
      wasCorrect: true,
      checkWinCondition: true,
    );
  }

  Question? _pickQuestionPreferringShortLines(
    List<Question> pool,
    Random random, {
    bool useLineEstimation = true,
  }) {
    if (pool.isEmpty) return null;
    if (!useLineEstimation) {
      final copy = List<Question>.from(pool);
      copy.shuffle(random);
      return copy.first;
    }
    const maxW = 320.0;
    final scored = <MapEntry<Question, int>>[];
    for (final q in pool) {
      scored.add(
        MapEntry(q, QuestionLineEstimator.estimateLines(q.text, maxW)),
      );
    }
    scored.sort((a, b) => a.value.compareTo(b.value));
    final minLines = scored.first.value;
    final ties = scored
        .where((e) => e.value == minLines)
        .map((e) => e.key)
        .toList();
    ties.shuffle(random);
    return ties.first;
  }
}
