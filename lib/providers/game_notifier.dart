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
import '../core/managers/audio_manager.dart';

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

  // Pause State
  final bool isGamePaused;

  final bool isDoubleTurn; // Indicates if current turn is a double roll bonus

  final BoardTile? currentTile;
  final GameCard? currentCard;
  final Player? winner;
  final String? setupMessage;

  // Turn Order Determination - stores dice rolls for each player
  final Map<String, int> orderRolls;

  // Tie-Breaker State
  /// Groups players by their dice roll value (roll value -> list of player IDs)
  final Map<int, List<String>> tieBreakerGroups;

  /// Players with confirmed final positions (unique rolls)
  final List<Player> finalizedOrder;

  /// Players currently in tie-breaker round (need to roll again)
  final List<Player> pendingTieBreakPlayers;

  /// Current tie-breaker round number
  final int tieBreakRound;

  /// Temporary rolls for the CURRENT tie-breaker round only (player ID -> roll value)
  /// Cleared at the start of each new tie-breaker round
  final Map<String, int> tieBreakRoundRolls;

  /// Track IDs of questions that have already been asked (to prevent repetition)
  final Set<String> askedQuestionIds;

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
    this.tieBreakerGroups = const {},
    this.finalizedOrder = const [],
    this.pendingTieBreakPlayers = const [],
    this.tieBreakRound = 0,
    this.tieBreakRoundRolls = const {},
    this.askedQuestionIds = const {},
    this.isGamePaused = false,
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
    Map<int, List<String>>? tieBreakerGroups,
    List<Player>? finalizedOrder,
    List<Player>? pendingTieBreakPlayers,
    int? tieBreakRound,
    Map<String, int>? tieBreakRoundRolls,
    Set<String>? askedQuestionIds,
    bool? isGamePaused,
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
      tieBreakerGroups: tieBreakerGroups ?? this.tieBreakerGroups,
      finalizedOrder: finalizedOrder ?? this.finalizedOrder,
      pendingTieBreakPlayers:
          pendingTieBreakPlayers ?? this.pendingTieBreakPlayers,
      tieBreakRound: tieBreakRound ?? this.tieBreakRound,
      tieBreakRoundRolls: tieBreakRoundRolls ?? this.tieBreakRoundRolls,
      askedQuestionIds: askedQuestionIds ?? this.askedQuestionIds,
      isGamePaused: isGamePaused ?? this.isGamePaused,
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

  // Completers for waiting for dialogs to close (Async Barrier)
  Completer<void>? _cardDialogCompleter;
  Completer<void>? _questionDialogCompleter;
  Completer<void>? _libraryPenaltyDialogCompleter;
  Completer<void>? _imzaGunuDialogCompleter;
  Completer<void>? _shopDialogCompleter;

  // Dialog lock flag - prevents turn actions while dialog is open
  bool get _isDialogOpen =>
      state.showQuestionDialog ||
      state.showCardDialog ||
      state.showLibraryPenaltyDialog ||
      state.showImzaGunuDialog ||
      state.showShopDialog ||
      state.showTurnOrderDialog ||
      state.showTurnSkippedDialog;

  GameNotifier() : super(GameState(players: []));

  bool get isProcessing => _isProcessing;

  /// Exposes processing state for UI lock during automated turn order
  bool get isTurnOrderProcessing =>
      _isProcessing &&
      (state.phase == GamePhase.rollingForOrder ||
          state.phase == GamePhase.tieBreaker);

  // ═══════════════════════════════════════════════════════════════════════════
  // PAUSE MECHANISM
  // ═══════════════════════════════════════════════════════════════════════════

  /// Pause the game logic
  void pauseGame() {
    state = state.copyWith(isGamePaused: true);
    _logBot('Game PAUSED');
  }

  /// Resume the game logic
  void resumeGame() {
    state = state.copyWith(isGamePaused: false);
    _logBot('Game RESUMED');
  }

  /// Async guard to halt execution while paused
  Future<void> _checkPauseStatus() async {
    if (!state.isGamePaused) return;

    _logBot('Execution halted (Paused)...');
    while (state.isGamePaused) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    _logBot('Execution resumed');
  }

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

    // SANITIZE: Ensure unique IDs to prevent logic/UI collisions
    final List<Player> uniquePlayers = [];
    final Set<String> existingIds = {};

    for (var i = 0; i < players.length; i++) {
      var p = players[i];
      // If ID is missing or duplicate, generate a robust unique ID
      if (p.id.isEmpty || existingIds.contains(p.id)) {
        final newId = 'player_${i}_${DateTime.now().millisecondsSinceEpoch}';
        p = p.copyWith(id: newId);
      }
      existingIds.add(p.id);
      uniquePlayers.add(p);
    }

    // Load questions from repository
    _cachedQuestions = await QuestionRepositoryImpl().getAllQuestions();

    state = GameState(
      players: uniquePlayers,
      tiles: BoardConfig.tiles,
      phase: GamePhase.rollingForOrder,
      lastAction: 'Sıra belirlemek için zar atın...',
    );

    _addLog("Oyun başlatıldı! ${uniquePlayers.length} oyuncu katıldı.");
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TURN ORDER DETERMINATION - Iron-Clad State Machine (v2.0)
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // This is a FULLY AUTOMATED system. No manual dice button presses.
  // Phase 1: All players auto-roll
  // Phase 2: Evaluate & detect ties
  // Phase 3: Recursive tie-break (fully automated)
  //
  // ═══════════════════════════════════════════════════════════════════════════

  /// Start the fully automated turn order determination.
  /// This method handles EVERYTHING - initial rolls, tie detection, and recursive tie-breaks.
  /// No user interaction required until the final order is displayed.
  Future<void> startAutomatedTurnOrder({
    List<Player>? playersToRoll,
    int depth = 0,
  }) async {
    // Prevent re-entry at root level
    if (_isProcessing && depth == 0) {
      _logBot('startAutomatedTurnOrder() BLOCKED - already processing');
      return;
    }
    if (depth == 0) _isProcessing = true;

    try {
      final candidates = playersToRoll ?? state.players;
      final isRootCall = depth == 0;
      final isTieBreak = depth > 0;

      // ═══════════════════════════════════════════════════════════════════════
      // PHASE 1: LOG START & SWITCH TO GAME BGM
      // ═══════════════════════════════════════════════════════════════════════
      if (isRootCall) {
        // Switch to in-game BGM (seamless transition from menu music)
        await AudioManager.instance.playInGameBgm();

        _addLog('🎲 Otomatik sıra belirleme başlıyor...', type: 'dice');
        state = state.copyWith(
          phase: GamePhase.rollingForOrder,
          orderRolls: {},
          lastAction: 'Sıra belirleniyor - Tüm oyuncular zar atıyor...',
        );
      } else {
        final tiedNames = candidates.map((p) => p.name).join(', ');
        _addLog(
          '🔄 Beraberlik! $tiedNames için $depth. tie-break turu...',
          type: 'warning',
        );
        state = state.copyWith(
          phase: GamePhase.tieBreaker,
          tieBreakRound: depth,
          lastAction: '🔄 Tie-break: $tiedNames tekrar atıyor...',
        );
      }

      // ═══════════════════════════════════════════════════════════════════════
      // PHASE 2: AUTO-ROLL ALL CANDIDATES (Sequential with Animation)
      // ═══════════════════════════════════════════════════════════════════════
      final Map<String, int> roundRolls = {}; // Rolls for THIS round only

      for (int i = 0; i < candidates.length; i++) {
        final player = candidates[i];

        // PAUSE GUARD: Wait if game is paused
        await _checkPauseStatus();

        // Highlight current player
        final playerGlobalIndex = state.players.indexOf(player);
        state = state.copyWith(
          currentPlayerIndex: playerGlobalIndex >= 0 ? playerGlobalIndex : 0,
          isDiceRolled: false,
          isDiceRolling: false,
          diceTotal: 0,
          dice1: 0,
          dice2: 0,
        );

        // Pre-roll delay (build anticipation) - shorter in bot mode
        final preDelay = _isBotPlaying
            ? const Duration(milliseconds: 200)
            : const Duration(milliseconds: 600);
        await Future.delayed(preDelay);

        // ═══════════════════════════════════════════════════════════════════
        // ANIMATION: Start dice rolling
        // ═══════════════════════════════════════════════════════════════════
        state = state.copyWith(isDiceRolling: true);
        AudioManager.instance.playSfx('audio/dice_roll.wav');

        // Animation duration - shorter in bot mode
        final animDelay = _isBotPlaying
            ? const Duration(milliseconds: 400)
            : const Duration(milliseconds: 1200);
        await Future.delayed(animDelay);

        // PAUSE GUARD
        await _checkPauseStatus();

        // ═══════════════════════════════════════════════════════════════════
        // ROLL: Generate dice values
        // ═══════════════════════════════════════════════════════════════════
        final int d1 = _random.nextInt(6) + 1;
        final int d2 = _random.nextInt(6) + 1;
        final int roll = d1 + d2;

        // Store roll for this round
        roundRolls[player.id] = roll;

        // Update global orderRolls (for final sorting)
        final updatedGlobalRolls = Map<String, int>.from(state.orderRolls);
        updatedGlobalRolls[player.id] = roll;

        // Update state with results
        state = state.copyWith(
          isDiceRolling: false,
          isDiceRolled: true,
          diceTotal: roll,
          dice1: d1,
          dice2: d2,
          orderRolls: updatedGlobalRolls,
        );

        _addLog(
          '${player.name}: $roll ($d1+$d2)',
          type: isTieBreak ? 'warning' : 'success',
        );

        // Post-roll display delay - shorter in bot mode
        final postDelay = _isBotPlaying
            ? const Duration(milliseconds: 300)
            : const Duration(milliseconds: 800);
        await Future.delayed(postDelay);
      }

      // ═══════════════════════════════════════════════════════════════════════
      // PHASE 3: EVALUATION - Find max roll and detect ties
      // ═══════════════════════════════════════════════════════════════════════
      int maxRoll = 0;
      for (final roll in roundRolls.values) {
        if (roll > maxRoll) maxRoll = roll;
      }

      // Find all players tied for the maximum roll
      final List<Player> tiedForMax = [];
      for (final player in candidates) {
        if ((roundRolls[player.id] ?? 0) == maxRoll) {
          tiedForMax.add(player);
        }
      }

      _logBot(
        'Evaluation: Max roll = $maxRoll, Winners = ${tiedForMax.length} (${tiedForMax.map((p) => p.name).join(", ")})',
      );

      // ═══════════════════════════════════════════════════════════════════════
      // PHASE 4: DECISION - Single winner or recurse for tie-break
      // ═══════════════════════════════════════════════════════════════════════
      if (tiedForMax.length > 1) {
        // CASE B: Multiple winners - RECURSE for tie-break
        _addLog(
          '⚖️ Beraberlik: ${tiedForMax.map((p) => p.name).join(", ")} ($maxRoll)',
          type: 'warning',
        );

        // Brief pause before tie-break
        await Future.delayed(const Duration(milliseconds: 1000));

        // RECURSIVE CALL - only tied players re-roll
        await startAutomatedTurnOrder(
          playersToRoll: tiedForMax,
          depth: depth + 1,
        );
        return; // Exit after recursion completes
      }

      // CASE A: Single winner (or all players unique after root call)
      // Only finalize at root level (depth == 0)
      if (isRootCall) {
        await _finalizeTurnOrderFromRolls(state.orderRolls);
      }
      // For tie-break calls (depth > 0), the winner is now known
      // The root call will handle finalization
    } catch (e, stackTrace) {
      debugPrint('🚨 ERROR in startAutomatedTurnOrder: $e');
      debugPrint('Stack trace: $stackTrace');
      _addLog('Sıra belirleme hatası: $e', type: 'error');
      _logBot('🚨 ERROR in startAutomatedTurnOrder: $e');
    } finally {
      if (depth == 0) {
        _isProcessing = false;
        _logBot('startAutomatedTurnOrder() COMPLETED - processing flag reset');
      }
    }
  }

  /// Finalize turn order from collected rolls.
  /// Sorts all players by their roll values (descending) and transitions to playerTurn phase.
  Future<void> _finalizeTurnOrderFromRolls(Map<String, int> rolls) async {
    _logBot('_finalizeTurnOrderFromRolls() - Finalizing order');

    // Sort players by roll (highest first)
    final sortedPlayers = List<Player>.from(state.players);
    sortedPlayers.sort((a, b) {
      final rollA = rolls[a.id] ?? 0;
      final rollB = rolls[b.id] ?? 0;
      return rollB.compareTo(rollA);
    });

    // Build order summary for log
    final orderSummary = StringBuffer();
    for (int i = 0; i < sortedPlayers.length; i++) {
      final player = sortedPlayers[i];
      final roll = rolls[player.id] ?? 0;
      orderSummary.writeln('  ${i + 1}. ${player.name} ($roll)');
    }

    _addLog('✅ Sıra belirlendi!');
    _addLog(orderSummary.toString());

    // Transition to playerTurn phase
    state = state.copyWith(
      players: sortedPlayers,
      currentPlayerIndex: 0,
      phase: GamePhase.playerTurn,
      isDiceRolled: false,
      isDiceRolling: false,
      diceTotal: 0,
      dice1: 0,
      dice2: 0,
      showTurnOrderDialog: true,
      lastAction: 'Sıra belirlendi! ${sortedPlayers.first.name} başlıyor.',
      // Clear tie-breaker state
      finalizedOrder: [],
      pendingTieBreakPlayers: [],
      tieBreakerGroups: {},
      tieBreakRound: 0,
      tieBreakRoundRolls: {},
    );

    _logBot(
      '_finalizeTurnOrderFromRolls() COMPLETED - First player: ${sortedPlayers.first.name}',
    );
  }

  /// Set turn order based on dice rolls (legacy API - kept for compatibility)
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
  // 2. ZAR ATMA & HAREKET (Dice Rolling & Movement)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Roll dice - handles MOVEMENT rolls during playerTurn phase.
  /// NOTE: Turn order rolls are handled automatically by startAutomatedTurnOrder().
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

    // CRITICAL: Block roll if ANY dialog is open (Async Barrier)
    if (_isDialogOpen) {
      _logBot('rollDice() BLOCKED - Dialog is open (_isDialogOpen=true)');
      return;
    }

    // CRITICAL: Turn order rolls are handled by startAutomatedTurnOrder()
    // Skip manual dice if we're in rollingForOrder or tieBreaker phase
    if (state.phase == GamePhase.rollingForOrder ||
        state.phase == GamePhase.tieBreaker) {
      _logBot(
        'rollDice() BLOCKED - Phase ${state.phase} uses automated rolling',
      );
      return;
    }

    _isProcessing = true;
    _startWatchdog(); // Start watchdog for this operation

    try {
      // Check if player has turns to skip (library penalty) - only in playerTurn phase
      if (state.phase == GamePhase.playerTurn &&
          state.currentPlayer.turnsToSkip > 0) {
        final player = state.currentPlayer;
        final remaining = player.turnsToSkip - 1;

        // Decrement turns to skip (BUG FIX: This is the ONLY place we decrement)
        List<Player> newPlayers = List.from(state.players);
        newPlayers[state.currentPlayerIndex] = player.copyWith(
          turnsToSkip: remaining,
        );
        state = state.copyWith(players: newPlayers);

        if (remaining > 0) {
          _addLog(
            "📚 ${player.name} Kütüphanede! Kalan ceza turu: $remaining",
            type: 'error',
          );
          state = state.copyWith(showTurnSkippedDialog: true);
        } else {
          _addLog(
            "✅ ${player.name} Kütüphane cezasını tamamladı! Sıradaki turda zar atabilir.",
            type: 'success',
          );
        }

        // CRITICAL: End turn immediately, DO NOT allow dice roll
        endTurn();
        return;
      }

      // Start dice rolling animation
      state = state.copyWith(isDiceRolling: true);
      _logBot('Dice rolling started...');
      AudioManager.instance.playSfx('audio/dice_roll.wav');

      // Wait for animation duration (2 seconds, faster in bot mode)
      final diceDelay = _isBotPlaying
          ? const Duration(milliseconds: 500)
          : const Duration(seconds: 2);
      await Future.delayed(diceDelay);
      await _checkPauseStatus(); // PAUSE GUARD

      // Generate two independent dice
      int d1 = _random.nextInt(6) + 1;
      int d2 = _random.nextInt(6) + 1;
      int roll = d1 + d2;
      bool isDouble = d1 == d2;

      _logBot('Dice rolled: $d1 + $d2 = $roll (Double: $isDouble)');

      // Stop rolling animation and show results
      state = state.copyWith(isDiceRolling: false);

      // Handle based on game phase (only playerTurn should reach here now)
      if (state.phase == GamePhase.playerTurn) {
        // Doubles mechanic during movement
        _logBot('Phase: playerTurn - Doubles mechanic ACTIVE');
        await _handleMovementRoll(d1, d2, roll, isDouble);
      } else {
        // Unexpected phase - log and handle safely
        _logBot(
          'WARNING: Unexpected phase ${state.phase} - ignoring dice roll',
        );
        debugPrint(
          '🚨 WARNING: Dice rolled in unexpected phase: ${state.phase}',
        );
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

  /// Close turn order dialog and start the game
  void closeTurnOrderDialog() {
    state = state.copyWith(showTurnOrderDialog: false);
  }

  /// Handle normal movement roll with strict double logic
  /// DOUBLES MECHANIC: Only applies during GamePhase.playerTurn
  /// During setup/rollingForOrder/tieBreaker, doubles are treated as normal values
  Future<void> _handleMovementRoll(
    int d1,
    int d2,
    int roll,
    bool isDouble,
  ) async {
    _logBot(
      '_handleMovementRoll() START - roll: $roll, isDouble: $isDouble, phase: ${state.phase}',
    );

    // ═══════════════════════════════════════════════════════════════════════
    // DEFENSIVE CHECK: Ensure doubles logic only applies during playerTurn phase
    // ═══════════════════════════════════════════════════════════════════════
    if (state.phase != GamePhase.playerTurn) {
      _logBot(
        'WARNING: _handleMovementRoll called in wrong phase (${state.phase}) - disabling doubles logic',
      );
      isDouble = false; // Force treat as normal roll
    }

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
        _isProcessing =
            false; // Reset before calling endTurn() to prevent blocking
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

        // ═══════════════════════════════════════════════════════════════════════
        // LIBRARY PRIORITY: Landing on Library overrides Double Dice re-roll
        // ═══════════════════════════════════════════════════════════════════════
        if (state.showLibraryPenaltyDialog) {
          // Library dialog is shown - it will end the turn when closed
          _logBot(
            'CASE B: Library dialog shown - deferring turn end to dialog closure',
          );
          return;
        }

        final playerAfterMove = state.currentPlayer;
        if (playerAfterMove.turnsToSkip > 0 || playerAfterMove.inJail) {
          // Player sent to jail via 3rd consecutive double
          _logBot('CASE B: Player sent to Jail via 3rd double - ending turn');
          _isProcessing = false;
          endTurn();
          return;
        }

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
      _isProcessing =
          false; // Reset before calling endTurn() to prevent blocking
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
        AudioManager.instance.playSfx('audio/pawn_step.wav');
        await Future.delayed(Duration(milliseconds: hopDelay));
      }

      final tile = state.tiles[currentPos];

      state = state.copyWith(currentTile: tile);
      _addLog("${tile.name} karesine gelindi.");
      _logBot('Landed on tile: ${tile.name} (type: ${tile.type})');

      await _handleTileArrival(tile);
    } catch (e, stackTrace) {
      debugPrint('🚨 ERROR in _movePlayer: $e');
      debugPrint('Stack trace: $stackTrace');
      _addLog('Hareket hatası: $e', type: 'error');
      _logBot('🚨 ERROR in _movePlayer: $e');
      endTurn();
    }
  }

  Future<void> _handleTileArrival(BoardTile tile) async {
    _logBot('_handleTileArrival() - Tile: ${tile.name}, Type: ${tile.type}');
    switch (tile.type) {
      case TileType.category:
        _logBot('Tile type: CATEGORY');
        if (tile.category != null) {
          await _triggerQuestion(tile);
        } else {
          endTurn();
        }
        break;
      case TileType.tesvik:
        _logBot('Tile type: TEŞVİK');
        // Teşvik tiles always trigger a bonus question
        await _triggerQuestion(tile);
        break;
      case TileType.start:
        _logBot('Tile type: START');
        // Start tile - award salary and end turn
        await _handleStartTileLanding();
        break;
      case TileType.shop:
        _logBot('Tile type: SHOP');
        // Kıraathane - Open shop
        await handleKiraathaneLanding();
        break;
      case TileType.library:
        _logBot('Tile type: LIBRARY');
        // Kütüphane - Apply 2-turn penalty
        await _handleLibraryLanding();
        break;
      case TileType.signingDay:
        _logBot('Tile type: SIGNING_DAY');
        // İmza Günü - Show dialog, no penalty
        await _handleSigningDayLanding();
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
      case TileType.chance:
        _logBot('Tile type: CHANCE (ŞANS)');
        // ŞANS - Draw a chance card
        await _drawCardAndApply(CardType.sans);
        break;
      case TileType.fate:
        _logBot('Tile type: FATE (KADER)');
        // KADER - Draw a fate card
        await _drawCardAndApply(CardType.kader);
        break;
    }
  }

  /// Handle Start tile landing - award salary and auto-end turn
  Future<void> _handleStartTileLanding() async {
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
  Future<void> _handleLibraryLanding() async {
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
      await Future.delayed(const Duration(milliseconds: 300), () {
        closeLibraryPenaltyDialog();
      });
      return;
    }

    // Human mode: Create completer to wait for dialog closure (Async Barrier)
    _libraryPenaltyDialogCompleter = Completer<void>();
    state = state.copyWith(players: newPlayers, showLibraryPenaltyDialog: true);

    _addLog(
      "📚 ${player.name} Kütüphanede! Sessizlik lazım, $libraryPenaltyTurns tur bekle.",
      type: 'error',
    );

    // Await the completer to wait for user to close dialog
    await _libraryPenaltyDialogCompleter!.future;
    _libraryPenaltyDialogCompleter = null;
  }

  /// Handle İmza Günü (Signing Day) landing - Show dialog, no penalty
  Future<void> _handleSigningDayLanding() async {
    final player = state.currentPlayer;

    // BOT MODE: Auto-close dialog after short delay
    if (_isBotPlaying) {
      _addLog(
        "🤖 Bot: ✍️ ${player.name} İmza Günü'nde okurlarıyla buluştu!",
        type: 'success',
      );
      await Future.delayed(const Duration(milliseconds: 300), () {
        closeImzaGunuDialog();
      });
      return;
    }

    // Human mode: Create completer to wait for dialog closure (Async Barrier)
    _imzaGunuDialogCompleter = Completer<void>();
    state = state.copyWith(showImzaGunuDialog: true);

    _addLog(
      "✍️ ${player.name} İmza Günü'nde okurlarıyla buluştu!",
      type: 'success',
    );

    // Await the completer to wait for user to close dialog
    await _imzaGunuDialogCompleter!.future;
    _imzaGunuDialogCompleter = null;
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

    // Complete the completer if waiting for dialog to close
    if (_libraryPenaltyDialogCompleter != null &&
        !_libraryPenaltyDialogCompleter!.isCompleted) {
      _libraryPenaltyDialogCompleter!.complete();
    }

    // Library always ends the turn (overrides Double Dice)
    endTurn();
  }

  /// Close İmza Günü dialog and end turn
  void closeImzaGunuDialog() {
    state = state.copyWith(showImzaGunuDialog: false);

    // Complete the completer if waiting for dialog to close
    if (_imzaGunuDialogCompleter != null &&
        !_imzaGunuDialogCompleter!.isCompleted) {
      _imzaGunuDialogCompleter!.complete();
    } else if (_isBotPlaying) {
      // Bot mode: end turn immediately
      endTurn();
    }
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

  Future<void> _triggerQuestion(BoardTile tile) async {
    // For Teşvik tiles, use combined pool of both 'tesvik' and 'bonusBilgiler' categories
    // For other tiles, use the tile's category
    List<String> categoryNames = [];
    if (tile.type == TileType.tesvik) {
      // Teşvik tiles pull from BOTH tesvik AND bonusBilgiler for maximum variety
      categoryNames = ['tesvik', 'bonusBilgiler'];
    } else if (tile.category != null) {
      categoryNames = [tile.category!];
    }

    if (categoryNames.isEmpty) {
      _addLog('Bu karoda soru yok.', type: 'info');
      endTurn();
      return;
    }

    // Now uses categoryNames list instead of tile.category!
    final player = state.currentPlayer;

    // AUTO-DIFFICULTY: Get difficulty based on player's mastery level
    // For Teşvik tiles, use tesvik category for mastery calculation
    final masteryCategoryName = tile.type == TileType.tesvik
        ? 'tesvik'
        : categoryNames.first;
    final masteryLevel = player.getMasteryLevel(masteryCategoryName);
    final targetDifficulty = _getDifficultyForMasteryLevel(masteryLevel);
    final difficultyFilter = switch (targetDifficulty) {
      Difficulty.easy => 'easy',
      Difficulty.medium => 'medium',
      Difficulty.hard => 'hard',
    };

    // Log the auto-selected difficulty
    final masteryName = masteryLevel.displayName;
    final categoryDisplay = tile.type == TileType.tesvik
        ? 'Teşvik/Bonus'
        : _getCategoryDisplayName(categoryNames.first);
    _addLog(
      '$categoryDisplay kategorisinde $masteryName seviyesi: $difficultyFilter soru seçildi.',
      type: 'info',
    );

    // BUG FIX: Filter out already asked questions to prevent repetition
    // For Teşvik tiles, match against EITHER tesvik OR bonusBilgiler
    final filteredQuestions = _cachedQuestions.where((q) {
      final matchesCategory = categoryNames.contains(q.category.name);
      final matchesDifficulty = q.difficulty == difficultyFilter;
      final notAskedBefore = !state.askedQuestionIds.contains(q.text);
      return matchesCategory && matchesDifficulty && notAskedBefore;
    }).toList();

    Question? selectedQuestion;
    bool shouldResetAskedIds = false;

    if (filteredQuestions.isEmpty) {
      // All questions in this category/difficulty have been asked
      // Reset and recycle questions
      _addLog(
        '⚠ Bu kategorideki tüm sorular soruldu. Liste sıfırlanıyor...',
        type: 'info',
      );
      shouldResetAskedIds = true;

      // Get all questions for this category and difficulty (including previously asked)
      final allCategoryQuestions = _cachedQuestions.where((q) {
        final matchesCategory = categoryNames.contains(q.category.name);
        final matchesDifficulty = q.difficulty == difficultyFilter;
        return matchesCategory && matchesDifficulty;
      }).toList();

      if (allCategoryQuestions.isEmpty) {
        // Fallback: any question from this category (any difficulty)
        final anyCategoryQuestions = _cachedQuestions
            .where((q) => categoryNames.contains(q.category.name))
            .toList();
        if (anyCategoryQuestions.isEmpty) {
          // FALLBACK FOR TEŞVIK TILES: Create a synthetic bonus reward question
          // This proves the tile logic works even when the database is empty
          if (tile.type == TileType.tesvik) {
            _addLog(
              '🎁 Teşvik karesi - Bonus ödülü kazandınız!',
              type: 'success',
            );

            // Award bonus stars directly
            final player = state.currentPlayer;
            final bonusStars = 5;
            List<Player> newPlayers = List.from(state.players);
            newPlayers[state.currentPlayerIndex] = player.copyWith(
              stars: player.stars + bonusStars,
            );
            state = state.copyWith(
              players: newPlayers,
              floatingEffect: FloatingEffect('+$bonusStars ⭐', Colors.amber),
            );

            // Clear floating effect after delay
            Future.delayed(const Duration(seconds: 2), () {
              state = state.copyWith(floatingEffect: null);
            });

            _addLog(
              '${player.name} Teşvik bonusu kazandı: +$bonusStars ⭐',
              type: 'success',
            );
            endTurn();
            return;
          }

          _addLog('Bu kategoride soru bulunamadı!', type: 'error');
          endTurn();
          return;
        }
        // Shuffle and pick random
        anyCategoryQuestions.shuffle(_random);
        selectedQuestion = anyCategoryQuestions.first;
        _addLog(
          '⚠ $difficultyFilter zorlu soru bulunamadı, rastgele soru seçildi.',
          type: 'info',
        );
      } else {
        // Shuffle and pick random from the recycled pool
        allCategoryQuestions.shuffle(_random);
        selectedQuestion = allCategoryQuestions.first;
        _addLog('🔄 Soru havuzu yenilendi, yeni soru seçiliyor.', type: 'info');
      }
    } else {
      // Shuffle the filtered list for true randomness, then pick first
      filteredQuestions.shuffle(_random);
      selectedQuestion = filteredQuestions.first;
    }

    // BOT MODE: Auto-answer question without showing dialog
    if (_isBotPlaying) {
      _addLog('🤖 Bot: Soru cevaplandı (${selectedQuestion.category.name})');
      // Track this question as asked even in bot mode
      final updatedAskedIds = Set<String>.from(state.askedQuestionIds);
      updatedAskedIds.add(selectedQuestion.text);
      state = state.copyWith(
        askedQuestionIds: shouldResetAskedIds
            ? {selectedQuestion.text}
            : updatedAskedIds,
      );
      // Bot has 50% chance to answer correctly
      final isCorrect = _random.nextBool();
      await _botAnswerQuestion(selectedQuestion, isCorrect);
      return;
    }

    // Normal mode: Show question dialog
    // Create completer to wait for user response (Async Barrier)
    _questionDialogCompleter = Completer<void>();

    // BUG FIX: Track this question as asked to prevent repetition
    final updatedAskedIds = Set<String>.from(state.askedQuestionIds);
    updatedAskedIds.add(selectedQuestion.text);

    state = state.copyWith(
      showQuestionDialog: true,
      currentQuestion: selectedQuestion,
      currentTile: tile,
      askedQuestionIds: shouldResetAskedIds
          ? {selectedQuestion.text}
          : updatedAskedIds,
    );

    // CRITICAL: Await the completer to wait for user to answer
    // The dialog will call answerQuestion() which will complete this completer
    await _questionDialogCompleter!.future;
    _questionDialogCompleter = null;
  }

  /// Bot auto-answers a question
  Future<void> _botAnswerQuestion(Question question, bool isCorrect) async {
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
          Difficulty.easy => GameConstants.rewardEasy,
          Difficulty.medium => GameConstants.rewardMedium,
          Difficulty.hard => GameConstants.rewardHard,
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

        // ═══════════════════════════════════════════════════════════════════════
        // CATCH-UP MECHANIC (Underdog Bonus) - Bot version
        // ═══════════════════════════════════════════════════════════════════════
        final leaderStars = state.players
            .map((p) => p.stars)
            .reduce((a, b) => a > b ? a : b);
        final bool isUnderdog =
            player.stars < (leaderStars * GameConstants.underdogThreshold);

        if (isUnderdog) {
          final underdogBonus =
              (baseStars * (GameConstants.underdogMultiplier - 1))
                  .round()
                  .clamp(GameConstants.underdogBonusStars, baseStars);
          totalStars += underdogBonus;
          _addLog('🔥 Bot: Mazlum Bonusu! +$underdogBonus ⭐', type: 'success');
        }

        // ═══════════════════════════════════════════════════════════════════════
        // QUOTE DROP RATE (Progression Bonus) - Bot version
        // ═══════════════════════════════════════════════════════════════════════
        var updatedPlayer = player;
        if (difficulty == Difficulty.hard &&
            _random.nextDouble() < GameConstants.hardQuestionQuoteDropRate) {
          final randomQuoteId = 'quote_${_random.nextInt(100)}';
          updatedPlayer = player.collectQuote(randomQuoteId);
          _addLog(
            '📜 Bot: Zor soru bonusu! Söz kartı kazandı!',
            type: 'success',
          );
        } else {
          updatedPlayer = player;
        }

        // Update player
        List<Player> newPlayers = List.from(state.players);

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
  Future<void> answerQuestion(bool isCorrect) async {
    debugPrint('🔷 answerQuestion called: isCorrect=$isCorrect');

    // NOTE: Removed _isProcessing guard - question answering is independent of dice rolling
    if (state.currentQuestion == null) {
      debugPrint('🔷 EARLY RETURN - no currentQuestion!');
      return;
    }

    bool shouldEndTurn = false;

    try {
      final tile = state.currentTile;
      final categoryName = tile?.category;
      final difficulty = tile?.difficulty ?? Difficulty.medium;

      // ═══════════════════════════════════════════════════════════════════════
      // STEP 1: IMMEDIATE LOGIC - Calculate score/stars (dialog still visible)
      // ═══════════════════════════════════════════════════════════════════════
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
          Difficulty.easy => GameConstants.rewardEasy,
          Difficulty.medium => GameConstants.rewardMedium,
          Difficulty.hard => GameConstants.rewardHard,
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

        // ═══════════════════════════════════════════════════════════════════════
        // CATCH-UP MECHANIC (Underdog Bonus)
        // ═══════════════════════════════════════════════════════════════════════
        // Get leader's star count
        final leaderStars = state.players
            .map((p) => p.stars)
            .reduce((a, b) => a > b ? a : b);
        final bool isUnderdog =
            player.stars < (leaderStars * GameConstants.underdogThreshold);

        if (isUnderdog) {
          // Apply underdog multiplier or bonus
          final underdogBonus =
              (baseStars * (GameConstants.underdogMultiplier - 1))
                  .round()
                  .clamp(GameConstants.underdogBonusStars, baseStars);
          totalStars += underdogBonus;
          _addLog(
            '🔥 Mazlum Bonusu! +$underdogBonus ⭐ (Geriden gelme bonusu)',
            type: 'success',
          );
        }

        // Update player stats
        List<Player> newPlayers = List.from(state.players);
        var updatedPlayer = player;

        // ═══════════════════════════════════════════════════════════════════════
        // QUOTE DROP RATE (Progression Bonus)
        // ═══════════════════════════════════════════════════════════════════════
        if (difficulty == Difficulty.hard &&
            _random.nextDouble() < GameConstants.hardQuestionQuoteDropRate) {
          // Generate a random quote ID
          final randomQuoteId = 'quote_${_random.nextInt(100)}';
          updatedPlayer = updatedPlayer.collectQuote(randomQuoteId);
          _addLog(
            '📜 Zor soru bonusu! Rastgele bir söz kartı kazandın!',
            type: 'success',
          );
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

        newPlayers[state.currentPlayerIndex] = updatedPlayer;

        // ═══════════════════════════════════════════════════════════════════════
        // STEP 2: TRIGGER ANIMATION - Update state to show confetti/feedback
        // ═══════════════════════════════════════════════════════════════════════
        state = state.copyWith(players: newPlayers);

        _addLog(
          'Doğru cevap! +$baseStars ⭐ ($difficultyName)',
          type: 'success',
        );
        // SFX now plays in dialog during reveal phase

        if (promotionMessage.isNotEmpty) {
          _addLog(
            '$promotionMessage (+$promotionReward ⭐ bonus)',
            type: 'success',
          );
        }

        _checkWinCondition();

        if (state.phase != GamePhase.gameOver) {
          shouldEndTurn = true;
        }
      } else if (!isCorrect) {
        _addLog("Yanlış cevap. Yıldız kazanamadın.", type: 'error');
        // SFX now plays in dialog during reveal phase
        shouldEndTurn = true;
      } else {
        shouldEndTurn = true;
      }

      // ═══════════════════════════════════════════════════════════════════════
      // STEP 3: TEARDOWN - Close dialog immediately
      // NOTE: Animation already played in the dialog widget before callback was called.
      // No additional delay needed here.
      // ═══════════════════════════════════════════════════════════════════════
      debugPrint('🔷 TEARDOWN: Setting showQuestionDialog=false');
      state = state.copyWith(showQuestionDialog: false, currentQuestion: null);
    } catch (e, stack) {
      debugPrint('🔷 ERROR in answerQuestion: $e');
      debugPrint('🔷 Stack: $stack');
    } finally {
      // SAFETY FALLBACK: Always reset processing flag and complete completer
      _isProcessing = false;
      debugPrint('🔷 FINALLY: _isProcessing reset to false');

      // Unblock the flow - safely complete the completer
      debugPrint(
        '🔷 Completer status: ${_questionDialogCompleter != null ? (_questionDialogCompleter!.isCompleted ? "completed" : "pending") : "null"}',
      );
      if (_questionDialogCompleter != null &&
          !_questionDialogCompleter!.isCompleted) {
        debugPrint('🔷 Completing _questionDialogCompleter NOW');
        _questionDialogCompleter!.complete();
      }
      _questionDialogCompleter = null;
      debugPrint('🔷 FINALLY complete, dialog should be closed now');
    }

    // End turn after everything is cleaned up
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
      case 'bonusBilgiler':
        return 'Bonus Bilgi';
      default:
        return categoryName;
    }
  }

  /// Draw a card from Şans or Kader deck
  /// Note: Currently unused - cards are handled through other mechanisms
  // ignore: unused_element
  Future<void> _drawCard(CardType cardType) async {
    await _drawCardAndApply(cardType);
  }

  /// Draw a card from Şans or Kader deck and apply its effect
  /// For human players: Shows card dialog, effect applied when dialog is closed
  /// For bot players: Auto-applies effect without showing dialog
  Future<void> _drawCardAndApply(CardType cardType) async {
    await Future.delayed(
      Duration(
        milliseconds: _isBotPlaying ? 100 : GameConstants.cardAnimationDelay,
      ),
    );

    final isSans = cardType == CardType.sans;
    final deck = isSans ? GameCards.sansCards : GameCards.kaderCards;
    final card = deck[_random.nextInt(deck.length)];
    final cardName = isSans ? "ŞANS" : "KADER";

    // BOT MODE: Auto-apply card effect without showing dialog
    if (_isBotPlaying) {
      _addLog('🤖 Bot: $cardName kartı çekildi');
      await _botApplyCardEffect(card);
      return;
    }

    // Human mode: Show card dialog and wait for it to close
    _addLog(
      '🎲 ${state.currentPlayer.name} $cardName karesine geldi! Kart çekiliyor...',
    );
    AudioManager.instance.playSfx('audio/card_flip.wav');

    // Create a completer to wait for dialog closure
    _cardDialogCompleter = Completer<void>();
    state = state.copyWith(showCardDialog: true, currentCard: card);

    // Wait for the dialog to be closed (completed in closeCardDialog)
    await _cardDialogCompleter!.future;
    _cardDialogCompleter = null;
  }

  /// Bot auto-applies a card effect
  Future<void> _botApplyCardEffect(GameCard card) async {
    try {
      final player = state.currentPlayer;

      switch (card.effectType) {
        case CardEffectType.moneyChange:
          // Borçlanma Koruması (Debt Protection): Balance never goes below 0
          final originalStars = player.stars;
          final rawNewStars = player.stars + card.value;
          final newStars = rawNewStars.clamp(0, double.infinity).toInt();

          // Check if player couldn't afford the full payment
          if (card.value < 0 && rawNewStars < 0) {
            // Player went into debt (before clamp) - apply alternative penalty
            List<Player> penaltyPlayers = List.from(state.players);
            penaltyPlayers[state.currentPlayerIndex] = player.copyWith(
              stars: newStars,
              turnsToSkip: player.turnsToSkip + 1, // Alternative: 1 turn wait
            );
            state = state.copyWith(players: penaltyPlayers);
            _addLog(
              "🤖 Bot: ⚠️ ${player.name} ödeyemedi! Yıldızlar 0'a düştü + 1 tur ceza!",
              type: 'error',
            );
          } else {
            _updateStars(player, newStars);
            if (card.value > 0) {
              _addLog(
                "🤖 Bot: 💰 ${player.name} +${card.value} yıldız kazandı!",
                type: 'success',
              );
            } else {
              final lost = originalStars - newStars;
              _addLog(
                "🤖 Bot: 💸 ${player.name} $lost yıldız kaybetti!",
                type: 'error',
              );
            }
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

        case CardEffectType.moveRelative:
          // Move forward/backward by relative amount
          int currentPos = player.position;
          int targetPos = (currentPos + card.value) % BoardConfig.boardSize;
          if (targetPos < 0) targetPos += BoardConfig.boardSize;

          List<Player> newPlayers = List.from(state.players);
          int newStars = player.stars;

          // Check if passed start (moving forward wraps around)
          if (card.value > 0 && targetPos < currentPos) {
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

          if (card.value > 0) {
            _addLog("🤖 Bot: ➡️ ${player.name} $targetPos. kareye ilerledi!");
          } else {
            _addLog("🤖 Bot: ⬅️ ${player.name} $targetPos. kareye geri gitti!");
          }
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

        case CardEffectType.skipTurn:
          List<Player> temp = List.from(state.players);
          temp[state.currentPlayerIndex] = player.copyWith(
            turnsToSkip: player.turnsToSkip + card.value,
          );
          state = state.copyWith(players: temp);
          _addLog(
            "🤖 Bot: ⏸️ ${player.name} ${card.value} tur ceza aldı!",
            type: 'error',
          );
          break;

        case CardEffectType.rollAgain:
          _addLog("🤖 Bot: 🎲 ${player.name} tekrar zar atıyor!", type: 'info');
          // Don't end turn, let the bot roll again
          return;

        case CardEffectType.loseStarsPercentage:
          int percentage = card.value; // e.g., 50 means 50%
          int loss = (player.stars * percentage / 100).round();
          int newStars = player.stars - loss;
          _updateStars(player, newStars);
          _addLog(
            "🤖 Bot: 📉 ${player.name} yıldızlarının %%$percentage'ini kaybetti! (-$loss ⭐)",
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
          // Borçlanma Koruması (Debt Protection): Balance never goes below 0
          final originalStars = player.stars;
          final rawNewStars = player.stars + card.value;
          final newStars = rawNewStars.clamp(0, double.infinity).toInt();

          // Check if player couldn't afford the full payment
          if (card.value < 0 && rawNewStars < 0) {
            // Player went into debt (before clamp) - apply alternative penalty
            List<Player> penaltyPlayers = List.from(state.players);
            penaltyPlayers[state.currentPlayerIndex] = player.copyWith(
              stars: newStars,
              turnsToSkip: player.turnsToSkip + 1, // Alternative: 1 turn wait
            );
            state = state.copyWith(players: penaltyPlayers);
            _addLog(
              "⚠️ ${player.name} ödeyemedi! Yıldızlar 0'a düştü + 1 tur ceza!",
              type: 'error',
            );
          } else {
            _updateStars(player, newStars);
            if (card.value > 0) {
              _addLog(
                "💰 ${player.name} +${card.value} yıldız kazandı!",
                type: 'success',
              );
            } else {
              final lost = originalStars - newStars;
              _addLog(
                "💸 ${player.name} $lost yıldız kaybetti!",
                type: 'error',
              );
            }
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

        case CardEffectType.moveRelative:
          // Move forward/backward by relative amount
          int currentPos = player.position;
          int targetPos = (currentPos + card.value) % BoardConfig.boardSize;
          if (targetPos < 0) targetPos += BoardConfig.boardSize;

          List<Player> newPlayers = List.from(state.players);
          int newStars = player.stars;

          // Check if passed start (moving forward wraps around)
          if (card.value > 0 && targetPos < currentPos) {
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

          if (card.value > 0) {
            _addLog("➡️ ${player.name} $targetPos. kareye ilerledi!");
          } else {
            _addLog("⬅️ ${player.name} $targetPos. kareye geri gitti!");
          }
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

        case CardEffectType.skipTurn:
          List<Player> temp = List.from(state.players);
          temp[state.currentPlayerIndex] = player.copyWith(
            turnsToSkip: player.turnsToSkip + card.value,
          );
          state = state.copyWith(players: temp);
          _addLog(
            "⏸️ ${player.name} ${card.value} tur ceza aldı!",
            type: 'error',
          );
          break;

        case CardEffectType.rollAgain:
          _addLog("🎲 ${player.name} tekrar zar atıyor!", type: 'info');
          // Don't end turn, let the player roll again
          state = state.copyWith(
            showCardDialog: false,
            currentCard: null,
            isDiceRolled: false,
          );
          return;

        case CardEffectType.loseStarsPercentage:
          int percentage = card.value; // e.g., 50 means 50%
          int loss = (player.stars * percentage / 100).round();
          int newStars = player.stars - loss;
          _updateStars(player, newStars);
          _addLog(
            "📉 ${player.name} yıldızlarının %%$percentage'ini kaybetti! (-$loss ⭐)",
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

    // Complete the completer if waiting for card dialog to close
    if (_cardDialogCompleter != null && !_cardDialogCompleter!.isCompleted) {
      _cardDialogCompleter!.complete();
    } else if (_isBotPlaying) {
      // Bot mode: end turn immediately
      endTurn();
    }
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

      // BUG FIX: Don't decrement here! Penalty is only decremented in rollDice()
      // We only check if the next player should be skipped
      bool isSkipped = nextPlayer.turnsToSkip > 0;
      List<Player> updatedPlayers = List.from(state.players);

      if (isSkipped) {
        _logBot(
          'Next player has turnsToSkip: ${nextPlayer.turnsToSkip} - will be skipped',
        );
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

  Future<void> openShopDialog() async {
    // BOT MODE: Auto-close dialog after short delay
    if (_isBotPlaying) {
      state = state.copyWith(showShopDialog: true);
      _addLog('🤖 Bot: Kıraathane\'ye hoş geldiniz!', type: 'info');
      await Future.delayed(const Duration(milliseconds: 500), () {
        closeShopDialog();
      });
      return;
    }

    // Human mode: Create completer to wait for dialog closure (Async Barrier)
    _shopDialogCompleter = Completer<void>();
    state = state.copyWith(showShopDialog: true);
    _addLog('Kıraathane\'ye hoş geldiniz!', type: 'info');

    // Await the completer to wait for user to close dialog
    await _shopDialogCompleter!.future;
    _shopDialogCompleter = null;
  }

  void closeShopDialog() {
    state = state.copyWith(showShopDialog: false);

    // Complete the completer if waiting for dialog to close
    if (_shopDialogCompleter != null && !_shopDialogCompleter!.isCompleted) {
      _shopDialogCompleter!.complete();
    } else if (_isBotPlaying) {
      // Bot mode: end turn immediately
      endTurn();
    }
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
      'bonusBilgiler': MasteryLevel.usta.value,
    };

    // Create category progress map with Hard difficulty set
    final categoryProgress = <String, Map<String, int>>{
      'turkEdebiyatindaIlkler': {'hard': 3},
      'edebiSanatlar': {'hard': 3},
      'eserKarakter': {'hard': 3},
      'edebiyatAkimlari': {'hard': 3},
      'benKimim': {'hard': 3},
      'tesvik': {'hard': 3},
      'bonusBilgiler': {'hard': 3},
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

  Future<void> handleKiraathaneLanding() async {
    await openShopDialog();
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
