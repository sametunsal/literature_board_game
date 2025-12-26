import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../models/question.dart';
import '../models/card.dart';
import '../models/dice_roll.dart';
import '../engine/game_engine.dart';

// Turn Phase State Machine
enum TurnPhase {
  waitingRoll,    // Waiting for player to roll dice
  rolling,        // Dice rolling animation
  moving,         // Player pawn moving
  resolvingTile,  // Processing tile effects
  turnEnd,       // Turn ending, preparing next player
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
  });

  Player? get currentPlayer {
    if (players.isEmpty || currentPlayerIndex < 0 || currentPlayerIndex >= players.length) {
      return null;
    }
    return players[currentPlayerIndex];
  }

  bool get isCurrentPlayerBankrupt => currentPlayer?.isBankrupt ?? false;
  bool get canRoll => turnPhase == TurnPhase.waitingRoll && !isCurrentPlayerBankrupt;

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
  late GameEngine _engine;
  static const int passStartReward = 50; // Stars earned when passing BAŞLANGIÇ
  static const int boardSize = 40; // Total tiles on board

  GameNotifier() : super(const GameState(
    players: [],
    tiles: [],
    questionPool: [],
    sansCards: [],
    kaderCards: [],
    currentPlayerIndex: 0,
  ));

  // Initialize game with data
  void initializeGame({
    required List<Player> players,
    required List<Tile> tiles,
    required List<Question> questionPool,
    required List<Card> sansCards,
    required List<Card> kaderCards,
  }) {
    _engine = GameEngine(
      players: players,
      tiles: tiles,
      questionPool: questionPool,
      sansCards: sansCards,
      kaderCards: kaderCards,
      onLogMessage: (message) {
        // Engine logs are handled by our state machine
      },
      onStarsChanged: (player, newAmount) {
        _updatePlayerStars(player.id, newAmount);
      },
      onPlayerMoved: (player, newPosition) {
        _updatePlayerPosition(player.id, newPosition);
      },
      onQuestionAsked: (player, question) {
        // Not used in simplified turn flow
      },
      onCardDrawn: (card) {
        // Not used in simplified turn flow
      },
    );

    _engine.initializeGame();
    
    state = state.copyWith(
      players: _engine.players,
      tiles: _engine.tiles,
      questionPool: _engine.questionPool,
      sansCards: _engine.sansCards,
      kaderCards: kaderCards,
      currentPlayerIndex: _engine.currentPlayerIndex,
      turnPhase: TurnPhase.waitingRoll,
    );
  }

  // Roll dice - Step 1 of turn
  void rollDice() {
    if (!state.canRoll) return;
    if (state.currentPlayer == null) return;

    // Update phase to rolling
    state = state.copyWith(
      turnPhase: TurnPhase.rolling,
    );

    // Generate random dice roll
    final diceRoll = DiceRoll.random();
    
    // Set lastRoll on current player
    state.currentPlayer!.lastRoll = diceRoll.total;
    
    // Log dice roll
    String logMessage = '${state.currentPlayer!.name} zar attı: ${diceRoll.die1} + ${diceRoll.die2} = ${diceRoll.total}';
    if (diceRoll.isDouble) {
      logMessage += ' (ÇİFT!)';
    }
    
    state = state.copyWith(
      lastDiceRoll: diceRoll,
    ).withLogMessage(logMessage);

    // Handle double dice
    if (diceRoll.isDouble) {
      state.currentPlayer!.incrementDoubleCount();
      state = state.withLogMessage('${state.currentPlayer!.name}: Çift zar sayısı: ${state.currentPlayer!.doubleDiceCount}/3');
      
      // Check for 3x double → Library Watch
      if (state.currentPlayer!.doubleDiceCount >= 3) {
        _handleTripleDouble();
        return;
      }
    } else {
      state.currentPlayer!.resetDoubleCount();
      state = state.withLogMessage('${state.currentPlayer!.name}: Çift zar sayacı sıfırlandı');
    }

    // Move to moving phase
    state = state.copyWith(
      turnPhase: TurnPhase.moving,
    );
    
    // Calculate new position
    moveCurrentPlayer(diceRoll.total);
  }

  // Move player - Step 2 of turn
  void moveCurrentPlayer(int diceTotal) {
    if (state.currentPlayer == null) return;
    
    final oldPosition = state.currentPlayer!.position;
    
    // Counter-clockwise movement: position increases
    // Board is 1-40, moving counter-clockwise means increasing position
    final newPosition = _calculateNewPosition(oldPosition, diceTotal);
    
    // Check if passed START (tile 1)
    final passedStart = _passedStart(oldPosition, newPosition);
    
    // Update player position
    state.currentPlayer!.position = newPosition;
    
    // Log movement
    state = state.copyWith(
      oldPosition: oldPosition,
      newPosition: newPosition,
      passedStart: passedStart,
      turnPhase: TurnPhase.resolvingTile,
    ).withLogMessage('${state.currentPlayer!.name} kutucuk $oldPosition\'den $newPosition\'e hareket etti');
    
    // Award stars if passed START
    if (passedStart) {
      state.currentPlayer!.addStars(passStartReward);
      state = state.withLogMessage('${state.currentPlayer!.name} BAŞLANGIÇ\'ten geçti! +$passStartReward yıldız');
    }
    
    // Resolve tile effect
    resolveCurrentTile();
  }

  // Calculate new position (counter-clockwise, 1-40)
  int _calculateNewPosition(int currentPosition, int diceTotal) {
    // Counter-clockwise: positions increase from 1 to 40, then wrap to 1
    int newPosition = (currentPosition + diceTotal - 1) % boardSize + 1;
    return newPosition;
  }

  // Check if player passed START (tile 1)
  bool _passedStart(int oldPosition, int newPosition) {
    // Passing from 40 to lower number means passed START (tile 1)
    if (oldPosition >= 35 && newPosition <= 5) {
      return true;
    }
    return false;
  }

  // Handle 3x double dice - Library Watch
  void _handleTripleDouble() {
    if (state.currentPlayer == null) return;
    
    state = state.withLogMessage('${state.currentPlayer!.name}: 3x Çift Zar! KÜTÜPHANE NÖBETİ tetiklendi!');
    
    state.currentPlayer!.enterLibraryWatch();
    state.currentPlayer!.position = 11; // Teleport to KÜTÜPHANE NÖBETİ
    
    state = state.copyWith(
      oldPosition: state.oldPosition,
      newPosition: 11,
      passedStart: false,
    ).withLogMessage('${state.currentPlayer!.name} kutucuk 11\'e (KÜTÜPHANE NÖBETİ) ışınlandı');
    
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
        tileLog += ' - Telif ücreti: ${tile.copyrightFee}';
        state = state.withLogMessage(tileLog);
        break;
      
      case TileType.publisher:
        tileLog += ' - Telif ücreti: ${tile.copyrightFee}';
        state = state.withLogMessage(tileLog);
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
    state = state.copyWith(
      turnPhase: TurnPhase.turnEnd,
    );
    
    endTurn();
  }

  // Handle corner tile effects
  void _handleCornerTile(Tile tile) {
    if (state.currentPlayer == null) return;
    
    switch (tile.cornerEffect) {
      case CornerEffect.baslangic:
        // BAŞLANGIÇ - handled by passing bonus
        state = state.withLogMessage('Kutucuk: ${tile.name} - Başlangıç kutucuğu');
        break;
      
      case CornerEffect.kutuphaneNobeti:
        // KÜTÜPHANE NÖBETİ - skip turns
        state.currentPlayer!.enterLibraryWatch();
        state = state.withLogMessage('KÜTÜPHANE NÖBETİ! ${state.currentPlayer!.name}: 2 tur ceza');
        break;
      
      case CornerEffect.imzaGunu:
        // İMZA GÜNÜ - skip next turn
        state.currentPlayer!.markTurnSkipped();
        state = state.withLogMessage('İMZA GÜNÜ! ${state.currentPlayer!.name}: Bir sonraki tur atlanacak');
        break;
      
      case CornerEffect.iflasRiski:
        // İFLAS RİSKİ - 50% star loss
        final lossAmount = (state.currentPlayer!.stars * 0.5).toInt();
        state.currentPlayer!.removeStars(lossAmount);
        state = state.withLogMessage('İFLAS RİSKİ! ${state.currentPlayer!.name}: -$lossAmount yıldız (%50 kayıp)');
        _checkBankruptcy();
        break;

      case null:
      break;

    }
  }

  // End turn - Step 4 of turn
  void endTurn() {
    if (state.currentPlayer == null) return;
    
    // Check for bankruptcy
    if (state.currentPlayer!.stars <= 0) {
      state.currentPlayer!.isBankrupt = true;
      state = state.withLogMessage('${state.currentPlayer!.name} İFLAS OLDU!');
      
      if (_isGameOver()) {
        _announceWinner();
        return;
      }
    }
    
    // Check if player rolled double (gets another turn)
    final wasDouble = state.lastDiceRoll?.isDouble ?? false;
    
    if (wasDouble) {
      state = state.withLogMessage('Çift zar attı! ${state.currentPlayer!.name} tekrar zar atacak.');
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
      state = state.copyWith(
        turnPhase: TurnPhase.waitingRoll,
        oldPosition: null,
        newPosition: null,
        passedStart: false,
      ).withLogMessage('Sıra: ${state.currentPlayer!.name}');
    }
  }

  // Check bankruptcy
  void _checkBankruptcy() {
    if (state.currentPlayer == null) return;
    
    if (state.currentPlayer!.stars <= 0) {
      state.currentPlayer!.isBankrupt = true;
      state = state.withLogMessage('${state.currentPlayer!.name} İFLAS OLDU!');
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
    
    state = state.copyWith(
      isGameOver: true,
      turnPhase: TurnPhase.turnEnd,
    ).withLogMessage('\n========================================');
    state = state.withLogMessage('KAZANAN: ${winner.name} - ${winner.stars} yıldız');
    state = state.withLogMessage('========================================\n');
    state = state.withLogMessage('OYUN BİTTİ!');
  }

  // Get player by ID
  Player? _getPlayerById(String playerId) {
    try {
      return state.players.firstWhere(
        (p) => p.id == playerId,
      );
    } catch (e) {
      return null;
    }
  }

  // Update player stars
  void _updatePlayerStars(String playerId, int newAmount) {
    final player = _getPlayerById(playerId);
    if (player != null) {
      player.stars = newAmount;
    }
  }

  // Update player position
  void _updatePlayerPosition(String playerId, int newPosition) {
    final player = _getPlayerById(playerId);
    if (player != null) {
      player.position = newPosition;
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
