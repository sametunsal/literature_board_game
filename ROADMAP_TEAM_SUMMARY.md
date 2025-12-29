# Literature Board Game - Roadmap Summary (Team Planning)

## Quick Overview

**Framework**: Flutter with Riverpod  
**Current Completion**: ~60%  
**Project Status**: Active Development  
**MVP Timeline**: 3-4 weeks (optimistic), 5-7 weeks (realistic)

---

## Development Phases at a Glance

```
Phase 0: Foundation          ✅ COMPLETE (100%)
Phase 1: Core UI             ✅ COMPLETE (100%)
Phase 2: Game Engine         ✅ COMPLETE (100%)
Phase 3: Gameplay Mechanics  ⏳ IN PROGRESS (20%) ← CRITICAL PATH
Phase 4: UI Improvements     ⏳ PENDING (0%)
Phase 5: Polish & Enhance    ⏳ PENDING (0%)
Phase 6: Testing & QA        ⏳ PENDING (0%)
Phase 7: Deployment          ⏳ PENDING (0%)
```

---

## Phase-by-Phase Breakdown

### Phase 0: Foundation & Infrastructure ✅ COMPLETE
**Status**: Done  
**Duration**: Completed  
**What's Done**:
- Flutter project setup (iOS, Android, Web, Desktop)
- Riverpod state management configured
- Project structure established
- Dependencies and build configuration ready

---

### Phase 1: Core UI Components ✅ COMPLETE
**Status**: Done  
**Duration**: Completed  
**What's Done**:
- 40-tile board layout (horizontal strip + square option)
- Animated player token movement (600ms smooth animation)
- Dice widget with rolling animation
- Player info panels (stars, position, status)
- All dialog widgets (question, card, purchase, turn end)

**Key Files**:
- `lib/views/board_view.dart`
- `lib/widgets/board_strip_widget.dart`
- `lib/widgets/enhanced_dice_widget.dart`
- `lib/widgets/enhanced_player_info_panel.dart`

---

### Phase 2: Game Engine & State Management ✅ COMPLETE
**Status**: Done  
**Duration**: Completed  
**What's Done**:
- All data models (Player, Tile, Question, Card, TurnResult, TurnHistory)
- Complete state management with GameState and GameNotifier
- Turn phase state machine (7 phases)
- Double dice tracking and Library Watch logic
- Bankruptcy detection
- Turn validation and replay engine
- Turn summary system with generateTurnSummary()

**Key Files**:
- `lib/providers/game_provider.dart`
- `lib/models/` (all models)
- `lib/engine/turn_history_validator.dart`
- `lib/utils/turn_summary_generator.dart`
- `lib/widgets/turn_summary_overlay.dart`

---

### Phase 3: Strategic Gameplay Mechanics ⏳ IN PROGRESS (20%)
**Status**: **CRITICAL PATH - Must Complete for MVP**  
**Estimated Duration**: 2-3 weeks  
**What's Done** (20%):
- ✅ Question system (display, selection, rewards)
- ✅ Some special tiles (BAŞLANGIÇ, KÜTÜPHANE NÖBETİ, İFLAS RİSKİ)
- ✅ Card data (ŞANS and KADER decks)
- ✅ Dialog widgets exist (card, purchase)

**Remaining Tasks** (80%):

#### 3.1 Question Timer (1-2 days)
- [ ] Implement countdown timer logic
- [ ] Auto-fail on timeout
- [ ] Add visual warning (<10 seconds remaining)

#### 3.2 Card Drawing Logic (2-3 days) ⭐ CRITICAL
- [ ] Implement `drawCard()` method
- [ ] Random selection from ŞANS/KADER decks
- [ ] State tracking for drawn card
- [ ] Trigger card dialog

#### 3.3 Card Effects (5-7 days) ⭐ CRITICAL
- [ ] Personal effects (gainStars, loseStars, skipNextTax, freeTurn, easyQuestionNext)
- [ ] Global effects (allPlayersGainStars, allPlayersLoseStars, taxWaiver, allPlayersEasyQuestion)
- [ ] Targeted effects (publisherOwnersLose, richPlayerPays)
- [ ] Effect logging
- [ ] Bankruptcy handling

#### 3.4 Card Dialog Integration (1-2 days)
- [ ] Connect dialog to GameView
- [ ] Link dismissal to effect application
- [ ] Test ŞANS and KADER display

#### 3.5 Copyright Purchase (3-4 days) ⭐ CRITICAL
- [ ] Implement `purchaseCopyright()` method
- [ ] Ownership tracking in Player model
- [ ] Star deduction and validation
- [ ] Transaction logging
- [ ] Tile owner field

#### 3.6 Rent Collection (2-3 days) ⭐ CRITICAL
- [ ] Check tile ownership on landing
- [ ] Calculate and transfer rent
- [ ] Bankruptcy handling
- [ ] Special cases (owner in Library Watch)

#### 3.7 Remaining Special Tiles (2-3 days)
- [ ] YAZARLIK OKULU (bonus question)
- [ ] DE EĞİTİM VAKFI (bonus stars)
- [ ] GELİR VERGİSİ (tax payment)
- [ ] YAZARLIK VERGİSİ (tax payment)

---

### Phase 4: UI Improvements & Visual Feedback ⏳ PENDING (0%)
**Status**: High Priority (after Phase 3)  
**Estimated Duration**: 1 week  
**Tasks**:

#### 4.1 Game Log UI (1-2 days)
- [ ] Re-enable GameLogWidget
- [ ] Add to GameView layout
- [ ] Auto-scroll functionality
- [ ] Message styling

#### 4.2 Tile Ownership Display (2-3 days)
- [ ] Owner color indicator on tiles
- [ ] Owner name/initials display
- [ ] Visual differentiation for owned tiles

#### 4.3 Bankruptcy Visuals (1-2 days)
- [ ] Grayscale/dimmed effect for bankrupt players
- [ ] "İFLAS OLDU" badge
- [ ] Remove from turn indicators
- [ ] Bankruptcy animation

#### 4.4 Turn Phase Indicators (1-2 days)
- [ ] Phase indicator in UI
- [ ] Icons/text for each phase
- [ ] Phase transition animations

---

### Phase 5: Polish & Enhancements ⏳ PENDING (0%)
**Status**: Medium Priority (nice-to-have)  
**Estimated Duration**: 1-2 weeks  
**Tasks**:

#### 5.1 Restart Game (1 day)
- [ ] Restart button on game over screen
- [ ] State reset logic
- [ ] Confirmation dialog

#### 5.2 Sound Effects (3-5 days)
- [ ] Audio package integration
- [ ] Sound files preparation
- [ ] Sound manager implementation
- [ ] Settings toggle

#### 5.3 Save/Load Game (5-7 days)
- [ ] Persistence package setup
- [ ] Model serialization
- [ ] Save/load methods
- [ ] UI integration

#### 5.4 Square Board Toggle (2-3 days)
- [ ] Layout toggle button
- [ ] Settings integration
- [ ] Testing on all layouts

#### 5.5 Settings Screen (2-3 days)
- [ ] Settings widget creation
- [ ] Sound toggle
- [ ] Layout preference
- [ ] Timer duration options
- [ ] Animation speed options

#### 5.6 Enhanced Animations (3-5 days)
- [ ] Card draw animation
- [ ] Copyright purchase animation
- [ ] Rent payment animation
- [ ] Bankruptcy animation
- [ ] Winner celebration
- [ ] Improved dice animation

---

### Phase 6: Testing & Quality Assurance ⏳ PENDING (0%)
**Status**: High Priority (before release)  
**Estimated Duration**: 1 week  
**Tasks**:

#### 6.1 Unit Tests (2-3 days)
- [ ] Dice rolling logic
- [ ] Player movement
- [ ] Turn switching
- [ ] Card effects
- [ ] Copyright purchase
- [ ] Rent collection
- [ ] Bankruptcy detection

#### 6.2 Widget Tests (2-3 days)
- [ ] Tile widgets
- [ ] Player info panels
- [ ] Dialogs
- [ ] Dice widget
- [ ] Game log
- [ ] Turn summary

#### 6.3 Integration Tests (2-3 days)
- [ ] Complete game flow
- [ ] Multiplayer scenarios
- [ ] Edge cases (bankruptcy, all tiles owned)
- [ ] Save/load functionality

#### 6.4 Bug Fixes (Ongoing)
- [ ] Fix reported bugs
- [ ] Performance optimization
- [ ] Error handling improvements

---

### Phase 7: Deployment & Release ⏳ PENDING (0%)
**Status**: Final Phase  
**Estimated Duration**: 1 week  
**Tasks**:

#### 7.1 Build Configuration (2-3 days)
- [ ] iOS release build
- [ ] Android release build
- [ ] Web release build
- [ ] Desktop release builds
- [ ] App signing
- [ ] Icons and splash screens

#### 7.2 App Store Deployment (2-3 days)
- [ ] Apple Developer setup
- [ ] Screenshots and descriptions
- [ ] App Store Connect listing
- [ ] Submission

#### 7.3 Google Play Deployment (2-3 days)
- [ ] Google Play Developer setup
- [ ] Screenshots and descriptions
- [ ] Play Console listing
- [ ] Submission

#### 7.4 Web Deployment (1 day)
- [ ] Build web release
- [ ] Hosting setup
- [ ] Domain configuration

#### 7.5 Documentation & Marketing (2-3 days)
- [ ] User documentation
- [ ] Tutorial videos
- [ ] Marketing materials
- [ ] Website/landing page

---

## Critical Path to Playable MVP

### Must Complete First (3-4 weeks):

```
Week 1: Core Card System
├── Day 1-2:   Question Timer
├── Day 3-5:   Card Drawing Logic
└── Day 6-7:   Start Card Effects

Week 2: Complete Card System
├── Day 8-12:  Finish Card Effects (all types)
├── Day 13-14: Card Dialog Integration

Week 3: Copyright System
├── Day 15-18: Copyright Purchase Flow
├── Day 19-21: Rent/Copyright Collection
└── Day 21-22: Remaining Special Tiles

Week 4: Testing & Refinement
├── Day 23-25: Integration Testing
├── Day 26-27: Bug Fixes
└── Day 28:    MVP Ready
```

### What Defines "Playable MVP":
- ✅ Players can draw and use ŞANS and KADER cards
- ✅ All card effects work correctly
- ✅ Players can purchase copyrights
- ✅ Players pay rent when landing on owned tiles
- ✅ All special tiles implemented
- ✅ Question timer functional
- ✅ Complete game loop playable (start to bankruptcy/win)

---

## Detailed Feature Status

### Core Mechanics ✅
- ✅ Dice rolling and animation
- ✅ Player movement with animation
- ✅ Turn switching
- ✅ Turn phases (7-phase state machine)
- ✅ Double dice and extra turns
- ✅ Library Watch (skip 2 turns)
- ✅ Bankruptcy detection

### Question System ⚠️ Partial
- ✅ Question display and selection
- ✅ Answer feedback
- ✅ Star rewards
- ❌ Question timer
- ❌ Easy question mode

### Card System ❌ Critical Missing
- ✅ Card data (decks ready)
- ✅ Card dialog widget
- ❌ Card drawing logic
- ❌ Card effects (all types)
- ❌ Card integration

### Copyright System ❌ Critical Missing
- ✅ Tile data and fees
- ✅ Purchase dialog widget
- ❌ Purchase logic
- ❌ Ownership tracking
- ❌ Rent collection
- ❌ Owner display

### Special Tiles ⚠️ Partial
- ✅ BAŞLANGIÇ (Start) - passing bonus
- ✅ KÜTÜPHANE NÖBETİ - skip turns
- ✅ İFLAS RİSKİ - lose 50% stars
- ✅ İMZA GÜNÜ - no action
- ❌ YAZARLIK OKULU - bonus question
- ❌ DE EĞİTİM VAKFI - bonus stars
- ❌ GELİR VERGİSİ - tax
- ❌ YAZARLIK VERGİSİ - tax

### UI Components ✅ (mostly)
- ✅ Board layout
- ✅ Player tokens
- ✅ Dice widget
- ✅ Player info panels
- ✅ Question dialog
- ✅ Turn summary overlay
- ⚠️ Card dialog (needs integration)
- ⚠️ Purchase dialog (needs integration)
- ❌ Game log (needs integration)
- ❌ Settings screen

### Advanced Features ✅
- ✅ Turn history tracking
- ✅ Turn transcripts
- ✅ Turn summary generation
- ✅ Debug timeline
- ✅ Turn replay engine
- ✅ Turn validator

### Polish Features ❌
- ❌ Sound effects
- ❌ Save/load game
- ❌ Restart game
- ❌ Settings screen
- ❌ Enhanced animations

### Testing ❌
- ❌ Unit tests
- ❌ Widget tests
- ❌ Integration tests

---

## Timeline Scenarios

### Optimistic (3-4 weeks)
- Week 1: Phase 3 core mechanics (cards, copyright, rent)
- Week 2: Complete Phase 3 (special tiles, timer)
- Week 3: Phase 4 UI improvements (game log, ownership display)
- Week 4: Basic testing + MVP release

**MVP Ready**: End of Week 4

### Realistic (5-7 weeks)
- Week 1-2: Phase 3 core mechanics (may uncover edge cases)
- Week 3: Complete Phase 3
- Week 4: Phase 4 UI improvements
- Week 5: Phase 5 polish (selected features)
- Week 6: Phase 6 testing (comprehensive)
- Week 7: Phase 7 deployment preparation

**Full Release**: End of Week 7

### Conservative (8-10 weeks)
- Weeks 1-2: Phase 3 with buffer
- Weeks 3-4: Phase 4-5 with refinement
- Weeks 5-6: Phase 6 comprehensive testing
- Weeks 7-8: Phase 7 deployment + documentation
- Weeks 9-10: Marketing and user feedback collection

**Polished Release**: End of Week 10

---

## Immediate Action Items (This Week)

### Priority 1 - Start Immediately:
1. **Day 1-2**: Implement question timer
   - File: `lib/providers/game_provider.dart`
   - Add countdown logic
   - Connect to QuestionDialog

2. **Day 3-5**: Card drawing logic
   - File: `lib/providers/game_provider.dart`
   - Method: `drawCard()`
   - Test with ŞANS and KADER tiles

### Priority 2 - After Card Drawing:
3. **Day 6-7**: Card effects (start with personal effects)
   - File: `lib/providers/game_provider.dart`
   - Method: `applyCardEffect()`
   - Focus on gainStars, loseStars first

### Priority 3 - Next Week:
4. **Day 8-10**: Complete card effects (global and targeted)
5. **Day 11-12**: Card dialog integration
6. **Day 13-14**: Start copyright purchase flow

---

## Risk Assessment

### High Risk:
- **Complex card effects** (global, targeted) may have edge cases
  - *Mitigation*: Test thoroughly, document clearly
- **Economic balance** in copyright system may need tuning
  - *Mitigation*: Playtesting, adjustable parameters

### Medium Risk:
- **Save/Load system** complexity
  - *Mitigation*: Use proven packages, incremental implementation
- **Performance** with many turns and 4 players
  - *Mitigation*: Efficient data structures, lazy loading

### Low Risk:
- UI components (most already working)
- Basic animations (token movement smooth)
- State management (Riverpod is mature)

---

## Team Recommendations

### For Single Developer:
- Focus 100% on Phase 3 (Core Gameplay)
- Use existing widgets where possible
- Defer Phase 5 polish until after testing
- Consider crowdsourcing beta testing

### For Small Team (2-3 people):
- **Dev 1**: Phase 3 core mechanics (cards, copyright)
- **Dev 2**: Phase 4 UI improvements + integration
- **Dev 3**: Phase 6 testing + bug fixes

### For Full Team (4-5 people):
- **Dev 1 (Lead)**: Phase 3 architecture and complex logic
- **Dev 2**: UI/UX - Phase 4 and 5 polish
- **Dev 3**: Testing - Phase 6 comprehensive testing
- **Dev 4**: DevOps - Phase 7 deployment and CI/CD
- **Dev 5**: Documentation - User docs and tutorials

---

## Success Metrics

### Development:
- Features completed per sprint
- Bug count and resolution time
- Code coverage percentage

### Quality:
- Critical bugs: 0 at release
- App crash rate: <1%
- Performance: <60fps on all devices

### User (Post-Launch):
- Download count
- Session duration (target: 20-40 min)
- Retention rate (Day 1, 7, 30)
- App store rating (target: 4.5+ stars)

---

## Quick Reference Commands

### Development:
```bash
# Run development server
flutter run

# Run in release mode (for testing)
flutter run --release

# Run tests
flutter test

# Run integration tests
flutter test integration_test/

# Build for platforms
flutter build ios
flutter build apk
flutter build web
```

### Hot Reload:
```bash
# Press 'r' in terminal for hot reload
# Press 'R' for hot restart
# Press 'q' to quit
```

---

## Key Files Reference

### Core Game Logic:
- `lib/providers/game_provider.dart` - Main game state
- `lib/providers/card_provider.dart` - Card decks
- `lib/providers/question_provider.dart` - Questions
- `lib/providers/tile_provider.dart` - Board tiles

### Models:
- `lib/models/player.dart` - Player state
- `lib/models/tile.dart` - Tile data
- `lib/models/card.dart` - Card definitions
- `lib/models/turn_result.dart` - Turn tracking
- `lib/models/turn_history.dart` - Game history

### UI Components:
- `lib/views/game_view.dart` - Main game screen
- `lib/views/board_view.dart` - Board display
- `lib/widgets/board_strip_widget.dart` - Animated board
- `lib/widgets/enhanced_player_info_panel.dart` - Player info
- `lib/widgets/question_dialog.dart` - Question display
- `lib/widgets/card_dialog.dart` - Card display
- `lib/widgets/turn_summary_overlay.dart` - Turn summary

### Utilities:
- `lib/utils/turn_summary_generator.dart` - Summary generation
- `lib/engine/turn_history_validator.dart` - Turn validation

---

## Summary

**Current State**: Solid foundation (60% complete) with excellent UI infrastructure and state management.

**Critical Path**: Phase 3 (Strategic Gameplay Mechanics) - cards, copyright, rent system.

**Timeline**: Playable MVP in 3-4 weeks, full release in 5-7 weeks.

**Focus**: Prioritize Phase 3 tasks to achieve playable game loop. Phase 4-7 are quality-of-life enhancements.

**Next Action**: Start with question timer (Day 1-2), then card drawing logic (Day 3-5).

---

**Document Version**: 1.0  
**Last Updated**: 2025-12-29  
**Status**: Active Development  
**Milestone**: Complete Phase 3 Core Gameplay Mechanics
