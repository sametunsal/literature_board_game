import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../models/question.dart';
import '../models/card.dart';
import '../models/dice_roll.dart';
import '../constants/game_constants.dart';

// Turn Phase State Machine
enum TurnPhase {
  waitingRoll, // Waiting for player to roll dice
  rolling, // Dice rolling animation
  moving, // Player pawn moving
  resolvingTile, // Processing tile effects
  answering, // Player answering a question
  turnEnd, // Turn ending, preparing next player
}

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
    this.turnPhase = TurnPhase.waitingRoll,
    this.oldPosition,
    this.newPosition,
    this.passedStart = false,
    this.isGameOver = false,
    this.questionState = QuestionState.waiting,
    this.currentQuestion,
    this.questionTimer = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
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
  bool get canRoll =>
      turnPhase == TurnPhase.waitingRoll && !isCurrentPlayerBankrupt;

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
          turnPhase: TurnPhase.waitingRoll,
        )
        .withLogMessage('Oyun başlatılıyor...');

    // Log initial player order
    for (int i = 0; i < players.length; i++) {
      state = state.withLogMessage('Sıra ${i + 1}: ${players[i].name}');
    }

    state = state.withLogMessage(
      'Oyun başladı! Sıra: ${state.currentPlayer?.name}',
    );
  }

  // Roll dice - Step 1 of turn
  void rollDice() {
    if (!state.canRoll) return;
    if (state.currentPlayer == null) return;

    // Update phase to rolling
    state = state.copyWith(turnPhase: TurnPhase.rolling);

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

    // Log dice roll
    String logMessage =
        '${currentPlayer.name} zar attı: ${diceRoll.die1} + ${diceRoll.die2} = ${diceRoll.total}';
    if (diceRoll.isDouble) {
      logMessage += ' (ÇİFT!)';
    }

    state = state
        .copyWith(lastDiceRoll: diceRoll, players: updatedPlayers)
        .withLogMessage(logMessage);

    // Handle double dice
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

    // Move to moving phase
    state = state.copyWith(turnPhase: TurnPhase.moving);

    // Calculate new position
    moveCurrentPlayer(diceRoll.total);
  }

  // Move player - Step 2 of turn
  void moveCurrentPlayer(int diceTotal) {
    if (state.currentPlayer == null) return;

    final currentPlayer = state.currentPlayer!;
    final oldPosition = currentPlayer.position;

    // Counter-clockwise movement: position increases
    // Board is 1-40, moving counter-clockwise means increasing position
    final newPosition = _calculateNewPosition(oldPosition, diceTotal);

    // Check if passed START (tile 1)
    final passedStart = _passedStart(oldPosition, newPosition);

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

    // Log movement
    state = state
        .copyWith(
          players: updatedPlayers,
          oldPosition: oldPosition,
          newPosition: newPosition,
          passedStart: passedStart,
          turnPhase: TurnPhase.resolvingTile,
        )
        .withLogMessage(
          '${currentPlayer.name} kutucuk $oldPosition\'den $newPosition\'e hareket etti',
        );

    if (passedStart) {
      state = state.withLogMessage(
        '${currentPlayer.name} BAŞLANGIÇ\'ten geçti! +${GameConstants.passStartReward} yıldız',
      );
    }

    // Resolve tile effect
    resolveCurrentTile();
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
    if (state.currentPlayer == null) return;

    final tileNumber = state.newPosition ?? state.currentPlayer!.position;
    final tile = state.tiles.firstWhere((t) => t.id == tileNumber);

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
        tileLog += ' - ŞANS kartı çekilecek (basitleştirilmiş)';
        state = state.withLogMessage(tileLog);
        break;

      case TileType.fate:
        tileLog += ' - KADER kartı çekilecek (basitleştirilmiş)';
        state = state.withLogMessage(tileLog);
        break;

      case TileType.tax:
        tileLog += ' - Vergi: %${tile.taxRate}';
        state = state.withLogMessage(tileLog);
        break;

      case TileType.special:
        tileLog += ' - Özel kutucuk';
        state = state.withLogMessage(tileLog);
        break;
    }

    // Move to turn end
    state = state.copyWith(turnPhase: TurnPhase.turnEnd);

    endTurn();
  }

  // Show question for book/publisher tiles
  void _showQuestion(Tile tile) {
    // Get a random question from the pool
    final question = _getRandomQuestion();

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

    final randomIndex =
        (DateTime.now().millisecondsSinceEpoch) % state.questionPool.length;
    return state.questionPool[randomIndex];
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
        // BAŞLANGIÇ - handled by passing bonus
        state = state.withLogMessage(
          'Kutucuk: ${tile.name} - Başlangıç kutucuğu',
        );
        break;

      case CornerEffect.kutuphaneNobeti:
        // KÜTÜPHANE NÖBETİ - skip turns
        updatedPlayer = currentPlayer.copyWith(
          isInLibraryWatch: true,
          libraryWatchTurnsRemaining: GameConstants.libraryWatchTurns,
        );
        state = state.withLogMessage(
          'KÜTÜPHANE NÖBETİ! ${currentPlayer.name}: 2 tur ceza',
        );
        break;

      case CornerEffect.imzaGunu:
        // İMZA GÜNÜ - skip next turn
        updatedPlayer = currentPlayer.copyWith(skippedTurn: true);
        state = state.withLogMessage(
          'İMZA GÜNÜ! ${currentPlayer.name}: Bir sonraki tur atlanacak',
        );
        break;

      case CornerEffect.iflasRiski:
        // İFLAS RİSKİ - 50% star loss
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

  // End turn - Step 4 of turn
  void endTurn() {
    if (state.currentPlayer == null) return;

    final currentPlayer = state.currentPlayer!;
    Player? updatedPlayer;

    // Check for bankruptcy
    if (currentPlayer.stars <= GameConstants.bankruptcyThreshold) {
      updatedPlayer = currentPlayer.copyWith(isBankrupt: true);
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
      state = state.withLogMessage(
        'Çift zar attı! ${currentPlayer.name} tekrar zar atacak.',
      );
      state = state.copyWith(
        turnPhase: TurnPhase.waitingRoll,
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
        state = state.withLogMessage('Tüm oyuncular iflas oldu!');
        _announceWinner();
        return;
      }
    } while (state.currentPlayer?.isBankrupt ?? false);

    if (state.currentPlayer != null) {
      state = state
          .copyWith(
            turnPhase: TurnPhase.waitingRoll,
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

    state = state
        .copyWith(isGameOver: true, turnPhase: TurnPhase.turnEnd)
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
