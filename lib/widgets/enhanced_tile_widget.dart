import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tile.dart';
import 'dart:math' as math;

/// Enhanced tile widget with special visual effects
/// Adds mini animations for ŞANS, KADER, Kitap, Yayınevi tiles
class EnhancedTileWidget extends StatefulWidget {
  final Tile tile;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const EnhancedTileWidget({
    super.key,
    required this.tile,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  State<EnhancedTileWidget> createState() => _EnhancedTileWidgetState();
}

class _EnhancedTileWidgetState extends State<EnhancedTileWidget>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Create animation controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    // Only animate special tiles
    if (_isSpecialTile()) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  bool _isSpecialTile() {
    return widget.tile.type == TileType.chance || // ŞANS
        widget.tile.type == TileType.fate || // KADER
        widget.tile.type == TileType.book || // Kitap
        widget.tile.type == TileType.publisher; // Yayınevi
  }

  @override
  Widget build(BuildContext context) {
    // Corner tiles are 1.5x larger than regular tiles
    final isCorner = widget.tile.type == TileType.corner;
    final tileWidth = isCorner ? 150.0 : 100.0;
    final tileHeight = isCorner ? 180.0 : 120.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Container(
            width: tileWidth,
            height: tileHeight,
            decoration: BoxDecoration(
              color: _getTileColor(),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.isHighlighted
                    ? Colors.orange
                    : Colors.brown.shade300,
                width: widget.isHighlighted ? 3 : 1,
              ),
              boxShadow: [
                if (widget.isHighlighted)
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: _isSpecialTile() ? _buildSpecialTile() : child,
          );
        },
        child: _buildNormalTile(),
      ),
    );
  }

  Color _getTileColor() {
    switch (widget.tile.type) {
      case TileType.chance: // ŞANS
        return Colors.purple.shade100;
      case TileType.fate: // KADER
        return Colors.red.shade100;
      case TileType.book: // Kitap
        return Colors.blue.shade100;
      case TileType.publisher: // Yayınevi
        return Colors.green.shade100;
      default:
        return Colors.brown.shade50;
    }
  }

  Color _getTileBorderColor() {
    switch (widget.tile.type) {
      case TileType.chance:
        return Colors.purple.shade600;
      case TileType.fate:
        return Colors.red.shade600;
      case TileType.book:
        return Colors.blue.shade600;
      case TileType.publisher:
        return Colors.green.shade600;
      default:
        return Colors.brown.shade400;
    }
  }

  Widget _buildNormalTile() {
    // Corner tiles have larger text
    final isCorner = widget.tile.type == TileType.corner;
    final fontSize = isCorner ? 14.0 : 10.0;
    final nameFontSize = isCorner ? 12.0 : 10.0;

    return Stack(
      children: [
        // Tile number
        Positioned(
          top: 4,
          left: 8,
          child: Text(
            '${widget.tile.id}',
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade700,
            ),
          ),
        ),
        // Tile content
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              widget.tile.name,
              style: GoogleFonts.poppins(
                fontSize: nameFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.brown.shade800,
              ),
              textAlign: TextAlign.center,
              maxLines: isCorner ? 3 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialTile() {
    return Stack(
      children: [
        // Shimmer effect
        ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getTileColor(),
                _getTileColor().withValues(alpha: 0.8),
                _getTileColor(),
              ],
              stops: [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(_shimmerAnimation.value),
            ).createShader(bounds);
          },
          child: _buildNormalTile(),
        ),
        // Glow effect
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: _getTileBorderColor(), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        // Tile number with icon
        Positioned(
          top: 4,
          left: 4,
          child: Row(
            children: [
              _getTileIcon(),
              const SizedBox(width: 4),
              Text(
                '${widget.tile.id}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getTileBorderColor(),
                ),
              ),
            ],
          ),
        ),
        // Sparkle particles (subtle animation)
        if (_isSpecialTile())
          ...List.generate(3, (index) {
            final offset = (index * math.pi / 1.5);
            return Positioned(
              right: 10 + (index * 10),
              top: 30 + (index * 5),
              child: AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  final opacity =
                      (math.sin(
                            _shimmerAnimation.value * 2 * math.pi + offset,
                          ) +
                          1) /
                      2;
                  return Transform.rotate(
                    angle: _shimmerAnimation.value * 2 * math.pi + offset,
                    child: Icon(
                      Icons.star,
                      size: 8,
                      color: Colors.amber.withValues(alpha: opacity * 0.6),
                    ),
                  );
                },
              ),
            );
          }),
      ],
    );
  }

  Icon _getTileIcon() {
    switch (widget.tile.type) {
      case TileType.chance:
        return Icon(
          Icons.question_mark,
          size: 14,
          color: Colors.purple.shade600,
        );
      case TileType.fate:
        return Icon(Icons.auto_awesome, size: 14, color: Colors.red.shade600);
      case TileType.book:
        return Icon(Icons.menu_book, size: 14, color: Colors.blue.shade600);
      case TileType.publisher:
        return Icon(Icons.business, size: 14, color: Colors.green.shade600);
      default:
        return const Icon(Icons.circle, size: 14, color: Colors.brown);
    }
  }
}

/// Custom gradient transform for shimmer effect
class _SlidingGradientTransform extends GradientTransform {
  final double percent;

  const _SlidingGradientTransform(this.percent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * percent, 0.0, 0.0);
  }
}
