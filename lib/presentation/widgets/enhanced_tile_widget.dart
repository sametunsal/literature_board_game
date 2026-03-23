import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../core/motion/motion_constants.dart';
import '../../models/board_tile.dart';
import '../../models/difficulty.dart';
import '../../models/tile_type.dart';

class EnhancedTileWidget extends StatefulWidget {
  final BoardTile tile;
  final double width;
  final double height;
  final int quarterTurns;
  final bool isSelected;
  final bool isHovered;

  const EnhancedTileWidget({
    super.key,
    required this.tile,
    required this.width,
    required this.height,
    this.quarterTurns = 0,
    this.isSelected = false,
    this.isHovered = false,
  });

  @override
  State<EnhancedTileWidget> createState() => _EnhancedTileWidgetState();
}

class _EnhancedTileWidgetState extends State<EnhancedTileWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed
        ? 0.96
        : (widget.isHovered ? 1.05 : (widget.isSelected ? 1.08 : 1.0));

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: scale,
        duration: MotionDurations.fast.safe,
        curve: MotionCurves.emphasized,
        child: AnimatedContainer(
          duration: MotionDurations.fast.safe,
          curve: MotionCurves.standard,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected ? Colors.blue : Colors.grey.shade300,
              width: widget.isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? Colors.blue.withValues(alpha: 0.3)
                    : Colors.transparent,
                blurRadius: _isPressed ? 8 : 0,
                spreadRadius: _isPressed ? 2 : 0,
              ),
              BoxShadow(
                color: widget.isSelected
                    ? Colors.blue.withValues(alpha: 0.2)
                    : (widget.isHovered
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1)),
                blurRadius: widget.isSelected
                    ? 8.0
                    : (widget.isHovered ? 6.0 : 3.0),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (widget.tile.type) {
      case TileType.start:
        return _buildCornerTileContent(
          icon: Icons.play_arrow,
          iconColor: Colors.green.shade700,
          label: 'BAŞLANGIÇ',
        );
      case TileType.shop:
        return _buildCornerTileContent(
          icon: Icons.local_cafe,
          iconColor: Colors.brown.shade700,
          label: 'KIRAATHANE',
        );
      case TileType.library:
        return _buildCornerTileContent(
          icon: Icons.local_library,
          iconColor: Colors.teal.shade700,
          label: 'KÜTÜPHANE',
        );
      case TileType.signingDay:
        return _buildCornerTileContent(
          icon: Icons.edit_note,
          iconColor: Colors.purple.shade700,
          label: 'İMZA GÜNÜ',
        );
      case TileType.chance:
        return _buildCornerTileContent(
          icon: Icons.casino,
          iconColor: Colors.amber.shade700,
          label: 'ŞANS',
        );
      case TileType.fate:
        return _buildCornerTileContent(
          icon: Icons.auto_awesome,
          iconColor: Colors.deepPurple.shade700,
          label: 'KADER',
        );
      case TileType.corner:
        return _buildCornerTileContent(
          icon: Icons.star,
          iconColor: Colors.orange.shade700,
          label: widget.tile.name,
        );
      default:
        break;
    }

    final groupColor = _getGroupColor();
    Widget colorStrip = Container(color: groupColor);
    Widget textContent = _buildStandardTileContent();

    switch (widget.quarterTurns) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
                height: math.max(4, widget.height * 0.13), child: colorStrip),
            Expanded(child: textContent),
          ],
        );
      case 1:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
                width: math.max(4, widget.width * 0.13), child: colorStrip),
            Expanded(
              child: ClipRect(
                child: RotatedBox(quarterTurns: 3, child: textContent),
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: textContent),
            SizedBox(
                height: math.max(4, widget.height * 0.13), child: colorStrip),
          ],
        );
      case 3:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRect(
                child: RotatedBox(quarterTurns: 3, child: textContent),
              ),
            ),
            SizedBox(
                width: math.max(4, widget.width * 0.13), child: colorStrip),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
                height: math.max(4, widget.height * 0.13), child: colorStrip),
            Expanded(child: textContent),
          ],
        );
    }
  }

  /// Tile depth map for isometric perspective compensation.
  /// 0 = farthest (top-left after transform), 13 = nearest (bottom-right).
  static const _depthMap = <int, int>{
    0: 13, 1: 12, 2: 11, 3: 10, 4: 9, 5: 8, 6: 7,
    7: 6, 8: 5, 9: 4, 10: 3, 11: 2, 12: 1, 13: 0,
    14: 1, 15: 2, 16: 3, 17: 4, 18: 5, 19: 6,
    20: 7, 21: 8, 22: 9, 23: 10, 24: 11, 25: 12,
  };

  double _perspectiveScale() {
    final id = int.tryParse(widget.tile.id) ?? 0;
    final depth = _depthMap[id] ?? 7;
    return 0.88 + (1.0 - depth / 13.0) * 0.24;
  }

  /// Per-tile adaptive sizing.  Accounts for tile dimensions, word
  /// structure and isometric foreshortening.  Each word gets its own
  /// line so `AutoSizeText` never has to split a word mid-line.
  _TileTextParams _computeTextParams() {
    final name = widget.tile.name;
    final words =
        name.split(RegExp(r'[\s\-]+')).where((w) => w.isNotEmpty).toList();
    final wordCount = words.length;
    final longestWord = words.fold<int>(0, (m, w) => math.max(m, w.length));

    final isVerticalEdge =
        widget.quarterTurns == 1 || widget.quarterTurns == 3;
    final contentW = isVerticalEdge ? widget.height : widget.width;
    final contentH = isVerticalEdge ? widget.width : widget.height;
    final usableW = math.max(20.0, contentW - 8);
    final usableH = math.max(20.0, contentH - 6);
    final pScale = _perspectiveScale();

    // Keep lines bounded for tiny perspective tiles.
    final int maxLines = wordCount.clamp(1, 4);

    // Base font from the width available for the longest word,
    // scaled by perspective depth so far-away tiles stay legible.
    final charWidth = usableW / math.max(longestWord, 1);
    final lineHeight = usableH / maxLines;
    final baseFont = math.min(charWidth * 1.55, lineHeight * 0.72) * pScale;

    final showDifficultyTag =
        widget.tile.type == TileType.category &&
        (usableH > 34) &&
        (pScale > 0.92);

    return _TileTextParams(
      maxFont: baseFont.clamp(6.5, 15.0),
      minFont: (baseFont * 0.55).clamp(4.5, 10.0),
      maxLines: maxLines,
      showDifficultyTag: showDifficultyTag,
    );
  }

  Widget _buildStandardTileContent() {
    final params = _computeTextParams();
    final displayName = _formatDisplayName(widget.tile.name, params.maxLines);
    final showDifficulty = params.showDifficultyTag &&
        widget.tile.category != null &&
        widget.tile.category!.isNotEmpty &&
        widget.tile.type == TileType.category;

    return ClipRect(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Center(
                child: AutoSizeText(
                  displayName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: params.maxFont,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    height: 1.1,
                  ),
                  minFontSize: params.minFont,
                  maxLines: params.maxLines,
                  stepGranularity: 0.25,
                  wrapWords: false,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
            if (showDifficulty)
              SizedBox(
                height: 9,
                child: Text(
                  widget.tile.difficulty.displayName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 6,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Put every word on its own line so AutoSizeText never has to break
  /// a word.  For 5+ words we pair short words together to save space.
  String _formatDisplayName(String name, int maxLines) {
    final words =
        name.split(RegExp(r'[\s\-]+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';

    // Start with one word per line.
    final lines = List<String>.from(words);
    // If lines exceed maxLines, merge last words into previous lines.
    while (lines.length > maxLines) {
      final last = lines.removeLast();
      lines[lines.length - 1] = '${lines.last} $last';
    }
    return lines.join('\n');
  }

  Widget _buildCornerTileContent({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    final shortSide = math.min(widget.width, widget.height);
    return ClipRect(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: math.max(16, shortSide * 0.42), color: iconColor),
                SizedBox(height: shortSide * 0.04),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getGroupColor() {
    final id = int.tryParse(widget.tile.id) ?? 0;
    switch (id) {
      case 0:
        return Colors.green.shade500;
      case 1:
        return Colors.blue.shade500;
      case 2:
        return Colors.purple.shade400;
      case 3:
        return Colors.orange.shade400;
      case 4:
        return Colors.red.shade400;
      case 5:
        return Colors.teal.shade400;
      case 6:
        return Colors.pink.shade400;
      case 7:
        return Colors.indigo.shade400;
      case 8:
        return Colors.brown.shade400;
      case 9:
        return Colors.grey.shade400;
      case 10:
        return Colors.blue.shade300;
      case 11:
        return Colors.purple.shade300;
      case 12:
        return Colors.orange.shade300;
      case 13:
        return Colors.red.shade300;
      case 14:
        return Colors.teal.shade300;
      case 15:
        return Colors.amber.shade300;
      case 16:
        return Colors.brown.shade300;
      case 20:
        return Colors.teal.shade600;
      case 21:
        return Colors.indigo.shade500;
      case 22:
        return Colors.deepOrange.shade600;
      case 23:
        return Colors.pink.shade600;
      case 24:
        return Colors.green.shade600;
      case 25:
        return Colors.blueGrey.shade600;
      case 17:
        return Colors.deepPurple.shade400;
      case 18:
        return Colors.cyan.shade400;
      case 19:
        return Colors.lime.shade400;
      default:
        return Colors.grey.shade200;
    }
  }
}

class _TileTextParams {
  final double maxFont;
  final double minFont;
  final int maxLines;
  final bool showDifficultyTag;
  const _TileTextParams({
    required this.maxFont,
    required this.minFont,
    required this.maxLines,
    required this.showDifficultyTag,
  });
}
