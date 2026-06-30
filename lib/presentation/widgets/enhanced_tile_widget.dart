import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/board_book_lookup_service.dart';
import '../../core/motion/motion_constants.dart';
import '../../models/book_level.dart';
import '../../models/book_ownership.dart';
import '../../models/board_tile.dart';
import '../../models/game_enums.dart';
import '../../models/player.dart';
import '../../models/tile_type.dart';

/// Kutucuk widget'ı - tüm içerik sıkı bir şekilde sığdırılır, overflow kontrol edilir.
class EnhancedTileWidget extends StatefulWidget {
  final BoardTile tile;
  final List<Player> players;
  final Map<String, BookOwnership> bookOwnerships;
  final double width;
  final double height;
  final int quarterTurns;
  final bool isSelected;
  final bool isHovered;

  const EnhancedTileWidget({
    super.key,
    required this.tile,
    this.players = const [],
    this.bookOwnerships = const {},
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
  /// Shared line height for board labels. Kept identical between the painter
  /// used for font fitting and the rendered Text so measurement matches paint.
  static const double _kLabelLineHeight = 1.05;

  /// Keep tracking neutral so labels render as normal readable words.
  static const double _kLabelLetterSpacing = 0.0;

  /// Font-fit search bounds. The ceiling is well above the old 9.0 cap so
  /// labels grow to fill generously sized tiles instead of looking tiny.
  static const double _kMaxLabelFontSize = 14.0;

  /// Lower ceiling for rotated side book labels. They measure against the
  /// tile's long axis, so without a tighter cap short titles balloon to the
  /// full [_kMaxLabelFontSize] and dwarf the top/bottom labels. Capping them
  /// here keeps board typography visually consistent without touching the
  /// long-axis measurement that prevents words from fragmenting.
  static const double _kMaxSideLabelFontSize = 11.0;

  static const double _kMinLabelFontSize = 6.2;

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
        child: Container(
          width: widget.width,
          height: widget.height,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isSelected ? Colors.blue : Colors.grey.shade300,
              width: widget.isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              if (widget.isSelected)
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.25),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: _buildTileContent(),
        ),
      ),
    );
  }

  Widget _buildTileContent() {
    // Köşe ve özel kutucuklar
    if (_isSpecialTile()) {
      return _buildSpecialTile();
    }
    // Kategori kutucukları
    return _buildCategoryTile();
  }

  bool _isSpecialTile() {
    return widget.tile.type == TileType.start ||
        widget.tile.type == TileType.shop ||
        widget.tile.type == TileType.library ||
        widget.tile.type == TileType.signingDay ||
        widget.tile.type == TileType.chance ||
        widget.tile.type == TileType.fate ||
        widget.tile.type == TileType.corner;
  }

  /// Köşe ve özel kutucuklar - ikon + etiket
  Widget _buildSpecialTile() {
    final IconData icon;
    final Color iconColor;
    final String label;

    switch (widget.tile.type) {
      case TileType.start:
        icon = Icons.play_arrow_rounded;
        iconColor = Colors.green.shade600;
        label = 'BAŞLA';
      case TileType.shop:
        icon = Icons.local_cafe_rounded;
        iconColor = Colors.brown.shade600;
        label = 'KIRAATHANE';
      case TileType.library:
        icon = Icons.local_library_rounded;
        iconColor = Colors.teal.shade600;
        label = 'KÜTÜPHANE';
      case TileType.signingDay:
        icon = Icons.edit_note_rounded;
        iconColor = Colors.purple.shade600;
        label = 'İMZA GÜNÜ';
      case TileType.chance:
        icon = Icons.casino_rounded;
        iconColor = Colors.amber.shade700;
        label = 'ŞANS';
      case TileType.fate:
        icon = Icons.auto_awesome_rounded;
        iconColor = Colors.deepPurple.shade600;
        label = 'KADER';
      default:
        icon = Icons.star_rounded;
        iconColor = Colors.orange.shade600;
        label = widget.tile.name;
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: iconColor),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kategori kutucukları - renk şeridi + isim
  Widget _buildCategoryTile() {
    final color = _getTileColor();
    final isVertical = widget.quarterTurns == 1 || widget.quarterTurns == 3;

    // Renk şeridi kalınlığı
    const stripThickness = 12.0;

    final book = BoardBookLookupService.bookForTile(widget.tile);

    final ownership = book == null ? null : widget.bookOwnerships[book.id];
    final owner = ownership == null
        ? null
        : _playerForOwnership(ownership.ownerPlayerId);

    final isBookTile = book != null;
    final displayText = isBookTile
        ? (book.boardLabel ?? book.title)
        : widget.tile.name;
    final ownershipChip = _buildOwnershipChip(
      ownership: ownership,
      owner: owner,
    );

    final maxLines = _maxLinesFor(displayText);

    final content = _buildLabelText(displayText, maxLines);
    final labelContent = isVertical && isBookTile
        ? _buildSideBookLabel(displayText, maxLines)
        : isVertical
        ? RotatedBox(quarterTurns: widget.quarterTurns, child: content)
        : content;

    // Kenar pozisyonuna göre renk şeridi yerleşimi
    switch (widget.quarterTurns) {
      case 0: // Alt kenar - şerit üstte
        return Column(
          children: [
            Container(
              height: stripThickness,
              color: color,
              child: ownershipChip,
            ),
            Expanded(child: labelContent),
          ],
        );
      case 1: // Sağ kenar - şerit solda
        return Row(
          children: [
            Container(
              width: stripThickness,
              color: color,
              child: ownershipChip,
            ),
            Expanded(child: labelContent),
          ],
        );
      case 2: // Üst kenar - şerit altta
        return Column(
          children: [
            Expanded(child: labelContent),
            Container(
              height: stripThickness,
              color: color,
              child: ownershipChip,
            ),
          ],
        );
      case 3: // Sol kenar - şerit sağda
        return Row(
          children: [
            Expanded(child: labelContent),
            Container(
              width: stripThickness,
              color: color,
              child: ownershipChip,
            ),
          ],
        );
      default:
        return Column(
          children: [
            Container(
              height: stripThickness,
              color: color,
              child: ownershipChip,
            ),
            Expanded(child: labelContent),
          ],
        );
    }
  }

  Widget _buildLabelText(
    String displayText,
    int maxLines, {
    bool isSideLabel = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = _titleFontSize(
          displayText,
          constraints.maxWidth,
          constraints.maxHeight,
          maxLines,
          maxFontSize: isSideLabel
              ? _kMaxSideLabelFontSize
              : _kMaxLabelFontSize,
        );

        return ClipRect(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                displayText,
                textAlign: TextAlign.center,
                maxLines: maxLines,
                overflow: TextOverflow.visible,
                softWrap: true,
                strutStyle: _labelStrut(fontSize),
                style: _labelStyle(fontSize),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSideBookLabel(String displayText, int maxLines) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableSize = constraints.biggest;
        final longAxis = availableSize.longestSide;
        final shortAxis = availableSize.shortestSide;
        final angle = widget.quarterTurns == 1 ? math.pi / 2 : -math.pi / 2;

        return ClipRect(
          child: Center(
            child: Transform.rotate(
              angle: angle,
              child: OverflowBox(
                minWidth: longAxis,
                maxWidth: longAxis,
                minHeight: shortAxis,
                maxHeight: shortAxis,
                child: SizedBox(
                  key: const ValueKey('side-book-label-long-axis-box'),
                  width: longAxis,
                  height: shortAxis,
                  child: _buildLabelText(
                    displayText,
                    maxLines,
                    isSideLabel: true,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Player? _playerForOwnership(String ownerPlayerId) {
    for (final player in widget.players) {
      if (player.id == ownerPlayerId) return player;
    }
    return null;
  }

  Widget? _buildOwnershipChip({
    required BookOwnership? ownership,
    required Player? owner,
  }) {
    if (ownership == null || owner == null) return null;

    final ownerIndex = widget.players.indexWhere(
      (player) => player.id == owner.id,
    );
    final hasLevel = ownership.level != BookLevel.none;
    final label = hasLevel
        ? switch (ownership.level) {
            BookLevel.telif => 'T',
            BookLevel.baski => 'B',
            BookLevel.cilt => 'C',
            BookLevel.none => '${ownerIndex >= 0 ? ownerIndex + 1 : '?'}',
          }
        : '${ownerIndex >= 0 ? ownerIndex + 1 : '?'}';

    return Center(
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: owner.color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.92),
            width: 0.6,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 5.8,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  /// Allow up to 3 lines so full canonical titles can break cleanly via
  /// explicit "\n" board labels (e.g. Saatleri / Ayarlama / Enstitüsü).
  /// Single-line text still gets 2 lines of head-room for soft wrapping.
  int _maxLinesFor(String text) {
    final explicitLines = '\n'.allMatches(text).length + 1;
    return explicitLines.clamp(2, 3);
  }

  /// Single source of truth for label typography, shared by the fit painter
  /// and the rendered Text so measurement always matches paint.
  TextStyle _labelStyle(double fontSize) => GoogleFonts.poppins(
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
    height: _kLabelLineHeight,
    letterSpacing: _kLabelLetterSpacing,
  );

  StrutStyle _labelStrut(double fontSize) => StrutStyle(
    fontSize: fontSize,
    height: _kLabelLineHeight,
    forceStrutHeight: true,
  );

  double _titleFontSize(
    String title,
    double maxWidth,
    double maxHeight,
    int maxLines, {
    double maxFontSize = _kMaxLabelFontSize,
  }) {
    final textBoxWidth = (maxWidth - 4).clamp(1.0, double.infinity);
    final textBoxHeight = (maxHeight - 4).clamp(1.0, double.infinity);

    for (
      double fontSize = maxFontSize;
      fontSize >= _kMinLabelFontSize;
      fontSize -= 0.2
    ) {
      if (_titleFits(title, textBoxWidth, textBoxHeight, fontSize, maxLines)) {
        return fontSize;
      }
    }
    return _kMinLabelFontSize;
  }

  bool _titleFits(
    String title,
    double maxWidth,
    double maxHeight,
    double fontSize,
    int maxLines,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: title, style: _labelStyle(fontSize)),
      textAlign: TextAlign.center,
      strutStyle: _labelStrut(fontSize),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return !painter.didExceedMaxLines &&
        painter.size.width <= maxWidth &&
        painter.size.height <= maxHeight;
  }

  static const _categoryColors = <QuestionCategory, Color>{
    QuestionCategory.turkEdebiyatindaIlkler: Color(0xFF2196F3),
    QuestionCategory.edebiSanatlar: Color(0xFF9C27B0),
    QuestionCategory.eserKarakter: Color(0xFFE65100),
    QuestionCategory.edebiyatAkimlari: Color(0xFF2E7D32),
    QuestionCategory.benKimim: Color(0xFFD32F2F),
    QuestionCategory.tesvik: Color(0xFF00838F),
  };

  Color _getTileColor() {
    final categoryName = widget.tile.category;
    if (categoryName != null && categoryName.isNotEmpty) {
      final category = QuestionCategory.values.where(
        (c) => c.name == categoryName,
      );
      if (category.isNotEmpty) {
        return _categoryColors[category.first] ?? Colors.grey.shade500;
      }
    }
    return Colors.grey.shade500;
  }
}
