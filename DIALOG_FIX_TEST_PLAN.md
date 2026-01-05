# Dialog Fix Testing Plan

## Overview
This document outlines the testing plan for the black screen fix that converted `QuestionDialog` and `CopyrightPurchaseDialog` from `AlertDialog` to `Center` + `Card` based overlay widgets.

## Changes Summary
- **QuestionDialog**: Converted from `AlertDialog` to `Center` + `Card`
- **CopyrightPurchaseDialog**: Converted from `AlertDialog` to `Center` + `Card`
- Both dialogs now work correctly when placed directly in a `Stack` widget

## Testing Instructions

### Prerequisites
1. Ensure Flutter is installed and updated
2. Run `flutter pub get` to install dependencies
3. Start the Android emulator (Pixel 9 recommended)

### Test 1: Question Dialog Display
**Objective**: Verify that the question dialog displays correctly without black screen

**Steps**:
1. Run the app: `flutter run -d emulator-5554`
2. Start a new game
3. Roll the dice to land on a question tile (tiles with book/publisher that require questions)
4. Observe the question dialog

**Expected Results**:
- ✅ Dialog appears in the center of the screen
- ✅ No black screen or rendering issues
- ✅ Dialog has rounded corners and elevation shadow
- ✅ Title bar shows "❓ Soru" with brown background
- ✅ Question content is visible and scrollable
- ✅ Category and difficulty badges are visible
- ✅ Timer countdown is working and visible
- ✅ Answer options (A, B, C, D) are clickable
- ✅ Skip button is visible at the bottom
- ✅ All colors and styling match the design

### Test 2: Question Dialog Interaction
**Objective**: Verify that question dialog interactions work correctly

**Steps**:
1. In the question dialog, select an answer option
2. Observe the behavior

**Expected Results**:
- ✅ Answer selection triggers game logic
- ✅ Dialog disappears after answer selection
- ✅ Game continues to next phase
- ✅ No navigation errors or exceptions

**Steps** (for skip):
1. In a question dialog, click the "Atla" (Skip) button
2. Observe the behavior

**Expected Results**:
- ✅ Skip triggers wrong answer logic
- ✅ Dialog disappears
- ✅ Game continues normally

### Test 3: Question Dialog Timer
**Objective**: Verify timer functionality

**Steps**:
1. Open a question dialog
2. Wait for the timer to reach 0 without answering

**Expected Results**:
- ✅ Timer counts down from 30 seconds
- ✅ Timer color changes (green → blue → orange → red)
- ✅ Timer icon changes based on remaining time
- ✅ Auto-fail when timer reaches 0
- ✅ Dialog closes and game continues

### Test 4: Copyright Purchase Dialog Display
**Objective**: Verify copyright purchase dialog displays correctly

**Steps**:
1. Answer a question correctly on a book or publisher tile
2. Observe the copyright purchase dialog

**Expected Results**:
- ✅ Dialog appears in the center of the screen
- ✅ No black screen or rendering issues
- ✅ Dialog has rounded corners and elevation shadow
- ✅ Title bar shows "© Telif Satın Al" with purple background
- ✅ Tile information (name, type) is visible
- ✅ Price is displayed with star icon
- ✅ Player's current stars are visible
- ✅ Purchase and Skip buttons are visible
- ✅ If insufficient funds, warning message appears
- ✅ Purchase button is disabled when funds are insufficient

### Test 5: Copyright Purchase Dialog Interaction
**Objective**: Verify purchase interactions work correctly

**Steps** (with sufficient funds):
1. In copyright purchase dialog with sufficient stars, click "Satın Al" (Purchase)
2. Observe the behavior

**Expected Results**:
- ✅ Purchase is processed
- ✅ Player's stars decrease by purchase price
- ✅ Player gains ownership of the tile
- ✅ Dialog disappears
- ✅ Game continues to next phase

**Steps** (skip purchase):
1. In copyright purchase dialog, click "Atla" (Skip)
2. Observe the behavior

**Expected Results**:
- ✅ Purchase is declined
- ✅ Player's stars remain unchanged
- ✅ Dialog disappears
- ✅ Game continues normally

### Test 6: Bot Player Handling
**Objective**: Verify bot players don't see dialogs

**Steps**:
1. Wait for a bot player's turn
2. Observe when bot lands on question or purchasable tile

**Expected Results**:
- ✅ No dialog is shown for bot players
- ✅ Bot automatically answers questions (incorrectly)
- ✅ Bot automatically declines purchases
- ✅ Game continues smoothly without UI interruption
- ✅ No rendering issues or black screens

### Test 7: Responsive Layout
**Objective**: Verify dialogs work in landscape orientation

**Steps**:
1. Ensure device is in landscape mode (should be default)
2. Trigger both question and copyright dialogs

**Expected Results**:
- ✅ Dialogs are centered and sized appropriately
- ✅ Max width constraint (600px for questions, 500px for copyright) is respected
- ✅ Content is scrollable if it exceeds viewport
- ✅ No overflow errors
- ✅ Dialogs don't block game board unnecessarily

### Test 8: Multiple Dialog Types
**Objective**: Verify different dialog types coexist properly

**Steps**:
1. Play through several turns triggering different dialogs:
   - Question dialog
   - Copyright purchase dialog
   - Card dialog (Şans/Kader)
   - Turn summary overlay

**Expected Results**:
- ✅ Each dialog type renders correctly
- ✅ No conflicts between different overlay types
- ✅ Transitions between dialogs are smooth
- ✅ No z-index or stacking issues

### Test 9: Hot Reload Compatibility
**Objective**: Verify changes work with hot reload

**Steps**:
1. Run the app
2. Open a question or copyright dialog
3. Make a minor UI change (e.g., change a color in the code)
4. Press 'r' for hot reload

**Expected Results**:
- ✅ Hot reload succeeds without errors
- ✅ Dialog updates with new changes
- ✅ No need for hot restart

### Test 10: Regression Testing
**Objective**: Verify no existing functionality was broken

**Steps**:
1. Play a complete game from start to finish
2. Test all major game features:
   - Dice rolling
   - Player movement
   - Question answering
   - Copyright purchasing
   - Card drawing
   - Turn summary
   - Game over screen

**Expected Results**:
- ✅ All game features work as before
- ✅ No new bugs introduced
- ✅ Game flows smoothly from start to end
- ✅ No console errors or exceptions

## Common Issues and Solutions

### Issue: Dialog appears but is not clickable
**Solution**: Check if there are overlapping widgets in the Stack

### Issue: Dialog content is cut off
**Solution**: Verify `maxWidth` constraints and scrollable areas

### Issue: Dialog doesn't disappear after action
**Solution**: Check game state transitions in `GameProvider`

### Issue: Styling looks different
**Solution**: Compare with original AlertDialog styling and adjust colors/padding

## Performance Checklist
- [ ] No frame drops when showing dialogs
- [ ] Smooth animations (if any)
- [ ] Quick response to button taps
- [ ] No memory leaks (monitor with Flutter DevTools)

## Accessibility Checklist
- [ ] Dialog content is readable
- [ ] Buttons have sufficient tap targets
- [ ] Colors have adequate contrast
- [ ] Text is not too small

## Sign-off
- [ ] All tests passed
- [ ] No regressions found
- [ ] Performance is acceptable
- [ ] Ready for production

## Notes
Record any observations or issues found during testing:

---
