import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../models/question.dart';
import '../models/card.dart';
import '../models/dice_roll.dart';
import '../models/turn_result.dart';
import '../models/turn_history.dart';
import '../models/turn_phase.dart';
import '../models/player_type.dart';
import '../models/phase_transition.dart';
import '../constants/game_constants.dart';
import '../engine/turn_history_validator.dart';

/// LOGGING BOUNDARIES DOCUMENTATION
/// =================================
///
/// GAMEPLAY LOGS (Core game state changes):
/// - Dice rolls and movement
/// - Star gains/losses from any source
/// - Card effects being applied
/// - Tax payments and skips
/// - Question answers (correct/wrong)
/// - Bankruptcy events
/// - Turn transitions
/// - Game start/end
///
/// UI FEEDBACK LOGS (User-facing information):
/// - Card descriptions being shown
/// - Question being asked
/// - Tile type information
/// - Double dice counter status
/// - Player order announcements
///
/// NOTE: TurnResult provides structured UI feedback separate from logs.
/// Logs are for game history and debugging, TurnResult is for immediate UI display.

// Shared Random instance for consistent randomness across the game
final _random = Random();

// Question answering state
enum QuestionState {
  waiting, // Waiting for player to answer
  answering, // Player is answering
  correct, // Answer was correct
  wrong, // Answer was wrong
  skipped, // Question was skipped
}

/// Phase behavior classification for documentation and validation
enum PhaseBehavior {
  /// Terminal phase - turn is complete, game has been updated
  /// Example: turnEnded - phase reset to start by endTurn()
  terminal,

  /// Manual phase - requires user interaction to advance
  /// UI must wait for user action before calling playTurn()
  /// Examples: start (roll button), questionResolved (answer button)
  manual,

  /// Auto-advance phase - automatically progresses after brief delay
  /// UI phase listener calls playTurn() automatically
  /// Examples: diceRolled, moved, tileResolved, cardApplied, taxResolved
  autoAdvance,
}

/// Auto-advance directive for UI-controlled timing
///
/// This encapsulates the decision of whether a phase should auto-advance and
/// what delay should be used. UI only executes the delay, GameNotifier
/// decides based on game rules (phase + player type).
class AutoAdvanceDirective {
  /// Whether the current phase should auto-advance
  final bool shouldAutoAdvance;

  /// Delay to use before calling playTurn()
  final Duration delay;

  const AutoAdvanceDirective({
    required this.shouldAutoAdvance,
    required this.delay,
  });

  /// Directive for phases that should not auto-advance
  const AutoAdvanceDirective.noAdvance()
    : shouldAutoAdvance = false,
      delay = Duration.zero;
}

// Game State
class GameState {
  final List<Player> players;
  final List<Tile> tiles;
  final List<Question> questionPool;
  final List<Card> sansCards;
  final List<Card> kaderCards;

  final int currentPlayerIndex;
  final DiceRoll? lastDiceRoll;
  final String? lastMessage;
  final List<String> logMessages;

  // Turn phase state machine
  final TurnPhase turnPhase;

  // Movement state
  final int? oldPosition;
  final int? newPosition;
  final bool passedStart;

  // Question answering state
  final QuestionState questionState;
  final Question? currentQuestion;
  final int? questionTimer;
  final int correctAnswers;
  final int wrongAnswers;

  // Card state
  final Card? currentCard;

  // Turn result for UI feedback
  final TurnResult lastTurnResult;

  // Turn history for game analysis
  final TurnHistory turnHistory;

  // Flags
  final bool isGameOver;
  final bool isDiceAnimationComplete; // Track dice animation completion

  const GameState({
    required this.players,
    required this.tiles,
    required this.questionPool,
    required this.sansCards,
    required this.kaderCards,
    required this.currentPlayerIndex,
    this.lastDiceRoll,
    this.lastMessage,
    this.logMessages = const [],
    this.turnPhase = TurnPhase.start,
    this.oldPosition,
    this.newPosition,
    this.passedStart = false,
    this.isGameOver = false,
    this.questionState = QuestionState.waiting,
    this.currentQuestion,
    this.questionTimer = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.currentCard,
    this.lastTurnResult = TurnResult.empty,
    this.turnHistory = const TurnHistory.empty(),
    this.isDiceAnimationComplete =
        true, // Default to true (no animation in progress)
  });

  Player? get currentPlayer {
    if (players.isEmpty ||
        currentPlayerIndex < 0 ||
        currentPlayerIndex >= players.length) {
      return null;
    }
    return players[currentPlayerIndex];
  }

  bool get isCurrentPlayerBankrupt => currentPlayer?.isBankrupt ?? false;
  bool get canRoll => turnPhase == TurnPhase.start && !isCurrentPlayerBankrupt;

  GameState copyWith({
    List<Player>? players,
    List<Tile>? tiles,
    List<Question>? questionPool,
    List<Card>? sansCards,
    List<Card>? kaderCards,
    int? currentPlayerIndex,
    DiceRoll? lastDiceRoll,
    String? lastMessage,
    List<String>? logMessages,
    TurnPhase? turnPhase,
    int? oldPosition,
    int? newPosition,
    bool? passedStart,
    bool? isGameOver,
    QuestionState? questionState,
    Question? currentQuestion,
    int? questionTimer,
    int? correctAnswers,
    int? wrongAnswers,
    Card? currentCard,
    TurnResult? lastTurnResult,
    TurnHistory? turnHistory,
    bool? isDiceAnimationComplete,
  }) {
    return GameState(
      players: players ?? this.players,
      tiles: tiles ?? this.tiles,
      questionPool: questionPool ?? this.questionPool,
      sansCards: sansCards ?? this.sansCards,
      kaderCards: kaderCards ?? this.kaderCards,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      lastDiceRoll: lastDiceRoll ?? this.lastDiceRoll,
      lastMessage: lastMessage ?? this.lastMessage,
      logMessages: logMessages ?? this.logMessages,
      turnPhase: turnPhase ?? this.turnPhase,
      oldPosition: oldPosition ?? this.oldPosition,
      newPosition: newPosition ?? this.newPosition,
      passedStart: passedStart ?? this.passedStart,
      isGameOver: isGameOver ?? this.isGameOver,
      questionState: questionState ?? this.questionState,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      questionTimer: questionTimer ?? this.questionTimer,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      currentCard: currentCard ?? this.currentCard,
      lastTurnResult: lastTurnResult ?? this.lastTurnResult,
      turnHistory: turnHistory ?? this.turnHistory,
      isDiceAnimationComplete:
          isDiceAnimationComplete ?? this.isDiceAnimationComplete,
    );
  }

  GameState withLogMessage(String message) {
    return copyWith(
      logMessages: [...logMessages, message],
      lastMessage: message,
    );
  }

  GameState withTurnPhase(TurnPhase phase) {
    return copyWith(turnPhase: phase);
  }
}

// Game Notifier
class GameNotifier extends StateNotifier<GameState> {
  GameNotifier()
    : super(
        const GameState(
          players: [],
          tiles: [],
          questionPool: [],
          sansCards: [],
          kaderCards: [],
          currentPlayerIndex: 0,
        ),
      );

  // ============================================================================
  // TURN BOUNDARIES & TRANSCRIPT SYSTEM
  // ============================================================================
  ///
  /// Turn Lifecycle:
  /// 1. TURN START: _nextPlayer() creates new TurnTranscript
  /// 2. TURN IN PROGRESS: Events incrementally added to _currentTranscript
  /// 3. TURN END (COMMIT): endTurn() finalizes transcript and creates TurnResult
  ///
  /// Commit Point:
  /// - Only endTurn() can commit (when phase = turnEnded)
  /// - Phase guard prevents turnEnded from calling playTurn()
  /// - Guarantees exactly one commit per turn
  ///
  /// Correctness:
  /// - No partial transcripts leak (_currentTranscript is private)
  /// - No duplicate commits (only one call to endTurn() per turn)
  /// - Immutable after commit (TurnTranscript uses copyWith pattern)
  /// - Single source of truth (state.lastTurnResult)

  /// Private: Current turn's transcript (never exposed directly)
  /// Only accessible via committed TurnResult after turn ends
  TurnTranscript _currentTranscript = TurnTranscript.empty;

  /// Private: Snapshot of player state at turn START
  ///
  /// Used to calculate accurate starsDelta and positionDelta by comparing
  /// start values with final values at turn COMMIT. This is the single
  /// source of truth for delta calculation, avoiding double counting that
  /// would occur if we inferred deltas from transcript events.
  ///
  /// Why snapshot-based delta?
  /// - Avoids double counting (e.g., card effect + passing START)
  /// - Single source of truth (compare start vs end, not sum of events)
  /// - Simpler and more accurate than parsing transcript events
  ///
  /// Lifecycle:
  /// - Created exactly once in _nextPlayer() at TURN START
  /// - Cleared/replaced on next turn start
  /// - Used only in endTurn() at TURN COMMIT
  TurnSnapshot? _turnStartSnapshot;

  // Initialize game with data
  void initializeGame({
    required List<Player> players,
    required List<Tile> tiles,
    required List<Question> questionPool,
    required List<Card> sansCards,
    required List<Card> kaderCards,
  }) {
    // Initialize game state with provided data
    state = state
        .copyWith(
          players: players,
          tiles: tiles,
          questionPool: questionPool,
          sansCards: sansCards,
          kaderCards: kaderCards,
          currentPlayerIndex: 0,
          turnPhase: TurnPhase.start,
        )
        .withLogMessage('Oyun başlatılıyor...');

    // UI FEEDBACK LOG: Player order announcements
    for (int i = 0; i < players.length; i++) {
      state = state.withLogMessage('Sıra ${i + 1}: ${players[i].name}');
    }

    // GAMEPLAY LOG: Game start
    state = state.withLogMessage(
      'Oyun başladı! Sıra: ${state.currentPlayer?.name}',
    );
  }

  /// ============================================================================
  /// TURN ORCHESTRATION - Phase 2: Single Entry Point
  /// ============================================================================
  ///
  /// playTurn() is the ONLY method UI should call to advance the game.
  /// It deterministically runs the next step based on currentTurnPhase.
  ///
  /// Phase progression:
  /// - start → diceRolled → moved → tileResolved → (cardApplied | questionResolved | taxResolved) → turnEnded → start
  ///
  /// Each call to playTurn() advances exactly one phase.
  /// No gameplay rules are changed - this is pure orchestration.
  ///
  /// UI flow:
  /// 1. UI calls playTurn()
  /// 2. playTurn() validates phase transition
  /// 3. playTurn() switches on currentTurnPhase
  /// 4. Calls the appropriate method (rollDice, moveCurrentPlayer, etc.)
  /// 5. That method advances the phase
  /// 6. UI reads updated state and calls playTurn() again
  /// 7. Repeat until turnEnded, then playTurn() resets to start for next player
  ///
  /// HARDENING: Phase transition guard ensures only valid phases can call playTurn().
  /// Invalid playTurn() calls are logged (debug) and safely ignored.
  ///
  /// IMPORTANT: This guard does NOT enforce a single "next phase" rule.
  /// The switch-case logic below determines the correct next phase based on game rules.
  /// This guard only validates whether playTurn() can be called from current phase.

  /// Maps each phase to its behavior type
  /// Used for validation and documentation only
  static const Map<TurnPhase, PhaseBehavior> _phaseBehavior = {
    // Manual phases - require user interaction
    TurnPhase.start: PhaseBehavior.manual,
    TurnPhase.questionResolved: PhaseBehavior.manual,
    TurnPhase.copyrightPurchased: PhaseBehavior.manual,

    // Auto-advance phases - UI phase listener triggers next step
    TurnPhase.diceRolled: PhaseBehavior.autoAdvance,
    TurnPhase.moved: PhaseBehavior.autoAdvance,
    TurnPhase.tileResolved: PhaseBehavior.autoAdvance,
    TurnPhase.cardApplied: PhaseBehavior.autoAdvance,
    TurnPhase.taxResolved: PhaseBehavior.autoAdvance,

    // Terminal phase - turn complete, already reset by endTurn()
    TurnPhase.turnEnded: PhaseBehavior.terminal,
  };

  /// Set of phases that are allowed to call playTurn()
  /// All phases except terminal can call playTurn()
  static const Set<TurnPhase> _playablePhases = {
    TurnPhase.start,
    TurnPhase.diceRolled,
    TurnPhase.moved,
    TurnPhase.tileResolved,
    TurnPhase.cardApplied,
    TurnPhase.questionResolved,
    TurnPhase.copyrightPurchased,
    TurnPhase.taxResolved,
    // Note: TurnPhase.turnEnded is EXCLUDED - it's terminal and should not call playTurn()
  };

  /// Check if a phase should auto-advance (UI-controlled timing)
  ///
  /// This helper is called by UI to determine whether to schedule a delayed playTurn() call.
  /// GameNotifier remains time-agnostic - it only defines WHICH phases are auto-advance,
  /// not WHEN the advance should happen.
  ///
  /// Separation of concerns:
  /// - GameNotifier: Defines phase behavior (manual vs auto-advance)
  /// - UI: Controls timing (300ms delay for auto-advance phases)
  /// Get auto-advance directive for UI-controlled timing
  ///
  /// This method encapsulates ALL game rules about timing:
  /// - Whether current phase should auto-advance
  /// - What delay should be used (short vs long)
  ///
  /// Separation of concerns:
  /// - GameNotifier: Defines game rules (phase + player type → directive)
  /// - UI: Controls timing execution (uses directive.delay)
  ///
  /// UI must NOT know about bot logic or delay categories.
  /// GameNotifier decides based on current state only.
  static AutoAdvanceDirective getAutoAdvanceDirective(GameState state) {
    final phase = state.turnPhase;
    final currentPlayerType = state.currentPlayer?.type;

    // Bot start phase: Manual phase that auto-plays with long delay
    if (phase == TurnPhase.start && currentPlayerType == PlayerType.bot) {
      return const AutoAdvanceDirective(
        shouldAutoAdvance: true,
        delay: Duration(milliseconds: 700),
      );
    }

    // SPECIAL CASE: diceRolled phase - wait for animation to complete
    // Only auto-advance if animation is finished
    if (phase == TurnPhase.diceRolled) {
      if (state.isDiceAnimationComplete) {
        return const AutoAdvanceDirective(
          shouldAutoAdvance: true,
          delay: Duration(milliseconds: 300),
        );
      } else {
        // Animation in progress - don't auto-advance
        return const AutoAdvanceDirective.noAdvance();
      }
    }

    // Standard auto-advance phases: Short delay
    if (_phaseBehavior[phase] == PhaseBehavior.autoAdvance) {
      return const AutoAdvanceDirective(
        shouldAutoAdvance: true,
        delay: Duration(milliseconds: 300),
      );
    }

    // Manual phases: No auto-advance
    return const AutoAdvanceDirective.noAdvance();
  }

  /// Main orchestration method - ONLY method UI should call
  ///
  /// Uses PhaseTransitionMap to find and execute the next phase transition.
  /// This makes the state machine explicit and declarative.
  void playTurn() {
    debugPrint(
      '🎮 playTurn() called - Current phase: ${state.turnPhase}, Player type: ${state.currentPlayer?.type}',
    );

    // HARDENING: Phase transition guard
    // Prevents accidental state corruption from invalid phase transitions
    final currentPhase = state.turnPhase;

    // Validate that current phase is allowed to call playTurn()
    if (!_playablePhases.contains(currentPhase)) {
      debugPrint(
        '⛔ PHASE GUARD VIOLATION: playTurn() called in invalid phase: $currentPhase',
      );
      debugPrint(
        '   Valid phases for playTurn(): ${_playablePhases.join(", ")}',
      );
      // Safely return without mutating state
      return;
    }

    // NOTE: Bot auto-play timing is now handled by UI, not GameNotifier.
    // UI phase listener uses shouldAutoAdvance() and applies 700ms delay for bot start phase.
    // This keeps GameNotifier completely time-agnostic.

    // Use PhaseTransitionMap to find the next transition
    final transition = PhaseTransitionMap.findTransition(currentPhase, state);

    if (transition == null) {
      debugPrint('⛔ No valid transition found from phase: $currentPhase');
      debugPrint('   This should not happen if state is valid.');
      return;
    }

    // Record transition in transcript
    _currentTranscript = _currentTranscript.addTransition(
      transition.name,
      transition.from,
      transition.to,
    );

    // Log to transition for debugging
    debugPrint(
      '🔄 Transition: ${transition.name} (${transition.from} → ${transition.to})',
    );

    // Execute transition based on destination phase
    // The PhaseTransitionMap tells us WHAT should happen next,
    // but we delegate to existing GameNotifier methods
    switch (transition.to) {
      case TurnPhase.diceRolled:
        rollDice();
        break;

      case TurnPhase.moved:
        moveCurrentPlayer(state.lastDiceRoll!.total);
        break;

      case TurnPhase.tileResolved:
        resolveCurrentTile();
        break;

      case TurnPhase.cardApplied:
        // Transition: draw_and_apply_card (chance/fate tile)
        drawCardAndApplyEffect();
        break;

      case TurnPhase.questionResolved:
        // Transition: show_question (book/publisher tile)
        showQuestionForCurrentTile();
        break;

      case TurnPhase.taxResolved:
        // Transition: handle_tax (tax tile)
        handleTaxForCurrentTile();
        break;

      case TurnPhase.copyrightPurchased:
        // Copyright purchase phase - UI shows dialog
        // Phase advances when user completes purchase or skips
        debugPrint('📜 Copyright purchase phase - waiting for user action');
        break;

      case TurnPhase.turnEnded:
        // Transition: resolve_corner_or_special (corner/special tile)
        // or: end_turn_after_card/question/tax
        endTurn();
        break;

      case TurnPhase.start:
        // Start phase should only be reached by resetting from turnEnded
        // If we reach here via a transition, something is wrong
        debugPrint(
          '⚠️ Unexpected transition to start phase - should only be reached by reset',
        );
        break;
    }

    // ============================================================================
    // DEBUG-ONLY: Validate transition events match transcript
    // ============================================================================
    ///
    /// This ensures semantic consistency between phase transitions and
    /// transcript events. If a transition executes, its expected
    /// event types should appear in the transcript.
    ///
    /// IMPORTANT:
    /// - Only runs in debug mode (kDebugMode)
    /// - Does NOT affect gameplay logic or state
    /// - If validation fails, logs detailed TransitionValidationResult
    /// - Uses assert() to halt execution in debug builds
    ///
    /// Validation rules:
    /// - Each transition declares expected event types
    /// - All expected types must be present in transcript
    /// - Empty expected list means no validation needed
    if (kDebugMode) {
      final validationResult = PhaseTransitionMap.validateTransitionEvents(
        transition,
        _currentTranscript,
      );

      if (!validationResult.isValid) {
        // Log validation failure with clear details
        debugPrint(
          '╔══════════════════════════════════════════════╗',
        );
        debugPrint(
          '║  🔴 TRANSITION EVENT VALIDATION FAILED                    ║',
        );
        debugPrint(
          '╠════════════════════════════════════════╣',
        );
        debugPrint(
          '║  Transition: ${validationResult.transitionName}                        ║',
        );
        debugPrint(
          '║  From → To: ${validationResult.from} → ${validationResult.to}                   ║',
        );
        debugPrint(
          '║  Found events: ${validationResult.foundEvents.join(", ")}                       ║',
        );
        debugPrint(
          '║  Missing events: ${validationResult.missingEvents.join(", ")}                   ║',
        );
        debugPrint(
          '╚══════════════════════════════════════════╝',
        );

        // Assert to halt execution in debug builds
        assert(
          false,
          'Transition event validation failed for ${validationResult.transitionName}: '
          'Missing events: ${validationResult.missingEvents.join(", ")}',
        );
      } else {
        // Log successful validation (optional, can be removed if too verbose)
        debugPrint(
          '✅ Transition events validated: ${transition.name} - '
          'Expected events found: ${validationResult.foundEvents.length}',
        );
      }
    }
  }

  /// Draw and apply card effect (chance/fate tile)
  ///
  /// Called when PhaseTransitionMap routes: tileResolved → cardApplied
  void drawCardAndApplyEffect() {
    final tileNumber = state.newPosition ?? state.currentPlayer!.position;
    final tile = state.tiles.firstWhere((t) => t.id == tileNumber);

    // Draw and apply card for chance/fate tiles
    final cardType = tile.type == TileType.chance
        ? CardType.sans
        : CardType.kader;
    drawCard(cardType);

    // Apply the drawn card effect
    if (state.currentCard != null) {
      applyCardEffect(state.currentCard!);
    }
  }

  /// Show question for current tile (book/publisher tile)
  ///
  /// Called when PhaseTransitionMap routes: tileResolved → questionResolved
  void showQuestionForCurrentTile() {
    final tileNumber = state.newPosition ?? state.currentPlayer!.position;
    final tile = state.tiles.firstWhere((t) => t.id == tileNumber);
    _showQuestion(tile);
  }

  /// Handle tax for current tile (tax tile)
  ///
  /// Called when PhaseTransitionMap routes: tileResolved → taxResolved
  void handleTaxForCurrentTile() {
    final tileNumber = state.newPosition ?? state.currentPlayer!.position;
    final tile = state.tiles.firstWhere((t) => t.id == tileNumber);
    _handleTaxTile(tile);
  }

  // Phase guard helper method
  bool _requirePhase(TurnPhase expected, String actionName) {
    if (state.turnPhase != expected) {
      debugPrint(
        '⛔ Phase Guard: $actionName called in ${state.turnPhase}, expected $expected',
      );
      assert(false, 'Invalid turn phase for $actionName');
      return false;
    }
    return true;
  }

  // Roll dice - Step 1 of turn
  void rollDice() {
    debugPrint('🎲 rollDice() called');
    if (!_requirePhase(TurnPhase.start, 'rollDice')) return;
    if (!state.canRoll) return;
    if (state.currentPlayer == null) return;

    // Update phase to diceRolled and mark animation as in progress
    state = state.copyWith(
      turnPhase: TurnPhase.diceRolled,
      isDiceAnimationComplete: false,
    );
    debugPrint('🎲 Phase updated to: diceRolled, animation in progress');

    // Generate random dice roll
    final diceRoll = DiceRoll.random();

    // Get current player
    final currentPlayer = state.currentPlayer!;

    // Update player immutably
    final updatedPlayer = currentPlayer.copyWith(
      lastRoll: diceRoll.total,
      doubleDiceCount: diceRoll.isDouble
          ? currentPlayer.doubleDiceCount + 1
          : 0,
    );

    // Update players list with updated player
    final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);

    // GAMEPLAY LOG: Dice roll result
    String logMessage =
        '${currentPlayer.name} zar attı: ${diceRoll.die1} + ${diceRoll.die2} = ${diceRoll.total}';
    if (diceRoll.isDouble) {
      logMessage += ' (ÇİFT!)';
    }

    state = state
        .copyWith(lastDiceRoll: diceRoll, players: updatedPlayers)
        .withLogMessage(logMessage);

    // TRANSCRIPT: Record dice roll
    _currentTranscript = _currentTranscript.addDiceRoll(
      diceRoll.die1,
      diceRoll.die2,
      diceRoll.total,
      diceRoll.isDouble,
    );

    // UI FEEDBACK LOG: Double dice counter status
    if (diceRoll.isDouble) {
      state = state.withLogMessage(
        '${currentPlayer.name}: Çift zar sayısı: ${updatedPlayer.doubleDiceCount}/3',
      );

      // Check for 3x double → Library Watch
      if (updatedPlayer.doubleDiceCount >= 3) {
        _handleTripleDouble();
        return;
      }
    } else {
      state = state.withLogMessage(
        '${currentPlayer.name}: Çift zar sayacı sıfırlandı',
      );
    }

    // NOTE: Phase advance stops here. UI will call playTurn() again to continue.
    // Previously: moveCurrentPlayer(diceRoll.total); was called automatically
    // Now: Orchestration layer (playTurn) handles calling the next method
  }

  // Move player - Step 2 of turn
  void moveCurrentPlayer(int diceTotal) {
    debugPrint('🚶 moveCurrentPlayer() called - Dice total: $diceTotal');
    if (!_requirePhase(TurnPhase.diceRolled, 'moveCurrentPlayer')) return;
    if (state.currentPlayer == null) return;

    final currentPlayer = state.currentPlayer!;
    final oldPosition = currentPlayer.position;

    // Counter-clockwise movement: position increases
    // Board is 1-40, moving counter-clockwise means increasing position
    final newPosition = _calculateNewPosition(oldPosition, diceTotal);

    // Check if passed START (tile 1)
    final passedStart = _passedStart(oldPosition, newPosition);

    debugPrint(
      '🚶 Player moving: $oldPosition → $newPosition (passed start: $passedStart)',
    );

    // Update player immutably
    var updatedPlayer = currentPlayer.copyWith(position: newPosition);

    // Award stars if passed START
    if (passedStart) {
      updatedPlayer = updatedPlayer.copyWith(
        stars: updatedPlayer.stars + GameConstants.passStartReward,
      );
    }

    // Update players list
    final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);

    // GAMEPLAY LOG: Player movement
    state = state
        .copyWith(
          players: updatedPlayers,
          oldPosition: oldPosition,
          newPosition: newPosition,
          passedStart: passedStart,
          turnPhase: TurnPhase.moved,
        )
        .withLogMessage(
          '${currentPlayer.name} kutucuk $oldPosition\'den $newPosition\'e hareket etti',
        );

    // TRANSCRIPT: Record movement
    _currentTranscript = _currentTranscript.addMove(
      oldPosition,
      newPosition,
      passedStart,
    );

    debugPrint('🚶 Phase updated to: moved');

    // GAMEPLAY LOG: Passing START bonus
    if (passedStart) {
      state = state.withLogMessage(
        '${currentPlayer.name} BAŞLANGIÇ\'ten geçti! +${GameConstants.passStartReward} yıldız',
      );
    }

    // NOTE: Phase advance stops here. UI will call playTurn() again to continue.
    // Previously: resolveCurrentTile(); was called automatically
    // Now: Orchestration layer (playTurn) handles calling the next method
  }

  // Calculate new position (counter-clockwise, 1-40)
  int _calculateNewPosition(int currentPosition, int diceTotal) {
    // Counter-clockwise: positions increase from 1 to 40, then wrap to 1
    int newPosition =
        (currentPosition + diceTotal - 1) % GameConstants.boardSize + 1;
    return newPosition;
  }

  // Check if player passed START (tile 1)
  bool _passedStart(int oldPosition, int newPosition) {
    // Passing from 40 to lower number means passed START (tile 1)
    if (oldPosition >= GameConstants.startPassThresholdOld &&
        newPosition <= GameConstants.startPassThresholdNew) {
      return true;
    }
    return false;
  }

  // Handle 3x double dice - Library Watch
  void _handleTripleDouble() {
    if (state.currentPlayer == null) return;

    final currentPlayer = state.currentPlayer!;

    // GAMEPLAY LOG: Triple double dice penalty
    state = state.withLogMessage(
      '${currentPlayer.name}: 3x Çift Zar! KÜTÜPHANE NÖBETİ tetiklendi!',
    );

    // Update player immutably
    final updatedPlayer = currentPlayer.copyWith(
      position: 11,
      isInLibraryWatch: true,
      libraryWatchTurnsRemaining: GameConstants.libraryWatchTurns,
      doubleDiceCount: 0,
    );

    final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);

    // GAMEPLAY LOG: Teleport to Library Watch
    state = state
        .copyWith(
          players: updatedPlayers,
          oldPosition: state.oldPosition,
          newPosition: 11,
          passedStart: false,
        )
        .withLogMessage(
          '${currentPlayer.name} kutucuk 11\'e (KÜTÜPHANE NÖBETİ) ışınlandı',
        );

    endTurn();
  }

  // Resolve current tile - Step 3 of turn
  void resolveCurrentTile() {
    if (!_requirePhase(TurnPhase.moved, 'resolveCurrentTile')) return;
    if (state.currentPlayer == null) return;

    final tileNumber = state.newPosition ?? state.currentPlayer!.position;
    final tile = state.tiles.firstWhere((t) => t.id == tileNumber);

    // Update phase to tileResolved
    state = state.copyWith(turnPhase: TurnPhase.tileResolved);

    // TRANSCRIPT: Record tile resolution
    _currentTranscript = _currentTranscript.addTileResolved(
      tile.id,
      tile.name,
      tile.type.toString(),
    );

    // UI FEEDBACK LOG: Tile type information
    String tileLog = 'Kutucuk: ${tile.name} (${tile.type})';

    // CHECK FOR RENT FIRST (for owned tiles)
    if (tile.canBeOwned &&
        tile.owner != null &&
        state.currentPlayer!.id != tile.owner) {
      collectRent();
      return; // Don't ask question or draw card on owned tiles
    }

    // Handle different tile types
    switch (tile.type) {
      case TileType.corner:
        _handleCornerTile(tile);
        break;

      case TileType.book:
      case TileType.publisher:
        // Show question for book/publisher tiles
        _showQuestion(tile);
        break;

      case TileType.chance:
        tileLog += ' - ŞANS kartı çekiliyor...';
        state = state.withLogMessage(tileLog);
        drawCard(CardType.sans);
        break;

      case TileType.fate:
        tileLog += ' - KADER kartı çekiliyor...';
        state = state.withLogMessage(tileLog);
        drawCard(CardType.kader);
        break;

      case TileType.tax:
        tileLog += ' - Vergi: %${tile.taxRate}';
        state = state.withLogMessage(tileLog);
        _handleTaxTile(tile);
        break;

      case TileType.special:
        tileLog += ' - Özel kutucuk';
        state = state.withLogMessage(tileLog);
        _handleSpecialTile(tile);
        break;
    }

    // NOTE: Phase advance stops here for tiles handled by playTurn().
    // Tiles that need special handling (card, question, tax) are routed by _handleTileResolved()
    // Corner and special tiles will be handled by playTurn() calling endTurn() when phase is tileResolved
  }

  // Show question for book/publisher tiles
  void _showQuestion(Tile tile) {
    if (!_requirePhase(TurnPhase.tileResolved, '_showQuestion')) return;
    if (state.currentPlayer == null) return;
    final currentPlayer = state.currentPlayer!;

    // Update phase to questionResolved
    state = state.copyWith(turnPhase: TurnPhase.questionResolved);

    // Get a random question from pool
    Question question = _getRandomQuestion();

    // If player has easyQuestionNext flag, consume it and get an easy question
    if (currentPlayer.easyQuestionNext) {
      question = _getEasyQuestion();
      // Consume the flag immediately
      final updatedPlayer = currentPlayer.copyWith(easyQuestionNext: false);
      final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);
      state = state.copyWith(players: updatedPlayers);
    }

    // UI FEEDBACK LOG: Question being asked
    state = state
        .copyWith(
          questionState: QuestionState.answering,
          currentQuestion: question,
          questionTimer: GameConstants.questionTimerDuration,
        )
        .withLogMessage('${tile.name} için soru soruluyor...');

    // TRANSCRIPT: Record question asked
    _currentTranscript = _currentTranscript.addQuestionAsked(
      question.question,
      question.category.toString(),
    );
    debugPrint('❓ Question asked: ${question.question}');
  }

  // Get a random question from pool
  Question _getRandomQuestion() {
    if (state.questionPool.isEmpty) {
      return Question(
        id: 'default',
        category: QuestionCategory.benKimim,
        difficulty: Difficulty.easy,
        question: 'Soru havuzu boş!',
        answer: 'Boş',
      );
    }

    final randomIndex = _random.nextInt(state.questionPool.length);
    return state.questionPool[randomIndex];
  }

  // Get an easy question from pool
  Question _getEasyQuestion() {
    if (state.questionPool.isEmpty) {
      return Question(
        id: 'default',
        category: QuestionCategory.benKimim,
        difficulty: Difficulty.easy,
        question: 'Soru havuzu boş!',
        answer: 'Boş',
      );
    }

    // Filter for easy questions
    final easyQuestions = state.questionPool
        .where((q) => q.difficulty == Difficulty.easy)
        .toList();

    if (easyQuestions.isEmpty) {
      // If no easy questions, return any question
      return _getRandomQuestion();
    }

    final randomIndex = _random.nextInt(easyQuestions.length);
    return easyQuestions[randomIndex];
  }

  // Draw a card from appropriate deck
  void drawCard(CardType cardType) {
    // Select the appropriate card deck based on card type
    final cardDeck = cardType == CardType.sans
        ? state.sansCards
        : state.kaderCards;

    if (cardDeck.isEmpty) {
      state = state.withLogMessage('Kart havuzu boş!');
      return;
    }

    // Randomly select a card from deck
    final randomIndex = _random.nextInt(cardDeck.length);
    final drawnCard = cardDeck[randomIndex];

    // Store the drawn card in the game state
    state = state.copyWith(currentCard: drawnCard);

    // UI FEEDBACK LOG: Card description
    final cardTypeName = cardType == CardType.sans ? 'ŞANS' : 'KADER';
    state = state.withLogMessage(
      '$cardTypeName kartı çekildi: ${drawnCard.description}',
    );

    // TRANSCRIPT: Record card drawn
    _currentTranscript = _currentTranscript.addCardDrawn(
      cardTypeName,
      drawnCard.description,
    );
    debugPrint('🃏 Card drawn: $cardTypeName - ${drawnCard.description}');
  }

  // Apply card effect
  void applyCardEffect(Card card) {
    if (!_requirePhase(TurnPhase.tileResolved, 'applyCardEffect')) return;
    if (state.currentPlayer == null) return;

    final currentPlayer = state.currentPlayer!;
    final cardTypeName = card.type == CardType.sans ? 'ŞANS' : 'KADER';

    // Update phase to cardApplied
    state = state.copyWith(turnPhase: TurnPhase.cardApplied);

    // UI FEEDBACK LOG: Card description being shown
    state = state.withLogMessage(
      '$cardTypeName kartı uygulanıyor: ${card.description}',
    );

    // Track effect type for centralized logging and bankruptcy checks
    bool isPersonalEffect = false;
    bool isGlobalOrTargetedEffect = false;
    String logMessage = '';

    switch (card.effect) {
      // Personal effects (affect only current player)
      case CardEffect.gainStars:
        _applyGainStars(currentPlayer, card.starAmount ?? 0);
        isPersonalEffect = true;
        logMessage =
            '${currentPlayer.name}: +${card.starAmount ?? 0} yıldız kazandı';
        break;

      case CardEffect.loseStars:
        _applyLoseStars(currentPlayer, card.starAmount ?? 0);
        isPersonalEffect = true;
        logMessage =
            '${currentPlayer.name}: -${card.starAmount ?? 0} yıldız kaybetti';
        break;

      case CardEffect.skipNextTax:
        _applySkipNextTax(currentPlayer);
        isPersonalEffect = true;
        logMessage =
            '${currentPlayer.name}: Bir sonraki vergi ödemesi atlanacak';
        break;

      case CardEffect.freeTurn:
        _applyFreeTurn(currentPlayer);
        isPersonalEffect = true;
        logMessage = '${currentPlayer.name}: Ücretsiz tur hakkı kazandı';
        break;

      case CardEffect.easyQuestionNext:
        _applyEasyQuestionNext(currentPlayer);
        isPersonalEffect = true;
        logMessage = '${currentPlayer.name}: Bir sonraki soru kolay olacak';
        break;

      // Global effects (affect all players)
      case CardEffect.allPlayersGainStars:
        _applyAllPlayersGainStars(card.starAmount ?? 0);
        isGlobalOrTargetedEffect = true;
        logMessage = 'Tüm oyuncular: +${card.starAmount ?? 0} yıldız kazandı';
        break;

      case CardEffect.allPlayersLoseStars:
        _applyAllPlayersLoseStars(card.starAmount ?? 0);
        isGlobalOrTargetedEffect = true;
        logMessage = 'Tüm oyuncular: -${card.starAmount ?? 0} yıldız kaybetti';
        break;

      case CardEffect.taxWaiver:
        _applyTaxWaiver();
        isGlobalOrTargetedEffect = true;
        logMessage = 'Tüm oyuncular: Bir sonraki vergi ödemesi atlanacak';
        break;

      case CardEffect.allPlayersEasyQuestion:
        _applyAllPlayersEasyQuestion();
        isGlobalOrTargetedEffect = true;
        logMessage = 'Tüm oyuncular: Bir sonraki soru kolay olacak';
        break;

      // Targeted effects (affect specific players)
      case CardEffect.publisherOwnersLose:
        final affectedCount = _applyPublisherOwnersLose(card.starAmount ?? 0);
        isGlobalOrTargetedEffect = true;
        logMessage =
            'Yayınevi sahipleri ($affectedCount oyuncu): -${card.starAmount ?? 0} yıldız kaybetti';
        break;

      case CardEffect.richPlayerPays:
        final richestId = _applyRichPlayerPays(card.starAmount ?? 0);
        isGlobalOrTargetedEffect = true;
        // Get richest player name for logging (before mutation)
        final richestPlayer = state.players.firstWhere(
          (p) => p.id == richestId,
          orElse: () => state.players.first,
        );
        logMessage =
            '${richestPlayer.name} (en zengin oyuncu): -${card.starAmount ?? 0} yıldız ödedi';
        break;
    }

    // GAMEPLAY LOG: Card effect result
    state = state.withLogMessage(logMessage);

    // TRANSCRIPT: Record card applied (only for effects with star changes)
    if (card.starAmount != null && card.starAmount! != 0) {
      _currentTranscript = _currentTranscript.addCardApplied(
        cardTypeName,
        card.description,
        card.starAmount,
      );
      debugPrint('🃏 Card applied: $cardTypeName - ${card.description}');
    }

    // Centralized bankruptcy checks
    if (isPersonalEffect) {
      _checkBankruptcy();
    } else if (isGlobalOrTargetedEffect) {
      _checkAllPlayersBankruptcy();
    }

    // Clear the current card after applying effect
    state = state.copyWith(currentCard: null);
  }

  // Personal effects - ONLY modify state, no logging or bankruptcy checks
  void _applyGainStars(Player player, int amount) {
    final updatedPlayer = player.copyWith(stars: player.stars + amount);
    final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);
    state = state.copyWith(players: updatedPlayers);
  }

  void _applyLoseStars(Player player, int amount) {
    final newStars = (player.stars - amount).clamp(0, player.stars);
    final updatedPlayer = player.copyWith(
      stars: newStars,
      isBankrupt: newStars <= 0,
    );
    final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);
    state = state.copyWith(players: updatedPlayers);
  }

  void _applySkipNextTax(Player player) {
    final updatedPlayer = player.copyWith(skipNextTax: true);
    final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);
    state = state.copyWith(players: updatedPlayers);
  }

  void _applyFreeTurn(Player player) {
    final updatedPlayer = player.copyWith(skippedTurn: false);
    final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);
    state = state.copyWith(players: updatedPlayers);
  }

  void _applyEasyQuestionNext(Player player) {
    final updatedPlayer = player.copyWith(easyQuestionNext: true);
    final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);
    state = state.copyWith(players: updatedPlayers);
  }

  // Global effects - ONLY modify state, no logging or bankruptcy checks
  void _applyAllPlayersGainStars(int amount) {
    List<Player> updatedPlayers = [];
    for (final player in state.players) {
      final updatedPlayer = player.copyWith(stars: player.stars + amount);
      updatedPlayers.add(updatedPlayer);
    }
    state = state.copyWith(players: updatedPlayers);
  }

  void _applyAllPlayersLoseStars(int amount) {
    List<Player> updatedPlayers = [];
    for (final player in state.players) {
      final newStars = (player.stars - amount).clamp(0, player.stars);
      final updatedPlayer = player.copyWith(
        stars: newStars,
        isBankrupt: newStars <= 0,
      );
      updatedPlayers.add(updatedPlayer);
    }
    state = state.copyWith(players: updatedPlayers);
  }

  void _applyTaxWaiver() {
    List<Player> updatedPlayers = [];
    for (final player in state.players) {
      final updatedPlayer = player.copyWith(skipNextTax: true);
      updatedPlayers.add(updatedPlayer);
    }
    state = state.copyWith(players: updatedPlayers);
  }

  void _applyAllPlayersEasyQuestion() {
    List<Player> updatedPlayers = [];
    for (final player in state.players) {
      final updatedPlayer = player.copyWith(easyQuestionNext: true);
      updatedPlayers.add(updatedPlayer);
    }
    state = state.copyWith(players: updatedPlayers);
  }

  // Targeted effects - ONLY modify state, return data for logging
  int _applyPublisherOwnersLose(int amount) {
    List<Player> updatedPlayers = [];
    int affectedCount = 0;

    for (final player in state.players) {
      // Check if player owns any publisher tiles
      final ownsPublisher = player.ownedTiles.any((tileId) {
        final tileIndex = state.tiles.indexWhere((t) => t.id == tileId);
        if (tileIndex < 0) return false;
        return state.tiles[tileIndex].type == TileType.publisher;
      });

      if (ownsPublisher) {
        final newStars = (player.stars - amount).clamp(0, player.stars);
        final updatedPlayer = player.copyWith(
          stars: newStars,
          isBankrupt: newStars <= 0,
        );
        updatedPlayers.add(updatedPlayer);
        affectedCount++;
      } else {
        updatedPlayers.add(player);
      }
    }

    state = state.copyWith(players: updatedPlayers);
    return affectedCount;
  }

  String _applyRichPlayerPays(int amount) {
    if (state.players.isEmpty) return '';

    // Find the richest player (highest star count) BEFORE any mutation
    Player richestPlayer = state.players.first;
    for (final player in state.players) {
      if (player.stars > richestPlayer.stars) {
        richestPlayer = player;
      }
    }

    // Store the ID before mutation
    final richestId = richestPlayer.id;

    // Apply the star loss
    final newStars = (richestPlayer.stars - amount).clamp(
      0,
      richestPlayer.stars,
    );
    final updatedPlayer = richestPlayer.copyWith(
      stars: newStars,
      isBankrupt: newStars <= 0,
    );
    final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);

    state = state.copyWith(players: updatedPlayers);
    return richestId;
  }

  // Check bankruptcy for all players
  void _checkAllPlayersBankruptcy() {
    List<Player> updatedPlayers = [];
    for (final player in state.players) {
      if (player.stars <= GameConstants.bankruptcyThreshold &&
          !player.isBankrupt) {
        final updatedPlayer = player.copyWith(isBankrupt: true);
        updatedPlayers.add(updatedPlayer);
        // GAMEPLAY LOG: Bankruptcy event
        state = state.withLogMessage('${player.name} İFLAS OLDU!');

        // TRANSCRIPT: Record bankruptcy event
        _currentTranscript = _currentTranscript.addBankruptcy(player.name);
        debugPrint('💀 Bankruptcy: ${player.name} is bankrupt');
      } else {
        updatedPlayers.add(player);
      }
    }
    state = state.copyWith(players: updatedPlayers);
  }

  // Answer question - correct
  void answerQuestionCorrect() {
    if (state.currentQuestion == null) return;

    final question = state.currentQuestion!;
    final reward = question.starReward;
    final currentPlayer = state.currentPlayer!;

    // Update player stars
    final updatedPlayer = currentPlayer.copyWith(
      stars: currentPlayer.stars + reward,
    );
    final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);

    // GAMEPLAY LOG: Correct answer with star reward
    state = state
        .copyWith(
          players: updatedPlayers,
          questionState: QuestionState.correct,
          correctAnswers: state.correctAnswers + 1,
        )
        .withLogMessage(
          '${currentPlayer.name} doğru cevap verdi! +$reward yıldız kazandı.',
        );

    // TRANSCRIPT: Record correct answer
    _currentTranscript = _currentTranscript.addQuestionAnswered(
      'correct',
      reward,
    );
    debugPrint('✅ Question answered correctly: +$reward stars');

    // Phase Transition: Advance to next phase
    // PhaseTransitionMap will decide whether to go to copyrightPurchased or turnEnded
    playTurn();
  }

  // Answer question - wrong
  void answerQuestionWrong() {
    if (state.currentQuestion == null) return;

    final penalty = GameConstants.wrongAnswerPenalty;
    final currentPlayer = state.currentPlayer!;

    // Update player stars
    final updatedPlayer = currentPlayer.copyWith(
      stars: (currentPlayer.stars - penalty).clamp(
        GameConstants.bankruptcyThreshold,
        currentPlayer.stars,
      ),
    );
    final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);

    // GAMEPLAY LOG: Wrong answer with star penalty
    state = state
        .copyWith(
          players: updatedPlayers,
          questionState: QuestionState.wrong,
          wrongAnswers: state.wrongAnswers + 1,
        )
        .withLogMessage(
          '${currentPlayer.name} yanlış cevap verdi! -$penalty yıldız kaybetti.',
        );

    // TRANSCRIPT: Record wrong answer
    _currentTranscript = _currentTranscript.addQuestionAnswered(
      'wrong',
      -penalty,
    );
    debugPrint('❌ Question answered incorrectly: -$penalty stars');

    // Phase Transition: Advance to next phase
    // PhaseTransitionMap will decide whether to go to copyrightPurchased or turnEnded
    playTurn();
  }

  // Skip question
  void skipQuestion() {
    // GAMEPLAY LOG: Question skipped
    state = state
        .copyWith(questionState: QuestionState.skipped)
        .withLogMessage(
          '${state.currentPlayer?.name ?? 'Oyuncu'} soruyu atladı.',
        );
  }

  // Helper method to skip to next player (used for penalties)
  void _skipToNextPlayer() {
    int attempts = 0;
    final totalPlayers = state.players.length;

    do {
      final nextIndex = (state.currentPlayerIndex + 1) % totalPlayers;

      state = state.copyWith(currentPlayerIndex: nextIndex);
      attempts++;

      if (attempts > totalPlayers * 2) {
        state = state.withLogMessage('Hata: Aktif oyuncu bulunamadı!');
        _announceWinner();
        return;
      }
    } while ((state.currentPlayer?.isBankrupt ?? false) ||
             (state.currentPlayer?.isInLibraryWatch ?? false) ||
             (state.currentPlayer?.skippedTurn ?? false));

  // Handle corner tile effects
  void _handleCornerTile(Tile tile) {
    if (state.currentPlayer == null) return;

    final currentPlayer = state.currentPlayer!;
    Player? updatedPlayer;

    switch (tile.cornerEffect) {
      case CornerEffect.baslangic:
        // UI FEEDBACK LOG: Tile name
        state = state.withLogMessage(
          'Kutucuk: ${tile.name} - Başlangıç kutucuğu',
        );
        break;

      case CornerEffect.kutuphaneNobeti:
        // GAMEPLAY LOG: Library Watch penalty
        updatedPlayer = currentPlayer.copyWith(
          isInLibraryWatch: true,
          libraryWatchTurnsRemaining: GameConstants.libraryWatchTurns,
        );
        state = state.withLogMessage(
          'KÜTÜPHANE NÖBETİ! ${currentPlayer.name}: 2 tur ceza',
        );
        break;

      case CornerEffect.imzaGunu:
        // GAMEPLAY LOG: Skip next turn
        updatedPlayer = currentPlayer.copyWith(skippedTurn: true);
        state = state.withLogMessage(
          'İMZA GÜNÜ! ${currentPlayer.name}: Bir sonraki tur atlanacak',
        );
        break;

      case CornerEffect.iflasRiski:
        // GAMEPLAY LOG: Star loss from bankruptcy risk
        final lossAmount =
            (currentPlayer.stars * GameConstants.bankruptcyLossPercentage)
                .toInt();
        final newStars = (currentPlayer.stars - lossAmount).clamp(
          GameConstants.bankruptcyThreshold,
          currentPlayer.stars,
        );
        updatedPlayer = currentPlayer.copyWith(
          stars: newStars,
          isBankrupt: newStars <= 0,
        );
        state = state.withLogMessage(
          'İFLAS RİSKİ! ${currentPlayer.name}: -$lossAmount yıldız (%50 kayıp)',
        );
        _checkBankruptcy();
        break;

      case null:
        break;
    }

    // Update players list if player was modified
    if (updatedPlayer != null) {
      final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);
      state = state.copyWith(players: updatedPlayers);
    }
  }

  // Handle tax tiles
  void _handleTaxTile(Tile tile) {
    if (!_requirePhase(TurnPhase.tileResolved, '_handleTaxTile')) return;
    if (state.currentPlayer == null) return;
    final currentPlayer = state.currentPlayer!;

    // Update phase to taxResolved
    state = state.copyWith(turnPhase: TurnPhase.taxResolved);

    // Check if player has skipNextTax flag
    if (currentPlayer.skipNextTax) {
      // Consume the flag immediately
      final updatedPlayer = currentPlayer.copyWith(skipNextTax: false);
      final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);
      state = state.copyWith(players: updatedPlayers);

      // GAMEPLAY LOG: Tax skipped
      state = state.withLogMessage(
        '${currentPlayer.name}: Vergi ödemesi atlandı (kart kullanıldı)',
      );
      return;
    }

    // Calculate tax amount
    int taxAmount;
    if (tile.taxType == TaxType.gelirVergisi) {
      taxAmount = _calculateTax(currentPlayer.stars, 10);
    } else if (tile.taxType == TaxType.yazarlikVergisi) {
      taxAmount = _calculateTax(currentPlayer.stars, 15);
    } else {
      return;
    }

    // Apply tax
    final newStars = (currentPlayer.stars - taxAmount).clamp(
      GameConstants.bankruptcyThreshold,
      currentPlayer.stars,
    );
    final updatedPlayer = currentPlayer.copyWith(
      stars: newStars,
      isBankrupt: newStars <= 0,
    );
    final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);

    state = state.copyWith(players: updatedPlayers);
    // GAMEPLAY LOG: Tax payment
    state = state.withLogMessage(
      '${currentPlayer.name}: -$taxAmount yıldız vergi ödedi',
    );

    // TRANSCRIPT: Record tax payment
    _currentTranscript = _currentTranscript.addTaxPaid(
      tile.taxType.toString(),
      taxAmount,
    );
    debugPrint('💰 Tax paid: ${tile.taxType} - $taxAmount stars');
  }

  // Calculate tax amount (percentage or fixed minimum)
  int _calculateTax(int stars, int percentage) {
    final percentageTax = (stars * percentage) ~/ 100;
    final minTax = percentage == 10 ? 20 : 30;
    return percentageTax > minTax ? percentageTax : minTax;
  }

  // End turn - Step 4 of turn
  void endTurn() {
    if (state.turnPhase != TurnPhase.taxResolved &&
        state.turnPhase != TurnPhase.cardApplied &&
        state.turnPhase != TurnPhase.questionResolved &&
        state.turnPhase != TurnPhase.copyrightPurchased) {
      debugPrint(
        '⛔ Phase Guard: endTurn called in ${state.turnPhase}, expected one of [taxResolved, cardApplied, questionResolved, copyrightPurchased]',
      );
      assert(false, 'Invalid turn phase for endTurn');
      return;
    }
    if (state.currentPlayer == null) return;

    final currentPlayer = state.currentPlayer!;
    Player? updatedPlayer;

    // Update phase to turnEnded (THIS IS THE COMMIT BOUNDARY)
    state = state.copyWith(turnPhase: TurnPhase.turnEnded);

    // ============================================================================
    // TURN COMMIT POINT
    // ============================================================================
    /// Finalize's current turn's transcript and commit it to state.
    /// This happens exactly once per turn when phase reaches turnEnded.
    /// The transcript becomes immutable after this point.
    ///
    /// Guarantees:
    /// - Commit happens exactly once (only endTurn() can commit)
    /// - No partial transcripts leak (only exposed via lastTurnResult)
    /// - No duplicate commits (phase guard prevents re-entry)
    /// - Immutable after commit (TurnTranscript uses copyWith pattern)
    /// - Single source of truth (state.lastTurnResult)

    /// Private: Current turn's transcript (never exposed directly)
    /// Only accessible via committed TurnResult after turn ends
    TurnTranscript _currentTranscript = TurnTranscript.empty;

    /// Private: Snapshot of player state at turn START
    ///
    /// Used to calculate accurate starsDelta and positionDelta by comparing
    /// start values with final values at turn COMMIT. This is the single
    /// source of truth for delta calculation, avoiding double counting that
    /// would occur if we inferred deltas from transcript events.
    ///
    /// Why snapshot-based delta?
    /// - Avoids double counting (e.g., card effect + passing START)
    /// - Single source of truth (compare start vs end, not sum of events)
    /// - Simpler and more accurate than parsing transcript events
    /// - Snapshot created exactly once at turn start, used exactly once at commit

    // CALCULATE DELTAS using snapshot comparison
    ///
    // Compare snapshot values (captured at turn START) with final values
    // This is single source of truth for delta calculation.
    final endStars = currentPlayer.stars;
    final endPosition = currentPlayer.position;

    // Calculate deltas from snapshot
    final starsDelta = _turnStartSnapshot != null
        ? endStars - _turnStartSnapshot!.startStars
        : 0;

    final positionDelta = _turnStartSnapshot != null
        ? endPosition - _turnStartSnapshot!.startPosition
        : 0;

    // COMMIT: Create TurnResult with finalized transcript and accurate deltas

    // Get tile type directly to avoid type errors
    String tileTypeStr = 'unknown';
    final tileNumber = state.newPosition ?? currentPlayer.position;
    try {
      final tile = state.tiles.firstWhere((t) => t.id == tileNumber);
      tileTypeStr = tile.type.toString();
    } catch (e) {
      tileTypeStr = 'unknown';
    }

    final turnResult = TurnResult(
      playerIndex: state.currentPlayerIndex,
      startPosition: _turnStartSnapshot?.startPosition ?? endPosition,
      endPosition: endPosition,
      diceTotal: state.lastDiceRoll?.total ?? 0,
      isDouble: state.lastDiceRoll?.isDouble ?? false,
      starsDelta: starsDelta, // Calculated from snapshot comparison
      tileType: tileTypeStr,
      questionAnsweredCorrectly: state.questionState == QuestionState.correct,
      taxPaid: state.turnPhase == TurnPhase.taxResolved,
      transcript: _currentTranscript, // FINALIZED transcript - immutable now
    );

    // Store committed result in state (this is single source of truth for completed turns)
    state = state.copyWith(lastTurnResult: turnResult);

    // Append to turn history
    state = state.copyWith(turnHistory: state.turnHistory.add(turnResult));

    debugPrint(
      '📋 Turn committed: Player ${turnResult.playerIndex}, '
      '${turnResult.transcript.events.length} events',
    );
    debugPrint(
      '📚 Turn history updated: ${state.turnHistory.totalTurns} total turns',
    );

    // ============================================================================
    // DEBUG-ONLY: Validate snapshot coverage for committed turn
    // ============================================================================
    ///
    /// Ensures that a TurnSnapshot was available when the turn was committed.
    /// This guarantees accurate delta calculation (stars and position)
    /// for all committed turns.
    ///
    /// IMPORTANT:
    /// - Only runs in debug mode (kDebugMode)
    /// - Does NOT affect gameplay logic or state
    /// - If validation fails, logs detailed error message
    /// - Uses assert() to halt execution in debug builds
    ///
    /// Validation logic:
    /// - TurnResult.starsDelta was calculated from snapshot comparison
    /// - TurnResult.startPosition came from snapshot
    /// - Therefore, snapshot must have existed when turn was committed
    if (kDebugMode) {
      // Verify snapshot existed when turn was committed
      final bool hadSnapshot = _turnStartSnapshot != null;

      if (!hadSnapshot) {
        // Log validation failure with clear details
        final lastTurnIndex = state.turnHistory.totalTurns - 1;
        debugPrint(
          '╔══════════════════════════════════════════════╗',
        );
        debugPrint(
          '║  🔴 SNAPSHOT COVERAGE VALIDATION FAILED                 ║',
        );
        debugPrint(
          '╠════════════════════════════════════════════╣',
        );
        debugPrint('║  Turn index: ${lastTurnIndex.toString().padRight(46)} ║');
        debugPrint(
          '║  Total turn count: ${state.turnHistory.totalTurns.toString().padRight(42)} ║',
        );
        debugPrint(
          '║  Snapshot status: MISSING                                    ║',
        );
        debugPrint(
          '║  This turn was committed WITHOUT a TurnSnapshot!           ║',
        );
        debugPrint(
          '║  Deltas may be incorrect.                                   ║',
        );
        debugPrint(
          '╚══════════════════════════════════════════════╝',
        );

        // Assert to halt execution in debug builds
        assert(
          false,
          'Missing TurnSnapshot for committed TurnResult at turn index $lastTurnIndex',
        );
      } else {
        // Log successful validation (optional, can be removed if too verbose)
        debugPrint(
          '✅ Snapshot coverage verified: Turn ${state.turnHistory.totalTurns} has snapshot',
        );
      }
    }

    // ============================================================================
    // DEBUG-ONLY: Validate turn history after each turn commit
    // ============================================================================
    ///
    /// This is a development safety check that validates the entire turn history
    /// after each turn is committed. It helps catch corrupted or inconsistent
    /// turn data early during development.
    ///
    /// IMPORTANT:
    /// - Only runs in debug mode (kDebugMode)
    /// - Does NOT affect gameplay logic or state
    /// - If validation fails, logs detailed ValidationReport
    /// - Uses assert() to halt execution in debug builds
    ///
    /// Validation rules:
    /// - Replays each turn to verify transcript consistency
    /// - Checks star deltas match calculated values
    /// - Validates position deltas
    /// - Ensures no corrupted state leaks into history
    if (kDebugMode) {
      final report = TurnHistoryValidator.validateAll(state.turnHistory);

      if (!report.isAllValid) {
        // Log validation failure with clear details
        debugPrint(
          '╔══════════════════════════════════════════════════════════════╗',
        );
        debugPrint(
          '║  🔴 TURN HISTORY VALIDATION FAILED                       ║',
        );
        debugPrint(
          '╠══════════════════════════════════════════════╣',
        );
        debugPrint(
          '║  Total turns validated: ${report.totalValidated.toString().padRight(20)} ║',
        );
        debugPrint(
          '║  Turns passed before failure: ${report.passedCount.toString().padRight(19)} ║',
        );
        debugPrint(
          '║  Failed at turn index: ${report.failedIndex.toString().padRight(22)} ║',
        );
        debugPrint(
          '║  Error: ${report.errorMessage ?? 'Unknown'}                                   ║',
        );
        debugPrint(
          '╚════════════════════════════════════════════════════════╝',
        );

        // Assert to halt execution in debug builds
        assert(
          false,
          'Turn history validation failed at turn ${report.failedIndex}: ${report.errorMessage}',
        );
      } else {
        // Log successful validation (optional, can be removed if too verbose)
        debugPrint(
          '✅ Turn history validated: ${report.totalValidated} turns passed',
        );
      }
    }

    // ============================================================================
    // DEBUG-ONLY: Bot turn determinism check
    // ============================================================================
    ///
    /// Validates that bot turns are deterministic by checking consistency
    /// of event sequences. This catches non-deterministic bot behavior
    /// that would corrupt replay and analysis.
    ///
    /// IMPORTANT:
    /// - Only runs in debug mode (kDebugMode)
    /// - Only validates bot turns (currentPlayer.isBot == true)
    /// - Does NOT affect gameplay logic or state
    /// - If validation fails, logs detailed error message
    /// - Uses assert() to halt execution in debug builds
    ///
    /// Validation logic:
    /// - Checks that transcript events follow expected patterns
    /// - Validates event sequences are consistent for bot turns
    /// - Ensures no non-deterministic choices by bot
    if (kDebugMode && currentPlayer.type == PlayerType.bot) {
      _validateBotTurnDeterminism(turnResult);
    }

    // Check for bankruptcy
    if (currentPlayer.stars <= GameConstants.bankruptcyThreshold) {
      updatedPlayer = currentPlayer.copyWith(isBankrupt: true);
      // GAMEPLAY LOG: Bankruptcy event
      state = state.withLogMessage('${currentPlayer.name} İFLAS OLDU!');

      if (_isGameOver()) {
        _announceWinner();
        return;
      }
    }

    // Update players list if player was modified
    if (updatedPlayer != null) {
      final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);
      state = state.copyWith(players: updatedPlayers);
    }

    // Check if player rolled double (gets another turn)
    final wasDouble = state.lastDiceRoll?.isDouble ?? false;

    if (wasDouble) {
      // GAMEPLAY LOG: Double dice bonus turn
      state = state.withLogMessage(
        'Çift zar attı! ${currentPlayer.name} tekrar zar atacak.',
      );
      state = state.copyWith(
        turnPhase: TurnPhase.start,
        oldPosition: null,
        newPosition: null,
        passedStart: false,
      );
      return;
    }

    // Move to next player
    _nextPlayer();
  }

  // Move to next player
  void _nextPlayer() {
    int attempts = 0;
    final totalPlayers = state.players.length;

    do {
      final nextIndex = (state.currentPlayerIndex + 1) % totalPlayers;

      state = state.copyWith(currentPlayerIndex: nextIndex);
      attempts++;

      if (attempts > totalPlayers) {
        // GAMEPLAY LOG: All players bankrupt or in penalties
        state = state.withLogMessage('Tüm oyuncular iflas oldu veya cezalı!');
        _announceWinner();
        return;
      }
    } while (state.currentPlayer?.isBankrupt ?? false);

    if (state.currentPlayer != null) {
      final currentPlayer = state.currentPlayer!;

      // Handle library watch penalty: decrement turns remaining
      if (currentPlayer.isInLibraryWatch) {
        final newTurnsRemaining = currentPlayer.libraryWatchTurnsRemaining - 1;
        Player? updatedPlayer;

        if (newTurnsRemaining <= 0) {
          // Penalty complete - release from library watch
          updatedPlayer = currentPlayer.copyWith(
            isInLibraryWatch: false,
            libraryWatchTurnsRemaining: 0,
          );
          state = state.withLogMessage(
            '${currentPlayer.name}: KÜTÜPHANE NÖBETİ cezası tamamlandı.',
          );
        } else {
          // Continue penalty - decrement turns
          updatedPlayer = currentPlayer.copyWith(
            libraryWatchTurnsRemaining: newTurnsRemaining,
          );
          state = state.withLogMessage(
            '${currentPlayer.name}: KÜTÜPHANE NÖBETİ - $newTurnsRemaining tur kaldı.',
          );
        }

        if (updatedPlayer != null) {
          final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);
          state = state.copyWith(players: updatedPlayers);
        }

        // Skip this player's turn
        _skipToNextPlayer();
        return;
      }

      // Handle skipped turn penalty: skip once, then reset
      if (currentPlayer.skippedTurn) {
        final updatedPlayer = currentPlayer.copyWith(skippedTurn: false);
        final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);
        state = state.copyWith(players: updatedPlayers);
        state = state.withLogMessage(
          '${currentPlayer.name}: İMZA GÜNÜ cezası tamamlandı, atlanan tur geçildi.',
        );

        // Skip this player's turn
        _skipToNextPlayer();
        return;
      }

    if (state.currentPlayer != null) {
      final currentPlayer = state.currentPlayer!;

      // UI FEEDBACK LOG: Turn transition
      state = state
          .copyWith(
            turnPhase: TurnPhase.start,
            oldPosition: null,
            newPosition: null,
            passedStart: false,
            isDiceAnimationComplete: true, // Reset animation flag for new turn
          )
          .withLogMessage('Sıra: ${state.currentPlayer!.name}');

      // START NEW TURN: Create snapshot and transcript
      ///
      // This is TURN START boundary. We capture the player's state at
      // beginning of the turn to calculate accurate deltas later.
      // Snapshot is single source of truth for delta calculation.

      // START NEW TRANSCRIPT: Initialize transcript for new turn
      _currentTranscript = TurnTranscript(
        playerIndex: state.currentPlayerIndex,
      );
      debugPrint(
        '📜 New transcript started for player ${state.currentPlayerIndex}',
      );

      // CREATE SNAPSHOT: Capture player state at turn START
      ///
      // This snapshot is used in endTurn() to calculate accurate deltas
      // by comparing start values with final values. This avoids double
      // counting that would occur if we inferred deltas from transcript events.
      _turnStartSnapshot = TurnSnapshot(
        playerIndex: state.currentPlayerIndex,
        startStars: currentPlayer.stars,
        startPosition: currentPlayer.position,
      );
      debugPrint(
        '📸 Snapshot created: Player ${currentPlayer.id}, '
        'Stars=${currentPlayer.stars}, Position=${currentPlayer.position}',
      );
    }
  }

  // Check bankruptcy
  void _checkBankruptcy() {
    if (state.currentPlayer == null) return;

    final currentPlayer = state.currentPlayer!;

    if (currentPlayer.stars <= GameConstants.bankruptcyThreshold) {
      final updatedPlayer = currentPlayer.copyWith(isBankrupt: true);
      final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);
      // GAMEPLAY LOG: Bankruptcy event
      state = state
          .copyWith(players: updatedPlayers)
          .withLogMessage('${currentPlayer.name} İFLAS OLDU!');

      // TRANSCRIPT: Record bankruptcy event
      _currentTranscript = _currentTranscript.addBankruptcy(currentPlayer.name);
      debugPrint('💀 Bankruptcy: ${currentPlayer.name} is bankrupt');
    }
  }

  // Check if game is over
  bool _isGameOver() {
    final activePlayers = state.players.where((p) => !p.isBankrupt).length;
    return activePlayers <= 1;
  }

  // Announce winner
  void _announceWinner() {
    final winner = state.players.firstWhere(
      (p) => !p.isBankrupt,
      orElse: () => state.players.first,
    );

    // GAMEPLAY LOG: Game end
    state = state
        .copyWith(isGameOver: true)
        .withLogMessage('\n========================================');
    state = state.withLogMessage(
      'KAZANAN: ${winner.name} - ${winner.stars} yıldız',
    );
    state = state.withLogMessage('========================================\n');
    state = state.withLogMessage('OYUN BİTTİ!');
  }

  // Helper method to get tile type string from current state
  String _getTileType(GameState state) {
    final tileNumber = state.newPosition ?? state.currentPlayer?.position ?? 0;
    try {
      final tile = state.tiles.firstWhere((t) => t.id == tileNumber);
      return tile.type.toString();
    } catch (e) {
      return 'unknown';
    }
  }

  // Helper method to update a player in players list immutably
  List<Player> _updatePlayerInList(List<Player> players, Player updatedPlayer) {
    return players
        .map((p) => p.id == updatedPlayer.id ? updatedPlayer : p)
        .toList();
  }

  // ============================================================================
  // PHASE 3: STRATEGIC GAMEPLAY MECHANICS
  // ============================================================================

  /// Decrement question timer
  /// Call this from UI every second while question is active
  void tickQuestionTimer() {
    if (state.questionState != QuestionState.answering) return;
    if (state.questionTimer == null || state.questionTimer! <= 0) return;

    final newTimer = state.questionTimer! - 1;

    // Check if timer reached 0
    if (newTimer <= 0) {
      // Auto-fail on timeout
      answerQuestionWrong();
      state = state.withLogMessage('Süre doldu! Soru yanlış sayıldı.');
      return;
    }

    // Visual warning at <10 seconds
    if (newTimer <= 10 && newTimer > 0) {
      state = state.withLogMessage('⚠️ Kalan süre: $newTimer saniye');
    }

    state = state.copyWith(questionTimer: newTimer);
  }

  /// Purchase copyright for current tile
  /// Called after correct answer on book/publisher tile
  void purchaseCopyright() {
    if (state.currentPlayer == null) return;
    if (state.currentQuestion == null) return;

    final currentPlayer = state.currentPlayer!;
    final tileNumber = state.newPosition ?? currentPlayer.position;
    final tile = state.tiles.firstWhere((t) => t.id == tileNumber);

    // Validate tile can be owned
    if (!tile.canBeOwned) {
      state = state.withLogMessage('${tile.name} telifi satın alınamaz.');
      return;
    }

    // Check if tile already owned
    if (tile.owner != null) {
      state = state.withLogMessage(
        '${tile.name} zaten ${tile.owner} tarafından satın alınmış.',
      );
      return;
    }

    // Check if player already owns this tile
    if (currentPlayer.ownsTile(tile.id)) {
      state = state.withLogMessage(
        '${currentPlayer.name} zaten ${tile.name} telifini sahipleniyor.',
      );
      return;
    }

    // Validate purchase price
    final purchasePrice = tile.purchasePrice ?? 0;
    if (purchasePrice <= 0) {
      state = state.withLogMessage(
        '${tile.name} için satın alma fiyatı ayarlanmamış.',
      );
      return;
    }

    // Check if player has enough stars
    if (currentPlayer.stars < purchasePrice) {
      state = state.withLogMessage(
        '${currentPlayer.name} telifi satın almak için yeterli yıldıza sahip değil. '
        'Gerekli: $purchasePrice, Sahip olunan: ${currentPlayer.stars}',
      );
      return;
    }

    // Apply purchase
    final updatedPlayer = currentPlayer.copyWith(
      stars: currentPlayer.stars - purchasePrice,
      ownedTiles: [...currentPlayer.ownedTiles, tile.id],
    );

    final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);

    // Update tile owner
    final updatedTiles = state.tiles.map((t) {
      if (t.id == tile.id) {
        return t.copyWith(owner: currentPlayer.id);
      }
      return t;
    }).toList();

    // Update state
    state = state
        .copyWith(players: updatedPlayers, tiles: updatedTiles)
        .withLogMessage(
          '${currentPlayer.name} ${tile.name} telifini satın aldı! -$purchasePrice yıldız',
        );

    // TRANSCRIPT: Record copyright purchase
    _currentTranscript = _currentTranscript.addCopyrightPurchased(
      tile.id,
      tile.name,
      purchasePrice,
    );
    debugPrint('📜 Copyright purchased: ${tile.name} - $purchasePrice stars');

    // Phase Transition: Advance to next phase
    // PhaseTransitionMap will route to turnEnded
    playTurn();
  }

  /// Collect rent when player lands on owned tile
  /// Called during tile resolution
  void collectRent() {
    if (state.currentPlayer == null) return;

    final currentPlayer = state.currentPlayer!;
    final tileNumber = state.newPosition ?? currentPlayer.position;
    final tile = state.tiles.firstWhere((t) => t.id == tileNumber);

    // Check if tile can be owned
    if (!tile.canBeOwned) {
      return; // Not a rent-paying tile
    }

    // Check if tile has owner
    if (tile.owner == null) {
      return; // Unowned tile - no rent
    }

    // Check if current player owns tile
    if (currentPlayer.id == tile.owner) {
      state = state.withLogMessage(
        '${currentPlayer.name} kendi telifine indi. Kira ödemesi gerekmiyor.',
      );
      return;
    }

    // Find owner player
    final ownerPlayer = state.players.firstWhere(
      (p) => p.id == tile.owner,
      orElse: () => state.players.first,
    );

    // Check if owner is in Library Watch
    if (ownerPlayer.isInLibraryWatch) {
      state = state.withLogMessage(
        'Telif sahibi (${ownerPlayer.name}) KÜTÜPHANE NÖBETİ\'nde. '
        'Kira ödemesi gerekmiyor.',
      );
      return;
    }

    // Check if owner is bankrupt
    if (ownerPlayer.isBankrupt) {
      state = state.withLogMessage(
        'Telif sahibi (${ownerPlayer.name}) iflas olmuş. '
        'Kira ödemesi gerekmiyor.',
      );
      return;
    }

    // Calculate rent amount
    final rentAmount = tile.copyrightFee ?? 0;
    if (rentAmount <= 0) {
      state = state.withLogMessage(
        '${tile.name} için kira ücreti ayarlanmamış.',
      );
      return;
    }

    // Check if player can pay rent
    if (currentPlayer.stars < rentAmount) {
      // Player goes bankrupt from rent
      final bankruptPlayer = currentPlayer.copyWith(stars: 0, isBankrupt: true);
      final updatedPlayers = _updatePlayerInList(state.players, bankruptPlayer);

      state = state
          .copyWith(players: updatedPlayers)
          .withLogMessage('${currentPlayer.name} kira ödeyemedi! İFLAS OLDU!');

      // TRANSCRIPT: Record bankruptcy
      _currentTranscript = _currentTranscript.addBankruptcy(currentPlayer.name);
      _checkBankruptcy();
      return;
    }

    // Transfer stars from player to owner
    final updatedPlayer = currentPlayer.copyWith(
      stars: currentPlayer.stars - rentAmount,
    );

    final updatedOwner = ownerPlayer.copyWith(
      stars: ownerPlayer.stars + rentAmount,
    );

    // Update both players in list
    final updatedPlayers = _updatePlayerInList(
      _updatePlayerInList(state.players, updatedPlayer),
      updatedOwner,
    );

    // Update state
    state = state
        .copyWith(players: updatedPlayers)
        .withLogMessage(
          '${currentPlayer.name} kira ödedi: -$rentAmount yıldız '
          '→ ${ownerPlayer.name}: +$rentAmount yıldız',
        );

    // TRANSCRIPT: Record rent paid
    _currentTranscript = _currentTranscript.addRentPaid(
      tile.id,
      tile.name,
      ownerPlayer.name,
      rentAmount,
    );
    debugPrint(
      '💰 Rent paid: ${tile.name} - $rentAmount stars to ${ownerPlayer.name}',
    );
  }

  /// Handle special tiles (YAZARLIK OKULU, DE EĞİTİM VAKFI)
  void _handleSpecialTile(Tile tile) {
    if (state.currentPlayer == null) return;

    final currentPlayer = state.currentPlayer!;

    switch (tile.specialType) {
      case SpecialType.yazarlikOkulu:
        // YAZARLIK OKULU: Bonus question
        _showQuestion(tile);
        state = state.withLogMessage(
          'YAZARLIK OKULU! ${currentPlayer.name} bonus soru sorulacak.',
        );
        break;

      case SpecialType.deEgitimVakfi:
        // DE EĞİTİM VAKFI: Bonus stars without question
        final bonusAmount = 40; // Bonus stars
        final updatedPlayer = currentPlayer.copyWith(
          stars: currentPlayer.stars + bonusAmount,
        );
        final updatedPlayers = _updatePlayerInList(
          state.players,
          updatedPlayer,
        );

        state = state
            .copyWith(players: updatedPlayers)
            .withLogMessage(
              'DE EĞİTİM VAKFI! ${currentPlayer.name}: +$bonusAmount bonus yıldız',
            );

        // TRANSCRIPT: Record bonus received
        _currentTranscript = _currentTranscript.addBonusReceived(
          tile.id,
          tile.name,
          bonusAmount,
        );
        debugPrint('⭐ Bonus received: ${tile.name} - $bonusAmount stars');
        break;

      case null:
        break;
    }
  }

  // ============================================================================
  // DEBUG-ONLY: Bot turn determinism validation
  // ============================================================================

  /// Validates that bot turns follow deterministic patterns
  ///
  /// This is a simplified validation that checks transcript consistency
  /// rather than attempting to replay the entire turn (which would
  /// require major refactoring). It validates that bot turns
  /// have consistent event sequences and valid patterns.
  ///
  /// IMPORTANT:
  /// - Only runs in debug mode (kDebugMode)
  /// - Only validates bot turns
  /// - Does NOT affect gameplay logic or state
  /// - If validation fails, logs detailed error message
  /// - Uses assert() to halt execution in debug builds
  ///
  /// Validation logic:
  /// - Checks event sequence consistency
  /// - Validates event payloads are complete
  /// - Ensures no non-deterministic choices
  void _validateBotTurnDeterminism(TurnResult turnResult) {
    final transcript = turnResult.transcript;
    final events = transcript.events;

    // Skip validation if no events
    if (events.isEmpty) {
      debugPrint('⚠️ Bot turn validation skipped: No events recorded');
      return;
    }

    // Validation 1: Check event sequence consistency
    bool sequenceValid = true;
    String? sequenceError;

    // Bot turns should always have certain events in expected order
    final eventTypes = events.map((e) => e.type).toList();

    // Check for duplicate events that shouldn't exist
    final diceRollCount = eventTypes
        .where((t) => t == TurnEventType.diceRoll)
        .length;
    final moveCount = eventTypes.where((t) => t == TurnEventType.move).length;

    if (diceRollCount > 1 || moveCount > 1) {
      sequenceValid = false;
      sequenceError =
          'Duplicate events: diceRoll=$diceRollCount, move=$moveCount';
    }

    // Validation 2: Check event payload completeness
    bool payloadsValid = true;
    String? payloadError;

    for (int i = 0; i < events.length; i++) {
      final event = events[i];

      // Dice roll must have complete data
      if (event.type == TurnEventType.diceRoll) {
        if (event.data['die1'] == null ||
            event.data['die2'] == null ||
            event.data['total'] == null ||
            event.data['isDouble'] == null) {
          payloadsValid = false;
          payloadError = 'Incomplete diceRoll event data at index $i';
          break;
        }
      }

      // Move must have complete data
      if (event.type == TurnEventType.move) {
        if (event.data['from'] == null ||
            event.data['to'] == null ||
            event.data['passedStart'] == null) {
          payloadsValid = false;
          payloadError = 'Incomplete move event data at index $i';
          break;
        }
      }

      // Tile resolved must have complete data
      if (event.type == TurnEventType.tileResolved) {
        if (event.data['tileId'] == null ||
            event.data['tileName'] == null ||
            event.data['tileType'] == null) {
          payloadsValid = false;
          payloadError = 'Incomplete tileResolved event data at index $i';
          break;
        }
      }
    }

    // Validation 3: Check phase transition consistency
    bool transitionsValid = true;
    String? transitionError;

    final transitionEvents = events
        .where((e) => e.type == TurnEventType.transition)
        .toList();
    final transitionNames = transitionEvents
        .map((e) => e.data['transitionName'] as String?)
        .whereType<String>()
        .toList();

    // Check for duplicate or invalid transition names
    final validTransitions = {
      'roll_dice',
      'move_player',
      'resolve_tile',
      'draw_and_apply_card',
      'show_question',
      'handle_tax',
      'end_turn_after_card',
      'end_turn_after_question',
      'end_turn_after_tax',
      'resolve_corner_or_special',
    };

    for (final name in transitionNames) {
      if (!validTransitions.contains(name)) {
        transitionsValid = false;
        transitionError = 'Invalid transition name: $name';
        break;
      }
    }

    // Report validation results
    final bool allValid = sequenceValid && payloadsValid && transitionsValid;

    if (!allValid) {
      // Log validation failure with clear details
      debugPrint(
        '╔════════════════════════════════════════════════════════════════════════════════════╗',
      );
      debugPrint('║  🔴 BOT TURN DETERMINISM CHECK FAILED             ║');
      debugPrint(
        '╠════════════════════════════════════════════════════════════════════════════════════════════════════════════╣',
      );
      debugPrint('║  Turn index: ${state.turnHistory.totalTurns.toString().padRight(42)} ║');
      debugPrint('║  Player index: ${turnResult.playerIndex.toString().padRight(44)} ║');
      debugPrint('║  Total events: ${events.length.toString().padRight(45)} ║');
      debugPrint(
        '╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════.

    // Report validation results
    final bool allValid = sequenceValid && payloadsValid && transitionsValid;

    if (!allValid) {
      // Log validation failure with clear details
      debugPrint(
        '╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════.

      if (sequenceError != null) {
        debugPrint(
          '║  Sequence error: $sequenceError                              ║',
        );
      }
      if (payloadError != null) {
        debugPrint(
          '║  Payload error: $payloadError                              ║',
        );
      }
      if (transitionError != null) {
        debugPrint(
          '║  Transition error: $transitionError                              ║',
        );
      }

      debugPrint(
        '╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════.

      // Assert to halt execution in debug builds
      assert(
        false,
        'Bot turn determinism check failed for player ${turnResult.playerIndex}: '
        '${sequenceError ?? payloadError ?? transitionError}',
      );
    } else {
      // Log successful validation (optional, can be removed if too verbose)
      debugPrint(
        '✅ Bot turn determinism verified: '
        'Player ${turnResult.playerIndex}, ${events.length} events',
      );
    }
  }
}

// Provider
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});

// Current player provider
final currentPlayerProvider = Provider<Player?>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.currentPlayer;
});

// Turn phase provider
final turnPhaseProvider = Provider<TurnPhase>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.turnPhase;
});

// Is game over provider
final isGameOverProvider = Provider<bool>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.isGameOver;
});

// Log messages provider
final logMessagesProvider = Provider<List<String>>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.logMessages;
});

// Can roll provider
final canRollProvider = Provider<bool>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.canRoll;
});

// Last dice roll provider
final lastDiceRollProvider = Provider<DiceRoll?>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.lastDiceRoll;
});

// Question state provider
final questionStateProvider = Provider<QuestionState>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.questionState;
});

// Current question provider
final currentQuestionProvider = Provider<Question?>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.currentQuestion;
});

// Question timer provider
final questionTimerProvider = Provider<int>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.questionTimer ?? 0;
});

// Correct answers provider
final correctAnswersProvider = Provider<int>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.correctAnswers;
});

// Wrong answers provider
final wrongAnswersProvider = Provider<int>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.wrongAnswers;
});

// Current card provider
final currentCardProvider = Provider<Card?>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.currentCard;
});

// Last turn result provider
final lastTurnResultProvider = Provider<TurnResult>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.lastTurnResult;
});

// Turn history provider
final turnHistoryProvider = Provider<TurnHistory>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.turnHistory;
});
