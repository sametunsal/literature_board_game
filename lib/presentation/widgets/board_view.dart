import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../core/constants/game_constants.dart';
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
import 'board/board_visual_constants.dart';
import 'board/player_hud_manager.dart';
import 'board/game_controls_overlay.dart';
import 'board/turn_order_dialog.dart';
import 'animated_question_card.dart';
import 'progression_celebration_dialog.dart';
import '../dialogs/card_dialog.dart';
import '../dialogs/notification_dialogs.dart';
import '../dialogs/kiraathane_dialog.dart';
import '../dialogs/shop_dialog.dart';
import 'animations/card_deal_transition.dart';
import '../../models/game_card.dart';

// ════════════════════════════════════════════════════════════════════════════
// LAYOUT CONFIGURATION - 9x6 RECTANGULAR GRID (26 tiles, landscape)
// ════════════════════════════════════════════════════════════════════════════

/// Board layout (26 tiles on perimeter, standard 7/4 topology):
///
///   [13-Shop] [14] [15] [16] [17-Şans] [18] [19] [20] [21-Library]
///   [12-Cat ]                                        [22-Cat ]
///   [11-Teşvik]              CENTER AREA             [23-Cat ]
///   [10-Fate]                  (7x4)                 [24-Fate]
///   [9-Cat  ]                                        [25-Teşvik]
///   [8-Imza ] [7]  [6]  [5]  [4-Şans ] [3]  [2] [1] [0-Start]
///
/// Corners: 0 (Start/BR), 8 (İmza Günü/BL), 13 (Shop/TL), 21 (Library/TR)

// ════════════════════════════════════════════════════════════════════════════
// MAIN BOARD VIEW
// ════════════════════════════════════════════════════════════════════════════

/// Key of the board zone (left side of the gameplay Row). Exposed so layout
/// tests can assert the board and HUD rects never intersect.
const Key kBoardAreaKey = ValueKey('board_area');

/// Key of the right-side HUD column zone.
const Key kHudColumnKey = ValueKey('hud_column');

class BoardView extends ConsumerStatefulWidget {
  const BoardView({super.key});

  @override
  ConsumerState<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends ConsumerState<BoardView> {
  late ConfettiController _confettiController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showOpeningOverlay = true;
  bool _didScheduleOpeningFlow = false;

  @override
  void initState() {
    super.initState();
    // Immersive fullscreen — hide system UI overlays completely
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    // Force landscape orientation for game board
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleOpeningFlow();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
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
        // No dedicated victory asset ships with the game; the success sting
        // stands in for the fanfare.
        AudioManager.instance.playCorrect();

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

    // Two-zone gameplay layout: [ board area | right HUD column ]. The column
    // takes a fixed slice of the viewport width and the board area gets the
    // rest, so the two zones cannot overlap. The board is then sized from the
    // board area's own constraints (see _buildBoardArea), never from the full
    // screen size.
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 900;
    final showLogInColumn =
        screenSize.width >= kHudColumnLogMinWidth &&
        screenSize.height >= kHudColumnLogMinHeight;
    final hudColumnWidth = showLogInColumn
        ? kHudColumnLogWidth
        : (isMobile ? kHudColumnCompactWidth : kHudColumnWideWidth);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: tokens.background,
      // The log lives in the drawer whenever it is not hosted in the column.
      drawer: !showLogInColumn
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
          // LAYER 1: Quiet premium backdrop
          // The board surface itself carries the visual richness now, so the
          // background stays a plain themed wash instead of a photographic
          // table that competes with the board for attention.
          // ═══════════════════════════════════════════════════════════════
          Positioned.fill(child: _buildBackdrop(tokens)),

          // ═══════════════════════════════════════════════════════════════
          // LAYER 2: Two-zone content — [ board area | HUD column ]
          // ═══════════════════════════════════════════════════════════════
          Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: KeyedSubtree(
                    key: kBoardAreaKey,
                    // The HUD column absorbs the right system inset, so the
                    // board area must not pad for it a second time.
                    child: MediaQuery.removePadding(
                      context: context,
                      removeRight: true,
                      child: _buildBoardArea(state, isDarkMode),
                    ),
                  ),
                ),
                _buildHudColumn(
                  state: state,
                  width: hudColumnWidth,
                  showLogInColumn: showLogInColumn,
                ),
              ],
            ),
          ),

          if (_showOpeningOverlay)
            Positioned.fill(child: _buildOpeningOverlay()),

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

          // ═════════════════════════════════════════════════════════════════════
          // FLAT DIALOG LAYER - All dialogs appear flat (orthogonal to screen)
          // This stays above the board transform so dialogs remain screen-aligned.
          // ═══════════════════════════════════════════════════════════════════════════
          // Dice-animation skip catcher — tap anywhere to reveal the result
          // early. Transparent so the rolling dice stay visible; active only
          // for a HUMAN roll (bot mode auto-plays the current turn, so the
          // catcher must never intercept bot rolls).
          if (state.isDiceRolling &&
              !ref.read(gameProvider.notifier).isBotPlaying)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    ref.read(gameProvider.notifier).skipDiceAnimation(),
                child: const SizedBox.expand(),
              ),
            ),

          _buildFlatDialogLayer(state, ref),

          // GAME OVER DIALOG REMOVED - Handled by Navigation
        ],
      ),
    );
  }

  /// Quiet themed wash behind both zones.
  Widget _buildBackdrop(ThemeTokens tokens) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.15, -0.2),
          radius: 1.15,
          colors: [
            tokens.backgroundHighlight,
            tokens.background,
            Color.lerp(tokens.background, Colors.black, 0.18) ??
                tokens.background,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }

  /// Left zone: the board, sized from this zone's own constraints.
  Widget _buildBoardArea(GameState state, bool isDarkMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardAreaSize = Size(constraints.maxWidth, constraints.maxHeight);
        final layout = BoardLayoutConfig.fromScreen(boardAreaSize);

        // FREEZE ANIMATIONS ON PAUSE
        return TickerMode(
          enabled: !state.isGamePaused,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 2.0,
                constrained: true,
                clipBehavior: Clip.none,
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
        );
      },
    );
  }

  /// Right zone: menu controls, the player panel list, and — where the
  /// viewport is large enough — the game log. Dice/roll controls deliberately
  /// stay in the board center.
  Widget _buildHudColumn({
    required GameState state,
    required double width,
    required bool showLogInColumn,
  }) {
    final tokens = ref.watch(themeProvider).tokens;

    return Container(
      key: kHudColumnKey,
      width: width,
      decoration: BoxDecoration(
        color: tokens.surface.withValues(alpha: 0.10),
        border: Border(
          left: BorderSide(
            color: GameTheme.goldAccent.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        left: false,
        child: Padding(
          padding: const EdgeInsets.all(kHudColumnPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GameControlsOverlay(embedded: true),
              const SizedBox(height: kHudColumnItemSpacing),

              // Player panels: scrollable so six players survive a 360dp-tall
              // landscape viewport without overflowing.
              Expanded(
                child: PlayerHudManager(
                  state: state,
                  mode: PlayerHudLayoutMode.column,
                ),
              ),

              if (showLogInColumn) ...[
                const SizedBox(height: kHudColumnItemSpacing),
                GameLog(
                  logs: state.logs,
                  players: state.players,
                  currentPlayerIndex: state.currentPlayerIndex,
                ),
              ] else ...[
                const SizedBox(height: kHudColumnItemSpacing),
                _buildLogDrawerButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the game-log drawer on viewports too short to host the log inline.
  Widget _buildLogDrawerButton() {
    return SizedBox(
      height: kMenuButtonSize * 0.75,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: GameTheme.goldAccent.withValues(alpha: 0.9),
          foregroundColor: GameTheme.tableBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: const Icon(Icons.bar_chart_rounded, size: 18),
        label: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Geçmiş'),
        ),
      ),
    );
  }

  Future<void> _scheduleOpeningFlow() async {
    if (_didScheduleOpeningFlow) return;
    _didScheduleOpeningFlow = true;

    await Future.delayed(
      const Duration(milliseconds: GameConstants.boardEntryIntroDelay),
    );
    if (!mounted) return;

    final state = ref.read(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    if (state.phase == GamePhase.rollingForOrder &&
        state.orderRolls.isEmpty &&
        !notifier.isTurnOrderProcessing) {
      notifier.startAutomatedTurnOrder();
    }

    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;

    setState(() => _showOpeningOverlay = false);
  }

  Widget _buildOpeningOverlay() {
    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        color: Colors.black.withValues(alpha: 0.42),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: GameTheme.goldAccent.withValues(alpha: 0.75),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: GameTheme.goldAccent,
                  size: 34,
                ),
                const SizedBox(height: 12),
                Text(
                  'Masa Hazırlanıyor',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: GameTheme.tableBackgroundColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Oyuncular yerleşiyor, sıra belirleme birazdan başlıyor.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build flat dialog layer - all dialogs appear orthogonal to screen.
  /// This prevents dialogs from inheriting the board transform.
  Widget _buildFlatDialogLayer(GameState state, WidgetRef ref) {
    final dialog = ref.watch(dialogProvider);

    return Stack(
      children: [
        // Turn Order Dialog
        if (dialog.showTurnOrderDialog)
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

        // Question Dialog with 3D Card Flip Animation
        if (dialog.showQuestionDialog && dialog.currentQuestion != null)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: AnimatedQuestionCard(
                question: dialog.currentQuestion!,
                onAnswer: (isCorrect) {
                  ref.read(gameProvider.notifier).answerQuestion(isCorrect);
                },
                onTimeExpired: () {
                  ref.read(gameProvider.notifier).answerQuestion(false);
                },
              ),
            ),
          ),

        // Card Dialog
        if (dialog.showCardDialog && dialog.currentCard != null)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: CardDealTransition(
                child: CardDialog(
                  card:
                      dialog.currentCard ??
                      const GameCard(
                        description: '',
                        effectType: CardEffectType.move,
                        type: CardType.sans,
                      ),
                ),
              ),
            ),
          ),

        // Library Penalty — soru kartı boyutu, ortada (tam ekran kart değil)
        if (dialog.showLibraryPenaltyDialog)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              alignment: Alignment.center,
              child: const LibraryPenaltyDialog(),
            ),
          ),

        // Printer Ink Issue Dialog — special themed dialog
        if (dialog.showPrinterIssueDialog)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              alignment: Alignment.center,
              child: const PrinterInkIssueDialog(),
            ),
          ),

        // Turn Skipped Dialog
        if (dialog.showTurnSkippedDialog)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.45),
              alignment: Alignment.center,
              child: const TurnSkippedDialog(),
            ),
          ),

        // İmza Günü — soru kartı boyutu, ortada
        if (dialog.showImzaGunuDialog)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              alignment: Alignment.center,
              child: const ImzaGunuDialog(),
            ),
          ),

        // Kiraathane Mesk dialog
        if (dialog.showKiraathaneDialog)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
              alignment: Alignment.center,
              child: const KiraathaneDialog(),
            ),
          ),

        // Shop Dialog
        if (dialog.showShopDialog)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: const ShopDialog(),
            ),
          ),

        // Progression celebration (book level upgrade) — centered,
        // self-clearing and non-blocking so play continues underneath.
        if (state.progressionCelebration != null)
          Positioned.fill(
            child: IgnorePointer(
              child: SafeArea(
                child: Center(
                  child: ProgressionCelebrationDialog(
                    celebration: state.progressionCelebration!,
                    onComplete: () {},
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
