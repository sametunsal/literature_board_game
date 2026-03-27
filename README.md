[![Türkçe](https://img.shields.io/badge/Lang-Türkçe-red)](README.tr.md)

# 📚 Edebina: Turkish Literature Board Game

**Edebina** is an immersive, multiplayer mobile board game built with **Flutter**, designed to make learning Turkish Literature periods, authors, and works interactive and fun. It combines classic monopoly-style mechanics with educational quizzes, "Chance/Fate" cards, and a rich audiovisual experience.

## 🚀 Key Features

### 🎮 Gameplay
- **Local Multiplayer:** Supports **2-6 players** on a single device
- **Dynamic Turn Order:** Automated dice rolling with recursive tie-breaker system
- **Educational Quizzes:** 7 question categories covering Turkish literature
- **Progression System:** Mastery ranks (Çırak → Kalfa → Usta) with bonus rewards
- **Special Tiles:** Library (Jail), İmza Günü (Signing Day), Kıraathane (Shop), Teşvik (Bonus)

### 🎨 Visual Design
- **Dark Academia Theme:** Warm, cozy library aesthetic with elegant typography
- **3D Dice Animation:** Realistic 6-faced cube animation with visible rotation, corner gaps eliminated
- **Perimeter HUD:** Player panels positioned around board edges (corners for ≤4 players, corners + middle-sides for 5-6)
- **Responsive Layout:** Optimized for various screen sizes with SafeArea support

### 🔊 Audio System
- **Context-Aware BGM:** Separate playlists for Menu vs. In-Game with seamless transitions
- **Volume Controls:** Independent sliders for Music (35% gain cap) and SFX
- **Fade Transitions:** Smooth 2-second fade-in, 1-second fade-out
- **Rich SFX:** Dice rolls, pawn steps, card flips, correct/wrong answers

## 🛠️ Tech Stack

### Framework & Language
- **Flutter** (Dart) - Cross-platform mobile UI framework
- **Dart** - Programming language (SDK ^3.10.4)

### State Management
- **flutter_riverpod** (^2.4.9) - Reactive state management
- **Provider** pattern - Clean architecture state containers

### UI & Animations
- **flutter_animate** (^4.5.0) - Declarative animation library
- **google_fonts** (^6.1.0) - Typography (Cinzel Decorative, Pinyon Script, Poppins, Crimson Text)
- **font_awesome_flutter** (^10.6.0) - Icons
- **confetti** (^0.7.0) - Victory celebration effects
- **lottie** (^3.1.0) - JSON-based animations
- **shimmer** (^3.0.0) - Loading effects

### Audio
- **audioplayers** (^6.1.0) - Audio playback with context-aware playlists

### Firebase (Optional)
- **firebase_core** (^3.6.0)
- **firebase_auth** (^5.3.1)
- **cloud_firestore** (^5.4.4)

### Utilities
- **uuid** (^4.3.3) - Unique player identification
- **auto_size_text** (^3.0.0) - Responsive text sizing
- **shared_preferences** (^2.2.2) - Local persistence
- **equatable** (^2.0.8) - Value equality comparisons
- **http** (^1.2.1) - Network requests

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point, Firebase init
│
├── core/                             # Shared utilities & constants
│   ├── constants/
│   │   └── game_constants.dart       # Game balance, animation timings
│   ├── managers/
│   │   ├── audio_manager.dart         # Context-aware BGM system (Menu/Game)
│   │   └── sound_manager.dart         # Legacy sound manager
│   ├── motion/
│   │   └── motion_constants.dart      # Animation durations & curves
│   ├── theme/
│   │   ├── game_theme.dart           # Main theme definitions
│   │   └── theme_tokens.dart         # Theme tokens (light/dark)
│   └── utils/
│       ├── board_layout_config.dart   # 7x8 grid layout calculations
│       └── board_layout_helper.dart   # Layout helper functions
│
├── models/                           # Domain models
│   ├── board_config.dart             # Board configuration (26 tiles)
│   ├── game_card.dart                # Chance/Fate card definitions
│   ├── game_enums.dart               # Enums (QuestionCategory, TileType, GamePhase, etc.)
│   ├── player.dart                   # Player entity with mastery system
│   ├── question.dart                 # Question model
│   └── tile_type.dart                # Tile type definitions
│
├── providers/                        # State management (Riverpod)
│   ├── app_bootstrap.dart            # App initialization provider
│   ├── firebase_providers.dart       # Firebase providers
│   ├── game_notifier.dart            # Main game state & logic
│   ├── repository_providers.dart     # Repository providers
│   └── theme_notifier.dart           # Theme state management
│
├── presentation/                     # UI layer
│   ├── dialogs/
│   │   ├── pause_dialog.dart         # In-game pause menu
│   │   ├── settings_dialog.dart      # Audio settings (volume sliders)
│   │   ├── modern_question_dialog.dart # Quiz dialog with suspense delay
│   │   ├── card_dialog.dart          # Chance/Fate card dialog
│   │   ├── notification_dialogs.dart # Library, Turn Skipped dialogs
│   │   └── ...
│   ├── screens/
│   │   ├── splash_screen.dart        # Splash screen
│   │   ├── main_menu_screen.dart     # Main menu
│   │   ├── setup_screen.dart         # Player setup (2-6 players)
│   │   ├── victory_screen.dart       # Victory celebration screen
│   │   └── collection_screen.dart   # Collection viewing
│   └── widgets/
│       ├── board_view.dart           # Main game board with effects overlay
│       ├── board/
│       │   ├── effects_overlay.dart   # Dialogs, confetti, floating effects
│       │   ├── player_hud.dart        # Player HUD panels (perimeter layout)
│       │   ├── center_area.dart       # Center area with dice roller
│       │   ├── tile_grid.dart         # 7x8 tile grid
│       │   └── turn_order_dialog.dart # Turn order result dialog
│       ├── animations/
│       │   └── card_deal_transition.dart # Card deal animation
│       ├── quiz/
│       │   └── option_button.dart      # Question option buttons
│       ├── common/
│       │   ├── bouncing_button.dart    # Animated bouncing button
│       │   └── game_button.dart        # Standardized button component
│       ├── dice_roller.dart          # Dice animation widget
│       ├── pawn_widget.dart           # 3D-style pawn widget
│       ├── game_log.dart              # In-game event log
│       └── player_scoreboard.dart     # Player scoreboard widget
│
├── data/                             # Data layer
│   ├── board_config.dart             # Board configuration (26 tiles)
│   ├── game_cards.dart               # Chance/Fate card definitions
│   ├── datasources/                  # Data sources
│   ├── models/                       # Data transfer objects
│   ├── mappers/                      # Model ↔ Entity mapping
│   └── repositories/                 # Repository implementations
│
├── domain/                           # Business logic (Pure Dart)
│   ├── domain.dart                   # Domain exports
│   └── repositories/                 # Repository interfaces
│
└── services/                         # App-level services
    └── streak_service.dart           # User streak tracking
```

## 🎯 Question Categories

| Category | Turkish Name | Description |
|----------|-------------|-------------|
| Ben Kimim? | Who Am I? | Personal identification questions |
| Türk Edebiyatında İlkler | Literary Firsts | Pioneering works and authors |
| Edebiyat Akımları | Literary Movements | Art movements and periods |
| Edebi Sanatlar | Literary Arts | Poetry, prose, and techniques |
| Eser-Karakter | Work-Character | Book and character identification |
| Teşvik | Encouragement | Bonus rewards & trivia |

## 🎲 Game Mechanics

### Turn Order Determination
- **Automated Dice Rolling:** All players roll automatically with animated dice
- **Tie-Breaker System:** Recursive re-rolls until a unique highest roll is determined
- **Visual Feedback:** Turn order dialog displays final player sequence

### Movement & Dice
- **Double Dice Rules:**
  - **1st or 2nd Double:** Roll again (bonus turn)
  - **3rd Consecutive Double:** Sent to Library (Jail) for 2 turns
- **Library Priority:** Landing on Library immediately ends turn (overrides Double bonus)
- **Pawn Movement:** 450ms per hop with synchronized audio feedback

### Mastery System
Answer **3 questions correctly** in the same category/difficulty to achieve ranks:
- **Çırak** (Apprentice) → 1x reward multiplier
- **Kalfa** (Journeyman) → 2x reward multiplier (requires Çırak)
- **Usta** (Master) → 3x reward multiplier (requires Kalfa)

### Special Tiles
| Tile | Effect |
|------|--------|
| 📚 **Kütüphane (Library)** | Jail - Skip next 2 turns |
| ✍️ **İmza Günü** | Signing Day - Fan meet event |
| 🏛️ **Kıraathane** | Shop - Buy literary quotes with stars |
| 🎲 **Teşvik** | Bonus - Free stars reward |
| ⚖️ **Şans/Kader** | Chance/Fate cards with random effects |

## ✨ Recent Additions

### New Card Interactions
- **Printer/Ink Issue Dialog:** Special themed popup for "Printer jammed" and "Out of ink" fate cards
- **Auto-Close:** Automatically closes after 1.8 seconds
- **Ink Stain Theme:** Visually cohesive design matching the game's aesthetic

### Player Experience Improvements
- **Question Shuffling:** Questions are randomly shuffled within their categories for each game
- **Dice Animation:** Realistic 3D dice with corner gaps eliminated

## 🚀 Installation & Setup

### Prerequisites
- Flutter SDK 3.10.4 or higher
- Dart 3.10.4 or higher
- Android Studio / VS Code (with Flutter extension)
- Physical device or emulator for testing

### Setup Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/sametunsal/literature_board_game.git
   cd literature_board_game
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Build for Release

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 🎮 How to Play

1. **Main Menu:** Click "Oyunu Başlat" (Start Game)
2. **Setup:** Select 2-6 players, choose avatars and names
3. **Turn Order:** Watch as players roll dice to determine starting order
4. **Roll Dice:** Tap the dice button to move around the board
5. **Answer Questions:** When landing on category tiles, answer correctly to earn stars
6. **Win Condition:** First player to achieve "Ehil" (Master) rank wins!

## 📸 Screenshots

*Note: Screenshots to be added*

- Main Menu with Dark Academia theme
- Player Setup screen (6-player support)
- Game board with Perimeter HUD layout
- Question dialog with suspense delay
- Victory celebration with confetti

## 🔧 Development Guidelines

### Adding New Features

1. **State First:** Define state in `GameNotifier.dart` or create new notifiers
2. **Domain Logic:** Keep business logic pure in `domain/` layer
3. **UI Components:** Create reusable widgets in `presentation/widgets/`
4. **Animations:** Use `MotionDurations` and `MotionCurves` constants
5. **Audio:** Use `AudioManager.instance` for all audio playback

### Audio Guidelines

**Playing Sound Effects:**
```dart
// SFX (sound effects)
AudioManager.instance.playSfx('audio/dice_roll.wav');
AudioManager.instance.playClick();
AudioManager.instance.playPawnStep();
```

**Switching Music Context:**
```dart
// Switch to game music (when game starts)
await AudioManager.instance.playInGameBgm();

// Switch to menu music (when returning to menu)
await AudioManager.instance.playMenuBgm();

// Adjust volumes
AudioManager.instance.setBgmVolume(0.7); // 0.0 - 1.0
AudioManager.instance.setSfxVolume(1.0);
```

### Animation Standards

**Always use project constants:**
```dart
// ✅ Good
await Future.delayed(MotionDurations.slow.safe);
curve: MotionCurves.emphasized;

// ❌ Bad
await Future.delayed(const Duration(milliseconds: 300));
curve: Curves.easeInOut;
```

### Component Usage

**Standard Button:**
```dart
GameButton(
  text: 'Roll Dice',
  onPressed: () => gameNotifier.rollDice(),
  variant: GameButtonVariant.primary,
)
```

## 📖 Documentation

- [`ARCHITECTURE.md`](ARCHITECTURE.md) - Detailed architecture documentation
- [`STATE_MANAGEMENT.md`](docs/STATE_MANAGEMENT.md) - State management guide
- [`CLAUDE.md`](CLAUDE.md) - Project context & coding standards

## 🐛 Known Issues

None at this time.

## 🔄 Version History

- **v1.0.1** - Printer/Ink issue themed dialog, question shuffling, dice corner gap fixes
- **v1.0.0** - Initial release with 6-player support, context-aware audio, and perimeter HUD layout

## 📄 License

This project is created for educational purposes.

## 👥 Credits

Developed with ❤️ using Flutter and Dart.

---

**Edebina** - Making Turkish Literature interactive, one question at a time.
