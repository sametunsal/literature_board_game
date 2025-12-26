# Android Emulator Setup for Flutter in VS Code

## Current Status

✅ Flutter installed (v3.38.5)
✅ Android SDK installed (version 36.1.0)
✅ Android Studio installed
✅ AVD Manager installed (v36.3.10.0)
✅ Pixel 9 emulator created
⚠️ Emulator currently showing as offline

## Quick Start Commands

### 1. Check Available Emulators
```bash
flutter emulators
```

**Current Output:**
```
Id      • Name    • Manufacturer • Platform
Pixel_9 • Pixel 9 • Google       • android
```

### 2. Launch Emulator
```bash
flutter emulators --launch Pixel_9
```

### 3. Check Connected Devices
```bash
flutter devices
```

**Expected Output (when emulator is online):**
```
Found 4 connected devices:
  Windows (desktop) • windows • windows-x64
  Chrome (web)      • chrome  • web-javascript
  Edge (web)        • edge    • web-javascript
  Android (emulator)• emulator-5554 • android • Android 14 (API 34)
```

### 4. Run App on Emulator
```bash
flutter run -d emulator-5554
```

Or specify by ID:
```bash
flutter run -d Pixel_9
```

---

## Troubleshooting Emulator Issues

### Issue: Emulator Shows as Offline

**Solution 1: Restart ADB Server**
```bash
adb kill-server
adb start-server
```

**Solution 2: Check if Emulator Window is Open**
The emulator should be running in a separate window. If not, launch it:
```bash
flutter emulators --launch Pixel_9
```

**Solution 3: Launch Emulator via Android Studio**
1. Open Android Studio
2. Go to: Tools → Device Manager
3. Select Pixel_9
4. Click the Play button to launch
5. Wait for it to fully boot (may take 1-2 minutes)

**Solution 4: Cold Boot Emulator**
```bash
# Kill the emulator
flutter emulators --launch Pixel_9 --cold-boot
```

**Solution 5: Check Emulator Status**
```bash
# List running emulators
flutter emulators --launch --verbose
```

---

## Complete VS Code + Flutter + Emulator Setup

### Step 1: Verify VS Code Extensions

1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Install these essential extensions:

**Required Extensions:**
- **Flutter** (by Dart Code)
  - Version: 3.x or higher
  - Provides Flutter/Dart support
  
- **Dart** (by Dart Code)
  - Version: 3.x or higher
  - Provides Dart language support

**Recommended Extensions:**
- **Flutter Widget Snippets** (by NirmalShah)
- **Awesome Flutter Snippets** (by Niroshan Ratnayake)
- **Flutter Riverpod Snippets** (by Roaa Kilo)

### Step 2: Configure VS Code Settings

Open VS Code Settings (Ctrl+,) and add/modify:

```json
{
  "dart.flutterSdkPath": "C:\\src\\flutter",
  "dart.enableSdkFormatter": true,
  "editor.formatOnSave": true,
  "editor.formatOnType": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  }
}
```

### Step 3: Verify Project Configuration

Ensure your `pubspec.yaml` includes:

```yaml
name: literature_board_game
description: A Flutter literature board game

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  flutter_riverpod: ^2.4.9
  google_fonts: ^6.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### Step 4: Configure VS Code Launch Settings

Create/Edit `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Android Emulator",
      "request": "launch",
      "type": "dart",
      "deviceId": "emulator-5554"
    },
    {
      "name": "Chrome",
      "request": "launch",
      "type": "dart",
      "deviceId": "chrome"
    },
    {
      "name": "Windows Desktop",
      "request": "launch",
      "type": "dart",
      "deviceId": "windows"
    }
  ]
}
```

### Step 5: Configure VS Code Debug Toolbar

The Flutter extension will automatically add a debug toolbar at the top of VS Code when you have a Flutter project open. You can:

- Select device from the dropdown (bottom-right corner)
- Click the Play button (▶️) to run
- Click the Debug button (🐛) to debug
- Click the Stop button (⏹️) to stop the app

---

## Advanced Emulator Management

### Create a New Emulator

```bash
# List available system images
flutter doctor --verbose

# Create a new emulator
flutter emulators --create --name Pixel_8 --device pixel_8

# Create with specific Android version
flutter emulators --create --name Pixel_API34 --device pixel --system-image android-34
```

### Delete an Emulator

```bash
# First, list emulators
flutter emulators

# Delete specific emulator
flutter emulators --delete Pixel_9
```

### List All Available Devices (for creating emulators)

```bash
flutter devices --machine
```

Or use Android Studio's AVD Manager:
1. Tools → Device Manager → Create Device
2. Choose device (e.g., Pixel 6, Pixel 8 Pro, Tablet, etc.)
3. Choose system image (recommended: Android 14 or 15)
4. Configure AVD settings
5. Finish and launch

---

## VS Code Key Shortcuts for Flutter

### Essential Shortcuts
- `Ctrl+Shift+P` - Command Palette
- `F5` - Start Debugging
- `Ctrl+F5` - Run without debugging
- `Shift+F5` - Stop debugging
- `Ctrl+Shift+R` - Hot Reload
- `Ctrl+Shift+F5` - Hot Restart
- `Ctrl+Shift+Alt+R` - Hot Reload on all devices

### Code Shortcuts
- `Ctrl+.` - Quick Fix
- `Alt+Enter` - Show Intentions
- `Ctrl+Space` - Code completion
- `Ctrl+Shift+A` - Show all actions
- `F12` - Go to definition
- `Shift+F12` - Find references

### Flutter-Specific
- `Ctrl+Shift+F` - Format document
- `Ctrl+Shift+K` - Toggle breakpoint
- `Ctrl+Shift+D` - Show debug console

---

## Testing the Animated Token Movement

### Run on Android Emulator

1. **Launch Emulator:**
   ```bash
   flutter emulators --launch Pixel_9
   ```

2. **Wait for Boot:**
   - Wait 1-2 minutes for emulator to fully boot
   - You'll see the Android home screen

3. **Run the App:**
   ```bash
   flutter run -d emulator-5554
   ```

4. **Test Animation:**
   - Start a new game
   - Roll the dice
   - Watch the player token smoothly animate from current tile to target tile
   - Test various scenarios:
     - Short moves (1-3 tiles)
     - Long moves (10+ tiles)
     - Board wrapping (40 → 1)
     - Multiple players on same tile

5. **Test Responsiveness:**
   - Rotate emulator (Ctrl+F11 or Ctrl+F12)
   - Change emulator resolution
   - Test in landscape and portrait modes

### Debug Animation Issues

If the animation doesn't work as expected:

1. **Check Turn Phase:**
   - Open Debug Console in VS Code
   - Verify `turnPhase` changes to `TurnPhase.moving`

2. **Check Position Tracking:**
   - Verify `oldPosition` and `newPosition` are set
   - Check they correspond to valid tile IDs (1-40)

3. **Check RenderBox:**
   - Ensure tiles have valid RenderBox positions
   - Verify GlobalKeys are properly assigned

4. **Enable Verbose Logging:**
   ```bash
   flutter run -d emulator-5554 -v
   ```

5. **Use Flutter DevTools:**
   - Click the DevTools icon in VS Code (flutter inspector)
   - Inspect widget tree
   - Check animation performance

---

## Performance Tips

### Optimize Emulator Performance

1. **Enable Hardware Acceleration:**
   - Edit AVD configuration
   - Set "Graphics" to "Automatic" or "Hardware - GLES 2.0"

2. **Allocate More RAM:**
   - In Android Studio AVD Manager
   - Edit AVD → Advanced Settings
   - Increase RAM (recommended: 4GB or more)

3. **Use x86 Emulator Images:**
   - Faster than ARM images on Intel/AMD processors
   - System images ending in "x86" or "x86_64"

4. **Enable VM Acceleration:**
   ```bash
   # Check if acceleration is available
   flutter doctor -v | grep -A 5 "Android toolchain"
   ```

### Optimize Flutter App Performance

1. **Use Profile Mode for Testing:**
   ```bash
   flutter run -d emulator-5554 --profile
   ```

2. **Enable Performance Overlay:**
   ```bash
   flutter run -d emulator-5554 --profile
   # Then press 'p' in the terminal to toggle performance overlay
   ```

3. **Check FPS:**
   - Open DevTools Performance tab
   - Monitor frame rendering
   - Target: 60 FPS for smooth animations

---

## Common Issues and Solutions

### Issue: "emulator-5554 is offline"

**Solutions:**
1. Wait longer for emulator to boot (2-3 minutes)
2. Restart ADB: `adb kill-server && adb start-server`
3. Cold boot emulator: `flutter emulators --launch Pixel_9 --cold-boot`
4. Launch from Android Studio Device Manager

### Issue: Emulator is too slow

**Solutions:**
1. Enable hardware acceleration in AVD settings
2. Increase allocated RAM (4GB+)
3. Close other applications
4. Use x86 system images instead of ARM
5. Enable HAXM (Hardware Accelerated Execution Manager)

### Issue: VS Code doesn't detect emulator

**Solutions:**
1. Restart VS Code
2. Reload Flutter: `Ctrl+Shift+P` → "Flutter: Restart Analysis Server"
3. Check Flutter extension is enabled
4. Verify `flutter devices` lists the emulator in terminal

### Issue: Animation doesn't show

**Solutions:**
1. Verify `turnPhase` is set to `TurnPhase.moving`
2. Check `oldPosition` and `newPosition` are set in GameState
3. Ensure GlobalKeys are assigned to all tiles
4. Check RenderBox positions are valid
5. Try hot reload: `Ctrl+Shift+R`

### Issue: Token misalignment

**Solutions:**
1. Verify tile dimensions (100x120 pixels)
2. Check token size (32 pixels)
3. Verify offset calculations:
   - Horizontal: `tileWidth/2 - tokenSize/2` = 50 - 16 = 34px
   - Vertical: `tileHeight/2 - tokenSize/2` = 60 - 16 = 44px

---

## Quick Reference Commands

```bash
# Check Flutter status
flutter doctor

# List devices
flutter devices

# List emulators
flutter emulators

# Launch emulator
flutter emulators --launch Pixel_9

# Run on specific device
flutter run -d emulator-5554
flutter run -d chrome
flutter run -d windows

# Hot reload
# Press 'r' in terminal or Ctrl+Shift+R

# Hot restart
# Press 'R' in terminal or Ctrl+Shift+F5

# Quit app
# Press 'q' in terminal

# Clean build
flutter clean
flutter pub get
flutter run

# Update dependencies
flutter pub upgrade

# Analyze code
flutter analyze

# Format code
dart format .
```

---

## Additional Resources

### Official Documentation
- [Flutter Setup](https://flutter.dev/docs/get-started/install)
- [Android Emulator](https://developer.android.com/studio/run/emulator)
- [VS Code Flutter Extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- [Flutter DevTools](https://flutter.dev/docs/development/tools/devtools/overview)

### Animation Documentation
- [AnimatedPositioned](https://api.flutter.dev/flutter/widgets/AnimatedPositioned-class.html)
- [Animation Tutorial](https://flutter.dev/docs/development/ui/animations)

### Community Resources
- [Flutter GitHub](https://github.com/flutter/flutter)
- [Flutter Discord](https://flutter.dev/discord)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)

---

## Summary

Your setup is nearly complete:
- ✅ Flutter and Android SDK are properly installed
- ✅ VS Code with Flutter extension is ready
- ✅ Pixel 9 emulator is configured
- ⏳ Emulator needs to be launched and come online
- 🎯 Next: Launch emulator and run the app to test animations

Once the emulator is online, you can test the animated token movement on a real Android device simulation!
