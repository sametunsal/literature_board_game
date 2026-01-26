import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/board_config.dart';
import '../models/game_enums.dart';
import '../domain/entities/game_enums.dart' as domain;
import '../models/player.dart';
import '../providers/game_notifier.dart';
import '../providers/theme_notifier.dart';
import '../core/theme/game_theme.dart';
import '../core/motion/motion_constants.dart';
import '../core/assets/asset_cache.dart';
import 'enhanced_tile_widget.dart';
import 'game_log.dart';
import 'dice_roller.dart';
import 'modern_question_dialog.dart';
import 'card_dialog.dart';
import 'copyright_purchase_dialog.dart';
import 'notification_dialogs.dart';
import 'upgrade_dialog.dart';
import 'pawn_widget.dart';
import 'pause_dialog.dart';
import 'settings_screen.dart';
import 'main_menu_screen.dart';
import 'game_over_dialog.dart';
import 'card_deck_widget.dart';
import 'floating_score.dart';
import 'shop_dialog.dart';
import '../utils/sound_manager.dart';

// ════════════════════════════════════════════════════════════════════════════
// LAYOUT CONFIGURATION - 6x7 RECTANGULAR GRID (22 tiles)
// ════════════════════════════════════════════════════════════════════════════

/// Cached layout calculations for the 6x7 rectangular game board
///
/// Board Layout (22 tiles on perimeter):
///
///   [11-Shop] [12-Cat] [13-Cat] [14-Cat] [15-Cat] [16-Fate]  -- Top row
///   [10-Cat ]                                     [17-Cat ]
///   [9-Cat  ]                                     [18-Cat ]
///   [8-Cat  ]         CENTER AREA                 [19-Cat ]
///   [7-Cat  ]         (empty)                     [20-Cat ]
///   [6-Cat  ]                                     [21-Cat ]
///   [5-Şans ] [4-Cat ] [3-Cat ] [2-Cat ] [1-Cat ] [0-Start]  -- Bottom row
///
/// Corners: 0 (Start), 5 (Şans), 11 (Shop), 16 (Kader)
class BoardLayoutConfig {
  final double boardWidth;
  final double boardHeight;

  /// Number of columns (width in tiles)
  static const int gridCols = 6;

  /// Number of rows (height in tiles)
  static const int gridRows = 7;

  /// Total perimeter tiles
  static const int totalTiles = 22;

  /// Size of each tile (uniform)
  late final double tileSize;

  /// Icon size ratio for center decoration
  static const double centerIconRatio = 0.25;

  /// Board size ratio relative to screen
  static const double boardToScreenRatio = 0.92;

  BoardLayoutConfig({required this.boardWidth, required this.boardHeight}) {
    // Tile size is determined by the shorter dimension / its tile count
    final tileByWidth = boardWidth / gridCols;
    final tileByHeight = boardHeight / gridRows;
    tileSize = (tileByWidth < tileByHeight) ? tileByWidth : tileByHeight;
  }

  /// Corner tile size (same as normal for uniform grid)
  double get cornerSize => tileSize;

  /// Normal tile size (same as corner)
  double get normalSize => tileSize;

  /// Actual board dimensions based on tile size
  double get actualWidth => tileSize * gridCols;
  double get actualHeight => tileSize * gridRows;

  /// Factory to create from screen size (optimized for landscape)
  factory BoardLayoutConfig.fromScreen(Size screenSize) {
    // Use most of screen height (limiting factor in landscape)
    final availableHeight = screenSize.height * boardToScreenRatio;
    // Calculate width maintaining 6:7 aspect ratio
    final aspectRatio = gridCols / gridRows; // 6/7 ≈ 0.857
    final availableWidth = availableHeight * aspectRatio;

    return BoardLayoutConfig(
      boardWidth: availableWidth,
      boardHeight: availableHeight,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// MAIN BOARD VIEW
// ════════════════════════════════════════════════════════════════════════════

class BoardView extends ConsumerStatefulWidget {
  const BoardView({super.key});

  @override
  ConsumerState<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends ConsumerState<BoardView> {
  late ConfettiController _confettiController;
  bool _showPauseMenu = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Landing pulse effect state
  int? _pulsingTileId;
  final Map<String, int> _lastPlayerPositions = {};

  // Hover state for tiles (UI-only, no rebuilds)
  int? _hoveredTileId;

  @override
  void initState() {
    super.initState();
    // Force landscape orientation for game board
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    // Preload assets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AssetCache.preload(context);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    // Reset to allow any orientation when leaving board view
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final themeState = ref.watch(themeProvider);
    final isDarkMode = themeState.isDarkMode;
    final tokens = themeState.tokens;

    // Listen to game state changes
    ref.listen<GameState>(gameProvider, (previous, next) {
      _handleLandingPulse(next);

      if (previous?.phase != GamePhase.gameOver &&
          next.phase == GamePhase.gameOver) {
        _confettiController.play();
        SoundManager.instance.playVictory();
      }
    });

    // Calculate layout dimensions (use full screen size for landscape optimization)
    final screenSize = MediaQuery.of(context).size;
    final layout = BoardLayoutConfig.fromScreen(screenSize);
    final isMobile = screenSize.width < 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: tokens.background,
      drawer: isMobile
          ? Drawer(
              width: 300,
              backgroundColor: Colors.transparent,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: GameLog(
                    logs: state.logs,
                    players: state.players,
                    currentPlayerIndex: state.currentPlayerIndex,
                  ),
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════════
          // LAYER 1: Base Background Color
          // ═══════════════════════════════════════════════════════════════
          Container(decoration: GameTheme.tableDecorationFor(isDarkMode)),

          // ═══════════════════════════════════════════════════════════════
          // LAYER 2: Paper Noise Texture - Tactile Paper Effect
          // ═══════════════════════════════════════════════════════════════
          Opacity(
            opacity: 0.1,
            child: Image(
              image: AssetCache.instance.paperNoiseImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              colorBlendMode: BlendMode.multiply,
              color: Colors.white,
            ),
          ),

          // ═══════════════════════════════════════════════════════════════
          // LAYER 3: Game Board Content
          // ═══════════════════════════════════════════════════════════════
          Center(child: _buildBoard(state, layout, isDarkMode)),

          // NOTE: Sidebar removed for RPG mode - board takes center stage
          // Player stats are visible via corner tiles and dialogs

          // MOBILE MENU BUTTON (Opens Drawer)
          if (isMobile)
            Positioned(
              left: 16,
              top: 16,
              child: SafeArea(
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: GameTheme.goldAccent,
                  foregroundColor: GameTheme.tableBackgroundColor,
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  child: const Icon(Icons.bar_chart_rounded),
                ),
              ),
            ),

          // PAUSE BUTTON (top-right)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildPauseButton(),
              ),
            ),
          ),

          // PAUSE MENU OVERLAY
          if (_showPauseMenu) _buildPauseOverlay(),

          // CONFETTI (on top)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: math.pi / 2,
              maxBlastForce: 15,
              minBlastForce: 5,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.2,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
              ],
            ),
          ),

          // GAME OVER DIALOG (on top of confetti)
          if (state.phase == GamePhase.gameOver)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: const GameOverDialog(),
              ),
            ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PAUSE MENU
  // ════════════════════════════════════════════════════════════════════════════

  /// Build the pause button with glass decoration
  Widget _buildPauseButton() {
    final themeState = ref.watch(themeProvider);
    final isDarkMode = themeState.isDarkMode;
    final tokens = themeState.tokens;

    return GestureDetector(
          onTap: () => setState(() => _showPauseMenu = true),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tokens.surface.withValues(alpha: isDarkMode ? 0.15 : 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: tokens.surface.withValues(alpha: isDarkMode ? 0.2 : 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.pause, color: tokens.accent, size: 28),
          ),
        )
        .animate()
        .fadeIn(
          delay: MotionDurations.slow.safe,
          duration: MotionDurations.pulse.safe,
        )
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  /// Build the pause menu overlay
  Widget _buildPauseOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: PauseDialog(
          onResume: () => setState(() => _showPauseMenu = false),
          onSettings: () {
            setState(() => _showPauseMenu = false);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          onEndGame: () {
            setState(() => _showPauseMenu = false);
            ref.read(gameProvider.notifier).endGame();
          },
          onExit: () {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainMenuScreen()),
              (route) => false,
            );
          },
        ),
      ),
    );
  }

  /// Main board container with all layers
  Widget _buildBoard(
    GameState state,
    BoardLayoutConfig layout,
    bool isDarkMode,
  ) {
    return Container(
          width: layout.actualWidth,
          height: layout.actualHeight,
          decoration: GameTheme.boardDecorationFor(isDarkMode),
          child: Stack(
            children: [
              // Layer 1: Center area background
              _buildCenterArea(layout),

              // Layer 2: All tiles (corners + edges)
              ..._buildAllTiles(layout),

              // Layer 3: Player pawns
              ..._buildPlayers(state.players, layout),

              // Layer 4: Effects and dialogs
              ..._buildEffectsAndDialogs(state, layout),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: MotionDurations.slow.safe)
        .scale(
          begin: const Offset(1.05, 1.05),
          end: const Offset(1.0, 1.0),
          duration: MotionDurations.slow.safe,
          curve: MotionCurves.standard,
        );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CENTER AREA
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildCenterArea(BoardLayoutConfig layout) {
    final state = ref.watch(gameProvider);
    final T = layout.tileSize;
    // Center area: inside the perimeter tiles
    // Width: 4 inner columns, Height: 5 inner rows
    final centerWidth = T * 4; // 6 - 2 edge tiles
    final centerHeight = T * 5; // 7 - 2 edge tiles
    final deckSize = math.min(centerWidth, centerHeight) * 0.20;

    return Positioned(
      top: T, // Below top edge
      left: T, // Right of left edge
      width: centerWidth,
      height: centerHeight,
      child: Container(
        decoration: BoxDecoration(
          // Parchment color for contrast with green table
          color: GameTheme.parchmentColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background icon (faded book)
            Center(
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.menu_book,
                  size:
                      math.min(centerWidth, centerHeight) *
                      BoardLayoutConfig.centerIconRatio,
                  color: GameTheme.textDark,
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // ŞANS CARD DECK (Top-Left, rotated)
            // ═══════════════════════════════════════════════════════════════
            Positioned(
              top: centerHeight * 0.08,
              left: centerWidth * 0.08,
              child: CardDeckWidget(
                type: CardType.sans,
                size: deckSize,
                rotation: 0.35,
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // KADER CARD DECK (Bottom-Right, rotated)
            // ═══════════════════════════════════════════════════════════════
            Positioned(
              bottom: centerHeight * 0.08,
              right: centerWidth * 0.08,
              child: CardDeckWidget(
                type: CardType.kader,
                size: deckSize,
                rotation: 0.35,
              ),
            ),

            // HUD content (center)
            Center(child: _buildHUD(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildHUD(GameState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Game title with gold accent
        Text(
          'EDEBİNA',
          style: GameTheme.hudTitleStyle.copyWith(
            color: GameTheme.goldAccent,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(2, 3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const DiceRoller(),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TILE GENERATION - 6x7 GRID (22 tiles)
  // ════════════════════════════════════════════════════════════════════════════
  //
  // Board Layout (tile IDs):
  //
  //   [11] [12] [13] [14] [15] [16]   <- Top row (left to right)
  //   [10]                     [17]
  //   [9]                      [18]
  //   [8]       CENTER         [19]   <- Left/Right columns
  //   [7]                      [20]
  //   [6]                      [21]
  //   [5]  [4]  [3]  [2]  [1]  [0]    <- Bottom row (right to left from Start)
  //
  // Movement: Clockwise starting from 0 (bottom-right)
  // Corners: 0 (Start), 5 (Şans), 11 (Shop), 16 (Kader)

  /// Generate all 22 tiles for 6x7 grid
  List<Widget> _buildAllTiles(BoardLayoutConfig layout) {
    final T = layout.tileSize;
    final W = layout.actualWidth;
    final H = layout.actualHeight;

    return [
      // ═════════════════════════════════════════════════════════════════════
      // BOTTOM ROW (IDs 0-5): Right to Left, from Start to Şans
      // ═════════════════════════════════════════════════════════════════════
      // 0: Start (Bottom-Right Corner)
      _buildTile(
        id: 0,
        left: W - T,
        top: H - T,
        width: T,
        height: T,
        rotation: 0,
      ),
      // 1-4: Bottom edge tiles (going left)
      _buildTile(
        id: 1,
        left: W - T * 2,
        top: H - T,
        width: T,
        height: T,
        rotation: 0,
      ),
      _buildTile(
        id: 2,
        left: W - T * 3,
        top: H - T,
        width: T,
        height: T,
        rotation: 0,
      ),
      _buildTile(
        id: 3,
        left: W - T * 4,
        top: H - T,
        width: T,
        height: T,
        rotation: 0,
      ),
      _buildTile(
        id: 4,
        left: W - T * 5,
        top: H - T,
        width: T,
        height: T,
        rotation: 0,
      ),
      // 5: Şans (Bottom-Left Corner)
      _buildTile(id: 5, left: 0, top: H - T, width: T, height: T, rotation: 0),

      // ═════════════════════════════════════════════════════════════════════
      // LEFT COLUMN (IDs 6-10): Bottom to Top
      // ═════════════════════════════════════════════════════════════════════
      _buildTile(
        id: 6,
        left: 0,
        top: H - T * 2,
        width: T,
        height: T,
        rotation: 3,
      ),
      _buildTile(
        id: 7,
        left: 0,
        top: H - T * 3,
        width: T,
        height: T,
        rotation: 3,
      ),
      _buildTile(
        id: 8,
        left: 0,
        top: H - T * 4,
        width: T,
        height: T,
        rotation: 3,
      ),
      _buildTile(
        id: 9,
        left: 0,
        top: H - T * 5,
        width: T,
        height: T,
        rotation: 3,
      ),
      _buildTile(
        id: 10,
        left: 0,
        top: H - T * 6,
        width: T,
        height: T,
        rotation: 3,
      ),

      // ═════════════════════════════════════════════════════════════════════
      // TOP ROW (IDs 11-16): Left to Right, from Shop to Kader
      // ═════════════════════════════════════════════════════════════════════
      // 11: Shop/Kıraathane (Top-Left Corner)
      _buildTile(id: 11, left: 0, top: 0, width: T, height: T, rotation: 2),
      // 12-15: Top edge tiles (going right)
      _buildTile(id: 12, left: T, top: 0, width: T, height: T, rotation: 2),
      _buildTile(id: 13, left: T * 2, top: 0, width: T, height: T, rotation: 2),
      _buildTile(id: 14, left: T * 3, top: 0, width: T, height: T, rotation: 2),
      _buildTile(id: 15, left: T * 4, top: 0, width: T, height: T, rotation: 2),
      // 16: Kader (Top-Right Corner)
      _buildTile(id: 16, left: W - T, top: 0, width: T, height: T, rotation: 2),

      // ═════════════════════════════════════════════════════════════════════
      // RIGHT COLUMN (IDs 17-21): Top to Bottom
      // ═════════════════════════════════════════════════════════════════════
      _buildTile(id: 17, left: W - T, top: T, width: T, height: T, rotation: 1),
      _buildTile(
        id: 18,
        left: W - T,
        top: T * 2,
        width: T,
        height: T,
        rotation: 1,
      ),
      _buildTile(
        id: 19,
        left: W - T,
        top: T * 3,
        width: T,
        height: T,
        rotation: 1,
      ),
      _buildTile(
        id: 20,
        left: W - T,
        top: T * 4,
        width: T,
        height: T,
        rotation: 1,
      ),
      _buildTile(
        id: 21,
        left: W - T,
        top: T * 5,
        width: T,
        height: T,
        rotation: 1,
      ),
    ];
  }

  /// Build a single positioned tile using EnhancedTileWidget
  /// The widget handles its own internal orientation based on quarterTurns
  Widget _buildTile({
    required int id,
    required double left,
    required double top,
    required double width,
    required double height,
    required int rotation,
  }) {
    // Get tile data from BoardConfig
    final tile = BoardConfig.getTile(id);

    // Find owner from state
    final state = ref.watch(gameProvider);
    Player? owner;
    for (final player in state.players) {
      if (player.ownedTiles.contains(id)) {
        owner = player;
        break;
      }
    }

    // Calculate rent based on upgrade level
    int? calculatedRent;
    if (owner != null && tile.baseRent != null) {
      final multiplier = tile.upgradeLevel == 4 ? 10 : (tile.upgradeLevel + 1);
      calculatedRent = (tile.baseRent ?? 20) * multiplier;
    }

    // Check if this tile should pulse (landing effect)
    final isPulsing = _pulsingTileId == id;

    // Determine selection state: tile where current player's pawn is located
    final isSelected = id == state.currentPlayer.position;

    // Determine hover state: tile currently being hovered
    final isHovered = id == _hoveredTileId;

    // Tile widget wrapped in MouseRegion for hover tracking (Desktop/Web only)
    Widget tileWidget = MouseRegion(
      onEnter: (event) {
        // Only track hover on Desktop/Web (mobile has no hover)
        final isDesktopOrWeb =
            Theme.of(context).platform != TargetPlatform.android &&
            Theme.of(context).platform != TargetPlatform.iOS;
        if (isDesktopOrWeb) {
          setState(() => _hoveredTileId = id);
        }
      },
      onExit: (event) {
        final isDesktopOrWeb =
            Theme.of(context).platform != TargetPlatform.android &&
            Theme.of(context).platform != TargetPlatform.iOS;
        if (isDesktopOrWeb) {
          setState(() => _hoveredTileId = null);
        }
      },
      child: EnhancedTileWidget(
        tile: tile,
        width: width,
        height: height,
        quarterTurns: rotation,
        owner: owner,
        calculatedRent: calculatedRent,
        isSelected: isSelected,
        isHovered: isHovered,
      ),
    );

    // Apply landing pulse animation if active
    if (isPulsing) {
      tileWidget = TweenAnimationBuilder<double>(
        key: ValueKey('pulse_$id'),
        tween: Tween(begin: 0.0, end: 1.0),
        duration: MotionDurations.pulse.safe,
        curve: MotionCurves.emphasized,
        onEnd: () {
          // Clear pulse state after animation
          if (mounted && _pulsingTileId == id) {
            setState(() => _pulsingTileId = null);
          }
        },
        builder: (context, value, child) {
          // Scale animation: 1.0 -> 1.15 -> 1.0
          final scale = value < 0.5
              ? 1.0 +
                    (value * 2 * 0.15) // 1.0 to 1.15
              : 1.15 - ((value - 0.5) * 2 * 0.15); // 1.15 to 1.0

          // Border flash opacity: fade in then out
          final borderOpacity = value < 0.5 ? value * 2 : (1.0 - value) * 2;

          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: GameTheme.copperAccent.withValues(
                    alpha: borderOpacity * 0.8,
                  ),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: GameTheme.goldAccent.withValues(
                      alpha: borderOpacity * 0.4,
                    ),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: tileWidget,
      );
    }

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: tileWidget,
    );
  }

  /// Check for player position changes and trigger landing pulse
  void _handleLandingPulse(GameState state) {
    for (final player in state.players) {
      final lastPos = _lastPlayerPositions[player.id];
      final currentPos = player.position;

      // If position changed and player has moved (not first detection)
      if (lastPos != null && lastPos != currentPos) {
        // Only pulse if not already pulsing another tile
        if (_pulsingTileId == null) {
          // Haptic feedback for tile landing
          HapticFeedback.mediumImpact();
          SoundManager.instance.playTileLanding(); // Tile landing sound

          // Schedule pulse on next frame to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _pulsingTileId = currentPos);
            }
          });
        }
      }

      _lastPlayerPositions[player.id] = currentPos;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PLAYER PAWNS
  // ════════════════════════════════════════════════════════════════════════════

  /// Build positioned pawns for all players using AnimatedPawnContainer
  List<Widget> _buildPlayers(List<Player> players, BoardLayoutConfig layout) {
    // Group players by position ONLY to calculate overlap offsets
    final Map<int, List<Player>> groupMap = {};
    for (final player in players) {
      groupMap.putIfAbsent(player.position, () => []).add(player);
    }

    final currentPlayerId = ref.watch(
      gameProvider.select((s) => s.currentPlayer.id),
    );

    final List<Widget> widgets = [];

    // Render each player individually to ensure stable identity (Key) for movement animation
    for (final player in players) {
      final position = player.position;
      final group = groupMap[position] ?? [player];
      final indexInGroup = group.indexOf(player);
      final count = group.length;

      var center = _getTileCenter(position, layout);

      // Apply offset if multiple players on same tile to prevent exact overlap
      if (count > 1) {
        final offsetAmount = layout.normalSize * 0.15;
        double dx = 0;
        double dy = 0;

        if (count == 2) {
          dx = (indexInGroup == 0 ? -1 : 1) * offsetAmount * 0.7;
          dy = (indexInGroup == 0 ? -1 : 1) * offsetAmount * 0.7;
        } else if (count == 3) {
          if (indexInGroup == 0) dy = -offsetAmount;
          if (indexInGroup == 1) {
            dx = -offsetAmount;
            dy = offsetAmount * 0.5;
          }
          if (indexInGroup == 2) {
            dx = offsetAmount;
            dy = offsetAmount * 0.5;
          }
        } else {
          // 4+ players: 2x2 grid approx
          dx = ((indexInGroup % 2) == 0 ? -1 : 1) * offsetAmount * 0.7;
          dy = (indexInGroup < 2 ? -1 : 1) * offsetAmount * 0.7;
        }
        center = center.translate(dx, dy);
      }

      widgets.add(
        AnimatedPawnContainer(
          // STABLE KEY based on ID allows AnimatedPawnContainer to track movement
          key: ValueKey('pawn_${player.id}'),
          center: center,
          areaSize: layout.cornerSize,
          players: [player], // Pass single player to container
          currentPlayerId: currentPlayerId,
          pawnSize: layout.normalSize * 0.45,
        ),
      );
    }

    return widgets;
  }

  /// Calculate the center point of a tile for pawn positioning (22-tile grid)
  Offset _getTileCenter(int tileId, BoardLayoutConfig layout) {
    final T = layout.tileSize;
    final W = layout.actualWidth;
    final H = layout.actualHeight;
    final halfT = T / 2;

    // Invalid tile ID - default to start
    if (tileId < 0 || tileId >= 22) return Offset(W - halfT, H - halfT);

    // ═════════════════════════════════════════════════════════════════════
    // BOTTOM ROW (IDs 0-5): Right to Left
    // ═════════════════════════════════════════════════════════════════════
    if (tileId <= 5) {
      // X: Start from right edge, move left by tile index
      // 0 -> W - T/2, 1 -> W - 1.5T, 2 -> W - 2.5T, etc.
      final x = W - halfT - (tileId * T);
      final y = H - halfT;
      return Offset(x, y);
    }

    // ═════════════════════════════════════════════════════════════════════
    // LEFT COLUMN (IDs 6-10): Bottom to Top
    // ═════════════════════════════════════════════════════════════════════
    if (tileId <= 10) {
      final x = halfT;
      // 6 -> H - 1.5T, 7 -> H - 2.5T, etc.
      final y = H - halfT - ((tileId - 5) * T);
      return Offset(x, y);
    }

    // ═════════════════════════════════════════════════════════════════════
    // TOP ROW (IDs 11-16): Left to Right
    // ═════════════════════════════════════════════════════════════════════
    if (tileId <= 16) {
      // 11 -> T/2, 12 -> 1.5T, 13 -> 2.5T, etc.
      final x = halfT + ((tileId - 11) * T);
      final y = halfT;
      return Offset(x, y);
    }

    // ═════════════════════════════════════════════════════════════════════
    // RIGHT COLUMN (IDs 17-21): Top to Bottom
    // ═════════════════════════════════════════════════════════════════════
    final x = W - halfT;
    // 17 -> 1.5T, 18 -> 2.5T, etc.
    final y = halfT + ((tileId - 16) * T);
    return Offset(x, y);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // EFFECTS AND DIALOGS
  // ════════════════════════════════════════════════════════════════════════════

  /// Build all overlay effects and modal dialogs
  List<Widget> _buildEffectsAndDialogs(
    GameState state,
    BoardLayoutConfig layout,
  ) {
    return [
      // Confetti effect - shoots from bottom center with celebratory colors
      Align(
        alignment: Alignment.bottomCenter,
        child: ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          blastDirection: -3.14159 / 2, // Shoots upward (π/2 radians)
          emissionFrequency: 0.05,
          numberOfParticles: 30,
          maxBlastForce: 40,
          minBlastForce: 20,
          gravity: 0.1,
          particleDrag: 0.05,
          colors: const [
            Color(0xFFD4AF37), // Gold
            Color(0xFF1976D2), // Blue
            Color(0xFFD32F2F), // Red
            Color(0xFF388E3C), // Green
            Color(0xFFFFFFFF), // White
            Color(0xFFE91E63), // Pink
          ],
          createParticlePath: _drawStar,
        ),
      ),
      // Secondary confetti from top for rain effect
      Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.directional,
          blastDirection: 3.14159 / 2, // Shoots downward
          emissionFrequency: 0.03,
          numberOfParticles: 15,
          maxBlastForce: 10,
          minBlastForce: 5,
          gravity: 0.15,
          particleDrag: 0.02,
          colors: const [
            Color(0xFFD4AF37), // Gold
            Color(0xFF1976D2), // Blue
            Color(0xFFD32F2F), // Red
            Color(0xFF388E3C), // Green
          ],
        ),
      ),

      // Modal dialogs
      if (state.showQuestionDialog && state.currentQuestion != null)
        _buildDialogOverlay(
          ModernQuestionDialog(
            question: state.currentQuestion!.text,
            answer: state
                .currentQuestion!
                .options[state.currentQuestion!.correctIndex],
            category: _getCategoryString(state.currentQuestion!.category),
            onConfirm: () {
              ref.read(gameProvider.notifier).answerQuestion(true);
            },
            onCancel: () {
              ref.read(gameProvider.notifier).answerQuestion(false);
            },
          ),
        ),

      if (state.showPurchaseDialog && state.currentTile != null)
        _buildDialogOverlay(CopyrightPurchaseDialog(tile: state.currentTile!)),

      if (state.showCardDialog && state.currentCard != null)
        _buildDialogOverlay(CardDialog(card: state.currentCard!)),

      if (state.showUpgradeDialog && state.currentTile != null)
        _buildDialogOverlay(UpgradeDialog(tile: state.currentTile!)),

      // Notification dialogs
      if (state.showRentDialog &&
          state.rentOwnerName != null &&
          state.rentAmount != null)
        _buildDialogOverlay(
          RentNotificationDialog(
            ownerName: state.rentOwnerName!,
            rentAmount: state.rentAmount!,
          ),
        ),

      if (state.showLibraryPenaltyDialog)
        _buildDialogOverlay(const LibraryPenaltyDialog()),

      if (state.showTurnSkippedDialog)
        _buildDialogOverlay(const TurnSkippedDialog()),

      if (state.showImzaGunuDialog) _buildDialogOverlay(const ImzaGunuDialog()),

      // Shop Dialog (Kıraathane)
      if (state.showShopDialog) _buildDialogOverlay(const ShopDialog()),

      // Floating Score Effect (money changes)
      if (state.floatingEffect != null) _buildFloatingScore(state, layout),
    ];
  }

  /// Wrap dialog in overlay with animation
  Widget _buildDialogOverlay(Widget dialog) {
    return Container(
      color: GameTheme.dialogOverlayColor,
      child: Center(
        child: dialog
            .animate()
            .scale(
              duration: MotionDurations.dialog.safe,
              curve: MotionCurves.emphasized,
            )
            .fadeIn(),
      ),
    );
  }

  /// Build floating score effect positioned over current player's pawn
  Widget _buildFloatingScore(GameState state, BoardLayoutConfig layout) {
    final effect = state.floatingEffect!;
    final playerPosition = state.currentPlayer.position;
    final pawnCenter = _getTileCenter(playerPosition, layout);

    // Determine if score is positive based on text (starts with +)
    final isPositive = effect.text.startsWith('+');

    return Positioned(
      left: pawnCenter.dx - 60, // Center horizontally (approx text width/2)
      top: pawnCenter.dy - 80, // Position above pawn
      child: FloatingScore(
        key: ValueKey(
          'score_${effect.text}_${DateTime.now().millisecondsSinceEpoch}',
        ),
        text: effect.text,
        color: effect.color,
        isPositive: isPositive,
        onComplete: () {
          // Effect is auto-cleared by game_notifier after delay
          // No action needed here
        },
      ),
    );
  }

  /// Convert QuestionCategory enum to display string
  String _getCategoryString(domain.QuestionCategory category) {
    switch (category) {
      case domain.QuestionCategory.benKimim:
        return 'Ben Kimim?';
      case domain.QuestionCategory.turkEdebiyatindaIlkler:
        return 'İlkler';
      case domain.QuestionCategory.edebiyatAkimlari:
        return 'Edebi Akımlar';
      case domain.QuestionCategory.edebiSanatlar:
        return 'Edebi Sanatlar';
      case domain.QuestionCategory.eserKarakter:
        return 'Eser & Karakter';
      case domain.QuestionCategory.bonusBilgiler:
        return 'Bonus Bilgiler';
      default:
        return 'Genel Kültür';
    }
  }

  /// Custom star-shaped particle path for confetti
  Path _drawStar(Size size) {
    final path = Path();
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double outerRadius = size.width / 2;
    final double innerRadius = size.width / 4;
    const int points = 5;
    const double rotation = -math.pi / 2; // Start from top

    for (int i = 0; i < points * 2; i++) {
      final double radius = i.isEven ? outerRadius : innerRadius;
      final double angle = rotation + (i * math.pi / points);
      final double x = centerX + radius * math.cos(angle);
      final double y = centerY + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }
}
