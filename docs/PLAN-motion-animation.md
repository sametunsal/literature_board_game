# Motion & Animation Improvement Plan

> **Goal**: Make animations consistent, premium, and accessible across the board game.

---

## Top 6 Motion Moments (Priority Order)

| # | Moment | Current State | Impact |
|---|--------|---------------|--------|
| 1 | **Dialog open/close** | Inconsistent durations (300-700ms) | HIGH - Most frequent |
| 2 | **Pawn movement** | Works but variable timing | HIGH - Core gameplay |
| 3 | **Dice roll + reveal** | Custom animation exists | MEDIUM - Fun factor |
| 4 | **Main menu entry** | flutter_animate, mixed durations | MEDIUM - First impression |
| 5 | **Tile highlight/selection** | Basic or missing | MEDIUM - Feedback clarity |
| 6 | **Reward feedback** | Confetti exists, money pop inconsistent | LOW - Polish |

---

## Proposed Motion Utility File

**Path**: `lib/core/motion/motion_constants.dart`

### Durations
```
fast:     150ms  (micro-interactions, hover, press)
medium:   300ms  (standard transitions, dialogs)
slow:     500ms  (emphasis, page transitions)

// Specific
dice:     800ms  (roll animation)
pawn:     400ms  (tile-to-tile movement)
dialog:   350ms  (open/close)
confetti: 2000ms (celebration duration)
```

### Curves
```
standard:     Curves.easeOutCubic    (most UI)
emphasized:   Curves.easeOutBack     (dialogs, pop-in)
decelerate:   Curves.decelerate      (settling, dice stop)
spring:       Curves.elasticOut      (bouncy feedback)
```

---

## Migration Order (5 Phases)

1. **Create `motion_constants.dart`** - Define all constants
2. **Dialogs** - pause_dialog, game_over_dialog, question_dialog
3. **Pawn + Dice** - board_view, dice_roller
4. **Main Menu** - main_menu_screen, setup_screen
5. **Tiles + Rewards** - enhanced_tile_widget, score effects

---

## Files to Touch First

| Phase | Files |
|-------|-------|
| 1 | `lib/core/motion/motion_constants.dart` [NEW] |
| 2 | `lib/widgets/pause_dialog.dart`, `game_over_dialog.dart`, `modern_question_dialog.dart` |
| 3 | `lib/widgets/board_view.dart`, `lib/widgets/dice_roller.dart` |
| 4 | `lib/widgets/main_menu_screen.dart`, `setup_screen.dart` |
| 5 | `lib/widgets/enhanced_tile_widget.dart` |

---

## Default Values

| Token | Duration | Curve | Use Case |
|-------|----------|-------|----------|
| `MotionDurations.fast` | 150ms | - | Button press, hover |
| `MotionDurations.medium` | 300ms | `easeOutCubic` | Default transitions |
| `MotionDurations.slow` | 500ms | `easeOutCubic` | Page/screen transitions |
| `MotionDurations.dialog` | 350ms | `easeOutBack` | Dialog open/close |
| `MotionDurations.pawn` | 400ms | `easeOutCubic` | Pawn hop animation |
| `MotionDurations.dice` | 800ms | `decelerate` | Dice roll + settle |

---

## QA Checklist

- [ ] No jank on low-end devices (test 60fps)
- [ ] No overlapping animations (cancel previous before starting new)
- [ ] Reduce motion support (`MediaQuery.disableAnimations`)
- [ ] Consistent feel across all dialogs
- [ ] Pawn movement doesn't block input
- [ ] Dice animation completes before allowing next action

---

## Risks & Mitigation

| Risk | Mitigation |
|------|------------|
| Breaking existing animations | Incremental migration, test each phase |
| Performance regression | Profile before/after with DevTools |
| Accessibility | Add `reduceMotion` checks |
| flutter_animate conflicts | Use constants alongside, don't fight the library |

---

## Testing Strategy

1. **Visual QA**: Record before/after videos of each motion moment
2. **Performance**: Use Flutter DevTools timeline to check for dropped frames
3. **Accessibility**: Test with system "Reduce motion" enabled
4. **Regression**: Verify no animation breaks existing gameplay flow

---

## Next Steps

1. Approve this plan
2. Create `motion_constants.dart` with duration/curve definitions
3. Migrate dialogs first (highest visibility, easiest to test)
4. Iterate through remaining phases
