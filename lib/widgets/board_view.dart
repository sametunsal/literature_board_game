import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/board_config.dart';
import '../models/game_enums.dart';
import '../models/player.dart';
import '../providers/game_notifier.dart';
import '../core/theme/game_theme.dart';
import 'enhanced_tile_widget.dart';
import 'game_log.dart';
import 'dice_roller.dart';
import 'question_dialog.dart';
import 'card_dialog.dart';
import 'copyright_purchase_dialog.dart';
import 'notification_dialogs.dart';
import 'pawn_widget.dart';
import 'pause_dialog.dart';
import 'settings_screen.dart';
import 'main_menu_screen.dart';
import 'game_over_dialog.dart';
import 'card_deck_widget.dart';
import '../utils/sound_manager.dart';

// ════════════════════════════════════════════════════════════════════════════
// LAYOUT CONFIGURATION
// ════════════════════════════════════════════════════════════════════════════

/// Cached layout calculations for the game board
/// Prevents recalculation on every build
class BoardLayoutConfig {
  final double boardSize;

  /// Base unit size (1/12 of board)
  late final double unitSize;

  /// Corner tile dimension (1.5 units)
  late final double cornerSize;

  /// Normal tile dimension (1 unit)
  late final double normalSize;

  /// Icon size ratio for center decoration
  static const double centerIconRatio = 0.3;

  /// Board size ratio relative to screen
  static const double boardToScreenRatio = 0.95;

  /// Grid units: 2 corners (1.5 each) + 9 normal tiles = 12 units total
  static const double totalGridUnits = 12.0;

  BoardLayoutConfig(this.boardSize) {
    unitSize = boardSize / totalGridUnits;
    cornerSize = unitSize * 1.5;
    normalSize = unitSize;
  }

  /// Factory to create from screen size (uses height in landscape for optimal fit)
  factory BoardLayoutConfig.fromScreen(Size screenSize) {
    // In landscape, height is the limiting dimension for the square board
    final shortestSide = screenSize.shortestSide;
    // Use slightly less of the screen to leave room for UI elements
    final availableSize = shortestSide * boardToScreenRatio;
    return BoardLayoutConfig(availableSize);
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

  // Landing pulse effect state
  int? _pulsingTileId;
  Map<String, int> _lastPlayerPositions = {};

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
    // Reset to portrait when leaving board view
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);

    // Check for player position changes to trigger landing pulse
    _checkForLandingPulse(state);

    // Trigger confetti and victory sound on game over
    if (state.phase == GamePhase.gameOver) {
      _confettiController.play();
      SoundManager.instance.playVictory();
    }

    // Calculate layout dimensions (use full screen size for landscape optimization)
    final screenSize = MediaQuery.of(context).size;
    final layout = BoardLayoutConfig.fromScreen(screenSize);

    return Scaffold(
      backgroundColor: GameTheme.tableBackgroundColor,
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════════
          // LAYER 1: Base Background Color
          // ═══════════════════════════════════════════════════════════════
          Container(decoration: GameTheme.tableDecoration),

          // ═══════════════════════════════════════════════════════════════
          // LAYER 2: Paper Noise Texture - Tactile Paper Effect
          // ═══════════════════════════════════════════════════════════════
          Opacity(
            opacity: 0.1,
            child: Image.asset(
              'assets/images/paper_noise.png',
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
          Center(child: _buildBoard(state, layout)),

          // LEFT SIDEBAR - GAME LOG / SCORE PANEL
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SafeArea(
              child: Container(
                width: 280,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: GameLog(
                  logs: state.logs,
                  players: state.players,
                  currentPlayerIndex: state.currentPlayerIndex,
                ),
              ),
            ),
          ),

          // PAUSE BUTTON (top-right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: _buildPauseButton(),
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
    return GestureDetector(
          onTap: () => setState(() => _showPauseMenu = true),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
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
            child: Icon(Icons.pause, color: GameTheme.goldAccent, size: 28),
          ),
        )
        .animate()
        .fadeIn(delay: 500.ms, duration: 400.ms)
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
  Widget _buildBoard(GameState state, BoardLayoutConfig layout) {
    return Container(
          width: layout.boardSize,
          height: layout.boardSize,
          decoration: GameTheme.boardDecoration,
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
        // Entrance animation chain
        .animate()
        .fadeIn(duration: 800.ms)
        .scale(
          begin: const Offset(1.05, 1.05),
          end: const Offset(1.0, 1.0),
          duration: 800.ms,
          curve: Curves.easeOutCubic,
        );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CENTER AREA
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildCenterArea(BoardLayoutConfig layout) {
    final state = ref.watch(gameProvider);
    final centerSize = layout.boardSize - (layout.cornerSize * 2);
    final deckSize = centerSize * 0.18; // Card deck size relative to center

    return Positioned(
      top: layout.cornerSize,
      left: layout.cornerSize,
      right: layout.cornerSize,
      bottom: layout.cornerSize,
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
                  size: layout.boardSize * BoardLayoutConfig.centerIconRatio,
                  color: GameTheme.textDark,
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // ŞANS CARD DECK (Top-Left, rotated 45°)
            // ═══════════════════════════════════════════════════════════════
            Positioned(
              top: centerSize * 0.08,
              left: centerSize * 0.08,
              child: CardDeckWidget(
                type: CardType.sans,
                size: deckSize,
                rotation: 0.35, // ~20 degrees
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // KADER CARD DECK (Bottom-Right, rotated -45°)
            // ═══════════════════════════════════════════════════════════════
            Positioned(
              bottom: centerSize * 0.08,
              right: centerSize * 0.08,
              child: CardDeckWidget(
                type: CardType.kader,
                size: deckSize,
                rotation: -0.35, // ~-20 degrees
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
  // TILE GENERATION
  // ════════════════════════════════════════════════════════════════════════════

  /// Generate all tiles (4 corners + 36 edge tiles)
  List<Widget> _buildAllTiles(BoardLayoutConfig layout) {
    return [
      // Corner tiles
      ..._buildCornerTiles(layout),

      // Edge tiles (4 edges x 9 tiles each)
      ..._buildLeftEdge(layout),
      ..._buildTopEdge(layout),
      ..._buildRightEdge(layout),
      ..._buildBottomEdge(layout),
    ];
  }

  /// Build the 4 corner tiles
  List<Widget> _buildCornerTiles(BoardLayoutConfig layout) {
    final L = layout;
    final S = L.boardSize;
    final C = L.cornerSize;

    return [
      // Bottom-Left (Start) - ID: 0
      _buildTile(id: 0, left: 0, top: S - C, width: C, height: C, rotation: 0),
      // Top-Left - ID: 10
      _buildTile(id: 10, left: 0, top: 0, width: C, height: C, rotation: 1),
      // Top-Right - ID: 20
      _buildTile(id: 20, left: S - C, top: 0, width: C, height: C, rotation: 2),
      // Bottom-Right - ID: 30
      _buildTile(
        id: 30,
        left: S - C,
        top: S - C,
        width: C,
        height: C,
        rotation: 3,
      ),
    ];
  }

  /// Left edge tiles (IDs 1-9, going upward)
  List<Widget> _buildLeftEdge(BoardLayoutConfig layout) {
    final L = layout;
    final S = L.boardSize;
    final C = L.cornerSize;
    final N = L.normalSize;

    return List.generate(9, (i) {
      final top = S - C - ((i + 1) * N);
      return _buildTile(
        id: 1 + i,
        left: 0,
        top: top,
        width: C,
        height: N,
        rotation: 3,
      );
    });
  }

  /// Top edge tiles (IDs 11-19, going rightward)
  List<Widget> _buildTopEdge(BoardLayoutConfig layout) {
    final L = layout;
    final C = L.cornerSize;
    final N = L.normalSize;

    return List.generate(9, (i) {
      final left = C + (i * N);
      return _buildTile(
        id: 11 + i,
        left: left,
        top: 0,
        width: N,
        height: C,
        rotation: 2,
      );
    });
  }

  /// Right edge tiles (IDs 21-29, going downward)
  List<Widget> _buildRightEdge(BoardLayoutConfig layout) {
    final L = layout;
    final S = L.boardSize;
    final C = L.cornerSize;
    final N = L.normalSize;

    return List.generate(9, (i) {
      final top = C + (i * N);
      return _buildTile(
        id: 21 + i,
        left: S - C,
        top: top,
        width: C,
        height: N,
        rotation: 1,
      );
    });
  }

  /// Bottom edge tiles (IDs 31-39, going leftward)
  List<Widget> _buildBottomEdge(BoardLayoutConfig layout) {
    final L = layout;
    final S = L.boardSize;
    final C = L.cornerSize;
    final N = L.normalSize;

    return List.generate(9, (i) {
      final left = S - C - ((i + 1) * N);
      return _buildTile(
        id: 31 + i,
        left: left,
        top: S - C,
        width: N,
        height: C,
        rotation: 0,
      );
    });
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

    // Tile widget
    Widget tileWidget = EnhancedTileWidget(
      tile: tile,
      width: width,
      height: height,
      quarterTurns: rotation,
      owner: owner,
      calculatedRent: calculatedRent,
    );

    // Apply landing pulse animation if active
    if (isPulsing) {
      tileWidget = TweenAnimationBuilder<double>(
        key: ValueKey('pulse_$id'),
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
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
  void _checkForLandingPulse(GameState state) {
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
    // Group players by position
    final Map<int, List<Player>> groups = {};
    for (final player in players) {
      groups.putIfAbsent(player.position, () => []).add(player);
    }

    final currentPlayerId = ref.watch(
      gameProvider.select((s) => s.currentPlayer.id),
    );

    final List<Widget> widgets = [];

    groups.forEach((position, group) {
      final center = _getTileCenter(position, layout);
      final pawnAreaSize = layout.cornerSize;
      final pawnSize = layout.normalSize * 0.45;

      widgets.add(
        AnimatedPawnContainer(
          key: ValueKey('pawn_group_$position'),
          center: center,
          areaSize: pawnAreaSize,
          players: group,
          currentPlayerId: currentPlayerId,
          pawnSize: pawnSize,
        ),
      );
    });

    return widgets;
  }

  /// Calculate the center point of a tile for pawn positioning
  Offset _getTileCenter(int tileId, BoardLayoutConfig layout) {
    final S = layout.boardSize;
    final C = layout.cornerSize;
    final N = layout.normalSize;

    // Corner tiles
    if (tileId == 0) return Offset(C / 2, S - C / 2);
    if (tileId == 10) return Offset(C / 2, C / 2);
    if (tileId == 20) return Offset(S - C / 2, C / 2);
    if (tileId == 30) return Offset(S - C / 2, S - C / 2);

    // Left edge (1-9)
    if (tileId < 10) {
      final top = S - C - ((tileId) * N);
      return Offset(C / 2, top + N / 2);
    }

    // Top edge (11-19)
    if (tileId < 20) {
      final left = C + ((tileId - 11) * N);
      return Offset(left + N / 2, C / 2);
    }

    // Right edge (21-29)
    if (tileId < 30) {
      final top = C + ((tileId - 21) * N);
      return Offset(S - C / 2, top + N / 2);
    }

    // Bottom edge (31-39)
    final left = S - C - ((tileId - 30) * N);
    return Offset(left + N / 2, S - C / 2);
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
        _buildDialogOverlay(QuestionDialog(question: state.currentQuestion!)),

      if (state.showPurchaseDialog && state.currentTile != null)
        _buildDialogOverlay(CopyrightPurchaseDialog(tile: state.currentTile!)),

      if (state.showCardDialog && state.currentCard != null)
        _buildDialogOverlay(CardDialog(card: state.currentCard!)),

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

      if (state.showImzaGunuDialog) _buildDialogOverlay(const ImzaGunuDialog()),
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
              duration: GameTheme.dialogEntryDuration,
              curve: Curves.easeOutBack,
            )
            .fadeIn(),
      ),
    );
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
