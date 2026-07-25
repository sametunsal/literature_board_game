/// Visual-only scale for the 3D dice animation in the board center.
const double kCenterDiceVisualScale = 0.64;

/// Visual scale for the Şans/Kader deck cards in the board center.
/// Kept separate from the dice/controls scales so the decks can grow to
/// balance the center area without touching the roll controls.
const double kCenterDeckVisualScale = 1.18;

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

/// Uniform gap between edge-anchored controls (player HUD panels, menu/action
/// buttons, the mobile log button) and the screen edge, applied in addition
/// to SafeArea. Shared so the button column and the HUD cards align on the
/// same edge line instead of each floating at its own offset.
const double kEdgeControlsInset = 8.0;

/// Square size of the edge menu/action buttons (pause, portfolio, bot mode).
/// 48dp keeps them comfortably tappable at the screen edge.
const double kMenuButtonSize = 48.0;

/// Vertical gap between stacked edge menu buttons.
const double kMenuButtonSpacing = 8.0;

/// Vertical clearance a corner player HUD panel occupies along its edge:
/// edge inset + panel height + a breathing gap. Controls stacked on the same
/// edge anchor beyond this so they never overlap the corner HUD cards.
const double kHudEdgeClearance = kEdgeControlsInset + kPlayerHudHeight + 8.0;

// ─── Right-side HUD column (board-first two-zone gameplay layout) ────────────
// The gameplay screen is a Row: [ board area | HUD column ]. The column takes
// a fixed width out of the viewport and the board area gets the rest, so the
// two zones can never overlap.

/// Inner padding of the right-side HUD column.
const double kHudColumnPadding = 10.0;

/// HUD column width on phone-class landscape screens (viewport width < 900).
/// Fits a compact player panel (134) plus column padding on both sides.
const double kHudColumnCompactWidth = 156.0;

/// HUD column width on larger screens. Fits a wide player panel (158) plus
/// column padding on both sides.
const double kHudColumnWideWidth = 180.0;

/// HUD column width when the column also hosts the game log inline. Sized to
/// the log panel's fixed 280dp width plus column padding on both sides.
const double kHudColumnLogWidth = 304.0;

/// Minimum viewport width before the game log may move from the drawer into
/// the HUD column. Below this the wider column would eat too much board area.
const double kHudColumnLogMinWidth = 1000.0;

/// Minimum viewport height before the game log may move from the drawer into
/// the HUD column. Short landscape screens keep the drawer/FAB affordance.
const double kHudColumnLogMinHeight = 620.0;

/// Vertical gap between the player panels stacked in the HUD column.
const double kHudColumnItemSpacing = 6.0;
