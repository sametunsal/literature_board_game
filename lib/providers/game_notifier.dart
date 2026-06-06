import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/board_tile.dart';
import '../models/book_level.dart';
import '../models/book_ownership.dart';
import '../models/game_enums.dart';
import '../models/question.dart';
import '../../core/utils/logger.dart';
import '../models/tile_type.dart';
import '../models/difficulty.dart';
import '../data/board_config.dart';
import '../data/game_cards.dart';
import '../core/constants/game_constants.dart';
import '../core/managers/audio_manager.dart';
import '../core/services/turn_order_service.dart';
import '../core/services/dice_service.dart';
import '../core/services/movement_service.dart';
import '../core/services/economy_service.dart';
import '../core/services/bot_callbacks.dart';
import '../core/services/bot_controller.dart';
import '../core/services/book_progression_service.dart';
import '../core/services/board_book_lookup_service.dart';
import '../core/services/card_effect_service.dart';
import '../core/services/question_flow_service.dart';
import 'dialog_provider.dart';
import 'repository_providers.dart';

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

  // Pause State
  final bool isGamePaused;

  final bool isDoubleTurn; // Indicates if current turn is a double roll bonus

  final BoardTile? currentTile;
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

  /// Publishing Tycoon dormant state: book ID -> ownership state.
  final Map<String, BookOwnership> bookOwnerships;

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
    this.isDoubleTurn = false,
    this.currentTile,
    this.winner,
    this.setupMessage,
    this.orderRolls = const {},
    this.tieBreakerGroups = const {},
    this.finalizedOrder = const [],
    this.pendingTieBreakPlayers = const [],
    this.tieBreakRound = 0,
    this.tieBreakRoundRolls = const {},
    this.askedQuestionIds = const {},
    this.bookOwnerships = const {},
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
    bool? isDoubleTurn,
    BoardTile? currentTile,
    Player? winner,
    String? setupMessage,
    Map<String, int>? orderRolls,
    Map<int, List<String>>? tieBreakerGroups,
    List<Player>? finalizedOrder,
    List<Player>? pendingTieBreakPlayers,
    int? tieBreakRound,
    Map<String, int>? tieBreakRoundRolls,
    Set<String>? askedQuestionIds,
    Map<String, BookOwnership>? bookOwnerships,
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
      isDoubleTurn: isDoubleTurn ?? this.isDoubleTurn,
      currentTile: currentTile ?? this.currentTile,
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
      bookOwnerships: bookOwnerships ?? this.bookOwnerships,
      isGamePaused: isGamePaused ?? this.isGamePaused,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final Ref ref;
  final TurnOrderService _turnOrderService = TurnOrderService();
  final DiceService _diceService = DiceService();
  final MovementService _movementService = MovementService();
  final EconomyService _economyService = const EconomyService();
  final BookProgressionService _bookProgressionService =
      const BookProgressionService();
  late final CardEffectService _cardEffectService = CardEffectService(
    _economyService,
  );
  late final QuestionFlowService _questionFlowService = QuestionFlowService(
    _economyService,
  );
  final _random = Random();
  Timer? _animationTimer;
  final List<Timer> _activeTimers = [];
  bool _isProcessing = false;

  /// Global action lock to prevent race conditions from rapid UI tapping
  bool _isProcessingAction = false;

  // Bot mode — delegated to BotController
  late final BotController _botController;
  bool get _isBotPlaying => _botController.isActive;
  bool get isBotPlaying => _botController.isActive;
  Timer? _botWatchdog;

  // Cached questions for the session
  List<Question> _cachedQuestions = [];

  // Guard against infinite card→tile→card chains
  int _tileArrivalDepth = 0;
  static const _maxTileArrivalDepth = 3;

  // Completers for waiting for dialogs to close (Async Barrier)
  Completer<void>? _cardDialogCompleter;
  Completer<void>? _questionDialogCompleter;
  Completer<void>? _libraryPenaltyDialogCompleter;
  Completer<void>? _imzaGunuDialogCompleter;
  Completer<void>? _shopDialogCompleter;

  // Dialog lock flag - prevents turn actions while dialog is open
  bool get _isDialogOpen => ref.read(dialogProvider).isAnyDialogOpen;

  GameNotifier(this.ref) : super(GameState(players: [])) {
    _botController = BotController(
      callbacks: BotCallbacks(
        rollDice: () => rollDice(),
        endTurn: () => endTurn(),
        addLog: (msg, {type = 'info'}) => _addLog(msg, type: type),
        applyAnswerResult: (r) => _applyAnswerResult(r),
        applyCardEffectResult: (r) => _applyCardEffectResult(r),
        checkWinCondition: () => _checkWinCondition(),
        closeCardDialog: () => closeCardDialog(),
        closeLibraryPenaltyDialog: () => closeLibraryPenaltyDialog(),
        closeImzaGunuDialog: () => closeImzaGunuDialog(),
        closePrinterIssueDialog: () => closePrinterIssueDialog(),
        closeShopDialog: () => closeShopDialog(),
        closeTurnOrderDialog: () => closeTurnOrderDialog(),
        closeTurnSkippedDialog: () => closeTurnSkippedDialog(),
        answerQuestion: (isCorrect) => answerQuestion(isCorrect),
        readDialogState: () {
          final d = ref.read(dialogProvider);
          return BotDialogSnapshot(
            showQuestionDialog: d.showQuestionDialog,
            showCardDialog: d.showCardDialog,
            showLibraryPenaltyDialog: d.showLibraryPenaltyDialog,
            showImzaGunuDialog: d.showImzaGunuDialog,
            showPrinterIssueDialog: d.showPrinterIssueDialog,
            showTurnSkippedDialog: d.showTurnSkippedDialog,
            showShopDialog: d.showShopDialog,
            showTurnOrderDialog: d.showTurnOrderDialog,
          );
        },
        readIsDiceRolling: () => state.isDiceRolling,
        readIsProcessing: () => _isProcessing,
        setProcessing: (v) => _isProcessing = v,
        readGamePhase: () => state.phase,
      ),
      cardEffectService: _cardEffectService,
      questionFlowService: _questionFlowService,
    );
  }

  bool get isProcessing => _isProcessing;

  /// Exposes processing state for UI lock during automated turn order
  bool get isTurnOrderProcessing =>
      _isProcessing &&
      (state.phase == GamePhase.rollingForOrder ||
          state.phase == GamePhase.tieBreaker);

  @visibleForTesting
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

  @visibleForTesting
  int computeLeadCompressionTurnBonus({
    required int currentStars,
    required int leaderStars,
    required bool isSkipped,
  }) {
    if (isSkipped) return 0;
    final adjusted = _economyService.applyLeadCompression(
      reward: GameConstants.underdogBonusStars,
      currentStars: currentStars,
      leaderStars: leaderStars,
    );
    return (adjusted - GameConstants.underdogBonusStars).clamp(0, 9999);
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // PAUSE MECHANISM
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

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
      await Future.delayed(
        const Duration(milliseconds: GameConstants.pauseCheckInterval),
      );
    }
    _logBot('Execution resumed');
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // BOT LOGGING (forwarded to BotController)
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  void _logBot(String message) => _botController.log(message);

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // WATCHDOG TIMER (Anti-Freeze Protection)
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Start or restart the watchdog timer
  void _startWatchdog() {
    if (!_isBotPlaying) return;

    // Cancel existing watchdog
    _botWatchdog?.cancel();

    // Start new watchdog with 4 second timeout
    _botWatchdog = Timer(const Duration(seconds: 4), () {
      if (_isBotPlaying) {
        final dialog = ref.read(dialogProvider);
        _logBot('ğŸš¨ WATCHDOG: Bot stuck! Forcing recovery...');
        safePrint('[BOT ğŸ¤–] WATCHDOG TRIGGERED - Current state:');
        safePrint('  - _isProcessing: $_isProcessing');
        safePrint('  - isDiceRolling: ${state.isDiceRolling}');
        safePrint('  - showQuestionDialog: ${dialog.showQuestionDialog}');
        safePrint('  - showCardDialog: ${dialog.showCardDialog}');
        safePrint(
          '  - showLibraryPenaltyDialog: ${dialog.showLibraryPenaltyDialog}',
        );
        safePrint('  - showImzaGunuDialog: ${dialog.showImzaGunuDialog}');
        safePrint(
          '  - showPrinterIssueDialog: ${dialog.showPrinterIssueDialog}',
        );
        safePrint('  - showShopDialog: ${dialog.showShopDialog}');
        safePrint('  - showTurnOrderDialog: ${dialog.showTurnOrderDialog}');
        safePrint('  - phase: ${state.phase}');
        safePrint('  - currentPlayer: ${state.currentPlayer.name}');

        // Force reset processing flag
        _isProcessing = false;

        // Try to recover by forcing next action
        if (dialog.showQuestionDialog) {
          _logBot('Watchdog: Closing stuck question dialog');
          answerQuestion(_random.nextBool());
        } else if (dialog.showCardDialog) {
          _logBot('Watchdog: Closing stuck card dialog');
          closeCardDialog();
        } else if (dialog.showLibraryPenaltyDialog) {
          _logBot('Watchdog: Closing stuck library dialog');
          closeLibraryPenaltyDialog();
        } else if (dialog.showImzaGunuDialog) {
          _logBot('Watchdog: Closing stuck imza gÃ¼nÃ¼ dialog');
          closeImzaGunuDialog();
        } else if (dialog.showPrinterIssueDialog) {
          _logBot('Watchdog: Closing stuck printer issue dialog');
          closePrinterIssueDialog();
        } else if (dialog.showShopDialog) {
          _logBot('Watchdog: Closing stuck shop dialog');
          closeShopDialog();
        } else if (dialog.showTurnOrderDialog) {
          _logBot('Watchdog: Closing stuck turn order dialog');
          closeTurnOrderDialog();
          _scheduleBotTurn();
        } else if (dialog.showTurnSkippedDialog) {
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

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // 1. OYUN BAÅLATMA & KURULUM
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Initialize game with player list
  Future<void> initializeGame(List<Player> players) async {
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

    // Load questions from repository (non-blocking: game starts even if Firestore fails)
    try {
      final questionRepository = ref.read(questionRepositoryProvider);
      _cachedQuestions = await questionRepository.getAllQuestions();
      // Shuffle questions for random order each game
      _cachedQuestions.shuffle(_random);
      safePrint('ℹ️ Questions shuffled for random order this game');
    } catch (e, stackTrace) {
      safePrint('JSON Yükleme Hatası: $e');
      safePrint('JSON Yükleme Hatası Stack Trace: $stackTrace');
      safePrint('⚠️ Question loading failed: $e - continuing with empty list');
      _cachedQuestions = [];
    }

    state = GameState(
      players: uniquePlayers,
      tiles: BoardConfig.tiles,
      phase: GamePhase.rollingForOrder,
      lastAction: 'SÄ±ra belirlemek iÃ§in zar atÄ±n...',
    );

    _addLog("Oyun baÅŸlatÄ±ldÄ±! ${uniquePlayers.length} oyuncu katÄ±ldÄ±.");
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // TURN ORDER DETERMINATION - Iron-Clad State Machine (v2.0)
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //
  // This is a FULLY AUTOMATED system. No manual dice button presses.
  // Phase 1: All players auto-roll
  // Phase 2: Evaluate & detect ties
  // Phase 3: Recursive tie-break (fully automated)
  //
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // SERVICE HELPERS (Exposed for TurnOrderService)
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  GameState get currentState => state;
  void updateState(GameState newState) => state = newState;
  void addLog(String message, {String? type}) =>
      _addLog(message, type: type ?? 'info');
  void logBot(String message) => _botController.log(message);
  Future<void> checkPauseStatus() => _checkPauseStatus();
  void setProcessing(bool value) => _isProcessing = value;

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // TURN ORDER DETERMINATION (Delegated to TurnOrderService)
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Delegated to TurnOrderService
  Future<void> startAutomatedTurnOrder({
    List<Player>? playersToRoll,
    int depth = 0,
  }) async {
    await _turnOrderService.execute(
      this,
      playersToRoll: playersToRoll,
      depth: depth,
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
      lastAction: 'SÄ±ra belirlendi! ${sortedPlayers.first.name} baÅŸlÄ±yor.',
    );

    _addLog("SÄ±ra belirlendi! ${sortedPlayers.first.name} baÅŸlÄ±yor.");
  }

  void debugJumpCurrentPlayerToPosition(int position) {
    if (!kDebugMode || state.players.isEmpty) return;

    final tiles = state.tiles.isNotEmpty ? state.tiles : BoardConfig.tiles;
    BoardTile? tile;
    for (final candidate in tiles) {
      if (candidate.position == position) {
        tile = candidate;
        break;
      }
    }

    if (tile == null) {
      _addLog('DEBUG: tile position $position not found', type: 'error');
      return;
    }

    final players = List<Player>.from(state.players);
    final playerIndex = state.currentPlayerIndex % players.length;
    final player = players[playerIndex];
    players[playerIndex] = player.copyWith(position: position);

    state = state.copyWith(players: players, currentTile: tile);
    _addLog(
      'DEBUG: ${player.name} jumped to tile $position (${tile.name})',
      type: 'info',
    );
  }

  Future<void> debugTriggerCurrentTile() async {
    if (!kDebugMode) return;

    final tile = state.currentTile;
    if (tile == null) {
      _addLog('DEBUG: no current tile to trigger', type: 'error');
      return;
    }

    _addLog(
      'DEBUG: triggering tile ${tile.position} (${tile.name})',
      type: 'info',
    );
    await _handleTileArrival(tile);
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // 2. ZAR ATMA & HAREKET (Dice Rolling & Movement)
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Roll dice - handles MOVEMENT rolls during playerTurn phase.
  /// NOTE: Turn order rolls are handled automatically by startAutomatedTurnOrder().
  Future<void> rollDice() async {
    // DIAGNOSTIC: Always print flag states for deadlock tracing
    safePrint(
      '🎲 rollDice() ENTRY - _isProcessingAction: $_isProcessingAction, _isProcessing: $_isProcessing, isDiceRolling: ${state.isDiceRolling}, phase: ${state.phase}',
    );

    // UI Race Condition Guard
    if (_isProcessingAction || state.isDiceRolling) {
      safePrint(
        '🎲 rollDice() BLOCKED - _isProcessingAction: $_isProcessingAction, isDiceRolling: ${state.isDiceRolling}',
      );
      _logBot(
        'rollDice() BLOCKED - _isProcessingAction active or dice rolling',
      );
      return;
    }
    _isProcessingAction = true;

    try {
      _logBot(
        'rollDice() START - ${_isProcessing ? "BLOCKED (processing)" : "OK"}',
      );

      if (_isProcessing) {
        _logBot('rollDice() BLOCKED - isProcessing: $_isProcessing');
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

      await _diceService.executeRoll(
        notifier: this,
        state: state,
        isBotPlaying: _isBotPlaying,
        onMovementRoll: (d1, d2, roll, isDouble) async {
          await _handleMovementRoll(d1, d2, roll, isDouble);
        },
      );
    } catch (e, stackTrace) {
      // SAFETY: Catch any error and log it
      safePrint('🚨 ERROR in rollDice: $e');
      safePrint('Stack trace: $stackTrace');
      _addLog('Hata oluştu: $e', type: 'error');
      _logBot('🚨 ERROR in rollDice: $e');
      // Try to recover
      _scheduleBotTurn();
    } finally {
      // SAFETY: Always reset processing flag to prevent freezing
      _isProcessing = false;
      _isProcessingAction = false; // Reset action guard
      _logBot('rollDice() finally - _isProcessing reset to false');
    }
  }

  /// Close turn order dialog and start the game
  void closeTurnOrderDialog() {
    ref.read(dialogProvider.notifier).hideTurnOrder();
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

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // DEFENSIVE CHECK: Ensure doubles logic only applies during playerTurn phase
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
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

      // CASE A: Consecutive double cap reached -> Jail
      if (newConsecutive > GameConstants.maxConsecutiveDoubles) {
        _logBot('CASE A: consecutive double cap reached -> Jail');
        _addLog(
          "ðŸš¨ Çok fazla çift! KÃ¼tÃ¼phaneye (Hapse) gidiyorsun.",
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
        await Future.delayed(
          _botController.getDelay(humanMs: 1500, botMs: 300),
        );
        _isProcessing =
            false; // Reset before calling endTurn() to prevent blocking
        endTurn();
        return;
      }

      // CASE B: Double Roll (1st or 2nd)
      if (isDouble) {
        _logBot('CASE B: Double roll (1st or 2nd)');
        _addLog(
          "ðŸŽ² Ã‡ift AttÄ±n ($newConsecutive. Kez)! Tekrar oyna.",
          type: 'dice',
        );
        if (newConsecutive == GameConstants.maxConsecutiveDoubles) {
          _addLog(
            "⚖️ Denge: 2. çift sonrası ödül bonuslarında azalma aktif.",
            type: 'warning',
          );
        }

        // Update state with dice results and consecutive count
        state = state.copyWith(
          dice1: d1,
          dice2: d2,
          diceTotal: roll,
          isDiceRolled: true,
          consecutiveDoubles: newConsecutive,
        );

        // Move player
        await Future.delayed(
          _botController.getDelay(humanMs: 1500, botMs: 300),
        );
        await _movePlayer(roll);

        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        // LIBRARY PRIORITY: Landing on Library overrides Double Dice re-roll
        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        if (ref.read(dialogProvider).showLibraryPenaltyDialog) {
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
        "${state.currentPlayer.name} $roll ($d1-$d2) attÄ±. SÄ±ra geÃ§iyor.",
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
      await Future.delayed(_botController.getDelay(humanMs: 1500, botMs: 300));
      await _movePlayer(roll);

      // After movement, endTurn() is called in finally block
      _logBot('_handleMovementRoll() COMPLETED');
    } catch (e, stackTrace) {
      safePrint('ðŸš¨ ERROR in _handleMovementRoll: $e');
      safePrint('Stack trace: $stackTrace');
      _addLog('Hareket hatasÄ±: $e', type: 'error');
      _logBot('ðŸš¨ ERROR in _handleMovementRoll: $e');
      // Ensure turn ends even on error
      _isProcessing =
          false; // Reset before calling endTurn() to prevent blocking
      endTurn();
    } finally {
      // SAFETY: Always reset processing flag to prevent freezing
      _isProcessing = false;
      _logBot('_handleMovementRoll() finally - _isProcessing reset to false');
    }
  }

  /// Move player step-by-step with hopping animation
  Future<void> _movePlayer(int steps) async {
    await _movementService.executeMovement(
      notifier: this,
      state: state,
      steps: steps,
      isBotPlaying: _isBotPlaying,
      onTileArrival: (tile) async {
        await _handleTileArrival(tile);
      },
      endTurn: endTurn,
    );
  }

  Future<void> _handleTileArrival(BoardTile tile) async {
    _logBot('_handleTileArrival() - Tile: ${tile.name}, Type: ${tile.type}');

    if (_tileArrivalDepth >= _maxTileArrivalDepth) {
      safePrint(
        '⚠️ Tile arrival chain depth exceeded $_maxTileArrivalDepth — breaking loop',
      );
      _tileArrivalDepth = 0;
      endTurn();
      return;
    }
    _tileArrivalDepth++;
    try {
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
          _logBot('Tile type: TEÅVÄ°K');
          // TeÅŸvik tiles always trigger a bonus question
          await _triggerQuestion(tile);
          break;
        case TileType.start:
          _logBot('Tile type: START');
          // Start tile - award salary and end turn
          await _handleStartTileLanding();
          break;
        case TileType.shop:
          _logBot('Tile type: SHOP');
          // KÄ±raathane - Open shop
          await handleKiraathaneLanding();
          break;
        case TileType.library:
          _logBot('Tile type: LIBRARY');
          // KÃ¼tÃ¼phane - Apply 2-turn penalty
          await _handleLibraryLanding();
          break;
        case TileType.signingDay:
          _logBot('Tile type: SIGNING_DAY');
          // Ä°mza GÃ¼nÃ¼ - Show dialog, no penalty
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
          _logBot('Tile type: CHANCE (ÅžANS)');
          // ÅžANS - Draw a chance card
          await _drawCardAndApply(CardType.sans);
          break;
        case TileType.fate:
          _logBot('Tile type: FATE (KADER)');
          // KADER - Draw a fate card
          await _drawCardAndApply(CardType.kader);
          break;
      }
    } finally {
      _tileArrivalDepth--;
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
      "ğŸ ${player.name} BaÅŸlangÄ±Ã§'tan geÃ§ti! +$salaryAmount YÄ±ldÄ±z kazandÄ±!",
      type: 'success',
    );

    // Wait to show the message, then end turn (faster in bot mode)
    await Future.delayed(_botController.getDelay(humanMs: 1500, botMs: 300));

    // Movement roll still holds _isProcessing — release before endTurn
    _isProcessing = false;
    endTurn();
  }

  /// Handle KÃ¼tÃ¼phane (Library) landing - Apply 2-turn penalty
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
      _botController.handleDialogTile(BotDialogType.library);
      return;
    }

    // Human mode: Create completer to wait for dialog closure (Async Barrier)
    _libraryPenaltyDialogCompleter = Completer<void>();
    ref.read(dialogProvider.notifier).showLibraryPenalty();

    _addLog(
      "📚 ${player.name} Kütüphanede! Sessizlik lazım, $libraryPenaltyTurns tur bekle.",
      type: 'error',
    );

    _isProcessingAction = false;

    // Await the completer to wait for user to close dialog
    await _libraryPenaltyDialogCompleter!.future;

    _libraryPenaltyDialogCompleter = null;
  }

  /// Handle Ä°mza GÃ¼nÃ¼ (Signing Day) landing - Show dialog, no penalty
  Future<void> _handleSigningDayLanding() async {
    final player = state.currentPlayer;

    // BOT MODE: Auto-close dialog after short delay
    if (_isBotPlaying) {
      _addLog(
        "ğŸ¤– Bot: âœï¸ ${player.name} Ä°mza GÃ¼nÃ¼'nde okurlarÄ±yla buluÅŸtu!",
        type: 'success',
      );
      _botController.handleDialogTile(BotDialogType.signingDay);
      return;
    }

    // Human mode: Create completer to wait for dialog closure (Async Barrier)
    _imzaGunuDialogCompleter = Completer<void>();
    ref.read(dialogProvider.notifier).showImzaGunu();

    _addLog(
      "✍️ ${player.name} İmza Günü'nde okurlarıyla buluştu!",
      type: 'success',
    );

    _isProcessingAction = false;

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

    state = state.copyWith(players: newPlayers, consecutiveDoubles: 0);

    ref.read(dialogProvider.notifier).hideLibraryPenalty();

    _addLog(
      "${player.name} ${GameConstants.jailTurns} tur ceza aldÄ±!",
      type: 'error',
    );

    // Complete the completer if waiting for dialog to close
    if (_libraryPenaltyDialogCompleter != null &&
        !_libraryPenaltyDialogCompleter!.isCompleted) {
      _libraryPenaltyDialogCompleter!.complete();
    }

    // Same as İmza Günü / shop: endTurn must not run while movement holds _isProcessing
    _isProcessing = false;
    // Library always ends the turn (overrides Double Dice)
    endTurn();
  }

  /// Close Ä°mza GÃ¼nÃ¼ dialog and end turn
  void closeImzaGunuDialog() {
    ref.read(dialogProvider.notifier).hideImzaGunu();

    // Complete the completer if waiting for dialog to close
    if (_imzaGunuDialogCompleter != null &&
        !_imzaGunuDialogCompleter!.isCompleted) {
      _imzaGunuDialogCompleter!.complete();
    }

    // Movement roll still holds _isProcessing until _handleMovementRoll's finally
    // runs. endTurn() no-ops while _isProcessing is true — release first.
    _isProcessing = false;
    endTurn();
  }

  /// Close printer/ink issue dialog and set turnsToSkip
  void closePrinterIssueDialog() {
    final player = state.currentPlayer;
    List<Player> newPlayers = List.from(state.players);
    newPlayers[state.currentPlayerIndex] = player.copyWith(
      turnsToSkip: player.turnsToSkip + 1, // 1 turn penalty
    );

    state = state.copyWith(players: newPlayers, consecutiveDoubles: 0);

    ref.read(dialogProvider.notifier).hidePrinterIssue();

    _addLog(
      "${player.name} yazıcı sorunu nedeniyle 1 tur ceza aldı!",
      type: 'error',
    );

    _isProcessing = false;
    endTurn();
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // 3. SORU & MASTERY SÄ°STEMÄ°
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Auto-select difficulty based on player's mastery level
  /// - Novice -> Easy
  /// - Ã‡Ä±rak -> Medium
  /// - Kalfa -> Hard
  /// - Usta -> Hard (for farming rewards)

  Future<void> _triggerQuestion(BoardTile tile) async {
    safePrint('TEST: Yüklü Soru Sayısı: ${_cachedQuestions.length}');

    final selectionResult = _questionFlowService.selectQuestion(
      tile: tile,
      player: state.currentPlayer,
      questionPool: _cachedQuestions,
      askedQuestionIds: state.askedQuestionIds,
      random: _random,
    );

    for (final log in selectionResult.logs) {
      _addLog(log.message, type: log.type);
    }

    if (selectionResult.noQuestionsFound) {
      endTurn();
      return;
    }

    if (selectionResult.isTesivkBonusFallback) {
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

      _activeTimers.add(
        Timer(
          const Duration(seconds: GameConstants.floatingEffectDurationSeconds),
          () {
            state = state.copyWith(floatingEffect: null);
          },
        ),
      );

      _addLog(
        '${player.name} Teşvik bonusu kazandı: +$bonusStars ⭐',
        type: 'success',
      );
      endTurn();
      return;
    }

    final selectedQuestion = selectionResult.question!;
    final shouldResetAskedIds = selectionResult.shouldResetAskedIds;

    // BOT MODE: Auto-answer question without showing dialog
    if (_isBotPlaying) {
      final updatedAskedIds = Set<String>.from(state.askedQuestionIds);
      updatedAskedIds.add(selectedQuestion.text);
      state = state.copyWith(
        askedQuestionIds: shouldResetAskedIds
            ? {selectedQuestion.text}
            : updatedAskedIds,
      );
      await _botController.handleQuestionTile(
        question: selectedQuestion,
        currentTile: state.currentTile,
        allPlayers: state.players,
        currentPlayerIndex: state.currentPlayerIndex,
        consecutiveDoubles: state.consecutiveDoubles,
      );
      return;
    }

    // Normal mode: Show question dialog
    _questionDialogCompleter = Completer<void>();

    final updatedAskedIds = Set<String>.from(state.askedQuestionIds);
    updatedAskedIds.add(selectedQuestion.text);

    state = state.copyWith(
      askedQuestionIds: shouldResetAskedIds
          ? {selectedQuestion.text}
          : updatedAskedIds,
    );

    ref.read(dialogProvider.notifier).showQuestion(selectedQuestion);

    _isProcessingAction = false;

    await _questionDialogCompleter!.future;

    _questionDialogCompleter = null;
  }

  Future<void> answerQuestion(bool isCorrect) async {
    // UI Race Condition Guard
    if (_isProcessingAction) return;
    _isProcessingAction = true;

    bool shouldEndTurn = false;

    try {
      safePrint('🔹 answerQuestion called: isCorrect=$isCorrect');

      final tile = state.currentTile;
      final categoryName = tile?.category;
      final difficulty = tile?.difficulty ?? Difficulty.medium;
      final actualQuestionDifficulty =
          QuestionFlowService.difficultyFromQuestionLabel(
            ref.read(dialogProvider).currentQuestion?.difficulty,
            fallback: difficulty,
          );

      final result = _questionFlowService.processAnswer(
        isCorrect: isCorrect,
        player: state.currentPlayer,
        categoryName: categoryName,
        difficulty: difficulty,
        actualQuestionDifficulty: actualQuestionDifficulty,
        allPlayers: state.players,
        currentPlayerIndex: state.currentPlayerIndex,
        consecutiveDoubles: state.consecutiveDoubles,
        random: _random,
      );

      _applyAnswerResult(result);

      if (result.checkWinCondition) {
        _checkWinCondition();
        if (state.phase != GamePhase.gameOver) {
          shouldEndTurn = true;
        }
      } else {
        shouldEndTurn = true;
      }

      safePrint('🔷 TEARDOWN: Setting showQuestionDialog=false');
      ref.read(dialogProvider.notifier).hideQuestion();
    } catch (e, stack) {
      safePrint('🔷 ERROR in answerQuestion: $e');
      safePrint('🔷 Stack: $stack');
    } finally {
      _isProcessing = false;
      _isProcessingAction = false;
      safePrint('🔷 FINALLY: _isProcessing reset to false');

      safePrint(
        '🔷 Completer status: ${_questionDialogCompleter != null ? (_questionDialogCompleter!.isCompleted ? "completed" : "pending") : "null"}',
      );
      if (_questionDialogCompleter != null &&
          !_questionDialogCompleter!.isCompleted) {
        safePrint('🔷 Completing _questionDialogCompleter NOW');
        _questionDialogCompleter!.complete();
      }
      _questionDialogCompleter = null;
      safePrint('🔷 FINALLY complete, dialog should be closed now');
    }

    if (shouldEndTurn) {
      endTurn();
    }
  }

  void _acquireTelifForCurrentBookIfEligible(BoardTile? tile, bool isCorrect) {
    if (!isCorrect || tile == null) return;

    final book = BoardBookLookupService.bookForTile(tile);
    if (book == null || state.bookOwnerships.containsKey(book.id)) return;

    final updatedOwnerships = Map<String, BookOwnership>.from(
      state.bookOwnerships,
    );
    updatedOwnerships[book.id] = BookOwnership(
      bookId: book.id,
      ownerPlayerId: state.currentPlayer.id,
      level: BookLevel.telif,
    );

    state = state.copyWith(bookOwnerships: updatedOwnerships);
    _addLog(
      'Telif alindi: ${state.currentPlayer.name} - ${book.title}',
      type: 'success',
    );
    final feedbackText = 'Telif: ${book.title}';
    state = state.copyWith(
      floatingEffect: FloatingEffect(feedbackText, Colors.amberAccent),
    );
    _activeTimers.add(
      Timer(
        const Duration(seconds: GameConstants.floatingEffectDurationSeconds),
        () {
          if (mounted && state.floatingEffect?.text == feedbackText) {
            state = state.copyWith(floatingEffect: null);
          }
        },
      ),
    );
  }

  void _upgradeOwnedTelifToBaskiIfEligible(
    BoardTile? tile,
    bool isCorrect, {
    required Map<String, BookOwnership> ownershipsBeforeAnswer,
  }) {
    if (!isCorrect || tile == null) return;

    final book = BoardBookLookupService.bookForTile(tile);
    if (book == null) return;

    final ownership = ownershipsBeforeAnswer[book.id];
    if (ownership == null ||
        ownership.ownerPlayerId != state.currentPlayer.id ||
        ownership.level != BookLevel.telif) {
      return;
    }

    if (state.currentPlayer.akce < book.baskiCostAkce) {
      _addLog(
        'Yetersiz Akce: ${book.title} Baski yukseltilemedi',
        type: 'error',
      );
      const feedbackText = 'Yetersiz Akce';
      state = state.copyWith(
        floatingEffect: FloatingEffect(feedbackText, Colors.redAccent),
      );
      _activeTimers.add(
        Timer(
          const Duration(seconds: GameConstants.floatingEffectDurationSeconds),
          () {
            if (mounted && state.floatingEffect?.text == feedbackText) {
              state = state.copyWith(floatingEffect: null);
            }
          },
        ),
      );
      return;
    }

    final result = _bookProgressionService.apply(
      book: book,
      players: state.players,
      currentPlayerId: state.currentPlayer.id,
      ownerships: state.bookOwnerships,
      isCorrect: true,
      difficulty: tile.difficulty,
    );

    if (result.actionType != BookProgressionActionType.upgradedToBaski) {
      return;
    }

    state = state.copyWith(
      players: result.updatedPlayers,
      bookOwnerships: result.updatedOwnerships,
    );
    _addLog(
      'Baski yukseltildi: ${state.currentPlayer.name} - ${book.title}',
      type: 'success',
    );
    final feedbackText = 'Baski: ${book.title}';
    state = state.copyWith(
      floatingEffect: FloatingEffect(feedbackText, Colors.lightBlueAccent),
    );
    _activeTimers.add(
      Timer(
        const Duration(seconds: GameConstants.floatingEffectDurationSeconds),
        () {
          if (mounted && state.floatingEffect?.text == feedbackText) {
            state = state.copyWith(floatingEffect: null);
          }
        },
      ),
    );
  }

  void _upgradeOwnedBaskiToCiltIfEligible(
    BoardTile? tile,
    bool isCorrect, {
    required Difficulty? answeredDifficulty,
    required Map<String, BookOwnership> ownershipsBeforeAnswer,
  }) {
    if (!isCorrect || tile == null) return;

    final book = BoardBookLookupService.bookForTile(tile);
    if (book == null) return;

    final ownership = ownershipsBeforeAnswer[book.id];
    if (ownership == null ||
        ownership.ownerPlayerId != state.currentPlayer.id ||
        ownership.level != BookLevel.baski) {
      return;
    }

    if (answeredDifficulty != Difficulty.hard) return;

    final mastery = state.currentPlayer.getMasteryLevel(book.category.name);
    if (mastery.value < MasteryLevel.kalfa.value) return;

    if (state.currentPlayer.akce < book.ciltCostAkce) {
      _addLog(
        'Yetersiz Akce: ${book.title} Cilt yukseltilemedi',
        type: 'error',
      );
      const feedbackText = 'Yetersiz Akce';
      state = state.copyWith(
        floatingEffect: FloatingEffect(feedbackText, Colors.redAccent),
      );
      _activeTimers.add(
        Timer(
          const Duration(seconds: GameConstants.floatingEffectDurationSeconds),
          () {
            if (mounted && state.floatingEffect?.text == feedbackText) {
              state = state.copyWith(floatingEffect: null);
            }
          },
        ),
      );
      return;
    }

    final result = _bookProgressionService.apply(
      book: book,
      players: state.players,
      currentPlayerId: state.currentPlayer.id,
      ownerships: state.bookOwnerships,
      isCorrect: true,
      difficulty: answeredDifficulty!,
    );

    if (result.actionType != BookProgressionActionType.upgradedToCilt) {
      return;
    }

    state = state.copyWith(
      players: result.updatedPlayers,
      bookOwnerships: result.updatedOwnerships,
    );
    _addLog(
      'Cilt yukseltildi: ${state.currentPlayer.name} - ${book.title}',
      type: 'success',
    );
    final feedbackText = 'Cilt: ${book.title}';
    state = state.copyWith(
      floatingEffect: FloatingEffect(feedbackText, Colors.deepPurpleAccent),
    );
    _activeTimers.add(
      Timer(
        const Duration(seconds: GameConstants.floatingEffectDurationSeconds),
        () {
          if (mounted && state.floatingEffect?.text == feedbackText) {
            state = state.copyWith(floatingEffect: null);
          }
        },
      ),
    );
  }

  /// Draw a card from Åžans or Kader deck
  /// Note: Currently unused - cards are handled through other mechanisms
  // ignore: unused_element
  Future<void> _drawCard(CardType cardType) async {
    await _drawCardAndApply(cardType);
  }

  /// Draw a card from Åžans or Kader deck and apply its effect
  /// For human players: Shows card dialog, effect applied when dialog is closed
  /// For bot players: Auto-applies effect without showing dialog
  Future<void> _drawCardAndApply(CardType cardType) async {
    await Future.delayed(
      _botController.getDelay(
        humanMs: GameConstants.cardAnimationDelay,
        botMs: 100,
      ),
    );

    final isSans = cardType == CardType.sans;
    final deck = isSans ? GameCards.sansCards : GameCards.kaderCards;
    final card = deck[_random.nextInt(deck.length)];
    final cardName = isSans ? "ÅžANS" : "KADER";

    // BOT MODE: Auto-apply card effect without showing dialog
    if (_isBotPlaying) {
      _addLog('🤖 Bot: $cardName kartı çekildi');
      await _botController.handleCardEffect(
        card: card,
        players: state.players,
        currentPlayerIndex: state.currentPlayerIndex,
      );
      return;
    }

    // Human mode: Show card dialog and wait for it to close
    _addLog(
      'ğŸ² ${state.currentPlayer.name} $cardName karesine geldi! Kart Ã§ekiliyor...',
    );
    AudioManager.instance.playSfx('audio/card_flip.wav');

    // Create a completer to wait
    _cardDialogCompleter = Completer<void>();
    ref.read(dialogProvider.notifier).showCard(card);

    _isProcessingAction = false;

    // Wait for the dialog to be closed (completed in closeCardDialog)
    await _cardDialogCompleter!.future;

    _cardDialogCompleter = null;
  }

  void closeCardDialog() {
    var scheduledChainedTileArrival = false;

    try {
      final card = ref.read(dialogProvider).currentCard;
      if (card != null) {
        final result = _cardEffectService.apply(
          card: card,
          players: state.players,
          currentPlayerIndex: state.currentPlayerIndex,
        );

        if (result.rollAgain) {
          for (final log in result.logs) {
            _addLog(log.message, type: log.type);
          }
          ref.read(dialogProvider.notifier).hideCard();
          if (_cardDialogCompleter != null &&
              !_cardDialogCompleter!.isCompleted) {
            _cardDialogCompleter!.complete();
          }
          _isProcessing = false;
          return;
        }

        _applyCardEffectResult(result);

        // CRITICAL FIX: After applying a movement card effect, trigger tile arrival
        if (result.movementOccurred) {
          final newPlayer = state.currentPlayer;
          if (state.tiles.isNotEmpty &&
              newPlayer.position < state.tiles.length) {
            final newTile = state.tiles[newPlayer.position];
            _logBot(
              'Card moved player to ${newTile.name} (${newTile.type}) - triggering tile arrival',
            );
            scheduledChainedTileArrival = true;
            Future.microtask(() async {
              await _handleTileArrival(newTile);
            });
          }
        }
      }
      ref.read(dialogProvider.notifier).hideCard();

      if (_cardDialogCompleter != null && !_cardDialogCompleter!.isCompleted) {
        _cardDialogCompleter!.complete();
      }

      _isProcessing = false;

      if (!scheduledChainedTileArrival) {
        endTurn();
      }
    } finally {
      // Release action guard
      _isProcessingAction = false;
    }
  }

  void _applyCardEffectResult(CardEffectResult result) {
    state = state.copyWith(players: result.updatedPlayers);
    for (final log in result.logs) {
      _addLog(log.message, type: log.type);
    }
    if (result.showFloatingEffect &&
        result.starsDelta != null &&
        result.starsDelta != 0) {
      final sign = result.starsDelta! > 0 ? '+' : '';
      final color = result.starsDelta! > 0
          ? Colors.greenAccent
          : Colors.redAccent;
      state = state.copyWith(
        floatingEffect: FloatingEffect('$sign${result.starsDelta}', color),
      );
    }
    if (result.showPrinterIssue) {
      ref.read(dialogProvider.notifier).showPrinterIssue();
    }
  }

  void _applyAnswerResult(AnswerResult result) {
    List<Player> newPlayers = List.from(state.players);
    newPlayers[state.currentPlayerIndex] = result.updatedPlayer;
    final ownershipsBeforeAnswer = state.bookOwnerships;
    state = state.copyWith(players: newPlayers);
    for (final log in result.logs) {
      _addLog(log.message, type: log.type);
    }
    _acquireTelifForCurrentBookIfEligible(state.currentTile, result.wasCorrect);
    _upgradeOwnedTelifToBaskiIfEligible(
      state.currentTile,
      result.wasCorrect,
      ownershipsBeforeAnswer: ownershipsBeforeAnswer,
    );
    _upgradeOwnedBaskiToCiltIfEligible(
      state.currentTile,
      result.wasCorrect,
      answeredDifficulty: result.answeredDifficulty,
      ownershipsBeforeAnswer: ownershipsBeforeAnswer,
    );
  }

  void closeDialogs() {
    ref.read(dialogProvider.notifier).hideCard();
    endTurn();
  }

  void endGame() {
    if (state.players.isEmpty) return;

    Player winner = state.players.reduce(
      (curr, next) => curr.stars > next.stars ? curr : next,
    );

    state = state.copyWith(winner: winner, phase: GamePhase.gameOver);
    _addLog("ğŸ† OYUN BÄ°TTÄ°! Kazanan: ${winner.name}", type: 'gameover');
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
      await Future.delayed(
        _botController.getDelay(
          humanMs: GameConstants.turnChangeDelay,
          botMs: 200,
        ),
      );
      int next = (state.currentPlayerIndex + 1) % state.players.length;
      final nextPlayer = state.players[next];
      bool isSkipped = nextPlayer.turnsToSkip > 0;
      final leaderStars = state.players
          .map((p) => p.stars)
          .reduce((a, b) => a > b ? a : b);
      final turnEndCompressionBonus = computeLeadCompressionTurnBonus(
        currentStars: nextPlayer.stars,
        leaderStars: leaderStars,
        isSkipped: isSkipped,
      );

      ref.read(dialogProvider.notifier).hideCard();

      if (state.consecutiveDoubles > 0) {
        _addLog(
          "Çift atıldığı için sıra tekrar ${state.currentPlayer.name} oyuncusunda!",
          type: 'turn',
        );
        state = state.copyWith(isDiceRolled: false, isDoubleTurn: true);
      } else {
        if (isSkipped) {
          _addLog("${nextPlayer.name} cezalı! Tur atlanıyor.", type: 'error');
        } else {
          _addLog("Sıra ${nextPlayer.name} oyuncusunda.", type: 'turn');
        }

        state = state.copyWith(
          currentPlayerIndex: next,
          isDiceRolled: false,
          isDoubleTurn: false,
        );

        if (turnEndCompressionBonus > 0) {
          final boostedPlayers = List<Player>.from(state.players);
          final boosted = boostedPlayers[next].copyWith(
            stars: boostedPlayers[next].stars + turnEndCompressionBonus,
          );
          boostedPlayers[next] = boosted;
          state = state.copyWith(players: boostedPlayers);
          _addLog(
            "🔄 Recenter: ${boosted.name} +$turnEndCompressionBonus ⭐ (catch-up)",
            type: 'success',
          );
        }

        if (isSkipped) {
          Future.microtask(_handleSkippedTurnEntry);
        } else if (_isBotPlaying) {
          _scheduleBotTurn();
        }
      }

      _logBot(
        'endTurn() COMPLETED - next: ${nextPlayer.name}, skipped: $isSkipped',
      );
    } catch (e, stackTrace) {
      safePrint('ğŸš¨ ERROR in endTurn: $e');
      safePrint('Stack trace: $stackTrace');
      _logBot('ğŸš¨ ERROR in endTurn: $e');
      _scheduleBotTurn();
    } finally {
      _isProcessing = false;
      _logBot('endTurn() finally - _isProcessing reset to false');
    }
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // BOT MODE METHODS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Toggle bot mode on/off — delegates to BotController.
  /// BotController handles state flip, logs, and initial scheduling.
  /// Subsequent scheduling still uses GameNotifier's _scheduleBotTurn for now.
  void toggleBotMode() {
    _botController.toggle();
    if (_botController.isActive) {
      _scheduleBotTurn();
    } else {
      _cancelWatchdog();
      for (final timer in _activeTimers) {
        timer.cancel();
      }
      _activeTimers.clear();
      _isProcessing = false;
      _isProcessingAction = false;
      state = state.copyWith(isDiceRolling: false, isDiceRolled: false);
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
    _activeTimers.add(
      Timer(
        const Duration(milliseconds: GameConstants.botTurnScheduleDelay),
        () {
          if (_isBotPlaying && state.phase != GamePhase.gameOver) {
            _logBot('_scheduleBotTurn() executing check...');
            // Check if any dialogs are open
            if (!ref.read(dialogProvider).showQuestionDialog &&
                !ref.read(dialogProvider).showCardDialog &&
                !ref.read(dialogProvider).showLibraryPenaltyDialog &&
                !ref.read(dialogProvider).showImzaGunuDialog &&
                !ref.read(dialogProvider).showShopDialog &&
                !ref.read(dialogProvider).showTurnOrderDialog &&
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
        },
      ),
    );
  }

  /// Handle dialogs in bot mode - auto-close them
  void _handleBotDialog() async {
    if (!_isBotPlaying) return;

    _logBot('_handleBotDialog() - checking dialogs...');
    await Future.delayed(const Duration(milliseconds: 500));

    if (ref.read(dialogProvider).showTurnOrderDialog) {
      _logBot('Closing TurnOrderDialog');
      closeTurnOrderDialog();
      _scheduleBotTurn();
    } else if (ref.read(dialogProvider).showLibraryPenaltyDialog) {
      _logBot('Closing LibraryPenaltyDialog');
      closeLibraryPenaltyDialog();
    } else if (ref.read(dialogProvider).showImzaGunuDialog) {
      _logBot('Closing ImzaGunuDialog');
      closeImzaGunuDialog();
    } else if (ref.read(dialogProvider).showPrinterIssueDialog) {
      _logBot('Closing PrinterIssueDialog');
      closePrinterIssueDialog();
    } else if (ref.read(dialogProvider).showTurnSkippedDialog) {
      _logBot('Closing TurnSkippedDialog');
      closeTurnSkippedDialog();
    } else if (ref.read(dialogProvider).showShopDialog) {
      _logBot('Closing ShopDialog');
      // Bot doesn't buy quotes, just close the shop
      closeShopDialog();
    } else if (ref.read(dialogProvider).showQuestionDialog) {
      _logBot('Closing QuestionDialog with random answer');
      answerQuestion(_random.nextBool());
    } else if (ref.read(dialogProvider).showCardDialog) {
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
    ref.read(dialogProvider.notifier).hideTurnSkipped();
  }

  Future<void> _handleSkippedTurnEntry() async {
    if (state.phase != GamePhase.playerTurn ||
        state.currentPlayer.turnsToSkip <= 0) {
      if (_isBotPlaying) {
        _scheduleBotTurn();
      }
      return;
    }

    final player = state.currentPlayer;
    final remaining = player.turnsToSkip - 1;
    final newPlayers = List<Player>.from(state.players);
    newPlayers[state.currentPlayerIndex] = player.copyWith(
      turnsToSkip: remaining,
    );
    state = state.copyWith(players: newPlayers, isDiceRolled: false);

    if (remaining > 0) {
      _addLog(
        "📚 ${player.name} Kütüphanede! Kalan ceza turu: $remaining",
        type: 'error',
      );
    } else {
      _addLog(
        "✅ ${player.name} Kütüphane cezasını tamamladı! Sıradaki turda zar atabilir.",
        type: 'success',
      );
    }

    ref.read(dialogProvider.notifier).showTurnSkipped();

    await Future.delayed(
      _botController.getDelay(
        humanMs: GameConstants.turnSkippedDialogAutoCloseDelay,
        botMs: 450,
      ),
    );

    if (!mounted || !ref.read(dialogProvider).showTurnSkippedDialog) return;

    closeTurnSkippedDialog();
    endTurn();
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // SHOP (KIRAATHANE) METHODS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  Future<void> openShopDialog() async {
    // BOT MODE: Auto-close dialog after short delay
    if (_isBotPlaying) {
      ref.read(dialogProvider.notifier).showShop();
      _addLog('ğŸ¤– Bot: KÄ±raathane\'ye hoÅŸ geldiniz!', type: 'info');
      _botController.handleDialogTile(BotDialogType.shop);
      return;
    }

    // Human mode: Create completer to wait for dialog closure (Async Barrier)
    _shopDialogCompleter = Completer<void>();
    ref.read(dialogProvider.notifier).showShop();
    _addLog('Kıraathane\'ye hoş geldiniz!', type: 'info');

    _isProcessingAction = false;

    // Await the completer to wait for user to close dialog
    await _shopDialogCompleter!.future;

    _shopDialogCompleter = null;
  }

  void closeShopDialog() {
    ref.read(dialogProvider.notifier).hideShop();

    // Complete the completer if waiting for dialog to close
    if (_shopDialogCompleter != null && !_shopDialogCompleter!.isCompleted) {
      _shopDialogCompleter!.complete();
    }

    _isProcessing = false;
    // Always end turn after closing shop (whether purchase was made or not)
    endTurn();
  }

  void purchaseQuote(String quoteId, int cost) {
    final player = state.currentPlayer;

    if (player.collectedQuotes.contains(quoteId)) {
      _addLog('Bu sÃ¶z zaten koleksiyonunda!', type: 'error');
      return;
    }

    if (player.stars < cost) {
      _addLog('Yeterli yÄ±ldÄ±zÄ±n yok!', type: 'error');
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
    _addLog('SÃ¶z satÄ±n alÄ±ndÄ±! (-$cost â­)', type: 'purchase');

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

      _addLog('ğŸ† ${player.name} EHÄ°L oldu! Oyun bitti!', type: 'gameover');
    }
  }

  /// DEBUG: Instantly trigger win for current player
  /// Sets all 6 categories to Hard (Usta) and gives 50 dummy quotes
  void debugTriggerWin() {
    final player = state.currentPlayer;

    safePrint('ğŸ† DEBUG: Triggering Instant Win for ${player.name}');

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
      'ğŸ† DEBUG: ${player.name} EHÄ°L oldu! (Instant Win Triggered)',
      type: 'gameover',
    );
  }

  Future<void> handleKiraathaneLanding() async {
    await openShopDialog();
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // LOGGING
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

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
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();
    _cancelWatchdog();
    _botController.dispose();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>(
  (ref) => GameNotifier(ref),
);
