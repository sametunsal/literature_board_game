# State Management Documentation

This document describes the state management implementation using **Riverpod** in the Literature Board Game project.

## Overview

The project uses **Riverpod** for reactive state management. Riverpod was chosen for its:

- **Compile-time safety**: Errors are caught at compile time
- **No BuildContext needed**: State can be accessed anywhere
- **Testability**: Easy to test with dependency injection
- **Performance**: Efficient rebuilds with selective listening

## Provider Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      PROVIDER HIERARCHY                       │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  gameProvider │    │ themeProvider │    │  Repository   │
│               │    │               │    │   Providers   │
│ GameNotifier  │    │ThemeNotifier  │    │               │
│               │    │               │    │ - gameRepo    │
│ - rollDice()  │    │ - toggleTheme │    │ - playerRepo  │
│ - movePlayer()│    │ - setMode()   │    │ - questionRepo│
│ - buyProperty │    │               │    │               │
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  UI Components  │
                    │                 │
                    │ - BoardView     │
                    │ - GameButton    │
                    │ - GameDialog    │
                    └─────────────────┘
```

## Main Providers

### gameProvider

The main game state provider that manages all game-related state.

**Location**: [`lib/providers/game_notifier.dart`](../lib/providers/game_notifier.dart)

**State Class**: `GameState`

```dart
class GameState {
  // Player State
  final List<Player> players;
  final int currentPlayerIndex;
  
  // Dice State
  final int diceTotal;
  final int dice1;
  final int dice2;
  final int consecutiveDoubles;
  final bool isDiceRolled;
  
  // Game Phase
  final GamePhase phase;
  
  // Board State
  final List<BoardTile> tiles;
  final BoardTile? currentTile;
  
  // Dialog States
  final bool showQuestionDialog;
  final bool showPurchaseDialog;
  final bool showCardDialog;
  final bool showUpgradeDialog;
  final bool showRentDialog;
  final bool showLibraryPenaltyDialog;
  final bool showImzaGunuDialog;
  final bool showTurnSkippedDialog;
  
  // Dialog Data
  final Question? currentQuestion;
  final GameCard? currentCard;
  final String? rentOwnerName;
  final int? rentAmount;
  
  // Game State
  final Player? winner;
  final String lastAction;
  final List<String> logs;
  final FloatingEffect? floatingEffect;
  
  // Setup State
  final String? setupMessage;
  final Map<String, int> orderRolls;
}
```

**Notifier Class**: `GameNotifier`

The `GameNotifier` class contains all the business logic for the game.

#### Initialization Methods

##### `initializeGame(List<Player> players)`
Initializes the game with the provided players and sets up the initial state.

```dart
void initializeGame(List<Player> setupPlayers) {
  state = state.copyWith(
    players: setupPlayers,
    currentPlayerIndex: 0,
    phase: GamePhase.rollingForOrder,
    orderRolls: {},
    // Reset all game state
  );
}
```

**Usage**:
```dart
final gameNotifier = ref.read(gameProvider.notifier);
gameNotifier.initializeGame(players);
```

#### Turn Order Methods

##### `rollForTurnOrder()`
Rolls dice for the current player during turn order determination.

```dart
int rollForTurnOrder() {
  // Roll dice and store result
  // Move to next player or finalize order
  return roll;
}
```

**Returns**: The dice roll value for UI animation

**Usage**:
```dart
final gameNotifier = ref.read(gameProvider.notifier);
final roll = gameNotifier.rollForTurnOrder();
```

#### Game Loop Methods

##### `rollDice()`
Rolls dice for the current player and initiates movement.

```dart
void rollDice() async {
  // Check if action is allowed
  // Roll two dice
  // Check for doubles (3x = jail)
  // Move player
}
```

**Action Guards**:
- Cannot roll if already processing
- Cannot roll if dice already rolled
- Cannot roll if not in playing phase
- Cannot roll if any dialog is showing

**Usage**:
```dart
final gameNotifier = ref.read(gameProvider.notifier);
gameNotifier.rollDice();
```

##### `movePlayer(int steps)`
Moves the current player step-by-step with animations.

```dart
Future<void> _movePlayer(int steps) async {
  // Move player one tile at a time
  // Check for passing start
  // Trigger animations
  // Handle tile arrival
}
```

**Usage**:
```dart
// Called automatically by rollDice()
// Not typically called directly
```

#### Property Management Methods

##### `buyProperty()`
Purchases the current tile for the player.

```dart
void buyProperty() {
  // Check if player can afford property
  // Deduct money
  // Add to owned tiles
  // Update tile ownership
}
```

**Action Guards**:
- Player must have enough money
- Tile must be purchasable
- Tile must not already be owned

**Usage**:
```dart
final gameNotifier = ref.read(gameProvider.notifier);
gameNotifier.buyProperty();
```

##### `upgradeProperty()`
Upgrades the current tile (if owned by player).

```dart
void upgradeProperty() {
  // Check if player owns property
  // Calculate upgrade cost
  // Deduct money
  // Increase rent value
}
```

**Action Guards**:
- Player must own the property
- Player must have enough money for upgrade

**Usage**:
```dart
final gameNotifier = ref.read(gameProvider.notifier);
gameNotifier.upgradeProperty();
```

#### Card Methods

##### `drawCard()`
Draws a random card from the deck.

```dart
void drawCard() {
  // Select random card
  // Apply card effect
  // Show card dialog
}
```

**Usage**:
```dart
final gameNotifier = ref.read(gameProvider.notifier);
gameNotifier.drawCard();
```

##### `answerQuestion(int answerIndex)`
Handles player's answer to a question.

```dart
void answerQuestion(int answerIndex) {
  // Check if answer is correct
  // Apply reward/penalty
  // Close dialog
}
```

**Usage**:
```dart
final gameNotifier = ref.read(gameProvider.notifier);
gameNotifier.answerQuestion(0); // First option
```

#### Turn Management Methods

##### `endTurn()`
Ends the current player's turn and moves to the next player.

```dart
void endTurn() {
  // Check for double rolls (extra turn)
  // Move to next player
  // Reset dice state
  // Update last action
}
```

**Usage**:
```dart
final gameNotifier = ref.read(gameProvider.notifier);
gameNotifier.endTurn();
```

#### Dialog Management Methods

##### `closeDialog()`
Closes the currently open dialog.

```dart
void closeDialog() {
  // Reset all dialog flags
  // Clear dialog data
}
```

**Usage**:
```dart
final gameNotifier = ref.read(gameProvider.notifier);
gameNotifier.closeDialog();
```

##### `showPurchaseDialog()`
Shows the property purchase dialog.

```dart
void showPurchaseDialog() {
  state = state.copyWith(showPurchaseDialog: true);
}
```

**Usage**:
```dart
final gameNotifier = ref.read(gameProvider.notifier);
gameNotifier.showPurchaseDialog();
```

#### Utility Methods

##### `_addLog(String message, {String type = 'info'})`
Adds a log entry and plays appropriate sound effect.

```dart
void _addLog(String message, {String type = 'info'}) {
  // Add message to logs
  // Play sound based on type
  // Update last action
}
```

**Sound Types**:
- `'dice'` - Dice roll sound
- `'success'` - Success sound
- `'error'` - Error sound
- `'purchase'` - Purchase sound
- `'gameover'` - Game over sound
- `'turn'` - Turn change sound

**Usage**:
```dart
// Internal method, called by other methods
```

### themeProvider

Manages the application theme (light/dark mode).

**Location**: [`lib/providers/theme_notifier.dart`](../lib/providers/theme_notifier.dart)

**State Class**: `ThemeState`

```dart
class ThemeState {
  final bool isDarkMode;
  final ThemeTokens tokens;
  
  ThemeState({required this.isDarkMode, required this.tokens});
}
```

**Notifier Class**: `ThemeNotifier`

#### Methods

##### `toggleTheme()`
Toggles between light and dark mode.

```dart
void toggleTheme() {
  state = ThemeState(
    isDarkMode: !state.isDarkMode,
    tokens: ThemeTokens.forMode(!state.isDarkMode),
  );
}
```

**Usage**:
```dart
final themeNotifier = ref.read(themeProvider.notifier);
themeNotifier.toggleTheme();
```

##### `setMode(bool isDarkMode)`
Sets the theme mode explicitly.

```dart
void setMode(bool isDarkMode) {
  state = ThemeState(
    isDarkMode: isDarkMode,
    tokens: ThemeTokens.forMode(isDarkMode),
  );
}
```

**Usage**:
```dart
final themeNotifier = ref.read(themeProvider.notifier);
themeNotifier.setMode(true); // Dark mode
```

### Repository Providers

Provides repository instances to the application.

**Location**: [`lib/providers/repository_providers.dart`](../lib/providers/repository_providers.dart)

#### gameRepositoryProvider

```dart
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl(
    boardDataSource: BoardConfigDataSource(),
    cardDataSource: GameCardDataSource(),
    tileMapper: TileMapper(),
    cardMapper: CardMapper(),
  );
});
```

**Usage**:
```dart
final gameRepo = ref.read(gameRepositoryProvider);
final tiles = await gameRepo.getBoardTiles();
```

#### playerRepositoryProvider

```dart
final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepositoryImpl(
    mapper: PlayerMapper(),
  );
});
```

**Usage**:
```dart
final playerRepo = ref.read(playerRepositoryProvider);
await playerRepo.savePlayer(player);
```

#### questionRepositoryProvider

```dart
final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepositoryImpl(
    dataSource: QuestionsDataSource(),
    mapper: QuestionMapper(),
  );
});
```

**Usage**:
```dart
final questionRepo = ref.read(questionRepositoryProvider);
final questions = await questionRepo.getAllQuestions();
```

## Using Providers in Widgets

### Watching State

To watch state and rebuild when it changes:

```dart
class BoardView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final themeState = ref.watch(themeProvider);
    
    return Scaffold(
      body: Text('Current player: ${gameState.currentPlayer.name}'),
    );
  }
}
```

### Reading State

To read state without rebuilding:

```dart
class SomeWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        // Read state without rebuilding
        final gameState = ref.read(gameProvider);
        print('Current player: ${gameState.currentPlayer.name}');
      },
      child: Text('Print Player'),
    );
  }
}
```

### Calling Methods

To call methods on a notifier:

```dart
class RollDiceButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        // Call method on notifier
        ref.read(gameProvider.notifier).rollDice();
      },
      child: Text('Roll Dice'),
    );
  }
}
```

### Selective Listening

To listen to only part of the state:

```dart
class PlayerInfo extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuild when currentPlayer changes
    final currentPlayer = ref.watch(gameProvider.select((state) => state.currentPlayer));
    
    return Text('Player: ${currentPlayer.name}');
  }
}
```

## Quick Wins Implemented

### Action Guards

The `GameNotifier` implements action guards to prevent invalid state transitions:

```dart
void rollDice() async {
  // Guard: Cannot roll if already processing
  if (_isProcessing) return;
  
  // Guard: Cannot roll if dice already rolled
  if (state.isDiceRolled) return;
  
  // Guard: Cannot roll if not in playing phase
  if (state.phase != GamePhase.playing) return;
  
  // Guard: Cannot roll if any dialog is showing
  if (state.showQuestionDialog ||
      state.showPurchaseDialog ||
      state.showUpgradeDialog ||
      state.showCardDialog ||
      state.showRentDialog ||
      state.showLibraryPenaltyDialog) {
    return;
  }
  
  // Proceed with roll...
}
```

### Null Safety

All state properties are properly typed with null safety:

```dart
class GameState {
  // Required fields (non-nullable)
  final List<Player> players;
  final int currentPlayerIndex;
  final int diceTotal;
  
  // Optional fields (nullable)
  final BoardTile? currentTile;
  final Question? currentQuestion;
  final Player? winner;
  final String? setupMessage;
}
```

### Immutable State

State is immutable using `copyWith` pattern:

```dart
GameState copyWith({
  List<Player>? players,
  int? currentPlayerIndex,
  int? diceTotal,
  // ... other fields
}) {
  return GameState(
    players: players ?? this.players,
    currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
    diceTotal: diceTotal ?? this.diceTotal,
    // ... other fields
  );
}
```

## Game Phases

The game goes through several phases, managed by the `GamePhase` enum:

```dart
enum GamePhase {
  setup,           // Initial setup, waiting for players
  rollingForOrder, // Determining turn order
  playing,         // Main game loop
  gameOver,        // Game ended
}
```

### Phase Transitions

```
setup → rollingForOrder → playing → gameOver
```

### Phase-Specific Behavior

| Phase | Available Actions |
|-------|-------------------|
| `setup` | Add players, start game |
| `rollingForOrder` | Roll dice for turn order |
| `playing` | Roll dice, buy property, answer questions |
| `gameOver` | View results, restart game |

## Best Practices

### 1. Use `ref.read` for Method Calls

```dart
// ✅ Good
ref.read(gameProvider.notifier).rollDice();

// ❌ Bad
ref.watch(gameProvider.notifier).rollDice();
```

### 2. Use `ref.watch` for State

```dart
// ✅ Good
final gameState = ref.watch(gameProvider);

// ❌ Bad
final gameState = ref.read(gameProvider); // Won't rebuild
```

### 3. Use Selective Listening for Performance

```dart
// ✅ Good - Only rebuilds when currentPlayer changes
final currentPlayer = ref.watch(gameProvider.select((s) => s.currentPlayer));

// ❌ Bad - Rebuilds on any state change
final gameState = ref.watch(gameProvider);
final currentPlayer = gameState.currentPlayer;
```

### 4. Keep Notifiers Focused

Each notifier should have a single responsibility:

```dart
// ✅ Good - Separate notifiers for different concerns
final gameProvider = StateNotifierProvider<GameNotifier, GameState>(...);
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(...);

// ❌ Bad - One notifier for everything
final appProvider = StateNotifierProvider<AppNotifier, AppState>(...);
```

### 5. Use Action Guards

Prevent invalid state transitions:

```dart
void someAction() {
  // Always check preconditions
  if (state.phase != GamePhase.playing) return;
  if (_isProcessing) return;
  
  // Proceed with action
}
```

## Testing State Management

### Testing Notifiers

```dart
test('rollDice should update dice state', () {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);
  
  notifier.rollDice();
  
  final state = container.read(gameProvider);
  expect(state.isDiceRolled, true);
  expect(state.diceTotal, greaterThan(0));
});
```

### Testing Selective Listening

```dart
test('selective listener should only rebuild on selected value change', () {
  final container = ProviderContainer();
  var buildCount = 0;
  
  container.listen(
    gameProvider.select((s) => s.currentPlayer),
    (previous, next) {
      buildCount++;
    },
  );
  
  final notifier = container.read(gameProvider.notifier);
  
  // Change unrelated state
  notifier._addLog('Test log');
  expect(buildCount, 0); // Should not rebuild
  
  // Change selected state
  notifier.endTurn();
  expect(buildCount, 1); // Should rebuild
});
```

## Related Documentation

- [`../README.md`](../README.md) - Project overview
- [`ARCHITECTURE.md`](ARCHITECTURE.md) - Architecture documentation
- [`ANIMATION_GUIDELINES.md`](ANIMATION_GUIDELINES.md) - Animation standards
- [`COMPONENT_LIBRARY.md`](COMPONENT_LIBRARY.md) - UI component documentation
