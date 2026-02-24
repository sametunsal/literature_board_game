import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../models/game_enums.dart';
import '../../models/player.dart';
import '../../providers/game_notifier.dart';
import '../../providers/theme_notifier.dart';
import '../../core/theme/game_theme.dart';
import 'game_log.dart';
import '../screens/victory_screen.dart';

import '../../providers/dialog_provider.dart';
import '../../core/utils/board_layout_config.dart';
import '../../core/managers/audio_manager.dart';
import 'board/board_layout.dart';
import 'board/player_hud_manager.dart';
import 'board/game_controls_overlay.dart';
import 'board/turn_order_dialog.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      if (previous?.phase != GamePhase.gameOver &&
          next.phase == GamePhase.gameOver) {
        _confettiController.play();
        AudioManager.instance.playVictory();

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
                  child: BoardLayout(
                    state: state,
                    layout: layout,
                    isDarkMode: isDarkMode,
                    confettiController: _confettiController,
                    onQuestionConfirm: () {
                      ref.read(gameProvider.notifier).answerQuestion(true);
                    },
                    onQuestionCancel: () {
                      ref.read(gameProvider.notifier).answerQuestion(false);
                    },
                  ),
                ),
              ),
            ),
          ),

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

          // ═══════════════════════════════════════════════════════════════
          // GAME CONTROLS (Pause, Bot Mode)
          // ═══════════════════════════════════════════════════════════════
          const GameControlsOverlay(),

          // ═══════════════════════════════════════════════════════════════
          // PERIMETER PLAYER HUD (Corners & Sides)
          // ═══════════════════════════════════════════════════════════════
          PlayerHudManager(state: state),

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
          if (ref.watch(dialogProvider).showTurnOrderDialog)
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
}
