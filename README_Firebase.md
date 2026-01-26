# Firebase Configuration for Literature Board Game

This project requires Firebase integration. Since the configuration files contain sensitive information or are project-specific, they are not included in the repository.

## 1. Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Create a new project named `literature-board-game` (or similar).

## 2. Generate Configuration Files (Recommended: FlutterFire CLI)
If you have the FlutterFire CLI installed:
```bash
flutterfire configure
```
Select "literature-board-game" (or the project you created) and enable Android, iOS, and Web.
This will automatically generate:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

**IMPORTANT**: If you run `flutterfire configure`, it will overwrite the placeholder `lib/firebase_options.dart` I created. This is expected and desired.

## 3. Manual Configuration (If not using CLI)

### Android
1. In Firebase Console, add an Android app.
2. Package name: `com.example.literature_board_game` (Check `android/app/build.gradle` for `applicationId`).
3. Download `google-services.json`.
4. Place it in `android/app/google-services.json`.
5. Ensure `android/build.gradle` has `classpath 'com.google.gms:google-services:4.3.15'` (or newer).
6. Ensure `android/app/build.gradle` has `apply plugin: 'com.google.gms.google-services'`.

### iOS
1. In Firebase Console, add an iOS app.
2. Bundle ID: `com.example.literatureBoardGame` (Check `ios/Runner.xcodeproj`).
3. Download `GoogleService-Info.plist`.
4. Place it in `ios/Runner/GoogleService-Info.plist`.
5. Open `ios/Runner.xcworkspace` in Xcode and ensure the file is added to the project (Runner target).

### Web / App Config
1. Update `lib/firebase_options.dart` with the values from your project settings (API keys, App IDs, etc.).

## 4. Emulator Setup (Optional)
To use local emulators, uncomment the emulator connection lines in `lib/main.dart` or `lib/providers/firebase_providers.dart` (if added).

Run emulators:
```bash
firebase emulators:start
```
