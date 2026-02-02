import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/player.dart';
import '../../core/constants/game_constants.dart';
import '../../core/motion/motion_constants.dart';
import 'isometric_icon.dart';

/// Animated pawn widget with polished 2D appearance
/// Features smooth slide animation with subtle scale pulse
class PawnWidget extends StatefulWidget {
  final Player player;
  final double size;
  final bool isActive;
  final bool isCurrentTurn;

  const PawnWidget({
    super.key,
    required this.player,
    required this.size,
    this.isActive = false,
    this.isCurrentTurn = false,
  });

  @override
  State<PawnWidget> createState() => _PawnWidgetState();
}

class _PawnWidgetState extends State<PawnWidget> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Pulsating glow controller
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation - subtle scale up when moving
    _pulseController = AnimationController(
      duration: MotionDurations.pawn.safe,
      vsync: this,
    );

    // Simple scale pulse: 1.0 → 1.1 → 1.0
    _pulseAnimation = TweenSequence<double>([
      // Scale up quickly (pickup)
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      // Hold at peak while sliding
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
      // Scale back down (place)
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_pulseController);

    // Pulsating glow animation - uses slow duration for gentle effect
    _glowController = AnimationController(
      duration: MotionDurations.slow * 2,
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: MotionCurves.standard),
    );

    if (widget.isCurrentTurn) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PawnWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger pulse on position change
    if (oldWidget.player.position != widget.player.position) {
      _pulseController.forward(from: 0);
    }

    // Handle glow
    if (widget.isCurrentTurn && !oldWidget.isCurrentTurn) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isCurrentTurn && oldWidget.isCurrentTurn) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _glowController]),
      builder: (context, child) {
        final scale = _pulseAnimation.value;

        return Transform.scale(scale: scale, child: child);
      },
      child: _buildPawnToken(),
    );
  }

  Widget _buildPawnToken() {
    final size = widget.size;
    final isCurrentTurn = widget.isCurrentTurn;
    final color = widget.player.color;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowIntensity = isCurrentTurn ? _glowAnimation.value : 0.0;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Active turn glow (behind icon)
            if (isCurrentTurn)
              Container(
                width: size * 1.5,
                height: size * 1.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(
                        alpha: 0.4 + (glowIntensity * 0.4),
                      ),
                      blurRadius: 10 + (glowIntensity * 10),
                      spreadRadius: 2 + (glowIntensity * 4),
                    ),
                  ],
                ),
              ),

            Center(
              child: IsometricIcon(
                icon:
                    GameConstants.iconPalette[widget.player.iconIndex %
                        GameConstants.iconPalette.length],
                color: color,
                size: size,
                depth: 5.0, // Fixed depth
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Container that smoothly moves pawn groups across the board
/// Uses strict 2x3 Grid Layout (3 Rows, 2 Columns)
/// Mapped for up to 6 players
class AnimatedPawnContainer extends StatefulWidget {
  final Offset center;
  final double width;
  final double height;
  final List<Player> players;
  final String currentPlayerId;
  final double pawnSize; // Base size hint

  const AnimatedPawnContainer({
    super.key,
    required this.center,
    required this.width,
    required this.height,
    required this.players,
    required this.currentPlayerId,
    required this.pawnSize,
  });

  @override
  State<AnimatedPawnContainer> createState() => _AnimatedPawnContainerState();
}

class _AnimatedPawnContainerState extends State<AnimatedPawnContainer> {
  Offset? _previousCenter;
  bool _justMoved = false;
  Timer? _moveResetTimer;

  @override
  void didUpdateWidget(AnimatedPawnContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect position change
    if (oldWidget.center != widget.center) {
      _previousCenter = oldWidget.center;
      _justMoved = true;

      _moveResetTimer?.cancel();
      _moveResetTimer = Timer(
        MotionDurations.pawn + MotionDurations.medium,
        () {
          if (mounted) {
            setState(() {
              _justMoved = false;
            });
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _moveResetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate top-left of the tile area
    final left = widget.center.dx - (widget.width / 2);
    final top = widget.center.dy - (widget.height / 2);

    Widget pawnContainer = Positioned(
      left: left,
      top: top,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double w = constraints.maxWidth;
            final double h = constraints.maxHeight;

            // 2 Columns (Left, Right)
            final double colWidth = w / 2;
            // 3 Rows (Top, Middle, Bottom)
            final double rowHeight = h / 3;

            // Safe Pawn Size: min dimension * 0.8 (allows padding)
            final double minDim = colWidth < rowHeight ? colWidth : rowHeight;
            final double safePawnSize = minDim * 0.8;

            // Calculate centering offsets within cell
            final double offsetX = (colWidth - safePawnSize) / 2;
            final double offsetY = (rowHeight - safePawnSize) / 2;

            return Stack(
              clipBehavior: Clip.none,
              // GUARANTEED UNIQUE MAPPING: Use List Index
              // The `players` list contains only players on THIS tile.
              // So mapping 0->TL, 1->TR etc. ensures perfect separation.
              children: widget.players.asMap().entries.map((entry) {
                final int index = entry.key;
                final Player p = entry.value;

                // Determine Slot based on List Index
                // 0: TL, 1: TR
                // 2: ML, 3: MR
                // 4: BL, 5: BR
                final int pos = index % 6;

                double pLeft = 0;
                double pTop = 0;

                // Column Determination (Even=Left, Odd=Right)
                if (pos % 2 == 0) {
                  pLeft = 0; // Left Column
                } else {
                  pLeft = colWidth; // Right Column
                }

                // Row Determination
                if (pos < 2) {
                  pTop = 0; // Top Row
                } else if (pos < 4) {
                  pTop = rowHeight; // Middle Row
                } else {
                  pTop = rowHeight * 2; // Bottom Row
                }

                // Apply centering padding
                pLeft += offsetX;
                pTop += offsetY;

                return Positioned(
                  left: pLeft,
                  top: pTop,
                  child: PawnWidget(
                    key: ValueKey(p.id),
                    player: p,
                    size: safePawnSize,
                    isActive: p.id == widget.currentPlayerId,
                    isCurrentTurn: p.id == widget.currentPlayerId,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );

    // Apply smooth slide animation
    if (_justMoved && _previousCenter != null) {
      final dx = left - (_previousCenter!.dx - (widget.width / 2));
      final dy = top - (_previousCenter!.dy - (widget.height / 2));

      return pawnContainer
          .animate(key: ValueKey('${widget.center.dx}_${widget.center.dy}'))
          .move(
            begin: Offset(-dx, -dy),
            end: Offset.zero,
            duration: MotionDurations.pawn.safe,
            curve: Curves.easeInOutCubic,
          );
    }

    return pawnContainer;
  }
}
