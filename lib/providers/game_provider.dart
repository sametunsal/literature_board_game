import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../models/question.dart';
import '../models/card.dart';
import '../models/dice_roll.dart';
import '../models/turn_phase.dart';
import '../models/turn_event.dart';
import '../models/turn_result.dart';
import '../models/turn_history.dart';
import '../models/player_type.dart';
import '../constants/game_constants.dart';
import '../repositories/question_repository.dart';
import '../utils/turn_summary_generator.dart';
import '../core/game_rules_engine.dart';
import '../core/game_state_manager.dart';
import '../core/card_effect_handler.dart';
import '../core/bot_ai_controller.dart';
import '../core/turn_orchestrator.dart';

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

// Sentinel object to distinguish between "not passed" and "passed null"
const _undefined = Object();

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
  final int? turnStartStars;

  // Question answering state
  final QuestionState questionState;
  final Question? currentQuestion;
  final int? questionTimer;
  final int correctAnswers;
  final int wrongAnswers;

  // Card state
  final Card? currentCard;
  final String? currentCardOwnerId;

  // Turn result for UI feedback
  final TurnResult lastTurnResult;

  // Turn history - storage of completed turns
  final TurnHistory turnHistory;

  // Current turn transcript for tracking turn events
  final TurnTranscript currentTranscript;

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
    this.turnStartStars,
    this.isGameOver = false,
    this.questionState = QuestionState.waiting,
    this.currentQuestion,
    this.questionTimer = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.currentCard,
    this.currentCardOwnerId,
    this.lastTurnResult = TurnResult.empty,
    this.turnHistory = const TurnHistory.empty(),
    this.currentTranscript = const TurnTranscript.empty(),
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

  // Botların da zar atabilmesi için canRoll kontrolü sadece faza bakmalı
  bool get canRoll => turnPhase == TurnPhase.start;

  // Updated copyWith to properly handle nullable fields using _undefined sentinel
  GameState copyWith({
    List<Player>? players,
    List<Tile>? tiles,
    List<Question>? questionPool,
    List<Card>? sansCards,
    List<Card>? kaderCards,
    int? currentPlayerIndex,
    Object? lastDiceRoll = _undefined, // Nullable field
    Object? lastMessage = _undefined, // Nullable field
    List<String>? logMessages,
    TurnPhase? turnPhase,
    Object? oldPosition = _undefined, // Nullable field
    Object? newPosition = _undefined, // Nullable field
    bool? passedStart,
    Object? turnStartStars = _undefined, // Nullable field
    bool? isGameOver,
    QuestionState? questionState,
    Object? currentQuestion = _undefined, // Nullable field
    Object? questionTimer = _undefined, // Nullable field
    int? correctAnswers,
    int? wrongAnswers,
    Object? currentCard = _undefined, // Nullable field
    Object? currentCardOwnerId = _undefined, // Nullable field
    TurnResult? lastTurnResult,
    TurnHistory? turnHistory,
    TurnTranscript? currentTranscript,
  }) {
    return GameState(
      players: players ?? this.players,
      tiles: tiles ?? this.tiles,
      questionPool: questionPool ?? this.questionPool,
      sansCards: sansCards ?? this.sansCards,
      kaderCards: kaderCards ?? this.kaderCards,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      // Handle nullable fields: if _undefined, keep old value; otherwise cast to type (allows null)
      lastDiceRoll: lastDiceRoll == _undefined
          ? this.lastDiceRoll
          : (lastDiceRoll as DiceRoll?),
      lastMessage: lastMessage == _undefined
          ? this.lastMessage
          : (lastMessage as String?),
      logMessages: logMessages ?? this.logMessages,
      turnPhase: turnPhase ?? this.turnPhase,
      oldPosition: oldPosition == _undefined
          ? this.oldPosition
          : (oldPosition as int?),
      newPosition: newPosition == _undefined
          ? this.newPosition
          : (newPosition as int?),
      passedStart: passedStart ?? this.passedStart,
      turnStartStars: turnStartStars == _undefined
          ? this.turnStartStars
          : (turnStartStars as int?),
      isGameOver: isGameOver ?? this.isGameOver,
      questionState: questionState ?? this.questionState,
      currentQuestion: currentQuestion == _undefined
          ? this.currentQuestion
          : (currentQuestion as Question?),
      questionTimer: questionTimer == _undefined
          ? this.questionTimer
          : (questionTimer as int?),
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      currentCard: currentCard == _undefined
          ? this.currentCard
          : (currentCard as Card?),
      currentCardOwnerId: currentCardOwnerId == _undefined
          ? this.currentCardOwnerId
          : (currentCardOwnerId as String?),
      lastTurnResult: lastTurnResult ?? this.lastTurnResult,
      turnHistory: turnHistory ?? this.turnHistory,
      currentTranscript: currentTranscript ?? this.currentTranscript,
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
  // Guard flag to prevent re-entry during turn processing
  bool _isProcessingTurn = false;

  // Guard flag to prevent recursive calls to applyCardEffect
  bool _isApplyingEffect = false;

  // --- YENİ MİMARİ ARAÇLARI ---
  final _rulesEngine = GameRulesEngine();

  // StateManager her çağrıldığında mevcut durumu (state) sarmalayacak
  GameStateManager get _stateManager => GameStateManager(state);

  // Kart efekt yöneticisi
  CardEffectHandler get _cardHandler => CardEffectHandler(
        stateManager: _stateManager,
        rulesEngine: _rulesEngine,
      );

  // Bot zeka yöneticisi
  BotAIController get _botAI => BotAIController(rulesEngine: _rulesEngine);

  // Oyun akış yönetmeni
  TurnOrchestrator get _orchestrator => TurnOrchestrator(
        stateManager: _stateManager,
        rulesEngine: _rulesEngine,
        botAI: _botAI,
      );
  // ---------------------------

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

  // ========================================================================
  // TRANSCRIPT LOGGING
  // ========================================================================

  /// Log an event to the current turn transcript
  void _logEvent(
    TurnEventType type, {
    String? description,
    Map<String, dynamic>? data,
  }) {
    final newTranscript = state.currentTranscript.add(
      type,
      description: description,
      data: data,
    );
    state = state.copyWith(currentTranscript: newTranscript);

    // Also add to log messages for backward compatibility
    if (description != null) {
      state = state.withLogMessage(description);
    }
  }

  // Initialize game with data
  void initializeGame({
    required List<Player> players,
    required List<Tile> tiles,
    List<Question>? questionPool,
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
          turnStartStars: players.isNotEmpty ? players[0].stars : null,
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
  Future<void> playTurn() async {
    debugPrint('🎮 playTurn() called - Current phase: ${state.turnPhase}');

    // Eğer oyun bittiyse dur
    if (state.isGameOver) return;

    // YENİ YAPI: Orkestratörden talimat al
    // (Şu anlık manuel switch-case ile yapıyoruz, sonra tamamen orchestrator'a geçecek)

    switch (state.turnPhase) {
      case TurnPhase.start:
        // Bot ise otomatik zar at
        if (state.currentPlayer?.type == PlayerType.bot) {
          debugPrint('🤖 Bot turn starting...');
          await Future.delayed(const Duration(seconds: 1));
          rollDice();
        } else {
          // İnsan oyuncu: UI üzerinden rollDice() çağrılmasını bekle.
          debugPrint('👤 İnsan oyuncu sırası. Butona basılması bekleniyor.');
        }
        break;

      case TurnPhase.diceRolled:
        // Zar atıldı, hareket bekleniyor (Otomatik)
        // moveCurrentPlayer içinde otomatik çağrılmıyorsa burada çağır
        // Ama biz moveCurrentPlayer'ı rollDice içinde çağırdık.
        // Sadece animasyon bekleme süresi gerekebilir.
        break;

      case TurnPhase.moved:
        // Hareket bitti, Tile çözümle
        debugPrint('🎮 Auto-advance directive: resolveTile');
        await Future.delayed(const Duration(milliseconds: 500)); // Animasyon payı
        resolveTile();
        break;

      case TurnPhase.questionWaiting:
        // Bot ise cevap ver
        if (state.currentPlayer?.type == PlayerType.bot) {
          await Future.delayed(const Duration(seconds: 2));
          _botAnswerQuestion();
        }
        break;

      case TurnPhase.cardWaiting:
        // Bot ise kart çek (UI açılmadan)
        if (state.currentPlayer?.type == PlayerType.bot) {
          await Future.delayed(const Duration(seconds: 1));
          if (state.currentCard != null) {
            applyCardEffect(state.currentCard!);
          } else {
            // Should not happen if drawCard works, but fallback
            endTurn();
          }
        }
        break;

      case TurnPhase.questionResolved:
        // Soru çözüldü, satın alma kararı veya tur sonu
        if (state.currentPlayer?.type == PlayerType.bot) {
          await Future.delayed(const Duration(seconds: 1));
          _handleBotCopyrightDecision();
        }
        break;

      case TurnPhase.turnEnded:
        // Tur bitti, sonraki tura geç
        debugPrint('🎮 Auto-advance directive: nextTurn');
        if (state.currentPlayer?.type == PlayerType.bot) {
          await Future.delayed(const Duration(seconds: 1));
          startNextTurn();
        }
        break;

      default:
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

  // Roll dice - Step 1 of turn (REFACTORED)
  void rollDice() {
    debugPrint('🎲 rollDice() called');

    if (state.isGameOver) return;

    // Faz kontrolü: Start veya TurnEnded (yeni tur başı) fazlarına izin ver
    if (state.turnPhase != TurnPhase.start &&
        state.turnPhase != TurnPhase.turnEnded) {
      debugPrint('⛔ rollDice engellendi: Yanlış faz (${state.turnPhase})');
      return;
    }

    // canRoll kontrolü
    if (!state.canRoll) {
      debugPrint('⛔ rollDice engellendi: canRoll false');
      return;
    }

    if (state.currentPlayer == null) return;

    // 1. KURAL MOTORU: Zarı at
    final diceRoll = _rulesEngine.rollDice();
    final currentPlayer = state.currentPlayer!;

    // 2. DURUM YÖNETİCİSİ: Fazı güncelle
    final manager = _stateManager; // Geçici yönetici oluştur
    manager.setTurnPhase(TurnPhase.diceRolled);
    debugPrint('🎲 Phase updated to: diceRolled');

    // 3. OYUNCU GÜNCELLEMESİ: Zar bilgisini oyuncuya işle
    final updatedPlayer = currentPlayer.copyWith(
      lastRoll: diceRoll.total,
      doubleDiceCount: diceRoll.isDouble
          ? currentPlayer.doubleDiceCount + 1
          : 0,
    );
    manager.updatePlayer(updatedPlayer);

    // 4. LOGLAMA: Zarı kaydet ve log ekle
    manager.setLastDiceRoll(diceRoll);

    String logMessage =
        '${currentPlayer.name} zar attı: ${diceRoll.die1} + ${diceRoll.die2} = ${diceRoll.total}';
    if (diceRoll.isDouble) logMessage += ' (ÇİFT!)';
    manager.addLogMessage(logMessage);

    // Transkript Logu
    _logEvent(
      TurnEventType.diceRoll,
      description: '${currentPlayer.name} zar attı: ${diceRoll.total}',
      data: {
        'die1': diceRoll.die1,
        'die2': diceRoll.die2,
        'total': diceRoll.total,
        'isDouble': diceRoll.isDouble,
      },
    );

    // Çift zar durumunu bildir
    if (diceRoll.isDouble) {
      manager.addLogMessage(
        '${currentPlayer.name}: Çift zar sayısı: ${updatedPlayer.doubleDiceCount}/3',
      );
    } else {
      manager.addLogMessage(
        '${currentPlayer.name}: Çift zar sayacı sıfırlandı',
      );
    }

    // --- DEĞİŞİKLİKLERİ UYGULA ---
    state = manager.state;

    // 5. ORKESTRASYON: Hareket veya Ceza
    // 3 çift zar kontrolü (Kural Motoru üzerinden yapılmalı ama şimdilik burada)
    if (updatedPlayer.doubleDiceCount >= 3) {
      _handleTripleDouble();
      return;
    }

    // İnsan oyuncu ise otomatik hareket et
    if (currentPlayer.type == PlayerType.human) {
      moveCurrentPlayer(diceRoll.total);
    }
  }

  // Move player - Step 2 of turn (REFACTORED)
  void moveCurrentPlayer(int diceTotal) {
    debugPrint('🚶 moveCurrentPlayer() called - Dice total: $diceTotal');
    if (!_requirePhase(TurnPhase.diceRolled, 'moveCurrentPlayer')) return;
    if (state.currentPlayer == null) return;

    final currentPlayer = state.currentPlayer!;
    final oldPosition = currentPlayer.position;

    // 1. KURAL MOTORU: Yeni pozisyonu hesapla
    final newPosition = _rulesEngine.calculateNewPosition(
      oldPosition,
      diceTotal,
      GameConstants.boardSize,
    );

    // Başlangıç noktasından geçti mi?
    final passedStart = _rulesEngine.passedStart(
      oldPosition,
      diceTotal,
      GameConstants.boardSize,
    );

    debugPrint(
      '🚶 Player moving: $oldPosition → $newPosition (passed start: $passedStart)',
    );

    // 2. DURUM YÖNETİCİSİ: Oyuncuyu güncelle
    final manager = _stateManager;

    // Konumu güncelle
    var updatedPlayer = currentPlayer.copyWith(position: newPosition);

    // Başlangıç ödülünü ver
    if (passedStart) {
      updatedPlayer = updatedPlayer.copyWith(
        stars: updatedPlayer.stars + GameConstants.passStartReward,
      );
      manager.addLogMessage(
        '${currentPlayer.name} BAŞLANGIÇ\'tan geçti! +${GameConstants.passStartReward} yıldız',
      );
    }

    manager.updatePlayer(updatedPlayer);

    // 3. DURUM YÖNETİCİSİ: Oyun durumu güncellemeleri
    // Not: GameStateManager'a bu özel alanları (oldPosition vb.) eklemedik,
    // o yüzden şimdilik manuel copyWith ile devam ediyoruz.
    var newState = manager.state.copyWith(
      oldPosition: oldPosition,
      newPosition: newPosition,
      passedStart: passedStart,
      turnPhase: TurnPhase.moved,
    );

    // Log ekle
    newState = newState.withLogMessage(
      '${currentPlayer.name} kutucuk $oldPosition\'den $newPosition\'e hareket etti',
    );

    state = newState;
    debugPrint('🚶 Phase updated to: moved');

    // Döngüyü tetikle
    playTurn();
  }

  // Calculate new position (counter-clockwise, 0-39)
  int _calculateNewPosition(int currentPosition, int diceTotal) {
    // Correct 0-based wrapping: (0..39)
    return (currentPosition + diceTotal) % GameConstants.boardSize;
  }

  // Check if player passed START (tile 1)
  bool _passedStart(int oldPosition, int diceTotal) {
    // Crossing the board size boundary means we wrapped past START
    return (oldPosition + diceTotal) >= GameConstants.boardSize;
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

  // Resolve tile effect (REFACTORED)
  void resolveTile() {
    debugPrint('🏁 resolveTile() called');
    if (!_requirePhase(TurnPhase.moved, 'resolveTile')) return;
    if (state.currentPlayer == null || state.newPosition == null) return;

    final currentPlayer = state.currentPlayer!;
    final tileId = state.newPosition!;

    // Tile bul
    final tile = state.tiles.firstWhere(
      (t) => t.id == tileId,
      orElse: () => state.tiles[0],
    );

    debugPrint('📍 Player landed on: ${tile.name} (${tile.type})');

    // 2. Tile Tipine Göre İşlem
    final manager = _stateManager;

    // CRITICAL FIX: Transition to tileResolved phase BEFORE processing
    // This allows methods like _showQuestion and _handleTaxTile to pass their guards
    // Direct state update to ensure atomic phase change
    state = state.copyWith(turnPhase: TurnPhase.tileResolved);
    // Sync manager with new state
    manager.updateState(state);

    debugPrint('🏁 Phase updated to: ${state.turnPhase} (Manual Override)');
    manager.setTurnPhase(TurnPhase.tileResolved);
    state = manager.state; // Sync state immediately
    debugPrint('🏁 Phase updated to: tileResolved');

    switch (tile.type) {
      case TileType.corner:
        // Köşe taşı etkileri
        _handleCornerTile(tile);
        // Faz güncelle: Tur bitti veya devam ediyor
        if (state.turnPhase != TurnPhase.turnEnded) {
          manager.setTurnPhase(TurnPhase.turnEnded);
          state = manager.state;
          endTurn(); // Otomatik tur bitir
        }
        break;

      case TileType.book:
      case TileType.publisher: // Yayınevleri de soru sorar (Eğer sahibi yoksa)
        if (tile.owner == null || tile.owner == currentPlayer.id) {
          // Sahibi yoksa veya kendisiyse -> Soru Sor
          _showQuestion(tile);
        } else {
          // Başkasının -> Kira Öde
          payRent();
          // Kira ödendikten sonra tur biter
          if (!state.currentPlayer!.isBankrupt) { // İflas etmediyse
            manager.setTurnPhase(TurnPhase.turnEnded);
            state = manager.state;
            endTurn();
          }
        }
        break;

      case TileType.chance:
      case TileType.fate:
        // Kart çekme
        // Draw card here, as UI might rely on state.currentCard
        if (state.currentCard == null) {
          drawCard(
            tile.type == TileType.chance ? CardType.sans : CardType.kader,
          );
        }
        break;

      case TileType.tax:
        _handleTaxTile(tile);
        // Vergi sonrası tur biter
        if (!state.currentPlayer!.isBankrupt) {
          manager.setTurnPhase(TurnPhase.turnEnded);
          state = manager.state;
          endTurn();
        }
        break;

      default:
        // Bilinmeyen tip -> Turu bitir
        debugPrint("⚠️ Bilinmeyen tile tipi: ${tile.type}");
        manager.setTurnPhase(TurnPhase.turnEnded);
        state = manager.state;
        endTurn();
    }
  }

  // Show question (REFACTORED)
  void _showQuestion(Tile tile) {
    if (!_requirePhase(TurnPhase.tileResolved, '_showQuestion')) return;
    if (state.currentPlayer == null) return;

    final currentPlayer = state.currentPlayer!;
    final manager = _stateManager;

    // Faz güncelle
    manager.setTurnPhase(TurnPhase.questionWaiting);

    // Kategori belirle
    // Not: Repository kullanımı ilerde RulesEngine içine de taşınabilir ama şimdilik burada kalabilir
    // Ancak soru SEÇİMİ (Random vs Easy) RulesEngine'e geçiyor.
    final category = tile.questionCategory ?? QuestionCategory.benKimim;

    // Soru havuzunu filtrele (Kategoriye göre)
    // Not: Normalde repository'den çekeriz ama burada state'deki pool'u kullanıyoruz.
    // Basitlik için tüm havuzu gönderiyoruz, RulesEngine içindeki selectQuestion metodunu güncelleyebiliriz
    // veya şimdilik repository mantığını koruyup sadece easy/random seçimini devredebiliriz.

    // Mevcut yapıyı koruyarak daha temiz hale getirelim:
    List<Question> categoryPool = state.questionPool
        .where((q) => q.category == category)
        .toList();

    // Eğer kategori boşsa genel havuzdan seç
    if (categoryPool.isEmpty) categoryPool = state.questionPool;

    // Easy mode kontrolü
    bool isEasyMode = currentPlayer.easyQuestionNext;

    // 1. KURAL MOTORU: Soruyu seç
    final question = _rulesEngine.selectQuestion(categoryPool, easyMode: isEasyMode);

    // Easy flag'ini tüket
    if (isEasyMode) {
      manager.updatePlayer(currentPlayer.copyWith(easyQuestionNext: false));
    }

    // 2. LOGLAMA VE STATE
    manager.setCurrentQuestion(question);

    // Timer ve durum ayarla
    // Not: Bu kısımlar GameStateManager'a eklenebilir ama şimdilik manuel copyWith yapıyoruz
    state = manager.state.copyWith(
      questionState: QuestionState.answering,
      questionTimer: GameConstants.questionTimerDuration,
    );

    manager.addLogMessage('${tile.name} için soru soruluyor...');
    state = manager.state;
  }

  // Bot auto-answer question (REFACTORED)
  void _botAnswerQuestion() {
    debugPrint('🤖 Bot answering question...');
    if (state.currentQuestion == null) return;

    // YENİ YAPI: Kararı BotAI versin
    final shouldAnswerCorrectly = _botAI.shouldAnswerCorrectly(
      state.currentQuestion!,
    );

    if (shouldAnswerCorrectly) {
      answerQuestionCorrect();
      debugPrint('🤖 Bot answered correctly');
    } else {
      answerQuestionWrong();
      debugPrint('🤖 Bot answered incorrectly');
    }

    // Advance phase
    final manager = _stateManager;
    manager.setTurnPhase(TurnPhase.questionResolved);
    state = manager.state;
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

    // Store the drawn card in the game state with owner ID
    state = state.copyWith(
      currentCard: drawnCard,
      currentCardOwnerId: state.currentPlayer?.id,
      turnPhase: TurnPhase.cardWaiting,
    );

    // UI FEEDBACK LOG: Card description
    final cardTypeName = cardType == CardType.sans ? 'ŞANS' : 'KADER';
    state = state.withLogMessage(
      '$cardTypeName kartı çekildi: ${drawnCard.description}',
    );
  }

  // Apply card effect (REFACTORED)
  void applyCardEffect(Card card) {
    // GUARD CHECKS
    if (_isApplyingEffect) {
      debugPrint("🛑 Çakışma önlendi: applyCardEffect zaten çalışıyor.");
      return;
    }
    if (state.currentPlayer == null) return;

    if (state.turnPhase != TurnPhase.cardWaiting) {
      debugPrint("🚫 Kart etkisi yanlış fazda tetiklendi: ${state.turnPhase}");
      return;
    }

    if (state.currentCardOwnerId != state.currentPlayer?.id) {
      debugPrint("🚫 kart sahibi eşleşmiyor.");
      return;
    }

    // LOCK & EXECUTE
    _isApplyingEffect = true;

    try {
      // Transkript Logu (Hala burada tutuyoruz çünkü UI event'i)
      _logEvent(
        TurnEventType.cardApplied,
        description: 'Kart Çekildi: ${card.description}',
        data: {'cardId': card.id, 'type': card.type.toString()},
      );

      // YENİ YAPI: İşi uzmana devret
      final handler = _cardHandler;
      handler.applyCardEffect(card, state.currentPlayer!);

      // StateManager güncellemeleri yaptı, state'i senkronize et
      state = handler.stateManager.state;

      debugPrint("✅ Kart işlemi tamamlandı (Handler).");

    } catch (e) {
      debugPrint("Hata: $e");
    } finally {
      // Handler zaten state'i temizledi ama flag'i burada kaldırıyoruz
      _isApplyingEffect = false;
    }
  }

  // Auto-advance directive for bot and human turns
  String? getAutoAdvanceDirective() {
    final isBot = state.currentPlayer?.type == PlayerType.bot;

    // Humans need to manually click button for Phase.start and questionWaiting
    // Bots auto-advance through all phases
    // Both auto-advance through all other phases
    switch (state.turnPhase) {
      case TurnPhase.start:
        // Only bots auto-roll dice, humans must click button
        return isBot ? 'rollDice' : null;
      case TurnPhase.diceRolled:
        return 'movePlayer';
      case TurnPhase.moved:
        return 'resolveTile';
      case TurnPhase.tileResolved:
        return 'handleTileEffect';
      case TurnPhase.cardWaiting:
        // HARD BLOCK: applyCard ONLY when ALL conditions are met
        if (state.turnPhase == TurnPhase.cardWaiting &&
            state.currentCard != null &&
            state.currentCardOwnerId == state.currentPlayer?.id &&
            state.currentPlayer?.type == PlayerType.bot) {
          return 'applyCard';
        }
        return null;
      case TurnPhase.questionWaiting:
        // Bots auto-answer questions, humans wait for input
        return isBot ? 'answerQuestion' : null;
      case TurnPhase.cardApplied:
      case TurnPhase.questionResolved:
      case TurnPhase.taxResolved:
        return 'endTurn';
      case TurnPhase.copyrightPurchased:
        // Bots auto-decide on copyright purchase, humans wait for dialog
        return isBot ? 'handleCopyrightDecision' : null;
      case TurnPhase.turnEnded:
        // CRITICAL FIX: Bots auto-advance to next turn, humans wait for summary button
        return isBot ? 'nextTurn' : null;
    }
  }

  /// Complete copyright purchase for human players
  void completeCopyrightPurchase() {
    if (state.currentPlayer == null) return;
    if (state.newPosition == null) return;

    final currentPlayer = state.currentPlayer!;
    final tileId = state.newPosition!;
    final tile = state.tiles.firstWhere(
      (t) => t.id == tileId,
      orElse: () => state.tiles[0],
    );

    // Validate purchase is possible
    if (!tile.canBeOwned) {
      debugPrint('⛔ Tile cannot be owned: ${tile.name}');
      return;
    }

    if (tile.owner != null) {
      debugPrint('⛔ Tile already owned by: ${tile.owner}');
      return;
    }

    final price = tile.purchasePrice ?? 0;
    if (currentPlayer.stars < price) {
      debugPrint('⛔ Player cannot afford: ${currentPlayer.stars} < $price');
      return;
    }

    // Perform the purchase transaction
    final updatedPlayer = currentPlayer.copyWith(
      stars: currentPlayer.stars - price,
      ownedTiles: [...currentPlayer.ownedTiles, tileId],
    );
    final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);

    // Update tile owner
    final updatedTile = tile.copyWith(owner: currentPlayer.id);
    final updatedTiles = _updateTileInList(state.tiles, updatedTile);

    // CRITICAL: Set phase to questionResolved (valid for endTurn)
    // This allows playTurn() to call endTurn() without assertion error
    state = state.copyWith(
      turnPhase: TurnPhase.questionResolved,
      players: updatedPlayers,
      tiles: updatedTiles,
    );

    // GAMEPLAY LOG: Copyright purchase
    state = state.withLogMessage(
      '${currentPlayer.name} ${tile.name} telifini satın aldı! -$price yıldız',
    );

    // Log event to transcript
    _logEvent(
      TurnEventType.copyrightPurchased,
      description: '${currentPlayer.name} ${tile.name} telifini satın aldı',
      data: {'tileId': tileId, 'tileName': tile.name, 'price': price},
    );
  }

  /// Decline copyright purchase for human players
  void declineCopyrightPurchase() {
    if (state.currentPlayer == null) return;

    // CRITICAL: Set phase to questionResolved (valid for endTurn)
    // This allows playTurn() to call endTurn() without assertion error
    state = state.copyWith(turnPhase: TurnPhase.questionResolved);

    // GAMEPLAY LOG: Purchase declined
    state = state.withLogMessage(
      '${state.currentPlayer!.name} telif satın almayı reddetti.',
    );
  }

  // Bot copyright purchase decision (REFACTORED)
  void _handleBotCopyrightDecision() {
    debugPrint('🤖 Bot making copyright purchase decision...');

    if (state.currentPlayer == null || state.newPosition == null) return;

    final currentPlayer = state.currentPlayer!;
    final tileId = state.newPosition!;

    // Tile bul
    final tile = state.tiles.firstWhere(
      (t) => t.id == tileId,
      orElse: () => state.tiles[0],
    );

    final manager = _stateManager;

    // Temel kontroller
    if (!tile.canBeOwned || tile.owner != null) {
      debugPrint('🤖 Bot skipping - not purchasable');
      manager.setTurnPhase(TurnPhase.questionResolved);
      state = manager.state;
      endTurn();
      return;
    }

    // YENİ YAPI: Kararı BotAI versin
    final shouldPurchase = _botAI.shouldPurchaseCopyright(tile, currentPlayer);

    if (shouldPurchase) {
      final price = tile.purchasePrice ?? 0;

      // Satın alma işlemini yap
      final updatedPlayer = currentPlayer.copyWith(
        stars: currentPlayer.stars - price,
        ownedTiles: [...currentPlayer.ownedTiles, tileId],
      );
      manager.updatePlayer(updatedPlayer);

      // Tile sahibini güncelle
      final updatedTile = tile.copyWith(owner: currentPlayer.id);
      // Not: updateTile metodunu StateManager'a eklemediysek,
      // tiles listesini manuel güncelleyip state'e verelim.
      // GameStateManager içinde updateTile yoksa şu anlık manuel yapalım:
      final updatedTiles = state.tiles
          .map((t) => t.id == tile.id ? updatedTile : t)
          .toList();

      // State güncelle (Tiles değişikliğini StateManager'a bildir)
      // GameStateManager şimdilik sadece oyuncu odaklı, bu yüzden manuel senkronizasyon yapıyoruz.
      // Önce manager'ın kendi state'ini güncelleyelim ki sonraki işlemler eski state'i kullanmasın.
      manager.updateState(manager.state.copyWith(tiles: updatedTiles));

      // Loglama
      manager.addLogMessage(
        '${currentPlayer.name} ${tile.name} telifini satın aldı! -$price yıldız',
      );

      _logEvent(
        TurnEventType.copyrightPurchased,
        description: '${currentPlayer.name} ${tile.name} telifini satın aldı',
        data: {'tileId': tileId, 'tileName': tile.name, 'price': price},
      );

      // Faz güncelle ve turu bitir
      manager.setTurnPhase(TurnPhase.questionResolved);
      state = manager.state;
      endTurn();

    } else {
      debugPrint('🤖 Bot declining purchase');
      manager.setTurnPhase(TurnPhase.questionResolved);
      state = manager.state;
      endTurn();
    }
  }

  // Helper method to update a tile in tiles list immutably
  List<Tile> _updateTileInList(List<Tile> tiles, Tile updatedTile) {
    return tiles.map((t) => t.id == updatedTile.id ? updatedTile : t).toList();
  }

  // Pay rent to tile owner
  void payRent() {
    if (state.currentPlayer == null) return;
    if (state.newPosition == null) return;

    final currentPlayer = state.currentPlayer!;
    final tileId = state.newPosition!;
    final tile = state.tiles.firstWhere(
      (t) => t.id == tileId,
      orElse: () => state.tiles[0],
    );

    // Check if tile can be owned and has an owner
    if (!tile.canBeOwned || tile.owner == null) {
      return;
    }

    // Check if current player owns this tile (no rent to self)
    if (tile.owner == currentPlayer.id) {
      state = state.withLogMessage(
        '${currentPlayer.name} kendi mülkü ${tile.name} üzerinde',
      );
      return;
    }

    // Find the owner
    final owner = state.players.firstWhere(
      (p) => p.id == tile.owner,
      orElse: () => state.players.first,
    );

    // Calculate rent amount
    final rentAmount = tile.copyrightFee ?? 0;

    // Deduct rent from current player
    final updatedCurrentPlayer = currentPlayer.copyWith(
      stars: (currentPlayer.stars - rentAmount).clamp(
        GameConstants.bankruptcyThreshold,
        currentPlayer.stars,
      ),
    );

    // Add rent to owner
    final updatedOwner = owner.copyWith(stars: owner.stars + rentAmount);

    // Update both players
    final updatedPlayers = _updatePlayerInList(
      _updatePlayerInList(state.players, updatedCurrentPlayer),
      updatedOwner,
    );

    state = state.copyWith(players: updatedPlayers);

    // GAMEPLAY LOG: Rent payment
    state = state.withLogMessage(
      '${currentPlayer.name} ${owner.name}\'a $rentAmount yıldız kira ödedi (${tile.name})',
    );

    // Log event to transcript
    _logEvent(
      TurnEventType.rentPaid,
      description: '${currentPlayer.name} ${owner.name}\'a kira ödedi',
      data: {
        'tileId': tileId,
        'tileName': tile.name,
        'rentAmount': rentAmount,
        'ownerId': owner.id,
        'ownerName': owner.name,
      },
    );

    // Check for bankruptcy
    _checkBankruptcy();
  }

  // Tick question timer
  void tickQuestionTimer() {
    if (state.questionTimer == null || state.questionTimer! <= 0) return;

    final newTimer = state.questionTimer! - 1;
    state = state.copyWith(questionTimer: newTimer);
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

    // End game if only one or zero active players remain
    if (_isGameOver()) {
      _announceWinner();
    }
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
          turnPhase: TurnPhase.copyrightPurchased,
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
          turnPhase: TurnPhase.questionResolved,
        )
        .withLogMessage(
          '${currentPlayer.name} yanlış cevap verdi! -$penalty yıldız kaybetti.',
        );
  }

  // Skip question
  void skipQuestion() {
    // GAMEPLAY LOG: Question skipped
    state = state
        .copyWith(
          questionState: QuestionState.skipped,
          turnPhase: TurnPhase.questionResolved,
        )
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
        // Design spec: Free parking / no action
        state = state.withLogMessage('İMZA GÜNÜ! Güvenli alan, işlem yok.');
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
  // CRITICAL FIX: This method now PAUSES at turnEnded instead of immediately moving to next player
  void endTurn() {
    // Allow ending turn from multiple phases (some tiles might resolve without further action)
    if (state.turnPhase != TurnPhase.taxResolved &&
        state.turnPhase != TurnPhase.cardApplied &&
        state.turnPhase != TurnPhase.questionResolved &&
        state.turnPhase != TurnPhase.tileResolved) {
      debugPrint(
        '⛔ Phase Guard: endTurn called in ${state.turnPhase}, expected one of [taxResolved, cardApplied, questionResolved, tileResolved]',
      );
      assert(false, 'Invalid turn phase for endTurn');
      return;
    }
    if (state.currentPlayer == null) return;

    final currentPlayer = state.currentPlayer!;
    Player? updatedPlayer;

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

    // Generate TurnResult using TurnSummaryGenerator
    // Calculate stars delta based on turn start snapshot
    final startStars = state.turnStartStars ?? currentPlayer.stars;
    final effectivePlayer = updatedPlayer ?? currentPlayer;
    final starsDelta = effectivePlayer.stars - startStars;

    // Create a safe transcript
    final transcript = state.currentTranscript;

    final turnResult = TurnSummaryGenerator.generateTurnResult(
      playerIndex: state.currentPlayerIndex,
      transcript: transcript,
      startPosition: state.oldPosition ?? currentPlayer.position,
      endPosition: state.newPosition ?? currentPlayer.position,
      starsDelta: starsDelta,
    );

    // Debug logging to verify playerIndex is correct
    debugPrint('📊 TurnResult playerIndex: ${turnResult.playerIndex}');
    debugPrint('📊 Current playerIndex: ${state.currentPlayerIndex}');

    // Check if player rolled double (gets another turn)
    final wasDouble = state.lastDiceRoll?.isDouble ?? false;

    if (wasDouble) {
      // Update lastTurnResult and turnHistory first
      state = state.copyWith(
        lastTurnResult: turnResult,
        turnHistory: state.turnHistory.add(turnResult),
      );

      // GAMEPLAY LOG: Double dice bonus turn
      state = state.withLogMessage(
        'Çift zar attı! ${currentPlayer.name} tekrar zar atacak.',
      );
      state = state.copyWith(
        turnPhase: TurnPhase.start,
        oldPosition: null,
        newPosition: null,
        passedStart: false,
        turnStartStars: currentPlayer.stars,
        // Clear per-turn artifacts before the bonus turn begins
        currentQuestion: null,
        questionState: QuestionState.waiting,
        questionTimer: 0,
        currentCard: null,
        lastDiceRoll: null,
        currentTranscript: const TurnTranscript.empty(),
      );
      return;
    }

    // CRITICAL FIX: Update lastTurnResult AND turnPhase in single atomic operation
    // This prevents race condition where UI sees turnEnded before lastTurnResult is set
    state = state.copyWith(
      lastTurnResult: turnResult,
      turnHistory: state.turnHistory.add(turnResult),
      turnPhase: TurnPhase.turnEnded,
    );

    debugPrint('🎬 Turn ended - waiting for startNextTurn()');
  }

  // CRITICAL FIX: New public method to start next turn
  // Called by turn_summary_overlay.dart "Devam" button for humans
  // Called by game_view.dart orchestration for bots
  void startNextTurn() {
    debugPrint('▶️ startNextTurn() called');

    // CRITICAL: Reset private guard flag before clearing state
    _isApplyingEffect = false;

    // HARD RESET: Clear ALL card/question/effect-related state in single operation
    // Note: We pass null to nullable fields, and the copyWith method
    // handles it correctly using the _undefined sentinel to clear them.
    state = state.copyWith(
      turnPhase: TurnPhase.start,
      currentCard: null,
      currentCardOwnerId: null,
      currentQuestion: null,
      questionState: QuestionState.waiting,
      questionTimer: 0,
      lastDiceRoll: null,
      currentTranscript: const TurnTranscript.empty(),
    );

    // Move to next player index
    var nextIndex = (state.currentPlayerIndex + 1) % state.players.length;

    // Skip bankrupt players
    int attempts = 0;
    final totalPlayers = state.players.length;
    while (state.players[nextIndex].isBankrupt && attempts < totalPlayers) {
      state = state.copyWith(currentPlayerIndex: nextIndex);
      nextIndex = (nextIndex + 1) % totalPlayers;
      attempts++;
    }

    state = state.copyWith(
      currentPlayerIndex: nextIndex,
      turnStartStars: state.players[nextIndex].stars,
    );

    // UI FEEDBACK LOG: Turn transition
    state = state.withLogMessage('Sıra: ${state.players[nextIndex].name}');
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

  /// Reset game to initial state while keeping player names and types
  /// This allows restarting the game without recreating all player data
  void resetGame() {
    // Preserve player names, colors, and types
    final preservedPlayers = state.players.map((p) {
      return Player(
        id: p.id,
        name: p.name,
        color: p.color,
        type: p.type,
        stars: GameConstants.initialStars,
        position: 0, // Start position
      );
    }).toList();

    // Reset to initial game state
    state = GameState(
      players: preservedPlayers,
      tiles: state.tiles
          .map((t) => t.copyWith(owner: null))
          .toList(), // Clear ownership
      questionPool: state.questionPool,
      sansCards: state.sansCards,
      kaderCards: state.kaderCards,
      currentPlayerIndex: 0,
      turnPhase: TurnPhase.start,
      turnStartStars: GameConstants.initialStars,
    ).withLogMessage('Oyun sıfırlandı! Yeni oyun başlıyor...');

    debugPrint('🔄 Game reset successfully');
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
