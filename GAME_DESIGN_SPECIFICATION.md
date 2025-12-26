# Game Design Specification: Literature Board Game

## Overview
A Monopoly-inspired educational board game where players move around a literature-themed board, answering questions about Turkish literature (AYT and KPSS) to earn stars and purchase book copyrights.

---

## 1. Board Layout

### 1.1 Board Structure
- **Shape**: Square board
- **Total Tiles**: 40 tiles
- **Layout**: 9 tiles per side + 4 corners = 40 tiles
- **Corner Tile Ratio**: Corner tiles are 1.5:1 size ratio compared to edge tiles
- **Movement Direction**: Counter-clockwise (starting from BAŞLANGIÇ - bottom-left corner)

### 1.2 Tile Distribution

#### Corner Tiles (4)
1. **Tile 1: BAŞLANGIÇ (Start)** - Bottom-left corner
   - Players earn stars when passing this tile
   
2. **Tile 11: KÜTÜPHANE NÖBETİ (Library Watch)** - Top-left corner
   - Players skip current turn and next turn (2 total turns)
   
3. **Tile 21: İMZA GÜNÜ (Signing Day)** - Top-right corner
   - No action taken
   - Turn passes to next player
   
4. **Tile 31: İFLAS RİSKİ (Bankruptcy Risk)** - Bottom-right corner
   - Player loses 50% of their stars

#### Special Tiles (10)
- **4 YAYINEVİ (Publishing House)**: Tiles 6, 16, 26, 36
- **3 ŞANS (Chance)**: Tiles 8, 23, 37
- **3 KADER (Fate)**: Tiles 3, 18, 34
- **1 YAZARLIK OKULU (Writer's School)**: Tile 13
- **1 DE EĞİTİM VAKFI (DE Education Foundation)**: Tile 29
- **1 GELİR VERGİSİ (Income Tax)**: Tile 5
- **1 YAZARLIK VERGİSİ (Writer's Tax)**: Tile 39

#### Book Tiles (26)
- **8 Groups total**
  - 6 groups with 3 books each (18 tiles)
  - 2 groups with 2 books each (4 tiles)
- Book titles from Turkish and world literature

### 1.3 Complete Tile Sequence (Counter-Clockwise)

| Tile # | Type | Name |
|--------|------|------|
| 1 | CORNER | BAŞLANGIÇ |
| 2 | BOOK | 1.GRUP KİTAP |
| 3 | KADER | KADER KARTI |
| 4 | BOOK | 1.GRUP KİTAP |
| 5 | TAX | GELİR VERGİSİ |
| 6 | PUBLISHER | 1.YAYINEVİ |
| 7 | BOOK | 2.GRUP KİTAP |
| 8 | CHANCE | ŞANS KARTI |
| 9 | BOOK | 2.GRUP KİTAP |
| 10 | BOOK | 2.GRUP KİTAP |
| 11 | CORNER | KÜTÜPHANE NÖBETİ |
| 12 | BOOK | 3.GRUP KİTAP |
| 13 | SPECIAL | YAZARLIK OKULU |
| 14 | BOOK | 3.GRUP KİTAP |
| 15 | BOOK | 3.GRUP KİTAP |
| 16 | PUBLISHER | 2.YAYINEVİ |
| 17 | BOOK | 4.GRUP KİTAP |
| 18 | KADER | KADER KARTI |
| 19 | BOOK | 4.GRUP KİTAP |
| 20 | BOOK | 4.GRUP KİTAP |
| 21 | CORNER | İMZA GÜNÜ |
| 22 | BOOK | 5.GRUP KİTAP |
| 23 | CHANCE | ŞANS KARTI |
| 24 | BOOK | 5.GRUP KİTAP |
| 25 | BOOK | 5.GRUP KİTAP |
| 26 | PUBLISHER | 3.YAYINEVİ |
| 27 | BOOK | 6.GRUP KİTAP |
| 28 | BOOK | 6.GRUP KİTAP |
| 29 | SPECIAL | DE EĞİTİM VAKFI |
| 30 | BOOK | 6.GRUP KİTAP |
| 31 | CORNER | İFLAS RİSKİ |
| 32 | BOOK | 7.GRUP KİTAP |
| 33 | BOOK | 7.GRUP KİTAP |
| 34 | KADER | KADER KARTI |
| 35 | BOOK | 7.GRUP KİTAP |
| 36 | PUBLISHER | 4.YAYINEVİ |
| 37 | CHANCE | ŞANS KARTI |
| 38 | BOOK | 8.GRUP KİTAP |
| 39 | TAX | YAZARLIK VERGİSİ |
| 40 | BOOK | 8.GRUP KİTAP |

---

## 2. Tile Types and Behaviors

### 2.1 BAŞLANGIÇ (Start)
- **Location**: Tile 1 (bottom-left corner)
- **Behavior**: 
  - Players start here
  - Each time a player passes this tile, they earn bonus stars
  - No question is asked

### 2.2 KÜTÜPHANE NÖBETİ (Library Watch)
- **Location**: Tile 11 (top-left corner)
- **Behavior**:
  - Player loses current turn and next turn (2 turns total)
  - No questions or actions during this period
  - Turn passes to next player
  - After 2 turns, player can resume normal gameplay
- **Trigger**: Landing on tile OR 3x double dice

### 2.3 İMZA GÜNÜ (Signing Day)
- **Location**: Tile 21 (top-right corner)
- **Behavior**:
  - No action required
  - No penalty
  - Turn immediately passes to next player
  - Player does not lose a turn permanently

### 2.4 İFLAS RİSKİ (Bankruptcy Risk)
- **Location**: Tile 31 (bottom-right corner)
- **Behavior**:
  - Player loses 50% of their current star count
  - Calculation: `new_stars = floor(current_stars * 0.5)`
  - If stars reach 0, player is bankrupt (game over condition)

### 2.5 Book Tiles
- **Total**: 26 tiles
- **Groups**: 8 groups (6 groups of 3, 2 groups of 2)
- **Behavior**:
  1. Player lands on book tile
  2. If tile is owned by another player:
     - Pay copyright fee to owner
     - No question asked
     - Turn ends
  3. If tile is unowned:
     - Player is asked a literature question
     - If answer is CORRECT:
       - Earn question reward stars
       - Option to buy copyright with stars
       - If insufficient stars: keep reward stars only
       - If sufficient stars: deduct copyright fee, acquire ownership
     - If answer is INCORRECT:
       - No stars earned
       - Cannot buy copyright
       - Turn ends

### 2.6 YAYINEVİ (Publishing House)
- **Total**: 4 tiles (6, 16, 26, 36)
- **Behavior**:
  - Special property tiles
  - Higher copyright fees than regular books
  - Similar question/ownership mechanic as book tiles
  - Can be owned and generate income

### 2.7 ŞANS (Chance) Cards
- **Total**: 3 tiles (8, 23, 37)
- **Behavior**:
  - Player draws a random ŞANS card
  - ŞANS cards affect the current player personally
  - Examples: Earn stars, lose stars, free copyright, skip turn
  - No question asked
  - Turn ends after effect is applied

### 2.8 KADER (Fate) Cards
- **Total**: 3 tiles (3, 18, 34)
- **Behavior**:
  - Player draws a random KADER card
  - KADER cards can affect multiple players
  - Examples: All players lose stars, transfer stars between players, global events
  - No question asked
  - Turn ends after effect is applied

### 2.9 YAZARLIK OKULU (Writer's School)
- **Location**: Tile 13
- **Behavior**:
  - Special educational tile
  - Player receives a bonus question opportunity
  - Extra reward for correct answer
  - No penalty for incorrect answer
  - Turn ends after question

### 2.10 DE EĞİTİM VAKFI (DE Education Foundation)
- **Location**: Tile 29
- **Behavior**:
  - Special bonus tile
  - Player earns bonus stars
  - No question required
  - Turn ends after receiving bonus

### 2.11 GELİR VERGİSİ (Income Tax)
- **Location**: Tile 5
- **Behavior**:
  - Player pays fixed tax amount
  - Tax: 10% of current stars or fixed amount (whichever is lower)
  - No question asked
  - Turn ends after payment

### 2.12 YAZARLIK VERGİSİ (Writer's Tax)
- **Location**: Tile 39
- **Behavior**:
  - Player pays fixed tax amount
  - Tax: 15% of current stars or fixed amount (whichever is lower)
  - No question asked
  - Turn ends after payment

---

## 3. Question System

### 3.1 Question Categories
1. **BEN KİMİM?** (Who Am I?)
   - Questions about literary figures, authors, poets
   - Example: "I am the author of Seyahatname. Who am I?" → Evliya Çelebi

2. **TÜRK EDEBİYATINDA İLKLER** (Firsts in Turkish Literature)
   - Questions about pioneering works and achievements
   - Example: "Who wrote the first Turkish novel?" → Şemsettin Sami (İntibah)

3. **EDEBİYAT AKIMLARI** (Literary Movements)
   - Questions about literary periods, movements, and characteristics
   - Example: "Which movement is associated with Servet-i Fünun?" → Servet-i Fünun

4. **EDEBİYAT SANATLARI** (Literary Arts)
   - Questions about literary techniques, forms, and genres
   - Example: "What is the art of creating ambiguity through multiple meanings?" → İnaz

5. **ESER-KARAKTER** (Work-Character)
   - Questions connecting works with their characters
   - Example: "In which work does the character 'İlyas' appear?" → Huzur

### 3.2 Question Selection Logic
- **Random Selection**: When player lands on book tile, question is randomly selected from available pool
- **Category**: Randomly chosen from 5 categories
- **Difficulty**: Balanced mix of AYT and KPSS level questions
- **No Repetition**: Questions should not repeat within same game session if possible

### 3.3 Rewards and Penalties

#### Correct Answer
- **Star Reward**: Base reward + difficulty bonus
  - Easy: 10 stars
  - Medium: 15 stars
  - Hard: 20 stars
- **Copyright Option**: Player can spend stars to acquire book copyright
- **Tax Deduction**: Stars earned may reduce tax payment on tax tiles

#### Incorrect Answer
- **No Stars**: Player earns 0 stars for the question
- **No Copyright**: Cannot purchase copyright for this turn
- **Turn Ends**: Turn passes to next player
- **No Penalty**: No star deduction for wrong answer

---

## 4. Player State

### 4.1 Player Attributes
Each player maintains the following state:

1. **Player Name**: Unique identifier
2. **Player Color/Token**: Visual representation on board
3. **Star Count**: Currency for purchasing copyrights
   - Starting amount: 150 stars
   - Earned from: Correct answers, passing BAŞLANGIÇ, ŞANS cards
   - Lost from: Buying copyrights, taxes, İFLAS RİSKİ, KADER cards, copyright fees

4. **Position**: Current tile number (1-40)
   - Starts at tile 1 (BAŞLANGIÇ)
   - Moves counter-clockwise

5. **Owned Copyrights**: List of book/publisher tiles owned
   - Includes tile numbers, names, copyright fees
   - Generates income when other players land on them

6. **Library Watch Status**: Boolean flag
   - `true`: Player is in library watch (skipping turns)
   - `false`: Player can play normally

7. **Library Watch Turns Remaining**: Integer (0-2)
   - Tracks how many turns player must skip
   - Decrements by 1 each turn
   - When 0, player resumes normal play

8. **Double Dice Count**: Integer (0-3)
   - Tracks consecutive double dice rolls
   - Resets to 0 when non-double is rolled
   - When reaches 3, triggers Library Watch

9. **Bankrupt Status**: Boolean flag
   - `true`: Player has 0 or negative stars
   - `false`: Player is still in game

10. **Skipped Turn**: Boolean flag
    - `true`: Player's turn is being skipped (due to Library Watch or other effects)
    - `false`: Player can take normal turn

### 4.2 Player State Transitions

#### Normal Play
```
[Active] → [Roll Dice] → [Move] → [Tile Effect] → [Next Player]
```

#### Library Watch
```
[Active] → [Trigger Library Watch] → [Skip Turn 1] → [Skip Turn 2] → [Active]
```

#### Bankruptcy
```
[Active] → [Stars ≤ 0] → [Bankrupt] → [Game Over]
```

---

## 5. Turn Flow

### 5.1 Game Initialization
1. All players start with 150 stars
2. All players position at tile 1 (BAŞLANGIÇ)
3. Determine turn order:
   - Each player rolls 2 dice
   - Sort players by total dice value (highest to lowest)
   - If tie: tied players re-roll until order is determined

### 5.2 Turn Sequence (Standard)

#### Step 1: Check Turn Validity
- Is player in Library Watch?
  - **Yes**: Decrement remaining turns, skip to next player
  - **No**: Continue to Step 2

#### Step 2: Roll Dice
- Player rolls 2 dice (values 1-6)
- Calculate total: `dice1 + dice2`

#### Step 3: Check Double Dice
- Are dice values equal? (1-1, 2-2, 3-3, 4-4, 5-5, 6-6)
  - **Yes**: 
    - Increment double dice count
    - If double dice count == 3:
      - Trigger Library Watch (teleport to tile 11, skip 2 turns)
      - Turn ends
    - If double dice count < 3:
      - Player gets extra turn after current turn completes
  - **No**: 
    - Reset double dice count to 0

#### Step 4: Move Player
- Calculate new position: `(current_position + dice_total - 1) % 40 + 1`
- **Special Case - Passing BAŞLANGIÇ**:
  - If movement passes from tile 40 to tile 1:
    - Earn bonus stars (e.g., +50 stars)

#### Step 5: Tile Effect
Based on tile type:

**A. Book Tile / Publisher Tile**
1. Check if tile is owned:
   - **By current player**: No action, turn ends
   - **By another player**: Pay copyright fee to owner, turn ends
   - **Unowned**:
     a. Ask literature question (random category)
     b. If correct:
        - Earn reward stars
        - Ask: "Do you want to buy copyright?"
        - If yes AND sufficient stars:
          - Deduct copyright fee
          - Add tile to owned copyrights
        - If no OR insufficient stars:
          - Keep reward stars only
     c. If incorrect:
        - No stars earned
        - Cannot buy copyright
     d. Turn ends

**B. BAŞLANGIÇ (Tile 1)**
- No effect (already handled in Step 4)
- Turn ends

**C. KÜTÜPHANE NÖBETİ (Tile 11)**
- Set Library Watch status to true
- Set turns remaining to 2
- Turn ends

**D. İMZA GÜNÜ (Tile 21)**
- No action
- Turn ends

**E. İFLAS RİSKİ (Tile 31)**
- Reduce stars by 50%
- Check for bankruptcy
- Turn ends

**F. ŞANS Tile**
- Draw random ŞANS card
- Apply effect to current player
- Turn ends

**G. KADER Tile**
- Draw random KADER card
- Apply effect to affected players
- Turn ends

**H. YAZARLIK OKULU (Tile 13)**
- Ask bonus question
- If correct: Earn bonus reward stars
- Turn ends

**I. DE EĞİTİM VAKFI (Tile 29)**
- Earn bonus stars
- Turn ends

**J. GELİR VERGİSİ / YAZARLIK VERGİSİ**
- Calculate tax amount
- Deduct from stars
- Turn ends

#### Step 6: Determine Next Turn
- If player rolled double dice AND didn't trigger Library Watch:
  - Same player gets another turn
  - Return to Step 2
- Else:
  - Move to next player in turn order
  - Return to Step 1

### 5.3 Turn Flow Diagram
```
┌─────────────────────────────────────┐
│         START OF TURN              │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│    Is player in Library Watch?     │
│         (turns remaining > 0)       │
└─────────────┬───────────────────────┘
              │
    ┌─────────┴─────────┐
    │YES                │NO
    ▼                   ▼
┌─────────────┐   ┌─────────────────┐
│ Skip turn   │   │   Roll 2 Dice   │
│ Decrement   │   │   Calculate     │
│ turn count  │   │   total         │
└──────┬──────┘   └────────┬────────┘
       │                   │
       ▼                   ▼
┌─────────────┐   ┌─────────────────┐
│ Next Player │   │   Is double?    │
└─────────────┘   └────────┬────────┘
                           │
               ┌───────────┴───────────┐
               │YES                    │NO
               ▼                       ▼
      ┌────────────────┐     ┌─────────────────┐
      │ Increment      │     │ Reset count to  │
      │ double count   │     │       0         │
      └───────┬────────┘     └────────┬────────┘
              │                      │
              └──────────┬───────────┘
                         │
                         ▼
              ┌────────────────────┐
              │   Is count == 3?   │
              └─────────┬──────────┘
                        │
            ┌───────────┴───────────┐
            │YES                    │NO
            ▼                       ▼
   ┌──────────────────┐    ┌─────────────────┐
   │ Library Watch!   │    │   Move Player   │
   │ Teleport to 11   │    │   (check for    │
   │ Skip 2 turns     │    │   BAŞLANGIÇ)    │
   └────────┬─────────┘    └────────┬────────┘
            │                      │
            └──────────┬───────────┘
                       │
                       ▼
            ┌────────────────────┐
            │   Process Tile     │
            │   Effect (see      │
            │   Section 5.2)     │
            └─────────┬──────────┘
                      │
                      ▼
            ┌────────────────────┐
            │   Was double AND   │
            │   not Library      │
            │   Watch triggered? │
            └─────────┬──────────┘
                      │
          ┌───────────┴───────────┐
          │YES                    │NO
          ▼                       ▼
 ┌─────────────────┐     ┌─────────────────┐
 │ Same player     │     │   Next Player   │
 │ gets another    │     │                 │
 │ turn            │     │                 │
 └─────────────────┘     └─────────────────┘
```

---

## 6. Dice Rules

### 6.1 Standard Dice Rolling
- **Dice Count**: 2 dice per roll
- **Dice Values**: 1-6 for each die
- **Total Movement**: Sum of both dice (2-12)

### 6.2 Double Dice
- **Definition**: Both dice show same value (1-1, 2-2, 3-3, 4-4, 5-5, 6-6)
- **Effect**: Player gets an extra turn after current turn completes
- **Tracking**: Consecutive double dice are counted

### 6.3 Double Dice Counter
- **Starts at**: 0 at beginning of game or after non-double roll
- **Increments**: +1 each time double is rolled
- **Resets**: To 0 when non-double is rolled
- **Maximum**: 3

### 6.4 Library Watch Penalty (3x Double Dice)
- **Trigger Condition**: Player rolls double dice 3 times consecutively
- **Effect**:
  1. Player immediately teleported to tile 11 (KÜTÜPHANE NÖBETİ)
  2. Library Watch status set to `true`
  3. Turns remaining set to 2
  4. Current turn ends
  5. Next player takes turn
- **Recovery**:
  - After 2 turns are skipped, player returns to normal play
  - Double dice count reset to 0
  - Player continues from tile 11

### 6.5 Dice Probability
- **Total probability distribution**:
  - 2: 1/36 (2.78%)
  - 3: 2/36 (5.56%)
  - 4: 3/36 (8.33%)
  - 5: 4/36 (11.11%)
  - 6: 5/36 (13.89%)
  - 7: 6/36 (16.67%)
  - 8: 5/36 (13.89%)
  - 9: 4/36 (11.11%)
  - 10: 3/36 (8.33%)
  - 11: 2/36 (5.56%)
  - 12: 1/36 (2.78%)
- **Double probability**: 6/36 (16.67%)
- **3x Double probability**: (1/6)³ = 1/216 (0.46%)

---

## 7. Win Condition

### 7.1 Primary Win Condition
**Bankruptcy of All Other Players**
- When all but one player have 0 or negative stars, the remaining player wins
- A player is considered bankrupt when:
  - Their star count ≤ 0
  - They cannot pay required fees (copyright, taxes)
  - They land on İFLAS RİSKİ and lose 50% of stars (resulting in ≤ 0)

### 7.2 Alternative Win Condition (Optional)
**Copyright Monopoly**
- Player owns a certain percentage of all copyright tiles
- Example: Own 75% of all book and publisher tiles
- All other players go bankrupt trying to pay fees

### 7.3 Game End Scenarios

#### Scenario 1: Last Player Standing
1. Player A goes bankrupt (stars ≤ 0)
2. Player B continues playing
3. Player C continues playing
4. Eventually Player B goes bankrupt
5. **Player C wins**

#### Scenario 2: All Bankrupt in Same Turn
1. Multiple players go bankrupt simultaneously
2. If only one non-bankrupt player remains, they win
3. If all players go bankrupt, game ends in draw

#### Scenario 3: Voluntary Game End
- Players may agree to end game early
- Winner determined by highest star count and/or copyright value

---

## 8. Copyright System

### 8.1 Copyright Ownership
- **Acquisition**: Purchase with stars when answering questions correctly
- **Cost**: Varies by tile (books: 50-200 stars, publishers: 150-300 stars)
- **Transfer**: Cannot be transferred between players
- **Loss**: No loss of ownership (only bankruptcy ends game)

### 8.2 Copyright Fees
- **When Paid**: When another player lands on your copyright tile
- **Amount**: Fixed fee based on tile (rent)
- **Recipient**: Copyright owner
- **Payer**: Player who landed on tile (does not get question opportunity)

### 8.3 Copyright Groups
Copyrights are organized into groups to create color-coded monopoly opportunities:

**Group 1**: Tiles 2, 4 (2 books)
**Group 2**: Tiles 7, 9, 10 (3 books)
**Group 3**: Tiles 12, 14, 15 (3 books)
**Group 4**: Tiles 17, 19, 20 (3 books)
**Group 5**: Tiles 22, 24, 25 (3 books)
**Group 6**: Tiles 27, 28, 30 (3 books)
**Group 7**: Tiles 32, 33, 35 (3 books)
**Group 8**: Tiles 38, 40 (2 books)

**Publishers**: Tiles 6, 16, 26, 36 (4 independent tiles)

---

## 9. Special Cards

### 9.1 ŞANS (Chance) Cards
**Personal Effects (affect current player only)**

**Positive Examples**:
- "Yazarlık ödülü kazandınız! +30 yıldız."
- "Kütüphaneden ücretsiz kitap ödünç aldınız. +20 yıldız."
- "Bir eserinizi basıldı. +50 yıldız."
- "Vergi muafiyeti kazandınız. Sonraki vergi ödemenizi atlayın."

**Negative Examples**:
- "Yazarken bilgisayarınız bozuldu. -25 yıldız."
- "Kitabınızın kopyası çıktı. -40 yıldız."
- "Sağlık giderleriniz oldu. -30 yıldız."

**Neutral/Mixed**:
- "Önünüze bir seçenek geldi: +20 yıldız veya bir ücretsiz tur."
- "Bir eserinizi satmaya karar verdiniz. Starlarınızın %10'unu kaybedin ama bir sonraki soruyu zor sorabilirsiniz."

### 9.2 KADER (Fate) Cards
**Global Effects (can affect multiple players)**

**Examples**:
- "Edebiyat dünyasında büyük bir sarsıntı! Tüm oyuncular -20 yıldız kaybeder."
- "Bir yayınevi iflas etti! Sahibi olan tüm oyuncular -50 yıldız kaybeder."
- "Devlet desteği! Tüm oyuncular +30 yıldız kazanır."
- "Vergi affı! Tüm oyuncular sonraki vergi ödemelerini atlar."
- "En zengin yazar tüm yazarlara destek verir: En çok stara sahip olan oyuncu diğer tüm oyunculara +10 yıldız öder (düşükse etkilenmez)."
- "Yazarlık okulu kampı! Tüm oyuncular bir sonraki soruyu kolay seviyede alır."

---

## 10. Economic Balance

### 10.1 Star Flow

#### Income Sources
- Starting stars: 150 per player
- Correct answers: 10-20 stars
- Passing BAŞLANGIÇ: +50 stars
- ŞANS cards: -30 to +50 stars
- KADER cards: Variable (all players)
- YAZARLIK OKULU: +30 stars
- DE EĞİTİM VAKFI: +40 stars
- Copyright fees from other players: Variable

#### Expense Sources
- Buying copyrights: 50-300 stars
- Paying copyright fees: Variable (when landing on others' tiles)
- Taxes (GELİR VERGİSİ, YAZARLIK VERGİSİ): 10-15% of stars
- İFLAS RİSKİ: 50% of stars
- ŞANS cards: -30 stars
- KADER cards: Variable

### 10.2 Game Balance Considerations
- Average stars per turn: ~20-30 (from questions and events)
- Average expenses per turn: ~25-35 (copyrights, taxes, fees)
- Game duration target: 20-40 minutes for 2-4 players
- Star equilibrium designed to create competitive gameplay without runaway leaders

---

## 11. Technical Requirements

### 11.1 Board Visualization
- Square layout with 40 tiles
- Counter-clockwise numbering (1-40)
- Corner tiles: 1.5:1 size ratio
- Color-coded tiles by type/group
- Player tokens visible on current tile
- Copyright ownership indicators

### 11.2 UI Elements Required
- Dice display (2 dice with values)
- Player info panel (stars, position, owned copyrights)
- Question display area
- Answer options (multiple choice or input)
- Star transaction logs
- Turn indicator
- Card display (ŞANS/KADER)
- Copyright purchase confirmation

### 11.3 State Management
- Player state tracking
- Copyright ownership mapping
- Turn order management
- Dice rolling logic
- Question pool management
- Card deck management (ŞANS, KADER)
- Bankruptcy detection

---

## 12. Educational Content

### 12.1 Question Sources
- AYT (Yükseköğretim Kurumları Sınavı) Edebiyat
- KPSS (Kamu Personeli Seçme Sınavı) Edebiyat
- Turkish literature curriculum
- World literature classics

### 12.2 Difficulty Levels
- **Easy**: Basic knowledge, famous works and authors
- **Medium**: Moderate difficulty, requires deeper understanding
- **Hard**: Advanced knowledge, specific details and analysis

### 12.3 Learning Objectives
- Reinforce Turkish literature knowledge
- Familiarize players with literary movements and periods
- Learn about major authors and their works
- Understand literary techniques and forms
- Develop analytical skills in literature

---

## 13. Game Variations (Optional)

### 13.1 Time Limit Mode
- Set time limit per question (e.g., 30 seconds)
- Incorrect if not answered in time

### 13.2 Team Play
- Players form teams (2-3 players per team)
- Teams share stars and copyrights
- Collaborative answering

### 13.3 Expert Mode
- All questions are hard difficulty
- Higher star rewards
- More severe penalties

### 13.4 Quick Play
- Reduced starting stars (100)
- Fewer questions per turn
- Faster bankruptcy conditions

---

## Appendix A: Sample Questions

### A.1 BEN KİMİM?
1. "Ben, Türk edebiyatının ilk romanını yazdım. İntibah eserimin yazarıyım. Kimim?" → Şemsettin Sami
2. "Ben, Divan edebiyatının en büyük şairlerinden biriyim. Bâki lakabıyla anılırım. Kimim?" → Bâkî

### A.2 TÜRK EDEBİYATINDA İLKLER
1. "Türk edebiyatının ilk romanı hangisidir?" → İntibah
2. "İlk Türk roman yazarı kimdir?" → Şemsettin Sami

### A.3 EDEBİYAT AKIMLARI
1. "Servet-i Fünun dönemi edebiyat akımı hangi dönemdir?" → Sanat için sanat dönemi
2. "Milli Edebiyat dönemi hangi yılları kapsar?" → 1911-1923

### A.4 EDEBİYAT SANATLARI
1. "İnaz sanatı nedir?" - Kelimelerin birden fazla anlam içermesi
2. "Tecahül-i lâfiki sanatının özelliği nedir?" - İki şeyi birbirine benzetme

### A.5 ESER-KARAKTER
1. "İlyas karakteri hangi Ahmet Hamdi Tanpınar eserinde yer alır?" → Huzur
2. "İbiş karakteri kimin eserindedir?" → Namık Kemal (İntibah)

---

## Appendix B: Tile Metadata Template

### Book Tile
```json
{
  "id": 2,
  "type": "BOOK",
  "name": "İntibah",
  "group": 1,
  "copyright_fee": 75,
  "purchase_price": 150,
  "description": "Şemsettin Sami'nin romanı"
}
```

### Publisher Tile
```json
{
  "id": 6,
  "type": "PUBLISHER",
  "name": "İletişim Yayınları",
  "copyright_fee": 100,
  "purchase_price": 200
}
```

### Special Tile
```json
{
  "id": 11,
  "type": "CORNER",
  "name": "KÜTÜPHANE NÖBETİ",
  "effect": "SKIP_2_TURNS"
}
```

---

**Document Version**: 1.0  
**Last Updated**: 2025  
**Status**: Complete Specification
