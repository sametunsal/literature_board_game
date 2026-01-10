import 'package:flutter/material.dart';
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

  /// Factory to create from screen size
  factory BoardLayoutConfig.fromScreen(double shortestSide) {
    return BoardLayoutConfig(shortestSide * boardToScreenRatio);
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

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);

    // Trigger confetti on game over
    if (state.phase == GamePhase.gameOver) {
      _confettiController.play();
    }

    // Calculate layout dimensions
    final screenShortest = MediaQuery.of(context).size.shortestSide;
    final layout = BoardLayoutConfig.fromScreen(screenShortest);

    return Scaffold(
      backgroundColor: GameTheme.backgroundTable.gradient != null
          ? null
          : GameTheme.primaryText,
      body: Container(
        decoration: GameTheme.backgroundTable,
        child: Center(child: _buildBoard(state, layout)),
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
        .animate()
        .fadeIn(duration: GameTheme.boardFadeDuration)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: GameTheme.boardEntryDuration,
          curve: Curves.easeOutBack,
        );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CENTER AREA
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildCenterArea(BoardLayoutConfig layout) {
    final state = ref.watch(gameProvider);

    return Positioned(
      top: layout.cornerSize,
      left: layout.cornerSize,
      right: layout.cornerSize,
      bottom: layout.cornerSize,
      child: Container(
        decoration: GameTheme.centerAreaDecoration,
        child: Stack(
          children: [
            // Background icon (faded book)
            Center(
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.menu_book,
                  size: layout.boardSize * BoardLayoutConfig.centerIconRatio,
                  color: Colors.white,
                ),
              ),
            ),
            // HUD content
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
        Text('EDEBİYAT', style: GameTheme.hudTitleStyle),
        const SizedBox(height: 10),
        const DiceRoller(),
        const SizedBox(height: 5),
        Text(state.lastAction, style: GameTheme.hudSubtitleStyle),
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
        rotation: 1,
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
        rotation: 3,
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

  /// Build a single positioned and rotated tile
  Widget _buildTile({
    required int id,
    required double left,
    required double top,
    required double width,
    required double height,
    required int rotation,
  }) {
    // For rotated tiles, swap internal dimensions
    final isRotated = rotation % 2 != 0;
    final internalWidth = isRotated ? height : width;
    final internalHeight = isRotated ? width : height;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: RotatedBox(
        quarterTurns: rotation,
        child: EnhancedTileWidget(
          tile: BoardConfig.getTile(id),
          width: internalWidth,
          height: internalHeight,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PLAYER PAWNS
  // ════════════════════════════════════════════════════════════════════════════

  /// Build positioned pawns for all players
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

      widgets.add(
        AnimatedPositioned(
          duration: GameTheme.pawnMoveDuration,
          curve: Curves.easeInOutCubic,
          left: center.dx - (pawnAreaSize / 2),
          top: center.dy - (pawnAreaSize / 2),
          child: SizedBox(
            width: pawnAreaSize,
            height: pawnAreaSize,
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 2,
                children: group
                    .map(
                      (p) => _buildPawn(
                        p,
                        layout.normalSize * 0.4,
                        currentPlayerId,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      );
    });

    return widgets;
  }

  /// Build a single pawn widget
  Widget _buildPawn(Player player, double size, String currentPlayerId) {
    final isActive = player.id == currentPlayerId;

    return Container(
      width: size,
      height: size,
      decoration: GameTheme.pawnDecoration(player.color, isActive: isActive),
      child: Icon(
        IconData(0xe000 + player.iconIndex, fontFamily: 'MaterialIcons'),
        size: size * 0.7,
        color: Colors.white,
      ),
    );
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
      // Confetti effect
      Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
        ),
      ),

      // Game log
      Positioned(
        bottom: layout.cornerSize + 10,
        right: layout.cornerSize + 10,
        child: GameLog(logs: state.logs),
      ),

      // Modal dialogs
      if (state.showQuestionDialog && state.currentQuestion != null)
        _buildDialogOverlay(QuestionDialog(question: state.currentQuestion!)),

      if (state.showPurchaseDialog && state.currentTile != null)
        _buildDialogOverlay(CopyrightPurchaseDialog(tile: state.currentTile!)),

      if (state.showCardDialog && state.currentCard != null)
        _buildDialogOverlay(CardDialog(card: state.currentCard!)),
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
}
