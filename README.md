# Literature Board Game

A Flutter-based board game inspired by classic literature. Players move around a 40-tile board, answering questions about famous books, managing money, and navigating special game mechanics.

Built with **Clean Architecture** principles for maintainability, scalability, and testability.

## Features

### Core Game Mechanics
- **40-Tile Board**: Classic board game layout with literature-themed tiles
- **Dice Rolling**: Two-dice system with double mechanics
- **Player Movement**: Animated pawn movement around the board
- **Money Management**: Buy book tiles, pay rent, collect money when passing GO

### Special Rules
1. **Library Watch (3x Double Dice)**: When a player rolls doubles three times in a row, they are sent to Library Watch for 3 turns
2. **Bankrupt Risk (FATE Tiles)**: Landing on FATE tiles results in a 50% loss of money
3. **CHANCE Tiles**: Random effects including finding or losing money

### Tile Types
- **START**: Starting point, collect $200 when passing
- **BOOK**: Literature tiles with questions, prices, and rent values
- **FATE**: Risk tiles that can cause 50% money loss
- **CHANCE**: Random effect tiles

## Architecture Overview

This project follows **Clean Architecture** principles with three distinct layers:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Widgets & Screens                                   │    │
│  │  - Board View, Dialogs, UI Components                │    │
│  │  - GameButton, GameCard, GameDialog                  │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  State Management (Riverpod)                         │    │
│  │  - GameNotifier, ThemeNotifier                       │    │
│  │  - Repository Providers                              │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                            ↑ depends on
┌─────────────────────────────────────────────────────────────┐
│                       DOMAIN LAYER                           │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Entities                                           │    │
│  │  - Player, BoardTile, GameCard, Question           │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Value Objects                                      │    │
│  │  - Money, Position, DiceRoll                         │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Use Cases                                          │    │
│  │  - RollDice, MovePlayer, HandleTileEffect, etc.     │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Repository Interfaces                             │    │
│  │  - GameRepository, PlayerRepository, etc.           │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                            ↑ depends on
┌─────────────────────────────────────────────────────────────┐
│                        DATA LAYER                            │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Data Sources                                       │    │
│  │  - BoardConfigDataSource, QuestionsDataSource       │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Models                                             │    │
│  │  - PlayerModel, BoardTileModel, etc.               │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Mappers                                            │    │
│  │  - Convert between models and entities              │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Repository Implementations                         │    │
│  │  - GameRepositoryImpl, PlayerRepositoryImpl, etc.  │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### Dependency Rules
- **Domain Layer**: Pure Dart, no Flutter dependencies
- **Data Layer**: Depends on Domain Layer
- **Presentation Layer**: Depends on Domain and Data Layers

## Project Structure

```
lib/
├── main.dart                          # App entry point
│
├── core/                              # Shared utilities & constants
│   ├── audio_manager.dart            # Audio playback management
│   ├── assets/asset_cache.dart       # Asset caching
│   ├── constants/game_constants.dart # Game configuration constants
│   ├── motion/motion_constants.dart  # Animation durations & curves
│   └── theme/                        # Theme system
│       ├── game_theme.dart           # Main theme definitions
│       └── theme_tokens.dart         # Theme tokens (light/dark)
│
├── domain/                           # Business logic (Pure Dart)
│   ├── entities/                     # Core business entities
│   │   ├── player.dart
│   │   ├── board_tile.dart
│   │   ├── game_card.dart
│   │   ├── question.dart
│   │   └── game_enums.dart
│   ├── value_objects/                # Value objects for domain concepts
│   │   ├── money.dart
│   │   ├── position.dart
│   │   └── dice_roll.dart
│   ├── use_cases/                    # Business operations
│   │   ├── roll_dice_use_case.dart
│   │   ├── move_player_use_case.dart
│   │   ├── handle_tile_effect_use_case.dart
│   │   ├── pay_rent_use_case.dart
│   │   ├── purchase_property_use_case.dart
│   │   ├── upgrade_property_use_case.dart
│   │   ├── draw_card_use_case.dart
│   │   └── end_turn_use_case.dart
│   ├── repositories/                 # Repository interfaces
│   │   ├── game_repository.dart
│   │   ├── player_repository.dart
│   │   └── question_repository.dart
│   └── services/                     # Domain services
│       └── dice_service.dart
│
├── data/                             # Data access & persistence
│   ├── datasources/                  # Data sources
│   │   ├── board_config_datasource.dart
│   │   ├── questions_datasource.dart
│   │   └── theme_datasource.dart
│   ├── models/                       # Data models
│   │   ├── player_model.dart
│   │   ├── board_tile_model.dart
│   │   ├── game_card_model.dart
│   │   └── question_model.dart
│   ├── mappers/                      # Model ↔ Entity mapping
│   │   ├── player_mapper.dart
│   │   ├── tile_mapper.dart
│   │   ├── card_mapper.dart
│   │   └── question_mapper.dart
│   └── repositories/                 # Repository implementations
│       ├── game_repository_impl.dart
│       ├── player_repository_impl.dart
│       └── question_repository_impl.dart
│
├── presentation/                     # UI layer
│   └── widgets/common/               # Reusable UI components
│       ├── game_button.dart          # Standardized button component
│       ├── game_card.dart            # Card component
│       └── game_dialog.dart          # Dialog component
│
├── providers/                        # Riverpod state management
│   ├── game_notifier.dart            # Main game state
│   ├── theme_notifier.dart           # Theme state
│   └── repository_providers.dart     # Repository providers
│
├── widgets/                          # Screen widgets
│   ├── board_view.dart              # Main game board
│   ├── dice_roller.dart             # Dice animation
│   ├── game_log.dart                # Game log display
│   ├── setup_screen.dart            # Player setup
│   └── ... (other screens)
│
├── logic/                            # Game engine
│   └── game_engine.dart
│
├── services/                         # App-level services
│   └── streak_service.dart
│
└── utils/                            # Utilities
    └── sound_manager.dart
```

## New Features & Improvements

### Clean Architecture Implementation
- **Domain Layer**: Pure Dart business logic with no Flutter dependencies
- **Data Layer**: Separated data access with mappers for model conversion
- **Presentation Layer**: UI components that depend only on domain abstractions

### Component Library
- **GameButton**: Standardized button with variants (primary, secondary, danger, success)
- **GameCard**: Reusable card component with consistent styling
- **GameDialog**: Animated dialog with accessibility support

### Animation Standardization
- **MotionDurations**: Centralized animation durations (fast, medium, slow, dialog, pawn, dice, confetti)
- **MotionCurves**: Standardized animation curves (standard, emphasized, decelerate, spring)
- **Accessibility**: `.safe` extension respects reduced motion settings

### Theme System
- **Theme Tokens**: Centralized theme configuration for light/dark modes
- **Modern Dark Academia**: Elegant dark theme with warm tones
- **Classic Library**: Light theme with parchment aesthetics

### State Management
- **Riverpod**: Modern reactive state management
- **GameNotifier**: Comprehensive game state with action guards
- **Null Safety**: All state is properly typed and non-null where appropriate

## How to Run

1. Ensure Flutter is installed on your system
2. Navigate to the project directory:
   ```bash
   cd literature_board_game
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Development Guidelines

### Adding New Features
1. **Domain First**: Start with domain entities, value objects, and use cases
2. **Data Layer**: Implement repositories and data sources
3. **Presentation**: Create UI components that use the domain layer
4. **State Management**: Add providers for new state as needed

### Animation Guidelines
- Always use `MotionDurations` constants instead of hardcoded values
- Use `MotionCurves` for consistent animation feel
- Apply `.safe` extension for accessibility support
- See [`docs/ANIMATION_GUIDELINES.md`](docs/ANIMATION_GUIDELINES.md) for details

### Component Usage
- Use `GameButton` for all primary actions
- Use `GameCard` for content cards
- Use `GameDialog` for all dialogs
- See [`docs/COMPONENT_LIBRARY.md`](docs/COMPONENT_LIBRARY.md) for usage examples

## Game Instructions

1. **Start**: The game begins with player setup
2. **Roll for Order**: Each player rolls dice to determine turn order
3. **Roll Dice**: Click the "Roll Dice" button to move
4. **Navigate**: Your pawn moves around the board step-by-step
5. **Book Tiles**: Click on book tiles to see literature questions
6. **Special Tiles**:
   - FATE: Risk losing 50% of your money
   - CHANCE: Random positive or negative effects
7. **Double Dice**: Roll doubles to get an extra turn (3x = Library Watch)
8. **Pass GO**: Collect $200 each time you pass START

## Technologies Used

- **Flutter**: Cross-platform UI framework
- **Riverpod**: State management
- **Google Fonts**: Poppins & Playfair Display typography
- **Font Awesome**: Icon library
- **Lottie**: Dice animations
- **Confetti**: Victory celebration effects
- **AudioPlayers**: Sound effects
- **UUID**: Unique player identification

## Documentation

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) - Detailed architecture documentation
- [`docs/STATE_MANAGEMENT.md`](docs/STATE_MANAGEMENT.md) - Riverpod state management guide
- [`docs/ANIMATION_GUIDELINES.md`](docs/ANIMATION_GUIDELINES.md) - Animation standards and best practices
- [`docs/COMPONENT_LIBRARY.md`](docs/COMPONENT_LIBRARY.md) - UI component documentation

## Tile Layout

The board consists of 40 tiles arranged as follows:
- START (Tile 0)
- Groups of Book tiles (2-4 tiles each)
- FATE and CHANCE tiles interspersed throughout
- Literature classics from Shakespeare to Dostoevsky

## Future Enhancements

- Multiplayer support (2-4 players)
- Question answering system with scoring
- Property ownership mechanics
- Trading between players
- More CHANCE and FATE effects
- Sound effects and animations
- Leaderboard and statistics

## License

This project is created for educational purposes.
