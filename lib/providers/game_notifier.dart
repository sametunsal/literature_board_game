import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/board_tile.dart';
import '../models/game_enums.dart';
import '../models/game_card.dart'; // Yeni import
import '../data/board_config.dart';
import '../data/mock_questions.dart';
import '../data/game_cards.dart'; // Yeni import

class GameState {
  final List<Player> players;
  final List<BoardTile> tiles;
  final int currentPlayerIndex;
  final int diceTotal;
  final String lastAction;
  final bool isDiceRolled;
  final GamePhase phase;

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

  // Tiles'ı State içinde başlatıyoruz ki dinamik upgrade yapılabilsin
  GameNotifier() : super(GameState(players: [], tiles: BoardConfig.tiles));

  // --- 1. SETUP ve SIRALAMA ---
  // SetupScreen'den çağrılıyor
  void initializeGame(List<Player> setupPlayers) async {
    state = state.copyWith(
      players: setupPlayers,
      phase: GamePhase.rollingForOrder,
      lastAction: "Sıralama için zar atılıyor...",
    );

    await Future.delayed(const Duration(seconds: 1));
    _determineOrder(setupPlayers);
  }

  void _determineOrder(List<Player> players) async {
    // Herkes için sanal zar at
    List<Map<String, dynamic>> rolls = [];
    for (var p in players) {
      int roll = _random.nextInt(11) + 2;
      rolls.add({'player': p, 'roll': roll});
    }

    // Zarlara göre sırala (Büyükten küçüğe)
    rolls.sort((a, b) => (b['roll'] as int).compareTo(a['roll'] as int));

    List<Player> sortedPlayers = rolls
        .map((r) => r['player'] as Player)
        .toList();

    // Sıralama mesajını oluştur
    String orderMsg =
        "Sıralama: " +
        sortedPlayers
            .map(
              (p) =>
                  "${p.name} (${rolls.firstWhere((r) => r['player'] == p)['roll']})",
            )
            .join(", ");

    state = state.copyWith(
      players: sortedPlayers,
      currentPlayerIndex: 0,
      phase: GamePhase.playing,
      lastAction: orderMsg,
    );
  }

  // --- 2. OYUN DÖNGÜSÜ ---
  void rollDice() async {
    if (state.isDiceRolled || state.phase != GamePhase.playing) return;

    // Dialoglar açıksa zar atamaz
    if (state.showQuestionDialog ||
        state.showPurchaseDialog ||
        state.showUpgradeDialog ||
        state.showCardDialog)
      return;

    int roll = _random.nextInt(11) + 2;
    state = state.copyWith(
      isDiceRolled: true,
      diceTotal: roll,
      lastAction: "${state.currentPlayer.name} $roll attı.",
    );

    await Future.delayed(const Duration(milliseconds: 800));
    _movePlayer(roll);
  }

  void _movePlayer(int steps) {
    var player = state.currentPlayer;

    // Kütüphane Nöbeti Kontrolü
    if (player.inJail) {
      // %50 Şansla çık (Basitlik için)
      if (_random.nextBool()) {
        // Çıktı
        state = state.copyWith(lastAction: "Nöbetten erken çıktın!");
        List<Player> newPlayers = List.from(state.players);
        newPlayers[state.currentPlayerIndex] = player.copyWith(inJail: false);
        state = state.copyWith(players: newPlayers);
      } else {
        state = state.copyWith(lastAction: "Hâlâ nöbettesin. Tur geçti.");
        endTurn();
        return;
      }
    }

    int newPos = (player.position + steps) % 40;
    int newBalance = player.balance;
    if (newPos < player.position)
      newBalance += 200; // Tur primi (Start'tan geçti)

    List<Player> newPlayers = List.from(state.players);
    newPlayers[state.currentPlayerIndex] = player.copyWith(
      position: newPos,
      balance: newBalance,
    );

    // Dinamik Tile State'i (Upgrade'leri görmek için BoardConfig yerine state.tiles kullanıyoruz)
    final tile = state.tiles[newPos];

    state = state.copyWith(
      players: newPlayers,
      currentTile: tile,
      lastAction: "${tile.title} karesine gelindi.",
    );

    _handleTileArrival(tile);
  }

  void _handleTileArrival(BoardTile tile) {
    // A) Mülk Kontrolü
    if (tile.type == TileType.property ||
        tile.type == TileType.publisher ||
        tile.type == TileType.writingSchool ||
        tile.type == TileType.educationFoundation) {
      Player? owner = _getTileOwner(tile.id);

      if (owner != null) {
        if (owner.id == state.currentPlayer.id) {
          // KENDİ MÜLKÜ -> BASKI YAPMA TEKLİFİ
          _offerUpgrade(tile);
        } else {
          // BAŞKASININ MÜLKÜ -> KİRA ÖDE
          _payRent(tile, owner);
        }
      } else {
        // SAHİPSİZ -> SATIN ALMA / SORU
        _triggerQuestion(tile);
      }
    }
    // B) Kartlar
    else if (tile.type == TileType.chance || tile.type == TileType.fate) {
      _drawCard(tile.type);
    }
    // C) Cezalar (İflas Riski / Kütüphane)
    else if (tile.type == TileType.bankruptcyRisk) {
      int newBalance = (state.currentPlayer.balance / 2).floor();
      _updateBalance(state.currentPlayer, newBalance);
      state = state.copyWith(lastAction: "İFLAS RİSKİ! Puan yarıya düştü.");
      endTurn();
    } else if (tile.type == TileType.libraryWatch) {
      state = state.copyWith(
        lastAction: "Kütüphane nöbetçilerine selam verdin.",
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
      // Yayınevi/Vakıf Kuralı: Zar * 15
      rent = state.diceTotal * 15;
    } else {
      // Kitap Kuralı: Baskı Sayısına Göre (state.tiles üzerinden güncel seviyeyi alır)
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
          break; // Cilt
        default:
          rent = base;
      }
    }

    _updateBalance(state.currentPlayer, state.currentPlayer.balance - rent);

    // Sahibine öde
    int ownerIdx = state.players.indexWhere((p) => p.id == owner.id);
    if (ownerIdx != -1) {
      List<Player> temp = List.from(state.players);
      temp[ownerIdx] = temp[ownerIdx].copyWith(
        balance: temp[ownerIdx].balance + rent,
      );
      state = state.copyWith(players: temp);
    }

    state = state.copyWith(
      lastAction: "${owner.name}'e $rent puan kira ödendi.",
    );
    endTurn();
  }

  void _offerUpgrade(BoardTile tile) {
    // Utility (Yayınevi/Vakıf) geliştirilemez
    if (tile.isUtility) {
      state = state.copyWith(lastAction: "Burası özel mülk, geliştirilemez.");
      endTurn();
      return;
    }

    if (tile.upgradeLevel < 4) {
      state = state.copyWith(
        showUpgradeDialog: true,
        lastAction: "Baskı/Cilt yapmak ister misin?",
      );
    } else {
      state = state.copyWith(lastAction: "Telif Hakkı Zirvede (Full Upgrade).");
      endTurn();
    }
  }

  // Kullanıcı "Evet" dediğinde çağrılır
  void upgradeProperty() {
    final tile = state.currentTile!;
    final player = state.currentPlayer;

    int cost = (tile.price ?? 100) ~/ 2; // Yarı fiyatına baskı
    if (tile.upgradeLevel == 3)
      cost = (tile.price ?? 100) * 2; // Cilt pahalı (x2)

    if (player.balance >= cost) {
      _updateBalance(player, player.balance - cost);

      // Tile'ı güncelle (State içindeki tiles listesinde)
      final newLevel = tile.upgradeLevel + 1;
      final newTile = tile.copyWith(upgradeLevel: newLevel);

      List<BoardTile> newTiles = List.from(state.tiles);
      int index = newTiles.indexWhere((t) => t.id == tile.id);
      if (index != -1) newTiles[index] = newTile;

      state = state.copyWith(
        tiles: newTiles, // Listeyi güncelle
        showUpgradeDialog: false,
        currentTile: newTile, // Current tile'ı da güncelle
        lastAction: "Geliştirme başarılı! (Seviye $newLevel)",
      );
    } else {
      state = state.copyWith(
        showUpgradeDialog: false,
        lastAction: "Yetersiz bakiye!",
      );
    }
    endTurn();
  }

  void declineUpgrade() {
    state = state.copyWith(
      showUpgradeDialog: false,
      lastAction: "Geliştirme yapılmadı.",
    );
    endTurn();
  }

  // --- 4. YARDIMCILAR ---
  void _triggerQuestion(BoardTile tile) {
    // Eğer mülk Utility ise (Vakıf vb) soru sormadan direkt satın alma sor
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
      state = state.copyWith(lastAction: "Doğru! Ödül: 50 Puan.");
      _updateBalance(state.currentPlayer, state.currentPlayer.balance + 50);
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(showPurchaseDialog: true);
    } else {
      state = state.copyWith(lastAction: "Yanlış cevap.");
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

      state = state.copyWith(
        players: newPlayers,
        showPurchaseDialog: false,
        lastAction: "Satın alındı!",
      );
    } else {
      state = state.copyWith(
        showPurchaseDialog: false,
        lastAction: "Yetersiz bakiye!",
      );
    }
    endTurn();
  }

  void declinePurchase() {
    state = state.copyWith(
      showPurchaseDialog: false,
      lastAction: "Satın alınmadı.",
    );
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

      switch (card.effectType) {
        case CardEffectType.moneyChange:
          _updateBalance(
            state.currentPlayer,
            state.currentPlayer.balance + card.value,
          );
          break;

        case CardEffectType.move:
          // İleriye veya geriye hareket
          int currentPos = state.currentPlayer.position;
          int targetPos = card.value;

          // Eğer targetPos 40'tan büyükse veya özel bir kod ise burada işlenebilir.
          // Şimdilik value = target tile index kabul ediyoruz.
          // Başlangıç noktasından geçme kontrolü (basitçe: yeni pozisyon < eski pozisyon ise tur attı varsayalım)

          if (targetPos < currentPos && targetPos != 10) {
            // 10 = Hapishane/Kütüphane, oraya gidiliyorsa para verilmez
            _updateBalance(
              state.currentPlayer,
              state.currentPlayer.balance + 200,
            );
          }

          List<Player> newPlayers = List.from(state.players);
          newPlayers[state.currentPlayerIndex] = state.currentPlayer.copyWith(
            position: targetPos,
          );
          state = state.copyWith(players: newPlayers);

          // Gittiği yerdeki aksiyonu tetikle (Recursive gibi olmamasına dikkat et)
          // Kart çekildikten sonra tekrar kart çekilen yere gitmesi sonsuz döngü yapabilir.
          // O yüzden şimdilik sadece konumu güncelle ve turu bitir veya basit handle et.
          // Güvenli olması için turu bitiriyoruz, ancak idealde _handleTileArrival çağrılmalı.
          // Basitlik adına tur bitiriyoruz.
          break;

        case CardEffectType.jail:
          List<Player> temp = List.from(state.players);
          temp[state.currentPlayerIndex] = state.currentPlayer.copyWith(
            position: 10, // Kütüphane Nöbeti
            inJail: true,
          );
          state = state.copyWith(
            players: temp,
            lastAction: "Kütüphane nöbetine yollandın!",
          );
          break;

        case CardEffectType.globalMoney:
          // Herkesten para al veya herkese para ver
          int amount = card.value;
          List<Player> updatedPlayers = List.from(state.players);
          Player current = updatedPlayers[state.currentPlayerIndex];

          for (int i = 0; i < updatedPlayers.length; i++) {
            if (i == state.currentPlayerIndex) continue;

            // Diğer oyuncudan al/ver
            updatedPlayers[i] = updatedPlayers[i].copyWith(
              balance: updatedPlayers[i].balance - amount,
            );
            current = current.copyWith(balance: current.balance + amount);
          }
          updatedPlayers[state.currentPlayerIndex] = current;
          state = state.copyWith(players: updatedPlayers);
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
    // En zengini bul
    Player winner = state.players.reduce(
      (curr, next) => curr.balance > next.balance ? curr : next,
    );
    state = state.copyWith(winner: winner, phase: GamePhase.gameOver);
  }

  void endTurn() async {
    if (state.phase == GamePhase.gameOver) return;

    // İflas kontrolü (Bakiye < 0 ise elenir)
    if (state.currentPlayer.balance < 0) {
      state = state.copyWith(
        lastAction:
            "${state.currentPlayer.name} iflas etti ve oyundan ayrıldı!",
      );

      await Future.delayed(const Duration(seconds: 2));

      // Oyuncuyu çıkar
      List<Player> remainingPlayers = List.from(state.players);
      remainingPlayers.removeAt(state.currentPlayerIndex);

      // Eğer tek kişi kaldıysa oyun biter
      if (remainingPlayers.length <= 1) {
        state = state.copyWith(players: remainingPlayers);
        endGame();
        return;
      }

      // Sıralama bozulmasın diye index ayarı
      // Eğer son oyuncu elendiyse, index 0'a döner.
      // Eğer aradan biri elendiyse, index aynı kalır (çünkü liste kayar, sıradaki oyuncu o indexe gelir)
      int nextIndex = state.currentPlayerIndex;
      if (nextIndex >= remainingPlayers.length) {
        nextIndex = 0;
      }

      state = state.copyWith(
        players: remainingPlayers,
        currentPlayerIndex: nextIndex,
        isDiceRolled: false,
        showPurchaseDialog: false,
        showQuestionDialog: false,
        showCardDialog: false,
        showUpgradeDialog: false,
        lastAction: "Sıra ${remainingPlayers[nextIndex].name} oyuncusunda.",
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
      showCardDialog: false,
      showUpgradeDialog: false,
      lastAction: "Sıra ${state.players[next].name} oyuncusunda.",
    );
  }

  // Helper
  void _updateBalance(Player p, int bal) {
    int idx = state.players.indexWhere((x) => x.id == p.id);
    if (idx == -1) return;
    List<Player> list = List.from(state.players);
    list[idx] = list[idx].copyWith(balance: bal);
    state = state.copyWith(players: list);
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
