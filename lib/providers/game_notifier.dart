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
import '../core/constants/game_constants.dart';

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
  final bool isDiceRolling; // True while dice animation is playing
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
  final bool showTurnOrderDialog; // Turn order result dialog
  final bool isDoubleTurn; // Indicates if current turn is a double roll bonus

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
    this.isDiceRolling = false,
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
    this.showTurnOrderDialog = false,
    this.isDoubleTurn = false,
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
    bool? isDiceRolling,
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
    bool? showTurnOrderDialog,
    bool? isDoubleTurn,
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
      isDiceRolling: isDiceRolling ?? this.isDiceRolling,
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
      showTurnOrderDialog: showTurnOrderDialog ?? this.showTurnOrderDialog,
      isDoubleTurn: isDoubleTurn ?? this.isDoubleTurn,
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

  // Bot mode variables
  bool _isBotPlaying = false;
  bool get isBotPlaying => _isBotPlaying;
  Timer? _botWatchdog;

  // Cached questions for the session
  List<Question> _cachedQuestions = [];

  GameNotifier() : super(GameState(players: []));

  bool get isProcessing => _isProcessing;

  // ═══════════════════════════════════════════════════════════════════════════
  // VERBOSE BOT LOGGING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Helper method for verbose bot logging with timestamp
  void _logBot(String message) {
    if (!_isBotPlaying) return;
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    debugPrint('[BOT 🤖] $timestamp - $message');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WATCHDOG TIMER (Anti-Freeze Protection)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Start or restart the watchdog timer
  void _startWatchdog() {
    if (!_isBotPlaying) return;

    // Cancel existing watchdog
    _botWatchdog?.cancel();

    // Start new watchdog with 4 second timeout
    _botWatchdog = Timer(const Duration(seconds: 4), () {
      if (_isBotPlaying) {
        _logBot('🚨 WATCHDOG: Bot stuck! Forcing recovery...');
        debugPrint('[BOT 🤖] WATCHDOG TRIGGERED - Current state:');
        debugPrint('  - _isProcessing: $_isProcessing');
        debugPrint('  - isDiceRolling: ${state.isDiceRolling}');
        debugPrint('  - showQuestionDialog: ${state.showQuestionDialog}');
        debugPrint('  - showCardDialog: ${state.showCardDialog}');
        debugPrint(
          '  - showLibraryPenaltyDialog: ${state.showLibraryPenaltyDialog}',
        );
        debugPrint('  - showImzaGunuDialog: ${state.showImzaGunuDialog}');
        debugPrint('  - showShopDialog: ${state.showShopDialog}');
        debugPrint('  - showTurnOrderDialog: ${state.showTurnOrderDialog}');
        debugPrint('  - phase: ${state.phase}');
        debugPrint('  - currentPlayer: ${state.currentPlayer.name}');

        // Force reset processing flag
        _isProcessing = false;

        // Try to recover by forcing next action
        if (state.showQuestionDialog) {
          _logBot('Watchdog: Closing stuck question dialog');
          answerQuestion(_random.nextBool());
        } else if (state.showCardDialog) {
          _logBot('Watchdog: Closing stuck card dialog');
          closeCardDialog();
        } else if (state.showLibraryPenaltyDialog) {
          _logBot('Watchdog: Closing stuck library dialog');
          closeLibraryPenaltyDialog();
        } else if (state.showImzaGunuDialog) {
          _logBot('Watchdog: Closing stuck imza günü dialog');
          closeImzaGunuDialog();
        } else if (state.showShopDialog) {
          _logBot('Watchdog: Closing stuck shop dialog');
          closeShopDialog();
        } else if (state.showTurnOrderDialog) {
          _logBot('Watchdog: Closing stuck turn order dialog');
          closeTurnOrderDialog();
          _scheduleBotTurn();
        } else if (state.showTurnSkippedDialog) {
          _logBot('Watchdog: Closing stuck turn skipped dialog');
          closeTurnSkippedDialog();
        } else {
          // No dialog open, try to roll dice or end turn
          _logBot('Watchdog: No dialog detected, attempting rollDice()');
          rollDice();
        }
      }
    });

    _logBot('Watchdog started (4s timeout)');
  }

  /// Cancel the watchdog timer
  void _cancelWatchdog() {
    _botWatchdog?.cancel();
    _botWatchdog = null;
    _logBot('Watchdog cancelled');
  }

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
    _logBot(
      'rollDice() START - ${_isProcessing ? "BLOCKED (processing)" : "OK"}',
    );

    if (_isProcessing || state.isDiceRolling) {
      _logBot(
        'rollDice() BLOCKED - isProcessing: $_isProcessing, isDiceRolling: ${state.isDiceRolling}',
      );
      return;
    }

    _isProcessing = true;
    _startWatchdog(); // Start watchdog for this operation

    try {
      // Block roll if dialogs are open
      if (state.showQuestionDialog ||
          state.showCardDialog ||
          state.showLibraryPenaltyDialog) {
        _logBot('rollDice() BLOCKED - Dialog open');
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

      // Start dice rolling animation
      state = state.copyWith(isDiceRolling: true);
      _logBot('Dice rolling started...');

      // Wait for animation duration (2 seconds, faster in bot mode)
      final diceDelay = _isBotPlaying
          ? const Duration(milliseconds: 500)
          : const Duration(seconds: 2);
      await Future.delayed(diceDelay);

      // Generate two independent dice
      int d1 = _random.nextInt(6) + 1;
      int d2 = _random.nextInt(6) + 1;
      int roll = d1 + d2;
      bool isDouble = d1 == d2;

      _logBot('Dice rolled: $d1 + $d2 = $roll (Double: $isDouble)');

      // Stop rolling animation and show results
      state = state.copyWith(isDiceRolling: false);

      // Handle based on game phase
      if (state.phase == GamePhase.rollingForOrder) {
        _logBot('Phase: rollingForOrder');
        await _handleTurnOrderRoll(d1, d2, roll);
      } else {
        _logBot('Phase: playerTurn');
        await _handleMovementRoll(d1, d2, roll, isDouble);
      }
      _logBot('rollDice() COMPLETED successfully');
    } catch (e, stackTrace) {
      // SAFETY: Catch any error and log it
      debugPrint('🚨 ERROR in rollDice: $e');
      debugPrint('Stack trace: $stackTrace');
      _addLog('Hata oluştu: $e', type: 'error');
      _logBot('🚨 ERROR in rollDice: $e');
      // Try to recover
      _scheduleBotTurn();
    } finally {
      // SAFETY: Always reset processing flag to prevent freezing
      _isProcessing = false;
      _logBot('rollDice() finally - _isProcessing reset to false');
    }
  }

  /// Handle turn order roll - store roll, show result, advance to next player
  Future<void> _handleTurnOrderRoll(int d1, int d2, int roll) async {
    _logBot('_handleTurnOrderRoll() START');
    try {
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

      // Show result for 3 seconds (shorter in bot mode)
      final delay = _isBotPlaying
          ? const Duration(milliseconds: 500)
          : const Duration(seconds: 3);
      await Future.delayed(delay);

      // Check if everyone has rolled
      if (updatedOrderRolls.length >= state.players.length) {
        _logBot('All players rolled, finalizing turn order');
        // All players have rolled - determine turn order
        _finalizeTurnOrder(updatedOrderRolls);
      } else {
        _logBot('Moving to next player for turn order roll');
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
      _logBot('_handleTurnOrderRoll() COMPLETED');
    } catch (e, stackTrace) {
      debugPrint('🚨 ERROR in _handleTurnOrderRoll: $e');
      debugPrint('Stack trace: $stackTrace');
      _addLog('Sıra belirleme hatası: $e', type: 'error');
      _logBot('🚨 ERROR in _handleTurnOrderRoll: $e');
      _scheduleBotTurn();
    } finally {
      // SAFETY: Always reset processing flag to prevent freezing
      _isProcessing = false;
      _logBot('_handleTurnOrderRoll() finally - _isProcessing reset to false');
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
      showTurnOrderDialog: true,
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

  /// Close turn order dialog and start the game
  void closeTurnOrderDialog() {
    state = state.copyWith(showTurnOrderDialog: false);
  }

  /// Handle normal movement roll with strict double logic
  Future<void> _handleMovementRoll(
    int d1,
    int d2,
    int roll,
    bool isDouble,
  ) async {
    _logBot('_handleMovementRoll() START - roll: $roll, isDouble: $isDouble');
    try {
      // 1. Calculate consecutive doubles
      int newConsecutive = isDouble ? state.consecutiveDoubles + 1 : 0;
      _logBot('Consecutive doubles: $newConsecutive');

      // CASE A: 3rd Consecutive Double -> Jail
      if (newConsecutive >= 3) {
        _logBot('CASE A: 3rd consecutive double -> Jail');
        _addLog(
          "🚨 3. Kez Çift! Kütüphaneye (Hapse) gidiyorsun.",
          type: 'error',
        );

        // Move player to jail immediately
        List<Player> temp = List.from(state.players);
        temp[state.currentPlayerIndex] = state.currentPlayer.copyWith(
          position: GameConstants.jailPosition,
          turnsToSkip: GameConstants.jailTurns,
        );

        state = state.copyWith(
          players: temp,
          dice1: d1,
          dice2: d2,
          diceTotal: roll,
          isDiceRolled: true,
          consecutiveDoubles: 0, // Reset
        );

        // Wait for animation then pass turn to next player
        final delay = _isBotPlaying
            ? const Duration(milliseconds: 300)
            : const Duration(milliseconds: 1500);
        await Future.delayed(delay);
        _isProcessing = false; // Reset before calling endTurn() to prevent blocking
        endTurn();
        return;
      }

      // CASE B: Double Roll (1st or 2nd)
      if (isDouble) {
        _logBot('CASE B: Double roll (1st or 2nd)');
        _addLog(
          "🎲 Çift Attın ($newConsecutive. Kez)! Tekrar oyna.",
          type: 'dice',
        );

        // Update state with dice results and consecutive count
        state = state.copyWith(
          dice1: d1,
          dice2: d2,
          diceTotal: roll,
          isDiceRolled: true,
          consecutiveDoubles: newConsecutive,
        );

        // Move player
        final delay = _isBotPlaying
            ? const Duration(milliseconds: 300)
            : const Duration(milliseconds: 1500);
        await Future.delayed(delay);
        await _movePlayer(roll);

        // After movement, set up for re-roll (same player)
        state = state.copyWith(isDiceRolled: false, isDoubleTurn: true);
        _logBot('CASE B: Completed, ready for re-roll');
        return;
      }

      // CASE C: Normal Roll (Not Double)
      _logBot('CASE C: Normal roll');
      _addLog(
        "${state.currentPlayer.name} $roll ($d1-$d2) attı. Sıra geçiyor.",
        type: 'dice',
      );

      // Update state
      state = state.copyWith(
        dice1: d1,
        dice2: d2,
        diceTotal: roll,
        isDiceRolled: true,
        consecutiveDoubles: 0, // Reset
      );

      // Move player
      final delay = _isBotPlaying
          ? const Duration(milliseconds: 300)
          : const Duration(milliseconds: 1500);
      await Future.delayed(delay);
      await _movePlayer(roll);

      // After movement, pass turn to next player
      _logBot('_handleMovementRoll() COMPLETED - calling endTurn()');
      _isProcessing = false; // Reset before calling endTurn() to prevent blocking
      endTurn();
    } catch (e, stackTrace) {
      debugPrint('🚨 ERROR in _handleMovementRoll: $e');
      debugPrint('Stack trace: $stackTrace');
      _addLog('Hareket hatası: $e', type: 'error');
      _logBot('🚨 ERROR in _handleMovementRoll: $e');
      // Ensure turn ends even on error
      endTurn();
    } finally {
      // SAFETY: Always reset processing flag to prevent freezing
      _isProcessing = false;
      _logBot('_handleMovementRoll() finally - _isProcessing reset to false');
    }
  }

  /// Move player step-by-step with hopping animation
  Future<void> _movePlayer(int steps) async {
    _logBot('_movePlayer() START - steps: $steps');
    try {
      var player = state.currentPlayer;
      _logBot(
        'Current position: ${player.position}, target: ${(player.position + steps) % BoardConfig.boardSize}',
      );

      if (player.inJail) {
        _logBot('Player is in jail');
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

        // Wait for hop animation (faster in bot mode)
        final hopDelay = _isBotPlaying ? 50 : GameConstants.hopAnimationDelay;
        await Future.delayed(Duration(milliseconds: hopDelay));
      }

      final tile = state.tiles[currentPos];

      state = state.copyWith(currentTile: tile);
      _addLog("${tile.name} karesine gelindi.");
      _logBot('Landed on tile: ${tile.name} (type: ${tile.type})');

      _handleTileArrival(tile);
    } catch (e, stackTrace) {
      debugPrint('🚨 ERROR in _movePlayer: $e');
      debugPrint('Stack trace: $stackTrace');
      _addLog('Hareket hatası: $e', type: 'error');
      _logBot('🚨 ERROR in _movePlayer: $e');
      endTurn();
    }
  }

  void _handleTileArrival(BoardTile tile) {
    _logBot('_handleTileArrival() - Tile: ${tile.name}, Type: ${tile.type}');
    switch (tile.type) {
      case TileType.category:
        _logBot('Tile type: CATEGORY');
        if (tile.category != null) {
          _triggerQuestion(tile);
        } else {
          endTurn();
        }
        break;
      case TileType.start:
        _logBot('Tile type: START');
        // Start tile - award salary and end turn
        _handleStartTileLanding();
        break;
      case TileType.shop:
        _logBot('Tile type: SHOP');
        // Kıraathane - Open shop
        handleKiraathaneLanding();
        break;
      case TileType.library:
        _logBot('Tile type: LIBRARY');
        // Kütüphane - Apply 2-turn penalty
        _handleLibraryLanding();
        break;
      case TileType.signingDay:
        _logBot('Tile type: SIGNING_DAY');
        // İmza Günü - Show dialog, no penalty
        _handleSigningDayLanding();
        break;
      case TileType.corner:
        _logBot('Tile type: CORNER');
        // Generic corners - end turn
        endTurn();
        break;
      case TileType.collection:
        _logBot('Tile type: COLLECTION');
        // Generic corners - end turn
        endTurn();
        break;
    }
  }

  /// Handle Start tile landing - award salary and auto-end turn
  void _handleStartTileLanding() async {
    final player = state.currentPlayer;
    const salaryAmount = 20; // Stars awarded for landing on start

    // Award salary
    List<Player> newPlayers = List.from(state.players);
    newPlayers[state.currentPlayerIndex] = player.copyWith(
      stars: player.stars + salaryAmount,
    );
    state = state.copyWith(players: newPlayers);

    _addLog(
      "🏁 ${player.name} Başlangıç'tan geçti! +$salaryAmount Yıldız kazandı!",
      type: 'success',
    );

    // Wait to show the message, then end turn (faster in bot mode)
    final delay = _isBotPlaying
        ? const Duration(milliseconds: 300)
        : const Duration(milliseconds: 1500);
    await Future.delayed(delay);
    endTurn();
  }

  /// Handle Kütüphane (Library) landing - Apply 2-turn penalty
  void _handleLibraryLanding() {
    final player = state.currentPlayer;
    const libraryPenaltyTurns = 2;

    List<Player> newPlayers = List.from(state.players);
    newPlayers[state.currentPlayerIndex] = player.copyWith(
      turnsToSkip: libraryPenaltyTurns,
    );

    // BOT MODE: Auto-close dialog after short delay
    if (_isBotPlaying) {
      state = state.copyWith(players: newPlayers);
      _addLog(
        "🤖 Bot: 📚 ${player.name} Kütüphanede! $libraryPenaltyTurns tur ceza.",
        type: 'error',
      );
      Future.delayed(const Duration(milliseconds: 300), () {
        closeLibraryPenaltyDialog();
      });
      return;
    }

    state = state.copyWith(players: newPlayers, showLibraryPenaltyDialog: true);

    _addLog(
      "📚 ${player.name} Kütüphanede! Sessizlik lazım, $libraryPenaltyTurns tur bekle.",
      type: 'error',
    );
  }

  /// Handle İmza Günü (Signing Day) landing - Show dialog, no penalty
  void _handleSigningDayLanding() {
    final player = state.currentPlayer;

    // BOT MODE: Auto-close dialog after short delay
    if (_isBotPlaying) {
      _addLog(
        "🤖 Bot: ✍️ ${player.name} İmza Günü'nde okurlarıyla buluştu!",
        type: 'success',
      );
      Future.delayed(const Duration(milliseconds: 300), () {
        closeImzaGunuDialog();
      });
      return;
    }

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

    Question? selectedQuestion;
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
      selectedQuestion =
          categoryQuestions[_random.nextInt(categoryQuestions.length)];
      _addLog(
        '⚠ $difficultyFilter zorlu soru bulunamadı, rastgele soru seçildi.',
        type: 'info',
      );
    } else {
      selectedQuestion =
          filteredQuestions[_random.nextInt(filteredQuestions.length)];
    }

    // BOT MODE: Auto-answer question without showing dialog
    if (_isBotPlaying) {
      _addLog('🤖 Bot: Soru cevaplandı (${selectedQuestion.category.name})');
      // Bot has 50% chance to answer correctly
      final isCorrect = _random.nextBool();
      _botAnswerQuestion(selectedQuestion, isCorrect);
      return;
    }

    // Normal mode: Show question dialog
    state = state.copyWith(
      showQuestionDialog: true,
      currentQuestion: selectedQuestion,
      currentTile: tile,
    );
  }

  /// Bot auto-answers a question
  void _botAnswerQuestion(Question question, bool isCorrect) async {
    try {
      final tile = state.currentTile;
      final categoryName = tile?.category;
      final difficulty = tile?.difficulty ?? Difficulty.medium;

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
          newMastery = MasteryLevel.cirak;
          promotionReward = GameConstants.promotionBaseReward * 1;
          promotionMessage =
              '🏆 ${_getCategoryDisplayName(categoryName)} kategorisinde Çırak oldun!';
        } else if (currentMastery == MasteryLevel.cirak &&
            difficulty == Difficulty.medium &&
            newAnswerCount >= GameConstants.answersRequiredForPromotion) {
          newMastery = MasteryLevel.kalfa;
          promotionReward = GameConstants.promotionBaseReward * 2;
          promotionMessage =
              '🏆 ${_getCategoryDisplayName(categoryName)} kategorisinde Kalfa oldun!';
        } else if (currentMastery == MasteryLevel.kalfa &&
            difficulty == Difficulty.hard &&
            newAnswerCount >= GameConstants.answersRequiredForPromotion) {
          newMastery = MasteryLevel.usta;
          promotionReward = GameConstants.promotionBaseReward * 3;
          promotionMessage =
              '🏆 ${_getCategoryDisplayName(categoryName)} kategorisinde Usta oldun!';
        }

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

        _addLog(
          '🤖 Bot: Doğru cevap! +$baseStars ⭐ ($difficultyName)',
          type: 'success',
        );

        if (promotionMessage.isNotEmpty) {
          _addLog(
            '🤖 Bot: $promotionMessage (+$promotionReward ⭐ bonus)',
            type: 'success',
          );
        }

        _checkWinCondition();
      } else if (!isCorrect) {
        _addLog("🤖 Bot: Yanlış cevap. Yıldız kazanamadın.", type: 'error');
      }

      // Wait a short delay then end turn
      await Future.delayed(const Duration(milliseconds: 500));
      endTurn();
    } catch (e, stackTrace) {
      debugPrint('🚨 ERROR in _botAnswerQuestion: $e');
      debugPrint('Stack trace: $stackTrace');
      endTurn();
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

  /// Draw a card from Şans or Kader deck
  /// Note: Currently unused - cards are handled through other mechanisms
  // ignore: unused_element
  void _drawCard(CardType cardType) async {
    await Future.delayed(
      Duration(
        milliseconds: _isBotPlaying ? 100 : GameConstants.cardAnimationDelay,
      ),
    );
    List<GameCard> deck = cardType == CardType.sans
        ? GameCards.sansCards
        : GameCards.kaderCards;
    GameCard card = deck[_random.nextInt(deck.length)];

    // BOT MODE: Auto-apply card effect without showing dialog
    if (_isBotPlaying) {
      _addLog('🤖 Bot: Kart çekildi (${cardType.name})');
      _botApplyCardEffect(card);
      return;
    }

    state = state.copyWith(showCardDialog: true, currentCard: card);
  }

  /// Bot auto-applies a card effect
  void _botApplyCardEffect(GameCard card) async {
    try {
      final player = state.currentPlayer;

      switch (card.effectType) {
        case CardEffectType.moneyChange:
          final newStars = player.stars + card.value;
          _updateStars(player, newStars);
          if (card.value > 0) {
            _addLog(
              "🤖 Bot: 💰 ${player.name} +${card.value} yıldız kazandı!",
              type: 'success',
            );
          } else {
            _addLog(
              "🤖 Bot: 💸 ${player.name} ${card.value} yıldız kaybetti!",
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
              "🤖 Bot: 🏁 Başlangıçtan geçtin: +${GameConstants.passingStartBonus} Yıldız!",
              type: 'success',
            );
          }

          newPlayers[state.currentPlayerIndex] = player.copyWith(
            position: targetPos,
            stars: newStars,
          );
          state = state.copyWith(players: newPlayers);
          _addLog("🤖 Bot: 🎯 ${player.name} $targetPos. kareye taşındı!");
          break;

        case CardEffectType.jail:
          List<Player> temp = List.from(state.players);
          temp[state.currentPlayerIndex] = player.copyWith(
            position: BoardConfig.shopPosition,
            turnsToSkip: GameConstants.jailTurns,
          );
          state = state.copyWith(players: temp);
          _addLog(
            "🤖 Bot: ⛔ ${player.name} kütüphane nöbetine yollandı!",
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
              "🤖 Bot: 🏆 ${player.name} herkesten toplam $totalTransfer ⭐ aldı!",
              type: 'success',
            );
          } else {
            _addLog(
              "🤖 Bot: 💸 ${player.name} herkese toplam $totalTransfer ⭐ ödedi!",
              type: 'error',
            );
          }
          break;
      }

      // Wait a short delay then end turn
      await Future.delayed(const Duration(milliseconds: 500));
      endTurn();
    } catch (e, stackTrace) {
      debugPrint('🚨 ERROR in _botApplyCardEffect: $e');
      debugPrint('Stack trace: $stackTrace');
      endTurn();
    }
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
    _logBot('endTurn() START - currentPlayer: ${state.currentPlayer.name}');
    if (_isProcessing || state.phase == GamePhase.gameOver) {
      _logBot(
        'endTurn() BLOCKED - isProcessing: $_isProcessing, phase: ${state.phase}',
      );
      return;
    }

    _isProcessing = true;
    _startWatchdog(); // Restart watchdog for turn change

    try {
      // Always pass turn to next player
      final delay = _isBotPlaying
          ? const Duration(milliseconds: 200)
          : Duration(milliseconds: GameConstants.turnChangeDelay);
      await Future.delayed(delay);
      int next = (state.currentPlayerIndex + 1) % state.players.length;

      final nextPlayer = state.players[next];
      _logBot('Passing turn to: ${nextPlayer.name} (index: $next)');

      bool isSkipped = false;
      List<Player> updatedPlayers = List.from(state.players);

      if (nextPlayer.turnsToSkip > 0) {
        isSkipped = true;
        updatedPlayers[next] = nextPlayer.copyWith(
          turnsToSkip: nextPlayer.turnsToSkip - 1,
        );
        _logBot('Next player has turnsToSkip: ${nextPlayer.turnsToSkip}');
      }

      state = state.copyWith(
        players: updatedPlayers,
        currentPlayerIndex: next,
        isDiceRolled: false,
        isDoubleTurn: false,
        consecutiveDoubles: 0, // Reset
        showQuestionDialog: false,
        showCardDialog: false,
        showTurnSkippedDialog: isSkipped,
      );

      if (isSkipped) {
        _addLog("${nextPlayer.name} cezalı! Tur atlanıyor.", type: 'error');
      } else {
        _addLog("Sıra ${state.players[next].name} oyuncusunda.", type: 'turn');
      }

      _logBot(
        'endTurn() COMPLETED - next: ${nextPlayer.name}, skipped: $isSkipped',
      );

      // BOT MODE: Trigger next turn automatically
      if (_isBotPlaying && !isSkipped) {
        _scheduleBotTurn();
      }
    } catch (e, stackTrace) {
      debugPrint('🚨 ERROR in endTurn: $e');
      debugPrint('Stack trace: $stackTrace');
      _logBot('🚨 ERROR in endTurn: $e');
      _scheduleBotTurn();
    } finally {
      _isProcessing = false;
      _logBot('endTurn() finally - _isProcessing reset to false');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BOT MODE METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Toggle bot mode on/off
  void toggleBotMode() {
    _isBotPlaying = !_isBotPlaying;
    if (_isBotPlaying) {
      _addLog('🤖 Bot Modu AKTİF! Oyun otomatik oynanıyor...', type: 'info');
      _logBot('=== BOT MODE ACTIVATED ===');
      // Start the bot game loop
      _scheduleBotTurn();
    } else {
      _addLog('🤖 Bot Modu KAPALI. Manuel oynamaya dönüldü.', type: 'info');
      _logBot('=== BOT MODE DEACTIVATED ===');
      _cancelWatchdog();
    }
  }

  /// Schedule the bot's next turn with a small delay
  void _scheduleBotTurn() {
    _logBot('_scheduleBotTurn() called');
    if (!_isBotPlaying || state.phase == GamePhase.gameOver) {
      _logBot(
        '_scheduleBotTurn() ABORTED - bot: $_isBotPlaying, phase: ${state.phase}',
      );
      return;
    }

    _startWatchdog(); // Start watchdog before scheduling

    // Use a microtask to avoid blocking and allow UI updates
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_isBotPlaying && state.phase != GamePhase.gameOver) {
        _logBot('_scheduleBotTurn() executing check...');
        // Check if any dialogs are open
        if (!state.showQuestionDialog &&
            !state.showCardDialog &&
            !state.showLibraryPenaltyDialog &&
            !state.showImzaGunuDialog &&
            !state.showShopDialog &&
            !state.showTurnOrderDialog &&
            !state.isDiceRolling &&
            !_isProcessing) {
          _logBot('No dialogs/blockers, calling rollDice()');
          rollDice();
        } else if (_isBotPlaying) {
          _logBot('Dialogs/blockers detected, handling them');
          // If a dialog is open, close it automatically
          _handleBotDialog();
        }
      }
    });
  }

  /// Handle dialogs in bot mode - auto-close them
  void _handleBotDialog() async {
    if (!_isBotPlaying) return;

    _logBot('_handleBotDialog() - checking dialogs...');
    await Future.delayed(const Duration(milliseconds: 500));

    if (state.showTurnOrderDialog) {
      _logBot('Closing TurnOrderDialog');
      closeTurnOrderDialog();
      _scheduleBotTurn();
    } else if (state.showLibraryPenaltyDialog) {
      _logBot('Closing LibraryPenaltyDialog');
      closeLibraryPenaltyDialog();
    } else if (state.showImzaGunuDialog) {
      _logBot('Closing ImzaGunuDialog');
      closeImzaGunuDialog();
    } else if (state.showTurnSkippedDialog) {
      _logBot('Closing TurnSkippedDialog');
      closeTurnSkippedDialog();
    } else if (state.showShopDialog) {
      _logBot('Closing ShopDialog');
      // Bot doesn't buy quotes, just close the shop
      closeShopDialog();
    } else if (state.showQuestionDialog) {
      _logBot('Closing QuestionDialog with random answer');
      answerQuestion(_random.nextBool());
    } else if (state.showCardDialog) {
      _logBot('Closing CardDialog');
      closeCardDialog();
    } else {
      _logBot(
        'No dialog found, but _isProcessing or isDiceRolling may be stuck',
      );
      // Force reset if stuck
      if (_isProcessing || state.isDiceRolling) {
        _logBot('Forcing reset of _isProcessing and isDiceRolling');
        _isProcessing = false;
        state = state.copyWith(isDiceRolling: false);
        _scheduleBotTurn();
      }
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

  /// DEBUG: Instantly trigger win for current player
  /// Sets all 6 categories to Hard (Usta) and gives 50 dummy quotes
  void debugTriggerWin() {
    final player = state.currentPlayer;

    debugPrint('🏆 DEBUG: Triggering Instant Win for ${player.name}');

    // Create mastery map with all categories set to Hard (Usta)
    final masteryLevels = <String, int>{
      'turkEdebiyatindaIlkler': MasteryLevel.usta.value,
      'edebiSanatlar': MasteryLevel.usta.value,
      'eserKarakter': MasteryLevel.usta.value,
      'edebiyatAkimlari': MasteryLevel.usta.value,
      'benKimim': MasteryLevel.usta.value,
      'tesvik': MasteryLevel.usta.value,
    };

    // Create category progress map with Hard difficulty set
    final categoryProgress = <String, Map<String, int>>{
      'turkEdebiyatindaIlkler': {'hard': 3},
      'edebiSanatlar': {'hard': 3},
      'eserKarakter': {'hard': 3},
      'edebiyatAkimlari': {'hard': 3},
      'benKimim': {'hard': 3},
      'tesvik': {'hard': 3},
    };

    // Create 50 dummy quote IDs
    final dummyQuoteIds = List<String>.generate(50, (i) => 'debug_quote_$i');

    // Update player with all win conditions met
    List<Player> newPlayers = List.from(state.players);
    newPlayers[state.currentPlayerIndex] = player.copyWith(
      mainTitle: 'Ehil',
      categoryLevels: masteryLevels,
      categoryProgress: categoryProgress,
      collectedQuotes: dummyQuoteIds,
    );

    // Update state with winner and game over
    state = state.copyWith(
      players: newPlayers,
      winner: newPlayers[state.currentPlayerIndex],
      phase: GamePhase.gameOver,
    );

    _addLog(
      '🏆 DEBUG: ${player.name} EHİL oldu! (Instant Win Triggered)',
      type: 'gameover',
    );
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
    _cancelWatchdog();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>(
  (ref) => GameNotifier(),
);
