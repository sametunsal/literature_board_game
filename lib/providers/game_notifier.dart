import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/board_tile.dart';
import '../models/game_enums.dart';
import '../models/game_card.dart';
import '../models/question.dart';
import '../models/tile_type.dart';
import '../models/difficulty.dart';
import '../data/board_config.dart';
import '../data/game_cards.dart';
import '../data/repositories/question_repository_impl.dart';
import '../core/audio_manager.dart'; // Audio Import
import '../core/motion/motion_constants.dart';
import '../core/constants/game_constants.dart';

// Domain layer imports (use cases and services)
import '../domain/services/dice_service.dart';

// Floating Effect Data Model
class FloatingEffect {
  final String text;
  final Color color;
  FloatingEffect(this.text, this.color);
}

class GameState {
  final List<Player> players;
  final List<BoardTile> tiles;
  final int currentPlayerIndex;
  final int diceTotal;
  final int dice1;
  final int dice2;
  final int consecutiveDoubles;
  final String lastAction;
  final bool isDiceRolled;
  final GamePhase phase;

  // LOGS
  final List<String> logs;

  // Floating Effect (Visual)
  final FloatingEffect? floatingEffect;

  // Dialog Durumları
  final Question? currentQuestion;
  final bool showQuestionDialog;
  final bool showCardDialog;
  final bool showLibraryPenaltyDialog;
  final bool showImzaGunuDialog;
  final bool showTurnSkippedDialog;
  final bool showShopDialog; // Kıraathane shop dialog

  final BoardTile? currentTile;
  final GameCard? currentCard;
  final Player? winner;
  final String? setupMessage;

  // Turn Order Determination - stores dice rolls for each player
  final Map<String, int> orderRolls;

  GameState({
    required this.players,
    this.tiles = const [],
    this.currentPlayerIndex = 0,
    this.diceTotal = 0,
    this.dice1 = 0,
    this.dice2 = 0,
    this.consecutiveDoubles = 0,
    this.lastAction = 'Oyun Kurulumu Bekleniyor...',
    this.isDiceRolled = false,
    this.phase = GamePhase.setup,
    this.logs = const [],
    this.floatingEffect,
    this.currentQuestion,
    this.showQuestionDialog = false,
    this.showCardDialog = false,
    this.showLibraryPenaltyDialog = false,
    this.showImzaGunuDialog = false,
    this.showTurnSkippedDialog = false,
    this.showShopDialog = false,
    this.currentTile,
    this.currentCard,
    this.winner,
    this.setupMessage,
    this.orderRolls = const {},
  });

  Player get currentPlayer => players.isNotEmpty
      ? players[currentPlayerIndex % players.length]
      : const Player(id: '0', name: '?', color: Colors.grey, iconIndex: 0);

  GameState copyWith({
    List<Player>? players,
    List<BoardTile>? tiles,
    int? currentPlayerIndex,
    int? diceTotal,
    int? dice1,
    int? dice2,
    int? consecutiveDoubles,
    String? lastAction,
    bool? isDiceRolled,
    GamePhase? phase,
    List<String>? logs,
    FloatingEffect? floatingEffect,
    Question? currentQuestion,
    bool? showQuestionDialog,
    bool? showCardDialog,
    bool? showLibraryPenaltyDialog,
    bool? showImzaGunuDialog,
    bool? showTurnSkippedDialog,
    bool? showShopDialog,
    BoardTile? currentTile,
    GameCard? currentCard,
    Player? winner,
    String? setupMessage,
    Map<String, int>? orderRolls,
  }) {
    return GameState(
      players: players ?? this.players,
      tiles: tiles ?? this.tiles,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      diceTotal: diceTotal ?? this.diceTotal,
      dice1: dice1 ?? this.dice1,
      dice2: dice2 ?? this.dice2,
      consecutiveDoubles: consecutiveDoubles ?? this.consecutiveDoubles,
      lastAction: lastAction ?? this.lastAction,
      isDiceRolled: isDiceRolled ?? this.isDiceRolled,
      phase: phase ?? this.phase,
      logs: logs ?? this.logs,
      floatingEffect: floatingEffect,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      showQuestionDialog: showQuestionDialog ?? this.showQuestionDialog,
      showCardDialog: showCardDialog ?? this.showCardDialog,
      showLibraryPenaltyDialog:
          showLibraryPenaltyDialog ?? this.showLibraryPenaltyDialog,
      showImzaGunuDialog: showImzaGunuDialog ?? this.showImzaGunuDialog,
      showTurnSkippedDialog:
          showTurnSkippedDialog ?? this.showTurnSkippedDialog,
      showShopDialog: showShopDialog ?? this.showShopDialog,
      currentTile: currentTile ?? this.currentTile,
      currentCard: currentCard ?? this.currentCard,
      winner: winner ?? this.winner,
      setupMessage: setupMessage ?? this.setupMessage,
      orderRolls: orderRolls ?? this.orderRolls,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final _random = Random();
  Timer? _animationTimer;
  bool _isProcessing = false;

  // Cached questions for the session
  List<Question> _cachedQuestions = [];

  GameNotifier() : super(GameState(players: []));

  bool get isProcessing => _isProcessing;

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. OYUN BAŞLATMA & KURULUM
  // ═══════════════════════════════════════════════════════════════════════════

  /// Initialize game with player list
  void initializeGame(List<Player> players) async {
    if (players.isEmpty) return;

    // Load questions from repository
    _cachedQuestions = await QuestionRepositoryImpl().getAllQuestions();

    state = GameState(
      players: players,
      tiles: BoardConfig.tiles,
      phase: GamePhase.rollingForOrder,
      lastAction: 'Sıra belirlemek için zar atın...',
    );

    _addLog("Oyun başlatıldı! ${players.length} oyuncu katıldı.");
  }

  /// Set turn order based on dice rolls
  void setTurnOrder(Map<String, int> rolls) {
    final sortedPlayers = List<Player>.from(state.players);
    sortedPlayers.sort(
      (a, b) => (rolls[b.id] ?? 0).compareTo(rolls[a.id] ?? 0),
    );

    state = state.copyWith(
      players: sortedPlayers,
      phase: GamePhase.playerTurn,
      orderRolls: rolls,
      lastAction: 'Sıra belirlendi! ${sortedPlayers.first.name} başlıyor.',
    );

    _addLog("Sıra belirlendi! ${sortedPlayers.first.name} başlıyor.");
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. ZAR ATMA & HAREKET
  // ═══════════════════════════════════════════════════════════════════════════

  /// Roll dice - handles both turn order and normal movement phases
  Future<void> rollDice() async {
    if (_isProcessing) return;

    _isProcessing = true;
    try {
      // Block roll if dialogs are open
      if (state.showQuestionDialog ||
          state.showCardDialog ||
          state.showLibraryPenaltyDialog) {
        return;
      }

      // Check if player has turns to skip (library penalty) - only in playerTurn phase
      if (state.phase == GamePhase.playerTurn &&
          state.currentPlayer.turnsToSkip > 0) {
        final player = state.currentPlayer;
        final remaining = player.turnsToSkip - 1;

        // Decrement turns to skip
        List<Player> newPlayers = List.from(state.players);
        newPlayers[state.currentPlayerIndex] = player.copyWith(
          turnsToSkip: remaining,
        );
        state = state.copyWith(players: newPlayers);

        if (remaining > 0) {
          _addLog(
            "${player.name} hala cezada! Kalan tur: $remaining",
            type: 'error',
          );
        } else {
          _addLog("${player.name} cezasını tamamladı!", type: 'success');
        }

        endTurn();
        return;
      }

      // Generate two independent dice
      int d1 = _random.nextInt(6) + 1;
      int d2 = _random.nextInt(6) + 1;
      int roll = d1 + d2;
      bool isDouble = d1 == d2;

      // Handle based on game phase
      if (state.phase == GamePhase.rollingForOrder) {
        await _handleTurnOrderRoll(d1, d2, roll);
      } else {
        await _handleMovementRoll(d1, d2, roll, isDouble);
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// Handle turn order roll - store roll, show result, advance to next player
  Future<void> _handleTurnOrderRoll(int d1, int d2, int roll) async {
    final currentPlayer = state.currentPlayer;

    // Store the roll for this player
    final updatedOrderRolls = Map<String, int>.from(state.orderRolls);
    updatedOrderRolls[currentPlayer.id] = roll;

    state = state.copyWith(
      isDiceRolled: true,
      diceTotal: roll,
      dice1: d1,
      dice2: d2,
      orderRolls: updatedOrderRolls,
    );

    _addLog(
      "🎲 ${currentPlayer.name} sıra için $roll ($d1-$d2) attı.",
      type: 'dice',
    );

    // Show result for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // Check if everyone has rolled
    if (updatedOrderRolls.length >= state.players.length) {
      // All players have rolled - determine turn order
      _finalizeTurnOrder(updatedOrderRolls);
    } else {
      // Move to next player
      final nextIndex = (state.currentPlayerIndex + 1) % state.players.length;
      state = state.copyWith(
        currentPlayerIndex: nextIndex,
        isDiceRolled: false,
        diceTotal: 0,
        dice1: 0,
        dice2: 0,
      );
    }
  }

  /// Finalize turn order - sort players by roll (highest first)
  void _finalizeTurnOrder(Map<String, int> rolls) {
    // Sort players by their roll (highest roll goes first)
    final sortedPlayers = List<Player>.from(state.players);
    sortedPlayers.sort(
      (a, b) => (rolls[b.id] ?? 0).compareTo(rolls[a.id] ?? 0),
    );

    state = state.copyWith(
      players: sortedPlayers,
      currentPlayerIndex: 0,
      phase: GamePhase.playerTurn,
      isDiceRolled: false,
      diceTotal: 0,
      dice1: 0,
      dice2: 0,
      lastAction: 'Sıra belirlendi! ${sortedPlayers.first.name} başlıyor.',
    );

    _addLog("✅ Sıra belirlendi! ${sortedPlayers.first.name} başlıyor.");

    // Log the order
    for (int i = 0; i < sortedPlayers.length; i++) {
      final player = sortedPlayers[i];
      final roll = rolls[player.id] ?? 0;
      _addLog("  ${i + 1}. ${player.name} ($roll)");
    }
  }

  /// Handle normal movement roll
  Future<void> _handleMovementRoll(
    int d1,
    int d2,
    int roll,
    bool isDouble,
  ) async {
    int newConsecutive = isDouble ? state.consecutiveDoubles + 1 : 0;

    // Check for 3 consecutive doubles -> Jail
    if (newConsecutive >= 3) {
      state = state.copyWith(
        dice1: d1,
        dice2: d2,
        diceTotal: roll,
        isDiceRolled: true,
        consecutiveDoubles: 0, // Reset
      );
      _addLog("3. Çift Zar ($d1-$d2)! Kütüphaneye gidiyorsun.", type: 'error');

      // Send to jail immediately
      await Future.delayed(const Duration(milliseconds: 1500));
      List<Player> temp = List.from(state.players);
      temp[state.currentPlayerIndex] = state.currentPlayer.copyWith(
        position: GameConstants.jailPosition,
        turnsToSkip: GameConstants.jailTurns,
      );
      state = state.copyWith(players: temp);
      endTurn();
      return;
    }

    state = state.copyWith(
      isDiceRolled: true,
      diceTotal: roll,
      dice1: d1,
      dice2: d2,
      consecutiveDoubles: newConsecutive,
    );

    if (isDouble) {
      _addLog(
        "${state.currentPlayer.name} $roll ($d1-$d2) attı. Çift! Tekrar oynayacak.",
        type: 'dice',
      );
    } else {
      _addLog(
        "${state.currentPlayer.name} $roll ($d1-$d2) attı.",
        type: 'dice',
      );
    }

    // Wait for dice animation to settle before moving
    await Future.delayed(const Duration(milliseconds: 1500));
    await _movePlayer(roll);
  }

  /// Move player step-by-step with hopping animation
  Future<void> _movePlayer(int steps) async {
    var player = state.currentPlayer;

    if (player.inJail) {
      if (_random.nextBool()) {
        List<Player> newPlayers = List.from(state.players);
        newPlayers[state.currentPlayerIndex] = player.copyWith(inJail: false);
        state = state.copyWith(players: newPlayers);
        _addLog("Nöbetten erken çıktın!", type: 'success');
      } else {
        _addLog("Hâlâ nöbettesin. Tur geçti.", type: 'error');
        endTurn();
        return;
      }
    }

    // Step-by-step hopping movement
    int currentPos = player.position;

    for (int i = 0; i < steps; i++) {
      currentPos = (currentPos + 1) % BoardConfig.boardSize;

      // Check if passed start
      if (currentPos == BoardConfig.startPosition) {
        // Award stars for passing start
        List<Player> startPlayers = List.from(state.players);
        startPlayers[state.currentPlayerIndex] = player.copyWith(
          stars: player.stars + GameConstants.passingStartBonus,
        );
        state = state.copyWith(players: startPlayers);
        player = state.currentPlayer;

        _addLog(
          "Başlangıçtan geçtin: +${GameConstants.passingStartBonus} Yıldız",
          type: 'purchase',
        );
      }

      // Update position for each step
      List<Player> stepPlayers = List.from(state.players);
      stepPlayers[state.currentPlayerIndex] = player.copyWith(
        position: currentPos,
      );
      state = state.copyWith(players: stepPlayers);
      player = state.currentPlayer;

      // Wait for hop animation
      await Future.delayed(
        Duration(milliseconds: GameConstants.hopAnimationDelay),
      );
    }

    final tile = state.tiles[currentPos];

    state = state.copyWith(currentTile: tile);
    _addLog("${tile.name} karesine gelindi.");

    _handleTileArrival(tile);
  }

  void _handleTileArrival(BoardTile tile) {
    switch (tile.type) {
      case TileType.category:
        if (tile.category != null) {
          _triggerQuestion(tile);
        } else {
          endTurn();
        }
        break;
      case TileType.start:
        // Start tile - no action needed
        endTurn();
        break;
      case TileType.shop:
        // Kıraathane - Open shop
        handleKiraathaneLanding();
        break;
      case TileType.library:
        // Kütüphane - Apply 2-turn penalty
        _handleLibraryLanding();
        break;
      case TileType.signingDay:
        // İmza Günü - Show dialog, no penalty
        _handleSigningDayLanding();
        break;
      case TileType.corner:
      case TileType.collection:
        // Generic corners - end turn
        endTurn();
        break;
    }
  }

  /// Handle Kütüphane (Library) landing - Apply 2-turn penalty
  void _handleLibraryLanding() {
    final player = state.currentPlayer;
    const libraryPenaltyTurns = 2;

    List<Player> newPlayers = List.from(state.players);
    newPlayers[state.currentPlayerIndex] = player.copyWith(
      turnsToSkip: libraryPenaltyTurns,
    );

    state = state.copyWith(players: newPlayers, showLibraryPenaltyDialog: true);

    _addLog(
      "📚 ${player.name} Kütüphanede! Sessizlik lazım, $libraryPenaltyTurns tur bekle.",
      type: 'error',
    );
  }

  /// Handle İmza Günü (Signing Day) landing - Show dialog, no penalty
  void _handleSigningDayLanding() {
    final player = state.currentPlayer;

    state = state.copyWith(showImzaGunuDialog: true);

    _addLog(
      "✍️ ${player.name} İmza Günü'nde okurlarıyla buluştu!",
      type: 'success',
    );
  }

  /// Close library penalty dialog and set turnsToSkip
  void closeLibraryPenaltyDialog() {
    final player = state.currentPlayer;
    List<Player> newPlayers = List.from(state.players);
    newPlayers[state.currentPlayerIndex] = player.copyWith(
      turnsToSkip: GameConstants.jailTurns,
    );

    state = state.copyWith(
      players: newPlayers,
      showLibraryPenaltyDialog: false,
    );

    _addLog(
      "${player.name} ${GameConstants.jailTurns} tur ceza aldı!",
      type: 'error',
    );
    endTurn();
  }

  /// Close İmza Günü dialog and end turn
  void closeImzaGunuDialog() {
    state = state.copyWith(showImzaGunuDialog: false);
    endTurn();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. SORU & MASTERY SİSTEMİ
  // ═══════════════════════════════════════════════════════════════════════════

  /// Auto-select difficulty based on player's mastery level
  /// - Novice -> Easy
  /// - Çırak -> Medium
  /// - Kalfa -> Hard
  /// - Usta -> Hard (for farming rewards)
  Difficulty _getDifficultyForMasteryLevel(MasteryLevel level) {
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

  void _triggerQuestion(BoardTile tile) {
    if (tile.category == null) {
      _addLog('Bu karoda soru yok.', type: 'info');
      endTurn();
      return;
    }

    final categoryName = tile.category!;
    final player = state.currentPlayer;

    // AUTO-DIFFICULTY: Get difficulty based on player's mastery level
    final masteryLevel = player.getMasteryLevel(categoryName);
    final targetDifficulty = _getDifficultyForMasteryLevel(masteryLevel);
    final difficultyFilter = switch (targetDifficulty) {
      Difficulty.easy => 'easy',
      Difficulty.medium => 'medium',
      Difficulty.hard => 'hard',
    };

    // Log the auto-selected difficulty
    final masteryName = masteryLevel.displayName;
    _addLog(
      '${_getCategoryDisplayName(categoryName)} kategorisinde $masteryName seviyesi: $difficultyFilter soru seçildi.',
      type: 'info',
    );

    // Filter questions by category and auto-selected difficulty
    final filteredQuestions = _cachedQuestions.where((q) {
      final matchesCategory = q.category.name == categoryName;
      final matchesDifficulty = q.difficulty == difficultyFilter;
      return matchesCategory && matchesDifficulty;
    }).toList();

    if (filteredQuestions.isEmpty) {
      // Fallback: any question from this category
      final categoryQuestions = _cachedQuestions
          .where((q) => q.category.name == categoryName)
          .toList();
      if (categoryQuestions.isEmpty) {
        _addLog('Bu kategoride soru bulunamadı!', type: 'error');
        endTurn();
        return;
      }
      final q = categoryQuestions[_random.nextInt(categoryQuestions.length)];
      state = state.copyWith(
        showQuestionDialog: true,
        currentQuestion: q,
        currentTile: tile,
      );
      _addLog(
        '⚠ $difficultyFilter zorlu soru bulunamadı, rastgele soru seçildi.',
        type: 'info',
      );
    } else {
      final q = filteredQuestions[_random.nextInt(filteredQuestions.length)];
      state = state.copyWith(
        showQuestionDialog: true,
        currentQuestion: q,
        currentTile: tile,
      );
    }
  }

  /// Answer question and handle mastery progression
  /// Mastery System:
  /// - 3 Easy answers → Çırak (1x reward)
  /// - 3 Medium answers → Kalfa (2x reward) [requires Çırak]
  /// - 3 Hard answers → Usta (3x reward) [requires Kalfa]
  void answerQuestion(bool isCorrect) async {
    if (_isProcessing || state.currentQuestion == null) return;

    _isProcessing = true;
    bool shouldEndTurn = false;

    try {
      final tile = state.currentTile;
      final categoryName = tile?.category;
      final difficulty = tile?.difficulty ?? Difficulty.medium;

      state = state.copyWith(showQuestionDialog: false, currentQuestion: null);

      if (isCorrect && categoryName != null) {
        final player = state.currentPlayer;

        // Record correct answer for this category and difficulty
        final newAnswerCount = player.recordCorrectAnswer(
          categoryName,
          difficulty,
        );
        final currentMastery = player.getMasteryLevel(categoryName);

        // Base stars for correct answer
        int baseStars = switch (difficulty) {
          Difficulty.easy => GameConstants.easyStarReward,
          Difficulty.medium => GameConstants.mediumStarReward,
          Difficulty.hard => GameConstants.hardStarReward,
        };

        String difficultyName = difficulty.displayName;
        String promotionMessage = '';
        MasteryLevel? newMastery;
        int promotionReward = 0;

        // Check for promotion
        if (currentMastery == MasteryLevel.novice &&
            difficulty == Difficulty.easy &&
            newAnswerCount >= GameConstants.answersRequiredForPromotion) {
          // Promote to Çırak
          newMastery = MasteryLevel.cirak;
          promotionReward = GameConstants.promotionBaseReward * 1; // 1x
          promotionMessage =
              '🏆 ${_getCategoryDisplayName(categoryName)} kategorisinde Çırak oldun!';
        } else if (currentMastery == MasteryLevel.cirak &&
            difficulty == Difficulty.medium &&
            newAnswerCount >= GameConstants.answersRequiredForPromotion) {
          // Promote to Kalfa
          newMastery = MasteryLevel.kalfa;
          promotionReward = GameConstants.promotionBaseReward * 2; // 2x
          promotionMessage =
              '🏆 ${_getCategoryDisplayName(categoryName)} kategorisinde Kalfa oldun!';
        } else if (currentMastery == MasteryLevel.kalfa &&
            difficulty == Difficulty.hard &&
            newAnswerCount >= GameConstants.answersRequiredForPromotion) {
          // Promote to Usta
          newMastery = MasteryLevel.usta;
          promotionReward = GameConstants.promotionBaseReward * 3; // 3x
          promotionMessage =
              '🏆 ${_getCategoryDisplayName(categoryName)} kategorisinde Usta oldun!';
        }

        // Calculate total stars
        int totalStars = baseStars + promotionReward;

        // Update player
        List<Player> newPlayers = List.from(state.players);
        var updatedPlayer = player;

        // Update category progress
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

        // Apply promotion if occurred
        if (newMastery != null) {
          final newLevels = Map<String, int>.from(player.categoryLevels);
          newLevels[categoryName] = newMastery.value;
          updatedPlayer = updatedPlayer.copyWith(categoryLevels: newLevels);
        }

        // Add stars
        updatedPlayer = updatedPlayer.copyWith(
          stars: updatedPlayer.stars + totalStars,
        );

        newPlayers[state.currentPlayerIndex] = updatedPlayer;
        state = state.copyWith(players: newPlayers);

        // Log messages
        _addLog(
          'Doğru cevap! +$baseStars ⭐ ($difficultyName)',
          type: 'success',
        );

        if (promotionMessage.isNotEmpty) {
          _addLog(
            '$promotionMessage (+$promotionReward ⭐ bonus)',
            type: 'success',
          );
        }

        await Future.delayed(
          Duration(milliseconds: GameConstants.cardAnimationDelay),
        );

        // Check win condition
        _checkWinCondition();

        if (state.phase != GamePhase.gameOver) {
          shouldEndTurn = true;
        }
      } else if (!isCorrect) {
        _addLog("Yanlış cevap. Yıldız kazanamadın.", type: 'error');
        shouldEndTurn = true;
      } else {
        shouldEndTurn = true;
      }
    } finally {
      _isProcessing = false;
    }

    if (shouldEndTurn) {
      endTurn();
    }
  }

  /// Get display name for category
  String _getCategoryDisplayName(String categoryName) {
    switch (categoryName) {
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
      default:
        return categoryName;
    }
  }

  void _drawCard(CardType cardType) async {
    await Future.delayed(
      Duration(milliseconds: GameConstants.cardAnimationDelay),
    );
    List<GameCard> deck = cardType == CardType.sans
        ? GameCards.sansCards
        : GameCards.kaderCards;
    GameCard card = deck[_random.nextInt(deck.length)];
    state = state.copyWith(showCardDialog: true, currentCard: card);
  }

  void closeCardDialog() {
    if (state.currentCard != null) {
      final card = state.currentCard!;
      final player = state.currentPlayer;

      switch (card.effectType) {
        case CardEffectType.moneyChange:
          final newStars = player.stars + card.value;
          _updateStars(player, newStars);
          if (card.value > 0) {
            _addLog(
              "💰 ${player.name} +${card.value} yıldız kazandı!",
              type: 'success',
            );
          } else {
            _addLog(
              "💸 ${player.name} ${card.value} yıldız kaybetti!",
              type: 'error',
            );
          }
          break;

        case CardEffectType.move:
          int targetPos = card.value % BoardConfig.boardSize;
          bool passedStart = targetPos < player.position;

          List<Player> newPlayers = List.from(state.players);
          int newStars = player.stars;

          if (passedStart && targetPos != BoardConfig.startPosition) {
            newStars += GameConstants.passingStartBonus;
            _addLog(
              "🏁 Başlangıçtan geçtin: +${GameConstants.passingStartBonus} Yıldız!",
              type: 'success',
            );
          }

          newPlayers[state.currentPlayerIndex] = player.copyWith(
            position: targetPos,
            stars: newStars,
          );
          state = state.copyWith(players: newPlayers);
          _addLog("🎯 ${player.name} $targetPos. kareye taşındı!");
          break;

        case CardEffectType.jail:
          List<Player> temp = List.from(state.players);
          temp[state.currentPlayerIndex] = player.copyWith(
            position: BoardConfig.shopPosition,
            turnsToSkip: GameConstants.jailTurns,
          );
          state = state.copyWith(players: temp);
          _addLog(
            "⛔ ${player.name} kütüphane nöbetine yollandı!",
            type: 'error',
          );
          break;

        case CardEffectType.globalMoney:
          List<Player> updatedPlayers = List.from(state.players);
          final currentIdx = state.currentPlayerIndex;
          int totalTransfer = 0;

          for (int i = 0; i < updatedPlayers.length; i++) {
            if (i != currentIdx) {
              if (card.value > 0) {
                int amount = card.value;
                if (updatedPlayers[i].stars < amount) {
                  amount = updatedPlayers[i].stars > 0
                      ? updatedPlayers[i].stars
                      : 0;
                }
                updatedPlayers[i] = updatedPlayers[i].copyWith(
                  stars: updatedPlayers[i].stars - amount,
                );
                totalTransfer += amount;
              } else {
                int amount = -card.value;
                updatedPlayers[i] = updatedPlayers[i].copyWith(
                  stars: updatedPlayers[i].stars + amount,
                );
                totalTransfer += amount;
              }
            }
          }

          int finalStars = card.value > 0
              ? player.stars + totalTransfer
              : player.stars - totalTransfer;
          updatedPlayers[currentIdx] = updatedPlayers[currentIdx].copyWith(
            stars: finalStars,
          );

          state = state.copyWith(players: updatedPlayers);

          if (card.value > 0) {
            _addLog(
              "🏆 ${player.name} herkesten toplam $totalTransfer ⭐ aldı!",
              type: 'success',
            );
          } else {
            _addLog(
              "💸 ${player.name} herkese toplam $totalTransfer ⭐ ödedi!",
              type: 'error',
            );
          }
          break;
      }
    }
    state = state.copyWith(showCardDialog: false, currentCard: null);
    endTurn();
  }

  void closeDialogs() {
    state = state.copyWith(showCardDialog: false);
    endTurn();
  }

  void endGame() {
    if (state.players.isEmpty) return;

    Player winner = state.players.reduce(
      (curr, next) => curr.stars > next.stars ? curr : next,
    );

    state = state.copyWith(winner: winner, phase: GamePhase.gameOver);
    _addLog("🏆 OYUN BİTTİ! Kazanan: ${winner.name}", type: 'gameover');
  }

  void endTurn() async {
    if (_isProcessing || state.phase == GamePhase.gameOver) return;

    _isProcessing = true;
    try {
      if (state.phase == GamePhase.playerTurn &&
          state.dice1 == state.dice2 &&
          state.dice1 != 0 &&
          state.currentPlayer.turnsToSkip == 0 &&
          !state.currentPlayer.inJail) {
        _addLog("Çift olduğu için tekrar zar at!", type: 'info');
        state = state.copyWith(
          isDiceRolled: false,
          lastAction: "${state.currentPlayer.name} tekrar zar atacak...",
        );
        return;
      }

      await Future.delayed(
        Duration(milliseconds: GameConstants.turnChangeDelay),
      );
      int next = (state.currentPlayerIndex + 1) % state.players.length;

      final nextPlayer = state.players[next];

      bool isSkipped = false;
      List<Player> updatedPlayers = List.from(state.players);

      if (nextPlayer.turnsToSkip > 0) {
        isSkipped = true;
        updatedPlayers[next] = nextPlayer.copyWith(
          turnsToSkip: nextPlayer.turnsToSkip - 1,
        );
      }

      state = state.copyWith(
        players: updatedPlayers,
        currentPlayerIndex: next,
        isDiceRolled: false,
        showQuestionDialog: false,
        showCardDialog: false,
        showTurnSkippedDialog: isSkipped,
      );

      if (isSkipped) {
        _addLog("${nextPlayer.name} cezalı! Tur atlanıyor.", type: 'error');
      } else {
        _addLog("Sıra ${state.players[next].name} oyuncusunda.", type: 'turn');
      }
    } finally {
      _isProcessing = false;
    }
  }

  void closeTurnSkippedDialog() {
    state = state.copyWith(showTurnSkippedDialog: false);
    endTurn();
  }

  void _updateStars(Player p, int stars) async {
    int idx = state.players.indexWhere((x) => x.id == p.id);
    if (idx == -1) return;

    int diff = stars - p.stars;
    if (diff != 0) {
      String sign = diff > 0 ? "+" : "";
      Color color = diff > 0 ? Colors.greenAccent : Colors.redAccent;
      state = state.copyWith(
        floatingEffect: FloatingEffect("$sign$diff", color),
      );
    }

    List<Player> list = List.from(state.players);
    list[idx] = list[idx].copyWith(stars: stars);
    state = state.copyWith(players: list);

    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      state = state.copyWith(floatingEffect: null);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOP (KIRAATHANE) METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  void openShopDialog() {
    state = state.copyWith(showShopDialog: true);
    _addLog('Kıraathane\'ye hoş geldiniz!', type: 'info');
  }

  void closeShopDialog() {
    state = state.copyWith(showShopDialog: false);
    endTurn();
  }

  void purchaseQuote(String quoteId, int cost) {
    final player = state.currentPlayer;

    if (player.collectedQuotes.contains(quoteId)) {
      _addLog('Bu söz zaten koleksiyonunda!', type: 'error');
      return;
    }

    if (player.stars < cost) {
      _addLog('Yeterli yıldızın yok!', type: 'error');
      return;
    }

    final newCollectedQuotes = List<String>.from(player.collectedQuotes)
      ..add(quoteId);
    final newStars = player.stars - cost;

    List<Player> newPlayers = List.from(state.players);
    newPlayers[state.currentPlayerIndex] = player.copyWith(
      stars: newStars,
      collectedQuotes: newCollectedQuotes,
    );

    state = state.copyWith(players: newPlayers);
    _addLog('Söz satın alındı! (-$cost ⭐)', type: 'purchase');

    _checkWinCondition();
  }

  /// Check if current player has won (Ehil)
  /// Win Condition: 50 quotes collected AND Usta in all 6 categories
  void _checkWinCondition() {
    final player = state.currentPlayer;

    if (player.hasWon()) {
      List<Player> newPlayers = List.from(state.players);
      newPlayers[state.currentPlayerIndex] = player.copyWith(mainTitle: 'Ehil');

      state = state.copyWith(
        players: newPlayers,
        winner: newPlayers[state.currentPlayerIndex],
        phase: GamePhase.gameOver,
      );

      _addLog('🏆 ${player.name} EHİL oldu! Oyun bitti!', type: 'gameover');
    }
  }

  void handleKiraathaneLanding() {
    openShopDialog();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGGING
  // ═══════════════════════════════════════════════════════════════════════════

  void _addLog(String message, {String type = 'info'}) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final logEntry = '[$timestamp] $message';

    final newLogs = List<String>.from(state.logs)..add(logEntry);
    if (newLogs.length > 100) {
      newLogs.removeAt(0);
    }

    state = state.copyWith(logs: newLogs);
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>(
  (ref) => GameNotifier(),
);
