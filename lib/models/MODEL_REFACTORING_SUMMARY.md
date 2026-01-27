# Model Refactoring Summary - TASK 1

## Overview
This document summarizes the model refactoring work completed for the Literature Quiz RPG game.

## Files Created/Modified

### New Models Created in lib/models/

1. **difficulty.dart** - Difficulty enum with values (Easy, Medium, Hard)
   - Includes extension for display names in Turkish
   - Location: `lib/models/difficulty.dart`

2. **tile_type.dart** - TileType enum with values (Start, Category, Corner, Shop, Collection)
   - Includes extension for display names in Turkish
   - Location: `lib/models/tile_type.dart`

3. **quote.dart** - Quote model for literary quotes
   - Properties: id, text, author, era, price, category
   - Includes fromJson/toJson methods
   - Location: `lib/models/quote.dart`

4. **board_config.dart** - Board configuration with 22 tiles
   - Generates exactly 22 tiles: 4 corners + 18 category tiles
   - Categories repeat 3 times (6 categories × 3 = 18 tiles)
   - Includes helper methods for board layout
   - Location: `lib/models/board_config.dart`

5. **user_entity.dart** - User entity for Firebase authentication
   - Copied from lib/domain/entities/
   - Location: `lib/models/user_entity.dart`

### Existing Models Updated

1. **player.dart** - Updated Player model
   - Added methods:
     - `addStars(int amount)` - Add stars to balance
     - `hasEnoughStars(int amount)` - Check if player has enough stars
     - `increaseCategoryLevel(String category)` - Increase level for a category
     - `getCategoryLevel(String category)` - Get rank name (Novice, Apprentice, Journeyman, Master)
     - `collectQuote(String quote)` - Collect a quote
     - `hasCollectedQuote(String quote)` - Check if quote is collected
     - `getTotalCollectedQuotes()` - Get total collected quotes
     - `isMasterInAllCategories()` - Check if Master in all 6 categories
     - `hasWon()` - Check win condition (50 quotes + Master in all categories)
   - Removed: No Monopoly-specific properties to remove (already clean)
   - Properties: stars, categoryLevels, collectedQuotes (already present)
   - Location: `lib/models/player.dart`

2. **board_tile.dart** - Updated BoardTile model
   - Changed id from `int` to `String`
   - Changed `title` to `name`
   - Added `position` property (0-21 for board positions)
   - Changed `category` from `QuestionCategory` enum to `String`
   - Added fromJson/toJson methods
   - Removed: No Monopoly-specific properties to remove (already clean)
   - Location: `lib/models/board_tile.dart`

### Imports Updated

1. **lib/providers/game_notifier.dart**
   - Changed: `import '../domain/entities/question.dart';` → `import '../models/question.dart';`

2. **lib/providers/firebase_providers.dart**
   - Changed: `import '../domain/entities/user_entity.dart';` → `import '../models/user_entity.dart';`

## Board Layout

The board configuration generates 22 tiles in the following layout:

### Corner Tiles (4)
- Position 0: BAŞLANGIÇ (Start)
- Position 5: ŞANS (Chance)
- Position 11: KIRAATHANE (Shop)
- Position 17: KADER (Fate)

### Category Tiles (18)
The 6 categories repeat 3 times around the board:

1. **Türk Edebiyatında İlkler** (turkEdebiyatindaIlkler)
2. **Edebi Sanatlar** (edebiSanatlar)
3. **Eser-Karakter** (eserKarakter)
4. **Edebiyat Akımları** (edebiyatAkimlari)
5. **Ben Kimim?** (benKimim)
6. **Teşvik** (tesvik)

### Difficulty Distribution
- Positions 1-9: Easy
- Positions 10-18: Medium
- Positions 19-21: Hard

## Key Changes

### Player Model
- Stars replace money as currency
- Category levels track progression (0=Novice, 1=Apprentice, 2=Journeyman, 3=Master)
- Collected quotes list for tracking progress
- Win condition: 50 quotes + Master in all 6 categories

### BoardTile Model
- String ID instead of integer
- Name property instead of title
- Position property for board placement
- String category instead of enum for flexibility
- Difficulty enum for question difficulty

### New Supporting Models
- Difficulty enum with Easy/Medium/Hard levels
- TileType enum with Start/Category/Corner/Shop/Collection types
- Quote model for literary quotes with era, price, category

## Notes

### Preserved Files
The following files in `lib/domain/entities/` are preserved to avoid breaking existing code:
- board_tile.dart
- game_card.dart
- game_enums.dart
- player.dart
- question.dart
- user_entity.dart

These files should be removed in a future task after all game logic and UI files are updated to use the new models in `lib/models/`.

### Expected Issues
The following errors are expected and will be resolved in future tasks:
- Type conflicts between old and new enum definitions
- Property name mismatches (title vs name, int id vs String id)
- Type mismatches (QuestionCategory enum vs String category)

These issues occur because existing game logic and UI files still use the old model structure. Updating these files is outside the scope of TASK 1.

## Next Steps (Future Tasks)
1. Update game logic files to use new models
2. Update UI files to use new models
3. Remove duplicate files from lib/domain/entities/
4. Test all functionality with new models

## Verification Checklist
- [x] All models consolidated into lib/models/
- [x] Player model updated with required properties and methods
- [x] BoardTile model updated with required properties
- [x] BoardConfig model created with 22 tiles
- [x] Difficulty enum created in separate file
- [x] TileType enum created in separate file
- [x] Quote model created
- [x] All imports updated to reference lib/models/
- [x] Documentation added to all models
- [ ] Remove lib/domain/entities/ directory (pending future task)
