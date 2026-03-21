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
    final shortestSide = screenSize.shortestSide;
    final isMobile = screenSize.width < 900;
    final isSmallMobile = screenSize.width < 600;
    final isTinyScreen = shortestSide < 400;

    // ═══════════════════════════════════════════════════════════════
    // 3D ISOMETRIC TRANSFORM
    // 1. Perspective Depth: Realistic 3D foreshortening
    // 2. Rotate X: Tilt the board backward (reduced from -0.65 to -0.55 to raise far corner)
    // 3. Rotate Z: Rotate 45° to create the diamond shape
    // ═══════════════════════════════════════════════════════════════
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // Perspective
      ..rotateX(
        -0.55,
      ) // Reduced tilt to raise far corner (top-right) and make it less compressed
      ..rotateZ(0.785398); // Rotate to diamond (45 degrees = pi/4)

    // The 45° Z-rotation turns the board into a diamond, expanding its
    // bounding box by sqrt(2). The X-tilt further compresses height.
    // We want the diamond to fill the screen within safe bounds.
    // Use shortestSide to ensure board fits on any orientation/size.
    final boardDiagonal = widget.layout.actualWidth * math.sqrt(2);

    // Dynamic screen usage ratio based on screen size
    final screenUsageRatio = isTinyScreen
        ? 1.05
        : (isSmallMobile ? 1.02 : (isMobile ? 0.98 : 0.95));
    final targetWidth = shortestSide * screenUsageRatio;

    // Height constraint - ensure board fits vertically with safe area
    final boardHeight =
        widget.layout.actualHeight *
        math.sqrt(2) *
        0.7; // Approximate visual height
    final availableHeight =
        screenSize.height * 0.80; // 80% of screen height for board
    final maxScaleByWidth = targetWidth / boardDiagonal;
    final maxScaleByHeight = availableHeight / boardHeight;
    final scaleFactor = math.min(maxScaleByWidth, maxScaleByHeight);

    // Visual thickness of the board (shadow offset)
    // For isometric projection: all layers must use same positioning method
    final thicknessOffset = 12.0; // Fixed pixel offset for 3D depth effect

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
          // ═══════════════════════════════════════════════════════════════
          // THICKNESS & SHADOW LAYERS (Underneath the board)
          // Using Transform.translate to preserve center alignment after
          // Matrix4 transform. All layers rotate around the same pivot point.
          // ═══════════════════════════════════════════════════════════════
          ...List.generate(6, (index) {
            // Each layer is progressively offset to create 3D depth
            final layerOffset = (index + 1) * (thicknessOffset / 6);
            return Transform.translate(
              offset: Offset(layerOffset, layerOffset),
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

          // ═════════════════════════════════════════════════════════════
          // LAYER 0: Board Thickness (Dark cardboard backing)
          // ═══════════════════════════════════════════════════════════════
          Transform.translate(
            offset: Offset(thicknessOffset, thicknessOffset),
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

                // Effects only (confetti, floating score) - NO DIALOGS
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
    // Use more offset for smaller screens
    final verticalOffset =
        screenSize.height *
        (isTinyScreen ? 0.14 : (isSmallMobile ? 0.18 : 0.28));

    // Calculate extra space needed for isometric transform overflow
    // The diamond shape expands beyond the rectangular bounds
    final extraSpace =
        boardDiagonal *
        0.25; // 25% extra space for transform (increased from 15%)

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: verticalOffset),
            child: OverflowBox(
              minWidth: boardDiagonal * scaleFactor + extraSpace,
              maxWidth: boardDiagonal * scaleFactor + extraSpace,
              minHeight: boardHeight * scaleFactor + extraSpace,
              maxHeight: boardHeight * scaleFactor + extraSpace,
              alignment: Alignment.center,
              child: SizedBox(
                width: boardDiagonal * scaleFactor,
                height: boardHeight * scaleFactor,
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
            ),
          ),
        );
      },
    );
  }
}
