# Manual Verification Guide: Turn Summary Overlay Fix

## Purpose
This guide provides step-by-step instructions for manually verifying that the black screen issue after clicking "Atla" in the Copyright Purchase Dialog has been fixed.

## Prerequisites
- Android emulator (Pixel 9, API 36) running
- Flutter environment set up
- Repository cloned and dependencies installed

## Setup Steps

1. **Navigate to project directory**
   ```bash
   cd /path/to/literature_board_game
   ```

2. **Install dependencies** (if not already done)
   ```bash
   flutter pub get
   ```

3. **Start Android emulator**
   ```bash
   # Check available emulators
   flutter emulators
   
   # Start the Pixel 9 emulator (or your preferred emulator)
   flutter emulators --launch Pixel_9_API_36
   ```

4. **Run the app**
   ```bash
   flutter run -d emulator-5554
   ```
   
   Note: Replace `emulator-5554` with your emulator ID if different. You can find it by running `flutter devices`.

## Test Scenario: Copyright Purchase Dialog → Turn Summary

### Objective
Verify that clicking "Atla" (Skip) in the Copyright Purchase Dialog displays the Turn Summary Overlay instead of a black screen.

### Steps

1. **Start a new game**
   - Wait for the game to initialize
   - The game board should appear with 4 players (1 human + 3 bots)

2. **Play until landing on a book or publisher tile**
   - **Human player turn**: Click the dice button to roll
   - **Bot player turns**: Will automatically advance
   - Continue playing until the human player lands on:
     - A **book tile** (blue tiles with book icons), OR
     - A **publisher tile** (purple tiles with publisher icons)
   
   Note: If you want to speed this up, you can modify the dice roll to always land on a book tile for testing. However, for a genuine test, play normally.

3. **Answer the question correctly**
   - When you land on a book/publisher tile, a question dialog will appear
   - Read the question
   - Click the **correct answer** option
   - The question dialog should close
   - **Expected**: Copyright Purchase Dialog should appear

4. **Click "Atla" (Skip) button**
   - In the Copyright Purchase Dialog, you should see:
     - Tile information (name, type, price)
     - Your current stars
     - Two buttons: "Satın Al" (Purchase) and "Atla" (Skip)
   - Click the **"Atla"** button

5. **Verify Turn Summary Overlay appears**
   - ✅ **SUCCESS**: Turn Summary Overlay appears with:
     - Player name
     - Dice roll result
     - Position change (e.g., "5 -> 12")
     - Stars gained/lost
     - "DEVAM ET" button
   - ❌ **FAILURE**: Black screen appears instead of the overlay

6. **Continue the game**
   - Click the **"DEVAM ET"** button in the Turn Summary Overlay
   - **Expected**: Next player's turn should start normally

### Expected Results

| Step | Expected Behavior | Issue if Fails |
|------|-------------------|----------------|
| 4 | Copyright Purchase Dialog closes | Dialog doesn't close |
| 5 | Turn Summary Overlay appears | Black screen appears |
| 5 | Overlay shows correct player name | Wrong player or error |
| 5 | Overlay shows dice roll and movement | Missing or incorrect data |
| 6 | Next turn starts normally | Game stuck or crashes |

## Test Scenario: Copyright Purchase → Turn Summary

### Objective
Verify that purchasing a copyright also leads to the Turn Summary Overlay (not tested by the fix, but good to verify).

### Steps

1. Follow steps 1-3 from the previous scenario
2. In the Copyright Purchase Dialog, click **"Satın Al"** (Purchase) instead of "Atla"
   - You must have enough stars to purchase
3. Verify Turn Summary Overlay appears
4. Continue the game

## Test Scenario: Bot Player Copyright Decision

### Objective
Verify that bot players automatically handle copyright purchase and show Turn Summary Overlay.

### Steps

1. Start a new game
2. **Skip human turns** until a bot lands on a book/publisher tile
   - Human turns: Roll dice and move through normally
   - Wait for a bot to land on a book/publisher tile
3. Observe bot behavior:
   - Bot automatically answers question (usually incorrect, 30% correct rate)
   - If answer is correct, bot makes instant decision (purchase or skip)
   - No dialogs should appear for bots
   - Turn Summary Overlay should appear briefly (2 seconds for bots)
4. Verify the game continues to next turn automatically

## Test Scenario: Alternative Paths

### Tax Tile → Turn Summary
1. Land on a tax tile (corner tiles or special tiles)
2. Pay the tax or skip (if you have skip bonus)
3. Verify Turn Summary Overlay appears

### Card Tile → Turn Summary
1. Land on a Şans (Chance) or Kader (Fate) tile
2. Card dialog appears
3. Card effect is applied
4. Verify Turn Summary Overlay appears

### Corner Tile → Turn Summary
1. Land on a corner tile (START, LIBRARY WATCH, INSPIRATION CORNER, etc.)
2. Tile effect is applied
3. Verify Turn Summary Overlay appears

## Debugging: If Turn Summary Doesn't Appear

1. **Check terminal logs** for:
   ```
   🎬 Turn ended - waiting for startNextTurn()
   ```
   - If you see this log, `endTurn()` was called

2. **Check for phase transition**:
   ```
   🎮 Auto-advance directive: null, Phase: TurnPhase.turnEnded
   ```
   - If you see this, phase is correctly set to `turnEnded`

3. **Check for errors** in the terminal:
   - Look for exceptions or assertion failures
   - Look for "⛔ Phase Guard" messages

4. **Check if overlay is hidden**:
   - The overlay might be rendering behind other widgets
   - Try commenting out other overlays in `game_view.dart` to isolate the issue

5. **Check TurnResult data**:
   - Add debug prints in `TurnSummaryOverlay` to see what `turnResult` contains:
     ```dart
     print('TurnResult: playerIndex=${turnResult.playerIndex}, '
           'startPos=${turnResult.startPosition}, '
           'endPos=${turnResult.endPosition}');
     ```

## Verification Checklist

- [ ] Turn Summary Overlay appears after clicking "Atla" in Copyright Purchase Dialog
- [ ] Overlay shows correct player information
- [ ] Overlay shows correct dice roll and movement
- [ ] Overlay shows correct stars delta
- [ ] "DEVAM ET" button works and continues to next turn
- [ ] No black screens occur during the flow
- [ ] No errors or exceptions in terminal logs
- [ ] Bot players also show Turn Summary Overlay (briefly)
- [ ] Turn Summary appears for other tile types (tax, card, corner)

## Success Criteria

The fix is considered successful if:
1. ✅ No black screen appears after clicking "Atla" in Copyright Purchase Dialog
2. ✅ Turn Summary Overlay displays correctly with valid data
3. ✅ Game continues normally after clicking "DEVAM ET"
4. ✅ No errors or exceptions in terminal logs
5. ✅ Bot players also work correctly with Turn Summary

## Reporting Issues

If the verification fails, please report:
1. Exact steps to reproduce the issue
2. Terminal logs (copy relevant portion)
3. Screenshot of the black screen or error
4. Device/emulator information
5. Flutter version (`flutter --version`)

## Additional Notes

### Hot Reload vs Hot Restart
- After making code changes, use **Hot Restart** (press 'R') to see the changes
- Hot Reload (press 'r') may not work for state-related changes

### Emulator Performance
- If the emulator is slow, try:
  - Increasing allocated RAM in AVD settings
  - Using a device with hardware acceleration
  - Closing other applications

### Known Limitations
- The app requires landscape orientation
- Some animations may not work smoothly on slower emulators
- Bot AI is intentionally simple (70% incorrect answers)

## Related Documentation

- `FIX_TURN_SUMMARY_OVERLAY.md` - Comprehensive fix documentation
- `GAME_DESIGN_SPECIFICATION.md` - Game rules and design
- `HOT_RELOAD_RESTART_GUIDE.md` - When to use hot reload vs restart
- `ANDROID_EMULATOR_SETUP.md` - Emulator setup and troubleshooting
