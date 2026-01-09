# Build Instructions

To generate an APK for Android, follow these steps:

## Prerequisites
- Flutter SDK installed and configured
- Android Studio / Android SDK configured

## Commands

### 1. Clean Build
It's always good practice to clean the build cache first:
```bash
flutter clean
flutter pub get
```

### 2. Build Debug APK (Testing)
For testing on your device without signing:
```bash
flutter build apk --debug
```
*Output: `build/app/outputs/flutter-apk/app-debug.apk`*

### 3. Build Release APK (Production)
For a performance-optimized release build (requires signing config for Play Store, but works for local install):
```bash
flutter build apk --release
```
*Output: `build/app/outputs/flutter-apk/app-release.apk`*

> **Note:** If you encounter errors related to `multidex`, ensure your `minSdkVersion` is 21 or higher (already configured).
