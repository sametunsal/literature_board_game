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

    final displayText = book != null ? book.title : widget.tile.name;
    final ownershipChip = _buildOwnershipChip(
      ownership: ownership,
      owner: owner,
    );

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(3, 2, 3, 2),
      child: Text(
        displayText,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          height: 1.12,
        ),
      ),
    );

    // Yatay kutucuklar için döndürülmüş içerik
    final rotatedContent = isVertical
        ? RotatedBox(quarterTurns: 3, child: content)
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
            Expanded(child: rotatedContent),
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
            Expanded(child: rotatedContent),
          ],
        );
      case 2: // Üst kenar - şerit altta
        return Column(
          children: [
            Expanded(child: rotatedContent),
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
            Expanded(child: rotatedContent),
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
            Expanded(child: rotatedContent),
          ],
        );
    }
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
