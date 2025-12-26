# Animated Token Movement - Test Verification Guide

## Test Environment

- **Device**: Pixel 9 (sdk gphone64 x86 64)
- **Device ID**: emulator-5554
- **OS**: Android 16 (API 36)
- **Status**: Online and Running
- **App Status**: Flutter app is running on emulator

---

## Test Objectives

Verify that animated player token movement works correctly using AnimatedPositioned when dice rolls occur.

---

## Test Scenarios

### Scenario 1: Initial Game State
**Objective**: Verify game starts with correct initial state

**Steps:**
1. Look at the emulator screen
2. Verify 4 player tokens are visible
3. All tokens should be on tile 1 (starting position)
4. Tokens should be properly colored:
   - Oyuncu 1: #FF5722 (Red)
   - Oyuncu 2: #2196F3 (Blue)
   - Oyuncu 3: #4CAF50 (Green)
   - Oyuncu 4: #FFEB3B (Yellow)

**Expected Result:**
```
✓ 4 tokens visible on tile 1
✓ Tokens are properly colored
✓ Tokens are centered on the tile
✓ Multiple tokens stack properly
```

---

### Scenario 2: Short Move Animation (1-3 tiles)
**Objective**: Verify smooth animation for short distances

**Steps:**
1. Tap the dice roll button (🎲 icon)
2. Wait for dice to stop and show result (1-3)
3. Watch the current player's token
4. Observe the animation

**Expected Result:**
```
Dice Roll: 2
Current Position: Tile 1 → Target Position: Tile 3
Animation Duration: 600ms
Animation Curve: EaseInOut

✓ Token moves smoothly in straight line
✓ Animation completes in ~600ms
✓ Token centers perfectly on target tile (Tile 3)
✓ Movement is not jerky or choppy
✓ Acceleration and deceleration is smooth (easeInOut)
```

**Visual Verification:**
- Token starts at Tile 1 position
- Token smoothly animates to Tile 3 position
- Animation takes about 0.6 seconds
- No flickering or jumping

---

### Scenario 3: Long Move Animation (10+ tiles)
**Objective**: Verify smooth animation for longer distances

**Steps:**
1. Tap the dice roll button
2. Wait for result (10-12)
3. Observe the token animation

**Expected Result:**
```
Dice Roll: 11
Current Position: Tile 3 → Target Position: Tile 14
Animation Duration: 600ms
Animation Curve: EaseInOut

✓ Token animates across multiple rows
✓ Animation speed is consistent (same 600ms)
✓ No performance issues or stuttering
✓ Token lands exactly on target tile
✓ Movement is predictable and controlled
```

**Visual Verification:**
- Token moves smoothly across the board
- No frame drops during long animations
- Movement feels natural and controlled
- Final position is accurate

---

### Scenario 4: Board Wrap-Around (40 → 1)
**Objective**: Verify animation works when wrapping around the board

**Steps:**
1. Navigate to tile 38-39
2. Tap dice roll button
3. Get result that causes wrap (e.g., roll 5 from tile 38 → tile 3)
4. Observe animation

**Expected Result:**
```
Dice Roll: 5
Current Position: Tile 38 → Target Position: Tile 3 (wrapped)
Animation Duration: 600ms
Animation Curve: EaseInOut

✓ Token moves correctly from tile 38 to tile 3
✓ Board wrap logic works correctly
✓ Animation is smooth despite wrap
✓ Target calculation is accurate
✓ No visual glitches during wrap
```

**Visual Verification:**
- Token moves from tile 38 position
- Smoothly transitions to tile 3 position
- No confusion about board wrapping

---

### Scenario 5: Multiple Players on Same Tile
**Objective**: Verify token stacking works correctly

**Steps:**
1. Roll dice and move multiple players to the same tile
2. Observe how tokens are displayed
3. Check if all tokens are visible

**Expected Result:**
```
Players on Tile 10:
- Oyuncu 1 (Red)
- Oyuncu 2 (Blue)
- Oyuncu 3 (Green)

✓ All 3 tokens are visible on tile 10
✓ Tokens stack using Stack widget
✓ Each token is visible (no hidden tokens)
✓ Stacking is offset so all tokens can be seen
✓ Colors are distinct and identifiable
```

**Visual Verification:**
- All tokens are centered on the same tile
- Slight offsets between stacked tokens
- All player colors are visible
- No token is completely hidden

---

### Scenario 6: Responsiveness Testing
**Objective**: Verify animation works on different screen orientations

**Steps:**
1. Roll dice and watch animation in portrait mode
2. Rotate emulator: Press `Ctrl+F11` or `Ctrl+F12`
3. Roll dice again and watch animation in landscape mode

**Expected Result:**
```
Portrait Mode:
✓ Animation is smooth
✓ Token alignment is correct
✓ No layout issues

Landscape Mode:
✓ Animation is smooth
✓ Token alignment is correct
✓ Layout adapts to new orientation
✓ No performance degradation
```

**Visual Verification:**
- Animation works equally well in both orientations
- Token positions are recalculated correctly
- Board layout adapts properly

---

### Scenario 7: Multiple Consecutive Rolls
**Objective**: Verify animation works consistently over multiple rolls

**Steps:**
1. Perform 5 consecutive dice rolls
2. Observe animation for each roll
3. Check for any degradation

**Expected Result:**
```
Roll #1: 4 → Tile 1 to Tile 5 ✓
Roll #2: 6 → Tile 5 to Tile 11 ✓
Roll #3: 2 → Tile 11 to Tile 13 ✓
Roll #4: 10 → Tile 13 to Tile 23 ✓
Roll #5: 3 → Tile 23 to Tile 26 ✓

✓ All 5 animations complete successfully
✓ Each animation is consistent
✓ No performance degradation over multiple rolls
✓ Game state updates correctly after each roll
✓ Turn phases change correctly
```

---

## Technical Specifications Verification

### Animation Configuration
Verify the animation matches the implementation:

```dart
AnimatedPositioned(
  duration: const Duration(milliseconds: 600),
  curve: Curves.easeInOut,
  // ... token widget
)
```

**Expected:**
- ✓ Duration: 600ms
- ✓ Curve: easeInOut (accelerates then decelerates)
- ✓ Smooth interpolation between positions

### Token Positioning
Verify offset calculations:

```dart
// Tile dimensions
const double tileWidth = 100;
const double tileHeight = 120;

// Token dimensions
const double tokenSize = 32;

// Offsets to center token on tile
final offsetX = tileWidth / 2 - tokenSize / 2;  // 34px
final offsetY = tileHeight / 2 - tokenSize / 2; // 44px
```

**Expected:**
- ✓ Token is horizontally centered on tile (34px offset)
- ✓ Token is vertically centered on tile (44px offset)
- ✓ Position is accurate regardless of tile location

### Game Mechanics Preservation
Verify all original features still work:

**Expected:**
- ✓ Tile highlighting works
- ✓ Tile colors are correct (special tiles)
- ✓ Player info panel shows correct data
- ✓ Game log updates correctly
- ✓ Stars/counters work properly
- ✓ Question dialogs work
- ✓ Card dialogs work

---

## Test Log Template

Use this template to record test results:

```
=== Animated Token Movement Test Log ===

Test Date: _____________
Device: Pixel 9 (emulator-5554)
OS: Android 16 (API 36)

Scenario 1: Initial State
[ ] Game starts correctly
[ ] 4 tokens visible on tile 1
[ ] Token colors correct
Notes: __________________

Scenario 2: Short Move (1-3 tiles)
Dice Roll: ___
From Tile: ___ → To Tile: ___
[ ] Animation smooth
[ ] Duration ~600ms
[ ] Token centered on target
Notes: __________________

Scenario 3: Long Move (10+ tiles)
Dice Roll: ___
From Tile: ___ → To Tile: ___
[ ] Animation smooth
[ ] No performance issues
[ ] Target accurate
Notes: __________________

Scenario 4: Board Wrap-Around
Dice Roll: ___
From Tile: ___ → To Tile: ___ (wrapped)
[ ] Wrap logic correct
[ ] Animation smooth
[ ] No visual glitches
Notes: __________________

Scenario 5: Multiple Players on Same Tile
[ ] All tokens visible
[ ] Stacking works correctly
[ ] Colors distinct
Notes: __________________

Scenario 6: Responsiveness
Portrait Mode:
[ ] Animation smooth
[ ] Alignment correct
Landscape Mode:
[ ] Animation smooth
[ ] Alignment correct
Notes: __________________

Scenario 7: Multiple Rolls
Roll #1: ✓
Roll #2: ✓
Roll #3: ✓
Roll #4: ✓
Roll #5: ✓
[ ] All animations successful
[ ] No degradation
Notes: __________________

Game Mechanics:
[ ] Tile highlighting works
[ ] Player info correct
[ ] Game log updates
[ ] Special tiles work
Notes: __________________

Overall Result:
[ ] All tests PASSED
[ ] Some tests FAILED
[ ] CRITICAL issues found

Additional Notes:
_________________________
_________________________
```

---

## Success Criteria

The animated token movement implementation is **SUCCESSFUL** if:

1. ✅ Tokens animate smoothly from current to target tile
2. ✅ Animation duration is 600ms consistently
3. ✅ Animation curve is easeInOut (smooth acceleration/deceleration)
4. ✅ Tokens are perfectly centered on target tiles
5. ✅ Works for short moves (1-3 tiles)
6. ✅ Works for long moves (10+ tiles)
7. ✅ Handles board wrap-around correctly
8. ✅ Multiple tokens stack properly
9. ✅ Responsive to screen orientation changes
10. ✅ All original game mechanics preserved

---

## Troubleshooting Common Issues

### Issue: Animation not showing
**Check:**
- Is `turnPhase` set to `TurnPhase.moving`?
- Are `oldPosition` and `newPosition` set correctly?
- Are GlobalKeys assigned to all tiles?

### Issue: Token misalignment
**Check:**
- Tile dimensions: 100x120px?
- Token size: 32px?
- Offset calculations: 34px (h) / 44px (v)?

### Issue: Choppy animation
**Check:**
- Device performance (use Profile mode)
- Other heavy processes running?
- Reduce animation duration to test

### Issue: Tokens overlapping completely
**Check:**
- Stack widget properly configured?
- Is Positioned widget used for stacking offset?
- Are token colors distinct?

---

## Hot Reload Testing

During testing, use Hot Reload to quickly iterate:

**To test different animation curves:**
1. Edit `lib/widgets/board_strip_widget.dart`
2. Change `curve: Curves.easeInOut` to other values:
   - `Curves.easeOut`
   - `Curves.bounceOut`
   - `Curves.elasticOut`
3. Press `r` in flutter run terminal
4. Test immediately

**To test different animation durations:**
1. Change `duration: const Duration(milliseconds: 600)` to:
   - `Duration(milliseconds: 300)` - Faster
   - `Duration(milliseconds: 1000)` - Slower
2. Press `r` for Hot Reload
3. Test immediately

---

## Conclusion

This test verification guide provides comprehensive scenarios to verify the animated token movement implementation. Execute all scenarios systematically and document results in the test log template.

The implementation uses **AnimatedPositioned** for smooth, performant token animations that:
- Maintain 60 FPS
- Run in 600ms consistently
- Use easeInOut curves for natural movement
- Center tokens perfectly on target tiles
- Preserve all game mechanics

**All tests should pass to confirm successful implementation!**
