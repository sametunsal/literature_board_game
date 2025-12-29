import '../models/player.dart';
import '../models/tile.dart';
import '../models/question.dart';
import '../models/card.dart';
import '../models/dice_roll.dart';
import '../repositories/question_repository.dart';

class GameEngine {
  final List<Player> players;
  final List<Tile> tiles;
  final List<Question> questionPool;
  final List<Card> sansCards;
  final List<Card> kaderCards;

  int currentPlayerIndex;
  DiceRoll? lastDiceRoll;
  String? lastMessage;
  int passStartReward;

  // Callbacks for external systems (UI, logging, etc.)
  final Function(String message)? onLogMessage;
  final Function(Player player, int amount)? onStarsChanged;
  final Function(Player player, int position)? onPlayerMoved;
  final Function(Player player, Question question)? onQuestionAsked;
  final Function(Card card)? onCardDrawn;
  final Function(String message)? onRentPaid;
  final Function(Tile tile, Player owner, int cost, int balance)?
  onCopyrightPurchaseOffered;
  final Function(Player player, int amount)? onQuestionAnswered;

  GameEngine({
    required this.players,
    required this.tiles,
    required this.questionPool,
    required this.sansCards,
    required this.kaderCards,
    this.currentPlayerIndex = 0,
    this.passStartReward = 50,
    this.onLogMessage,
    this.onStarsChanged,
    this.onPlayerMoved,
    this.onQuestionAsked,
    this.onCardDrawn,
    this.onRentPaid,
    this.onCopyrightPurchaseOffered,
    this.onQuestionAnswered,
  });

  Player get currentPlayer => players[currentPlayerIndex];

  bool get isGameOver => players.where((p) => !p.isBankrupt).length <= 1;

  // Initialize game with turn order based on initial dice rolls
  void initializeGame() {
    _log('Oyun baslatiliyor...');

    // Roll dice to determine turn order
    final playerRolls = <MapEntry<Player, int>>[];
    for (final player in players) {
      final roll = DiceRoll.random();
      playerRolls.add(MapEntry(player, roll.total));
      _log('${player.name} zar atti: ${roll.total}');
    }

    // Sort players by dice total (highest first)
    playerRolls.sort((a, b) => b.value.compareTo(a.value));

    // Update player order based on rolls
    final newPlayerOrder = playerRolls.map((e) => e.key).toList();
    for (int i = 0; i < newPlayerOrder.length; i++) {
      _log('Sira ${i + 1}: ${newPlayerOrder[i].name}');
    }

    _log('Oyun basladi! Sira: ${currentPlayer.name}');
  }

  // Main turn execution - simplified for compilation
  void executeTurn() {
    if (isGameOver) {
      _log('Oyun bitti!');
      return;
    }

    _log('\n--- ${currentPlayer.name}\'in turu ---');

    // Step 1: Check if player can play
    if (!currentPlayer.canPlay) {
      _handleSkippedTurn();
      return;
    }

    // Step 2: Roll dice
    final diceRoll = _rollDice();
    lastDiceRoll = diceRoll;
    _log('Zar: ${diceRoll.die1} + ${diceRoll.die2} = ${diceRoll.total}');

    // Step 3: Check double dice
    if (diceRoll.isDouble) {
      currentPlayer.incrementDoubleCount();
      _log('Cift zar! (Sira: ${currentPlayer.doubleDiceCount})');

      // Check for 3x double
      if (currentPlayer.doubleDiceCount >= 3) {
        _triggerLibraryWatch();
        return;
      }
    } else {
      currentPlayer.resetDoubleCount();
    }

    // Step 4: Move player
    final oldPosition = currentPlayer.position;
    final newPosition = _calculateNewPosition(
      currentPlayer.position,
      diceRoll.total,
    );
    _movePlayer(currentPlayer, newPosition);

    // Check if passed START
    if (_passedStart(oldPosition, newPosition)) {
      _awardPassStart();
    }

    // Step 5: Process tile effect
    _processTileEffect(currentPlayer, newPosition);

    // Step 6: Determine next turn
    _determineNextTurn(diceRoll.isDouble);
  }

  // Roll dice
  DiceRoll _rollDice() {
    final roll = DiceRoll.random();
    return roll;
  }

  // Calculate new position (counter-clockwise, 0-39)
  int _calculateNewPosition(int currentPosition, int diceTotal) {
    return (currentPosition + diceTotal) % 40;
  }

  // Move player to new position
  void _movePlayer(Player player, int newPosition) {
    player.position = newPosition;
    onPlayerMoved?.call(player, newPosition);
    _log('${player.name} kutucuk $newPosition\'e hareket etti');
  }

  // Check if player passed START (tile 0)
  bool _passedStart(int oldPosition, int newPosition) {
    return newPosition < oldPosition;
  }

  // Award stars for passing START
  void _awardPassStart() {
    currentPlayer.addStars(passStartReward);
    _log('BASLANGIC\'ten gecti! +$passStartReward yildiz');
    onStarsChanged?.call(currentPlayer, currentPlayer.stars);
  }

  // Handle skipped turn (Library Watch, etc.)
  void _handleSkippedTurn() {
    _log('Tur atlaniyor...');

    if (currentPlayer.isInLibraryWatch) {
      _log(
        'KUTUPHANE NOBETI: ${currentPlayer.libraryWatchTurnsRemaining} tur kaldi',
      );
      currentPlayer.decrementLibraryWatchTurns();

      if (!currentPlayer.isInLibraryWatch) {
        _log('KUTUPHANE NOBETI bitti! ${currentPlayer.name} oyununa dondu');
      }
    }

    currentPlayer.resetSkippedTurn();
    _nextPlayer();
  }

  // Trigger Library Watch (3x double dice)
  void _triggerLibraryWatch() {
    _log('3x Cift Zar! KUTUPHANE NOBETI tetiklendi!');
    currentPlayer.enterLibraryWatch();
    _movePlayer(currentPlayer, 10); // Tile 10 is Library Duty
    _nextPlayer();
  }

  // Process tile effect based on tile type
  void _processTileEffect(Player player, int tileNumber) {
    final tile = tiles.firstWhere((t) => t.id == tileNumber);

    _log('Kutucuk: ${tile.name} (${tile.type})');

    switch (tile.type) {
      case TileType.book:
      case TileType.publisher:
        _handleBookTile(player, tile);
        break;

      case TileType.corner:
        _handleCornerTile(player, tile);
        break;

      case TileType.chance:
      case TileType.fate:
        _log('Kart cekilecek (basitlestirilmis)');
        break;

      case TileType.tax:
        _handleTaxTile(player, tile);
        break;

      case TileType.special:
        _log('Ozel kutucuk');
        break;
    }
  }

  // Handle book/publisher tile - Question & Economy flow
  void _handleBookTile(Player player, Tile tile) {
    // Step 1: Check ownership
    if (tile.owner == null) {
      // Unowned tile - Trigger Question Phase
      _triggerQuestionPhase(player, tile);
    } else if (tile.owner == player.id) {
      // Owned by current player - Do nothing
      _log('${player.name} kendi telifine indi. Islem gerektirmiyor.');
    } else {
      // Owned by another player - Collect rent
      _collectRent(player, tile);
    }
  }

  // Trigger Question Phase for unowned tile
  void _triggerQuestionPhase(Player player, Tile tile) {
    _log('${tile.name} telifi sahipsiz. Soru soruluyor...');

    // Get a random question from any category
    final randomCategory = QuestionCategory
        .values[DateTime.now().millisecond % QuestionCategory.values.length];
    final question = QuestionRepository.getRandomQuestion(randomCategory);

    // Trigger question display callback
    onQuestionAsked?.call(player, question);
  }

  // Handle correct answer
  void handleQuestionCorrect(Player player, Tile tile, Question question) {
    // Add star reward
    final reward = question.starReward;
    player.addStars(reward);
    onStarsChanged?.call(player, player.stars);
    onQuestionAnswered?.call(player, reward);

    _log('${player.name} doğru cevap verdi! +$reward yıldız kazandı.');

    // Offer copyright purchase
    _offerCopyrightPurchase(player, tile);
  }

  // Handle wrong answer
  void handleQuestionWrong(Player player, Question question) {
    // No penalty points (as per task requirement)
    onQuestionAnswered?.call(player, 0);

    _log('${player.name} yanlış cevap verdi. Puan kazanmadı.');
  }

  // Offer copyright purchase after correct answer
  void _offerCopyrightPurchase(Player player, Tile tile) {
    final cost = tile.purchasePrice ?? 0;
    if (cost <= 0) {
      _log('${tile.name} için satın alma fiyatı ayarlanmamış.');
      return;
    }

    _log('${tile.name} telifi için satın alma teklifi: $cost yıldız');

    // Trigger copyright purchase offer callback
    onCopyrightPurchaseOffered?.call(tile, player, cost, player.stars);
  }

  // Handle copyright purchase - YES
  void handleCopyrightPurchase(Player player, Tile tile) {
    final cost = tile.purchasePrice ?? 0;

    if (cost > player.stars) {
      _log(
        '${player.name} yetersiz bakiye! Gerekli: $cost, Sahip: ${player.stars}',
      );
      return;
    }

    // Deduct cost and assign ownership
    player.removeStars(cost);
    player.ownedTiles.add(tile.id);

    // Update tile with new owner using copyWith
    final tileIndex = tiles.indexWhere((t) => t.id == tile.id);
    if (tileIndex >= 0) {
      tiles[tileIndex] = tile.copyWith(owner: player.id);
    }

    onStarsChanged?.call(player, player.stars);

    _log('${player.name} ${tile.name} telifini satın aldı! -$cost yıldız');
  }

  // Handle copyright purchase - NO (skip purchase)
  void handleCopyrightSkip(Player player, Tile tile) {
    _log('${player.name} ${tile.name} telifini satın almadı.');
  }

  // Collect rent when player lands on owned tile
  void _collectRent(Player player, Tile tile) {
    // Find owner player
    final owner = players.firstWhere(
      (p) => p.id == tile.owner,
      orElse: () => players.first,
    );

    // Check if owner is in Library Watch
    if (owner.isInLibraryWatch) {
      _log(
        'Telif sahibi (${owner.name}) KÜTÜPHANE NÖBETİ\'nde. Kira gerekmiyor.',
      );
      return;
    }

    // Check if owner is bankrupt
    if (owner.isBankrupt) {
      _log('Telif sahibi (${owner.name}) iflas olmuş. Kira gerekmiyor.');
      return;
    }

    // Calculate rent amount
    final rentAmount = tile.copyrightFee ?? 0;
    if (rentAmount <= 0) {
      _log('${tile.name} için kira ücreti ayarlanmamış.');
      return;
    }

    // Check if player can pay rent
    if (player.stars < rentAmount) {
      // Player goes bankrupt from rent
      player.stars = 0;
      player.isBankrupt = true;
      onStarsChanged?.call(player, player.stars);

      _log('${player.name} kira ödeyemedi! İFLAS OLDU!');
      _log('${player.name} oyundan çıktı.');
      _checkBankruptcy(player);
      return;
    }

    // Transfer stars from player to owner
    player.removeStars(rentAmount);
    owner.addStars(rentAmount);

    onStarsChanged?.call(player, player.stars);
    onStarsChanged?.call(owner, owner.stars);

    // Trigger rent paid callback for UI
    onRentPaid?.call(
      '${player.name} kira ödedi: -$rentAmount yıldız → ${owner.name}: +$rentAmount yıldız',
    );

    _log('${player.name} ${tile.name} için kira ödedi: -$rentAmount yıldız');
    _log('${owner.name} kira aldı: +$rentAmount yıldız');
  }

  // Handle corner tiles
  void _handleCornerTile(Player player, Tile tile) {
    switch (tile.cornerEffect) {
      case CornerEffect.baslangic:
        _log('Kutucuk: Baslangic kutucugu');
        break;

      case CornerEffect.kutuphaneNobeti:
        _log('KUTUPHANE NOBETI! 2 tur ceza.');
        player.enterLibraryWatch();
        break;

      case CornerEffect.imzaGunu:
        _log('IMZA GUNU! Tur atlaniyor.');
        player.markTurnSkipped();
        break;

      case CornerEffect.iflasRiski:
        _log('IFLAS RISKI! %50 yildiz kaybi ve KUTUPHANE NOBETI!');
        player.losePercentageOfStars(50);
        onStarsChanged?.call(player, player.stars);

        // Move to Library Duty immediately
        _movePlayer(player, 10);
        player.enterLibraryWatch();
        _log('${player.name} kutucuk 10\'a (KUTUPHANE NOBETI) gonderildi');

        _checkBankruptcy(player);
        break;

      case null:
        break;
    }
  }

  // Handle tax tiles
  void _handleTaxTile(Player player, Tile tile) {
    int taxAmount;

    if (tile.taxType == TaxType.gelirVergisi) {
      taxAmount = _calculateTax(player.stars, 10);
      _log('GELIR VERGISI: -$taxAmount yildiz (%10)');
    } else if (tile.taxType == TaxType.yazarlikVergisi) {
      taxAmount = _calculateTax(player.stars, 15);
      _log('YAZARLIK VERGISI: -$taxAmount yildiz (%15)');
    } else {
      return;
    }

    player.removeStars(taxAmount);
    onStarsChanged?.call(player, player.stars);
    _checkBankruptcy(player);
  }

  // Calculate tax amount (percentage or fixed minimum)
  int _calculateTax(int stars, int percentage) {
    final percentageTax = (stars * percentage) ~/ 100;
    final minTax = percentage == 10 ? 20 : 30;
    return percentageTax > minTax ? percentageTax : minTax;
  }

  // Determine next turn
  void _determineNextTurn(bool wasDouble) {
    if (wasDouble) {
      _log('Cift zar! ${currentPlayer.name} tekrar zar atacak.');
      // Same player gets another turn
    } else {
      _nextPlayer();
    }
  }

  // Move to next player
  void _nextPlayer() {
    currentPlayer.resetSkippedTurn();
    int attempts = 0;
    final totalPlayers = players.length;

    do {
      currentPlayerIndex = (currentPlayerIndex + 1) % totalPlayers;
      attempts++;

      if (attempts > totalPlayers) {
        _log('Tum oyuncular iflas oldu!');
        break;
      }
    } while (currentPlayer.isBankrupt);

    _log('Sira: ${currentPlayer.name}');
  }

  // Check and handle bankruptcy
  void _checkBankruptcy(Player player) {
    if (player.isBankrupt) {
      _log('${player.name} IFLAS OLDU!');
      _log('${player.name} oyundan cikti.');

      if (isGameOver) {
        _announceWinner();
      }
    }
  }

  // Announce game winner
  void _announceWinner() {
    final winner = players.firstWhere(
      (p) => !p.isBankrupt,
      orElse: () => players.first,
    );

    _log('\n========================================');
    _log('KAZANAN: ${winner.name}');
    _log('========================================\n');

    if (isGameOver) {
      _log('Oyun bitti!');
    }
  }

  // Internal logging
  void _log(String message) {
    onLogMessage?.call(message);
  }
}
