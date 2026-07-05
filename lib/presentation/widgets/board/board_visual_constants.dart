/// Visual-only scale for the 3D dice animation in the board center.
const double kCenterDiceVisualScale = 0.68;

/// Visual scale for the Şans/Kader deck cards in the board center.
/// Kept separate from the dice/controls scales so the decks can grow to
/// balance the center area without touching the roll controls.
const double kCenterDeckVisualScale = 1.10;

/// Shared dimensions for every player HUD panel. All players — current, next,
/// or waiting — use the same panel size for a given screen class; turn
/// emphasis is paint-only (gradient, border, glow, badge) and must never
/// change these layout dimensions.
const double kPlayerHudWideWidth = 158;

/// HUD panel width on phone-sized screens: corner cards must leave the
/// landscape board visible and stay clear of the device frame.
const double kPlayerHudCompactWidth = 134;

/// Fixed HUD panel height (both screen classes) so panels are identical even
/// when badges or emphasis differ between players.
const double kPlayerHudHeight = 54;

/// Visual scale for the center roll controls ("Zar At" button area).
/// Kept separate from the dice scale so the button stays easy to tap while
/// the dice visuals shrink to balance with the 7/4 landscape board.
const double kCenterControlsVisualScale = 1.0;
