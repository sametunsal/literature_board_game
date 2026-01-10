import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/board_tile.dart';
import '../models/game_enums.dart';
import '../models/game_card.dart';
import '../data/board_config.dart';
import '../data/mock_questions.dart';
import '../data/game_cards.dart';
import '../core/audio_manager.dart'; // Audio Import

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

  final BoardTile? currentTile;
  final GameCard? currentCard;
  final Player? winner;
  final String? setupMessage;

  GameState({
    required this.players,
    this.tiles = const [],
    this.currentPlayerIndex = 0,
    this.diceTotal = 0,
    this.lastAction = 'Oyun Kurulumu Bekleniyor...',
    this.isDiceRolled = false,
    this.phase = GamePhase.setup,
    this.logs = const [],
    this.floatingEffect, // New field
    this.currentQuestion,
    this.showQuestionDialog = false,
    this.showPurchaseDialog = false,
    this.showCardDialog = false,
    this.showUpgradeDialog = false,
    this.currentTile,
    this.currentCard,
    this.winner,
    this.setupMessage,
  });

  Player get currentPlayer => players.isNotEmpty
      ? players[currentPlayerIndex]
      : const Player(id: '0', name: '?', color: Colors.grey, iconIndex: 0);

  GameState copyWith({
    List<Player>? players,
    List<BoardTile>? tiles,
    int? currentPlayerIndex,
    int? diceTotal,
    String? lastAction,
    bool? isDiceRolled,
    GamePhase? phase,
    List<String>? logs,
    FloatingEffect? floatingEffect, // New parameter
    Question? currentQuestion,
    bool? showQuestionDialog,
    bool? showPurchaseDialog,
    bool? showCardDialog,
    bool? showUpgradeDialog,
    BoardTile? currentTile,
    GameCard? currentCard,
    Player? winner,
    String? setupMessage,
  }) {
    return GameState(
      players: players ?? this.players,
      tiles: tiles ?? this.tiles,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      diceTotal: diceTotal ?? this.diceTotal,
      lastAction: lastAction ?? this.lastAction,
      isDiceRolled: isDiceRolled ?? this.isDiceRolled,
      phase: phase ?? this.phase,
      logs: logs ?? this.logs,
      floatingEffect: floatingEffect, // Allows null to clear
      currentQuestion: currentQuestion ?? this.currentQuestion,
      showQuestionDialog: showQuestionDialog ?? this.showQuestionDialog,
      showPurchaseDialog: showPurchaseDialog ?? this.showPurchaseDialog,
      showCardDialog: showCardDialog ?? this.showCardDialog,
      showUpgradeDialog: showUpgradeDialog ?? this.showUpgradeDialog,
      currentTile: currentTile ?? this.currentTile,
      currentCard: currentCard ?? this.currentCard,
      winner: winner ?? this.winner,
      setupMessage: setupMessage ?? this.setupMessage,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final Random _random = Random();

  GameNotifier() : super(GameState(players: [], tiles: BoardConfig.tiles));

  // --- LOG & AUDIO HELPER ---
  void _addLog(String message, {String type = 'info'}) {
    List<String> newLogs = List.from(state.logs)..add(message);
    state = state.copyWith(logs: newLogs, lastAction: message);

    // Ses Efektleri
    if (type == 'dice')
      AudioManager.instance.playDiceRoll();
    else if (type == 'success')
      AudioManager.instance.playSuccess();
    else if (type == 'error')
      AudioManager.instance.playError();
    else if (type == 'purchase')
      AudioManager.instance.playPurchase();
    else if (type == 'gameover')
      AudioManager.instance.playGameOver();
    else if (type == 'turn')
      AudioManager.instance.playTurnChange();
  }

  // --- 1. SETUP ve SIRALAMA ---
  void initializeGame(List<Player> setupPlayers) async {
    state = state.copyWith(
      players: setupPlayers,
      phase: GamePhase.rollingForOrder,
      lastAction: "Sıralama için zar atılıyor...",
    );
    _addLog("Oyun Kuruluyor...", type: 'info');

    await Future.delayed(const Duration(seconds: 1));
    _determineOrder(setupPlayers);
  }

  void _determineOrder(List<Player> players) async {
    List<Map<String, dynamic>> rolls = [];
    for (var p in players) {
      int roll = _random.nextInt(11) + 2;
      rolls.add({'player': p, 'roll': roll});
    }

    rolls.sort((a, b) => (b['roll'] as int).compareTo(a['roll'] as int));

    List<Player> sortedPlayers = rolls
        .map((r) => r['player'] as Player)
        .toList();

    String orderMsg =
        "Sıralama: " + sortedPlayers.map((p) => "${p.name}").join(", ");

    state = state.copyWith(
      players: sortedPlayers,
      currentPlayerIndex: 0,
      phase: GamePhase.playing,
    );
    _addLog(orderMsg, type: 'success');
  }

  // --- 2. OYUN DÖNGÜSÜ ---
  void rollDice() async {
    if (state.isDiceRolled || state.phase != GamePhase.playing) return;
    if (state.showQuestionDialog ||
        state.showPurchaseDialog ||
        state.showUpgradeDialog ||
        state.showCardDialog)
      return;

    int roll = _random.nextInt(11) + 2;
    state = state.copyWith(isDiceRolled: true, diceTotal: roll);

    _addLog("${state.currentPlayer.name} $roll attı.", type: 'dice');

    await Future.delayed(const Duration(milliseconds: 800));
    _movePlayer(roll);
  }

  void _movePlayer(int steps) {
    var player = state.currentPlayer;

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

    int newPos = (player.position + steps) % 40;
    int newBalance = player.balance;
    if (newPos < player.position) {
      newBalance += 200;
      _addLog("Başlangıçtan geçtin: +200 Puan", type: 'purchase');
    }

    List<Player> newPlayers = List.from(state.players);
    newPlayers[state.currentPlayerIndex] = player.copyWith(
      position: newPos,
      balance: newBalance,
    );

    final tile = state.tiles[newPos];

    state = state.copyWith(players: newPlayers, currentTile: tile);
    _addLog("${tile.title} karesine gelindi.");

    _handleTileArrival(tile);
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
      int newBalance = (state.currentPlayer.balance / 2).floor();
      _updateBalance(state.currentPlayer, newBalance);
      _addLog("İFLAS RİSKİ! Puan yarıya düştü.", type: 'error');
      endTurn();
    } else if (tile.type == TileType.libraryWatch) {
      _addLog("Kütüphane nöbetçilerine selam verdin.");
      endTurn();
    } else {
      endTurn();
    }
  }

  // --- 3. EKONOMİ (Kira & Baskı) ---
  void _payRent(BoardTile tile, Player owner) {
    int rent = 0;
    if (tile.isUtility) {
      rent = state.diceTotal * 15;
    } else {
      int base = tile.baseRent ?? 20;
      switch (tile.upgradeLevel) {
        case 0:
          rent = base;
          break;
        case 1:
          rent = base * 2;
          break;
        case 2:
          rent = base * 4;
          break;
        case 3:
          rent = base * 8;
          break;
        case 4:
          rent = base * 20;
          break;
        default:
          rent = base;
      }
    }

    // Payer loses money
    _updateBalance(state.currentPlayer, state.currentPlayer.balance - rent);

    // Owner gains money
    Player? currentOwner = state.players.firstWhere((p) => p.id == owner.id);
    _updateBalance(currentOwner, currentOwner.balance + rent);

    _addLog("${owner.name}'e $rent puan kira ödendi.", type: 'purchase');
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
    final tile = state.currentTile!;
    final player = state.currentPlayer;
    int cost = (tile.price ?? 100) ~/ 2;
    if (tile.upgradeLevel == 3) cost = (tile.price ?? 100) * 2;

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
        lastAction: "Satın alınabilir özel mülk.",
      );
      return;
    }
    final q = mockQuestions[_random.nextInt(mockQuestions.length)];
    state = state.copyWith(showQuestionDialog: true, currentQuestion: q);
  }

  void answerQuestion(int index) async {
    if (state.currentQuestion == null) return;
    bool correct = index == state.currentQuestion!.correctIndex;
    state = state.copyWith(showQuestionDialog: false, currentQuestion: null);

    if (correct) {
      _addLog("Doğru cevap! Ödül: 50 Puan.", type: 'success');
      _updateBalance(state.currentPlayer, state.currentPlayer.balance + 50);
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(showPurchaseDialog: true);
    } else {
      _addLog("Yanlış cevap.", type: 'error');
      endTurn();
    }
  }

  void purchaseProperty() {
    final tile = state.currentTile!;
    final player = state.currentPlayer;

    if (player.balance >= (tile.price ?? 0)) {
      _updateBalance(player, player.balance - (tile.price ?? 0));
      List<int> newOwned = List.from(player.ownedTiles)..add(tile.id);
      List<Player> newPlayers = List.from(state.players);
      newPlayers[state.currentPlayerIndex] = player.copyWith(
        ownedTiles: newOwned,
      );

      state = state.copyWith(players: newPlayers, showPurchaseDialog: false);
      _addLog("${tile.title} satın alındı!", type: 'purchase');
    } else {
      state = state.copyWith(showPurchaseDialog: false);
      _addLog("Yetersiz bakiye!", type: 'error');
    }
    endTurn();
  }

  void declinePurchase() {
    state = state.copyWith(showPurchaseDialog: false);
    _addLog("Satın alınmadı.");
    endTurn();
  }

  void _drawCard(TileType type) async {
    await Future.delayed(const Duration(milliseconds: 500));
    List<GameCard> deck = type == TileType.chance
        ? GameCards.sansCards
        : GameCards.kaderCards;
    GameCard card = deck[_random.nextInt(deck.length)];
    state = state.copyWith(showCardDialog: true, currentCard: card);
  }

  void closeCardDialog() {
    if (state.currentCard != null) {
      final card = state.currentCard!;
      _addLog("Kart: ${card.description}");

      switch (card.effectType) {
        case CardEffectType.moneyChange:
          _updateBalance(
            state.currentPlayer,
            state.currentPlayer.balance + card.value,
          );
          break;
        case CardEffectType.move:
          int targetPos = card.value;
          List<Player> newPlayers = List.from(state.players);
          newPlayers[state.currentPlayerIndex] = state.currentPlayer.copyWith(
            position: targetPos,
          );
          state = state.copyWith(players: newPlayers);
          break;
        case CardEffectType.jail:
          List<Player> temp = List.from(state.players);
          temp[state.currentPlayerIndex] = state.currentPlayer.copyWith(
            position: 10,
            inJail: true,
          );
          state = state.copyWith(players: temp);
          _addLog("Nöbete yollandın!", type: 'error');
          break;
        case CardEffectType.globalMoney:
          // Basit pas geçiyorum, logic çok uzadı.
          break;
      }
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

  void endGame() {
    if (state.players.isEmpty) return;
    Player winner = state.players.reduce(
      (curr, next) => curr.balance > next.balance ? curr : next,
    );
    state = state.copyWith(winner: winner, phase: GamePhase.gameOver);
    _addLog("OYUN BİTTİ! Kazanan: ${winner.name}", type: 'gameover');
  }

  void endTurn() async {
    if (state.phase == GamePhase.gameOver) return;

    if (state.currentPlayer.balance < 0) {
      _addLog("${state.currentPlayer.name} iflas etti!", type: 'gameover');
      await Future.delayed(const Duration(seconds: 2));

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

    await Future.delayed(const Duration(milliseconds: 1200));
    int next = (state.currentPlayerIndex + 1) % state.players.length;

    state = state.copyWith(
      currentPlayerIndex: next,
      isDiceRolled: false,
      showPurchaseDialog: false,
      showQuestionDialog: false,
      showUpgradeDialog: false,
      showCardDialog: false,
    );
    _addLog("Sıra ${state.players[next].name} oyuncusunda.", type: 'turn');
  }

  void _updateBalance(Player p, int bal) async {
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
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>(
  (ref) => GameNotifier(),
);
