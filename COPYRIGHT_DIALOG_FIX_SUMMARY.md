# Copyright Purchase Dialog Fix - Summary

## Issue
After answering a question correctly on a book/publisher tile, the game showed a black screen instead of displaying the Copyright Purchase Dialog for human players.

## Root Cause
In `lib/widgets/question_dialog.dart`, the `_handleAnswer()` method was calling `playTurn()` immediately after `answerQuestionCorrect()`, causing a race condition:

```dart
// OLD CODE (BROKEN)
void _handleAnswer(bool isCorrect) {
  if (!mounted) return;
  
  if (isCorrect) {
    ref.read(gameProvider.notifier).answerQuestionCorrect();  // Sets phase to copyrightPurchased
  } else {
    ref.read(gameProvider.notifier).answerQuestionWrong();
  }
  
  ref.read(gameProvider.notifier).playTurn();  // Called immediately! Dialog never shown
}
```

**Problem:** When `answerQuestionCorrect()` set the phase to `copyrightPurchased`, `playTurn()` was called before the UI had a chance to rebuild and show the CopyrightPurchaseDialog.

## Solution
Modified `_handleAnswer()` to check the resulting phase after answering, and only call `playTurn()` if the phase is NOT `copyrightPurchased`:

```dart
// NEW CODE (FIXED)
void _handleAnswer(bool isCorrect) {
  if (!mounted) return;
  
  final gameNotifier = ref.read(gameProvider.notifier);
  
  if (isCorrect) {
    gameNotifier.answerQuestionCorrect();
  } else {
    gameNotifier.answerQuestionWrong();
  }
  
  // Check the resulting phase
  final currentPhase = ref.read(turnPhaseProvider);
  
  if (currentPhase == TurnPhase.copyrightPurchased) {
    // Don't call playTurn() - let UI show CopyrightPurchaseDialog first
    // Dialog will call playTurn() after user makes decision
    return;
  }
  
  // For questionResolved phase (wrong answer), advance immediately
  WidgetsBinding.instance.addPostFrameCallback((_) {
    gameNotifier.playTurn();
  });
}
```

## How It Works

### Correct Answer Flow (Human Player)
1. Player clicks correct answer
2. `answerQuestionCorrect()` sets phase to `copyrightPurchased` ✅
3. `_handleAnswer()` checks phase and returns early (doesn't call `playTurn()`) ✅
4. UI rebuilds and shows `CopyrightPurchaseDialog` ✅
5. Player clicks "Satın Al" or "Atla"
6. Dialog calls `completeCopyrightPurchase()` or `declineCopyrightPurchase()`
7. Dialog then calls `playTurn()` via `addPostFrameCallback`
8. Turn ends normally

### Wrong Answer Flow (Human Player)
1. Player clicks wrong answer or "Atla"
2. `answerQuestionWrong()` sets phase to `questionResolved`
3. `_handleAnswer()` checks phase and calls `playTurn()` via `addPostFrameCallback`
4. Turn ends immediately

### Bot Flow
Unchanged - bots already have separate handling in `game_provider._botAnswerQuestion()` which is called from `playTurn()`.

## Pattern Used
This fix follows the same pattern as the `CardDialog._applyCard()` method, which was previously fixed to handle a similar race condition.

## Files Changed
- `lib/widgets/question_dialog.dart` - Fixed `_handleAnswer()` method

## Verification
See `VERIFICATION_COPYRIGHT_DIALOG_FIX.md` for detailed test scenarios and expected behaviors.
