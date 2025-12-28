import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../models/question.dart';
import '../models/card.dart';
import '../models/dice_roll.dart';
import '../models/turn_result.dart';
import '../models/turn_phase.dart';
import '../models/player_type.dart';
import '../constants/game_constants.dart';

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

  // Flags
  final bool isGameOver;

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
  /// - start → diceRolled → moved → tileResolved → (cardApplied | questionResolved | taxResolved) → turnEnded
  ///
  /// Each call to playTurn() advances exactly one phase.
  /// No gameplay rules are changed - this is pure orchestration.
  ///
  /// UI flow:
  /// 1. UI calls playTurn()
  /// 2. playTurn() switches on currentTurnPhase
  /// 3. Calls the appropriate method (rollDice, moveCurrentPlayer, etc.)
  /// 4. That method advances the phase
  /// 5. UI reads updated state and calls playTurn() again
  /// 6. Repeat until turnEnded, then playTurn() resets to start for next player

  /// Main orchestration method - the ONLY method UI should call
  void playTurn() {
    debugPrint('🎮 playTurn() called - Current phase: ${state.turnPhase}');

    // Phase 5.1: Bot trigger - ONLY automation point
    // If current player is bot, auto-trigger playTurn() with delay
    if (state.turnPhase == TurnPhase.start &&
        state.currentPlayer?.type == PlayerType.bot) {
      Future.delayed(const Duration(milliseconds: 700), () {
        playTurn();
      });
      return;
    }

    // Switch on current phase to determine next action
    switch (state.turnPhase) {
      // Phase 1: Start of turn - roll the dice
      case TurnPhase.start:
        debugPrint('🎲 Phase: start → rolling dice');
        rollDice();
        break;

      // Phase 2: Dice rolled - move player
      case TurnPhase.diceRolled:
        debugPrint('🚶 Phase: diceRolled → moving player');
        moveCurrentPlayer(state.lastDiceRoll?.total ?? 0);
        break;

      // Phase 3: Player moved - resolve tile effects
      case TurnPhase.moved:
        debugPrint('🏠 Phase: moved → resolving tile');
        resolveCurrentTile();
        break;

      // Phase 4: Tile resolved - determine next action based on tile type
      case TurnPhase.tileResolved:
        debugPrint('🎯 Phase: tileResolved → handling tile effect');
        _handleTileResolved();
        break;

      // Phase 5: Card applied - end turn
      case TurnPhase.cardApplied:
        debugPrint('🃏 Phase: cardApplied → ending turn');
        endTurn();
        break;

      // Phase 5: Question resolved - end turn
      case TurnPhase.questionResolved:
        debugPrint('❓ Phase: questionResolved → ending turn');
        endTurn();
        break;

      // Phase 5: Tax resolved - end turn
      case TurnPhase.taxResolved:
        debugPrint('💰 Phase: taxResolved → ending turn');
        endTurn();
        break;

      // Phase 6: Turn ended - this phase is transient, next call will start new turn
      case TurnPhase.turnEnded:
        // This shouldn't happen - turnEnded is reset to start by endTurn()
        debugPrint(
          '⚠️ playTurn called in turnEnded phase - should be reset to start',
        );
        break;
    }
  }

  /// Handle tile resolved phase - route to appropriate action based on tile type
  void _handleTileResolved() {
    final tileNumber = state.newPosition ?? state.currentPlayer!.position;
    final tile = state.tiles.firstWhere((t) => t.id == tileNumber);

    // Route based on tile type
    switch (tile.type) {
      case TileType.chance:
      case TileType.fate:
        // Card tile - draw and apply card
        drawCard(tile.type == TileType.chance ? CardType.sans : CardType.kader);
        // Note: drawCard stores the card, then we need to apply it
        // But drawCard doesn't auto-apply, so we need to call applyCardEffect
        if (state.currentCard != null) {
          applyCardEffect(state.currentCard!);
        }
        break;

      case TileType.book:
      case TileType.publisher:
        // Question tile - show question
        _showQuestion(tile);
        break;

      case TileType.tax:
        // Tax tile - handle tax
        _handleTaxTile(tile);
        break;

      case TileType.corner:
      case TileType.special:
        // Corner or special tile - no additional action needed, end turn
        endTurn();
        break;
    }
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

    // Update phase to diceRolled
    state = state.copyWith(turnPhase: TurnPhase.diceRolled);
    debugPrint('🎲 Phase updated to: diceRolled');

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

    // UI FEEDBACK LOG: Tile type information
    String tileLog = 'Kutucuk: ${tile.name} (${tile.type})';

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

    // Get a random question from the pool
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
  }

  // Get a random question from the pool
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

  // Get an easy question from the pool
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

  // Draw a card from the appropriate deck
  void drawCard(CardType cardType) {
    // Select the appropriate card deck based on card type
    final cardDeck = cardType == CardType.sans
        ? state.sansCards
        : state.kaderCards;

    if (cardDeck.isEmpty) {
      state = state.withLogMessage('Kart havuzu boş!');
      return;
    }

    // Randomly select a card from the deck
    final randomIndex = _random.nextInt(cardDeck.length);
    final drawnCard = cardDeck[randomIndex];

    // Store the drawn card in the game state
    state = state.copyWith(currentCard: drawnCard);

    // UI FEEDBACK LOG: Card description
    final cardTypeName = cardType == CardType.sans ? 'ŞANS' : 'KADER';
    state = state.withLogMessage(
      '$cardTypeName kartı çekildi: ${drawnCard.description}',
    );
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
        state.turnPhase != TurnPhase.questionResolved) {
      debugPrint(
        '⛔ Phase Guard: endTurn called in ${state.turnPhase}, expected one of [taxResolved, cardApplied, questionResolved]',
      );
      assert(false, 'Invalid turn phase for endTurn');
      return;
    }
    if (state.currentPlayer == null) return;

    final currentPlayer = state.currentPlayer!;
    Player? updatedPlayer;

    // Update phase to turnEnded
    state = state.copyWith(turnPhase: TurnPhase.turnEnded);

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
        // GAMEPLAY LOG: All players bankrupt
        state = state.withLogMessage('Tüm oyuncular iflas oldu!');
        _announceWinner();
        return;
      }
    } while (state.currentPlayer?.isBankrupt ?? false);

    if (state.currentPlayer != null) {
      // UI FEEDBACK LOG: Turn transition
      state = state
          .copyWith(
            turnPhase: TurnPhase.start,
            oldPosition: null,
            newPosition: null,
            passedStart: false,
          )
          .withLogMessage('Sıra: ${state.currentPlayer!.name}');
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

  // Helper method to update a player in players list immutably
  List<Player> _updatePlayerInList(List<Player> players, Player updatedPlayer) {
    return players
        .map((p) => p.id == updatedPlayer.id ? updatedPlayer : p)
        .toList();
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
