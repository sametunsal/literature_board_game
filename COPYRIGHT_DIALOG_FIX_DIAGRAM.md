# Copyright Purchase Dialog Fix - Visual Flow Diagram

## Before Fix (BROKEN) ❌

```
Player lands on Book/Publisher Tile
         ↓
Question Dialog appears
         ↓
Player clicks CORRECT answer
         ↓
answerQuestionCorrect() called
         ├→ Sets phase to: copyrightPurchased
         └→ Returns
         ↓
playTurn() called IMMEDIATELY ⚠️
         ├→ Sees phase: copyrightPurchased
         └→ Does nothing for human players
         ↓
UI tries to rebuild to show CopyrightPurchaseDialog
         ↓
❌ BLACK SCREEN / Dialog never appears
         ↓
Game stuck (no further progression)
```

**Problem:** `playTurn()` was called before the UI had a chance to rebuild and show the dialog.

---

## After Fix (WORKING) ✅

```
Player lands on Book/Publisher Tile
         ↓
Question Dialog appears
         ↓
Player clicks CORRECT answer
         ↓
answerQuestionCorrect() called
         ├→ Sets phase to: copyrightPurchased
         └→ Returns
         ↓
_handleAnswer() checks phase
         ├→ Phase is: copyrightPurchased
         └→ Returns EARLY (doesn't call playTurn) ✅
         ↓
UI rebuilds
         ↓
✅ CopyrightPurchaseDialog appears
         ↓
Player clicks "Satın Al" or "Atla"
         ↓
Dialog handler calls:
  ├→ completeCopyrightPurchase() OR declineCopyrightPurchase()
  └→ Both set phase to: questionResolved
         ↓
Dialog handler calls playTurn() via addPostFrameCallback
         ├→ Sees phase: questionResolved
         └→ Calls endTurn()
         ↓
✅ Turn ends normally
```

**Solution:** Check the phase after answering, and only call `playTurn()` if NOT in `copyrightPurchased` phase.

---

## Wrong Answer Flow (Both Before and After) ✅

```
Player lands on Book/Publisher Tile
         ↓
Question Dialog appears
         ↓
Player clicks WRONG answer or "Atla"
         ↓
answerQuestionWrong() called
         ├→ Sets phase to: questionResolved
         └→ Returns
         ↓
_handleAnswer() checks phase
         ├→ Phase is: questionResolved
         └→ Calls playTurn() via addPostFrameCallback ✅
         ↓
playTurn() called
         ├→ Sees phase: questionResolved
         └→ Calls endTurn()
         ↓
✅ Turn ends immediately (no copyright dialog)
```

**Note:** Wrong answer flow was already working correctly, but now uses `addPostFrameCallback` for consistency.

---

## Key Code Changes

### Old Code (Broken)
```dart
void _handleAnswer(bool isCorrect) {
  if (!mounted) return;
  
  if (isCorrect) {
    ref.read(gameProvider.notifier).answerQuestionCorrect();
  } else {
    ref.read(gameProvider.notifier).answerQuestionWrong();
  }
  
  // ❌ PROBLEM: Always calls playTurn() immediately
  ref.read(gameProvider.notifier).playTurn();
}
```

### New Code (Fixed)
```dart
void _handleAnswer(bool isCorrect) {
  if (!mounted) return;
  
  final gameNotifier = ref.read(gameProvider.notifier);
  
  if (isCorrect) {
    gameNotifier.answerQuestionCorrect();
  } else {
    gameNotifier.answerQuestionWrong();
  }
  
  // ✅ FIX: Check phase and act accordingly
  final currentPhase = ref.read(turnPhaseProvider);
  
  if (currentPhase == TurnPhase.copyrightPurchased) {
    // Don't call playTurn() - let UI show dialog first
    return;
  }
  
  // For questionResolved phase, advance with proper timing
  WidgetsBinding.instance.addPostFrameCallback((_) {
    gameNotifier.playTurn();
  });
}
```

---

## Phase State Machine

```
TurnPhase.questionWaiting
    ↓ (correct answer)
TurnPhase.copyrightPurchased ← Fix prevents premature playTurn() here
    ↓ (user decision)
TurnPhase.questionResolved
    ↓ (playTurn called)
TurnPhase.turnEnded
```

vs.

```
TurnPhase.questionWaiting
    ↓ (wrong answer)
TurnPhase.questionResolved ← playTurn() called with addPostFrameCallback
    ↓
TurnPhase.turnEnded
```

---

## Pattern Source

This fix follows the same pattern as `CardDialog._applyCard()` which was previously fixed for a similar race condition:

```dart
// CardDialog pattern (from lib/widgets/card_dialog.dart)
void _applyCard() {
  final gameNotifier = ref.read(gameProvider.notifier);
  gameNotifier.applyCardEffect(widget.card);
  Navigator.of(context).pop();
  
  // Use addPostFrameCallback to ensure proper timing
  WidgetsBinding.instance.addPostFrameCallback((_) {
    gameNotifier.playTurn();
  });
}
```

Same principles applied to QuestionDialog fix:
1. Capture notifier reference early
2. Perform state-changing operation
3. Check resulting state
4. Use `addPostFrameCallback` for proper timing when calling `playTurn()`
