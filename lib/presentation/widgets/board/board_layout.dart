import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/game_theme.dart';
import '../../../../core/motion/motion_constants.dart';
import '../../../../core/utils/board_layout_config.dart';
import '../../../providers/game_notifier.dart';
import 'center_area.dart';
import 'tile_grid.dart';
import 'pawn_manager.dart';
import 'effects_overlay.dart';
import 'package:confetti/confetti.dart';

/// Main board container with all layers
/// Rendered in Top-Down 2D View
class BoardLayout extends StatefulWidget {
  final GameState state;
  final BoardLayoutConfig layout;
  final bool isDarkMode;
  final ConfettiController confettiController;
  final VoidCallback onQuestionConfirm;
  final VoidCallback onQuestionCancel;

  const BoardLayout({
    super.key,
    required this.state,
    required this.layout,
    required this.isDarkMode,
    required this.confettiController,
    required this.onQuestionConfirm,
    required this.onQuestionCancel,
  });

  @override
  State<BoardLayout> createState() => _BoardLayoutState();
}

class _BoardLayoutState extends State<BoardLayout> {
  int? _hoveredTileId;

  @override
  Widget build(BuildContext context) {
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
                width: widget.layout.actualWidth,
                height: widget.layout.actualHeight,
                decoration: BoxDecoration(
                  color: widget.isDarkMode
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
              width: widget.layout.actualWidth,
              height: widget.layout.actualHeight,
              decoration: GameTheme.boardDecorationFor(widget.isDarkMode),
              child: Stack(
                children: [
                  // Layer 1: Center area background
                  CenterArea(state: widget.state, layout: widget.layout),

                  // Layer 2: All tiles (corners + edges)
                  TileGrid(
                    layout: widget.layout,
                    currentPlayerPosition: widget.state.currentPlayer.position,
                    hoveredTileId: _hoveredTileId,
                    onHoverEnter: (id) => setState(() => _hoveredTileId = id),
                    onHoverExit: (id) => setState(() => _hoveredTileId = null),
                  ),

                  // Layer 3: Player pawns handled cleanly by manager
                  PawnManager(state: widget.state, layout: widget.layout),

                  // Layer 4: Effects and dialogs
                  EffectsOverlay(
                    state: widget.state,
                    layout: widget.layout,
                    confettiController: widget.confettiController,
                    onQuestionConfirm: widget.onQuestionConfirm,
                    onQuestionCancel: widget.onQuestionCancel,
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
}
