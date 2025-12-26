# Hot Reload & Hot Restart Guide

## 📱 Current Status

✅ **Flutter App Running Successfully**
- **Device:** Pixel 9 (sdk gphone64 x86 64)
- **Device ID:** emulator-5554
- **OS:** Android 16 (API 36)
- **Status:** Online and running
- **Port:** http://127.0.0.1:64184
- **DevTools:** http://127.0.0.1:64184/I72EGc8aThs=/devtools/

---

## 🔄 Available Commands

### 1. Hot Reload (r)
**Purpose:** Apply code changes instantly without losing application state

**When to Use:**
- ✅ Changing UI colors, sizes, spacing
- ✅ Modifying widget layouts
- ✅ Updating animation parameters (duration, curve)
- ✅ Changing text content
- ✅ Adjusting styling and decorations

**What's Preserved:**
- App state (current player, scores, etc.)
- Game progress
- Animation controllers
- User data
- Navigation stack

**What's NOT Preserved:**
- Global variable changes
- New animation controllers (use Hot Restart)
- Major code structure changes

---

### 2. Hot Restart (R)
**Purpose:** Restart the application and reset all state

**When to Use:**
- ✅ Adding new animation controllers
- ✅ Modifying state management logic
- ✅ Changing initialization code
- ✅ Updating provider/state logic
- ✅ Making major refactoring changes
- ✅ After Hot Reload doesn't apply changes correctly

**What's Reset:**
- Complete app state (fresh start)
- All animation controllers (recreated)
- Provider state (reset to initial)
- Game progress (restarted)
- User navigation (back to start)

---

## 💻 How to Execute Commands

### Method 1: Direct Terminal Input (Recommended)

The Flutter app is currently running in the terminal. You can type commands directly.

**Step-by-Step:**
1. Click on the terminal showing `flutter run`
2. Type the command letter and press Enter
3. Watch the output for confirmation

**Example:**
```
r  [Press Enter]
```

**Terminal Output (Hot Reload):**
```
r
Performing hot reload...
Reloaded 0 of 500 libraries in 233ms.
```

**Terminal Output (Hot Restart):**
```
R
Restarting application...
Syncing files to device sdk gphone64 x86 64...
```

---

### Method 2: VS Code Terminal

**Step-by-Step:**
1. Open a new terminal in VS Code (`Ctrl+``)
2. Navigate to project directory (if needed)
3. Execute the desired command

**Command to send Hot Reload:**
```bash
# Option A: Using interactive input (if app running)
echo "r"

# Option B: Using flutter attach (alternative)
flutter attach --device-id emulator-5554
# Then type 'r' and press Enter
```

**Command to send Hot Restart:**
```bash
# Option A: Using interactive input (if app running)
echo "R"

# Option B: Using flutter attach (alternative)
flutter attach --device-id emulator-5554
# Then type 'R' and press Enter
```

---

### Method 3: VS Code Keyboard Shortcuts (Quickest)

**Hot Reload:**
- Windows/Linux: `Ctrl + Shift + R`
- macOS: `Cmd + Shift + R`

**Hot Restart:**
- Windows/Linux: `Ctrl + Shift + F5`
- macOS: `Cmd + Shift + F5`

**Note:** These shortcuts work when the Flutter app is the active window.

---

### Method 4: Command Line (Cline)

If using Cline, you can execute:

**For Hot Reload:**
```
Type: r (into the running Flutter terminal)
```

**For Hot Restart:**
```
Type: R (into the running Flutter terminal)
```

---

## 📋 All Available Flutter Run Commands

The Flutter app is running with the following interactive commands:

| Command | Action | Description |
|---------|---------|-------------|
| `r` | **Hot Reload** | Apply code changes without losing state |
| `R` | **Hot Restart** | Restart app and reset all state |
| `h` | **Help** | List all available interactive commands |
| `d` | **Detach** | Terminate "flutter run" but keep app running |
| `c` | **Clear** | Clear the terminal screen |
| `q` | **Quit** | Terminate application on device |
| `s` | **Save** | Save the current app state |
| `w` | **Widget Tree** | Show widget tree hierarchy |
| `t` | **Trace** | Toggle tracing |
| `p` | **Performance** | Show performance overlay |
| `L` | **Layout** | Show layout boundaries |
| `i` | **Inspector** | Show inspector for widget under cursor |

---

## 🎨 Practical Examples

### Example 1: Change Animation Duration

**Scenario:** Make dice roll animation faster

**Code Change:**
```dart
// lib/widgets/enhanced_dice_widget.dart
// Change line ~25:
duration: const Duration(milliseconds: 300), // Was 600
```

**Apply with Hot Reload:**
1. Save the file (`Ctrl+S`)
2. Type `r` in Flutter terminal and press Enter
3. Observe: Dice rolls faster on next roll

**Result:** ✅ Changes applied, game state preserved

---

### Example 2: Change Tile Colors

**Scenario:** Make ŞANS tiles gold instead of purple

**Code Change:**
```dart
// lib/widgets/enhanced_tile_widget.dart
// Change line ~127:
case TileType.chance:
  return Colors.amber.shade100; // Was Colors.purple.shade100
```

**Apply with Hot Reload:**
1. Save the file (`Ctrl+S`)
2. Type `r` in Flutter terminal and press Enter
3. Observe: ŞANS tiles immediately turn gold

**Result:** ✅ Changes applied, no game restart needed

---

### Example 3: Add New Animation Controller

**Scenario:** Add a new animation to player token

**Code Change:**
```dart
// lib/widgets/board_strip_widget.dart
class _BoardStripWidgetState extends State<BoardStripWidget>
    with TickerProviderStateMixin {
  
  // Add new controller
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    
    // Initialize new controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
```

**Apply with Hot Restart:**
1. Save the file (`Ctrl+S`)
2. Type `R` in Flutter terminal and press Enter
3. Observe: App restarts, new animation plays

**Result:** ✅ New controller initialized, app state reset

---

### Example 4: Modify Game Logic

**Scenario:** Change scoring rules

**Code Change:**
```dart
// lib/engine/game_engine.dart
void updateScore(int points) {
  // Change scoring logic
  _score += points * 2; // Was just += points
}
```

**Apply with Hot Restart:**
1. Save the file (`Ctrl+S`)
2. Type `R` in Flutter terminal and press Enter
3. Observe: App restarts with new rules

**Result:** ✅ New logic applied, game reset to initial state

---

## 🔍 Verifying Successful Execution

### Hot Reload Success Indicators

**Terminal Output:**
```
Performing hot reload...
Reloaded 0 of 500 libraries in 233ms.
```

**Visual Indicators:**
- ✅ UI updates immediately (if visible changes)
- ✅ Game state preserved (current player, scores, etc.)
- ✅ Animations continue (not interrupted)
- ✅ No app restart (no splash screen)

**App Behavior:**
- Game continues from exact state before reload
- Current turn is preserved
- All player positions maintained
- No data loss

---

### Hot Restart Success Indicators

**Terminal Output:**
```
Restarting application...
Syncing files to device sdk gphone64 x86 64...
Running Gradle task 'assembleDebug'...
√ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...
```

**Visual Indicators:**
- ✅ App restarts (brief splash screen)
- ✅ Fresh app state (game reset to start)
- ✅ All animations reinitialized
- ✅ New code structure applied

**App Behavior:**
- Game starts from beginning
- All scores reset to zero
- All players back at starting position
- Clean slate for testing

---

## ⚡ Quick Workflow

### Development Workflow (Recommended)

**For UI/Visual Changes:**
```
1. Make code change
2. Save file (Ctrl+S)
3. Type 'r' and Enter (Hot Reload)
4. Test on emulator
5. Repeat as needed
```

**For Logic/State Changes:**
```
1. Make code change
2. Save file (Ctrl+S)
3. Type 'R' and Enter (Hot Restart)
4. Test from fresh start
5. Repeat as needed
```

**For Testing Multiple Scenarios:**
```
1. Make code change
2. Hot Reload ('r')
3. Test current state
4. Hot Restart ('R')
5. Test from fresh start
6. Compare results
```

---

## 🚨 Common Issues & Solutions

### Issue 1: Hot Reload Not Applying Changes

**Symptoms:**
- Code changes don't appear in app
- Terminal shows "No changes detected"

**Solutions:**
1. Ensure file is saved (`Ctrl+S`)
2. Check if changes are in Flutter-compatible code
3. Try Hot Restart ('R') instead
4. Check for syntax errors in terminal output

---

### Issue 2: Hot Reload Causing Errors

**Symptoms:**
- App crashes after Hot Reload
- Error messages in terminal
- Red error screen on emulator

**Solutions:**
1. Use Hot Restart ('R') instead
2. Check for incompatible state changes
3. Review error messages in terminal
4. Fix errors and Hot Restart again

---

### Issue 3: Hot Restart Taking Too Long

**Symptoms:**
- App taking >30 seconds to restart
- Gradle build hangs

**Solutions:**
1. Wait for build to complete (may take 1-2 minutes on first run)
2. Check emulator performance
3. Close other heavy applications
4. Consider using Hot Reload for minor changes

---

### Issue 4: "Skipped Frames" Warning

**Symptoms:**
- Terminal shows "Skipped 290 frames!"
- App feels sluggish

**Solutions:**
1. Reduce animation complexity
2. Decrease animation duration
3. Use Release mode (`flutter run --release`)
4. Profile with DevTools to find bottlenecks

**Note:** This is common during development and not critical.

---

## 📊 Performance Monitoring

### Using DevTools

**Access DevTools:**
```
URL: http://127.0.0.1:64184/I72EGc8aThs=/devtools/
```

**Features:**
- **Flutter Inspector:** View and debug widget tree
- **Performance:** Analyze app performance
- **Memory:** Check memory usage and leaks
- **Network:** Monitor network requests
- **Logging:** View app logs

### Performance Overlay

**Enable Performance Overlay:**
```
Type 'p' in Flutter terminal and press Enter
```

**What It Shows:**
- FPS (Frames Per Second)
- GPU rasterization time
- UI thread build time
- Frame timing graph

**Disable:**
```
Type 'p' again to toggle off
```

---

## 🎯 Testing Enhanced Features

### Test Plan with Hot Reload

**1. Test Player Info Panel:**
```
Change: Star icon color (e.g., Colors.red)
Action: Save, Hot Reload ('r')
Verify: Star icon changes color immediately
```

**2. Test Dice Widget:**
```
Change: Roll duration to 300ms
Action: Save, Hot Reload ('r')
Verify: Dice rolls faster on next roll
```

**3. Test Tile Effects:**
```
Change: ŞANS tile to gold (Colors.amber)
Action: Save, Hot Reload ('r')
Verify: All ŞANS tiles turn gold immediately
```

**4. Test Combined Features:**
```
Change: Multiple animation parameters
Action: Save, Hot Reload ('r')
Verify: All changes applied simultaneously
```

---

## 📱 Testing on Running Emulator

### Current Emulator Status
- **Device:** Pixel 9 (sdk gphone64 x86 64)
- **ID:** emulator-5554
- **OS:** Android 16 (API 36)
- **Status:** ✅ Running
- **Flutter App:** ✅ Launched and active

### Quick Verification Steps

**1. Verify App is Running:**
```bash
flutter devices
```
Expected output shows emulator-5554 as "online"

**2. Apply Hot Reload:**
```
Type: r [Enter]
```
Expected: "Reloaded X of Y libraries in Zms."

**3. Apply Hot Restart:**
```
Type: R [Enter]
```
Expected: "Restarting application..."

---

## 🛠️ Advanced Usage

### Batch File for Quick Hot Reload (Windows)

Create `hotreload.bat`:
```batch
@echo off
echo r | flutter attach -d emulator-5554
```

**Usage:**
```
hotreload.bat
```

### Shell Script for Quick Hot Reload (macOS/Linux)

Create `hotreload.sh`:
```bash
#!/bin/bash
echo "r" | flutter attach -d emulator-5554
```

**Usage:**
```bash
chmod +x hotreload.sh
./hotreload.sh
```

### VS Code Settings

**Auto-save on focus lost:**
```json
{
  "files.autoSave": "onFocusChange"
}
```

This ensures files are always saved before Hot Reload.

---

## 📚 Command Reference

### Summary of Commands

| Command | Key | Action | Use For |
|---------|-----|---------|----------|
| Hot Reload | `r` | Apply changes without state loss | UI, styling, parameters |
| Hot Restart | `R` | Reset app state | Logic, structure, controllers |
| Help | `h` | Show all commands | Reference |
| Detach | `d` | Keep app, stop flutter | Running app independently |
| Clear | `c` | Clear terminal | Clean view |
| Quit | `q` | Stop app and flutter | End session |
| Save | `s` | Save app state | Debugging |
| Widget Tree | `w` | Show hierarchy | Debugging layout |
| Trace | `t` | Toggle tracing | Performance |
| Performance | `p` | Show overlay | FPS monitoring |
| Layout | `L` | Show boundaries | Debugging layout |
| Inspector | `i` | Inspect widget | Debugging UI |

---

## ✅ Success Checklist

After Hot Reload:
- [ ] Terminal shows "Reloaded X of Y libraries"
- [ ] UI changes visible (if applicable)
- [ ] Game state preserved (player positions, scores)
- [ ] No errors in terminal
- [ ] App continues smoothly

After Hot Restart:
- [ ] Terminal shows "Restarting application"
- [ ] App restarts (brief splash screen)
- [ ] Game starts from beginning (fresh state)
- [ ] All new code applied
- [ ] No errors in terminal

---

## 🎓 Best Practices

### DO:
- ✅ Use Hot Reload for visual/UI changes
- ✅ Use Hot Restart for logic/state changes
- ✅ Always save files before Hot Reload
- ✅ Read terminal output for errors
- ✅ Test both Hot Reload and Hot Restart
- ✅ Use DevTools for debugging

### DON'T:
- ❌ Don't use Hot Reload for new controllers
- ❌ Don't expect Hot Reload to fix bugs
- ❌ Don't ignore terminal error messages
- ❌ Don't forget to save files
- ❌ Don't use Hot Reload for major refactors
- ❌ Don't skip testing after changes

---

## 🔗 Related Resources

- **Flutter Hot Reload Documentation:** https://docs.flutter.dev/tools/hot-reload
- **Flutter DevTools:** https://docs.flutter.dev/tools/devtools/overview
- **Flutter Performance:** https://docs.flutter.dev/perf

---

## 📝 Quick Reference

```
Hot Reload:  r     [Instant UI updates, state preserved]
Hot Restart: R     [Full app restart, state reset]
Help:        h     [Show all commands]
Quit:        q     [Exit flutter run]

Current Device: emulator-5554 (Pixel 9)
App Status:    ✅ Running
Port:          http://127.0.0.1:64184
DevTools:      http://127.0.0.1:64184/.../devtools/
```

---

## 🎉 Ready to Use

The Flutter app is running on Pixel 9 emulator with full Hot Reload and Hot Restart support!

**Quick Start:**
1. Make a code change
2. Save the file
3. Type `r` for Hot Reload OR `R` for Hot Restart
4. Test on emulator
5. Repeat!

**All enhanced features are ready for testing with instant feedback!**
