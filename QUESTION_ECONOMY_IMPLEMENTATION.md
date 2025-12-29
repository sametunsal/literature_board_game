# Question & Economy Flow Implementation

## Overview
This document describes the implementation of the Question & Economy flow for the Literature Board Game, which handles questions, copyright purchases, and rent collection.

## Architecture

### 1. QuestionRepository (`lib/repositories/question_repository.dart`)
**Purpose**: Provides dummy literature questions for AYT/KPSS level.

**Features**:
- Questions organized by 5 categories:
  - `benKimim` (Who Am I?)
  - `turkEdebiyatindaIlkler` (Firsts in Turkish Literature)
  - `edebiyatAkillari` (Literary Movements)
  - `edebiyatSanatlari` (Literary Arts)
  - `eserKarakter` (Works/Characters)
- Each question has difficulty level (easy, medium, hard)
- Star rewards: Easy=10, Medium=15, Hard=20
- Random question selection by category

**Usage**:
```dart
// Get random question from specific category
final question = QuestionRepository.getRandomQuestion(QuestionCategory.benKimim);

// Get all questions for initialization
final allQuestions = QuestionRepository.getAllQuestions();
```

### 2. GameEngine Updates (`lib/engine/game_engine.dart`)
**New Methods Added**:

#### Question Phase Methods
- `_triggerQuestionPhase(Player, Tile)`: Displays question for unowned tiles
- `handleQuestionCorrect(Player, Tile, Question)`: Processes correct answer, awards points
- `handleQuestionWrong(Player, Question)`: Processes wrong answer, no points
- `_offerCopyrightPurchase(Player, Tile)`: Shows purchase dialog after correct answer

#### Economy Methods
- `_handleBookTile(Player, Tile)`: Main entry point for Book/Publisher tiles
- `handleCopyrightPurchase(Player, Tile)`: Completes copyright purchase
- `handleCopyrightSkip(Player, Tile)`: Skips copyright purchase
- `_collectRent(Player, Tile)`: Collects rent from landing player

#### New Callbacks
```dart
// Rent payment notification
final Function(String message)? onRentPaid;

// Copyright purchase offer (shows dialog with price and balance)
final Function(Tile tile, Player owner, int cost, int balance)? 
  onCopyrightPurchaseOffered;

// Question answer result notification
final Function(Player player, int amount)? onQuestionAnswered;
```

## Question & Economy Flow

### Flow Diagram

```
Player lands on Book/Publisher Tile
         │
         ▼
    Check Ownership
         │
    ┌────┴────┐
    │           │
 Owned by    Owned by  Unowned
    current     another
    player      player
    │           │           │
    │           │           ▼
    │           ▼     Trigger Question
    │        Collect   (show dialog)
    │          Rent
    │           │
    │           ▼
    │       Transfer stars
    │       player → owner
    │
    ▼
  (Do nothing)
```

### Question Answer Flow

```
Question Displayed
       │
       ▼
  Player Answers
       │
  ┌────┴────┐
  │           │
  Wrong       Correct
  Answer      Answer
  │           │
  ▼           ▼
No points   Award points
Turn ends  (starReward)
            │
            ▼
    Offer Copyright Purchase
            (show dialog: "Correct! +X points. 
              Price: [Cost]. Balance: [Balance]. 
              Do you want to buy?")
            │
       ┌────┴────┐
       │           │
       YES         NO
       │           │
       ▼           ▼
   Deduct cost  (Skip purchase
   Assign owner   Turn ends)
   Turn ends
```

## UI Integration Guide

### Required UI Components

#### 1. Question Dialog
**When**: `onQuestionAsked` callback is triggered

**Display**:
- Question text
- Question category badge
- Answer input field (text or multiple choice)
- Submit button

**Callbacks to call**:
- `gameEngine.handleQuestionCorrect(player, tile, question)` on correct answer
- `gameEngine.handleQuestionWrong(player, question)` on wrong answer

#### 2. Copyright Purchase Dialog
**When**: `onCopyrightPurchaseOffered` callback is triggered

**Display**:
```
┌─────────────────────────────────┐
│  Doğru Cevap!              │
│                              │
│  +{starReward} yıldız kazandın! │
│                              │
│  ─────────────────────────   │
│                              │
│  Telif: {tile.name}         │
│  Fiyat: {cost} yıldız      │
│  Bakiye: {balance} yıldız    │
│                              │
│  [Satın Al]  [Atla]       │
└─────────────────────────────────┘
```

**Callbacks to call**:
- `gameEngine.handleCopyrightPurchase(player, tile)` on "Satın Al" (Buy)
- `gameEngine.handleCopyrightSkip(player, tile)` on "Atla" (Skip)

#### 3. Rent Paid Notification
**When**: `onRentPaid` callback is triggered

**Display**: Toast or banner showing rent payment
- Example: "Ahmet kira ödedi: -20 yıldız → Mehmet: +20 yıldız"

**Duration**: 3-5 seconds (auto-dismiss)

#### 4. Question Answer Feedback
**When**: `onQuestionAnswered` callback is triggered

**Display**: 
- Correct: Green banner with star reward
- Wrong: Red banner (no points)

**Duration**: 2-3 seconds (auto-dismiss)

## Game Flow Examples

### Example 1: Unowned Book Tile - Correct Answer
```
1. Player rolls dice, lands on Tile 1 (Book Group 1)
2. GameEngine checks ownership: tile.owner == null
3. GameEngine triggers: onQuestionAsked(player, question)
4. UI shows question dialog: "Hangi yazar Tutunamayanlar romanının yazarıdır?"
5. Player answers: "Oğuz Atay" ✓ Correct!
6. UI calls: gameEngine.handleQuestionCorrect(player, tile, question)
7. GameEngine awards: +20 stars (easy question)
8. GameEngine triggers: onCopyrightPurchaseOffered(tile, player, 50, 170)
9. UI shows purchase dialog: "Correct! +20 points. Price: 50. Balance: 170. Buy?"
10. Player clicks "Satın Al" (Buy)
11. UI calls: gameEngine.handleCopyrightPurchase(player, tile)
12. GameEngine deducts: -50 stars, assigns ownership
13. Turn ends
```

### Example 2: Unowned Book Tile - Wrong Answer
```
1. Player rolls dice, lands on Tile 6 (Book Group 2)
2. GameEngine checks ownership: tile.owner == null
3. GameEngine triggers: onQuestionAsked(player, question)
4. UI shows question dialog: "İnce Memed romanının yazarı kimdir?"
5. Player answers: "Sabahattin Ali" ✗ Wrong!
6. UI shows: "Yanlış cevap! Puan kazanmadı."
7. UI calls: gameEngine.handleQuestionWrong(player, question)
8. GameEngine awards: 0 stars (no penalty)
9. Turn ends
```

### Example 3: Owned Book Tile - Rent
```
1. Player rolls dice, lands on Tile 15 (Publisher 2)
2. GameEngine checks ownership: tile.owner == "player2_id"
3. GameEngine calls: _collectRent(player, tile)
4. GameEngine finds owner: player2
5. GameEngine calculates rent: tile.copyrightFee = 25
6. GameEngine transfers: player (-25), owner (+25)
7. GameEngine triggers: onRentPaid("Ahmet kira ödedi: -25 yıldız → Mehmet: +25 yıldız")
8. UI shows rent notification toast
9. Turn ends
```

### Example 4: Owner Lands on Own Tile
```
1. Player rolls dice, lands on Tile 21 (Book Group 5)
2. GameEngine checks ownership: tile.owner == current_player.id
3. GameEngine logs: "Ahmet kendi telifine indi. İşlem gerekmiyor."
4. No actions taken
5. Turn ends
```

## Implementation Checklist

### Backend (GameEngine) ✅
- [x] QuestionRepository with dummy data
- [x] Question Phase trigger logic
- [x] Correct answer handling with star rewards
- [x] Wrong answer handling (no penalty)
- [x] Copyright purchase offer logic
- [x] Copyright purchase completion logic
- [x] Copyright skip logic
- [x] Rent collection logic
- [x] Bankruptcy checks (insufficient balance)
- [x] Library Watch exemption (no rent)
- [x] Owner bankruptcy exemption (no rent)

### UI Components ⏳
- [ ] Question dialog widget
- [ ] Copyright purchase dialog widget
- [ ] Rent paid toast notification
- [ ] Question answer feedback banner
- [ ] Integration with GameEngine callbacks
- [ ] Star balance updates in UI
- [ ] Ownership indicators on tiles

### Testing ⏳
- [ ] Test question display for each category
- [ ] Test correct answer → copyright purchase flow
- [ ] Test correct answer → skip purchase
- [ ] Test wrong answer → turn end
- [ ] Test rent collection on owned tiles
- [ ] Test insufficient balance for purchase
- [ ] Test owner landing on own tile
- [ ] Test library watch exemption from rent
- [ ] Test bankruptcy from rent payment
- [ ] Test multiple players with different ownership

## Game Rules Summary

### Question System
- **Trigger**: Landing on unowned Book/Publisher tiles
- **Categories**: 5 (Who Am I, Firsts, Movements, Arts, Works)
- **Rewards**: Easy=10, Medium=15, Hard=20 stars
- **Wrong Answer**: No penalty (as per requirements)

### Copyright Purchase
- **Offer**: After correct answer
- **Cost**: Tile.purchasePrice (varies by tile)
- **Ownership**: Assigned to player on purchase
- **Insufficient Balance**: Purchase blocked, turn continues

### Rent Collection
- **Trigger**: Landing on owned Book/Publisher tile
- **Amount**: Tile.copyrightFee (varies by tile)
- **Exemptions**: 
  - Owner in Library Watch
  - Owner is bankrupt
- **Bankruptcy**: Player goes bankrupt if can't pay rent

## Notes

1. **Star Rewards**: Questions provide income mechanism separate from copyright sales
2. **No Penalty on Wrong Answer**: Per task requirements, wrong answers don't deduct points
3. **Library Watch Protection**: Players in Library Watch don't collect rent but still pay rent
4. **Bankruptcy**: Triggered by rent payment inability or BANKRUPTCY RISK tile
5. **Counter-Clockwise Movement**: Players move 0→39→0 (increasing position)
6. **Pass START**: Awards 50 stars for completing a full loop

## Next Steps

1. **Create UI Dialogs**: Implement Question and Copyright Purchase dialogs
2. **Integrate Callbacks**: Connect GameEngine callbacks to UI components
3. **Test Full Flow**: Verify end-to-end question/economy/rent flow
4. **Add Visual Feedback**: Show ownership status on tiles
5. **Balance Updates**: Real-time star balance display updates
