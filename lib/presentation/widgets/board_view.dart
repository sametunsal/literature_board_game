import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/game_enums.dart';
import '../../models/player.dart';
import '../../providers/game_notifier.dart';
import '../../providers/theme_notifier.dart';
import '../../core/theme/game_theme.dart';
import '../../core/motion/motion_constants.dart';
import 'game_log.dart';
import 'pawn_widget.dart';
import '../dialogs/pause_dialog.dart';
import '../dialogs/settings_dialog.dart';
import '../screens/main_menu_screen.dart';
import '../screens/victory_screen.dart';

import '../screens/collection_screen.dart';
import '../../core/managers/sound_manager.dart';
import '../../core/utils/board_layout_config.dart';
import '../../core/utils/board_layout_helper.dart';
import 'board/turn_order_dialog.dart';
import 'board/center_area.dart';
import 'board/tile_grid.dart';
import 'board/effects_overlay.dart';
import 'board/player_hud.dart';

// ════════════════════════════════════════════════════════════════════════════
// LAYOUT CONFIGURATION - 7x8 RECTANGULAR GRID (26 tiles)
// ════════════════════════════════════════════════════════════════════════════

/// Cached layout calculations for the 7x8 rectangular game board
///
/// Board Layout (26 tiles on perimeter):
///
///   [13-Shop] [14-Cat] [15-Cat] [16-Şans] [17-Cat] [18-Cat] [19-Cat]   -- Top row (up to corner)
///   [12-Cat ]                                                  [20-Library] -- Top-Right Corner
///   [11-Cat ]                                                  [21-Cat ]
///   [10-Fate]                  CENTER AREA                      [22-Fate]
///   [9-Cat  ]                    (5x6 empty)                    [23-Cat ]
///   [8-Cat  ]                                                   [24-Cat ]
///   [7-Imza ]                                                  [25-Cat ]   -- Bottom-Left Corner
///   [6-Cat ] [5-Cat ] [4-Cat ] [3-Şans ] [2-Cat ] [1-Cat ] [0-Start]  -- Bottom row
///
/// Corners: 0 (Start/BR), 7 (Imza Günü/BL), 13 (Shop/TL), 20 (Library/TR)

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
  }

  @override
  void dispose() {
    _confettiController.dispose();
    // Reset to allow any orientation when leaving board view
    SystemChrome.setPreferredOrientations([
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

        // Determine Winner
        final sortedPlayers = List<Player>.from(next.players)
          ..sort((a, b) => b.stars.compareTo(a.stars));
        final winner = sortedPlayers.isNotEmpty
            ? sortedPlayers.first
            : next.players.first;

        // Navigate to Victory Screen
        // Using addPostFrameCallback to ensure context is stable
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => VictoryScreen(winner: winner),
            ),
          );
        });
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
          // LAYER 1: Base Background Table Image
          // ═══════════════════════════════════════════════════════════════
          Positioned.fill(
            child: Image.asset(
              'assets/images/wooden_table_bg.png',
              key: const ValueKey('bg_updated_v2'), // Force refresh
              fit: BoxFit.cover,
            ),
          ),
          // LAYER 2: Contrast Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),

          // ═══════════════════════════════════════════════════════════════
          // LAYER 3: Game Board Content
          // ═══════════════════════════════════════════════════════════════
          // FREEZE ANIMATIONS ON PAUSE
          TickerMode(
            enabled: !state.isGamePaused,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildBoard(state, layout, isDarkMode),
                ),
              ),
            ),
          ),

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

          // PAUSE BUTTON (top-right) - moved to overlap with P2 scoreboard
          // PAUSE BUTTON (top-right) - Buttons float below the P2 Profile Card
          Positioned(
            top: 140, // Moved down to clear the player panel
            right: 16,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPauseButton(),
                  const SizedBox(height: 8),
                  _buildBotModeButton(),
                ],
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════════════
          // ═══════════════════════════════════════════════════════════════
          // PERIMETER PLAYER HUD (Corners & Sides)
          // ═══════════════════════════════════════════════════════════════
          ..._buildPlayerHuds(context, state),

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

          // TURN ORDER DIALOG - Shows final turn order after rolling phase
          if (state.showTurnOrderDialog)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: TurnOrderDialog(
                  players: state.players,
                  orderRolls: state.orderRolls,
                  onClose: () {
                    ref.read(gameProvider.notifier).closeTurnOrderDialog();
                  },
                ),
              ),
            ),

          // GAME OVER DIALOG REMOVED - Handled by Navigation
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
          onTap: () {
            ref.read(gameProvider.notifier).pauseGame();
            setState(() => _showPauseMenu = true);
          },
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

  /// Build the bot mode toggle button
  Widget _buildBotModeButton() {
    final themeState = ref.watch(themeProvider);
    final isDarkMode = themeState.isDarkMode;
    final tokens = themeState.tokens;
    final gameNotifier = ref.read(gameProvider.notifier);
    final isBotPlaying = gameNotifier.isBotPlaying;

    return GestureDetector(
          onTap: () {
            ref.read(gameProvider.notifier).toggleBotMode();
            // Force rebuild to update button appearance
            setState(() {});
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isBotPlaying
                  ? Colors.green.withValues(alpha: 0.9)
                  : tokens.surface.withValues(alpha: isDarkMode ? 0.15 : 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isBotPlaying
                    ? Colors.greenAccent
                    : tokens.surface.withValues(alpha: isDarkMode ? 0.2 : 0.5),
                width: isBotPlaying ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isBotPlaying
                      ? Colors.green.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: isBotPlaying ? Colors.white : tokens.accent,
              size: 28,
            ),
          ),
        )
        .animate(
          onPlay: (controller) {
            if (isBotPlaying) {
              controller.repeat();
            }
          },
        )
        .shimmer(
          duration: const Duration(seconds: 2),
          color: isBotPlaying
              ? Colors.greenAccent.withValues(alpha: 0.5)
              : Colors.transparent,
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 200),
        );
  }

  /// Build the pause menu overlay
  Widget _buildPauseOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: PauseDialog(
          onResume: () {
            ref.read(gameProvider.notifier).resumeGame();
            setState(() => _showPauseMenu = false);
          },
          onSettings: () {
            // Keep pause menu hidden or shown?
            // User requested: "Ensure... they see the EXACT same dialog"
            // Since SettingsDialog is a dialog, we can show it on top.
            // If we hide pause menu, we should confirm if we want to return to it.
            // For now, let's keep it simple as requested: show the dialog.
            // I will NOT hide the pause menu (_showPauseMenu = false) immediately if I want to keep context,
            // BUT the original code hid it.
            // If I hide it, the game is visible behind the settings dialog.
            // If I don't hide it, the pause menu is behind the settings dialog.
            // Original behavior: Hide pause menu, push SettingsScreen (full screen).
            // New behavior: Show SettingsDialog (modal).
            // I will hide the pause menu to match the previous logic of "leaving" the pause state partially,
            // or I can keep it because it's a dialog on top of a dialog?
            // SettingsDialog is transparent/modal.
            // Getting specific: "Replace... with showDialog... SettingsDialog".
            // I will do exactly that.
            showDialog(
              context: context,
              builder: (context) => const SettingsDialog(),
            );
          },

          onCollection: () {
            setState(() => _showPauseMenu = false);
            final state = ref.read(gameProvider);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CollectionScreen(
                  players: state.players,
                  initialPlayerIndex: state.currentPlayerIndex,
                ),
              ),
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
  /// Rendered in Top-Down 2D View
  Widget _buildBoard(
    GameState state,
    BoardLayoutConfig layout,
    bool isDarkMode,
  ) {
    // Visual thickness of the board (shadow offset)
    const thicknessOffset = 8.0;

    return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // ═══════════════════════════════════════════════════════════════
            // LAYER 0: Board Thickness (Dark cardboard backing)
            // ═══════════════════════════════════════════════════════════════
            Positioned(
              left: 0,
              top: thicknessOffset,
              child: Container(
                width: layout.actualWidth,
                height: layout.actualHeight,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF3D2B1F) // Dark brown for dark mode
                      : const Color(0xFF5D4037), // Medium brown for light mode
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // LAYER 1: Main Board Surface
            // ═══════════════════════════════════════════════════════════════
            Container(
              width: layout.actualWidth,
              height: layout.actualHeight,
              decoration: GameTheme.boardDecorationFor(isDarkMode),
              child: Stack(
                children: [
                  // Layer 1: Center area background
                  CenterArea(state: state, layout: layout),

                  // Layer 2: All tiles (corners + edges)
                  TileGrid(
                    layout: layout,
                    currentPlayerPosition: state.currentPlayer.position,
                    pulsingTileId: _pulsingTileId,
                    hoveredTileId: _hoveredTileId,
                    onHoverEnter: (id) => setState(() => _hoveredTileId = id),
                    onHoverExit: (id) => setState(() => _hoveredTileId = null),
                    onPulseComplete: () {
                      if (mounted) {
                        setState(() => _pulsingTileId = null);
                      }
                    },
                  ),

                  // Layer 3: Player pawns
                  ..._buildPlayers(state.players, layout),

                  // Layer 4: Effects and dialogs
                  EffectsOverlay(
                    state: state,
                    layout: layout,
                    confettiController: _confettiController,
                    onQuestionConfirm: () {
                      ref.read(gameProvider.notifier).answerQuestion(true);
                    },
                    onQuestionCancel: () {
                      ref.read(gameProvider.notifier).answerQuestion(false);
                    },
                  ),
                ],
              ),
            ),
          ],
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
  // PERIMETER HUD LAYOUT (2-6 Players)
  // ════════════════════════════════════════════════════════════════════════════

  /// Build player HUDS positioned around the perimeter of the board
  /// Rules:
  /// <= 4 Players: Corners only (TL, TR, BR, BL)
  /// > 4 Players: Corners + Middle Sides (TL, TR, MR, BR, BL, ML)
  List<Widget> _buildPlayerHuds(BuildContext context, GameState state) {
    final players = state.players;
    if (players.isEmpty) return [];

    final isMoreThanFour = players.length > 4;
    final currentPlayerId = state.players.isNotEmpty
        ? state.players[state.currentPlayerIndex].id
        : '';
    final nextIndex = (state.currentPlayerIndex + 1) % state.players.length;
    final nextPlayerId = state.players.isNotEmpty
        ? state.players[nextIndex].id
        : '';

    return List.generate(players.length, (index) {
      final player = players[index];
      final isCurrent = player.id == currentPlayerId;
      final isNext = player.id == nextPlayerId;

      // Determine Position based on Rules
      double? top, bottom, left, right;

      // Default corner logic (Index 0-3)
      // 0: TL, 1: TR, 2: BR/MR, 3: BL/BR

      if (!isMoreThanFour) {
        // STANDARD CORNER LAYOUT (<= 4 Players)
        switch (index) {
          case 0: // Top-Left
            top = 0;
            left = 0;
            break;
          case 1: // Top-Right
            top = 0;
            right = 0;
            break;
          case 2: // Bottom-Right
            bottom = 0;
            right = 0;
            break;
          case 3: // Bottom-Left
            bottom = 0;
            left = 0;
            break;
        }
      } else {
        // PERIMETER 6-POINT LAYOUT (> 4 Players)
        switch (index) {
          case 0: // Top-Left
            top = 0;
            left = 0;
            break;
          case 1: // Top-Right
            top = 0;
            right = 0;
            break;
          case 2: // Middle-Right
            // Vertical centering handled via Alignment in Positioned.fill/Align combo below
            top = 0;
            bottom = 0;
            right = 0;
            break;
          case 3: // Bottom-Right
            bottom = 0;
            right = 0;
            break;
          case 4: // Bottom-Left
            bottom = 0;
            left = 0;
            break;
          case 5: // Middle-Left
            // Vertical centering handled via Alignment below
            top = 0;
            bottom = 0;
            left = 0;
            break;
        }
      }

      // Safe Area flags
      bool safeTop = (top == 0 && bottom == 0) ? false : (top == 0);
      bool safeBottom = (top == 0 && bottom == 0) ? false : (bottom == 0);

      // Special handling for Middle slots (Index 2 & 5 when > 4)
      if (isMoreThanFour && (index == 2 || index == 5)) {
        return Positioned(
          top: 0,
          bottom: 0,
          left: index == 5 ? 0 : null,
          right: index == 2 ? 0 : null,
          child: Align(
            alignment: index == 2
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Padding(
              // Add vertical offset to Middle-Right (Index 2) to avoid PAUSE buttons if needed
              // Pushing down by 80px to clear the top-right button area
              padding: EdgeInsets.only(top: index == 2 ? 100 : 0),
              child: PlayerHud(
                player: player,
                isCurrentPlayer: isCurrent,
                isNextPlayer: isNext,
              ),
            ),
          ),
        );
      }

      // Standard Corner Positioning
      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: SafeArea(
          top: safeTop,
          bottom: safeBottom,
          child: PlayerHud(
            player: player,
            isCurrentPlayer: isCurrent,
            isNextPlayer: isNext,
          ),
        ),
      );
    });
  }

  /// Build positioned pawns for all players using AnimatedPawnContainer
  List<Widget> _buildPlayers(List<Player> players, BoardLayoutConfig layout) {
    // Group players by position (Tile ID)
    final Map<int, List<Player>> groupMap = {};
    for (final player in players) {
      groupMap.putIfAbsent(player.position, () => []).add(player);
    }

    final currentPlayerId = ref.watch(
      gameProvider.select((s) => s.currentPlayer.id),
    );

    final List<Widget> widgets = [];

    // Create ONE container per Tile Position
    groupMap.forEach((tileIndex, tilePlayers) {
      final center = BoardLayoutHelper.getTileCenter(tileIndex, layout);

      // Get exact dimensions for this tile (Standard, Corner, or Rectangular)
      final tileSize = BoardLayoutHelper.getTileSize(tileIndex, layout);

      widgets.add(
        AnimatedPawnContainer(
          // Use Tile Index in Key to keep container stable for that tile
          // Players will animate "into" this container's layout
          key: ValueKey('pawn_group_$tileIndex'),
          center: center,
          width: tileSize.width,
          height: tileSize.height,
          players: tilePlayers, // Pass ALL players on this tile
          currentPlayerId: currentPlayerId,
          pawnSize: layout.normalSize * 0.45,
        ),
      );
    });

    return widgets;
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
          // Audio now handled in GameNotifier._movePlayer() with pawn_step.wav

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
}
