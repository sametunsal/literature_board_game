# Project Architecture Map - EdebinA 3D

## 1. FILE TREE & RESPONSIBILITIES

```
lib/
├── main.dart [ENTRY POINT: App bootstrap, Firebase init, Provider scope]
├── firebase_options.dart [Firebase configuration]
│
├── core/ [SHARED FOUNDATIONS]
│   ├── constants/
│   │   └── game_constants.dart [Game balance values: rewards, penalties, delays]
│   ├── motion/
│   │   └── motion_constants.dart [Animation durations & curves system-wide]
│   ├── theme/
│   │   ├── game_theme.dart [Color palettes, text styles, dark/light themes]
│   │   └── theme_tokens.dart [Design system tokens]
│   ├── managers/
│   │   └── sound_manager.dart [Audio: SFX, background music, mute state]
│   └── utils/
│       ├── board_layout_config.dart [Board geometry, tile positions]
│       └── board_layout_helper.dart [Position calculations, tile center finder]
│
├── data/ [DATA LAYER: Sources, Repositories, Mappers]
│   ├── board_config.dart [Static board layout: 26 tiles, categories]
│   ├── game_cards.dart [Şans & Kader card decks (static data)]
│   ├── datasources/
│   │   ├── auth_data_source.dart [Firebase Auth interface]
│   │   ├── board_config_datasource.dart [Board configuration provider]
│   │   ├── questions_datasource.dart [Question loader (Firebase/JSON)]
│   │   ├── theme_datasource.dart [Theme persistence]
│   │   └── user_remote_data_source.dart [Firestore user data]
│   ├── models/
│   │   ├── literary_quote_model.dart [Quote DTO from Firebase]
│   │   └── question_model.dart [Question DTO from Firebase]
│   ├── mappers/
│   │   ├── card_mapper.dart [Card DTO → Domain]
│   │   ├── player_mapper.dart [Player DTO ↔ Domain]
│   │   ├── question_mapper.dart [Question DTO → Domain]
│   │   └── tile_mapper.dart [Tile DTO → Domain]
│   └── repositories/
│       ├── auth_repository_impl.dart [Firebase Auth implementation]
│       ├── game_repository_impl.dart [Game state persistence]
│       ├── player_repository_impl.dart [Player CRUD operations]
│       ├── question_repository_impl.dart [Question loader with caching]
│       ├── quote_repository.dart [Quote collection from Firebase]
│       └── user_repository_impl.dart [User profile from Firestore]
│
├── domain/ [BUSINESS LOGIC LAYER]
│   ├── domain.dart [Barrel file for domain exports]
│   └── repositories/
│       ├── auth_repository.dart [Auth abstraction interface]
│       ├── game_repository.dart [Game persistence abstraction]
│       ├── player_repository.dart [Player CRUD abstraction]
│       └── question_repository.dart [Question loading abstraction]
│
├── models/ [DOMAIN MODELS: Core business entities]
│   ├── board_tile.dart [Tile: type, category, position, properties]
│   ├── difficulty.dart [Difficulty enum: easy, medium, hard]
│   ├── game_card.dart [Card: type, effect, value, description]
│   ├── game_enums.dart [TileType, CardType, CardEffectType, GamePhase]
│   ├── player.dart [Player: stats, position, mastery levels, quotes]
│   ├── question.dart [Question: text, answer, category, difficulty]
│   ├── quote.dart [Literary quote for shop collection]
│   └── tile_type.dart [Tile type enumeration]
│
├── providers/ [STATE MANAGEMENT: Riverpod Notifiers]
│   ├── app_bootstrap.dart [Firebase init guard, loading state]
│   ├── firebase_providers.dart [Firebase instances: Auth, Firestore]
│   ├── game_notifier.dart [★ CORE BRAIN: Turn logic, dice, movement, questions]
│   ├── repository_providers.dart [Repository DI bindings]
│   └── theme_notifier.dart [Theme mode state: light/dark/system]
│
├── presentation/ [UI LAYER]
│   ├── screens/
│   │   ├── splash_screen.dart [Loading screen while Firebase inits]
│   │   ├── main_menu_screen.dart [Main menu: play, collection, settings]
│   │   ├── setup_screen.dart [Player setup: name, color, avatar]
│   │   ├── collection_screen.dart [Quote collection gallery]
│   │   └── settings_screen.dart [Audio, theme toggles]
│   ├── dialogs/
│   │   ├── card_dialog.dart [Event card display dialog]
│   │   ├── game_over_dialog.dart [Winner announcement dialog]
│   │   ├── modern_question_dialog.dart [Question flashcard dialog]
│   │   ├── notification_dialogs.dart [Library penalty, turn skipped, etc.]
│   │   ├── pause_dialog.dart [Pause menu dialog]
│   │   ├── rules_dialog.dart [Game rules display]
│   │   └── shop_dialog.dart [Kıraathane quote shop]
│   ├── widgets/
│   │   ├── board/ [BOARD SUB-COMPONENTS]
│   │   │   ├── center_area.dart [Board center: logo, decorations]
│   │   │   ├── effects_overlay.dart [Dialogs, confetti, floating effects]
│   │   │   ├── tile_grid.dart [26-tile grid layout]
│   │   │   ├── tile_widget.dart [Individual tile renderer]
│   │   │   └── turn_order_dialog.dart [Turn order result display]
│   │   ├── common/ [SHARED UI COMPONENTS]
│   │   │   ├── game_button.dart [Themed button widget]
│   │   │   ├── game_card.dart [Card display widget]
│   │   │   ├── game_dialog.dart [Dialog container wrapper]
│   │   │   └── star_shape.dart [Star icon painter]
│   │   ├── board_view.dart [★ MAIN BOARD: Complete game view]
│   │   ├── card_deck_widget.dart [Card deck display]
│   │   ├── dice_roller.dart [Dice animation & roller widget]
│   │   ├── enhanced_tile_widget.dart [Rich tile with icons/effects]
│   │   ├── floating_score.dart [Floating score animation]
│   │   ├── game_log.dart [Turn log display]
│   │   ├── isometric_icon.dart [Isometric category icons]
│   │   ├── pawn_widget.dart [Player pawn piece]
│   │   ├── player_scoreboard.dart [Player stats scoreboard]
│   │   ├── reward_particles_widget.dart [Reward confetti effect]
│   │   └── streak_candle_widget.dart [Win streak indicator]
│
├── services/ [CROSS-CUTTING SERVICES]
│   └── streak_service.dart [Win streak calculation logic]
│
└── exceptions/ [ERROR HANDLING]
    └── question_loading_exception.dart [Question load failure exception]
```

---

## 2. KEY ARCHITECTURAL COMPONENTS

### State Management: The "Brain"
| File | Role |
|------|------|
| **`game_notifier.dart`** | **CORE LOGIC** - Single source of truth for game state. Manages: turn order, dice rolling, player movement, question triggering, card effects, win conditions, bot mode, dialog states. Uses `StateNotifier` pattern with `GameState` immutable model. |
| **`theme_notifier.dart`** | Theme mode state (light/dark/system) |
| **`app_bootstrap.dart`** | Firebase initialization guard, loading/splash state |

### UI Layer: Main Board & Sub-Components
| Widget | Responsibility |
|--------|---------------|
| **`board_view.dart`** | **MAIN BOARD** - Complete game view. Orchestrates: tile grid, pawns, center area, dice roller, effects overlay. Handles user interactions (tap to roll). |
| `tile_grid.dart` | 26-tile perimeter layout using `board_layout_config.dart` |
| `tile_widget.dart` / `enhanced_tile_widget.dart` | Individual tile rendering with icons, colors, animations |
| `pawn_widget.dart` | Player piece with hopping animation |
| `dice_roller.dart` | 3D dice rolling animation (visual only) |
| `effects_overlay.dart` | Confetti, floating effects, dialog overlays |
| `center_area.dart` | Board center decorations (logo, theme elements) |
| `player_scoreboard.dart` | Player stats panel (stars, mastery levels) |

### Data Layer: Questions & Cards
| Source | Type | Details |
|--------|------|---------|
| **Firebase Firestore** | Questions | Loaded via `question_repository_impl.dart` - Cached in `GameNotifier._cachedQuestions` |
| **`game_cards.dart`** | Event Cards | Static data - Şans (10 cards) + Kader (10 cards) |
| **`board_config.dart`** | Board Layout | Static 26-tile configuration with categories |
| **Local JSON** | Fallback | Questions can load from `assets/data/questions.json` |

### Services & Helpers
| Service | Role |
|---------|------|
| `sound_manager.dart` | Audio playback (SFX, music, mute state) |
| `streak_service.dart` | Win streak calculation |
| `board_layout_helper.dart` | Tile position calculations (pixel coordinates) |
| `motion_constants.dart` | Animation timing system (durations, curves) |

---

## 3. CRITICAL FLOWS

### End Turn Logic
**File:** `game_notifier.dart`

```
endTurn() (line 1942)
├── Advance player index (next % players.length)
├── Check for turnsToSkip (library penalty)
├── Reset: isDiceRolled, isDoubleTurn, consecutiveDoubles
├── Clear dialog flags
├── Show turn-skipped dialog if needed
└── Schedule bot turn if in bot mode
```

### Dice Roll: Animation vs Logic
| Aspect | File | Details |
|--------|------|---------|
| **Animation** | `dice_roller.dart` | Visual 3D dice rolling using `flutter_animate` |
| **Logic** | `game_notifier.dart` | `rollDice()` → generates random numbers, handles doubles, triggers movement |

**Flow:**
```
User taps "ROLL" button (board_view.dart)
    ↓
dice_roller shows 2s animation
    ↓
game_notifier.rollDice() generates: d1, d2, total, isDouble
    ↓
_handleMovementRoll() applies: double rules, jail on 3 doubles
    ↓
_movePlayer() hops pawn tile-by-tile
    ↓
_handleTileArrival() triggers: question, card, or effect
```

### Question Dialog Flow
```
_triggerQuestion() (game_notifier.dart)
├── Select question by category + difficulty (mastery-based)
├── Create Completer<void> (async barrier)
├── Set showQuestionDialog: true
├── AWAIT completer.future  ← BLOCKS HERE
├── User clicks BİLDİN/BİLEMEDİN
│   └── answerQuestion() called
│       └── Completer completed
└── Continue → endTurn()
```

### Card Dialog Flow (Şans/Kader)
```
_drawCardAndApply() (game_notifier.dart)
├── Draw random card from deck
├── Create Completer<void>
├── Set showCardDialog: true
├── AWAIT completer.future
├── User closes dialog
├── closeCardDialog() applies effect
│   └── Completer completed
└── Continue → endTurn()
```

---

## 4. DATA FLOW ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                      │
│  (screens, dialogs, widgets)                                │
└───────────────────────────┬─────────────────────────────────┘
                            │ watches
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   STATE MANAGEMENT (Riverpod)               │
│  game_notifier.dart ← CORE BRAIN                            │
│  theme_notifier.dart                                         │
└───────────────────────────┬─────────────────────────────────┘
                            │ uses
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                           │
│  models/ (Player, Question, BoardTile, GameCard)            │
│  domain/repositories/ (interfaces)                          │
└───────────────────────────┬─────────────────────────────────┘
                            │ implements
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                            │
│  data/repositories/ (impl)                                  │
│  data/datasources/ (Firebase, JSON)                         │
│  data/mappers/ (DTO ↔ Domain)                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. KEY DESIGN PATTERNS

| Pattern | Usage |
|---------|-------|
| **Repository Pattern** | Domain interfaces vs Data implementations |
| **Mapper Pattern** | DTO ↔ Domain conversion (Firebase → App models) |
| **StateNotifier** | Immutable state with explicit updates |
| **Completer Barrier** | Async/await for dialog user responses |
| **Builder Pattern** | `GameState.copyWith()` for immutable updates |
| **Provider DI** | Riverpod for dependency injection |

---

## 6. GAME CONSTANTS (Balance)

| File | Key Values |
|------|------------|
| `game_constants.dart` | `easyStarReward: 1`, `mediumStarReward: 2`, `hardStarReward: 3`<br>`promotionBaseReward: 5`, `answersRequiredForPromotion: 3`<br>`jailPosition: 19`, `jailTurns: 2`<br>`hopAnimationDelay: 300ms`, `boardSize: 26` |

---

## 7. FILE REFERENCE INDEX

### Core Game Files (Most Important)
| File | Lines | Purpose |
|------|-------|---------|
| `game_notifier.dart` | ~2280 | Game state & logic brain |
| `board_view.dart` | ~700 | Main board UI |
| `modern_question_dialog.dart` | ~480 | Question dialog |
| `board_config.dart` | ~400 | Board tile definitions |
| `player.dart` | ~200 | Player model |

### Configuration Files
| File | Purpose |
|------|---------|
| `game_constants.dart` | Balance values |
| `motion_constants.dart` | Animation timing |
| `game_theme.dart` | Visual theme |

### Data Loading
| File | Purpose |
|------|---------|
| `question_repository_impl.dart` | Question loading |
| `game_cards.dart` | Event card decks |

---

**Report Generated:** `2026-02-01`
**Total Files:** `98 Dart files`
**Architecture:** Clean Architecture + Repository Pattern + Riverpod State Management
