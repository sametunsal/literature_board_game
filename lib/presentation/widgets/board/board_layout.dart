import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

import '../../../../core/theme/game_theme.dart';
import '../../../../core/motion/motion_constants.dart';
import '../../../../core/utils/board_layout_config.dart';
import '../../../providers/game_notifier.dart';
import 'center_area.dart';
import 'tile_grid.dart';
import 'pawn_manager.dart';
import 'effects_overlay.dart';

/// Main board container rendered in Isometric 3D View.
///
/// Applies a Matrix4 perspective transform to the 2D tile grid, creating a
/// diamond-shaped, tilted board with simulated 3D thickness layers.
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
    final screenSize = MediaQuery.of(context).size;

    // ═══════════════════════════════════════════════════════════════
    // 3D ISOMETRIC TRANSFORM
    // 1. Perspective Depth: Realistic 3D foreshortening
    // 2. Rotate X: Tilt the board backward (~37 degrees)
    // 3. Rotate Z: Rotate 45° to create the diamond shape
    // ═══════════════════════════════════════════════════════════════
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // Perspective
      ..rotateX(-0.65)        // Tilt back (-37 degrees approx)
      ..rotateZ(0.785398);    // Rotate to diamond (45 degrees = pi/4)

    // The 45° Z-rotation turns the board into a diamond, expanding its
    // bounding box by sqrt(2). The X-tilt further compresses height.
    // We want the diamond to fill ~85% of screen width.
    final boardDiagonal = widget.layout.actualWidth * math.sqrt(2);
    final targetWidth = screenSize.width * 0.85;
    final scaleFactor = targetWidth / boardDiagonal;

    // Visual thickness of the board (shadow offset)
    const thicknessOffset = 8.0;

    Widget isometricBoard = Transform(
      transform: matrix,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ═══════════════════════════════════════════════════════════════
          // THICKNESS & SHADOW LAYERS (Underneath the board)
          // Multiple solid colored containers shifted along Y axis simulate
          // 3D depth thanks to the perspective transform.
          // ═══════════════════════════════════════════════════════════════
          ...List.generate(6, (index) {
            final offset = (index + 1) * 2.0;
            return Positioned(
              top: offset,
              left: offset,
              child: Container(
                width: widget.layout.actualWidth,
                height: widget.layout.actualHeight,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    const Color(0xFF8B5A2B), // Base brown
                    Colors.black,
                    (index / 5) * 0.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: index == 5
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 25,
                            spreadRadius: 5,
                            offset: const Offset(15, 15),
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),

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
                    ? const Color(0xFF3D2B1F)
                    : const Color(0xFF5D4037),
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
                // Center area background
                CenterArea(state: widget.state, layout: widget.layout),

                // All tiles (corners + edges)
                TileGrid(
                  layout: widget.layout,
                  currentPlayerPosition: widget.state.currentPlayer.position,
                  hoveredTileId: _hoveredTileId,
                  onHoverEnter: (id) => setState(() => _hoveredTileId = id),
                  onHoverExit: (id) => setState(() => _hoveredTileId = null),
                ),

                // Player pawns
                PawnManager(state: widget.state, layout: widget.layout),

                // Effects and dialogs
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
      ),
    );

    // Shift the board upward so the bottom doesn't overflow.
    // The isometric tilt pushes the visual center downward, so we compensate.
    final verticalOffset = screenSize.height * 0.08;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: verticalOffset),
        child: isometricBoard
            .animate()
            .fadeIn(duration: MotionDurations.slow.safe)
            .scale(
              begin: Offset(scaleFactor * 0.8, scaleFactor * 0.8),
              end: Offset(scaleFactor, scaleFactor),
              duration: MotionDurations.slow.safe,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}
