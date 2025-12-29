# Turn History Validator

A developer/debug tool for validating entire game history using the TurnReplayEngine.

## Overview

`TurnHistoryValidator` provides sequential validation of `TurnHistory` by replaying each turn and checking consistency. It validates that turn results match what actually happened during gameplay.

## Architecture

- **Pure Dart**: No Flutter, no Riverpod, no providers
- **Sequential validation**: Validates turns in order, stops on first failure
- **Uses TurnReplayEngine**: Leverages existing replay engine for turn validation
- **Non-invasive**: Does NOT modify gameplay logic

## Features

### ValidationReport

Provides detailed validation results:

```dart
class ValidationReport {
  final int totalValidated;  // Total turns checked
  final int passedCount;      // Turns that passed
  final int? failedIndex;     // Index of first failure
  final String? errorMessage;  // Error details
  final bool isAllValid;      // Overall status
}
```

### TurnHistoryValidator

Core validation methods:

#### validateTurn
Validates a single turn result:

```dart
final result = TurnHistoryValidator.validateTurn(turnResult, snapshot);
print(result.isValid);  // true/false
print(result.errorMessage); // null if valid
```

#### validateAll
Validates all turns in TurnHistory:

```dart
final report = TurnHistoryValidator.validateAll(turnHistory);
print(report.isAllValid);     // true if all passed
print(report.failedIndex);     // null if all passed
print(report.errorMessage);     // detailed error if failed
```

### Convenience Extensions

#### TurnHistory Extension

```dart
// One-line validation of entire history
final report = turnHistory.validate();
if (turnHistory.isValid) {
  print('All turns are valid!');
}
```

#### TurnResult Extension

```dart
// Validate individual turn
final result = turnResult.validate();
if (turnResult.isValid) {
  print('This turn is valid!');
}
```

## Usage Examples

### Basic Validation

```dart
import 'package:literature_board_game/engine/turn_history_validator.dart';
import 'package:literature_board_game/models/turn_history.dart';

// Get turn history from game state
final turnHistory = gameState.turnHistory;

// Validate entire history
final report = TurnHistoryValidator.validateAll(turnHistory);

if (report.isAllValid) {
  print('✅ All ${report.totalValidated} turns are valid');
} else {
  print('❌ Validation failed at turn ${report.failedIndex}');
  print('Error: ${report.errorMessage}');
}
```

### Quick Check

```dart
// Quick boolean check
if (turnHistory.isValid) {
  // History is valid, proceed
} else {
  // History has corruption, debug needed
}
```

### Detailed Error Reporting

```dart
final report = turnHistory.validate();

print(report.toString());
// Output:
// ValidationReport:
//   Total validated: 10
//   Passed: 8
//   Status: ❌ FAILED
//   Failed at index: 8
//   Error: Stars delta mismatch: Expected (claim): 50, Actual (replay): 100
```

### Turn-by-Turn Validation

```dart
// Validate turns individually
for (final turn in turnHistory.all) {
  final result = TurnHistoryValidator.validateTurn(turn);
  
  if (!result.isValid) {
    print('Turn at position ${turn.startPosition} failed:');
    print(result.errorMessage);
    break;
  }
}
```

## How It Works

### Validation Process

1. **Snapshot Reconstruction**: If no `TurnSnapshot` is provided, `TurnHistoryValidator` reconstructs it by:
   - Calculating end stars from transcript events
   - Reverse-calculating start stars using the delta
   - This allows validation without needing original game state

2. **Replay**: Uses `TurnReplayEngine.replayAndValidate()` to:
   - Reconstruct initial player state from snapshot
   - Replay all transcript events in order
   - Calculate expected final state

3. **Comparison**: Compares replayed state with `TurnResult`:
   - Position: Does end position match?
   - Stars: Does stars delta match?

4. **Report**: Returns detailed validation report

### Event Handling

The validator handles all event types from `TurnEventType`:

- `diceRoll`: No state change
- `move`: Updates position and adds START bonus
- `cardApplied`: Applies star changes
- `questionAnswered`: Applies star changes (correct/wrong only)
- `taxPaid`: Subtracts tax amount
- `starChange`: Applies generic star delta
- Others (`transition`, `tileResolved`, etc.): No state change

## Error Scenarios

### Position Mismatch

```dart
// Claimed: endPosition = 10
// Replayed: endPosition = 12
// Error: Position mismatch
```

### Stars Delta Mismatch

```dart
// Claimed: starsDelta = +50
// Replayed: starsDelta = +100
// Error: Stars delta mismatch
```

### Failed Event Application

```dart
// Event has missing or invalid data
// Error: Failed to apply event TYPE: [details]
```

## Best Practices

### 1. Use After Game State Changes

Validate turn history after significant gameplay changes:

```dart
void onGameStateChanged() {
  final report = turnHistory.validate();
  if (!report.isAllValid) {
    debugPrint('Game state corruption detected!');
    debugPrint(report.errorMessage);
  }
}
```

### 2. Debug Mode Only

This is a developer tool. Use conditionally:

```dart
void validateHistory() {
  if (kDebugMode) {
    final report = turnHistory.validate();
    debugPrint(report.toString());
  }
}
```

### 3. Early Detection

Validate history frequently to detect corruption early:

```dart
void onTurnEnd() {
  final report = turnHistory.validate();
  if (!report.isAllValid) {
    // Handle corruption immediately
    handleGameError(report);
  }
}
```

### 4. Logging

Log validation reports for debugging:

```dart
void validateAndLog() {
  final report = turnHistory.validate();
  developer.log(report.toString());
}
```

## Testing

Run the test suite:

```bash
flutter test test/turn_history_validator_test.dart
```

Test coverage includes:

- Valid turn validation
- Multiple turn validation
- First failure detection
- Empty history handling
- Extension methods
- Report formatting

## Integration with TurnReplayEngine

`TurnHistoryValidator` is built on top of `TurnReplayEngine`:

```
TurnHistoryValidator
    ↓ (for each turn)
TurnReplayEngine
    ↓ (with invariant checking)
ReplayValidationResult
    ↓
TurnHistoryValidator aggregates results
    ↓
ValidationReport
```

### Invariant Checking

`TurnReplayEngine` now includes invariant violation detection:

- **missingCardApplied**: cardDrawn event without corresponding cardApplied
- **bankruptcyWithStars**: bankruptcy event but player still has stars
- **missingTileFollowUp**: card tile resolved but no cardApplied event
- **tileEffectMismatch**: tileResolved indicates effect but none applied

These checks ensure transcript semantic consistency without implementing gameplay logic.

## Performance Considerations

- **O(n) complexity**: Validating n turns
- **Stops early**: Returns immediately on first failure
- **Minimal state**: Only reconstructs necessary data
- **Pure Dart**: No UI overhead

## Limitations

1. **Requires Complete Transcripts**: Turn transcripts must be complete and accurate
2. **No Side Effects**: Only validates, does not fix errors
3. **Developer Only**: Not intended for production gameplay
4. **Snapshot Dependency**: If original snapshot is lost, reconstruction may be inaccurate

## Future Enhancements

Potential improvements:

- [ ] Automatic error correction suggestions
- [ ] Validation with warnings (non-fatal issues)
- [ ] Performance profiling for large histories
- [ ] Integration with test frameworks
- [ ] Visual validation reports

## Related Files

- `lib/engine/turn_history_validator.dart` - Implementation
- `lib/engine/turn_replay_engine.dart` - Replay engine
- `lib/models/turn_result.dart` - Turn result model
- `lib/models/turn_history.dart` - History model
- `test/turn_history_validator_test.dart` - Test suite
