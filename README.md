# Literature Board Game

A Flutter-based board game inspired by classic literature. Players move around a 40-tile board, answering questions about famous books, managing money, and navigating special game mechanics.

## Features

### Core Game Mechanics
- **40-Tile Board**: Classic board game layout with literature-themed tiles
- **Dice Rolling**: Two-dice system with double mechanics
- **Player Movement**: Animated pawn movement around the board
- **Money Management**: Buy book tiles, pay rent, collect money when passing GO

### Special Rules
1. **Library Watch (3x Double Dice)**: When a player rolls doubles three times in a row, they are sent to Library Watch for 3 turns
2. **Bankrupt Risk (FATE Tiles)**: Landing on FATE tiles results in a 50% loss of money
3. **CHANCE Tiles**: Random effects including finding or losing money

### Tile Types
- **START**: Starting point, collect $200 when passing
- **BOOK**: Literature tiles with questions, prices, and rent values
- **FATE**: Risk tiles that can cause 50% money loss
- **CHANCE**: Random effect tiles

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/
│   ├── player.dart        # Player model with game state
│   └── tile.dart          # Tile model with categories
├── providers/
│   ├── game_provider.dart # Game state management
│   └── tile_provider.dart # 40-tile board data
├── views/
│   └── board_view.dart    # Main game board UI
└── widgets/
    └── tile_widget.dart   # Individual tile component
```

## How to Run

1. Ensure Flutter is installed on your system
2. Navigate to the project directory:
   ```bash
   cd literature_board_game
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Game Instructions

1. **Start**: The game begins with one player at START
2. **Roll Dice**: Click the "Roll Dice" button to move
3. **Navigate**: Your pawn (red circle) moves around the board
4. **Book Tiles**: Click on book tiles to see literature questions
5. **Special Tiles**:
   - FATE: Risk losing 50% of your money
   - CHANCE: Random positive or negative effects
6. **Double Dice**: Roll doubles to get an extra turn (3x = Library Watch)
7. **Pass GO**: Collect $200 each time you pass START

## Technologies Used

- **Flutter**: Cross-platform UI framework
- **Riverpod**: State management
- **Google Fonts**: Poppins typography
- **Font Awesome**: Icon library
- **UUID**: Unique player identification

## Tile Layout

The board consists of 40 tiles arranged as follows:
- START (Tile 0)
- Groups of Book tiles (2-4 tiles each)
- FATE and CHANCE tiles interspersed throughout
- Literature classics from Shakespeare to Dostoevsky

## Future Enhancements

- Multiplayer support (2-4 players)
- Question answering system with scoring
- Property ownership mechanics
- Trading between players
- More CHANCE and FATE effects
- Sound effects and animations
- Leaderboard and statistics

## License

This project is created for educational purposes.
