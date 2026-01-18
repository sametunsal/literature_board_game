# Flutter Digital Board Game - Clean Architecture Refactoring Plan

## Project Overview

**Project**: literature_board_game - Flutter digital board game
**Goal**: Clean architecture approach, state management simplification, animation standardization
**Style**: Warm Library Light + Dark Academia themes
**Animation System**: MotionDurations/MotionCurves (already exists in `lib/core/motion/motion_constants.dart`)

## Key Rules

1. **Small changes, always compilable** - Each change must result in a buildable project
2. **No new dependencies** - Only add if absolutely necessary with justification, keep minimal
3. **Extract repeating widgets** - UI components should be reusable
4. **Preserve game rules** - Dice, 3 doubles → penalty, chance/fate must remain intact

---

## Current Architecture Analysis

### Existing Structure

```
lib/
├── core/
│   ├── audio_manager.dart
│   ├── motion/
│   │   └── motion_constants.dart (✓ Already exists)
│   └── theme/
│       ├── game_theme.dart
│       └── theme_tokens.dart
├── data/
│   ├── board_config.dart
│   ├── game_cards.dart
│   └── mock_questions.dart
├── exceptions/
│   └── question_loading_exception.dart
├── logic/
│   └── game_engine.dart (minimal, mostly empty)
├── models/
│   ├── board_tile.dart
│   ├── game_card.dart
│   ├── game_enums.dart
│   ├── player.dart
│   └── question.dart
├── providers/
│   ├── game_notifier.dart (⚠️ 1000+ lines - too large)
│   └── theme_notifier.dart (✓ Good size)
├── services/
│   └── streak_service.dart
├── utils/
│   └── sound_manager.dart
└── widgets/ (20+ widgets)
```

### Issues Identified

1. **No clear separation of concerns** - Business logic mixed with UI logic in GameNotifier
2. **GameNotifier is monolithic** - 1000+ lines handling dice, movement, dialogs, economy
3. **GameState is too large** - Contains UI state (dialog flags) mixed with game state
4. **Animation inconsistency** - Some widgets use MotionDurations, others have hardcoded values
5. **UI code duplication** - Similar button/card/dialog patterns repeated across widgets
6. **No domain layer** - Game rules logic is embedded in presentation layer

---

## Proposed Clean Architecture

### Layer Structure

```
lib/
├── domain/                    # Business logic (no Flutter dependencies)
│   ├── entities/             # Core business objects
│   │   ├── player.dart
│   │   ├── board_tile.dart
│   │   ├── game_card.dart
│   │   └── question.dart
│   ├── value_objects/        # Immutable values (Money, Position, DiceRoll)
│   ├── use_cases/           # Application logic (interactors)
│   │   ├── roll_dice_use_case.dart
│   │   ├── move_player_use_case.dart
│   │   ├── handle_tile_effect_use_case.dart
│   │   ├── pay_rent_use_case.dart
│   │   ├── purchase_property_use_case.dart
│   │   └── end_turn_use_case.dart
│   ├── repositories/         # Repository interfaces (contracts)
│   │   ├── game_repository.dart
│   │   ├── player_repository.dart
│   │   └── question_repository.dart
│   └── services/            # Domain services (no side effects)
│       └── dice_service.dart
│
├── data/                     # Data access (Flutter dependencies OK)
│   ├── repositories/         # Repository implementations
│   │   ├── game_repository_impl.dart
│   │   ├── player_repository_impl.dart
│   │   └── question_repository_impl.dart
│   ├── datasources/         # Data sources
│   │   ├── local/
│   │   │   ├── board_config_datasource.dart
│   │   │   └── questions_datasource.dart
│   │   └── shared_preferences/
│   │       └── theme_datasource.dart
│   ├── models/              # Data models (DTOs)
│   │   ├── player_model.dart
│   │   ├── board_tile_model.dart
│   │   └── question_model.dart
│   └── mappers/             # Convert data ↔ domain
│       ├── player_mapper.dart
│       ├── tile_mapper.dart
│       └── question_mapper.dart
│
├── presentation/             # UI layer (Flutter dependencies)
│   ├── providers/           # State management (Riverpod)
│   │   ├── game/
│   │   │   ├── game_provider.dart
│   │   │   ├── dice_provider.dart
│   │   │   ├── player_provider.dart
│   │   │   └── dialog_provider.dart
│   │   └── theme/
│   │       └── theme_provider.dart (existing)
│   ├── screens/             # Screen widgets
│   │   ├── main_menu_screen.dart
│   │   ├── setup_screen.dart
│   │   └── game_screen.dart
│   ├── widgets/             # Reusable UI components
│   │   ├── common/
│   │   │   ├── game_button.dart
│   │   │   ├── game_card.dart
│   │   │   ├── game_dialog.dart
│   │   │   └── loading_indicator.dart
│   │   ├── game/
│   │   │   ├── board_view.dart
│   │   │   ├── dice_roller.dart
│   │   │   ├── pawn_widget.dart
│   │   │   └── tile_widget.dart
│   │   └── dialogs/
│   │       ├── pause_dialog.dart
│   │       ├── question_dialog.dart
│   │       └── game_over_dialog.dart
│   └── controllers/        # Widget controllers (optional)
│       └── board_controller.dart
│
├── core/                     # Shared utilities (framework-independent)
│   ├── error/               # Error handling
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/             # (if needed)
│   └── utils/               # Pure utilities
│       ├── logger.dart
│       └── validators.dart
│
└── app/                      # App-level setup
    ├── app.dart
    └── routes.dart
```

---

## Phase-by-Phase Implementation Plan

### Phase 1: Architecture Analysis & Planning ✓
- [x] Document current architecture issues
- [x] Define clean architecture layers
- [x] Identify state management refactoring opportunities
- [x] Plan animation standardization approach

### Phase 2: Clean Architecture - Domain Layer

**Goal**: Extract business logic from presentation layer

#### Tasks:
1. Create domain entities (pure Dart, no Flutter)
   - Move existing models to `domain/entities/`
   - Ensure immutability where appropriate

2. Create value objects
   - `Money` (with currency operations)
   - `Position` (board position with validation)
   - `DiceRoll` (two dice with doubles detection)

3. Create use cases (interactors)
   - Extract game rules from GameNotifier:
     - `RollDiceUseCase` - dice rolling, doubles detection, 3 doubles rule
     - `MovePlayerUseCase` - step-by-step movement, passing start
     - `HandleTileEffectUseCase` - property, chance, fate, penalties
     - `PayRentUseCase` - rent calculation, balance updates
     - `PurchasePropertyUseCase` - property ownership, balance checks
     - `UpgradePropertyUseCase` - upgrade levels, costs
     - `DrawCardUseCase` - chance/fate card drawing
     - `EndTurnUseCase` - turn management, consecutive doubles reset

4. Create repository interfaces
   - `GameRepository` - game state persistence
   - `PlayerRepository` - player data
   - `QuestionRepository` - question loading

**Files to Create**:
```
domain/entities/player.dart
domain/entities/board_tile.dart
domain/entities/game_card.dart
domain/entities/question.dart
domain/value_objects/money.dart
domain/value_objects/position.dart
domain/value_objects/dice_roll.dart
domain/use_cases/roll_dice_use_case.dart
domain/use_cases/move_player_use_case.dart
domain/use_cases/handle_tile_effect_use_case.dart
domain/use_cases/pay_rent_use_case.dart
domain/use_cases/purchase_property_use_case.dart
domain/use_cases/upgrade_property_use_case.dart
domain/use_cases/draw_card_use_case.dart
domain/use_cases/end_turn_use_case.dart
domain/repositories/game_repository.dart
domain/repositories/player_repository.dart
domain/repositories/question_repository.dart
```

**Game Rules Preservation Checklist**:
- [ ] Dice rolling (2 dice, 2-12 range)
- [ ] Double detection (dice1 == dice2)
- [ ] 3 consecutive doubles → library penalty (position 10, 2 turns skip)
- [ ] Double allows extra turn
- [ ] Passing start (+200 points)
- [ ] Chance/Fate cards
- [ ] Property purchase questions
- [ ] Rent calculation (base * (upgrade + 1), max upgrade = 10x)
- [ ] Utility rent (dice total * 15)

### Phase 3: Clean Architecture - Data Layer

**Goal**: Implement data access with repository pattern

#### Tasks:
1. Create repository implementations
   - Implement domain repository interfaces
   - Use existing data sources (board_config, mock_questions)

2. Create data models (DTOs)
   - JSON serialization
   - Mapper to/from domain entities

3. Create data sources
   - `BoardConfigDataSource` - static board configuration
   - `QuestionsDataSource` - questions.json loading
   - `ThemeDataSource` - SharedPreferences for theme

**Files to Create**:
```
data/repositories/game_repository_impl.dart
data/repositories/player_repository_impl.dart
data/repositories/question_repository_impl.dart
data/datasources/board_config_datasource.dart
data/datasources/questions_datasource.dart
data/datasources/theme_datasource.dart
data/models/player_model.dart
data/models/board_tile_model.dart
data/models/question_model.dart
data/mappers/player_mapper.dart
data/mappers/tile_mapper.dart
data/mappers/question_mapper.dart
```

### Phase 4: Clean Architecture - Presentation Layer

**Goal**: Simplify state management by splitting monolithic GameNotifier

#### Tasks:
1. Split GameNotifier into focused providers:
   - `GameProvider` - orchestrates use cases, high-level game state
   - `DiceProvider` - dice rolling state and animations
   - `PlayerProvider` - player management (positions, balances)
   - `DialogProvider` - dialog visibility and state

2. Simplify GameState:
   - Remove UI-specific flags (dialog flags) to DialogProvider
   - Keep only game state (players, board, phase)
   - Use smaller, focused state objects

3. Connect providers to use cases:
   - Each provider injects relevant use cases
   - Use cases handle business logic
   - Providers handle UI state

**Files to Create/Modify**:
```
presentation/providers/game/game_provider.dart (NEW - simplified)
presentation/providers/game/dice_provider.dart (NEW)
presentation/providers/game/player_provider.dart (NEW)
presentation/providers/game/dialog_provider.dart (NEW)
```

**Refactoring GameNotifier** (1000+ lines → split):

| Current Functionality | New Location |
|---------------------|--------------|
| Dice rolling | DiceProvider + RollDiceUseCase |
| Player movement | PlayerProvider + MovePlayerUseCase |
| Tile effects | GameProvider + HandleTileEffectUseCase |
| Economy (rent, purchase) | GameProvider + Use Cases |
| Dialog management | DialogProvider |
| Game phase management | GameProvider |

### Phase 5: Animation Standardization

**Goal**: Ensure all animations use MotionDurations/MotionCurves

#### Tasks:
1. Audit all widgets for hardcoded animation values:
   - Search for `Duration(milliseconds:` not using MotionDurations
   - Search for `Curves.` not using MotionCurves

2. Replace hardcoded values:
   - All durations → `MotionDurations.*`
   - All curves → `MotionCurves.*`
   - All animations → use `.safe` extension

3. Document animation patterns:
   - Add comments explaining animation purpose
   - Create animation guidelines doc

**Animation Audit Checklist**:

| Widget | Current Status | Action Needed |
|--------|----------------|---------------|
| dice_roller.dart | ✓ Uses MotionDurations | None |
| pause_dialog.dart | ✓ Uses MotionDurations | None |
| modern_question_dialog.dart | ✓ Uses MotionDurations | None |
| pawn_widget.dart | ✓ Uses MotionDurations | None |
| main_menu_screen.dart | ⚠️ Partial | Review and fix |
| settings_screen.dart | ⚠️ Partial | Review and fix |
| game_over_dialog.dart | ⚠️ Partial | Review and fix |
| board_view.dart | ⚠️ Partial | Review and fix |
| streak_candle_widget.dart | ⚠️ Partial | Review and fix |
| reward_particles_widget.dart | ⚠️ Partial | Review and fix |

**Animation Patterns to Standardize**:

```dart
// ❌ Before (hardcoded)
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeOut,
)

// ✅ After (standardized)
AnimatedContainer(
  duration: MotionDurations.medium.safe,
  curve: MotionCurves.standard,
)
```

### Phase 6: UI Component Extraction

**Goal**: Extract repeating widget patterns into reusable components

#### Tasks:
1. Identify repeating patterns:
   - Buttons (pause, settings, game over, dialogs)
   - Cards (property cards, dialog cards)
   - Dialogs (similar structure, different content)

2. Create reusable components:
   - `GameButton` - Standardized button with variants (primary, secondary, danger)
   - `GameCard` - Card with consistent styling
   - `GameDialog` - Base dialog with animation
   - `TileWidget` - Unified tile rendering

3. Refactor existing widgets:
   - Replace inline button code with `GameButton`
   - Replace inline card code with `GameCard`
   - Extract common dialog logic

**Files to Create**:
```
presentation/widgets/common/game_button.dart
presentation/widgets/common/game_card.dart
presentation/widgets/common/game_dialog.dart
presentation/widgets/common/loading_indicator.dart
presentation/widgets/game/tile_widget.dart
```

**Component Extraction Examples**:

```dart
// ❌ Before (repeated in multiple files)
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: GameTheme.copperAccent,
    foregroundColor: GameTheme.textDark,
    padding: EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  child: Text('BUTTON'),
)

// ✅ After (reusable)
GameButton(
  label: 'BUTTON',
  variant: GameButtonVariant.primary,
  onPressed: () {},
)
```

### Phase 7: Testing & Validation

**Goal**: Ensure refactoring doesn't break functionality

#### Tasks:
1. Game Rules Testing:
   - [ ] Dice rolling produces 2-12
   - [ ] Double detection works correctly
   - [ ] 3 consecutive doubles → library penalty
   - [ ] Double allows extra turn
   - [ ] Passing start adds 200 points
   - [ ] Chance/Fate cards work
   - [ ] Property purchase questions work
   - [ ] Rent calculation correct
   - [ ] Upgrade costs correct

2. Animation Testing:
   - [ ] All animations use MotionDurations
   - [ ] All animations use MotionCurves
   - [ ] Animations are smooth (60fps)
   - [ ] Reduce motion accessibility works

3. Theme Testing:
   - [ ] Warm Library Light theme works
   - [ ] Dark Academia theme works
   - [ ] Theme switching works
   - [ ] Theme persists across restarts

4. Integration Testing:
   - [ ] Full game flow works
   - [ ] Multiplayer works
   - [ ] Win condition works

### Phase 8: Documentation

**Goal**: Document new architecture and patterns

#### Tasks:
1. Update README:
   - New architecture overview
   - Clean architecture explanation
   - How to add features

2. Create architecture docs:
   - `docs/ARCHITECTURE.md` - Layer responsibilities
   - `docs/STATE_MANAGEMENT.md` - Provider patterns
   - `docs/ANIMATION_GUIDELINES.md` - Animation standards
   - `docs/COMPONENT_LIBRARY.md` - Reusable components

3. Code documentation:
   - Add package-level documentation
   - Document use cases
   - Document repository interfaces

---

## Implementation Order (Small, Compilable Steps)

### Step 1: Create Domain Layer (No Flutter dependencies)
1. Create `domain/entities/` - Move existing models
2. Create `domain/value_objects/` - Money, Position, DiceRoll
3. Create `domain/repositories/` - Repository interfaces
4. Create `domain/use_cases/` - Extract game rules from GameNotifier

**Build Check**: Project should compile (domain layer has no Flutter deps)

### Step 2: Create Data Layer
1. Create `data/models/` - DTOs with JSON serialization
2. Create `data/mappers/` - Convert data ↔ domain
3. Create `data/datasources/` - Wrap existing data sources
4. Create `data/repositories/` - Implement repository interfaces

**Build Check**: Project should compile

### Step 3: Create Presentation Layer - Part 1
1. Create `presentation/widgets/common/` - GameButton, GameCard
2. Create `presentation/widgets/game/` - TileWidget (unified)
3. Refactor existing widgets to use new components

**Build Check**: Project should compile and run

### Step 4: Create Presentation Layer - Part 2
1. Create `presentation/providers/game/dice_provider.dart`
2. Create `presentation/providers/game/player_provider.dart`
3. Create `presentation/providers/game/dialog_provider.dart`
4. Update GameNotifier to use new providers (gradual migration)

**Build Check**: Project should compile and run

### Step 5: Presentation Layer - Part 3
1. Create `presentation/providers/game/game_provider.dart` (simplified)
2. Migrate remaining GameNotifier logic to use cases
3. Remove old GameNotifier (or deprecate)

**Build Check**: Project should compile and run

### Step 6: Animation Standardization
1. Audit all widgets for hardcoded animations
2. Replace with MotionDurations/MotionCurves
3. Add `.safe` extension usage

**Build Check**: Project should compile and run

### Step 7: Final Testing & Cleanup
1. Run all game rule tests
2. Test theme switching
3. Test animations
4. Remove deprecated code
5. Update documentation

**Build Check**: Final build and release

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Breaking game rules | Extract rules to domain layer first, test independently |
| Large refactoring breaks build | Small, incremental steps, compile after each step |
| Animation regressions | Audit first, replace systematically, test each change |
| State management complexity | Split gradually, keep old code until new code works |
| Theme switching breaks | Test both themes after each UI change |

---

## Success Criteria

1. **Clean Architecture**:
   - [ ] Domain layer has no Flutter dependencies
   - [ ] Data layer implements repository interfaces
   - [ ] Presentation layer uses use cases
   - [ ] Business logic is testable independently

2. **State Management**:
   - [ ] No provider exceeds 300 lines
   - [ ] UI state separated from game state
   - [ ] Each provider has single responsibility

3. **Animation Standardization**:
   - [ ] 100% of animations use MotionDurations
   - [ ] 100% of animations use MotionCurves
   - [ ] All animations use `.safe` extension

4. **UI Components**:
   - [ ] No duplicate button/card code
   - [ ] Common patterns extracted to components
   - [ ] Component library documented

5. **Game Rules**:
   - [ ] All rules work correctly
   - [ ] No regressions from refactoring
   - [ ] Multiplayer works

---

## Notes

**"Yeni bağımlılık ekleme; eklemen şartsa gerekçeli öner ve minimal tut."**
- Only add dependencies if absolutely necessary
- Provide justification for any new dependency
- Keep dependencies minimal

**"UI'da tekrar eden widget'ları component'lere böl."**
- Extract repeating patterns into reusable components
- Standardize button, card, dialog styles
- Create component library

**"Oyun kuralları (zar, 3 double → ceza, chance/fate) bozulmasın."**
- Extract game rules to domain layer first
- Test rules independently
- Verify rules after each refactoring step
