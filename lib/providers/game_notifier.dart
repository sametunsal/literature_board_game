import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/board_tile.dart';
import '../models/game_enums.dart';
import '../models/game_card.dart';
import '../domain/entities/question.dart';
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
  final bool showPurchaseDialog;
  final bool showCardDialog;
  final bool showUpgradeDialog;
  final bool showRentDialog;
  final bool showLibraryPenaltyDialog;
  final bool showImzaGunuDialog;
  final bool showTurnSkippedDialog;

  // Rent notification info
  final String? rentOwnerName;
  final int? rentAmount;

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
    this.showPurchaseDialog = false,
    this.showCardDialog = false,
    this.showUpgradeDialog = false,
    this.showRentDialog = false,
    this.showLibraryPenaltyDialog = false,
    this.showImzaGunuDialog = false,
    this.showTurnSkippedDialog = false,
    this.rentOwnerName,
    this.rentAmount,
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
    bool? showPurchaseDialog,
    bool? showCardDialog,
    bool? showUpgradeDialog,
    bool? showRentDialog,
    bool? showLibraryPenaltyDialog,
    bool? showImzaGunuDialog,
    bool? showTurnSkippedDialog,
    String? rentOwnerName,
    int? rentAmount,
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
      showPurchaseDialog: showPurchaseDialog ?? this.showPurchaseDialog,
      showCardDialog: showCardDialog ?? this.showCardDialog,
      showUpgradeDialog: showUpgradeDialog ?? this.showUpgradeDialog,
      showRentDialog: showRentDialog ?? this.showRentDialog,
      showLibraryPenaltyDialog:
          showLibraryPenaltyDialog ?? this.showLibraryPenaltyDialog,
      showImzaGunuDialog: showImzaGunuDialog ?? this.showImzaGunuDialog,
      showTurnSkippedDialog:
          showTurnSkippedDialog ?? this.showTurnSkippedDialog,
      rentOwnerName: rentOwnerName ?? this.rentOwnerName,
      rentAmount: rentAmount ?? this.rentAmount,
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
      showPurchaseDialog: false,
      showCardDialog: false,
      showUpgradeDialog: false,
      showRentDialog: false,
      showLibraryPenaltyDialog: false,
      showImzaGunuDialog: false,
      showTurnSkippedDialog: false,
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
      phase: GamePhase.playing,
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
        state.phase != GamePhase.playing) {
      return;
    }
    if (state.showQuestionDialog ||
        state.showPurchaseDialog ||
        state.showUpgradeDialog ||
        state.showCardDialog ||
        state.showRentDialog ||
        state.showLibraryPenaltyDialog) {
      return;
    }

    _isProcessing = true;
    try {
      if (state.showQuestionDialog ||
          state.showPurchaseDialog ||
          state.showUpgradeDialog ||
          state.showCardDialog ||
          state.showRentDialog ||
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
      _movePlayer(roll);
    } finally {
      _isProcessing = false;
    }
  }

  /// Move player step-by-step with hopping animation
  Future<void> _movePlayer(int steps) async {
    var player = state.currentPlayer;

    // NOTE: _isProcessing check removed here because rollDice() already sets it to true
    // before calling this method. Re-checking it caused a deadlock where movement
    // was effectively cancelled.

    _isProcessing = true; // Kept to ensure lock logic if called from elsewhere
    try {
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
      int newBalance = player.balance;

      for (int i = 0; i < steps; i++) {
        currentPos = (currentPos + 1) % GameConstants.boardSize;

        // Check if passed start
        if (currentPos == GameConstants.startPosition) {
          newBalance += GameConstants.passingStartBonus;
          _addLog(
            "Başlangıçtan geçtin: +${GameConstants.passingStartBonus} Puan",
            type: 'purchase',
          );
        }

        // Update position for each step (triggers hop animation in UI)
        List<Player> stepPlayers = List.from(state.players);
        stepPlayers[state.currentPlayerIndex] = state.currentPlayer.copyWith(
          position: currentPos,
          balance: newBalance,
        );
        state = state.copyWith(players: stepPlayers);

        // Wait for hop animation
        await Future.delayed(
          Duration(milliseconds: GameConstants.hopAnimationDelay),
        );
      }

      final tile = state.tiles[currentPos];

      state = state.copyWith(currentTile: tile);
      _addLog("${tile.title} karesine gelindi.");

      _handleTileArrival(tile);
    } finally {
      _isProcessing = false;
    }
  }

  void _handleTileArrival(BoardTile tile) {
    if (tile.type == TileType.property ||
        tile.type == TileType.publisher ||
        tile.type == TileType.writingSchool ||
        tile.type == TileType.educationFoundation) {
      Player? owner = _getTileOwner(tile.id);

      if (owner != null) {
        if (owner.id == state.currentPlayer.id) {
          _offerUpgrade(tile);
        } else {
          _payRent(tile, owner);
        }
      } else {
        _triggerQuestion(tile);
      }
    } else if (tile.type == TileType.chance || tile.type == TileType.fate) {
      _drawCard(tile.type);
    } else if (tile.type == TileType.bankruptcyRisk) {
      int newBalance =
          (state.currentPlayer.balance * GameConstants.bankruptcyRiskMultiplier)
              .floor();
      _updateBalance(state.currentPlayer, newBalance);
      _addLog("İFLAS RİSKİ! Puan yarıya düştü.", type: 'error');
      endTurn();
    } else if (tile.type == TileType.libraryWatch) {
      // Show library penalty dialog
      state = state.copyWith(showLibraryPenaltyDialog: true);
      _addLog("Kütüphane nöbeti cezası!", type: 'error');
    } else if (tile.type == TileType.autographDay) {
      // Show İmza Günü dialog - informative only
      state = state.copyWith(showImzaGunuDialog: true);
      _addLog("✍️ İmza Günü! Okurlarınla buluştun.", type: 'success');
    } else if (tile.type == TileType.incomeTax) {
      _updateBalance(
        state.currentPlayer,
        state.currentPlayer.balance - GameConstants.incomeTax,
      );
      _addLog(
        "Gelir Vergisi ödendi (-${GameConstants.incomeTax} Puan).",
        type: 'error',
      );
      endTurn();
    } else if (tile.type == TileType.writingTax) {
      _updateBalance(
        state.currentPlayer,
        state.currentPlayer.balance - GameConstants.writingTax,
      );
      _addLog(
        "Yazarlık Vergisi ödendi (-${GameConstants.writingTax} Puan).",
        type: 'error',
      );
      endTurn();
    } else {
      endTurn();
    }
  }

  // --- 3. EKONOMİ (Kira & Baskı) ---
  void _payRent(BoardTile tile, Player owner) {
    int rent = 0;

    if (tile.isUtility) {
      rent = state.diceTotal * GameConstants.utilityRentMultiplier;
      _addLog(
        "Yayınevi kirası: Zar(${state.diceTotal}) x ${GameConstants.utilityRentMultiplier} = $rent",
      );
    } else {
      // Property rent: baseRent * (upgradeLevel + 1)
      int base = tile.baseRent ?? 20;
      int multiplier = tile.upgradeLevel + 1;

      // Special multiplier for max upgrade (Cilt)
      if (tile.upgradeLevel == GameConstants.maxUpgradeLevel) {
        multiplier =
            GameConstants.maxUpgradeRentMultiplier; // Cilt gives 10x rent
      }

      rent = base * multiplier;
    }

    final payer = state.currentPlayer;

    // Check if payer can afford rent
    if (payer.balance < rent) {
      // Payer goes bankrupt - pay what they can
      rent = payer.balance > 0 ? payer.balance : 0;
      _addLog(
        "${payer.name} kira ödeyemiyor! Tüm parasını ($rent) kaybetti.",
        type: 'error',
      );
    }

    // Payer loses money
    _updateBalance(payer, payer.balance - rent);

    // Owner gains money
    Player currentOwner = state.players.firstWhere((p) => p.id == owner.id);
    _updateBalance(currentOwner, currentOwner.balance + rent);

    _addLog(
      "${payer.name} → ${owner.name}: $rent kira ödedi.",
      type: 'purchase',
    );

    // Show rent notification dialog
    state = state.copyWith(
      showRentDialog: true,
      rentOwnerName: owner.name,
      rentAmount: rent,
    );

    // Check for bankruptcy after rent
    _checkBankruptcy();
  }

  /// Close rent dialog and end turn
  void closeRentDialog() {
    state = state.copyWith(
      showRentDialog: false,
      rentOwnerName: null,
      rentAmount: null,
    );
    endTurn();
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

  void _offerUpgrade(BoardTile tile) {
    if (tile.isUtility) {
      _addLog("Burası özel mülk, geliştirilemez.");
      endTurn();
      return;
    }

    if (tile.upgradeLevel < 4) {
      state = state.copyWith(
        showUpgradeDialog: true,
        lastAction: "Baskı/Cilt yapmak ister misin?",
      );
    } else {
      _addLog("Telif Hakkı Zirvede (Full Upgrade).");
      endTurn();
    }
  }

  void upgradeProperty() {
    final tile = state.currentTile;
    if (tile == null) {
      _addLog("Mülk bulunamadı!", type: 'error');
      state = state.copyWith(showUpgradeDialog: false);
      endTurn();
      return;
    }

    final player = state.currentPlayer;
    int cost =
        ((tile.price ?? GameConstants.defaultPropertyPrice) *
                GameConstants.upgradeCostMultiplier)
            .floor();
    if (tile.upgradeLevel == GameConstants.finalUpgradeLevel) {
      cost =
          ((tile.price ?? GameConstants.defaultPropertyPrice) *
                  GameConstants.finalUpgradeCostMultiplier)
              .floor();
    }

    if (player.balance >= cost) {
      _updateBalance(player, player.balance - cost);
      final newLevel = tile.upgradeLevel + 1;
      final newTile = tile.copyWith(upgradeLevel: newLevel);
      List<BoardTile> newTiles = List.from(state.tiles);
      int index = newTiles.indexWhere((t) => t.id == tile.id);
      if (index != -1) newTiles[index] = newTile;

      state = state.copyWith(
        tiles: newTiles,
        showUpgradeDialog: false,
        currentTile: newTile,
      );
      _addLog("Geliştirme başarılı! (Seviye $newLevel)", type: 'success');
    } else {
      state = state.copyWith(showUpgradeDialog: false);
      _addLog("Yetersiz bakiye!", type: 'error');
    }
    endTurn();
  }

  void declineUpgrade() {
    state = state.copyWith(showUpgradeDialog: false);
    _addLog("Geliştirme yapılmadı.");
    endTurn();
  }

  // --- 4. YARDIMCILAR ---
  void _triggerQuestion(BoardTile tile) {
    if (tile.category == null) {
      state = state.copyWith(
        showPurchaseDialog: true,
        currentTile: tile,
        lastAction: "Satın alınabilir özel mülk.",
      );
      return;
    }

    // Get random question from cached questions
    if (_cachedQuestions.isEmpty) {
      _addLog('Soru bulunamadı!', type: 'error');
      endTurn();
      return;
    }
    final q = _cachedQuestions[_random.nextInt(_cachedQuestions.length)];
    state = state.copyWith(
      showQuestionDialog: true,
      currentQuestion: q,
      currentTile: tile, // Store tile for purchase after question
    );
  }

  /// Answer question with open-ended format (Bildin/Bilemedin)
  void answerQuestion(bool isCorrect) async {
    if (_isProcessing || state.currentQuestion == null) return;

    _isProcessing = true;
    try {
      state = state.copyWith(showQuestionDialog: false, currentQuestion: null);

      if (isCorrect) {
        _addLog("Doğru cevap! Ödül: 50 Puan.", type: 'success');
        _updateBalance(
          state.currentPlayer,
          state.currentPlayer.balance + GameConstants.questionReward,
        );
        await Future.delayed(
          Duration(milliseconds: GameConstants.cardAnimationDelay),
        );

        // Safety check: ensure currentTile exists before showing purchase dialog
        if (state.currentTile != null) {
          state = state.copyWith(showPurchaseDialog: true);
        } else {
          // Fallback: If tile was lost, just end turn
          _addLog("Mülk bulunamadı, tur sonlandırılıyor.", type: 'error');
          endTurn();
        }
      } else {
        _addLog("Yanlış cevap.", type: 'error');
        endTurn();
      }
    } finally {
      _isProcessing = false;
    }
  }

  void purchaseProperty() {
    final tile = state.currentTile;
    if (tile == null) {
      _addLog("Mülk bulunamadı!", type: 'error');
      state = state.copyWith(showPurchaseDialog: false);
      endTurn();
      return;
    }

    final player = state.currentPlayer;
    final price = tile.price ?? 0;

    if (player.balance >= price) {
      // Deduct price
      _updateBalance(player, player.balance - price);

      // Add tile to owned list
      List<int> newOwned = List.from(player.ownedTiles)..add(tile.id);
      List<Player> newPlayers = List.from(state.players);
      newPlayers[state.currentPlayerIndex] = player.copyWith(
        ownedTiles: newOwned,
        balance: player.balance - price, // Also update balance in player object
      );

      state = state.copyWith(players: newPlayers, showPurchaseDialog: false);
      _addLog(
        "✅ ${player.name} '${tile.title}' satın aldı! (-$price)",
        type: 'purchase',
      );
    } else {
      state = state.copyWith(showPurchaseDialog: false);
      _addLog(
        "❌ Yetersiz bakiye! (Gereken: $price, Mevcut: ${player.balance})",
        type: 'error',
      );
    }
    endTurn();
  }

  void declinePurchase() {
    state = state.copyWith(showPurchaseDialog: false);
    _addLog("Satın alınmadı.");
    endTurn();
  }

  void _drawCard(TileType type) async {
    if (_isProcessing) return;

    _isProcessing = true;
    try {
      await Future.delayed(
        Duration(milliseconds: GameConstants.cardAnimationDelay),
      );
      List<GameCard> deck = type == TileType.chance
          ? GameCards.sansCards
          : GameCards.kaderCards;
      GameCard card = deck[_random.nextInt(deck.length)];
      state = state.copyWith(showCardDialog: true, currentCard: card);
    } finally {
      _isProcessing = false;
    }
  }

  void closeCardDialog() {
    if (state.currentCard != null) {
      final card = state.currentCard!;
      final player = state.currentPlayer;

      switch (card.effectType) {
        case CardEffectType.moneyChange:
          final newBalance = player.balance + card.value;
          _updateBalance(player, newBalance);
          if (card.value > 0) {
            _addLog(
              "💰 ${player.name} +${card.value} kazandı!",
              type: 'success',
            );
          } else {
            _addLog("💸 ${player.name} ${card.value} kaybetti!", type: 'error');
          }
          break;

        case CardEffectType.move:
          int targetPos = card.value % GameConstants.boardSize;
          bool passedStart = targetPos < player.position;

          List<Player> newPlayers = List.from(state.players);
          int newBalance = player.balance;

          // Give passing start bonus if passed start
          if (passedStart && targetPos != GameConstants.startPosition) {
            newBalance += GameConstants.passingStartBonus;
            _addLog(
              "🏁 Başlangıçtan geçtin: +${GameConstants.passingStartBonus}!",
              type: 'success',
            );
          }

          newPlayers[state.currentPlayerIndex] = player.copyWith(
            position: targetPos,
            balance: newBalance,
          );
          state = state.copyWith(players: newPlayers);
          _addLog("🎯 ${player.name} $targetPos. kareye taşındı!");
          break;

        case CardEffectType.jail:
          List<Player> temp = List.from(state.players);
          temp[state.currentPlayerIndex] = player.copyWith(
            position: GameConstants.jailPosition,
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
                if (updatedPlayers[i].balance < amount) {
                  amount = updatedPlayers[i].balance > 0
                      ? updatedPlayers[i].balance
                      : 0;
                }
                updatedPlayers[i] = updatedPlayers[i].copyWith(
                  balance: updatedPlayers[i].balance - amount,
                );
                totalTransfer += amount;
              } else {
                // Current player pays to others
                int amount = -card.value;
                updatedPlayers[i] = updatedPlayers[i].copyWith(
                  balance: updatedPlayers[i].balance + amount,
                );
                totalTransfer += amount;
              }
            }
          }

          // Update current player
          int finalBalance = card.value > 0
              ? player.balance + totalTransfer
              : player.balance - totalTransfer;
          updatedPlayers[currentIdx] = updatedPlayers[currentIdx].copyWith(
            balance: finalBalance,
          );

          state = state.copyWith(players: updatedPlayers);

          if (card.value > 0) {
            _addLog(
              "🏆 ${player.name} herkesten toplam $totalTransfer aldı!",
              type: 'success',
            );
          } else {
            _addLog(
              "💸 ${player.name} herkese toplam $totalTransfer ödedi!",
              type: 'error',
            );
          }
          break;
      }

      _checkBankruptcy();
    }
    state = state.copyWith(showCardDialog: false, currentCard: null);
    endTurn();
  }

  void closeDialogs() {
    state = state.copyWith(
      showCardDialog: false,
      showUpgradeDialog: false,
      showPurchaseDialog: false,
    );
    endTurn();
  }

  /// Check if any player is bankrupt and handle elimination
  void _checkBankruptcy() {
    for (int i = 0; i < state.players.length; i++) {
      if (state.players[i].balance < 0) {
        _addLog("🚨 ${state.players[i].name} iflas etti!", type: 'gameover');
        // Bankruptcy is handled in endTurn
        return;
      }
    }
  }

  /// Calculate player's net worth: cash + (property values ×1.5)
  int calculateNetWorth(Player player) {
    int assetValue = 0;

    for (final tileId in player.ownedTiles) {
      final tile = BoardConfig.getTile(tileId);
      if (tile.price != null) {
        // Assets valued at 1.5x purchase price
        assetValue += (tile.price! * 1.5).round();
      }
    }

    return player.balance + assetValue;
  }

  void endGame() {
    if (state.players.isEmpty) return;

    // Find winner based on NET WORTH (balance + assets at 1.5x)
    Player winner = state.players.reduce(
      (curr, next) =>
          calculateNetWorth(curr) > calculateNetWorth(next) ? curr : next,
    );

    final winnerNetWorth = calculateNetWorth(winner);

    state = state.copyWith(winner: winner, phase: GamePhase.gameOver);
    _addLog(
      "🏆 OYUN BİTTİ! Kazanan: ${winner.name} (Net Değer: $winnerNetWorth)",
      type: 'gameover',
    );
  }

  void endTurn() async {
    if (_isProcessing || state.phase == GamePhase.gameOver) return;

    _isProcessing = true;
    try {
      // Check for re-roll on doubles (if not in jail/penalty)
      if (state.phase == GamePhase.playing &&
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

      if (state.currentPlayer.balance < 0) {
        _addLog("${state.currentPlayer.name} iflas etti!", type: 'gameover');
        await Future.delayed(
          Duration(milliseconds: GameConstants.bankruptcyDialogDelay),
        );

        List<Player> remainingPlayers = List.from(state.players);
        remainingPlayers.removeAt(state.currentPlayerIndex);

        if (remainingPlayers.length <= 1) {
          state = state.copyWith(players: remainingPlayers);
          endGame();
          return;
        }

        int nextIndex = state.currentPlayerIndex;
        if (nextIndex >= remainingPlayers.length) nextIndex = 0;

        state = state.copyWith(
          players: remainingPlayers,
          currentPlayerIndex: nextIndex,
          isDiceRolled: false,
          showPurchaseDialog: false,
          showQuestionDialog: false,
          showUpgradeDialog: false,
          showCardDialog: false,
        );
        _addLog(
          "Sıra ${remainingPlayers[nextIndex].name} oyuncusunda.",
          type: 'turn',
        );
        return;
      }

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
        showPurchaseDialog: false,
        showQuestionDialog: false,
        showUpgradeDialog: false,
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

  void _updateBalance(Player p, int bal) async {
    // Balance updates don't need to block other actions
    // Just update without the processing flag
    int idx = state.players.indexWhere((x) => x.id == p.id);
    if (idx == -1) return;

    int diff = bal - p.balance;
    if (diff != 0) {
      String sign = diff > 0 ? "+" : "";
      Color color = diff > 0 ? Colors.greenAccent : Colors.redAccent;
      // Trigger effect
      state = state.copyWith(
        floatingEffect: FloatingEffect("$sign$diff", color),
      );

      // Clear effect after delay to allow re-triggering
      // Note: In UI we play animation on change.
      // To ensure 'change' is detected even if same value, we might need a timestamp or unique ID.
      // But for now, let's just set it.
      // To prevent 'stuck' state if multiple updates happen fast, UI should handle keying.
    }

    List<Player> list = List.from(state.players);
    list[idx] = list[idx].copyWith(balance: bal);
    state = state.copyWith(players: list);

    // Auto-reset effect state after a short duration so next event triggers change
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      state = state.copyWith(floatingEffect: null);
    }
  }

  Player? _getTileOwner(int id) {
    for (var p in state.players) {
      if (p.ownedTiles.contains(id)) return p;
    }
    return null;
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
