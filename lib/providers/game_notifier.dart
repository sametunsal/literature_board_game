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
  final Random _random = Random();
  bool _isProcessing = false;
  Timer? _animationTimer;

  // Domain layer use cases and services
  // Domain layer use cases and services
  // TODO: Implement proper Clean Architecture by delegating logic to these use cases
  // currently logic is embedded in the Notifier for State/UI handling.
  final RandomDiceService _diceService = RandomDiceService();

  // List of player IDs involved in a tie-breaker
  List<String> _tieBreakerIds = [];

  // Question repository and cached questions
  final QuestionRepositoryImpl _questionRepository = QuestionRepositoryImpl();
  List<Question> _cachedQuestions = [];

  GameNotifier() : super(GameState(players: [], tiles: BoardConfig.tiles)) {
    _loadQuestions();
  }

  /// Load questions from repository
  Future<void> _loadQuestions() async {
    try {
      _cachedQuestions = await _questionRepository.getAllQuestions();
      _addLog('${_cachedQuestions.length} soru yüklendi.', type: 'info');
    } catch (e) {
      _addLog('Soru yükleme hatası: $e', type: 'error');
    }
  }

  // --- LOG & AUDIO HELPER ---
  void _addLog(String message, {String type = 'info'}) {
    List<String> newLogs = List.from(state.logs)..add(message);
    state = state.copyWith(logs: newLogs, lastAction: message);

    // Ses Efektleri
    if (type == 'dice') {
      AudioManager.instance.playDiceRoll();
    } else if (type == 'success') {
      AudioManager.instance.playSuccess();
    } else if (type == 'error') {
      AudioManager.instance.playError();
    } else if (type == 'purchase') {
      AudioManager.instance.playPurchase();
    } else if (type == 'gameover') {
      AudioManager.instance.playGameOver();
    } else if (type == 'turn') {
      AudioManager.instance.playTurnChange();
    }
  }

  // --- 1. SETUP ve SIRALAMA ---
  void initializeGame(List<Player> setupPlayers) {
    _tieBreakerIds = []; // Reset tie breaker list
    state = state.copyWith(
      players: setupPlayers,
      currentPlayerIndex: 0,
      phase: GamePhase.rollingForOrder,
      orderRolls: {}, // Reset order rolls
      lastAction: "${setupPlayers[0].name} sıra için zar atacak...",
      // Reset match state
      diceTotal: 0,
      isDiceRolled: false,
      currentTile: null,
      currentCard: null,
      currentQuestion: null,
      winner: null,
      floatingEffect: null,
      // Reset all dialog flags
      showQuestionDialog: false,
      showCardDialog: false,
      showLibraryPenaltyDialog: false,
      showImzaGunuDialog: false,
      showTurnSkippedDialog: false,
      showShopDialog: false,
    );
    _addLog("Oyun Kuruluyor - Sıralama belirleniyor...", type: 'info');
  }

  /// Roll dice for current player during turn order determination
  /// Returns dice result for UI animation purposes
  int rollForTurnOrder() {
    if (state.phase != GamePhase.rollingForOrder) return 0;

    final currentPlayer = state.currentPlayer;

    // Generate two independent dice for proper visual display
    final d1 = _random.nextInt(6) + 1;
    final d2 = _random.nextInt(6) + 1;
    final roll = d1 + d2;

    // Store roll
    final newOrderRolls = Map<String, int>.from(state.orderRolls);
    newOrderRolls[currentPlayer.id] = roll;

    _addLog("${currentPlayer.name} zar attı: $roll ($d1-$d2)", type: 'info');

    // Check if next player exists (considering tie breakers)
    _advanceToNextRoller();

    // Check if we finished the round (looped back to start or end of list)
    if (state.currentPlayerIndex >= state.players.length) {
      // All players rolled - determine final order (and show last roll)
      // We need to update state to show the last player's roll before finalizing
      // CRITICAL FIX: Keep currentPlayerIndex pointing to the player who just rolled
      // instead of the out-of-bounds index from _advanceToNextRoller().
      state = state.copyWith(
        currentPlayerIndex: state.players.indexOf(currentPlayer),
        orderRolls: newOrderRolls,
        diceTotal: roll,
        dice1: d1,
        dice2: d2,
        isDiceRolled: true,
      );

      // Delay finalization slightly to let animation play
      Future.delayed(const Duration(milliseconds: 2000), () {
        _finalizeOrder(newOrderRolls);
      });
    } else {
      // Move to next player
      state = state.copyWith(
        orderRolls: newOrderRolls,
        diceTotal: roll,
        dice1: d1,
        dice2: d2,
        isDiceRolled: true, // Trigger dice animation
        lastAction:
            "${state.players[state.currentPlayerIndex].name} sıra için zar atacak...",
      );

      // Reset isDiceRolled after animation completes (only for rollingForOrder phase)
      _animationTimer?.cancel();
      _animationTimer = Timer(
        MotionDurations.dice.safe +
            Duration(milliseconds: GameConstants.diceResetDelay),
        () {
          if (state.phase == GamePhase.rollingForOrder) {
            state = state.copyWith(isDiceRolled: false);
          }
        },
      );
    }

    return roll;
  }

  /// Skip players not involved in tie-breaker
  void _advanceToNextRoller() {
    state = state.copyWith(currentPlayerIndex: state.currentPlayerIndex + 1);

    // If active tie breaker, skip players not in the list
    if (_tieBreakerIds.isNotEmpty) {
      while (state.currentPlayerIndex < state.players.length &&
          !_tieBreakerIds.contains(
            state.players[state.currentPlayerIndex].id,
          )) {
        state = state.copyWith(
          currentPlayerIndex: state.currentPlayerIndex + 1,
        );
      }
    }
  }

  /// Finalize turn order based on collected rolls
  void _finalizeOrder(Map<String, int> rolls) {
    // Sort players by their rolls (highest first)
    List<Player> sortedPlayers = List.from(state.players);
    sortedPlayers.sort((a, b) {
      final rollA = rolls[a.id] ?? 0;
      final rollB = rolls[b.id] ?? 0;
      return rollB.compareTo(rollA); // Descending order
    });

    // Check for TIE (for 1st place)
    final topRoll = rolls[sortedPlayers[0].id] ?? 0;
    final tiedPlayers = sortedPlayers
        .where((p) => (rolls[p.id] ?? 0) == topRoll)
        .toList();

    if (tiedPlayers.length > 1) {
      // TIE FOUND - RE-ROLL required
      _tieBreakerIds = tiedPlayers.map((p) => p.id).toList();

      // Clear rolls for tied players only
      final newOrderRolls = Map<String, int>.from(rolls);
      for (final p in tiedPlayers) {
        newOrderRolls.remove(p.id);
      }

      String tieMsg =
          "Eşitlik: ${tiedPlayers.map((p) => p.name).join(' ve ')} için tekrar zar atılacak!";
      _addLog(tieMsg, type: 'info');

      state = state.copyWith(
        orderRolls: newOrderRolls,
        currentPlayerIndex: 0, // Reset for re-roll loop
        lastAction: tieMsg,
        // Reset dice state
        isDiceRolled: false,
        diceTotal: 0,
        dice1: 0,
        dice2: 0,
      );

      // Advance to first tied player
      _advanceToNextRoller();
      return; // EXIT here to wait for re-rolls
    }

    _tieBreakerIds = []; // Clear tie breakers if resolved

    String orderMsg =
        "Sıralama: ${sortedPlayers.map((p) => '${p.name} (${rolls[p.id]})').join(', ')}";

    state = state.copyWith(
      players: sortedPlayers,
      currentPlayerIndex: 0,
      phase: GamePhase.playerTurn,
      orderRolls: {}, // Clear rolls after use
      lastAction: "${sortedPlayers[0].name} başlıyor!",
      // Reset dice state so the start game button appears
      isDiceRolled: false,
      diceTotal: 0,
      dice1: 0,
      dice2: 0,
    );

    _addLog(orderMsg, type: 'success');
    _addLog("Oyun Başladı! ${sortedPlayers[0].name} oynuyor.", type: 'success');
  }

  // --- 2. OYUN DÖNGÜSÜ ---
  void rollDice() async {
    if (_isProcessing ||
        state.isDiceRolled ||
        state.phase != GamePhase.playerTurn) {
      return;
    }
    if (state.showQuestionDialog ||
        state.showCardDialog ||
        state.showLibraryPenaltyDialog) {
      return;
    }

    _isProcessing = true;
    try {
      if (state.showQuestionDialog ||
          state.showCardDialog ||
          state.showLibraryPenaltyDialog) {
        return;
      }

      // Check if player has turns to skip (library penalty)
      if (state.currentPlayer.turnsToSkip > 0) {
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
        _addLog(
          "3. Çift Zar ($d1-$d2)! Kütüphaneye gidiyorsun.",
          type: 'error',
        );

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
      await _movePlayer(roll); // MUST await to keep _isProcessing lock active
    } finally {
      _isProcessing = false;
    }
  }

  /// Move player step-by-step with hopping animation
  /// NOTE: _isProcessing is managed by rollDice(), not here
  Future<void> _movePlayer(int steps) async {
    var player = state.currentPlayer;

    // _isProcessing handling removed - rollDice() manages the lock
    // to prevent race conditions with question dialogs

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
        player = state.currentPlayer; // Update local player reference

        _addLog(
          "Başlangıçtan geçtin: +${GameConstants.passingStartBonus} Yıldız",
          type: 'purchase',
        );
      }

      // Update position for each step (triggers hop animation in UI)
      List<Player> stepPlayers = List.from(state.players);
      stepPlayers[state.currentPlayerIndex] = player.copyWith(
        position: currentPos,
      );
      state = state.copyWith(players: stepPlayers);
      player = state.currentPlayer; // Update local player reference

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
    if (tile.type == TileType.category && tile.category != null) {
      _triggerQuestion(tile);
    } else if (tile.type == TileType.corner) {
      // Corner tiles: START (no action), ŞANS (chance), KADER (fate), KIRAATHANe (shop)
      if (tile.position == GameConstants.chancePosition ||
          tile.position == GameConstants.fatePosition) {
        _drawCard(
          tile.position == GameConstants.chancePosition
              ? CardType
                    .sans // Use CardType enum for card drawing
              : CardType.kader,
        );
      } else if (tile.position == GameConstants.shopPosition) {
        handleKiraathaneLanding();
      } else {
        // START tile - no action
        endTurn();
      }
    } else {
      endTurn();
    }
  }

  /// Close library penalty dialog and set turnsToSkip
  void closeLibraryPenaltyDialog() {
    // Set jail turns penalty for current player
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

  /// Close İmza Günü dialog and end turn (informative only, no penalty)
  void closeImzaGunuDialog() {
    state = state.copyWith(showImzaGunuDialog: false);
    endTurn();
  }

  // --- 4. YARDIMCILAR ---
  void _triggerQuestion(BoardTile tile) {
    // RPG MODE: Always show question for category tiles
    if (tile.category == null) {
      // No category (shouldn't happen with new 22-tile layout)
      _addLog('Bu karoda soru yok.', type: 'info');
      endTurn();
      return;
    }

    // Get question based on tile difficulty (not player level)
    // Questions are now tied to tile difficulty, not player progression
    final player = state.currentPlayer;
    final categoryName = tile.category!;

    // Determine difficulty based on tile difficulty
    String difficultyFilter;
    switch (tile.difficulty) {
      case Difficulty.easy:
        difficultyFilter = 'easy';
        break;
      case Difficulty.medium:
        difficultyFilter = 'medium';
        break;
      case Difficulty.hard:
        difficultyFilter = 'hard';
        break;
    }

    // Filter questions by category and difficulty
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

  /// Answer question with open-ended format (Bildin/Bilemedin)
  ///
  /// Level Up System:
  /// - Correct answer on Easy tile: +1 level, +5 stars
  /// - Correct answer on Medium tile: +1 level, +10 stars
  /// - Correct answer on Hard tile: +1 level, +15 stars
  /// - Wrong answer: No level change, no stars
  /// - Maximum level per category: 3 (Master)
  /// - Bonus stars for reaching new levels: +20 stars
  void answerQuestion(bool isCorrect) async {
    if (_isProcessing || state.currentQuestion == null) return;

    _isProcessing = true;
    bool shouldEndTurn = false;

    try {
      final tile = state.currentTile;
      final categoryName = tile?.category;

      state = state.copyWith(showQuestionDialog: false, currentQuestion: null);

      if (isCorrect && categoryName != null) {
        // LEVEL UP SYSTEM: Award stars and increase level
        final player = state.currentPlayer;
        final currentLevel = player.categoryLevels[categoryName] ?? 0;

        // Determine star reward based on tile difficulty
        int starsAwarded;
        String difficultyName;

        switch (tile!.difficulty) {
          case Difficulty.easy:
            starsAwarded = GameConstants.easyStarReward;
            difficultyName = 'Kolay';
            break;
          case Difficulty.medium:
            starsAwarded = GameConstants.mediumStarReward;
            difficultyName = 'Orta';
            break;
          case Difficulty.hard:
            starsAwarded = GameConstants.hardStarReward;
            difficultyName = 'Zor';
            break;
        }

        // Check if player can level up (max level is 3)
        int newLevel = currentLevel;
        final newCategoryLevels = Map<String, int>.from(player.categoryLevels);
        String promotionMessage = '';

        if (currentLevel < GameConstants.maxLevelPerCategory) {
          // LEVEL UP! Increase level and award bonus stars
          newLevel = currentLevel + 1;
          newCategoryLevels[categoryName] = newLevel;

          // Award bonus stars for level up
          final totalStars = starsAwarded + GameConstants.levelUpBonusStars;

          // Get rank name
          String rankName;
          switch (newLevel) {
            case 1:
              rankName = 'Çırak';
              break;
            case 2:
              rankName = 'Kalfa';
              break;
            case 3:
              rankName = 'Usta';
              break;
            default:
              rankName = 'Seviye $newLevel';
          }

          // Get category display name
          final categoryDisplayName = _getCategoryDisplayName(categoryName);
          promotionMessage =
              '🏆 $categoryDisplayName kategorisinde $rankName oldun! (+${GameConstants.levelUpBonusStars} ⭐ bonus)';

          // Update player with new level and stars
          List<Player> newPlayers = List.from(state.players);
          newPlayers[state.currentPlayerIndex] = player.copyWith(
            stars: player.stars + totalStars,
            categoryLevels: newCategoryLevels,
          );
          state = state.copyWith(players: newPlayers);
        } else {
          // Already at max level - only award stars
          promotionMessage =
              '⭐ Zaten Usta seviyesindesin! Sadece yıldız kazandın.';

          // Update player with stars only
          List<Player> newPlayers = List.from(state.players);
          newPlayers[state.currentPlayerIndex] = player.copyWith(
            stars: player.stars + starsAwarded,
          );
          state = state.copyWith(players: newPlayers);
        }

        // Log messages
        _addLog(
          'Doğru cevap! +$starsAwarded ⭐ ($difficultyName)',
          type: 'success',
        );
        if (promotionMessage.isNotEmpty) {
          _addLog(promotionMessage, type: 'success');
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
        // Wrong answer - no stars, no level change
        _addLog("Yanlış cevap. Seviye veya yıldız kazanamadın.", type: 'error');
        shouldEndTurn = true;
      } else {
        // No category (shouldn't happen)
        shouldEndTurn = true;
      }
    } finally {
      _isProcessing = false;
    }

    if (shouldEndTurn) {
      endTurn();
    }
  }

  /// Get display name for category (helper)
  /// Note: categoryName is a String from the tile's category field
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
    // NOTE: _isProcessing guard removed - rollDice() manages the lock
    // This method is called from _handleTileArrival which is inside rollDice's lock

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

          // Give passing start bonus if passed start
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
            position: BoardConfig
                .shopPosition, // Go to shop/kıraathane instead of jail
            turnsToSkip: GameConstants.jailTurns,
          );
          state = state.copyWith(players: temp);
          _addLog(
            "⛔ ${player.name} kütüphane nöbetine yollandı!",
            type: 'error',
          );
          break;

        case CardEffectType.globalMoney:
          // Collect from or pay to all other players
          List<Player> updatedPlayers = List.from(state.players);
          final currentIdx = state.currentPlayerIndex;
          int totalTransfer = 0;

          for (int i = 0; i < updatedPlayers.length; i++) {
            if (i != currentIdx) {
              if (card.value > 0) {
                // Current player receives from others
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
                // Current player pays to others
                int amount = -card.value;
                updatedPlayers[i] = updatedPlayers[i].copyWith(
                  stars: updatedPlayers[i].stars + amount,
                );
                totalTransfer += amount;
              }
            }
          }

          // Update current player
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

    // Find winner based on EHİL status or most stars
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
      // Check for re-roll on doubles (if not in jail/penalty)
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

      // In RPG mode, bankruptcy is not a thing.
      // Players continue playing until win condition is met.

      await Future.delayed(
        Duration(milliseconds: GameConstants.turnChangeDelay),
      );
      int next = (state.currentPlayerIndex + 1) % state.players.length;

      // Switch to next player
      final nextPlayer = state.players[next];

      // Check if next player is in penalty
      bool isSkipped = false;
      List<Player> updatedPlayers = List.from(state.players);

      if (nextPlayer.turnsToSkip > 0) {
        isSkipped = true;
        // Decrement penalty
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
        showTurnSkippedDialog: isSkipped, // Show dialog if skipped
      );

      if (isSkipped) {
        _addLog("${nextPlayer.name} cezalı! Tur atlanıyor.", type: 'error');
        // Turn will be auto-ended when dialog is closed
      } else {
        _addLog("Sıra ${state.players[next].name} oyuncusunda.", type: 'turn');
      }
    } finally {
      _isProcessing = false;
    }
  }

  void closeTurnSkippedDialog() {
    state = state.copyWith(showTurnSkippedDialog: false);
    endTurn(); // Loop to next player
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

  /// Open the shop dialog (called when landing on Kıraathane or manually)
  void openShopDialog() {
    state = state.copyWith(showShopDialog: true);
    _addLog('Kıraathane\'ye hoş geldiniz!', type: 'info');
  }

  /// Close the shop dialog
  void closeShopDialog() {
    state = state.copyWith(showShopDialog: false);
    endTurn();
  }

  /// Purchase a quote with stars
  void purchaseQuote(String quoteId, int cost) {
    final player = state.currentPlayer;

    // Check if already owned
    if (player.collectedQuotes.contains(quoteId)) {
      _addLog('Bu söz zaten koleksiyonunda!', type: 'error');
      return;
    }

    // Check if enough stars
    if (player.stars < cost) {
      _addLog('Yeterli yıldızın yok!', type: 'error');
      return;
    }

    // Deduct stars and add to collectedQuotes
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

    // Check win condition after purchase
    _checkWinCondition();
  }

  /// Check if current player has won (Ehil)
  ///
  /// Win Condition: 50 quotes collected AND Master in all 6 categories
  void _checkWinCondition() {
    final player = state.currentPlayer;

    // Check if Master in all categories and has 50+ quotes
    if (player.hasWon()) {
      // Update title and trigger victory
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

  /// Handle Kıraathane tile landing - opens shop
  ///
  /// Shop allows players to purchase quotes with their stars
  void handleKiraathaneLanding() {
    openShopDialog();
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
