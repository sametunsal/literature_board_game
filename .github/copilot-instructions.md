# Edebiyat Oyunu (Literature Board Game) - AI Coding Guide

## Project Overview
A Flutter-based educational board game (similar to Monopoly) featuring Turkish literature themes. Players move around a 40-tile board, answer questions about literature (AYT/KPSS), collect stars (money), and purchase book copyrights. Supports 1 human + 3 bot players with automated turn management.

## Critical Architecture

### State Management: Riverpod + Phase-Based Turn System
The game uses **deterministic phase transitions** where each turn progresses through explicit phases:
- `TurnPhase` enum (see [lib/models/turn_phase.dart](../lib/models/turn_phase.dart)) defines: `start → diceRolled → moved → tileResolved → questionWaiting/cardApplied/taxResolved → turnEnded`
- **Core orchestration method**: `playTurn()` in [lib/providers/game_provider.dart](../lib/providers/game_provider.dart#L281)
  - NEVER modify game logic directly in UI - all state transitions happen via `playTurn()`
  - Each call advances exactly ONE phase based on current state
  - UI asks `getAutoAdvanceDirective()` to determine if/when to auto-advance (bot vs human logic)

### Player Types: Human vs Bot
- `PlayerType` enum ([lib/models/player_type.dart](../lib/models/player_type.dart)): `human` | `bot`
- Bot behavior is **UI-side automation only** - no gameplay logic changes
- Bots auto-advance through phases with delays (see [PHASE_5_1_DUMMY_BOT_ORCHESTRATION.md](../PHASE_5_1_DUMMY_BOT_ORCHESTRATION.md))
  - Always answer questions incorrectly (70% correct rate)
  - Always decline purchases
  - Dialogs hidden for bots (return `SizedBox.shrink()`)

### Board Layout: 40-Tile Counter-Clockwise System
- **Critical**: Board uses 0-39 indexing, counter-clockwise from tile 0 (BAŞLANGIÇ/START at bottom-left)
- Movement calculation: `(currentPosition + diceTotal) % 40` (see [lib/providers/game_provider.dart](../lib/providers/game_provider.dart#L534))
- Tiles defined in [lib/providers/tile_provider.dart](../lib/providers/tile_provider.dart) - DO NOT modify without checking [GAME_DESIGN_SPECIFICATION.md](../GAME_DESIGN_SPECIFICATION.md)

## Essential Development Workflows

### Running the App
```powershell
# Install dependencies (only needed after pubspec.yaml changes)
flutter pub get

# Run on Android emulator (Pixel 9)
flutter run -d emulator-5554

# Hot reload (preserves state) - for UI changes
# Press 'r' in running terminal

# Hot restart (resets state) - for logic changes or new animations
# Press 'R' in running terminal
```
See [HOT_RELOAD_RESTART_GUIDE.md](../HOT_RELOAD_RESTART_GUIDE.md) for detailed guidance on when to use hot reload vs restart.

### Code Formatting
**Always use the Dart formatter, never manual formatting**:
```powershell
# Format all Dart files
dart format .

# Format specific file
dart format lib/providers/game_provider.dart
```

### Testing on Emulator
- Default emulator: Pixel 9 (`emulator-5554`) running Android 16 API 36
- Set landscape orientation in [lib/main.dart](../lib/main.dart#L17) via `SystemChrome.setPreferredOrientations()`
- See [ANDROID_EMULATOR_SETUP.md](../ANDROID_EMULATOR_SETUP.md) for troubleshooting

## Project-Specific Conventions

### Game Constants
**NEVER use magic numbers** - all constants defined in [lib/constants/game_constants.dart](../lib/constants/game_constants.dart):
```dart
GameConstants.boardSize          // 40
GameConstants.passStartReward    // 50 stars
GameConstants.libraryWatchTurns  // 2 turns
GameConstants.maxDoubleDice      // 3 (triggers library watch)
```

### Logging Boundaries (Critical!)
Two distinct logging categories in `game_provider.dart`:
1. **GAMEPLAY LOGS**: Game state changes (dice rolls, star gains/losses, bankruptcy)
   - Use: `state = state.withLogMessage('message')`
2. **UI FEEDBACK LOGS**: User-facing information (card descriptions, questions)
   - Separate from `TurnResult` which provides structured UI feedback

### Turn History & Transcripts
- `TurnHistory` tracks multi-turn statistics (see [lib/models/turn_history.dart](../lib/models/turn_history.dart))
- `TurnTranscript` captures single-turn events for summary overlay
- `TurnSummaryGenerator` ([lib/utils/turn_summary_generator.dart](../lib/utils/turn_summary_generator.dart)) creates turn summaries from transcripts

### Question System
- Questions loaded from [assets/data/questions.json](../assets/data/questions.json)
- `QuestionRepository` ([lib/repositories/question_repository.dart](../lib/repositories/question_repository.dart)) provides random questions by category
- Categories: `benKimim`, `eserKarakter`, `edebiBilgi`, `sanatAkimi` (see [lib/models/question.dart](../lib/models/question.dart))

## Common Patterns

### Adding New Card Effects
1. Define card in `generateSansCards()` or `generateKaderCards()` in [lib/providers/card_provider.dart](../lib/providers/card_provider.dart)
2. Add effect type to `CardEffect` enum if needed
3. Implement in `_applyCardEffect()` in [lib/providers/game_provider.dart](../lib/providers/game_provider.dart#L950)
4. Effects use helper methods: `_applyGainStars()`, `_applyLoseStars()`, `_applySkipNextTax()`, etc.

### Modifying Turn Flow
1. **DO**: Update phase transitions in `playTurn()` switch statement
2. **DO**: Add phase to `TurnPhase` enum if needed
3. **DO**: Update `getAutoAdvanceDirective()` to handle new phase
4. **DON'T**: Create parallel state machines or bypass `playTurn()`
5. **DON'T**: Add delays in game logic (delays are UI-side only in [lib/views/game_view.dart](../lib/views/game_view.dart))

### Creating UI Dialogs
Follow pattern from existing dialogs ([lib/widgets/question_dialog.dart](../lib/widgets/question_dialog.dart), [lib/widgets/card_dialog.dart](../lib/widgets/card_dialog.dart)):
```dart
// 1. Check if bot player - return empty widget
if (currentPlayer?.type == PlayerType.bot) {
  Future.delayed(const Duration(milliseconds: 500), () {
    if (!mounted) return;
    // Bot auto-action here
  });
  return const SizedBox.shrink();
}

// 2. Disable buttons when phase != waiting phase
final canInteract = turnPhase == TurnPhase.questionWaiting;

// 3. Use mounted check before ref.read() in callbacks
```

## Key Files Reference
- **Game Logic**: [lib/providers/game_provider.dart](../lib/providers/game_provider.dart) (1548 lines - core game engine)
- **Board Configuration**: [lib/providers/tile_provider.dart](../lib/providers/tile_provider.dart) (40-tile setup)
- **Main Game UI**: [lib/views/game_view.dart](../lib/views/game_view.dart) (orchestration listener)
- **Design Spec**: [GAME_DESIGN_SPECIFICATION.md](../GAME_DESIGN_SPECIFICATION.md) (826 lines - game rules)

## Integration Points
- **Questions**: Loaded from JSON → `QuestionRepository` → `game_provider.drawQuestion()`
- **Cards**: Generated programmatically in `card_provider.dart` → shuffled at game start
- **Player Initialization**: [lib/main.dart](../lib/main.dart#L106) `_generatePlayers()` creates 1 human + 3 bots

## Common Pitfalls
1. **Off-by-one errors**: Board is 0-39, not 1-40
2. **Phase progression**: Always call `playTurn()` to advance, never set `turnPhase` directly in UI
3. **Bot checks**: Always check `PlayerType` before showing dialogs or waiting for input
4. **Mounted checks**: Always verify `mounted` before using `ref.read()` in delayed callbacks
5. **Hot restart needed**: New animation controllers or major state changes require 'R', not 'r'
