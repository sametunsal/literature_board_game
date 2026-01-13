import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/board_tile.dart';
import '../models/game_enums.dart';
import '../models/game_card.dart';
import '../models/question.dart';
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
  final bool showRentDialog;
  final bool showLibraryPenaltyDialog;
  final bool showImzaGunuDialog;

  // Rent notification info
  final String? rentOwnerName;
  final int? rentAmount;

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
    this.floatingEffect,
    this.currentQuestion,
    this.showQuestionDialog = false,
    this.showPurchaseDialog = false,
    this.showCardDialog = false,
    this.showUpgradeDialog = false,
    this.showRentDialog = false,
    this.showLibraryPenaltyDialog = false,
    this.showImzaGunuDialog = false,
    this.rentOwnerName,
    this.rentAmount,
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
    FloatingEffect? floatingEffect,
    Question? currentQuestion,
    bool? showQuestionDialog,
    bool? showPurchaseDialog,
    bool? showCardDialog,
    bool? showUpgradeDialog,
    bool? showRentDialog,
    bool? showLibraryPenaltyDialog,
    bool? showImzaGunuDialog,
    String? rentOwnerName,
    int? rentAmount,
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
      rentOwnerName: rentOwnerName ?? this.rentOwnerName,
      rentAmount: rentAmount ?? this.rentAmount,
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
        "Sıralama: ${sortedPlayers.map((p) => p.name).join(", ")}";

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

    int roll = _random.nextInt(11) + 2;
    state = state.copyWith(isDiceRolled: true, diceTotal: roll);

    _addLog("${state.currentPlayer.name} $roll attı.", type: 'dice');

    // Wait for dice animation to settle before moving
    await Future.delayed(const Duration(milliseconds: 1500));
    _movePlayer(roll);
  }

  /// Move player step-by-step with hopping animation
  Future<void> _movePlayer(int steps) async {
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

    // Step-by-step hopping movement
    int currentPos = player.position;
    int newBalance = player.balance;

    for (int i = 0; i < steps; i++) {
      currentPos = (currentPos + 1) % 40;

      // Check if passed start
      if (currentPos == 0) {
        newBalance += 200;
        _addLog("Başlangıçtan geçtin: +200 Puan", type: 'purchase');
      }

      // Update position for each step (triggers hop animation in UI)
      List<Player> stepPlayers = List.from(state.players);
      stepPlayers[state.currentPlayerIndex] = state.currentPlayer.copyWith(
        position: currentPos,
        balance: newBalance,
      );
      state = state.copyWith(players: stepPlayers);

      // Wait for hop animation (150ms per step for snappy feel)
      await Future.delayed(const Duration(milliseconds: 150));
    }

    final tile = state.tiles[currentPos];

    state = state.copyWith(currentTile: tile);
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
      // Show library penalty dialog
      state = state.copyWith(showLibraryPenaltyDialog: true);
      _addLog("Kütüphane nöbeti cezası!", type: 'error');
    } else if (tile.type == TileType.autographDay) {
      // Show İmza Günü dialog - informative only
      state = state.copyWith(showImzaGunuDialog: true);
      _addLog("✍️ İmza Günü! Okurlarınla buluştun.", type: 'success');
    } else {
      endTurn();
    }
  }

  // --- 3. EKONOMİ (Kira & Baskı) ---
  void _payRent(BoardTile tile, Player owner) {
    int rent = 0;

    if (tile.isUtility) {
      // Utility rent: dice * 15
      rent = state.diceTotal * 15;
      _addLog("Yayınevi kirası: Zar(${state.diceTotal}) x 15 = $rent");
    } else {
      // Property rent: baseRent * (upgradeLevel + 1)
      int base = tile.baseRent ?? 20;
      int multiplier = tile.upgradeLevel + 1;

      // Special multiplier for max upgrade (Cilt)
      if (tile.upgradeLevel == 4) {
        multiplier = 10; // Hotel/Cilt gives 10x rent
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
    // Set 2 turns penalty for current player
    final player = state.currentPlayer;
    List<Player> newPlayers = List.from(state.players);
    newPlayers[state.currentPlayerIndex] = player.copyWith(turnsToSkip: 2);

    state = state.copyWith(
      players: newPlayers,
      showLibraryPenaltyDialog: false,
    );

    _addLog("${player.name} 2 tur ceza aldı!", type: 'error');
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

  /// Answer question with open-ended format (Bildin/Bilemedin)
  void answerQuestion(bool isCorrect) async {
    if (state.currentQuestion == null) return;
    state = state.copyWith(showQuestionDialog: false, currentQuestion: null);

    if (isCorrect) {
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
          int targetPos = card.value % 40;
          bool passedStart = targetPos < player.position;

          List<Player> newPlayers = List.from(state.players);
          int newBalance = player.balance;

          // Give 200 if passed start
          if (passedStart && targetPos != 0) {
            newBalance += 200;
            _addLog("🏁 Başlangıçtan geçtin: +200!", type: 'success');
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
            position: 10,
            turnsToSkip: 2,
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

  /// Calculate player's net worth: cash + (property values × 1.5)
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
