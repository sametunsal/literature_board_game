import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:literature_board_game/core/constants/game_constants.dart';
import 'package:literature_board_game/core/services/economy_service.dart';
import 'package:literature_board_game/core/services/question_flow_service.dart';
import 'package:literature_board_game/models/board_tile.dart';
import 'package:literature_board_game/models/difficulty.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/models/question.dart';
import 'package:literature_board_game/models/tile_type.dart';

class _FixedRandom implements Random {
  final double _doubleValue;
  final int _intValue;

  _FixedRandom({double doubleValue = 0.5, int intValue = 42})
    : _doubleValue = doubleValue,
      _intValue = intValue;

  @override
  double nextDouble() => _doubleValue;

  @override
  int nextInt(int max) => _intValue % max;

  @override
  bool nextBool() => _doubleValue < 0.5;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QuestionFlowService service;
  late Random random;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    service = const QuestionFlowService(EconomyService());
    random = Random(42);
  });

  Player makePlayer({
    String id = 'p1',
    String name = 'Alice',
    int stars = 20,
    int position = 5,
    Map<String, int> categoryLevels = const {},
    Map<String, Map<String, int>> categoryProgress = const {},
    List<String> collectedQuotes = const [],
  }) {
    return Player(
      id: id,
      name: name,
      color: Colors.blue,
      iconIndex: 1,
      stars: stars,
      position: position,
      categoryLevels: categoryLevels,
      categoryProgress: categoryProgress,
      collectedQuotes: collectedQuotes,
    );
  }

  Question makeQuestion({
    String text = 'Q?',
    QuestionCategory category = QuestionCategory.edebiSanatlar,
    String difficulty = 'easy',
  }) {
    return Question(
      text: text,
      options: ['A', 'B', 'C', 'D'],
      correctIndex: 0,
      category: category,
      difficulty: difficulty,
    );
  }

  BoardTile categoryTile({
    String category = 'edebiSanatlar',
    Difficulty difficulty = Difficulty.easy,
  }) {
    return BoardTile(
      id: '1',
      name: 'Test',
      position: 1,
      type: TileType.category,
      category: category,
      difficulty: difficulty,
    );
  }

  BoardTile tesvikTile() {
    return BoardTile(
      id: '2',
      name: 'Teşvik',
      position: 2,
      type: TileType.tesvik,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // getDifficultyForMastery
  // ═══════════════════════════════════════════════════════════════

  group('getDifficultyForMastery', () {
    test('novice → easy', () {
      expect(
        QuestionFlowService.getDifficultyForMastery(MasteryLevel.novice),
        Difficulty.easy,
      );
    });

    test('cirak → medium', () {
      expect(
        QuestionFlowService.getDifficultyForMastery(MasteryLevel.cirak),
        Difficulty.medium,
      );
    });

    test('kalfa → hard', () {
      expect(
        QuestionFlowService.getDifficultyForMastery(MasteryLevel.kalfa),
        Difficulty.hard,
      );
    });

    test('usta → hard', () {
      expect(
        QuestionFlowService.getDifficultyForMastery(MasteryLevel.usta),
        Difficulty.hard,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // getCategoryDisplayName
  // ═══════════════════════════════════════════════════════════════

  group('getCategoryDisplayName', () {
    test('all known categories return Turkish names', () {
      expect(
        QuestionFlowService.getCategoryDisplayName('turkEdebiyatindaIlkler'),
        'Türk Edebiyatında İlkler',
      );
      expect(
        QuestionFlowService.getCategoryDisplayName('edebiSanatlar'),
        'Edebi Sanatlar',
      );
      expect(
        QuestionFlowService.getCategoryDisplayName('eserKarakter'),
        'Eser-Karakter',
      );
      expect(
        QuestionFlowService.getCategoryDisplayName('edebiyatAkimlari'),
        'Edebiyat Akımları',
      );
      expect(
        QuestionFlowService.getCategoryDisplayName('benKimim'),
        'Ben Kimim?',
      );
      expect(QuestionFlowService.getCategoryDisplayName('tesvik'), 'Teşvik');
      expect(
        QuestionFlowService.getCategoryDisplayName('bonusBilgiler'),
        'Bonus Bilgi',
      );
    });

    test('unknown category returns raw ID', () {
      expect(
        QuestionFlowService.getCategoryDisplayName('unknownCat'),
        'unknownCat',
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // selectQuestion
  // ═══════════════════════════════════════════════════════════════

  group('selectQuestion', () {
    test('returns matching question when exact match exists', () {
      final pool = [
        makeQuestion(text: 'Q1', difficulty: 'easy'),
        makeQuestion(text: 'Q2', difficulty: 'medium'),
      ];
      final result = service.selectQuestion(
        tile: categoryTile(),
        player: makePlayer(),
        questionPool: pool,
        askedQuestionIds: {},
        random: random,
        useLineEstimation: false,
      );

      expect(result.question, isNotNull);
      expect(result.question!.text, 'Q1');
      expect(result.noQuestionsFound, false);
      expect(result.shouldResetAskedIds, false);
    });

    test('filters by category', () {
      final pool = [
        makeQuestion(
          text: 'Wrong cat',
          category: QuestionCategory.benKimim,
          difficulty: 'easy',
        ),
        makeQuestion(
          text: 'Right cat',
          category: QuestionCategory.edebiSanatlar,
          difficulty: 'easy',
        ),
      ];
      final result = service.selectQuestion(
        tile: categoryTile(category: 'edebiSanatlar'),
        player: makePlayer(),
        questionPool: pool,
        askedQuestionIds: {},
        random: random,
        useLineEstimation: false,
      );

      expect(result.question!.text, 'Right cat');
    });

    test('filters by mastery-based difficulty', () {
      final pool = [
        makeQuestion(text: 'Easy', difficulty: 'easy'),
        makeQuestion(text: 'Medium', difficulty: 'medium'),
      ];
      final player = makePlayer(categoryLevels: {'edebiSanatlar': 1});
      final result = service.selectQuestion(
        tile: categoryTile(),
        player: player,
        questionPool: pool,
        askedQuestionIds: {},
        random: random,
        useLineEstimation: false,
      );

      expect(result.question!.text, 'Medium');
    });

    test('filters out already-asked questions', () {
      final pool = [
        makeQuestion(text: 'Asked', difficulty: 'easy'),
        makeQuestion(text: 'Fresh', difficulty: 'easy'),
      ];
      final result = service.selectQuestion(
        tile: categoryTile(),
        player: makePlayer(),
        questionPool: pool,
        askedQuestionIds: {'Asked'},
        random: random,
        useLineEstimation: false,
      );

      expect(result.question!.text, 'Fresh');
    });

    test('recycles when all questions asked', () {
      final pool = [makeQuestion(text: 'Only', difficulty: 'easy')];
      final result = service.selectQuestion(
        tile: categoryTile(),
        player: makePlayer(),
        questionPool: pool,
        askedQuestionIds: {'Only'},
        random: random,
        useLineEstimation: false,
      );

      expect(result.question!.text, 'Only');
      expect(result.shouldResetAskedIds, true);
    });

    test('falls back to any difficulty when target difficulty empty', () {
      final pool = [makeQuestion(text: 'Hard Q', difficulty: 'hard')];
      final result = service.selectQuestion(
        tile: categoryTile(),
        player: makePlayer(),
        questionPool: pool,
        askedQuestionIds: {},
        random: random,
        useLineEstimation: false,
      );

      expect(result.question!.text, 'Hard Q');
      expect(result.shouldResetAskedIds, true);
      expect(result.logs.any((l) => l.message.contains('rastgele soru')), true);
    });

    test('tesvik tile uses bonusBilgiler category', () {
      final pool = [
        makeQuestion(
          text: 'Bonus',
          category: QuestionCategory.bonusBilgiler,
          difficulty: 'easy',
        ),
        makeQuestion(
          text: 'Other',
          category: QuestionCategory.edebiSanatlar,
          difficulty: 'easy',
        ),
      ];
      final result = service.selectQuestion(
        tile: tesvikTile(),
        player: makePlayer(),
        questionPool: pool,
        askedQuestionIds: {},
        random: random,
        useLineEstimation: false,
      );

      expect(result.question!.text, 'Bonus');
    });

    test('tesvik with no questions returns bonus fallback', () {
      final result = service.selectQuestion(
        tile: tesvikTile(),
        player: makePlayer(),
        questionPool: [],
        askedQuestionIds: {},
        random: random,
        useLineEstimation: false,
      );

      expect(result.isTesivkBonusFallback, true);
      expect(result.question, isNull);
    });

    test('empty pool for non-tesvik returns noQuestionsFound', () {
      final result = service.selectQuestion(
        tile: categoryTile(),
        player: makePlayer(),
        questionPool: [],
        askedQuestionIds: {},
        random: random,
        useLineEstimation: false,
      );

      expect(result.noQuestionsFound, true);
      expect(result.question, isNull);
    });

    test('tile with no category returns noQuestionsFound', () {
      final tile = BoardTile(
        id: '0',
        name: 'Corner',
        position: 0,
        type: TileType.corner,
      );
      final result = service.selectQuestion(
        tile: tile,
        player: makePlayer(),
        questionPool: [makeQuestion()],
        askedQuestionIds: {},
        random: random,
        useLineEstimation: false,
      );

      expect(result.noQuestionsFound, true);
      expect(result.logs.first.message, contains('soru yok'));
    });

    test('logs auto-selected difficulty', () {
      final pool = [makeQuestion(difficulty: 'easy')];
      final result = service.selectQuestion(
        tile: categoryTile(),
        player: makePlayer(),
        questionPool: pool,
        askedQuestionIds: {},
        random: random,
        useLineEstimation: false,
      );

      expect(result.logs.first.message, contains('easy soru seçildi'));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // processAnswer — correct
  // ═══════════════════════════════════════════════════════════════

  group('processAnswer correct', () {
    test('easy correct awards rewardEasy', () {
      final player = makePlayer(stars: 10);
      final result = service.processAnswer(
        isCorrect: true,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.easy,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: _FixedRandom(doubleValue: 0.9),
      );

      expect(result.baseStars, GameConstants.rewardEasy);
      expect(result.updatedPlayer.stars, 10 + result.totalStars);
      expect(result.wasCorrect, true);
      expect(result.checkWinCondition, true);
    });

    test('medium correct awards rewardMedium', () {
      final player = makePlayer(stars: 10);
      final result = service.processAnswer(
        isCorrect: true,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.medium,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: _FixedRandom(doubleValue: 0.9),
      );

      expect(result.baseStars, GameConstants.rewardMedium);
    });

    test('hard correct awards rewardHard', () {
      final player = makePlayer(stars: 10);
      final result = service.processAnswer(
        isCorrect: true,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.hard,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: _FixedRandom(doubleValue: 0.9),
      );

      expect(result.baseStars, GameConstants.rewardHard);
    });

    test('records answer count in categoryProgress', () {
      final player = makePlayer();
      final result = service.processAnswer(
        isCorrect: true,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.easy,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: _FixedRandom(doubleValue: 0.9),
      );

      expect(
        result.updatedPlayer.categoryProgress['edebiSanatlar']!['easy'],
        1,
      );
    });

    test('3rd easy correct as novice promotes to cirak', () {
      final player = makePlayer(
        categoryProgress: {
          'edebiSanatlar': {'easy': 2},
        },
      );
      final result = service.processAnswer(
        isCorrect: true,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.easy,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: _FixedRandom(doubleValue: 0.9),
      );

      expect(result.promoted, true);
      expect(result.newMastery, MasteryLevel.cirak);
      expect(result.promotionReward, GameConstants.promotionBaseReward * 1);
      expect(result.updatedPlayer.categoryLevels['edebiSanatlar'], 1);
    });

    test('3rd medium correct as cirak promotes to kalfa', () {
      final player = makePlayer(
        categoryLevels: {'edebiSanatlar': 1},
        categoryProgress: {
          'edebiSanatlar': {'medium': 2},
        },
      );
      final result = service.processAnswer(
        isCorrect: true,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.medium,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: _FixedRandom(doubleValue: 0.9),
      );

      expect(result.promoted, true);
      expect(result.newMastery, MasteryLevel.kalfa);
      expect(result.promotionReward, GameConstants.promotionBaseReward * 2);
      expect(result.updatedPlayer.categoryLevels['edebiSanatlar'], 2);
    });

    test('3rd hard correct as kalfa promotes to usta', () {
      final player = makePlayer(
        categoryLevels: {'edebiSanatlar': 2},
        categoryProgress: {
          'edebiSanatlar': {'hard': 2},
        },
      );
      final result = service.processAnswer(
        isCorrect: true,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.hard,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: _FixedRandom(doubleValue: 0.9),
      );

      expect(result.promoted, true);
      expect(result.newMastery, MasteryLevel.usta);
      expect(result.promotionReward, GameConstants.promotionBaseReward * 3);
      expect(result.updatedPlayer.categoryLevels['edebiSanatlar'], 3);
    });

    test('wrong difficulty for level does not promote', () {
      final player = makePlayer(
        categoryProgress: {
          'edebiSanatlar': {'medium': 2},
        },
      );
      final result = service.processAnswer(
        isCorrect: true,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.medium,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: _FixedRandom(doubleValue: 0.9),
      );

      expect(result.promoted, false);
      expect(result.newMastery, isNull);
      expect(result.promotionReward, 0);
    });

    test('hard question quote drop when random below threshold', () {
      final player = makePlayer();
      final result = service.processAnswer(
        isCorrect: true,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.hard,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: _FixedRandom(doubleValue: 0.1, intValue: 7),
      );

      expect(result.quoteDrop, true);
      expect(result.quoteId, 'quote_7');
      expect(result.updatedPlayer.collectedQuotes, contains('quote_7'));
    });

    test('hard question no drop when random above threshold', () {
      final player = makePlayer();
      final result = service.processAnswer(
        isCorrect: true,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.hard,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: _FixedRandom(doubleValue: 0.5),
      );

      expect(result.quoteDrop, false);
      expect(result.quoteId, isNull);
    });

    test('easy/medium questions never trigger quote drop', () {
      final player = makePlayer();
      final result = service.processAnswer(
        isCorrect: true,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.easy,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: _FixedRandom(doubleValue: 0.01),
      );

      expect(result.quoteDrop, false);
    });

    test('totalStars includes base + promotion + underdog', () {
      final trailing = makePlayer(id: 'p1', stars: 5);
      final leader = makePlayer(
        id: 'p2',
        name: 'Bob',
        stars: 100,
        position: 10,
      );
      final result = service.processAnswer(
        isCorrect: true,
        player: trailing,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.easy,
        allPlayers: [trailing, leader],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: _FixedRandom(doubleValue: 0.9),
      );

      expect(result.totalStars, greaterThan(result.baseStars));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // processAnswer — incorrect
  // ═══════════════════════════════════════════════════════════════

  group('processAnswer incorrect', () {
    test('incorrect returns unchanged player', () {
      final player = makePlayer(stars: 20);
      final result = service.processAnswer(
        isCorrect: false,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.easy,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: random,
      );

      expect(result.updatedPlayer.stars, 20);
      expect(result.totalStars, 0);
      expect(result.wasCorrect, false);
      expect(result.checkWinCondition, false);
    });

    test('incorrect logs error message', () {
      final player = makePlayer();
      final result = service.processAnswer(
        isCorrect: false,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.easy,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: random,
      );

      expect(result.logs.first.type, 'error');
      expect(result.logs.first.message, contains('Yanlış cevap'));
    });

    test('null categoryName returns unchanged player', () {
      final player = makePlayer(stars: 20);
      final result = service.processAnswer(
        isCorrect: true,
        player: player,
        categoryName: null,
        difficulty: Difficulty.easy,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: random,
      );

      expect(result.updatedPlayer.stars, 20);
      expect(result.wasCorrect, false);
      expect(result.checkWinCondition, false);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // processAnswer — bot vs human logs
  // ═══════════════════════════════════════════════════════════════

  group('bot vs human logs', () {
    test('bot correct log has bot prefix', () {
      final player = makePlayer();
      final result = service.processAnswer(
        isCorrect: true,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.easy,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: _FixedRandom(doubleValue: 0.9),
        isBot: true,
      );

      final correctLog = result.logs
          .where((l) => l.message.contains('Doğru cevap'))
          .first;
      expect(correctLog.message, startsWith('🤖 Bot:'));
    });

    test('human correct log has no bot prefix', () {
      final player = makePlayer();
      final result = service.processAnswer(
        isCorrect: true,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.easy,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: _FixedRandom(doubleValue: 0.9),
        isBot: false,
      );

      final correctLog = result.logs
          .where((l) => l.message.contains('Doğru cevap'))
          .first;
      expect(correctLog.message.startsWith('🤖'), false);
    });

    test('bot incorrect log has bot prefix', () {
      final player = makePlayer();
      final result = service.processAnswer(
        isCorrect: false,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.easy,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: random,
        isBot: true,
      );

      expect(result.logs.first.message, startsWith('🤖 Bot:'));
    });

    test('human incorrect log has no prefix', () {
      final player = makePlayer();
      final result = service.processAnswer(
        isCorrect: false,
        player: player,
        categoryName: 'edebiSanatlar',
        difficulty: Difficulty.easy,
        allPlayers: [player],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
        random: random,
        isBot: false,
      );

      expect(result.logs.first.message, startsWith('Yanlış'));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // computeAdjustedReward
  // ═══════════════════════════════════════════════════════════════

  group('computeAdjustedReward', () {
    test('basic reward without bonuses', () {
      final total = service.computeAdjustedReward(
        baseStars: 5,
        promotionReward: 0,
        currentStars: 50,
        leaderStars: 50,
        consecutiveDoubles: 0,
      );

      expect(total, 5);
    });

    test('includes promotion reward', () {
      final total = service.computeAdjustedReward(
        baseStars: 5,
        promotionReward: 10,
        currentStars: 50,
        leaderStars: 50,
        consecutiveDoubles: 0,
      );

      expect(total, 15);
    });

    test('trailing player gets underdog bonus', () {
      final total = service.computeAdjustedReward(
        baseStars: 5,
        promotionReward: 0,
        currentStars: 5,
        leaderStars: 100,
        consecutiveDoubles: 0,
      );

      expect(total, greaterThan(5));
    });
  });
}
