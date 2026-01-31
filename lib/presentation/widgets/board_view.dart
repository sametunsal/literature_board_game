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
import '../screens/settings_screen.dart';
import '../screens/main_menu_screen.dart';
import '../dialogs/game_over_dialog.dart';
import 'player_scoreboard.dart';
import '../screens/collection_screen.dart';
import '../../core/managers/sound_manager.dart';
import '../../core/utils/board_layout_config.dart';
import '../../core/utils/board_layout_helper.dart';
import 'board/turn_order_dialog.dart';
import 'board/center_area.dart';
import 'board/tile_grid.dart';
import 'board/effects_overlay.dart';

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
          // LAYER 2: Game Board Content
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

          // PAUSE BUTTON (top-right) - moved to overlap with P2 scoreboard
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 60, right: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPauseButton(),
                    const SizedBox(height: 8),
                    _buildBotModeButton(),
                    const SizedBox(height: 8),
                    _buildDebugWinButton(),
                  ],
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════════════
          // CORNER SCOREBOARDS - Player stats at 4 corners
          // ═══════════════════════════════════════════════════════════════
          ..._buildCornerScoreboards(state),

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

  /// Build debug win button for testing victory logic
  Widget _buildDebugWinButton() {
    return GestureDetector(
          onTap: () {
            ref.read(gameProvider.notifier).debugTriggerWin();
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade700, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.emoji_events, color: Colors.white, size: 28),
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
          onCollection: () {
            setState(() => _showPauseMenu = false);
            final state = ref.read(gameProvider);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CollectionScreen(
                  collectedQuoteIds: state.currentPlayer.collectedQuotes,
                  playerName: state.currentPlayer.name,
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
  // CORNER SCOREBOARDS
  // ════════════════════════════════════════════════════════════════════════════

  /// Build corner scoreboards for all players (2-4 players supported)
  List<Widget> _buildCornerScoreboards(GameState state) {
    final players = state.players;
    if (players.isEmpty) return [];

    // Corner positions: [TopLeft, TopRight, BottomLeft, BottomRight]
    const alignments = [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomLeft,
      Alignment.bottomRight,
    ];

    return List.generate(players.length.clamp(0, 4), (index) {
      final player = players[index];
      final isCurrentPlayer = index == state.currentPlayerIndex;
      // Calculate next player index (wraps around)
      final nextPlayerIndex =
          (state.currentPlayerIndex + 1) % state.players.length;
      final isNext = index == nextPlayerIndex;
      final alignment = alignments[index];

      // Position based on alignment
      return Positioned(
        top: alignment == Alignment.topLeft || alignment == Alignment.topRight
            ? 0
            : null,
        bottom:
            alignment == Alignment.bottomLeft ||
                alignment == Alignment.bottomRight
            ? 0
            : null,
        left:
            alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
            ? 0
            : null,
        right:
            alignment == Alignment.topRight ||
                alignment == Alignment.bottomRight
            ? 0
            : null,
        child: SafeArea(
          child: PlayerScoreboard(
            player: player,
            isCurrentPlayer: isCurrentPlayer,
            isNext: isNext,
            alignment: alignment,
          ),
        ),
      );
    });
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

      var center = BoardLayoutHelper.getTileCenter(position, layout);

      // Apply offset if multiple players on same tile to prevent exact overlap
      if (count > 1) {
        final offset = BoardLayoutHelper.calculatePlayerOffset(
          indexInGroup,
          count,
          layout.normalSize,
        );
        center = center.translate(offset.dx, offset.dy);
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
}
