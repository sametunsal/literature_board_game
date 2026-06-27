import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

import '../../../../core/motion/motion_constants.dart';
import '../../../../core/theme/game_theme.dart';
import '../../../../core/utils/board_layout_config.dart';
import '../../../providers/game_notifier.dart';
import 'center_area.dart';
import 'effects_overlay.dart';
import 'pawn_manager.dart';
import 'tile_grid.dart';

/// Main board container rendered as a flat top-down board.
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.sizeOf(context);
        final mediaPadding = MediaQuery.paddingOf(context);
        final containerSize = Size(
          constraints.hasBoundedWidth ? constraints.maxWidth : mediaSize.width,
          constraints.hasBoundedHeight
              ? constraints.maxHeight
              : mediaSize.height,
        );
        final safeRect = Rect.fromLTRB(
          mediaPadding.left,
          mediaPadding.top,
          math.max(mediaPadding.left, containerSize.width - mediaPadding.right),
          math.max(
            mediaPadding.top,
            containerSize.height - mediaPadding.bottom,
          ),
        );
        final adjustedSafeRect = Rect.fromLTRB(
          safeRect.left,
          safeRect.top,
          safeRect.right,
          math.max(safeRect.top, safeRect.bottom - 8),
        );

        final shortestSide = adjustedSafeRect.size.shortestSide;
        final isMobile = adjustedSafeRect.width < 900;
        final isSmallMobile = adjustedSafeRect.width < 600;
        final isTinyScreen = shortestSide < 400;

        final boardMatrix = Matrix4.identity();
        const boardDepth = 6.0;

        final screenUsageRatio = isTinyScreen
            ? 1.0
            : (isSmallMobile ? 1.0 : (isMobile ? 0.98 : 0.95));
        final targetWidth = adjustedSafeRect.width * screenUsageRatio;
        final targetHeight = adjustedSafeRect.height * 0.99;
        const fitSafetyScale = 0.97;

        final projectedBounds = _projectedBoardBounds(
          boardMatrix,
          Size(
            widget.layout.actualWidth + boardDepth,
            widget.layout.actualHeight + boardDepth,
          ),
        );

        final policyScale = math.min(
          targetWidth / projectedBounds.width,
          targetHeight / projectedBounds.height,
        );
        final fitScale = math.min(
          adjustedSafeRect.width / projectedBounds.width,
          adjustedSafeRect.height / projectedBounds.height,
        );
        final scaleFactor = math.min(policyScale, fitScale) * fitSafetyScale;
        final visualSize = Size(
          projectedBounds.width * scaleFactor,
          projectedBounds.height * scaleFactor,
        );
        final boardSurface = _buildBoardSurface(boardDepth);

        return SizedBox(
          width: containerSize.width,
          height: containerSize.height,
          child: Stack(
            children: [
              Positioned.fromRect(
                rect: adjustedSafeRect,
                child: Center(
                  child: SizedBox(
                    width: visualSize.width,
                    height: visualSize.height,
                    child: Transform.scale(
                      scale: scaleFactor,
                      alignment: Alignment.center,
                      child: Transform(
                        transform: boardMatrix,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: widget.layout.actualWidth + boardDepth,
                          height: widget.layout.actualHeight + boardDepth,
                          child: boardSurface
                              .animate()
                              .fadeIn(duration: MotionDurations.slow.safe)
                              .scale(
                                begin: const Offset(0.92, 0.92),
                                end: const Offset(1, 1),
                                duration: MotionDurations.slow.safe,
                                curve: Curves.easeOutBack,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoardSurface(double boardDepth) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Transform.translate(
          offset: const Offset(6, 6),
          child: Container(
            width: widget.layout.actualWidth,
            height: widget.layout.actualHeight,
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? const Color(0xFF3D2B1F)
                  : const Color(0xFF5D4037),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(4, 4),
          child: Container(
            width: widget.layout.actualWidth,
            height: widget.layout.actualHeight,
            decoration: BoxDecoration(
              color: Color.lerp(const Color(0xFF6E4B2A), Colors.black, 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(2, 2),
          child: Container(
            width: widget.layout.actualWidth,
            height: widget.layout.actualHeight,
            decoration: BoxDecoration(
              color: Color.lerp(const Color(0xFF8B5A2B), Colors.black, 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Container(
          width: widget.layout.actualWidth,
          height: widget.layout.actualHeight,
          decoration: GameTheme.boardDecorationFor(widget.isDarkMode).copyWith(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: widget.isDarkMode ? 0.22 : 0.12,
                ),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              CenterArea(state: widget.state, layout: widget.layout),
              TileGrid(
                layout: widget.layout,
                currentPlayerPosition: widget.state.currentPlayer.position,
                players: widget.state.players,
                bookOwnerships: widget.state.bookOwnerships,
                hoveredTileId: _hoveredTileId,
                onHoverEnter: (id) => setState(() => _hoveredTileId = id),
                onHoverExit: (id) => setState(() => _hoveredTileId = null),
              ),
              PawnManager(state: widget.state, layout: widget.layout),
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
    );
  }

  Rect _projectedBoardBounds(Matrix4 matrix, Size boardSize) {
    final center = Offset(boardSize.width / 2, boardSize.height / 2);
    final points = <Offset>[
      Offset.zero,
      Offset(boardSize.width, 0),
      Offset(0, boardSize.height),
      Offset(boardSize.width, boardSize.height),
    ].map((point) => _transformAroundCenter(matrix, point, center));

    final xs = points.map((point) => point.dx);
    final ys = points.map((point) => point.dy);
    return Rect.fromLTRB(
      xs.reduce(math.min),
      ys.reduce(math.min),
      xs.reduce(math.max),
      ys.reduce(math.max),
    );
  }

  Offset _transformAroundCenter(Matrix4 matrix, Offset point, Offset center) {
    final transformed = MatrixUtils.transformPoint(matrix, point - center);
    return transformed + center;
  }
}
