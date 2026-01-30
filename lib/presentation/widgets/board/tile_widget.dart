import 'package:flutter/material.dart';
import '../../../core/motion/motion_constants.dart';
import '../../../core/theme/game_theme.dart';
import '../../../data/board_config.dart';
import '../enhanced_tile_widget.dart';

/// Individual tile widget with pulse animation support
class TileWidget extends StatefulWidget {
  final int id;
  final double left;
  final double top;
  final double width;
  final double height;
  final int rotation;
  final bool isSelected;
  final bool isPulsing;
  final bool isHovered;
  final VoidCallback? onHoverEnter;
  final VoidCallback? onHoverExit;
  final VoidCallback? onPulseComplete;

  const TileWidget({
    super.key,
    required this.id,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.rotation,
    this.isSelected = false,
    this.isPulsing = false,
    this.isHovered = false,
    this.onHoverEnter,
    this.onHoverExit,
    this.onPulseComplete,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget> {
  @override
  Widget build(BuildContext context) {
    // Get tile data from BoardConfig
    final tile = BoardConfig.getTile(widget.id);

    // Tile widget wrapped in MouseRegion for hover tracking (Desktop/Web only)
    Widget tileWidget = MouseRegion(
      onEnter: (event) {
        // Only track hover on Desktop/Web (mobile has no hover)
        final isDesktopOrWeb =
            Theme.of(context).platform != TargetPlatform.android &&
            Theme.of(context).platform != TargetPlatform.iOS;
        if (isDesktopOrWeb && widget.onHoverEnter != null) {
          widget.onHoverEnter!();
        }
      },
      onExit: (event) {
        final isDesktopOrWeb =
            Theme.of(context).platform != TargetPlatform.android &&
            Theme.of(context).platform != TargetPlatform.iOS;
        if (isDesktopOrWeb && widget.onHoverExit != null) {
          widget.onHoverExit!();
        }
      },
      child: EnhancedTileWidget(
        tile: tile,
        width: widget.width,
        height: widget.height,
        quarterTurns: widget.rotation,
        isSelected: widget.isSelected,
        isHovered: widget.isHovered,
      ),
    );

    // Apply landing pulse animation if active
    if (widget.isPulsing) {
      tileWidget = TweenAnimationBuilder<double>(
        key: ValueKey('pulse_${widget.id}'),
        tween: Tween(begin: 0.0, end: 1.0),
        duration: MotionDurations.pulse.safe,
        curve: MotionCurves.emphasized,
        onEnd: () {
          // Clear pulse state after animation
          if (widget.onPulseComplete != null) {
            widget.onPulseComplete!();
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
      left: widget.left,
      top: widget.top,
      width: widget.width,
      height: widget.height,
      child: tileWidget,
    );
  }
}
