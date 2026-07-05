/// Visual-only scale for the 3D dice animation in the board center.
const double kCenterDiceVisualScale = 0.68;

/// Visual scale for the Şans/Kader deck cards in the board center.
/// Kept separate from the dice/controls scales so the decks can grow to
/// balance the center area without touching the roll controls.
const double kCenterDeckVisualScale = 1.10;

/// Visual scale for the center roll controls ("Zar At" button area).
/// Kept separate from the dice scale so the button stays easy to tap while
/// the dice visuals shrink to balance with the 7/4 landscape board.
const double kCenterControlsVisualScale = 1.0;
