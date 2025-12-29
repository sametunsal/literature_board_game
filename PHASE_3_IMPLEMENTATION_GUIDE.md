# Phase 3 Implementation Guide - Strategic Gameplay Mechanics

## Overview
This document provides implementation details for Phase 3 critical gameplay mechanics needed for a playable MVP.

---

## Implementation Status

### ✅ Already Implemented
1. **Card Drawing Logic** - `drawCard()` method in game_provider.dart
2. **Card Effects** - `applyCardEffect()` with all effect types:
   - Personal: gainStars, loseStars, skipNextTax, freeTurn, easyQuestionNext
   - Global: allPlayersGainStars, allPlayersLoseStars, taxWaiver, allPlayersEasyQuestion
   - Targeted: publisherOwnersLose, richPlayerPays
3. **Question System** - Display, selection, rewards
4. **Tax Tiles** - GELİR VERGİSİ, YAZARLIK VERGİSİ
5. **Corner Tiles** - BAŞLANGIÇ, KÜTÜPHANE NÖBETİ, İFLAS RİSKİ, İMZA GÜNÜ

### ❌ Missing Mechanics
1. **Question Timer Countdown** - Timer duration exists but no countdown mechanism
2. **Copyright Purchase Flow** - Dialog exists but no purchase logic
3. **Rent Collection System** - No implementation
4. **Special Tiles** - YAZARLIK OKULU, DE EĞİTİM VAKFI

---

## Task 1: Question Timer Implementation

### Requirements
- Countdown timer that decreases each second
- Auto-fail question when timer reaches 0
- Visual warning when time is low (<10 seconds)
- Timer state in GameState (`questionTimer`)

### Implementation

#### 1. Add Timer State to GameState
```dart
// Already in GameState:
final int? questionTimer;
```

#### 2. Add Timer Provider (if not exists)
```dart
// Already exists in game_provider.dart:
final questionTimerProvider = Provider<int>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.questionTimer ?? 0;
});
```

#### 3. Start Timer in _showQuestion()
The timer is already set when question is shown:
```dart
state = state.copyWith(
  questionState: QuestionState.answering,
  currentQuestion: question,
  questionTimer: GameConstants.questionTimerDuration, // 30 seconds
);
```

#### 4. Add Tick Method to GameNotifier
Add a method to decrement timer:

```dart
/// Decrement question timer
/// Call this from UI every second while question is active
void tickQuestionTimer() {
  if (state.questionState != QuestionState.answering) return;
  if (state.questionTimer == null || state.questionTimer! <= 0) return;

  final newTimer = state.questionTimer! - 1;

  // Check if timer reached 0
  if (newTimer <= 0) {
    // Auto-fail on timeout
    answerQuestionWrong();
    state = state.withLogMessage(
      'Süre doldu! Soru yanlış sayıldı.',
    );
    return;
  }

  // Visual warning at <10 seconds
  if (newTimer <= 10 && newTimer > 0) {
    state = state.withLogMessage(
      '⚠️ Kalan süre: $newTimer saniye',
    );
  }

  state = state.copyWith(questionTimer: newTimer);
}
```

#### 5. UI Integration
In `QuestionDialog`, add a timer that calls `tickQuestionTimer()`:

```dart
// In question_dialog.dart:
// Use Timer.periodic to tick every second
Timer? _timer;

@override
void initState() {
  super.initState();
  final gameState = ref.watch(gameProvider);
  
  if (gameState.questionState == QuestionState.answering) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      ref.read(gameProvider.notifier).tickQuestionTimer();
    });
  }
}

@override
void dispose() {
  _timer?.cancel();
  super.dispose();
}
```

---

## Task 2: Copyright Purchase Flow

### Requirements
- Players can purchase copyrights on book/publisher tiles after correct answer
- Deduct stars from player
- Add tile to player's ownedTiles
- Prevent purchase if insufficient stars
- Log transactions
- Tile owner tracking

### Implementation

#### 1. Add purchaseCopyright() Method to GameNotifier

```dart
/// Purchase copyright for current tile
/// Called after correct answer on book/publisher tile
void purchaseCopyright() {
  if (state.currentPlayer == null) return;
  if (state.currentQuestion == null) return;

  final currentPlayer = state.currentPlayer!;
  final tileNumber = state.newPosition ?? currentPlayer.position;
  final tile = state.tiles.firstWhere((t) => t.id == tileNumber);

  // Validate tile can be owned
  if (!tile.canBeOwned) {
    state = state.withLogMessage(
      '${tile.name} telifi satın alınamaz.',
    );
    return;
  }

  // Check if tile already owned
  if (tile.owner != null) {
    state = state.withLogMessage(
      '${tile.name} zaten ${tile.owner} tarafından satın alınmış.',
    );
    return;
  }

  // Check if player already owns this tile
  if (currentPlayer.ownsTile(tile.id)) {
    state = state.withLogMessage(
      '${currentPlayer.name} zaten ${tile.name} telifini sahipleniyor.',
    );
    return;
  }

  // Validate purchase price
  final purchasePrice = tile.purchasePrice ?? 0;
  if (purchasePrice <= 0) {
    state = state.withLogMessage(
      '${tile.name} için satın alma fiyatı ayarlanmamış.',
    );
    return;
  }

  // Check if player has enough stars
  if (currentPlayer.stars < purchasePrice) {
    state = state.withLogMessage(
      '${currentPlayer.name} telifi satın almak için yeterli yıldıza sahip değil. '
      'Gerekli: $purchasePrice, Sahip olunan: ${currentPlayer.stars}',
    );
    return;
  }

  // Apply purchase
  final updatedPlayer = currentPlayer.copyWith(
    stars: currentPlayer.stars - purchasePrice,
    ownedTiles: [...currentPlayer.ownedTiles, tile.id],
  );

  final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);

  // Update tile owner
  final updatedTiles = state.tiles.map((t) {
    if (t.id == tile.id) {
      return t.copyWith(owner: currentPlayer.id);
    }
    return t;
  }).toList();

  // Update state
  state = state
      .copyWith(
        players: updatedPlayers,
        tiles: updatedTiles,
      )
      .withLogMessage(
        '${currentPlayer.name} ${tile.name} telifini satın aldı! -$purchasePrice yıldız',
      );

  // TRANSCRIPT: Record copyright purchase
  _currentTranscript = _currentTranscript.addCopyrightPurchased(
    tile.id,
    tile.name,
    purchasePrice,
  );
  debugPrint('📜 Copyright purchased: ${tile.name} - $purchasePrice stars');
}
```

#### 2. Add owner Field to Tile Model

Update `lib/models/tile.dart`:

```dart
class Tile {
  final int id;
  final String name;
  final TileType type;
  final String? owner; // ADD THIS FIELD
  
  // ... existing fields ...
  
  const Tile({
    required this.id,
    required this.name,
    required this.type,
    this.owner, // ADD THIS PARAMETER
    // ... existing parameters ...
  });
  
  // Add copyWith method if not exists
  Tile copyWith({
    int? id,
    String? name,
    TileType? type,
    String? owner,
    // ... other fields ...
  }) {
    return Tile(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      owner: owner ?? this.owner,
      // ... other fields ...
    );
  }
}
```

#### 3. Add Transcript Event for Copyright Purchase

Update `lib/models/turn_result.dart` TurnTranscript class:

```dart
TurnTranscript addCopyrightPurchased(int tileId, String tileName, int amount) {
  return TurnTranscript(
    playerIndex: playerIndex,
    events: [...events, TurnEvent(
      type: TurnEventType.copyrightPurchased,
      timestamp: DateTime.now(),
      description: 'Satın alındı: $tileName',
      data: {
        'tileId': tileId,
        'tileName': tileName,
        'amount': amount,
      },
    )],
  );
}
```

#### 4. UI Integration

In `QuestionDialog`, after correct answer:

```dart
// Show purchase option if tile can be owned
if (tile.canBeOwned && !player.ownsTile(tile.id) && tile.owner == null) {
  showDialog(
    context: context,
    builder: (context) => CopyrightPurchaseDialog(
      tile: tile,
      playerStars: player.stars,
      onPurchase: () {
        ref.read(gameProvider.notifier).purchaseCopyright();
        Navigator.of(context).pop();
        Navigator.of(context).pop(); // Close question dialog too
      },
      onSkip: () {
        Navigator.of(context).pop(); // Just close purchase dialog
      },
    ),
  );
}
```

---

## Task 3: Rent Collection System

### Requirements
- Check tile ownership when player lands
- Calculate rent amount based on tile.copyrightFee
- Transfer stars from current player to tile owner
- Handle bankruptcy from rent payment
- Handle special cases (owner in Library Watch)
- Log transactions

### Implementation

#### 1. Add collectRent() Method to GameNotifier

```dart
/// Collect rent when player lands on owned tile
/// Called during tile resolution
void collectRent() {
  if (state.currentPlayer == null) return;

  final currentPlayer = state.currentPlayer!;
  final tileNumber = state.newPosition ?? currentPlayer.position;
  final tile = state.tiles.firstWhere((t) => t.id == tileNumber);

  // Check if tile can be owned
  if (!tile.canBeOwned) {
    return; // Not a rent-paying tile
  }

  // Check if tile has owner
  if (tile.owner == null) {
    return; // Unowned tile - no rent
  }

  // Check if current player owns the tile
  if (currentPlayer.id == tile.owner) {
    state = state.withLogMessage(
      '${currentPlayer.name} kendi telifine indi. Kira ödemesi gerekmiyor.',
    );
    return;
  }

  // Find owner player
  final ownerPlayer = state.players.firstWhere(
    (p) => p.id == tile.owner,
    orElse: () => state.players.first,
  );

  // Check if owner is in Library Watch
  if (ownerPlayer.isInLibraryWatch) {
    state = state.withLogMessage(
      'Telif sahibi (${ownerPlayer.name}) KÜTÜPHANE NÖBETİ\'nde. '
      'Kira ödemesi gerekmiyor.',
    );
    return;
  }

  // Check if owner is bankrupt
  if (ownerPlayer.isBankrupt) {
    state = state.withLogMessage(
      'Telif sahibi (${ownerPlayer.name}) iflas olmuş. '
      'Kira ödemesi gerekmiyor.',
    );
    return;
  }

  // Calculate rent amount
  final rentAmount = tile.copyrightFee ?? 0;
  if (rentAmount <= 0) {
    state = state.withLogMessage(
      '${tile.name} için kira ücreti ayarlanmamış.',
    );
    return;
  }

  // Check if player can pay rent
  if (currentPlayer.stars < rentAmount) {
    // Player goes bankrupt from rent
    final bankruptPlayer = currentPlayer.copyWith(
      stars: 0,
      isBankrupt: true,
    );
    final updatedPlayers = _updatePlayerInList(state.players, bankruptPlayer);

    state = state
        .copyWith(players: updatedPlayers)
        .withLogMessage(
          '${currentPlayer.name} kira ödeyemedi! İFLAS OLDU!',
        );

    // TRANSCRIPT: Record bankruptcy
    _currentTranscript = _currentTranscript.addBankruptcy(currentPlayer.name);
    _checkBankruptcy();
    return;
  }

  // Transfer stars from player to owner
  final updatedPlayer = currentPlayer.copyWith(
    stars: currentPlayer.stars - rentAmount,
  );

  final updatedOwner = ownerPlayer.copyWith(
    stars: ownerPlayer.stars + rentAmount,
  );

  // Update both players in list
  final updatedPlayers = _updatePlayerInList(
    _updatePlayerInList(state.players, updatedPlayer),
    updatedOwner,
  );

  // Update state
  state = state
      .copyWith(players: updatedPlayers)
      .withLogMessage(
        '${currentPlayer.name} kira ödedi: -$rentAmount yıldız '
        '→ ${ownerPlayer.name}: +$rentAmount yıldız',
      );

  // TRANSCRIPT: Record rent paid
  _currentTranscript = _currentTranscript.addRentPaid(
    tile.id,
    tile.name,
    ownerPlayer.name,
    rentAmount,
  );
  debugPrint('💰 Rent paid: ${tile.name} - $rentAmount stars to ${ownerPlayer.name}');
}
```

#### 2. Call collectRent() in Tile Resolution

Update `resolveCurrentTile()` method:

```dart
void resolveCurrentTile() {
  if (!_requirePhase(TurnPhase.moved, 'resolveCurrentTile')) return;
  if (state.currentPlayer == null) return;

  final tileNumber = state.newPosition ?? state.currentPlayer!.position;
  final tile = state.tiles.firstWhere((t) => t.id == tileNumber);

  // Update phase to tileResolved
  state = state.copyWith(turnPhase: TurnPhase.tileResolved);

  // TRANSCRIPT: Record tile resolution
  _currentTranscript = _currentTranscript.addTileResolved(
    tile.id,
    tile.name,
    tile.type.toString(),
  );

  // UI FEEDBACK LOG: Tile type information
  String tileLog = 'Kutucuk: ${tile.name} (${tile.type})';

  // CHECK FOR RENT FIRST (for owned tiles)
  if (tile.canBeOwned && tile.owner != null && 
      state.currentPlayer!.id != tile.owner) {
    collectRent();
    return; // Don't ask question or draw card on owned tiles
  }

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
}
```

#### 3. Add Transcript Event for Rent Payment

Update `lib/models/turn_result.dart`:

```dart
TurnTranscript addRentPaid(int tileId, String tileName, String ownerName, int amount) {
  return TurnTranscript(
    playerIndex: playerIndex,
    events: [...events, TurnEvent(
      type: TurnEventType.rentPaid,
      timestamp: DateTime.now(),
      description: 'Kira ödendi: $tileName',
      data: {
        'tileId': tileId,
        'tileName': tileName,
        'ownerName': ownerName,
        'amount': amount,
      },
    )],
  );
}
```

---

## Task 4: Remaining Special Tiles

### Requirements
1. **YAZARLIK OKULU (Tile 13)** - Bonus question opportunity
2. **DE EĞİTİM VAKFI (Tile 29)** - Bonus stars without question

### Implementation

#### 1. Add Special Tile Handler Method

```dart
/// Handle special tiles (YAZARLIK OKULU, DE EĞİTİM VAKFI)
void _handleSpecialTile(Tile tile) {
  if (state.currentPlayer == null) return;

  final currentPlayer = state.currentPlayer!;

  switch (tile.specialType) {
    case SpecialType.yazarlikOkulu:
      // YAZARLIK OKULU: Bonus question
      _showQuestion(tile);
      state = state.withLogMessage(
        'YAZARLIK OKULU! ${currentPlayer.name} bonus soru sorulacak.',
      );
      break;

    case SpecialType.deEgitimVakfi:
      // DE EĞİTİM VAKFI: Bonus stars without question
      final bonusAmount = 40; // Bonus stars
      final updatedPlayer = currentPlayer.copyWith(
        stars: currentPlayer.stars + bonusAmount,
      );
      final updatedPlayers = _updatePlayerInList(state.players, updatedPlayer);

      state = state
          .copyWith(players: updatedPlayers)
          .withLogMessage(
            'DE EĞİTİM VAKFI! ${currentPlayer.name}: +$bonusAmount bonus yıldız',
          );

      // TRANSCRIPT: Record bonus received
      _currentTranscript = _currentTranscript.addBonusReceived(
        tile.id,
        tile.name,
        bonusAmount,
      );
      debugPrint('⭐ Bonus received: ${tile.name} - $bonusAmount stars');
      break;

    case null:
      break;
  }
}
```

#### 2. Integrate into Tile Resolution

Update `resolveCurrentTile()` to handle special tiles:

```dart
case TileType.special:
  tileLog += ' - Özel kutucuk';
  state = state.withLogMessage(tileLog);
  _handleSpecialTile(tile); // ADD THIS
  break;
```

#### 3. Add Transcript Event for Bonus Received

Update `lib/models/turn_result.dart`:

```dart
TurnTranscript addBonusReceived(int tileId, String tileName, int amount) {
  return TurnTranscript(
    playerIndex: playerIndex,
    events: [...events, TurnEvent(
      type: TurnEventType.bonusReceived,
      timestamp: DateTime.now(),
      description: 'Bonus: $tileName',
      data: {
        'tileId': tileId,
        'tileName': tileName,
        'amount': amount,
      },
    )],
  );
}
```

---

## Updated TurnEventType Enum

Add new event types to `lib/models/turn_result.dart`:

```dart
enum TurnEventType {
  // Existing events...
  diceRoll,
  move,
  tileResolved,
  questionAsked,
  questionAnswered,
  cardDrawn,
  cardApplied,
  taxPaid,
  bankruptcy,
  phaseTransition,

  // New events for Phase 3:
  copyrightPurchased,  // When player buys a tile
  rentPaid,           // When player pays rent
  bonusReceived,        // When player gets bonus from special tile
}
```

---

## Testing Checklist

After implementing all Phase 3 mechanics, test:

### Question Timer
- [ ] Timer counts down from 30 to 0
- [ ] Auto-fails when timer reaches 0
- [ ] Visual warning appears at <10 seconds
- [ ] Timer stops when question is answered
- [ ] Timer works correctly across multiple questions

### Copyright Purchase
- [ ] Purchase option appears after correct answer
- [ ] Can purchase with sufficient stars
- [ ] Cannot purchase with insufficient stars
- [ ] Stars deducted correctly
- [ ] Tile added to ownedTiles
- [ ] Tile owner updated
- [ ] Cannot purchase same tile twice
- [ ] Cannot purchase already owned tiles

### Rent Collection
- [ ] Rent paid when landing on owned tiles
- [ ] Stars transferred correctly
- [ ] No rent on own tiles
- [ ] No rent when owner is in Library Watch
- [ ] No rent when owner is bankrupt
- [ ] Bankruptcy triggered if cannot pay rent
- [ ] Transaction logged correctly

### Special Tiles
- [ ] YAZARLIK OKULU shows bonus question
- [ ] Bonus question rewards correctly
- [ ] DE EĞİTİM VAKFI gives bonus stars
- [ ] No question required for DE EĞİTİM VAKFI
- [ ] Bonus amount correct

---

## Integration with Existing UI

### Question Dialog Updates
- Add timer display (countdown from 30)
- Add purchase button for copyright tiles
- Handle purchase confirmation dialog
- Update timer display in real-time

### Turn Summary Updates
- Include copyright purchases in summary
- Include rent payments in summary
- Include bonus received in summary
- Show tile ownership changes

### Game Log Updates
- Copyright purchase logs
- Rent payment logs
- Bonus received logs
- Timer warning logs

---

## Dependencies

### Required Methods (Already Exist):
- ✅ `_updatePlayerInList()` - Update player in list immutably
- ✅ `_checkBankruptcy()` - Check and handle bankruptcy
- ✅ `_showQuestion()` - Display question dialog
- ✅ `_getRandomQuestion()` - Get question from pool

### New Methods to Add:
- ❌ `tickQuestionTimer()` - Decrement question timer
- ❌ `purchaseCopyright()` - Handle copyright purchase
- ❌ `collectRent()` - Handle rent collection
- ❌ `_handleSpecialTile()` - Handle special tiles

### Model Updates Required:
- ❌ Tile: Add `owner` field
- ❌ Tile: Add `copyWith()` method
- ❌ TurnEventType: Add `copyrightPurchased`, `rentPaid`, `bonusReceived`
- ❌ TurnTranscript: Add helper methods for new events

---

## Success Criteria

Phase 3 is complete when:
- ✅ Question timer counts down and auto-fails
- ✅ Players can purchase copyrights on book/publisher tiles
- ✅ Players pay rent when landing on owned tiles
- ✅ All special tiles implemented (YAZARLIK OKULU, DE EĞİTİM VAKFI)
- ✅ Complete game loop playable from start to bankruptcy/win
- ✅ All transactions logged correctly
- ✅ All mechanics deterministic and testable

---

## Next Steps

1. **Implement Question Timer** (1-2 days)
   - Add `tickQuestionTimer()` method
   - Update QuestionDialog with timer UI
   - Test timer functionality

2. **Implement Copyright Purchase** (3-4 days)
   - Add `purchaseCopyright()` method
   - Update Tile model with owner field
   - Add transcript events
   - Update QuestionDialog integration
   - Test purchase flow

3. **Implement Rent Collection** (2-3 days)
   - Add `collectRent()` method
   - Integrate into tile resolution
   - Add transcript events
   - Test rent payment scenarios

4. **Implement Special Tiles** (1-2 days)
   - Add `_handleSpecialTile()` method
   - Handle YAZARLIK OKULU and DE EĞİTİM VAKFI
   - Add transcript events
   - Test special tile effects

5. **Comprehensive Testing** (2-3 days)
   - Test all Phase 3 mechanics
   - Verify integration with existing systems
   - Check edge cases
   - Validate deterministic behavior

---

**Document Version**: 1.0  
**Last Updated**: 2025-12-29  
**Status**: Ready for Implementation
