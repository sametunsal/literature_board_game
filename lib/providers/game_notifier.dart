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
  final int currentPlayerIndex;
  final int diceTotal;
  final String lastAction;
  final bool isDiceRolled;
  final Question? currentQuestion;
  final bool showQuestionDialog;
  final bool showPurchaseDialog;
  final BoardTile? currentTile;
  final GameCard? currentCard;
  final bool showCardDialog;
  final GamePhase phase; // Yeni faz ekledik
  final String? setupMessage; // Sıralama belirleme sırasındaki mesajlar

  GameState({
    required this.players,
    this.currentPlayerIndex = 0,
    this.diceTotal = 0,
    this.lastAction = 'Oyun Başladı',
    this.isDiceRolled = false,
    this.currentQuestion,
    this.showQuestionDialog = false,
    this.showPurchaseDialog = false,
    this.currentTile,
    this.currentCard,
    this.showCardDialog = false,
    this.phase = GamePhase.setup, // Başlangıç fazı
    this.setupMessage,
  });

  Player get currentPlayer => players.isNotEmpty
      ? players[currentPlayerIndex]
      : const Player(id: '0', name: 'Loading', color: Colors.grey);

  GameState copyWith({
    List<Player>? players,
    int? currentPlayerIndex,
    int? diceTotal,
    String? lastAction,
    bool? isDiceRolled,
    Question? currentQuestion,
    bool? showQuestionDialog,
    bool? showPurchaseDialog,
    BoardTile? currentTile,
    GameCard? currentCard,
    bool? showCardDialog,
    GamePhase? phase,
    String? setupMessage,
  }) {
    return GameState(
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      diceTotal: diceTotal ?? this.diceTotal,
      lastAction: lastAction ?? this.lastAction,
      isDiceRolled: isDiceRolled ?? this.isDiceRolled,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      showQuestionDialog: showQuestionDialog ?? this.showQuestionDialog,
      showPurchaseDialog: showPurchaseDialog ?? this.showPurchaseDialog,
      currentTile: currentTile ?? this.currentTile,
      currentCard: currentCard ?? this.currentCard,
      showCardDialog: showCardDialog ?? this.showCardDialog,
      phase: phase ?? this.phase,
      setupMessage: setupMessage ?? this.setupMessage,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final Random _random = Random();

  GameNotifier() : super(GameState(players: [], tiles: BoardConfig.tiles));

  // --- OYUN KURULUMU ---
  void initializeGame(List<Player> players) {
    state = state.copyWith(
      players: players,
      // Tiles zaten init'te yüklendi ama resetlemek gerekirse tekrar BoardConfig.tiles'dan alabiliriz
      phase: GamePhase.rollingForOrder,
      setupMessage: "Sıralama için zar atılıyor...",
    );
    _determineTurnOrder();
  }

  void _determineTurnOrder() async {
    await Future.delayed(const Duration(seconds: 1));

    // Basit sıralama mantığı: Herkese rastgele bir sayı ata ve sırala
    // Gerçek zar atma animasyonu gibi göstermek için delay'ler eklenebilir

    List<Map<String, dynamic>> orderResults = [];

    for (var player in state.players) {
      int roll = _random.nextInt(11) + 2; // 2-12
      orderResults.add({'player': player, 'roll': roll});

      // Tek tek göstermek istersek burada state update edip delay koyabiliriz
      // Şimdilik hızlı geçelim
    }

    // Zarlara göre sırala (Büyükten küçüğe)
    orderResults.sort((a, b) => b['roll'].compareTo(a['roll']));

    List<Player> sortedPlayers = orderResults
        .map((e) => e['player'] as Player)
        .toList();

    // Setup bitti, oyun başlıyor
    String orderMsg =
        "Sıralama: " +
        sortedPlayers
            .map(
              (p) =>
                  "${p.name} (${orderResults.firstWhere((e) => e['player'] == p)['roll']})",
            )
            .join(", ");

    state = state.copyWith(
      players: sortedPlayers,
      phase: GamePhase.playing,
      lastAction: "Oyun Başladı! $orderMsg",
      currentPlayerIndex: 0,
      setupMessage: null,
    );
  }

  // --- 1. ZAR ATMA ---
  void rollDice() async {
    if (state.phase != GamePhase.playing) return; // Sadece oyun modunda çalışır

    if (state.isDiceRolled ||
        state.showQuestionDialog ||
        state.showPurchaseDialog ||
        state.showCardDialog)
      return;

    int roll = _random.nextInt(11) + 2;
    state = state.copyWith(
      isDiceRolled: true,
      diceTotal: roll,
      lastAction: "Zar atılıyor...",
    );
    await Future.delayed(const Duration(milliseconds: 600));

    var player = state.currentPlayer;

    // Kütüphane Nöbeti Kontrolü (Basit)
    if (player.inJail) {
      // Şimdilik 1 tur ceza gibi davranıp çıkıyor
      List<Player> newPlayers = List.from(state.players);
      newPlayers[state.currentPlayerIndex] = player.copyWith(inJail: false);
      state = state.copyWith(
        players: newPlayers,
        lastAction: "Kütüphane nöbetinden çıktın.",
      );
      endTurn();
      return;
    }

    int newPos = (player.position + roll) % 40;

    int newBalance = player.balance;
    if (newPos < player.position) {
      newBalance += 200; // Tur primi
    }

    List<Player> newPlayers = List.from(state.players);
    newPlayers[state.currentPlayerIndex] = player.copyWith(
      position: newPos,
      balance: newBalance,
    );

    // BoardConfig yerine state.tiles kullanıyoruz
    final tile = state.tiles[newPos];

    state = state.copyWith(
      players: newPlayers,
      diceTotal: roll,
      currentTile: tile,
      lastAction: "${tile.title} karesine gelindi.",
    );

    _handleTileArrival(tile);
  }

  // --- 2. KUTUCUK MANTIĞI (GELİŞMİŞ) ---
  void _handleTileArrival(BoardTile tile) {
    if (tile.type == TileType.property ||
        tile.type == TileType.publisher ||
        tile.type == TileType.educationFoundation) {
      Player? owner = _getTileOwner(tile.id);

      if (owner != null) {
        if (owner.id == state.currentPlayer.id) {
          // KENDİ MÜLKÜ -> Geliştirme Kontrolü
          if (!tile.isUtilities && tile.upgradeLevel < 4) {
            state = state.copyWith(
              showUpgradeDialog: true,
              lastAction: "Mülk geliştirme fırsatı!",
            );
          } else if (!tile.isUtilities && tile.upgradeLevel == 4) {
            state = state.copyWith(
              lastAction: "Telif Hakkı Zirvede! (Max Seviye)",
            );
            endTurn();
          } else {
            state = state.copyWith(lastAction: "Kendi mülkünüzdesiniz.");
            endTurn();
          }
        } else {
          // BAŞKASININ MÜLKÜ -> Kira
          _payRent(tile, owner);
        }
      } else {
        // SAHİPSİZ -> Soru tetikle (Satın alma orada açılıyor)
        // Yayınevleri için soru var mı? BoardConfig'de null olabilir.
        if (tile.questionCategory == null) {
          state = state.copyWith(
            showPurchaseDialog: true,
            lastAction: "Satın alınabilir mülk.",
          );
        } else {
          _triggerQuestion(tile);
        }
      }
    }
    // B) ŞANS / KADER
    else if (tile.type == TileType.chance || tile.type == TileType.fate) {
      _drawCard(tile.type);
    }
    // C) CEZA KARELERİ
    else if (tile.type == TileType.bankruptcyRisk) {
      int newBalance = (state.currentPlayer.balance / 2).floor();
      _updateCurrentPlayerBalance(newBalance);
      state = state.copyWith(
        lastAction: "İFLAS RİSKİ! Puanlarınız yarıya düştü.",
      );
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

  // --- KİRA HESAPLAMA (GELİŞMİŞ) ---
  int _calculateRent(BoardTile tile) {
    if (tile.isUtilities) {
      // Yayınevi/Vakıf: Zar * 15
      return state.diceTotal * 15;
    } else {
      // Mülk: Seviyeye göre katlama
      int base = tile.baseRent ?? 10;
      switch (tile.upgradeLevel) {
        case 0:
          return base;
        case 1:
          return base * 2;
        case 2:
          return base * 4;
        case 3:
          return base * 8;
        case 4:
          return base * 20;
        default:
          return base;
      }
    }
  }

  void _payRent(BoardTile tile, Player owner) {
    int rent = _calculateRent(tile);

    _updateCurrentPlayerBalance(state.currentPlayer.balance - rent);

    int ownerIndex = state.players.indexWhere((p) => p.id == owner.id);
    List<Player> tempPlayers = List.from(state.players);
    tempPlayers[ownerIndex] = tempPlayers[ownerIndex].copyWith(
      balance: tempPlayers[ownerIndex].balance + rent,
    );

    state = state.copyWith(
      players: tempPlayers,
      lastAction: "${owner.name}'e $rent kira ödendi.",
    );

    // Oyun bitirme kontrolü (Basit iflas)
    if (state.currentPlayer.balance <= 0) {
      // İflas mantığı eklenebilir ama şimdilik devam veya oyun sonu
      // endGame();
    }

    endTurn();
  }

  // --- MÜLK GELİŞTİRME ---
  void upgradeProperty() {
    final tile = state.currentTile;
    final player = state.currentPlayer;

    if (tile == null || tile.price == null) return;

    if (tile.upgradeLevel >= 4) return;

    int cost = 0;
    if (tile.upgradeLevel < 3) {
      // Baskı Yap (0->1, 1->2, 2->3) -> Fiyat * 0.5
      cost = (tile.price! * 0.5).round();
    } else {
      // Cilt/Seri (3->4) -> Fiyat * 2
      cost = (tile.price! * 2).round();
    }

    if (player.balance >= cost) {
      // Ödeme yap
      _updateCurrentPlayerBalance(player.balance - cost);

      // Tile güncelle
      int tileIndex = state.tiles.indexWhere((t) => t.id == tile.id);
      if (tileIndex != -1) {
        // BoardTile'a copyWith lazım, ama şu an yok gibi duruyor? Varsa kullanalım.
        // Elimizdeki BoardTile modeline copyWith eklemedik. Manuel yeni obje oluşturalım.
        BoardTile oldTile = state.tiles[tileIndex];
        BoardTile newTile = BoardTile(
          id: oldTile.id,
          title: oldTile.title,
          type: oldTile.type,
          price: oldTile.price,
          baseRent: oldTile.baseRent,
          questionCategory: oldTile.questionCategory,
          isUtilities: oldTile.isUtilities,
          upgradeLevel: oldTile.upgradeLevel + 1,
        );

        List<BoardTile> newTiles = List.from(state.tiles);
        newTiles[tileIndex] = newTile;

        state = state.copyWith(
          tiles: newTiles,
          currentTile: newTile, // Current tile'ı da güncelle
          showUpgradeDialog: false,
          lastAction:
              "${newTile.title} geliştirildi! (Seviye ${newTile.upgradeLevel})",
        );
      }
    } else {
      state = state.copyWith(lastAction: "Geliştirme için yetersiz bakiye.");
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

  // --- OYUN SONU ---
  void endGame() {
    // En zengin oyuncuyu bul
    Player winner = state.players.reduce(
      (curr, next) => curr.balance > next.balance ? curr : next,
    );
    state = state.copyWith(
      phase: GamePhase.gameOver,
      lastAction:
          "OYUN BİTTİ! Kazanan: ${winner.name} (${winner.balance} Puan)",
    );
  }

  // --- 3. KART SİSTEMİ (YENİ) ---
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
      _applyCardEffect(state.currentCard!);
    }
    state = state.copyWith(showCardDialog: false, currentCard: null);
    endTurn();
  }

  void _applyCardEffect(GameCard card) {
    Player player = state.currentPlayer;

    switch (card.effectType) {
      case CardEffectType.moneyChange:
        _updateCurrentPlayerBalance(player.balance + card.value);
        break;

      case CardEffectType.move:
        List<Player> newPlayers = List.from(state.players);
        newPlayers[state.currentPlayerIndex] = player.copyWith(
          position: card.value,
        );
        state = state.copyWith(
          players: newPlayers,
          lastAction: "Kart etkisiyle ilerlendi.",
        );
        // Gittiği yerde tekrar işlem yapmaması için şimdilik sadece konum değişiyor
        break;

      case CardEffectType.jail:
        List<Player> newPlayers = List.from(state.players);
        newPlayers[state.currentPlayerIndex] = player.copyWith(
          position: 10,
          inJail: true,
        ); // 10: Kütüphane ID
        state = state.copyWith(
          players: newPlayers,
          lastAction: "Kütüphane nöbetine yollandın!",
        );
        break;

      case CardEffectType.globalMoney:
        // Herkesten para al veya herkese ver
        int amount = card.value;
        List<Player> tempPlayers = List.from(state.players);

        if (amount > 0) {
          // Herkesten al
          for (int i = 0; i < tempPlayers.length; i++) {
            if (i != state.currentPlayerIndex) {
              tempPlayers[i] = tempPlayers[i].copyWith(
                balance: tempPlayers[i].balance - amount,
              );
              tempPlayers[state.currentPlayerIndex] =
                  tempPlayers[state.currentPlayerIndex].copyWith(
                    balance:
                        tempPlayers[state.currentPlayerIndex].balance + amount,
                  );
            }
          }
        } else {
          // Herkese ver
          int payAmount = amount.abs();
          for (int i = 0; i < tempPlayers.length; i++) {
            if (i != state.currentPlayerIndex) {
              tempPlayers[i] = tempPlayers[i].copyWith(
                balance: tempPlayers[i].balance + payAmount,
              );
              tempPlayers[state.currentPlayerIndex] =
                  tempPlayers[state.currentPlayerIndex].copyWith(
                    balance:
                        tempPlayers[state.currentPlayerIndex].balance -
                        payAmount,
                  );
            }
          }
        }
        state = state.copyWith(
          players: tempPlayers,
          lastAction: "Global ödeme gerçekleşti.",
        );
        break;
    }
  }

  // --- 4. SORU VE SATIN ALMA ---
  void _triggerQuestion(BoardTile tile) {
    if (tile.category == null) {
      state = state.copyWith(
        showPurchaseDialog: true,
        lastAction: "Satın alınabilir mülk.",
      );
      return;
    }
    final question = mockQuestions[_random.nextInt(mockQuestions.length)];
    state = state.copyWith(showQuestionDialog: true, currentQuestion: question);
  }

  void answerQuestion(int index) async {
    if (state.currentQuestion == null) return;

    bool isCorrect = index == state.currentQuestion!.correctIndex;
    state = state.copyWith(showQuestionDialog: false, currentQuestion: null);

    if (isCorrect) {
      int reward = 50;
      _updateCurrentPlayerBalance(state.currentPlayer.balance + reward);
      state = state.copyWith(lastAction: "DOĞRU! $reward puan kazandınız.");
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(showPurchaseDialog: true);
    } else {
      state = state.copyWith(lastAction: "YANLIŞ! Sıra geçti.");
      endTurn();
    }
  }

  void purchaseProperty() {
    final tile = state.currentTile;
    final player = state.currentPlayer;
    if (tile != null && tile.price != null && player.balance >= tile.price!) {
      List<int> newOwned = List.from(player.ownedTiles)..add(tile.id);
      int newBalance = player.balance - tile.price!;

      List<Player> newPlayers = List.from(state.players);
      newPlayers[state.currentPlayerIndex] = player.copyWith(
        balance: newBalance,
        ownedTiles: newOwned,
      );

      state = state.copyWith(
        players: newPlayers,
        showPurchaseDialog: false,
        lastAction: "${tile.title} satın alındı!",
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
      lastAction: "Satın alma reddedildi.",
    );
    endTurn();
  }

  // --- HELPER METHODS ---
  Player? _getTileOwner(int tileId) {
    for (var p in state.players) {
      if (p.ownedTiles.contains(tileId)) return p;
    }
    return null;
  }

  void _updateCurrentPlayerBalance(int newBalance) {
    List<Player> newPlayers = List.from(state.players);
    newPlayers[state.currentPlayerIndex] = state.currentPlayer.copyWith(
      balance: newBalance,
    );
    state = state.copyWith(players: newPlayers);
  }

  void endTurn() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    int nextIndex = (state.currentPlayerIndex + 1) % state.players.length;
    state = state.copyWith(
      currentPlayerIndex: nextIndex,
      isDiceRolled: false,
      showPurchaseDialog: false,
      showQuestionDialog: false,
      showCardDialog: false, // Dialogları resetle
      lastAction: "Sıra ${state.players[nextIndex].name} oyuncusunda.",
    );
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>(
  (ref) => GameNotifier(),
);
