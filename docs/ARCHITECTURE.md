# Architecture Documentation

This document describes the clean architecture used in the Literature Board Game project.

## Overview

The project follows **Clean Architecture** principles as defined by Robert C. Martin (Uncle Bob). This architecture separates the application into three distinct layers with clear dependency rules:

1. **Domain Layer** - Business logic and enterprise rules (Pure Dart)
2. **Data Layer** - Data access and external interfaces (Depends on Domain)
3. **Presentation Layer** - UI and user interaction (Depends on Domain and Data)

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                         │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  Widgets & Screens                                           │  │
│  │  - BoardView, SetupScreen, Dialogs                          │  │
│  │  - GameButton, GameCard, GameDialog                         │  │
│  └─────────────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  State Management (Riverpod)                                │  │
│  │  - GameNotifier, ThemeNotifier                              │  │
│  │  - Repository Providers                                     │  │
│  └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↑ depends on
┌─────────────────────────────────────────────────────────────────┐
│                          DOMAIN LAYER                           │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  Entities (Pure Dart)                                       │  │
│  │  - Player, BoardTile, GameCard, Question                    │  │
│  │  - GamePhase, TileType, CardType                            │  │
│  └─────────────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  Value Objects (Pure Dart)                                  │  │
│  │  - Money, Position, DiceRoll                                 │  │
│  └─────────────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  Use Cases (Pure Dart)                                      │  │
│  │  - RollDiceUseCase, MovePlayerUseCase                       │  │
│  │  - HandleTileEffectUseCase, PayRentUseCase                  │  │
│  │  - PurchasePropertyUseCase, UpgradePropertyUseCase          │  │
│  │  - DrawCardUseCase, EndTurnUseCase                          │  │
│  └─────────────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  Repository Interfaces (Pure Dart)                          │  │
│  │  - GameRepository, PlayerRepository, QuestionRepository     │  │
│  └─────────────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  Services (Pure Dart)                                       │  │
│  │  - DiceService                                              │  │
│  └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↑ depends on
┌─────────────────────────────────────────────────────────────────┐
│                           DATA LAYER                             │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  Data Sources                                                │  │
│  │  - BoardConfigDataSource, QuestionsDataSource                │  │
│  │  - ThemeDataSource                                          │  │
│  └─────────────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  Models                                                      │  │
│  │  - PlayerModel, BoardTileModel, GameCardModel               │  │
│  │  - QuestionModel                                            │  │
│  └─────────────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  Mappers                                                     │  │
│  │  - PlayerMapper, TileMapper, CardMapper, QuestionMapper      │  │
│  └─────────────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  Repository Implementations                                 │  │
│  │  - GameRepositoryImpl, PlayerRepositoryImpl                  │  │
│  │  - QuestionRepositoryImpl                                    │  │
│  └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Dependency Rules

### Core Principle
**Dependencies only point inward** - outer layers depend on inner layers, but never the reverse.

### Specific Rules

| Layer | Can Depend On | Cannot Depend On |
|-------|---------------|------------------|
| **Domain** | Nothing (Pure Dart) | Flutter, Data, Presentation |
| **Data** | Domain | Presentation, Flutter (except in models) |
| **Presentation** | Domain, Data | - |

### Key Benefits

1. **Testability**: Domain layer can be tested without Flutter
2. **Independence**: Business logic is independent of UI frameworks
3. **Flexibility**: Can swap data sources without affecting business logic
4. **Maintainability**: Clear separation of concerns

## Domain Layer

The domain layer contains the core business logic of the application. It is written in **pure Dart** with no Flutter dependencies.

### Directory Structure
```
lib/domain/
├── entities/           # Core business entities
├── value_objects/      # Value objects for domain concepts
├── use_cases/          # Business operations
├── repositories/       # Repository interfaces (abstractions)
├── services/           # Domain services
└── domain.dart         # Barrel export file
```

### Entities

Entities are the core business objects that represent the application's domain concepts.

#### Player Entity
[`lib/domain/entities/player.dart`](../lib/domain/entities/player.dart)

```dart
class Player {
  final String id;
  final String name;
  final Color color;
  final int iconIndex;
  final int position;
  final int balance;
  final List<String> ownedTiles;
  final bool inJail;
  final int turnsToSkip;
}
```

**Responsibilities**:
- Represents a player in the game
- Encapsulates player state (position, money, properties)
- Provides business rules for player behavior

#### BoardTile Entity
[`lib/domain/entities/board_tile.dart`](../lib/domain/entities/board_tile.dart)

```dart
class BoardTile {
  final int id;
  final String title;
  final TileType type;
  final int? price;
  final int? rent;
  final String? category;
  final String? questionId;
}
```

**Responsibilities**:
- Represents a tile on the game board
- Defines tile type (START, BOOK, FATE, CHANCE)
- Contains tile-specific data (price, rent, category)

#### GameCard Entity
[`lib/domain/entities/game_card.dart`](../lib/domain/entities/game_card.dart)

```dart
class GameCard {
  final String id;
  final CardType type;
  final String title;
  final String description;
  final int? moneyEffect;
}
```

**Responsibilities**:
- Represents chance/fate cards
- Defines card effects (money changes, special actions)

#### Question Entity
[`lib/domain/entities/question.dart`](../lib/domain/entities/question.dart)

```dart
class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String? tileId;
}
```

**Responsibilities**:
- Represents literature questions
- Contains question text and answer options

### Value Objects

Value objects are immutable objects that represent domain concepts without identity.

#### Money Value Object
[`lib/domain/value_objects/money.dart`](../lib/domain/value_objects/money.dart)

```dart
class Money {
  final int amount;
  
  Money operator +(Money other) => Money(amount + other.amount);
  Money operator -(Money other) => Money(amount - other.amount);
  bool get isNegative => amount < 0;
}
```

**Responsibilities**:
- Encapsulates monetary values
- Provides arithmetic operations
- Ensures valid money operations

#### Position Value Object
[`lib/domain/value_objects/position.dart`](../lib/domain/value_objects/position.dart)

```dart
class Position {
  final int value;
  final int boardSize;
  
  Position advance(int steps) => Position((value + steps) % boardSize);
  bool get isStart => value == 0;
}
```

**Responsibilities**:
- Encapsulates board position logic
- Handles board wrapping
- Provides position-related queries

#### DiceRoll Value Object
[`lib/domain/value_objects/dice_roll.dart`](../lib/domain/value_objects/dice_roll.dart)

```dart
class DiceRoll {
  final int die1;
  final int die2;
  
  int get total => die1 + die2;
  bool get isDouble => die1 == die2;
}
```

**Responsibilities**:
- Encapsulates dice roll logic
- Provides double detection
- Calculates total value

### Use Cases

Use cases represent the application's business operations. Each use case is a single, well-defined action.

#### RollDiceUseCase
[`lib/domain/use_cases/roll_dice_use_case.dart`](../lib/domain/use_cases/roll_dice_use_case.dart)

```dart
class RollDiceUseCase {
  DiceRoll execute() {
    // Generate random dice roll
    return DiceRoll(die1, die2);
  }
}
```

**Responsibilities**:
- Generates dice roll values
- Encapsulates dice rolling logic

#### MovePlayerUseCase
[`lib/domain/use_cases/move_player_use_case.dart`](../lib/domain/use_cases/move_player_use_case.dart)

```dart
class MovePlayerUseCase {
  Player execute(Player player, int steps, int boardSize) {
    // Calculate new position with board wrapping
    // Handle passing start bonus
    return updatedPlayer;
  }
}
```

**Responsibilities**:
- Moves player on the board
- Handles board wrapping
- Calculates passing start bonus

#### HandleTileEffectUseCase
[`lib/domain/use_cases/handle_tile_effect_use_case.dart`](../lib/domain/use_cases/handle_tile_effect_use_case.dart)

```dart
class HandleTileEffectUseCase {
  TileEffectResult execute(Player player, BoardTile tile) {
    // Apply tile-specific effects
    // Handle FATE, CHANCE, BOOK tiles
    return TileEffectResult(...);
  }
}
```

**Responsibilities**:
- Applies tile effects to player
- Handles special tile logic
- Returns effect results

#### PayRentUseCase
[`lib/domain/use_cases/pay_rent_use_case.dart`](../lib/domain/use_cases/pay_rent_use_case.dart)

```dart
class PayRentUseCase {
  RentPaymentResult execute(Player payer, Player owner, int amount) {
    // Transfer money between players
    // Check for bankruptcy
    return RentPaymentResult(...);
  }
}
```

**Responsibilities**:
- Handles rent payments
- Transfers money between players
- Checks bankruptcy conditions

#### PurchasePropertyUseCase
[`lib/domain/use_cases/purchase_property_use_case.dart`](../lib/domain/use_cases/purchase_property_use_case.dart)

```dart
class PurchasePropertyUseCase {
  PurchaseResult execute(Player player, BoardTile tile) {
    // Check if player can afford property
    // Deduct money, add to owned tiles
    return PurchaseResult(...);
  }
}
```

**Responsibilities**:
- Validates property purchase
- Handles money deduction
- Updates ownership

#### UpgradePropertyUseCase
[`lib/domain/use_cases/upgrade_property_use_case.dart`](../lib/domain/use_cases/upgrade_property_use_case.dart)

```dart
class UpgradePropertyUseCase {
  UpgradeResult execute(Player player, BoardTile tile) {
    // Check if player owns property
    // Calculate upgrade cost
    // Apply upgrade
    return UpgradeResult(...);
  }
}
```

**Responsibilities**:
- Validates property upgrades
- Handles upgrade costs
- Updates property level

#### DrawCardUseCase
[`lib/domain/use_cases/draw_card_use_case.dart`](../lib/domain/use_cases/draw_card_use_case.dart)

```dart
class DrawCardUseCase {
  GameCard execute(List<GameCard> deck) {
    // Draw random card from deck
    return selectedCard;
  }
}
```

**Responsibilities**:
- Draws random card from deck
- Returns card for effect application

#### EndTurnUseCase
[`lib/domain/use_cases/end_turn_use_case.dart`](../lib/domain/use_cases/end_turn_use_case.dart)

```dart
class EndTurnUseCase {
  int execute(int currentPlayerIndex, int playerCount, bool rolledDouble) {
    // Calculate next player index
    // Handle double rolls (extra turn)
    return nextPlayerIndex;
  }
}
```

**Responsibilities**:
- Calculates next player
- Handles double roll extra turns
- Manages turn flow

### Repository Interfaces

Repository interfaces define contracts for data access without specifying implementation.

#### GameRepository
[`lib/domain/repositories/game_repository.dart`](../lib/domain/repositories/game_repository.dart)

```dart
abstract class GameRepository {
  Future<List<BoardTile>> getBoardTiles();
  Future<List<GameCard>> getGameCards();
}
```

**Responsibilities**:
- Provides access to game configuration
- Abstraction for board and card data

#### PlayerRepository
[`lib/domain/repositories/player_repository.dart`](../lib/domain/repositories/player_repository.dart)

```dart
abstract class PlayerRepository {
  Future<void> savePlayer(Player player);
  Future<Player?> getPlayer(String id);
  Future<List<Player>> getAllPlayers();
}
```

**Responsibilities**:
- Provides player data access
- Handles player persistence

#### QuestionRepository
[`lib/domain/repositories/question_repository.dart`](../lib/domain/repositories/question_repository.dart)

```dart
abstract class QuestionRepository {
  Future<List<Question>> getAllQuestions();
  Future<Question?> getQuestionById(String id);
  Future<List<Question>> getQuestionsForTile(String tileId);
}
```

**Responsibilities**:
- Provides question data access
- Filters questions by tile

### Domain Services

Domain services contain business logic that doesn't naturally fit into entities or value objects.

#### DiceService
[`lib/domain/services/dice_service.dart`](../lib/domain/services/dice_service.dart)

```dart
abstract class DiceService {
  DiceRoll roll();
  bool isDouble(DiceRoll roll);
}
```

**Responsibilities**:
- Provides dice rolling functionality
- Abstracts random number generation

## Data Layer

The data layer is responsible for data access, persistence, and external system integration. It implements the repository interfaces defined in the domain layer.

### Directory Structure
```
lib/data/
├── datasources/        # Data source implementations
├── models/             # Data models (DTOs)
├── mappers/            # Model ↔ Entity mapping
└── repositories/       # Repository implementations
```

### Data Sources

Data sources are responsible for retrieving data from external systems (JSON files, APIs, databases).

#### BoardConfigDataSource
[`lib/data/datasources/board_config_datasource.dart`](../lib/data/datasources/board_config_datasource.dart)

```dart
class BoardConfigDataSource {
  Future<List<BoardTileModel>> getBoardTiles() async {
    // Load board configuration from JSON
    return tiles;
  }
}
```

**Responsibilities**:
- Loads board configuration from assets
- Returns data models

#### QuestionsDataSource
[`lib/data/datasources/questions_datasource.dart`](../lib/data/datasources/questions_datasource.dart)

```dart
class QuestionsDataSource {
  Future<List<QuestionModel>> getQuestions() async {
    // Load questions from JSON
    return questions;
  }
}
```

**Responsibilities**:
- Loads questions from assets
- Returns data models

#### ThemeDataSource
[`lib/data/datasources/theme_datasource.dart`](../lib/data/datasources/theme_datasource.dart)

```dart
class ThemeDataSource {
  Future<ThemeConfigModel> getThemeConfig() async {
    // Load theme configuration
    return config;
  }
}
```

**Responsibilities**:
- Loads theme configuration
- Returns theme data model

### Models

Data models (DTOs) represent the data format as it comes from external sources.

#### PlayerModel
[`lib/data/models/player_model.dart`](../lib/data/models/player_model.dart)

```dart
class PlayerModel {
  final String id;
  final String name;
  final int colorValue;
  final int iconIndex;
  final int position;
  final int balance;
  final List<String> ownedTiles;
  final bool inJail;
  final int turnsToSkip;
}
```

**Responsibilities**:
- Represents player data format
- Used for serialization/deserialization

#### BoardTileModel
[`lib/data/models/board_tile_model.dart`](../lib/data/models/board_tile_model.dart)

```dart
class BoardTileModel {
  final int id;
  final String title;
  final String type;
  final int? price;
  final int? rent;
  final String? category;
  final String? questionId;
}
```

**Responsibilities**:
- Represents tile data format
- Used for JSON deserialization

### Mappers

Mappers convert between data models and domain entities.

#### PlayerMapper
[`lib/data/mappers/player_mapper.dart`](../lib/data/mappers/player_mapper.dart)

```dart
class PlayerMapper {
  static Player toEntity(PlayerModel model) {
    return Player(
      id: model.id,
      name: model.name,
      color: Color(model.colorValue),
      // ... other fields
    );
  }
  
  static PlayerModel toModel(Player entity) {
    return PlayerModel(
      id: entity.id,
      name: entity.name,
      colorValue: entity.color.value,
      // ... other fields
    );
  }
}
```

**Responsibilities**:
- Converts PlayerModel ↔ Player entity
- Handles color serialization

#### TileMapper
[`lib/data/mappers/tile_mapper.dart`](../lib/data/mappers/tile_mapper.dart)

```dart
class TileMapper {
  static BoardTile toEntity(BoardTileModel model) {
    return BoardTile(
      id: model.id,
      title: model.title,
      type: TileType.fromString(model.type),
      // ... other fields
    );
  }
}
```

**Responsibilities**:
- Converts BoardTileModel ↔ BoardTile entity
- Handles enum conversion

### Repository Implementations

Repository implementations fulfill the contracts defined in the domain layer.

#### GameRepositoryImpl
[`lib/data/repositories/game_repository_impl.dart`](../lib/data/repositories/game_repository_impl.dart)

```dart
class GameRepositoryImpl implements GameRepository {
  final BoardConfigDataSource _boardDataSource;
  final BoardTileMapper _tileMapper;
  
  @override
  Future<List<BoardTile>> getBoardTiles() async {
    final models = await _boardDataSource.getBoardTiles();
    return models.map(_tileMapper.toEntity).toList();
  }
}
```

**Responsibilities**:
- Implements GameRepository interface
- Uses data sources and mappers
- Returns domain entities

#### PlayerRepositoryImpl
[`lib/data/repositories/player_repository_impl.dart`](../lib/data/repositories/player_repository_impl.dart)

```dart
class PlayerRepositoryImpl implements PlayerRepository {
  final PlayerMapper _mapper;
  
  @override
  Future<void> savePlayer(Player player) async {
    // Save player using mapper
  }
}
```

**Responsibilities**:
- Implements PlayerRepository interface
- Handles player persistence

#### QuestionRepositoryImpl
[`lib/data/repositories/question_repository_impl.dart`](../lib/data/repositories/question_repository_impl.dart)

```dart
class QuestionRepositoryImpl implements QuestionRepository {
  final QuestionsDataSource _questionsDataSource;
  final QuestionMapper _mapper;
  
  @override
  Future<List<Question>> getAllQuestions() async {
    final models = await _questionsDataSource.getQuestions();
    return models.map(_mapper.toEntity).toList();
  }
}
```

**Responsibilities**:
- Implements QuestionRepository interface
- Filters and returns questions

## Presentation Layer

The presentation layer handles UI rendering and user interaction. It depends on the domain layer for business logic and the data layer for data access.

### Directory Structure
```
lib/presentation/
└── widgets/common/      # Reusable UI components
    ├── game_button.dart
    ├── game_card.dart
    └── game_dialog.dart
```

### Widgets

#### GameButton
[`lib/presentation/widgets/common/game_button.dart`](../lib/presentation/widgets/common/game_button.dart)

A standardized button component with multiple variants.

**Variants**:
- `primary` - Main action buttons
- `secondary` - Secondary actions
- `danger` - Destructive actions
- `success` - Confirmation actions

**Features**:
- Loading state
- Disabled state
- Icon support
- Full width option

#### GameCard
[`lib/presentation/widgets/common/game_card.dart`](../lib/presentation/widgets/common/game_card.dart)

A reusable card component with consistent styling.

**Features**:
- Customizable content
- Theme-aware colors
- Shadow effects
- Border styling

#### GameDialog
[`lib/presentation/widgets/common/game_dialog.dart`](../lib/presentation/widgets/common/game_dialog.dart)

An animated dialog component with accessibility support.

**Features**:
- Animated entry/exit
- Theme-aware styling
- Accessibility support
- Customizable actions

## State Management

The project uses **Riverpod** for state management. See [`STATE_MANAGEMENT.md`](STATE_MANAGEMENT.md) for detailed documentation.

### Key Providers

- **gameProvider** - Main game state ([`lib/providers/game_notifier.dart`](../lib/providers/game_notifier.dart))
- **themeProvider** - Theme state ([`lib/providers/theme_notifier.dart`](../lib/providers/theme_notifier.dart))
- **repositoryProviders** - Repository providers ([`lib/providers/repository_providers.dart`](../lib/providers/repository_providers.dart))

## Data Flow

### Example: Rolling Dice

```
┌─────────────────────────────────────────────────────────────┐
│ 1. User clicks "Roll Dice" button                            │
│    (Presentation Layer)                                       │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. GameNotifier.rollDice() called                            │
│    (Presentation Layer - State Management)                    │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. RollDiceUseCase.execute() called                          │
│    (Domain Layer - Use Case)                                 │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. DiceService.roll() called                                │
│    (Domain Layer - Service)                                  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. Returns DiceRoll(die1, die2)                             │
│    (Domain Layer - Value Object)                             │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. MovePlayerUseCase.execute() called                       │
│    (Domain Layer - Use Case)                                 │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ 7. HandleTileEffectUseCase.execute() called                 │
│    (Domain Layer - Use Case)                                 │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ 8. GameNotifier state updated                                │
│    (Presentation Layer - State Management)                    │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ 9. UI rebuilds with new state                               │
│    (Presentation Layer - Widgets)                            │
└─────────────────────────────────────────────────────────────┘
```

## Benefits of This Architecture

1. **Testability**: Domain layer can be tested in isolation without Flutter
2. **Maintainability**: Clear separation of concerns makes code easier to understand
3. **Scalability**: Easy to add new features without affecting existing code
4. **Flexibility**: Can swap data sources or UI frameworks without changing business logic
5. **Reusability**: Domain logic can be reused across different platforms

## Best Practices

### Domain Layer
- Keep entities and value objects immutable
- Use cases should be single-purpose
- Repository interfaces should be abstract
- No Flutter dependencies

### Data Layer
- Use mappers for model/entity conversion
- Keep data sources focused on data retrieval
- Repository implementations should return domain entities
- Handle errors appropriately

### Presentation Layer
- Widgets should be thin and delegate logic to use cases
- Use Riverpod for state management
- Keep UI components reusable
- Follow Flutter best practices

## Related Documentation

- [`../README.md`](../README.md) - Project overview and getting started
- [`STATE_MANAGEMENT.md`](STATE_MANAGEMENT.md) - Riverpod state management guide
- [`ANIMATION_GUIDELINES.md`](ANIMATION_GUIDELINES.md) - Animation standards
- [`COMPONENT_LIBRARY.md`](COMPONENT_LIBRARY.md) - UI component documentation
