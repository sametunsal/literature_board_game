> # CLEAN-ROOM PROTOTYPE — READ THIS FIRST
>
> **This is a brand-new experimental repository.**
> - **Do NOT** read or modify the existing `literature_board_game` / Edebina repository.
> - **Do NOT** import files from the old project unless explicitly asked.
> - **Do NOT** assume the old architecture is available.
> - **Build this as a clean-room prototype.**
>
> **Goal:** Create a new Flutter/Dart board game prototype inspired by the design goals described below, but with a clean architecture from scratch.
>
> **Important:**
> - Keep the **first implementation minimal.**
> - Prefer a **working vertical slice** over a huge incomplete system.
> - Use small, testable modules.
> - Add tests as features are added.
> - Commit in small steps.
> - Do **not** over-engineer multiplayer, persistence, audio, or animations in the first pass.
>
> The full spec below is the **complete reference** for later phases. The **First Pass Scope** (next section) defines what to build right now.

---

## FIRST PASS SCOPE — minimal vertical slice (build THIS first)

Before anything in §1–29, deliver one small, fully-working, end-to-end game loop. No polish, no audio, no persistence, no bot. Everything below can be thrown away later.

- **Players:** 2 only, hot-seat. No avatar/color picker — just "Oyuncu 1 / Oyuncu 2".
- **Board:** the 26-tile perimeter from §4, but render only: **start**, **category (book)**, **chance**, **fate**, **library**. Tiles: simple colored squares with a label (no strips, no ownership badges).
- **Dice:** plain two-D6 sum, a single tappable button, **temporary 2D face** (just show the number). No 3D CustomPainter yet.
- **Pawn:** a plain colored circle per player.
- **Movement:** step-by-step hop, board wrap, **passing-start +5**. No hop animation needed — instant or simple move is fine.
- **Turn order:** skip the dice tournament; player 1 goes first (or a single shared roll).
- **Question:** basic dialog — question text + 4 options, tap to answer, correct/wrong highlight, reward easy3/medium5/hard8 by tile difficulty. Difficulty = tile difficulty (skip mastery-driven selection for now).
- **Cards:** implement **only `moneyChange`** effect for chance/fate; other 7 effects stubbed to "no effect" with a log.
- **Library:** `turnsToSkip = 2`, skip next 2 turns. No double-zar jail rule yet.
- **Doubles:** ignored in the first pass (no re-roll, no jail-on-3).
- **Mastery / publishing / royalties / shop / Meşk / streak / bot:** **out of scope for pass 1.**
- **Win condition (pass 1 only):** **first player to 30 Akçe** wins. (The real 3-Cilt rule comes in a later pass.)
- **Theme/UI:** default Flutter theme, landscape board, minimal HUD showing both players' Akçe + position + whose turn it is.

**Pass 1 "done":** a full 2-player game runs start → moves → questions → cards → a winner at 30 Akçe, with `flutter analyze` clean and a few unit tests on movement + reward math. Commit each step.

---

# FABLE REBUILD SPEC — "Edebina" Turkish Literature Board Game

> **Purpose:** This is a complete, self-contained specification for rebuilding this game **from scratch** in **Flutter/Dart**. Read this entire document before writing any code. It captures the *intended, cleaned-up* design (the original codebase has several bugs/inconsistencies; the "Discrepancies & Decisions" section tells you which to fix vs. preserve). The **First Pass Scope** above is what to build first; the rest is the long-term reference.

---

## 0. Your Task

Build **Edebina** — a local multiplayer (hot-seat + optional bot) mobile board game that fuses **Monopoly's property economy**, **Trivial-Pursuit-style quiz mechanics**, and **Turkish literature** into one cozy, strategic experience. Players move around a 26-tile rectangular board, answer literature questions to earn currency, **acquire and publish books** (the property layer), draw Şans/Kader (Chance/Fate) cards, and race to publish 3 "Cilt" (bound-edition) books to win.

**Target platforms:** Android & iOS (Flutter). Phone-first, portrait for menus, **landscape** for the game board. No backend / no Firebase — all data is local JSON.

**Tone:** "Cozy + strategic." A warm Ottoman coffeehouse (Kıraathane) aesthetic with dark-teal/leather/gold accents. Relaxing motion, never abrupt.

---

## 1. Tech Stack

| Layer | Choice |
|---|---|
| Framework | **Flutter** (Dart SDK `^3.10.4`) |
| State management | **flutter_riverpod** `^2.4.9` (use `StateNotifier<GameState>` for the core game) |
| Routing | Plain `Navigator` pushes + a phase-driven home router |
| Fonts | **google_fonts** `^6.1.0` |
| Icons | **font_awesome_flutter** `^10.6.0` + Material icons |
| Animations | **flutter_animate** `^4.5.0`, **shimmer** `^3.0.0`, custom `CustomPainter` (NO Lottie for dice) |
| Effects | **confetti** `^0.7.0` (optional; victory uses a custom particle painter) |
| Audio | **audioplayers** `^6.1.0` |
| Misc | **uuid** `^4.3.3`, **auto_size_text** `^3.0.0`, **shared_preferences** `^2.2.2`, **equatable** `^2.0.8`, **http** `^1.2.1` |
| Testing | **flutter_test**, **mocktail** `^1.0.0`, **fake_async** |
| Lints | **flutter_lints** `^6.0.0` |

**Do NOT add** Firebase, Lottie runtime usage, or any backend. Keep the dependency list lean.

---

## 2. Architecture (Clean Architecture, 4 layers)

```
PRESENTATION  → screens, widgets, dialogs, Riverpod notifiers
PROVIDERS     → GameNotifier (StateNotifier<GameState>), ThemeNotifier, DialogProvider, repository providers, AppBootstrap
DOMAIN        → repository INTERFACES (pure Dart), no Flutter
DATA          → datasources (JSON loaders), models/DTOs, mappers, repository IMPLEMENTATIONS
CORE          → services (movement, dice, economy, question-flow, turn-order, win, bot, card-effect, book-progression), constants, theme, motion, managers (audio), utils (board topology/layout, logger)
```

**Dependency rule:** outer layers depend on inner; `domain` depends on nothing (pure Dart). `data` implements `domain` interfaces. `core/services` hold the pure game rules (no Flutter). `providers` orchestrates `core/services` + `data` repositories and exposes state to `presentation`.

> ⚠️ The original has a messy split (`models/` AND `domain/` both exist with overlapping entities). For the rebuild, **unify**: keep one set of domain entities under `lib/models/` (immutable, with `copyWith`, `fromJson`/`toJson`). Do not duplicate.

### Recommended folder layout
```
lib/
  main.dart
  core/
    constants/game_constants.dart
    managers/audio_manager.dart
    motion/motion_constants.dart
    theme/  game_theme.dart, theme_tokens.dart
    utils/  board_topology.dart, board_layout_config.dart, board_layout_helper.dart, logger.dart, question_line_estimator.dart
    services/ movement_service.dart, dice_service.dart, economy_service.dart, question_flow_service.dart,
              turn_order_service.dart, win_condition_service.dart, bot_controller.dart, card_effect_service.dart,
              book_progression_service.dart, board_book_lookup_service.dart
  data/
    book_config.dart, board_config.dart, game_cards.dart
    datasources/ questions_datasource.dart, theme_datasource.dart
    repositories/ question_repository_impl.dart, quote_repository.dart
  models/
    board_tile.dart, book.dart, book_level.dart, book_ownership.dart, difficulty.dart,
    game_card.dart, game_enums.dart, player.dart, question.dart, quote.dart, tile_type.dart
  providers/
    app_bootstrap.dart, game_notifier.dart, dialog_provider.dart, theme_notifier.dart, repository_providers.dart
  services/streak_service.dart
  presentation/
    screens/ splash_screen.dart, main_menu_screen.dart, setup_screen.dart, victory_screen.dart, collection_screen.dart, settings_screen.dart
    widgets/
      board_view.dart
      board/ board_layout.dart, tile_grid.dart, tile_widget.dart, enhanced_tile_widget.dart, center_area.dart,
            center_dice_roll_overlay.dart, dice_roll_three_view.dart, effects_overlay.dart, pawn_manager.dart,
            player_hud.dart, player_hud_manager.dart, board_visual_constants.dart
      dice_roller.dart, pawn_widget.dart, player_scoreboard.dart, game_log.dart, flying_star.dart, reward_toast.dart
      common/ game_button.dart, scholar_button.dart, bouncing_button.dart, game_dialog.dart, ottoman_background.dart
      animated_question_card.dart
    theme/ card_visual_theme.dart
    dialogs/ card_dialog.dart, kiraathane_dialog.dart, shop_dialog.dart, notification_dialogs.dart, pause_dialog.dart, settings_dialog.dart
assets/
  images/wooden_table_bg.png
  data/ questions.json, literary_quotes.json
  audio/ (see §16)
  app_icon.png
```

---

## 3. Concept & Theme

- **High concept:** An Ottoman coffeehouse where you explore Turkish literature with friends. Acquire books, publish them (Telif→Baskı→Cilt), answer questions to earn currency, dodge Kader cards, and become the library's master.
- **Players:** 2–6, hot-seat on one device, plus an **optional Bot mode** (autoplays turns).
- **Session length:** ~15–25 minutes.
- **Currency:** **Akçe** (stars). Two economies exist conceptually — Akçe (books/mastering) and Stars (used in the quote shop). In this rebuild, treat Akçe and Stars as the **same backing field** (`Player.stars`) — the "Akçe" name is just a UI alias. Don't create a separate currency.

---

## 4. The Board — Topology & Tiles

### 4.1 Geometry
A **26-tile perimeter** rectangle, walked **counter-clockwise** starting at the **bottom-right corner** (position 0).
- `boardSize = 26`, `boardWidth = 9`, `boardHeight = 6`.
- Corners (in path order): bottomRight=**0**, bottomLeft=**8**, topLeft=**13**, topRight=**21**.
- Middle runs: bottom tiles 1–7 (walked right→left), left 9–12 (bottom→top), top 14–20 (left→right), right 22–25 (top→bottom).
- Aspect ratio ≈ 10:7 (landscape). Corners are square; bottom/top middles are tall-narrow rects; left/right middles are short-wide rects. Each tile's text rotates to face the center: bottom=0°, right=90°CW, top=180°, left=270°; corners=0°.

Grid map:
```
[13-TL]  [14] [15] [16] [17] [18] [19] [20]  [21-TR]
[12]                                          [22]
[11]              CENTER AREA                 [23]
[10]                                          [24]
[ 9]                                          [25]
[ 8-BL]   [ 7] [ 6] [ 5] [ 4] [ 3] [ 2] [ 1]  [ 0-BR]
```

### 4.2 Complete tile table (THE authoritative board)

| pos | side | type | name | category | bookId | difficulty |
|---|---|---|---|---|---|---|
| 0 | corner | start | BAŞLANGIÇ | — | — | easy |
| 1 | bottom | category | Türk Edebiyatında İlkler | turkEdebiyatindaIlkler | intibah | easy |
| 2 | bottom | category | Edebi Sanatlar | edebiSanatlar | araba_sevdasi | easy |
| 3 | bottom | category | Eser-Karakter | eserKarakter | ask_i_memnu | easy |
| 4 | bottom | chance | ŞANS | — | — | medium |
| 5 | bottom | category | Edebiyat Akımları | edebiyatAkimlari | sinekli_bakkal | easy |
| 6 | bottom | category | Türk Edebiyatında İlkler | turkEdebiyatindaIlkler | kuyucakli_yusuf | medium |
| 7 | bottom | category | Eser-Karakter | eserKarakter | fatih_harbiye | medium |
| 8 | corner | signingDay | İMZA GÜNÜ | — | — | medium |
| 9 | left | category | Ben Kimim? | benKimim | calikusu | medium |
| 10 | left | fate | KADER | — | — | medium |
| 11 | left | tesvik | Teşvik | tesvik | — | medium |
| 12 | left | category | Edebi Sanatlar | edebiSanatlar | dokuzuncu_hariciye_kogusi | medium |
| 13 | corner | shop | KIRAATHANE | — | — | medium |
| 14 | top | category | Edebiyat Akımları | edebiyatAkimlari | tehlikeli_oyunlar | medium |
| 15 | top | category | Ben Kimim? | benKimim | ince_memed | medium |
| 16 | top | tesvik | Teşvik | tesvik | — | medium |
| 17 | top | chance | ŞANS | — | — | medium |
| 18 | top | category | Türk Edebiyatında İlkler | turkEdebiyatindaIlkler | saatleri_ayarlama_enstitusu | medium |
| 19 | top | category | Edebiyat Akımları | edebiyatAkimlari | kiralik_konak | hard |
| 20 | top | category | Ben Kimim? | benKimim | mai_ve_siyah | hard |
| 21 | corner | library | KÜTÜPHANE | — | — | hard |
| 22 | right | category | Edebi Sanatlar | edebiSanatlar | huzur | hard |
| 23 | right | category | Eser-Karakter | eserKarakter | yaban | hard |
| 24 | right | fate | KADER | — | — | medium |
| 25 | right | tesvik | Teşvik | tesvik | — | hard |

**Generate this board programmatically** from topology + `BookConfig`, exactly as the table above (don't hand-place). `corner`/`collection` `TileType` values are NOT used by the generator.

---

## 5. Books / Properties (the Monopoly layer)

Each **category tile is a specific Turkish literature book** (15 books total). Players acquire and publish books to win. Book model:

```dart
class Book {
  final String id;
  final String title;        // full Turkish title
  final String author;
  final String? boardLabel;  // short wrapped label for the tile (null → use title)
  final QuestionCategory category;
  final int tilePosition;
  final int telifRewardAkce; // default 0
  final int baskiCostAkce;   // upgrade cost to Baskı
  final int ciltCostAkce;    // upgrade cost to Cilt
}
```

### The 15 books

| id | title | author | category | tile | baskiCost | ciltCost | difficulty |
|---|---|---|---|---|---|---|---|
| intibah | İntibah | Namık Kemal | turkEdebiyatindaIlkler | 1 | 8 | 18 | easy |
| araba_sevdasi | Araba Sevdası | Recaizade M. Ekrem | edebiSanatlar | 2 | 8 | 18 | easy |
| ask_i_memnu | Aşk-ı Memnu | Halit Ziya Uşaklıgil | eserKarakter | 3 | 10 | 22 | easy |
| sinekli_bakkal | Sinekli Bakkal | Halide Edib Adıvar | edebiyatAkimlari | 5 | 10 | 22 | easy |
| kuyucakli_yusuf | Kuyucaklı Yusuf | Sabahattin Ali | turkEdebiyatindaIlkler | 6 | 12 | 26 | medium |
| fatih_harbiye | Fatih-Harbiye | Peyami Safa | eserKarakter | 7 | 12 | 26 | medium |
| calikusu | Çalıkuşu | Reşat Nuri Güntekin | benKimim | 9 | 10 | 22 | medium |
| dokuzuncu_hariciye_kogusu | Dokuzuncu Hariciye Koğuşu | Peyami Safa | edebiSanatlar | 12 | 12 | 26 | medium |
| tehlikeli_oyunlar | Tehlikeli Oyunlar | Oğuz Atay | edebiyatAkimlari | 14 | 14 | 30 | medium |
| ince_memed | İnce Memed | Yaşar Kemal | benKimim | 15 | 14 | 30 | medium |
| saatleri_ayarlama_enstitusu | Saatleri Ayarlama Enstitüsü | A. H. Tanpınar | turkEdebiyatindaIlkler | 18 | 14 | 30 | medium |
| kiralik_konak | Kiralık Konak | Yakup Kadri K. | edebiyatAkimlari | 19 | 16 | 34 | hard |
| mai_ve_siyah | Mai ve Siyah | Halit Ziya Uşaklıgil | benKimim | 20 | 16 | 34 | hard |
| huzur | Huzur | A. H. Tanpınar | edebiSanatlar | 22 | 16 | 34 | hard |
| yaban | Yaban | Yakup Kadri K. | eserKarakter | 23 | 16 | 34 | hard |

### Category → books (5 categories own books)
- **Türk Edebiyatında İlkler**: intibah(1), kuyucakli_yusuf(6), saatleri_ayarlama_enstitusu(18)
- **Edebi Sanatlar**: araba_sevdasi(2), dokuzuncu_hariciye_kogusu(12), huzur(22)
- **Eser-Karakter**: ask_i_memnu(3), fatih_harbiye(7), yaban(23)
- **Edebiyat Akımları**: sinekli_bakkal(5), tehlikeli_oyunlar(14), kiralik_konak(19)
- **Ben Kimim?**: calikusu(9), ince_memed(15), mai_ve_siyah(20)

Cost tiers follow a clean ladder: 8/18, 10/22, 12/26, 14/30, 16/34 (each step +2 baski / +4 cilt).

### BookLevel progression (house analogy)
`enum BookLevel { none, telif, baski, cilt }` — none→**telif**→**baskı**→**cilt** (caps at cilt). Think: license → print run → bound edition.

### BookOwnership (session state)
```dart
class BookOwnership {
  final String bookId;
  final String ownerPlayerId;
  final BookLevel level;
}
```
Stored in `GameState.bookOwnerships: Map<String, BookOwnership>` (keyed by bookId).

---

## 6. Enums (define exactly)

```dart
enum Difficulty { easy, medium, hard } // displayName: Kolay/Orta/Zor

enum QuestionCategory {
  benKimim,                       // "Ben Kimim?"
  turkEdebiyatindaIlkler,         // "Türk Edebiyatında İlkler"
  edebiyatAkimlari,               // "Edebiyat Akımları"
  edebiSanatlar,                  // "Edebi Sanatlar"
  eserKarakter,                   // "Eser-Karakter"
  tesvik,                         // "Teşvik"
  bonusBilgiler,                  // "Bonus Bilgi" (used by Teşvik tiles + practice/Meşk)
}

enum GamePhase { setup, rollingForOrder, tieBreaker, playerTurn, questionPhase, cardPhase, movementPhase, gameOver }
// NOTE: in the original, only setup/rollingForOrder/tieBreaker/playerTurn/gameOver are actually set.
// Questions & cards are handled via dialog flags on top of playerTurn. You MAY keep it that way.

enum CardType { sans, kader }     // Şans/Kader
enum TileType { start, category, corner, shop, collection, library, signingDay, chance, fate, tesvik }
enum MasteryLevel { novice, cirak, kalfa, usta } // Hiçbir Şey Bilmiyor / Çırak / Kalfa / Usta
enum BookLevel { none, telif, baski, cilt }
```

`CardEffectType { moneyChange, move, moveRelative, jail, skipTurn, rollAgain, loseStarsPercentage, globalMoney }`

---

## 7. Data Models

### 7.1 Question + questions.json
**Model:**
```dart
class Question {
  final String id;                       // FIX original: add id
  final String text;                     // from JSON "question"
  final List<String> options;            // always 4
  final int correctIndex;                // DERIVE: options.indexOf(answer)
  final QuestionCategory category;
  final Difficulty difficulty;           // use enum, not String
}
```
**JSON schema (660 questions):**
```json
{ "id":"bk_001", "category":"benKimim", "difficulty":"easy",
  "question":"...", "answer":"Mehmet Akif Ersoy",
  "options":["...","Mehmet Akif Ersoy","...","..."] }
```
- Load: for each row, `correctIndex = options.indexOf(answer)`. Fall back to 0 if not found. Map `difficulty` string → enum; `category` string → enum.
- **Question counts (must match):** Total **660**. Per category: benKimim 213, turkEdebiyatindaIlkler 137, eserKarakter 127, tesvik 63, edebiSanatlar 49, edebiyatAkimlari 39, bonusBilgiler 32. Per difficulty: easy 135, medium 216, hard 309.
- ⚠️ Data quirk: `tesvik` is **100% hard** (63/63) and `bonusBilgiler` has no board tile. See §13 for how Teşvik tiles use these.

### 7.2 Quote + literary_quotes.json
**Model:**
```dart
class Quote {
  final String id;
  final String text;
  final String author;
  final String era;    // FIX original: JSON key is "period", map to this
  final int price;     // FIX original: JSON key is "starCost", map to this
  // category is absent in JSON — omit or default
}
```
**JSON schema (25 quotes):**
```json
{ "id":"quote_001", "text":"...", "author":"Yunus Emre", "period":"Halk Edebiyatı", "starCost":10 }
```
- 25 quotes. Distinct prices: {5, 8, 10, 12, 15}. Periods: Cumhuriyet Dönemi (7), Divan Edebiyatı (5), Halk Edebiyatı (4), İkinci Yeni (2), Milli Edebiyat (2), Tanzimat Edebiyatı (2), Servetifünun (2), Fecr-i Ati (1). (Ignore a stray `"answer"` key on `quote_009`.)
- Quotes are a **collectible** bought in the shop (spend Akçe). Collection target for UI = 20. **Note: quote collection is NOT the win condition** (see §14).

### 7.3 BoardTile
```dart
class BoardTile {
  final String id;             // = position as string
  final String name;
  final int position;          // 0–25
  final TileType type;
  final String? category;      // category enum name, or '' for special tiles
  final String? bookId;        // set on category tiles
  final Difficulty difficulty; // default medium
}
```

### 7.4 Player
```dart
class Player {
  final String id, name;
  final Color color;
  final int iconIndex;
  final int position;          // 0–25
  final bool inJail;           // legacy flag (see §11)
  final int turnsToSkip;       // active Library penalty counter
  final int stars;             // currency (Akçe/stars — same field)
  final List<String> collectedQuotes;
  final Map<String, int> categoryLevels;                       // categoryName → 0..3
  final Map<String, Map<String, int>> categoryProgress;        // category → {difficultyName: correctCount}
  final String mainTitle;      // default 'Çaylak'
}
```
Provide `addStars`, `copyWith`, `fromJson`/`toJson`, mastery helpers (`getMasteryLevel`, `canPromoteToCirak/Kalfa/Usta`, `promoteInCategory`, `recordCorrectAnswer`, `getCorrectAnswerCount`).

---

## 8. GameState & State Machine

`GameState` (immutable, held by `GameNotifier extends StateNotifier<GameState>`):

| field | type | default |
|---|---|---|
| players | `List<Player>` | required |
| tiles | `List<BoardTile>` | `BoardConfig.tiles` |
| currentPlayerIndex | `int` | 0 |
| diceTotal, dice1, dice2 | `int` | 0 |
| consecutiveDoubles | `int` | 0 |
| isDiceRolled, isDiceRolling | `bool` | false |
| isDoubleTurn | `bool` | false |
| isGamePaused | `bool` | false |
| phase | `GamePhase` | `setup` |
| lastAction | `String` | status text |
| logs | `List<String>` | capped 100 |
| floatingEffect | `FloatingEffect?` | reward toast (STICKY — see below) |
| currentTile | `BoardTile?` | — |
| currentQuestion | `Question?` | — |
| winner | `Player?` | — |
| bookOwnerships | `Map<String,BookOwnership>` | — |
| askedQuestionIds | `Set<String>` | keyed on question TEXT (prevents repeats) |
| turn-order fields | `orderRolls`, `tieBreakerGroups`, `finalizedOrder`, `pendingTieBreakPlayers`, `tieBreakRound`, `tieBreakRoundRolls` | empty |

**Sticky floatingEffect:** the toast survives unrelated `copyWith` updates; it clears only via its own 2-second timer (clear it with an explicit `clearFloatingEffect: true` flag).

**Effective phase flow:**
```
setup →(initializeGame)→ rollingForOrder →(tie)→ tieBreaker →(recurse)→ tieBreaker
rollingForOrder →(finalize)→ playerTurn
playerTurn →(3 Cilt books)→ gameOver
```
Sub-states (question/card/shop/library dialogs) are **dialog flags** in `DialogProvider` layered over `playerTurn`, not phase changes. Implement a `DialogProvider` with booleans (`showQuestionDialog`, `showCardDialog`, `showLibraryPenaltyDialog`, `showSigningDayDialog`, `showKiraathaneDialog`, `showShopDialog`, `showTurnSkippedDialog`, `showTurnOrderDialog`, `showPrinterIssueDialog`) plus `isAnyDialogOpen`. `rollDice()` is blocked while any dialog is open.

**Locks:** maintain `_isProcessing` (logic lock) and `_isProcessingAction` (UI race guard). Many methods must clear `_isProcessing` before calling `endTurn()` (since `endTurn()` no-ops while locked).

**Async barrier:** every human dialog uses a `Completer<void>` awaited in the handler; the matching `close…Dialog()` completes it. Bots bypass dialog completers and auto-advance.

---

## 9. Turn Flow (the complete loop)

1. **Setup** → `initializeGame(players)`: sanitize IDs, load + **shuffle all questions once** per game, set `tiles`, `phase=rollingForOrder`.
2. **Turn order tournament** (§15) → `phase=playerTurn`, players sorted by their (final) roll **descending**.
3. **A turn:**
   - `rollDice()` — guards: not processing, no dialog open, phase is `playerTurn`.
   - `DiceService.executeRoll`: two independent D6 (`diceMinRoll=2, diceMaxRoll=12`), `isDouble = d1==d2`. Set `isDiceRolling=true`, play `dice_roll.wav`, wait **6100ms** (human) / **500ms** (bot), set `isDiceRolled=true`.
   - `_handleMovementRoll(d1,d2,total,isDouble)` — apply dice rules (§10).
   - `_movePlayer(total)` → `MovementService` hops step-by-step (§11) → `_handleTileArrival(tile)` (§12).
   - Eventually `endTurn()` (§9.1).
4. After any Cilt upgrade or bot correct answer, check win condition (§14).

### 9.1 endTurn()
- No-op if processing or `gameOver`.
- Wait **1200ms** (bot 200ms).
- `next = (currentPlayerIndex+1) % players.length`.
- Compute leader stars; apply **turn-end catch-up bonus** to the next player if not skipped (§13.3d).
- If `consecutiveDoubles > 0` → same player rolls again (`isDoubleTurn=true`).
- Else → advance to `next`, reset dice flags. If next player `turnsToSkip>0` → `_handleSkippedTurnEntry()` (decrement skip, show TurnSkipped dialog, auto-close after 1200ms/450ms bot, then chain `endTurn()` again). Else if it's a bot → schedule bot turn.

---

## 10. Dice Rules

- Two D6, total 2–12. `isDouble = d1 == d2`.
- `newConsecutive = isDouble ? consecutiveDoubles + 1 : 0`.
- `maxConsecutiveDoubles = 2` (soft cap).
- **CASE A — 3rd consecutive double** (`newConsecutive > 2`): send player to **Kütüphane (pos 21)**, set `turnsToSkip = jailTurns = 2`, reset `consecutiveDoubles=0`, then `endTurn()`.
- **CASE B — 1st or 2nd double** (`isDouble`): log "Çift Attın! Tekrar oyna." If it's the 2nd consecutive, log a warning that **double-decay** is now active (§13.3c). Move player. **Library override:** if the move lands on Library, end turn via the library dialog (no re-roll). Otherwise `isDoubleTurn=true`, `isDiceRolled=false` → **same player re-rolls**.
- **CASE C — non-double:** reset `consecutiveDoubles=0`, move, end turn.

---

## 11. Movement

- Board wraps: `currentPos = (currentPos + 1) % 26` per step.
- **Passing-start bonus:** when crossing start mid-route (`currentPos == 0 && !isLastStep`), award `passingStartBonus = 5` Akçe, show "BAŞLANGIÇ BONUSU" toast, play star SFX.
- **Landing exactly on start:** handled separately in `_handleStartTileLanding` (see §12) to avoid double-awarding.
- Hop delay: **450ms** (human) / **50ms** (bot) per step; play `pawn_step.wav` per hop; `HapticFeedback.mediumImpact()` on each landing.
- On final landing → `_handleTileArrival(tile)`.

---

## 12. Tile-Type Handling

On arrival (with a **chain guard**: if `_tileArrivalDepth >= 3`, break the chain and `endTurn()` — prevents infinite card→move→card loops):

| TileType | Action |
|---|---|
| **category** (book) | If `tile.category != null` → trigger a question (§13). Else end turn. |
| **tesvik** | Trigger a question using category `bonusBilgiler` (bonus tile). |
| **start** | Award `salaryAmount = 20` Akçe, log, end turn. (Plus the +5 pass bonus if crossed.) |
| **shop** (Kıraathane) | Open Kıraathane dialog → player may open the quote shop or start Meşk practice (§17). |
| **library** (Kütüphane / jail) | Set `turnsToSkip = 2`, show library dialog; on close set skip + reset doubles, **always end turn** (overrides doubles). |
| **signingDay** (İmza Günü) | No penalty — show a flavor dialog ("okurlarıyla buluştu"), end turn. |
| **chance** (ŞANS) | Draw from `GameCards.sansCards`, show card dialog, apply effect. |
| **fate** (KADER) | Draw from `GameCards.kaderCards`, show card dialog, apply effect. |

**Card chaining:** if a card causes movement (`move`/`moveRelative`/`jail`) → after applying, chain `_handleTileArrival(newTile)` via a microtask (bounded by the depth guard). If `rollAgain` → same player re-rolls. Otherwise end turn.

---

## 13. Question Flow, Mastery & Rewards

### 13.1 Difficulty selection (by mastery)
| Player mastery in category | Question difficulty |
|---|---|
| novice | easy |
| cirak | medium |
| kalfa | hard |
| usta | hard |

For **Teşvik** tiles, category is forced to `bonusBilgiler`.

### 13.2 Question selection & anti-repeat
- Pool = questions where `category matches` ∧ `difficulty matches` ∧ `text not in askedQuestionIds`.
- If empty → flag reset, retry ignoring asked-set.
- If still empty → relax difficulty (any difficulty for that category), prefer short questions (`QuestionLineEstimator`, estimate rendered lines at maxWidth 320, sort ascending, pick from the readable tier, capped to ~35% of pool).
- If still empty for Teşvik → award a flat **+5 Akçe** fallback bonus and end turn.
- If still empty (non-Teşvik) → end turn.

### 13.3 Rewards
**Base reward by difficulty:** easy **3**, medium **5**, hard **8**. `wrongAnswerPenalty = 0` (no deduction, never negative).

Total = `leadCompression(base) → doubleDecay → + underdogBonus → + promotionReward`. Details:

a) **Underdog bonus:** if `leaderStars <= 0` → none. Else if `current < leader * 0.5` → bonus = `round(base*(1.5−1)).clamp(3, base)`. (threshold 0.5, multiplier 1.5, min 3, max = base.)

b) **Lead compression:** if `gap = leader − current >= 15` → reward × 1.2 (boosts trailing players). (threshold 15, scale 1.2.)

c) **Double-decay:** if `consecutiveDoubles >= 2` → reward × 0.5 (−50%) on the 2nd-and-beyond consecutive double.

d) **Turn-end recenter bonus:** at each non-skipped turn handoff, give the trailing next player a small catch-up = `applyLeadCompression(3, nextPlayer.stars, leader)` clamped.

### 13.4 Mastery promotion (thresholds)
`answersRequiredForPromotion = 3`. Promotion only when the answered difficulty matches the **current mastery's target** and per-difficulty correct count ≥ 3:
| From | Answer difficulty | Count | To | Promotion reward |
|---|---|---|---|---|
| novice | easy | 3 | **cirak** | +10 |
| cirak | medium | 3 | **kalfa** | +20 |
| kalfa | hard | 3 | **usta** | +30 |

Progress stored in `categoryProgress[category][difficulty.name]`. On promote, `categoryLevels[category] = newLevel`. Reward multiplier hint: cirak 1×, kalfa 2×, usta 3×.

### 13.5 Quote drop
On a **correct HARD** answer, with probability `hardQuestionQuoteDropRate = 0.3` (30%), collect a random quote (`quote_{0..99}`).

### 13.6 Hint & timer (UI)
- Question timer: **45s** standard, **60s** for chance/fate cards. Timer expiry → treat as wrong answer.
- `hintCost = 1` Akçe is defined; you MAY add a hint button that eliminates one wrong option for 1 Akçe. (Original left this unwired.)

---

## 14. Publishing Tycoon (book ownership) & Win Condition

### 14.1 Acquisition & upgrades (applied after each answer, in order)
1. **Acquire Telif (free):** correct answer + the landed book is unowned → grant `BookLevel.telif` to current player (no cost).
2. **Upgrade Telif→Baskı:** correct + owns telif + `akce >= book.baskiCostAkce` → deduct cost, set `baskı`.
3. **Upgrade Baskı→Cilt:** correct + owns baskı + **answered HARD** + mastery ≥ kalfa in that category + `akce >= book.ciltCostAkce` → deduct cost, set `cilt`. Then check win condition.
4. **Royalty (rent):** **wrong** answer + an opponent owns the landed book → payer gives `royaltyForLevel`: telif=2, baskı=4, cilt=6 Akçe, capped at payer's current balance.

### 14.2 WIN CONDITION (the actual rule)
**First player to own 3 books at `BookLevel.cilt` wins.** (`publishingCiltBooksToWin = 3`.) Check after every Cilt upgrade. On win → `winner = player`, `phase = gameOver`.

> ⚠️ Discrepancy note: the README/GDD claim the win is "20 quotes + 3 masteries." That is **not** the implemented rule. Use the **3-Cilt-books** rule as primary. You may keep `isUstaInAllCategories()`/`ustaCategoryCount` on the model and `quotesToCollect=20` as a UI-only collection target, but do not trigger wins from them.

---

## 15. Turn-Order Tournament (automated dice)

Fully automated, recursive tie-breaking:
1. Root (`depth=0`): play in-game BGM, 800ms settle, `phase=rollingForOrder`, `orderRolls={}`.
2. For each player (sequentially, animated): highlight, pre-roll delay (bot 200ms / human 600ms), roll two D6 (sum; doubles ignored for ordering), store in `orderRolls[id]`, animate dice (bot 400ms / human 6100ms), post-roll delay (bot 300ms / human 800ms).
3. Find max roll; collect all candidates tied at max.
4. If >1 tied → log tie, 1000ms pause, **recurse** with only the tied players (`depth+1`, `phase=tieBreaker`). Re-rolled values overwrite `orderRolls[id]`.
5. When unique → **finalize**: sort ALL players by `orderRolls[id]` **descending**, `currentPlayerIndex=0`, `phase=playerTurn`, show `TurnOrderDialog`.

---

## 16. Cards (Şans & Kader)

Decks (`GameCards.sansCards`, `GameCards.kaderCards`). Draw = uniform random from the deck.

### Şans cards (9, reward-leaning, target EV +8)
- "Telif hakkı ödemesi aldın!" — moneyChange **+8**
- "Küçük bir edebi ödül kazandın." — moneyChange **+10**
- "Makalen dergide yayınlandı." — moneyChange **+12**
- "İlham perisi geldi!" — moveRelative **+1**
- "Vakit nakittir!" — **rollAgain**
- "Eleştirmenlere karşı geçici bağışıklık." — moneyChange **+5** (placeholder)
- "Okuyucularından güzel mektuplar aldın." — moneyChange **+8**
- "Kütüphanede kıymetli bir eser buldun." — moveRelative **+1**
- "Yayınevinden küçük bir avans geldi." — moneyChange **+10**

### Kader cards (9–10, risk-leaning, target EV −8)
- "Mürekkepin bitti." — skipTurn **1** (→ Printer Issue dialog)
- "Yazıcı tıkandı!" — skipTurn **1** (→ Printer Issue dialog)
- "Tektip yayınladın." — moveRelative **−1**
- "Eserin eleştirildi." — moveRelative **−2**
- "Cüzdanını düşürdün." — loseStarsPercentage **40**
- "Kötü bir yatırım yaptın." — loseStarsPercentage **30**
- "Kahve faturası öde." — moneyChange **−4**
- "Kırtasiye masrafı." — moneyChange **−6**
- "Kütüphane cezası." — moneyChange **−8**

### Card effect application (all 8 effect types)
| effect | logic |
|---|---|
| `moneyChange` | `stars = (stars + value).clamp(0, ∞)`. If a negative value can't be paid (would go below 0) → set to 0 **and add +1 skip turn** ("ödeyemedi"). Positive/affordable → apply delta + floating toast. |
| `move` | absolute: `target = value % 26`; if passed start → +5; set position; chain arrival. |
| `moveRelative` | `target = (position + value) % 26` (normalize negatives); if value>0 and wrapped → +5; chain arrival. |
| `jail` | position = 21 (library), `turnsToSkip = 2`; chain arrival. |
| `skipTurn` | if desc contains "Mürekkep"/"Yazıcı" → show Printer Issue dialog (then +1 skip on close); else `turnsToSkip += value`. |
| `rollAgain` | no state change → same player re-rolls. |
| `loseStarsPercentage` | `pct = value.clamp(0, 40)`; `loss = round(stars*pct/100)`; `stars = max(0, stars-loss)`; toast. |
| `globalMoney` | affects all OTHER players: value>0 take min(value, their stars) each → sum to current; value<0 give `−value` to each, subtract sum from current. |

`maxPercentLoss = 40` (loss cap). Target EV constants: chance +8.0, fate −8.0.

---

## 17. Kıraathane (shop tile), Meşk & Shop

On landing on the shop tile (pos 13):
- **Bot:** auto-pass, end turn.
- If `akce < meskCostAkce (5)` → log "insufficient", end turn (no dialog).
- Else show **Kıraathane dialog** ("Meşk Kategorisi", coffee icon, cost 5 Akçe) listing all categories except `bonusBilgiler` (disabled if can't afford). Player chooses:
  - **Start Meşk (practice):** costs 5 Akçe (spent upfront, **not refunded on wrong answer**). Pick a question at the player's mastery-derived difficulty (no line-estimation). Correct → mastery progress only (no stars, no underdog/decay, no quote drop). Then end turn.
  - **Open shop** → Quote shop: shows 6 random unowned quotes ("Günün Nadide Eserleri"), filterable by period. Buy a quote for `quote.starCost` Akçe → deduct, add to `collectedQuotes`, show a toast. Bot never buys.
  - **Cancel** → end turn.

---

## 18. Bot AI

- Toggle via `BotController.toggle()`; when active, schedule bot turns on an **800ms** timer.
- **Decision loop:** if no dialog open, not rolling, not processing → `rollDice()`; else `_handleDialog()`.
- **Answer correctness:** `_random.nextBool()` → **exactly 50%** correct, no strategy weighting.
- **Difficulty:** derived normally from tile category + bot's mastery (bot doesn't choose).
- **Dialog handling:** after 500ms, close whichever dialog is open (priority order). Bot **never buys / never does Meşk**.
- **Auto-close delays:** library/signingDay dialogs 300ms, shop 500ms.
- **Watchdog:** a **4-second** timer; if it fires, force `_isProcessing=false` and recover by closing the stuck dialog or calling `rollDice()`.
- **Timing helper:** `getDelay(humanMs, botMs)` returns the bot value when active.

---

## 19. Daily Streak (out-of-game, optional flavor)

A separate single-user layer via SharedPreferences. On app open (`checkAndUpdateStreak`): first login → streak 1; same day → unchanged; exactly 1-day gap → +1; >1-day gap → reset to 1. Store `streak_last_login_date`, `streak_days`. Show as a "Sönmeyen Mum" (Eternal Candle) widget, "{n} gün". **No in-game reward** tied to streak.

---

## 20. UI / UX Specification

### 20.1 App entry & navigation
- `main()`: `WidgetsFlutterBinding.ensureInitialized()` → `await AudioManager.instance.init()` → force portrait → `runApp(ProviderScope(child: MyApp()))`.
- `MyApp`: `MaterialApp` title 'EDEBİNA', `debugShowCheckedModeBanner:false`, theme from `ThemeNotifier`, home = a **phase-driven router**: `setup`→SplashScreen, `rollingForOrder`→"Sıra belirleniyor…" loading, default→BoardView.
- Imperative pushes: Splash→Menu (fade 800ms), Menu→Setup (`MaterialPageRoute`), Setup→BoardView (fade 600ms, **await `initializeGame(players)` first**), BoardView→VictoryScreen on `gameOver` (play victory SFX + confetti, sort players by stars desc), Victory→Menu (`pushAndRemoveUntil`).
- **Orientation:** portrait for menus; **landscape + immersive sticky** for the board (restore portrait on dispose).
- **No Firebase.** All local JSON.

### 20.2 Splash → Main Menu → Setup
- **Splash:** shows EDEBİNA title (Cinzel Decorative), tagline, loads `wooden_table_bg.png`, auto-advances to menu.
- **Main Menu:** Ottoman scholar palette, "OYUNU BAŞLAT" (ScholarButton) → Setup; plus Settings dialog, How-to-play dialog, Collection.
- **Setup ("Oyuncu Defteri"):** 2–6 players (start 2). Each player card: avatar medallion (→ picker), signature-style name TextField, wax-seal color picker (breathing animation), remove button. "YENİ OYUNCU EKLE" add button. Start FAB = ScholarButton "OYUNU BAŞLAT".
  - **Wax-seal palette (8 colors):** `#A83F39` cinnabar, `#1E5A7D` lapis, `#2D5A3D` malachite, `#B8860B` dark gold, `#5C3C7A` tyrian purple, `#D4AF37` polished gold, `#8B4513` sepia, `#1A4D42` ottoman teal.
  - **Avatar icons (use ONE consistent list — see discrepancy):** 12 Material icons (person, face, emoji_people, sentiment_satisfied_alt, catching_pokemon, psychology, school, auto_stories, create, favorite, star, pets). Keep this single list for both setup and pawn.

### 20.3 BoardView (landscape) — a Stack of layers (z-order)
1. `assets/images/wooden_table_bg.png` (BoxFit.cover) + black 30% overlay.
2. Board content: `TickerMode(!paused)` → `Center` → `InteractiveViewer(minScale:0.5,maxScale:2.0)` → **BoardLayout** (a Stack of: CenterArea, TileGrid, PawnManager, EffectsOverlay; board surface fakes 3D thickness with 4 stacked translucent "wood slab" offsets).
3. Mobile log FAB (drawer with GameLog) when `width < 900`.
4. GameControlsOverlay (pause, bot-mode toggle).
5. PlayerHudManager (perimeter HUD).
6. Opening overlay ("Masa Hazırlanıyor") fading out on entry.
7. Confetti (top-center).
8. **Flat dialog layer** — all gameplay dialogs rendered orthogonally (NOT via showDialog), driven by `DialogProvider`.

### 20.4 Perimeter HUD
- Fixed panel size per screen class (compact when `shortestSide < 500`). Turn emphasis = paint-only (glow/border/badge), never resizes.
- **≤4 players** → 4 corners (TL, TR, BR, BL).
- **5–6 players** → 6 points (TL, TR, mid-right, BR, BL, mid-left). Mid cards anchored just above the bottom corners.

### 20.5 Dice — CUSTOM 3D CustomPainter (NOT Lottie)
- **Two widgets:** a roll button (3-layer stacked slab button with press-down animation, label by phase: "ZAR AT" / "SIRALAMA BELİRLE" / "ÇİFT GELDİ - TEKRAR AT") AND the in-flight 3D dice (`DiceRollThreeView` shown via a center overlay while `isDiceRolling`).
- **3D dice = a `CustomPainter`:** real cube vertex math, X+Y rotation matrices, back-face culling, painter's-algorithm depth sort, perspective projection, per-face brightness shading, pips per visible face. Two dice, ivory faces (`#FFFDF5/#F5F0E0/#E8E0D0`), border `#9A9080`, pips `#1A1408`. Multi-stage sine bounce physics.
- **Timing:** tumble 3600ms, settle hold 1100ms, result hold 1400ms = **6100ms total** for humans (bot 500ms).
- ⚠️ Ignore `assets/animations/dice.json` / Lottie — it's dead legacy. Don't load it.

### 20.6 Pawn — 2D lacquered token (NOT 3D/emoji)
- Circular disc, 90% of size, **radial gradient lit top-left** (`Alignment(-0.35,-0.45)`) using HSL-derived shades (light/base/dark/rim) from player color.
- Inner bevel highlight ring + player's **Material icon** (white, embossed shadow) at 50% of size + specular top-left sheen.
- Ground shadow (flattened ellipse). **Active-turn glow:** halo at 1.5×, pulsing box-shadow. **Move pulse:** TweenSequence 1.0→1.12→1.10→1.0.
- Placement: `AnimatedPositioned` (duration `MotionDurations.pawn`), slotted in a 2-col×3-row grid per tile, `HapticFeedback.mediumImpact()` on landing.

### 20.7 Tile widget
- **Special tiles:** icon + label in FittedBox, Poppins 9sp bold:
  start→`play_arrow_rounded` green "BAŞLA"; shop→`local_cafe_rounded` brown "KIRAATHANE"; library→`local_library_rounded` teal "KÜTÜPHANE"; signingDay→`edit_note_rounded` purple "İMZA GÜNÜ"; chance→`casino_rounded` amber "ŞANS"; fate→`auto_awesome_rounded` deepPurple "KADER".
- **Category (book) tiles:** a 12px color strip (position by side) + book title (auto-fit font search via `TextPainter`; side labels rotated along the tile's long axis).
- **Category strip colors:** turkEdebiyatindaIlkler `#2196F3`, edebiSanatlar `#9C27B0`, eserKarakter `#E65100`, edebiyatAkimlari `#2E7D32`, benKimim `#D32F2F`, tesvik `#00838F`.
- **Ownership badge** in strip (11px disc): flat owner-color disc, or gradient by level — Telif bronze `[#D8A05C,#8C5A24]`, Baskı ink-blue `[#4F94DC,#1D4F8C]`, Cilt purple `[#A476DC,#5B2E91]`.
- **Landing pulse:** scale 1.0→1.15→1.0 + copper border flash + gold box-shadow.

### 20.8 Question card — "Who Wants to Be a Millionaire" reveal
- Fixed design-size 320×580 card scaled via `FittedBox(BoxFit.contain)` (never scrolls). Cream body `#FFFDF8`, 18 radius, 3px brown `#5D4037` border. Brown header band, category label in Merriweather 15sp bold (amber `#FFECB3`). Question in parchment inset `#F5F0E6`, AutoSizeText Merriweather 20sp. Options A/B/C/D lettered circles, Merriweather 18sp.
- **Reveal sequence:** tap option → selection **orange pulse** (`#FFE0B2/#FFF8E1`, border `#FF9800→#F57C00`, 200ms repeat) → after **900ms suspense** → reveal correct=green `#E8F5E9/#2E7D32`, wrong-selected=red `#FFEBEE/#C62828` + icons → callback after **1600ms (correct)** / **800ms (wrong)**.
- Correct → trigger `FlyingStar` overlay (3/5/8 stars by difficulty).
- Timer 45s (60s for cards) → expiry = wrong.

### 20.9 Card dialog (Şans/Kader)
- Visual theme by type:
  - **Şans** (day): bg `[#FFF7EC,#F6E6B8,#D6AD55]`, surface `#FFF7DE`, foreground `#4B3218`, accent `#B77A18`, metallic `#D8B667`, icon `wb_sunny_rounded`, title "ŞANS KARTI".
  - **Kader** (night): bg `[#31152A,#1B1C35,#090E1C]`, surface `#17172A`, foreground `#F8EEDC`, accent `#7B263D`, metallic `#C2A66B`, icon `nights_stay_rounded`, title "KADER KARTI".
- Top countdown `LinearProgressIndicator` (metallic). Icon medallion + title pill + description (Poppins 15sp) + "Kapatmak için dokun".
- **Auto-close after `cardDialogDurationMs = 5000ms`;** tap anywhere closes immediately. Entrance 280ms easeOutCubic (Şans scales from 0.96, Kader from 1.03); exit 150ms.

### 20.10 Victory screen
- Background: blurred `wooden_table_bg.png` + black 70%.
- **Custom gold-letter particle system** (NOT confetti pkg): ~20 particles, random uppercase letters, Cinzel Decorative gold `#C5A059`, drifting down, 10s loop.
- **Parchment certificate scroll:** aged parchment `#FDF6E3`, double ornamental border (teal `#00695C` + gold `#C5A059`), corner decorations. Entrance slides up + scaleY, 1000ms easeOutBack.
- Content: "EDEBİ ZAFER!" title, winner medallion (gold laurel border + avatar), winner name in **Pinyon Script** 48sp, flavor "Kütüphanenin Hâkimi" (Cormorant Garamond italic), a single "Şampiyon" row with stars. "ANA MENÜYE DÖN" gold button → switch to menu BGM + `pushAndRemoveUntil` to Menu.

---

## 21. Theme & Fonts

> ⚠️ Discrepancy: the original is "bifurcated" — runtime uses Modern Minimalist tokens (blue/white/teal), menus use hardcoded Ottoman constants, victory uses its own parchment palette. **For the rebuild, pick ONE coherent system.** Recommended: the **Ottoman Scholar** palette consistently (the cozy coffeehouse theme the game intends). Tokens below reflect the original values you can reuse.

**Runtime tokens (Modern Minimalist Dark):** background `#0F2E25`, highlight `#1A3D32`, surface `#FFFFFF`, textPrimary `#1A1A1A`, primary `#2196F3`, accent `#FFB300`, success `#4CAF50`, danger `#F44336`, border `#E0E0E0`, dialogOverlay `#99000000`.

**Ottoman Scholar static consts (menus/setup):** background `#F5F1E8`, accent (ink teal) `#1A4D42`, sepia `#8B4513`, gold `#C9A227`, goldLight `#D4AF37`, text `#3D3B35`, cinnabar `#A83F39`.

**Fonts (Google Fonts):** poppins (base UI/HUD), cinzelDecorative (titles), cormorantGaramond (subtitles), crimsonText (Ottoman buttons/snackbar), amiri (name inputs), pinyonScript (winner name), playfairDisplay (card titles), merriweather (question card), lora (İmza Günü body). `buildThemeData`: Material 3, full Poppins textTheme.

`ThemeNotifier`: presets `warmLibraryLight` (default) / `darkAcademia`, persisted via SharedPreferences key `'themePreset'`.

---

## 22. Motion Constants

**Durations (`MotionDurations`, with `.safe` → `Duration.zero` when reduced motion is on):** fast 150ms, medium 300ms, slow 500ms, dialog 350ms, pawn 400ms, dice 800ms, confetti 2000ms, ambientGradient 8000ms, shimmerLong 3000ms, pulse 350ms, slowDouble 1000ms.

**Curves (`MotionCurves`):** standard `easeOutCubic`, emphasized `easeOutBack`, decelerate, spring `elasticOut`, pawnMove `easeOutQuart`, scaleIn `easeOutBack`, breathe `easeInOutSine`.

**Reduced motion:** read `platformDispatcher.accessibilityFeatures.disableAnimations`; all motion consumers use `.safe` durations. (Background gradient breathes on an 8s loop.)

---

## 23. AudioManager

- **Singleton** `AudioManager.instance`. Two `audioplayers` players: `_bgmPlayer`, `_sfxPlayer`. SFX player stops any in-flight SFX before next (no overlap).
- **Context-aware BGM playlists:** menu `audio/menu_bg1..4.mp3`, in-game `audio/ingame_bg1..4.mp3`. On track end → advance index mod playlist + fade in; on context switch pick a **random** track, fade-out 800ms + 200ms gap + fade-in 2000ms (no-op if already in target context).
- **Fade:** linear stepping over 20 steps; fade-in default 2s, fade-out default 1s.
- **Volume & gain caps:** sliders 0–1; **BGM actual output = slider × 0.35** (hard cap so BGM never overpowers SFX); SFX not capped. Persist enable/disable + volumes.
- **SFX helpers:** playClick→`ui_click.wav`, playDiceRoll→`dice_roll.wav`, playVictory→`correct.wav`, playWrong→`wrong.wav`, playCardFlip→`card_flip.wav`, playPawnStep→`pawn_step.wav`.

---

## 24. Buttons

- **GameButton** (in-game, token-based): variants `primary/secondary/danger/success`, sizes `normal/compact`; optional icon, isLoading, isFullWidth, isDisabled. Plays `ui_click.wav` on press. Poppins w600.
- **ScholarButton** (menus/setup, Ottoman): leather-texture gradient + gold-leaf border, 16 radius, dual box-shadow + shimmer sweep on press (scale 1.0→0.95). Label crimsonText w700, letterSpacing 1.5. Subclass `ScholarButtonSmall`.
- **BouncingButton**: generic press-scale wrapper (scaleFactor 0.95, 100ms, easeInOut) for any child.

---

## 25. Assets

**Provide:**
- `assets/images/wooden_table_bg.png` (wooden table background).
- `assets/data/questions.json` (660 questions, schema §7.1).
- `assets/data/literary_quotes.json` (25 quotes, schema §7.2).
- `assets/app_icon.png` (1024×1024) + flutter_launcher_icons config (android `launcher_icon`, ios true, minSdk 21, remove alpha ios).
- Audio (10 files): `menu_bg1..4.mp3`, `ingame_bg1..4.mp3`, `ui_click.wav`, `dice_roll.wav`, `correct.wav`, `wrong.wav`, `card_flip.wav`, `pawn_step.wav`.

**Do NOT create/rely on:** `assets/animations/dice.json` (dead), `assets/images/avatar_01..20.png` or `decks/*.png` (missing in original — use Material icons for avatars instead).

`pubspec.yaml`: `uses-material-design: true`, declare the asset folders/files explicitly, SDK `^3.10.4`.

---

## 26. Constants Cheatsheet (all exact values)

```
jailTurns = 2
initialStars = 0
rewardEasy = 3, rewardMedium = 5, rewardHard = 8, rewardTesvik = 10
hintCost = 1, wrongAnswerPenalty = 0, jailFee = 5
passingStartBonus = 5
salaryAmount = 20            // landing ON start
maxConsecutiveDoubles = 2, doubleDecayAfterSecond = 0.5
diceMinRoll = 2, diceMaxRoll = 12
answersRequiredForPromotion = 3, promotionBaseReward = 10, maxLevelPerCategory = 3
quotesToCollect = 20, totalCategories = 6, publishingCiltBooksToWin = 3, meskCostAkce = 5
underdogThreshold = 0.5, underdogBonusStars = 3, underdogMultiplier = 1.5
leadCompressionThreshold = 15, trailingBoostScale = 1.2
targetChanceCardEV = 8.0, targetFateCardEV = -8.0, maxPercentLoss = 40
hardQuestionQuoteDropRate = 0.3
questionTimerSeconds = 45, chanceCardTimerSeconds = 60, cardTimerSeconds = 60
// timings (ms): human / bot
hopAnimationDelay = 450 / 50
diceAnimationDelay = 6100 / 500
turnChangeDelay = 1200 / 200
cardAnimationDelay = 500 / 100
turnSkippedDialogAutoCloseDelay = 1200 / 450
botDialogAutoCloseDelay = 500, botPenaltyDialogAutoCloseDelay = 300
cardDialogDurationMs = 5000, botTurnScheduleDelay = 800
pauseCheckInterval = 500, floatingEffectDurationSeconds = 2
// board geometry: boardSize=26, boardWidth=9, boardHeight=6
```

Royalties by BookLevel: telif=2, baskı=4, cilt=6.

---

## 27. Discrepancies & Decisions (resolve these cleanly — don't copy bugs)

1. **Unify entity layer** — original duplicates `models/` and `domain/`. Use ONE set of immutable models.
2. **Question model ↔ JSON** — original `Question` has no `id`, uses `correctIndex` + `text`, but JSON uses `id`/`question`/`answer`. **Fix:** model has `id` + `text` (from `question`) + `correctIndex` (derive from `options.indexOf(answer)`).
3. **Quote model ↔ JSON** — model keys `era`/`price`; JSON keys `period`/`starCost`. **Fix:** map `period→era`, `starCost→price`; ignore the stray `answer` on `quote_009`.
4. **Missing/dead data loader** — original references a non-existent `question_model.dart` and a stub `BoardConfigDataSource` returning `[]`. **Fix:** load directly into your unified `Question` model; generate the board from `BoardConfig` (not the stub datasource).
5. **Win condition** — use **3 Cilt books** (not "20 quotes + 3 masteries").
6. **Currency** — Akçe and Stars are the **same field** (`Player.stars`). Don't split.
7. **`bonusBilgiler` category** has 32 questions but no tile. It's used by **Teşvik** tiles and **Meşk** practice. Keep it; don't add a board tile for it.
8. **`tesvik` is 100% hard** in the data — acceptable since Teşvik is a bonus tile. If you regenerate questions, consider a balanced mix.
9. **Avatar icons** — use a single consistent list (the 12 Material icons in §20.2) for both setup and pawn. Original has 3 disagreeing lists.
10. **Dice** — custom CustomPainter 3D; ignore Lottie.
11. **Theme** — pick ONE coherent palette (recommend Ottoman Scholar) instead of the original's 3-way split.
12. **`modern_question_dialog.dart`** is dead code in the original; the live UI is `animated_question_card.dart`. Build the AnimatedQuestionCard (WWTBAM-style).
13. **`inJail` (bool) vs `turnsToSkip` (int)** — two jail mechanisms. Use `turnsToSkip` as the active Library penalty; you can drop the separate 50%-early-release-on-`inJail` logic or keep it optional. Prefer clarity: Library = `turnsToSkip = 2`, no separate `inJail` flag.

---

## 28. Suggested Build Order (MVP → full)

**Phase 1 — Models & data (no UI):** enums, models (Player, BoardTile, Book, BookLevel, BookOwnership, GameCard, Question, Quote, Difficulty), `BookConfig` (15 books), `BoardConfig` (26-tile generator from topology), `GameCards` decks, JSON loaders for questions/quotes. Unit-test parsing + the board table.

**Phase 2 — Core game rules (pure Dart, fully testable):** GameState, GameNotifier skeleton, DiceService, MovementService (passing-start), EconomyService (rewards + catch-up), QuestionFlowService (selection, mastery, promotion, quote drop), CardEffectService (all 8 effects), BookProgressionService (acquire/upgrade/royalty), WinConditionService, TurnOrderService (recursive). Write tests for each.

**Phase 3 — Minimal playable UI:** Splash→Menu→Setup→BoardView→Victory; TileGrid + simple tiles; DiceRoller button + (temporarily) 2D dice; pawn as a colored disc; basic question dialog (options + correct/wrong); card dialog; HUD; end-turn flow. Get a full hot-seat game working end-to-end.

**Phase 4 — Polish:** custom 3D dice CustomPainter; lacquered pawn; enhanced tile widget (strips, ownership badges); WWTBAM question reveal sequence; Şans/Kader card visuals; perimeter HUD; Kıraathane/Meşk/Shop; confetti/particles + victory certificate; AudioManager (BGM playlists + SFX + fade); motion constants + reduced-motion; theme.

**Phase 5 — Bot AI + streak:** BotController (50% accuracy, dialog auto-close, 4s watchdog); turn-order tournament animation; daily streak widget.

**Verify constantly:** `flutter analyze` clean, `flutter test` green, `flutter run` on a real device in landscape.

---

## 29. Definition of Done

- 2–6 player hot-seat game runs a full game to a 3-Cilt win.
- Bot mode autoplays turns with no hangs (watchdog recovers within 4s).
- All 26 tiles behave per §12; all 8 card effects per §16; mastery/royalty/publishing per §13–14.
- Dice = custom 3D painter, 6.1s human timing.
- Ottoman/cozy theme consistent across all screens; reduced-motion respected.
- Audio: context-aware BGM with fades, SFX on all events, 0.35 BGM gain cap, settings persisted.
- `flutter analyze`: no warnings. `flutter test`: passing. Portrait menus, landscape board.

**Now build it, phase by phase, testing each layer before moving on. Start with Phase 1.**
