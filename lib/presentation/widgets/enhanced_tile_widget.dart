import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/motion/motion_constants.dart';
import '../../models/board_tile.dart';
import '../../models/tile_type.dart';

/// Kutucuk widget'ı - tüm içerik FittedBox ile sığdırılır, overflow imkansız.
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
    const stripThickness = 5.0;

    // İçerik widget'ı - sadece isim (FittedBox ile)
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _formatName(widget.tile.name),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.15,
            ),
          ),
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
            Container(height: stripThickness, color: color),
            Expanded(child: rotatedContent),
          ],
        );
      case 1: // Sağ kenar - şerit solda
        return Row(
          children: [
            Container(width: stripThickness, color: color),
            Expanded(child: rotatedContent),
          ],
        );
      case 2: // Üst kenar - şerit altta
        return Column(
          children: [
            Expanded(child: rotatedContent),
            Container(height: stripThickness, color: color),
          ],
        );
      case 3: // Sol kenar - şerit sağda
        return Row(
          children: [
            Expanded(child: rotatedContent),
            Container(width: stripThickness, color: color),
          ],
        );
      default:
        return Column(
          children: [
            Container(height: stripThickness, color: color),
            Expanded(child: rotatedContent),
          ],
        );
    }
  }

  /// İsmi satırlara böl - her kelime kendi satırında
  String _formatName(String name) {
    // Tek kelimelik isimler
    if (!name.contains(' ') && !name.contains('-')) {
      return name;
    }

    // Çok uzun tek kelimeler için kısaltma
    final words = name.split(RegExp(r'[\s\-]+')).where((w) => w.isNotEmpty).toList();
    
    if (words.isEmpty) return name;
    if (words.length == 1) return words.first;

    // Her kelimeyi ayrı satıra koy (max 3 satır)
    if (words.length <= 3) {
      return words.join('\n');
    }

    // 3'ten fazla kelime varsa, ilk 2 ve son kelimeleri grupla
    return '${words[0]}\n${words.sublist(1, words.length - 1).join(' ')}\n${words.last}';
  }

  Color _getTileColor() {
    final id = int.tryParse(widget.tile.id) ?? 0;
    
    // Kategori renklerini tile ID'sine göre belirle
    final colors = [
      Colors.green.shade500,    // 0
      Colors.blue.shade500,     // 1
      Colors.purple.shade500,   // 2
      Colors.orange.shade500,   // 3
      Colors.red.shade500,      // 4
      Colors.teal.shade500,     // 5
      Colors.pink.shade500,     // 6
      Colors.indigo.shade500,   // 7
      Colors.brown.shade500,    // 8
      Colors.cyan.shade500,     // 9
      Colors.amber.shade600,    // 10
      Colors.deepPurple.shade500, // 11
      Colors.lightGreen.shade600, // 12
      Colors.deepOrange.shade500, // 13
      Colors.blueGrey.shade500, // 14
      Colors.lime.shade600,     // 15
      Colors.indigo.shade400,   // 16
      Colors.pink.shade400,     // 17
      Colors.teal.shade400,     // 18
      Colors.amber.shade500,    // 19
      Colors.blue.shade400,     // 20
      Colors.purple.shade400,   // 21
      Colors.orange.shade400,   // 22
      Colors.red.shade400,      // 23
      Colors.green.shade400,    // 24
      Colors.brown.shade400,    // 25
    ];

    return colors[id % colors.length];
  }
}
