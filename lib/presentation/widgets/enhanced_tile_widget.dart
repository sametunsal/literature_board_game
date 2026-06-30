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

  /// Slightly tighter ceiling for multi-line side labels (e.g. the rotated
  /// "Fatih\nHarbiye"). A two-line side label stacks across the short axis and
  /// each short line easily reaches [_kMaxSideLabelFontSize], making it read
  /// larger and bolder than the single-line side labels beside it. Shaving the
  /// cap here evens them out without shrinking single-word side labels.
  static const double _kMaxMultilineSideLabelFontSize = 10.5;

  /// Reduced ceiling for short special/action tile labels (e.g. "Teşvik").
  /// These are single short words with no book attached, so against the full
  /// [_kMaxLabelFontSize] they grow large enough to dwarf the surrounding
  /// multi-line book labels. Capping them keeps the action tiles visually
  /// balanced with their neighbours without shrinking book typography.
  static const double _kMaxActionLabelFontSize = 10.5;

  static const double _kMinLabelFontSize = 6.2;

  /// Lower floor used only when trying to keep a *single word* on one line on a
  /// rotated side tile. Side tiles are wide-and-short, so after the colour strip
  /// the rotated long axis is only ~45–52px at phone scale — just shy of fitting
  /// an 8-letter title like "Çalıkuşu" at [_kMinLabelFontSize], which would
  /// otherwise force an ugly mid-word break ("Çalık/uşu"). Allowing the
  /// single-line attempt to shrink a little further keeps such words whole.
  ///
  /// This is a *minimum*, not the rendered size: a label always uses the largest
  /// font that fits, so on roomier tiles it is already larger (≈6.2pt @411dp,
  /// ≈5.6pt @390dp) regardless of this floor. The floor only binds on the
  /// tightest phones (~360dp), where the rotated axis caps "Çalıkuşu" at ≈5.0pt.
  /// Raising it (5.2/5.4) cannot enlarge the label — it only makes such words
  /// fragment to two lines there — so it is held at 5.0 to keep them whole.
  /// Multi-line fallbacks still use the readable [_kMinLabelFontSize] floor, so
  /// multi-word labels (e.g. "Fatih\nHarbiye") are never crushed to fit.
  static const double _kMinSideSingleLineFontSize = 5.0;

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

    // Short action tiles (e.g. "Teşvik") carry no book and use a lower font
    // ceiling so they stay visually consistent with neighbouring labels.
    final labelMaxFont = isBookTile ? null : _kMaxActionLabelFontSize;

    final content = _buildLabelText(
      displayText,
      maxLines,
      maxFontSize: labelMaxFont,
    );
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
    double? maxFontSize,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolved = _resolveRenderedLabel(
          displayText,
          constraints.maxWidth,
          constraints.maxHeight,
          maxLines: maxLines,
          isSideLabel: isSideLabel,
          maxFontSize: maxFontSize,
        );

        return ClipRect(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                resolved.text,
                textAlign: TextAlign.center,
                maxLines: resolved.maxLines,
                overflow: TextOverflow.visible,
                softWrap: true,
                strutStyle: _labelStrut(resolved.fontSize),
                style: _labelStyle(resolved.fontSize),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Chooses the actual string, font size, and line count to render.
  ///
  /// Top/bottom labels render their [displayText] verbatim. Side labels rotate
  /// along the tile's long axis, so a label that needs an explicit "\n" break
  /// on the top/bottom row frequently fits as a single real-word line when
  /// rotated. For those we collapse the break to a space and render one line
  /// when it fits at the single-line side cap; otherwise we keep the explicit
  /// multi-line label (with the tighter multi-line cap) so words never
  /// fragment and no abbreviation/ellipsis is needed.
  ({String text, double fontSize, int maxLines}) _resolveRenderedLabel(
    String displayText,
    double maxWidth,
    double maxHeight, {
    required int maxLines,
    required bool isSideLabel,
    double? maxFontSize,
  }) {
    if (isSideLabel && maxFontSize == null && displayText.contains('\n')) {
      final singleLine = displayText.replaceAll('\n', ' ');
      final textBoxWidth = (maxWidth - 4).clamp(1.0, double.infinity);
      final textBoxHeight = (maxHeight - 4).clamp(1.0, double.infinity);
      for (
        double fontSize = _kMaxSideLabelFontSize;
        fontSize >= _kMinLabelFontSize;
        fontSize -= 0.2
      ) {
        if (_titleFits(singleLine, textBoxWidth, textBoxHeight, fontSize, 1)) {
          return (text: singleLine, fontSize: fontSize, maxLines: 1);
        }
      }
      // Falls through: the collapsed line does not fit even at the minimum
      // size, so keep the explicit multi-line label below.
    }

    final isMultilineSideLabel = isSideLabel && displayText.contains('\n');
    final cap =
        maxFontSize ??
        (isSideLabel
            ? (isMultilineSideLabel
                  ? _kMaxMultilineSideLabelFontSize
                  : _kMaxSideLabelFontSize)
            : _kMaxLabelFontSize);
    final fit = _resolveLabelFit(
      displayText,
      maxWidth,
      maxHeight,
      maxLines,
      cap,
      // Single-word side labels (e.g. "Çalıkuşu") may shrink a little further
      // to stay whole on the short rotated axis rather than fragmenting.
      singleLineFloor: isSideLabel
          ? _kMinSideSingleLineFontSize
          : _kMinLabelFontSize,
    );
    return (text: displayText, fontSize: fit.fontSize, maxLines: fit.maxLines);
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

  /// Resolves the font size and the number of lines a label should render with.
  ///
  /// Short/medium single-word titles (no whitespace, no explicit break) prefer
  /// staying on a single line: the font is shrunk first, and only if the word
  /// cannot fit on one line even at [_kMinLabelFontSize] is a controlled wrap
  /// to the supplied [maxLines] allowed. Multi-word and pre-broken labels keep
  /// the original behaviour.
  ({double fontSize, int maxLines}) _resolveLabelFit(
    String title,
    double maxWidth,
    double maxHeight,
    int maxLines,
    double maxFontSize, {
    double singleLineFloor = _kMinLabelFontSize,
  }) {
    final textBoxWidth = (maxWidth - 4).clamp(1.0, double.infinity);
    final textBoxHeight = (maxHeight - 4).clamp(1.0, double.infinity);

    final isSingleWord =
        !title.contains('\n') && !RegExp(r'\s').hasMatch(title);

    if (isSingleWord && maxLines > 1) {
      for (
        double fontSize = maxFontSize;
        fontSize >= singleLineFloor;
        fontSize -= 0.2
      ) {
        if (_titleFits(title, textBoxWidth, textBoxHeight, fontSize, 1)) {
          return (fontSize: fontSize, maxLines: 1);
        }
      }
      // Falls through: the word will not fit on one line even at the minimum
      // size, so a controlled multi-line wrap is the lesser evil.
    }

    for (
      double fontSize = maxFontSize;
      fontSize >= _kMinLabelFontSize;
      fontSize -= 0.2
    ) {
      if (_titleFits(title, textBoxWidth, textBoxHeight, fontSize, maxLines)) {
        return (fontSize: fontSize, maxLines: maxLines);
      }
    }
    return (fontSize: _kMinLabelFontSize, maxLines: maxLines);
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
