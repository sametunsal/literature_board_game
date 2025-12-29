# Phase Transition Map Refactoring

## Overview

This document describes the introduction of an explicit Phase Transition Map to make all valid phase transitions visible, declarative, and testable - without changing any gameplay behavior.

## What Changed

### 1. New File: `lib/models/phase_transition.dart`

Created two new classes:

#### PhaseTransition
A simple data structure representing a single state machine transition:
- `from`: Source phase (where transition starts)
- `to`: Destination phase (where transition ends)
- `name`: Semantic name (e.g., "roll_dice", "show_question")
- `canExecute`: Guard function that validates if transition can execute in current state

#### PhaseTransitionMap
Central registry of all valid phase transitions:
- `transitions`: Complete list of all valid transitions
- `findTransition(from, state)`: Finds the first matching transition
- `getTransitionsFrom(from)`: Gets all possible transitions from a phase (for debugging)
- `canTransitionTo(from, to, state)`: Validates if a specific transition is valid
- `getTransitionName(from, to)`: Gets transition name for logging

### 2. Modified File: `lib/providers/game_provider.dart`

#### Added Import
```dart
import '../models/phase_transition.dart';
```

#### Refactored `playTurn()` Method

**Before:**
```dart
switch (state.turnPhase) {
  case TurnPhase.start:
    rollDice();
    break;
  case TurnPhase.diceRolled:
    moveCurrentPlayer(state.lastDiceRoll?.total ?? 0);
    break;
  // ... etc
}
```

**After:**
```dart
final transition = PhaseTransitionMap.findTransition(currentPhase, state);

if (transition == null) {
  debugPrint('⛔ No valid transition found from phase: $currentPhase');
  return;
}

debugPrint('🔄 Transition: ${transition.name} (${transition.from} → ${transition.to})');

switch (transition.to) {
  case TurnPhase.diceRolled:
    rollDice();
    break;
  case TurnPhase.moved:
    moveCurrentPlayer(state.lastDiceRoll!.total);
    break;
  // ... etc
}
```

## Key Design Decisions

### 1. Metadata-Only Transitions
The `PhaseTransition` class does NOT include an `execute` function. Instead:
- The transition map declares WHAT should happen next (from → to)
- `playTurn()` delegates HOW to existing GameNotifier methods
- This keeps the transition map declarative and avoids tight coupling

### 2. Ordered Transitions for Branching
Multiple transitions can exist from a single phase, evaluated in order:
```dart
// tileResolved → cardApplied (if chance/fate tile)
PhaseTransition(from: TurnPhase.tileResolved, to: TurnPhase.cardApplied, ...),

// tileResolved → questionResolved (if book/publisher tile)
PhaseTransition(from: TurnPhase.tileResolved, to: TurnPhase.questionResolved, ...),

// tileResolved → taxResolved (if tax tile)
PhaseTransition(from: TurnPhase.tileResolved, to: TurnPhase.taxResolved, ...),
```

The first transition whose guard evaluates to `true` wins. This allows `tileResolved` to branch based on tile type without complex switch logic.

### 3. No Gameplay Logic Changes
- All existing methods (`rollDice`, `moveCurrentPlayer`, `resolveCurrentTile`, etc.) remain unchanged
- The transition map only affects orchestration, not game rules
- UI timing (`getAutoAdvanceDirective`) remains unchanged
- Bot logic remains unchanged

## Complete Transition Map

```
start → diceRolled (roll_dice)
  Guard: state.canRoll

diceRolled → moved (move_player)
  Guard: state.lastDiceRoll != null

moved → tileResolved (resolve_tile)
  Guard: state.currentPlayer != null

tileResolved → cardApplied (draw_and_apply_card)
  Guard: tile is chance or fate

tileResolved → questionResolved (show_question)
  Guard: tile is book or publisher

tileResolved → taxResolved (handle_tax)
  Guard: tile is tax

tileResolved → turnEnded (resolve_corner_or_special)
  Guard: tile is corner or special

cardApplied → turnEnded (end_turn_after_card)
  Guard: state.currentPlayer != null

questionResolved → turnEnded (end_turn_after_question)
  Guard: state.currentPlayer != null

taxResolved → turnEnded (end_turn_after_tax)
  Guard: state.currentPlayer != null
```

## Benefits

### 1. Explicit State Machine
All valid transitions are visible in one place. No need to trace through multiple methods to understand the complete flow.

### 2. Better Debugging
Each transition is logged with a semantic name:
```
🔄 Transition: roll_dice (start → diceRolled)
🔄 Transition: show_question (tileResolved → questionResolved)
```

### 3. Testability
The transition map can be tested in isolation:
```dart
test('tileResolved branches to questionResolved for book tiles', () {
  final state = createTestState(tileType: TileType.book);
  final transition = PhaseTransitionMap.findTransition(
    TurnPhase.tileResolved, 
    state
  );
  expect(transition?.to, TurnPhase.questionResolved);
});
```

### 4. Validation
Invalid transitions are caught early:
```dart
if (transition == null) {
  debugPrint('⛔ No valid transition found from phase: $currentPhase');
  return;
}
```

### 5. Documentation
The transition map serves as living documentation of the complete state machine.

### 6. Visualization Ready
The declarative structure makes it easy to generate state machine diagrams or transition graphs.

## What Was NOT Changed

- ❌ Game rules (dice rolling, movement, card effects, etc.)
- ❌ UI timing (300ms delays, 700ms bot delay)
- ❌ Bot logic
- ❌ Phase behavior classification (_phaseBehavior map)
- ❌ Auto-advance directive (getAutoAdvanceDirective)
- ❌ Any existing GameNotifier methods
- ❌ UI code (game_view.dart)

## Future Improvements

Now that transitions are explicit, we can:

1. **Add transition validation**: Validate that all declared transitions are reachable
2. **Generate diagrams**: Auto-generate Mermaid/PlantUML state machine diagrams
3. **Add transition tests**: Unit tests for the transition map
4. **Add transition metrics**: Track how often each transition is executed
5. **Enable simulation**: Run full game simulations without UI
6. **Implement AI opponents**: Use transition map for AI decision-making

## Verification

To verify behavior is unchanged:

1. Run the game and play through several turns
2. Check debug logs for transition names:
   ```
   🎮 playTurn() called - Current phase: start, Player type: human
   🔄 Transition: roll_dice (start → diceRolled)
   🎲 rollDice() called
   🎲 Phase updated to: diceRolled
   ```
3. Verify all phase transitions work as before
4. Verify UI timing (300ms delays) still works
5. Verify bot auto-play (700ms delay on start phase) still works

## Conclusion

This refactoring introduces an explicit Phase Transition Map that makes the state machine visible, declarative, and testable - all without changing gameplay behavior. The transition map serves as the single source of truth for valid phase transitions, making the codebase easier to understand, debug, and extend.
