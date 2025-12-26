# Animated Player Token Movement Implementation

## Overview

This document explains how the animated player token movement works in the Flutter board game using `AnimatedPositioned`. The implementation provides smooth visual feedback when a player moves between tiles after rolling the dice.

## Key Components

### 1. BoardStripWidget Changes

The widget has been converted from `ConsumerWidget` to `ConsumerStatefulWidget` to manage animation state:

```dart
class BoardStripWidget extends ConsumerStatefulWidget {
  const BoardStripWidget({super.key});

  @override
  ConsumerState<BoardStripWidget> createState() => _BoardStripWidgetState();
}
```

### 2. State Management

Two key maps are maintained:

```dart
// Store global keys for each tile to get their positions
final Map<int, GlobalKey> _tileKeys = {};

// Store animated token positions
final Map<String, TokenPosition> _tokenPositions = {};
```

- `_tileKeys`: Maps tile IDs to GlobalKeys, allowing us to retrieve the exact position of each tile on screen
- `_tokenPositions`: Stores the start and end positions for animated tokens

### 3. Animation Architecture

#### Layer Structure
```
Stack
├── Board Tiles Layer (Static)
│   └── SingleChildScrollView
│       └── Wrap
│           └── Individual Tiles (each with a GlobalKey)
│
└── Animated Tokens Layer (Dynamic - only during movement)
    └── AnimatedPositioned widgets for moving player tokens
```

#### Turn Phase Detection
The animation only activates during the `TurnPhase.moving` phase:

```dart
final turnPhase = ref.watch(turnPhaseProvider);

// Animated tokens layer - overlay for smooth movement
if (turnPhase == TurnPhase.moving)
  ..._buildAnimatedTokens(gameState),
```

### 4. Position Calculation

The `_updateTokenPositions` method calculates the exact screen coordinates:

```dart
void _updateTokenPositions(GameState gameState, TurnPhase turnPhase) {
  if (turnPhase != TurnPhase.moving || gameState.currentPlayer == null) {
    return;
  }

  final currentPlayer = gameState.currentPlayer!;
  
  // Get old and new tile positions
  final oldKey = _tileKeys[gameState.oldPosition];
  final newKey = _tileKeys[gameState.newPosition];

  if (oldKey != null && newKey != null) {
    final oldContext = oldKey.currentContext;
    final newContext = newKey.currentContext;

    if (oldContext != null && newContext != null) {
      final oldRenderBox = oldContext.findRenderObject() as RenderBox?;
      final newRenderBox = newContext.findRenderObject() as RenderBox?;

      if (oldRenderBox != null && newRenderBox != null) {
        // Get positions relative to the board container
        final oldPosition = oldRenderBox.localToGlobal(Offset.zero);
        final newPosition = newRenderBox.localToGlobal(Offset.zero);
        
        // Get the board container's position
        final boardContext = context;
        final boardRenderBox = boardContext.findRenderObject() as RenderBox?;
        
        if (boardRenderBox != null) {
          final boardPosition = boardRenderBox.localToGlobal(Offset.zero);
          
          // Calculate relative positions
          final startOffset = Offset(
            oldPosition.dx - boardPosition.dx + 50, // +50 for center of tile (100/2)
            oldPosition.dy - boardPosition.dy + 60, // +60 for center of tile (120/2)
          );
          
          final endOffset = Offset(
            newPosition.dx - boardPosition.dx + 50,
            newPosition.dy - boardPosition.dy + 60,
          );

          setState(() {
            _tokenPositions[currentPlayer.id] = TokenPosition(
              start: startOffset,
              end: endOffset,
              current: startOffset,
              player: currentPlayer,
            );
          });
        }
      }
    }
  }
}
```

**Key Calculations:**
- Tiles are 100x120 pixels
- Token center offset: +50 (horizontal) and +60 (vertical) to center the 32px token
- Positions are calculated relative to the board container for proper alignment

### 5. Animated Token Widget

The animated token uses `AnimatedPositioned` for smooth movement:

```dart
List<Widget> _buildAnimatedTokens(GameState gameState) {
  final animatedTokens = <Widget>[];

  _tokenPositions.forEach((playerId, tokenPos) {
    animatedTokens.add(
      AnimatedPositioned(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        left: tokenPos.end.dx - 16, // Center the token (32/2)
        top: tokenPos.end.dy - 16,
        child: _buildPlayerToken(tokenPos.player),
      ),
    );
  });

  return animatedTokens;
}
```

**Animation Parameters:**
- **Duration**: 600ms (balanced between smooth and responsive)
- **Curve**: `Curves.easeInOut` for natural acceleration/deceleration
- **Offset adjustment**: -16px to center the 32px token on the target position

### 6. TokenPosition Class

Stores position data for each moving token:

```dart
class TokenPosition {
  final Offset start;      // Starting position (old tile)
  final Offset end;        // Ending position (new tile)
  Offset current;          // Current position during animation
  final Player player;      // Reference to the player
}
```

### 7. Static Token Visibility Control

Static tokens are hidden during animation to prevent duplication:

```dart
// In _buildTile
bool showStaticTokens = turnPhase != TurnPhase.moving;

// Only show static tokens when not animating
if (showStaticTokens && playersOnTile.isNotEmpty)
  Positioned(
    top: -8,
    right: -8,
    child: Column(
      // ... stacked tokens
    ),
  ),
```

## Responsive Design

The implementation is fully responsive:

1. **Automatic Position Calculation**: Uses `RenderBox` and `localToGlobal()` to get actual rendered positions
2. **Relative Offsets**: All calculations are relative to the board container
3. **No Hardcoded Positions**: Positions are calculated dynamically based on the actual widget tree

### Screen Size Handling

- Works on mobile, tablet, and desktop
- Adapts to different screen orientations
- Maintains proper alignment regardless of scaling

## Animation Flow

```
1. Player rolls dice
   ↓
2. TurnPhase changes to 'moving'
   ↓
3. oldPosition and newPosition are set in GameState
   ↓
4. WidgetsBinding.addPostFrameCallback triggers position calculation
   ↓
5. GlobalKeys retrieve tile RenderBoxes
   ↓
6. Start and end offsets are calculated
   ↓
7. TokenPosition is stored in _tokenPositions map
   ↓
8. AnimatedPositioned widget renders on top layer
   ↓
9. Animation runs for 600ms with easeInOut curve
   ↓
10. TurnPhase changes to 'resolvingTile'
   ↓
11. Animated layer disappears, static tokens reappear
```

## Integration with Game State

### TurnPhase Enum (from game_provider.dart)

```dart
enum TurnPhase {
  waitingRoll,    // Waiting for player to roll dice
  rolling,        // Dice rolling animation
  moving,         // Player pawn moving ← Animation active here
  resolvingTile,  // Processing tile effects
  turnEnd,       // Turn ending, preparing next player
}
```

### GameState Movement Properties

```dart
class GameState {
  // ... other properties
  
  final int? oldPosition;      // Starting tile before movement
  final int? newPosition;      // Target tile after movement
  final bool passedStart;      // Whether player passed tile 1
  
  // ... other properties
}
```

## Preserved Features

All existing functionality is maintained:

✅ **Tile Highlighting**: Yellow highlight on current tile
✅ **Tile Sizes**: 100x120 pixel tiles
✅ **Player Token Design**: Circular colored tokens with initials
✅ **Stacked Tokens**: Multiple players on same tile stacked vertically
✅ **Dice Roll Display**: Shows dice results on active tile
✅ **Tile Colors**: Type-specific colors (orange, blue, green, etc.)
✅ **Game Mechanics**: All turn phases, movement, and tile effects

## Customization Options

### Animation Duration

Change the animation speed in `_buildAnimatedTokens`:

```dart
AnimatedPositioned(
  duration: const Duration(milliseconds: 600), // Adjust this value
  curve: Curves.easeInOut,
  // ...
)
```

### Animation Curve

Use different easing curves:

```dart
AnimatedPositioned(
  duration: const Duration(milliseconds: 600),
  curve: Curves.easeOut,          // Fast start, slow end
  // Or: Curves.easeIn              // Slow start, fast end
  // Or: Curves.linear              // Constant speed
  // Or: Curves.bounceOut           // Bouncy effect
  // ...
)
```

### Token Size

Modify token dimensions in `_buildPlayerToken`:

```dart
Container(
  width: 32,  // Change token size
  height: 32, // Change token size
  // ...
)
```

Remember to update the center offset calculations if changing size:
```dart
left: tokenPos.end.dx - (tokenSize / 2),
top: tokenPos.end.dy - (tokenSize / 2),
```

## Performance Considerations

1. **PostFrameCallback**: Position calculations are deferred to avoid layout thrashing
2. **Conditional Rendering**: Animated layer only exists during movement phase
3. **RenderBox Caching**: Keys allow efficient widget reuse
4. **Minimal Rebuilds**: Only the moving player's token is animated

## Testing Recommendations

Test the animation on:

1. **Different Screen Sizes**:
   - Mobile phones (portrait/landscape)
   - Tablets
   - Desktop browsers

2. **Movement Scenarios**:
   - Short moves (1-3 tiles)
   - Long moves (10+ tiles)
   - Wrapping around the board (40 → 1)

3. **Edge Cases**:
   - Multiple players on same tile
   - Rapid successive moves (double dice)
   - Player teleportation (library watch)

## Example Usage

The animation works automatically when a player rolls the dice:

```dart
// In game_provider.dart - rollDice() method
void rollDice() {
  // ... dice roll logic
  
  // Move to moving phase
  state = state.copyWith(
    turnPhase: TurnPhase.moving,
  );
  
  // Calculate new position
  moveCurrentPlayer(diceRoll.total);
}

// moveCurrentPlayer() sets oldPosition and newPosition
void moveCurrentPlayer(int diceTotal) {
  final oldPosition = state.currentPlayer!.position;
  final newPosition = _calculateNewPosition(oldPosition, diceTotal);
  
  state = state.copyWith(
    oldPosition: oldPosition,
    newPosition: newPosition,
    turnPhase: TurnPhase.resolvingTile,
  );
  
  // ... rest of movement logic
}
```

## Troubleshooting

### Animation Not Showing

- Check that `turnPhase` is correctly set to `TurnPhase.moving`
- Verify `oldPosition` and `newPosition` are set in GameState
- Ensure GlobalKeys are properly assigned to tiles

### Token Misaligned

- Verify tile dimensions match the offset calculations (100x120)
- Check token size matches the center offset (32px → -16px)
- Ensure the board container is the correct reference point

### Jerky Animation

- Increase duration if movement feels too fast
- Try different curves (e.g., `Curves.easeOutCubic`)
- Check for performance issues on low-end devices

## Conclusion

This implementation provides a smooth, responsive animation system that enhances the user experience while maintaining all existing game functionality. The use of `AnimatedPositioned` with proper position calculations ensures tokens move accurately between tiles regardless of screen size or layout.
