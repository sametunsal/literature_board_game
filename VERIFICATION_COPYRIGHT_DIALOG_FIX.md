# Copyright Purchase Dialog Fix - Verification Guide

## Issue Fixed
The Copyright Purchase Dialog was being skipped for human players after answering a question correctly on book/publisher tiles, showing a black screen instead.

## Root Cause
In `lib/widgets/question_dialog.dart`, the `_handleAnswer()` method was calling `playTurn()` immediately after `answerQuestionCorrect()`, causing a race condition where the dialog never got a chance to be displayed.

## Changes Made

### File: `lib/widgets/question_dialog.dart`

**Before:**
```dart
void _handleAnswer(bool isCorrect) {
  if (!mounted) return;

  if (isCorrect) {
    ref.read(gameProvider.notifier).answerQuestionCorrect();
  } else {
    ref.read(gameProvider.notifier).answerQuestionWrong();
  }

  // THIS WAS THE PROBLEM - playTurn() called immediately!
  ref.read(gameProvider.notifier).playTurn();
}
```

**After:**
```dart
void _handleAnswer(bool isCorrect) {
  if (!mounted) return;

  // Capture the notifier reference before any state changes
  final gameNotifier = ref.read(gameProvider.notifier);

  // Set answer state (this updates game state and phase)
  if (isCorrect) {
    gameNotifier.answerQuestionCorrect();
  } else {
    gameNotifier.answerQuestionWrong();
  }

  // Check the resulting phase to determine next action
  final currentPhase = ref.read(turnPhaseProvider);

  if (currentPhase == TurnPhase.copyrightPurchased) {
    // Don't call playTurn() - let UI show CopyrightPurchaseDialog first
    // The dialog will call playTurn() after user makes a decision
    return;
  }

  // For questionResolved phase (wrong answer), advance immediately
  WidgetsBinding.instance.addPostFrameCallback((_) {
    gameNotifier.playTurn();
  });
}
```

## Expected Behavior After Fix

### Scenario 1: Correct Answer on Unowned Book/Publisher Tile
1. Player lands on unowned book/publisher tile
2. Question dialog appears
3. Player clicks correct answer
4. ✅ **Copyright Purchase Dialog should appear** (not black screen!)
5. Player clicks "Satın Al" (Purchase) or "Atla" (Skip)
6. Turn continues normally

### Scenario 2: Wrong Answer
1. Player lands on book/publisher tile
2. Question dialog appears
3. Player clicks wrong answer or "Atla" (Skip)
4. ✅ **Turn ends immediately** (no copyright dialog)
5. Next player's turn begins

### Scenario 3: Bot Players
1. Bot lands on book/publisher tile
2. Bot auto-answers question (with delay)
3. If correct: Bot auto-declines copyright purchase (no dialog shown)
4. Turn continues automatically

## How to Test

### Prerequisites
```bash
flutter pub get
flutter run -d emulator-5554  # Or your Android emulator
```

### Test Steps

#### Test 1: Human Player Correct Answer
1. Start the game
2. Roll dice until you land on a book tile (blue) or publisher tile
3. Answer the question correctly
4. **VERIFY:** Copyright Purchase Dialog appears (not black screen)
5. Click "Satın Al" or "Atla"
6. **VERIFY:** Turn continues normally

#### Test 2: Human Player Wrong Answer
1. Start the game
2. Roll dice until you land on a book tile or publisher tile
3. Answer the question incorrectly or click "Atla"
4. **VERIFY:** No copyright dialog appears
5. **VERIFY:** Turn ends and next player starts

#### Test 3: Bot Player Behavior
1. Start the game
2. Wait for bot turn
3. Wait for bot to land on book/publisher tile
4. **VERIFY:** Bot auto-answers question
5. **VERIFY:** If correct, bot auto-declines (no dialog visible)
6. **VERIFY:** Turn continues automatically

### Terminal Logs to Watch

**Before Fix (BAD):**
```
🎮 Auto-advance directive: null, Phase: TurnPhase.questionWaiting
🎮 playTurn() called - Current phase: TurnPhase.copyrightPurchased
🎮 Auto-advance directive: null, Phase: TurnPhase.copyrightPurchased
🎮 playTurn() called - Current phase: TurnPhase.questionResolved  <- SKIPPED!
```

**After Fix (GOOD):**
```
🎮 Auto-advance directive: null, Phase: TurnPhase.questionWaiting
[User answers correctly]
[Phase changes to TurnPhase.copyrightPurchased]
[CopyrightPurchaseDialog appears]
[User clicks "Satın Al" or "Atla"]
🎮 playTurn() called - Current phase: TurnPhase.questionResolved
[Turn ends normally]
```

## Technical Details

### Phase Transition Flow
1. `TurnPhase.questionWaiting` → Player answers question
2. **Correct answer:** `answerQuestionCorrect()` → `TurnPhase.copyrightPurchased`
   - Fix: Don't call `playTurn()` here, wait for dialog
   - Dialog user interaction → `completeCopyrightPurchase()` or `declineCopyrightPurchase()`
   - Both methods set phase to `questionResolved`
   - Dialog then calls `playTurn()` → `endTurn()`
3. **Wrong answer:** `answerQuestionWrong()` → `TurnPhase.questionResolved`
   - Fix: Call `playTurn()` via postFrameCallback
   - `playTurn()` → `endTurn()`

### Pattern Used
This fix follows the same pattern as `CardDialog._applyCard()` method, which was previously fixed to handle the same race condition issue with card dialogs.

## Troubleshooting

### If dialog still doesn't appear:
1. Check that `answerQuestionCorrect()` is setting phase to `copyrightPurchased`
2. Check that the tile is actually a book or publisher tile
3. Verify the tile is not already owned by another player
4. Check terminal logs for phase transitions

### If game freezes:
1. Ensure `completeCopyrightPurchase()` and `declineCopyrightPurchase()` set phase correctly
2. Verify `playTurn()` is being called after dialog closes
3. Check for any exceptions in terminal

## Related Files
- `/lib/widgets/question_dialog.dart` - Fixed file
- `/lib/widgets/copyright_purchase_dialog.dart` - Dialog that should appear
- `/lib/providers/game_provider.dart` - Game state management
- `/lib/views/game_view.dart` - Shows dialogs based on phase
- `/lib/models/turn_phase.dart` - Phase definitions
