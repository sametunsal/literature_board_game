import 'package:flutter/material.dart';
import 'game_enums.dart';

/// Color group identifiers for Monopoly-style property grouping
enum PropertyColorGroup {
  brown, // Group 1: Near Start
  lightBlue, // Group 2
  pink, // Group 3
  orange, // Group 4
  red, // Group 5
  yellow, // Group 6
  green, // Group 7
  blue, // Group 8: Most expensive
  utility, // Publishers, Schools, Foundations
  special, // Corners, Tax, Cards
}

class BoardTile {
  final int id;
  final String title;
  final TileType type;
  final int? price;
  final int? baseRent;
  final QuestionCategory? category;
  final bool isUtility;
  final int upgradeLevel;
  final PropertyColorGroup? colorGroup;

  const BoardTile({
    required this.id,
    required this.title,
    required this.type,
    this.price,
    this.baseRent,
    this.category,
    this.isUtility = false,
    this.upgradeLevel = 0,
    this.colorGroup,
  });

  BoardTile copyWith({int? upgradeLevel}) {
    return BoardTile(
      id: id,
      title: title,
      type: type,
      price: price,
      baseRent: baseRent,
      category: category,
      isUtility: isUtility,
      upgradeLevel: upgradeLevel ?? this.upgradeLevel,
      colorGroup: colorGroup,
    );
  }

  /// Get the color for this tile's property group
  Color get groupColor {
    return switch (colorGroup) {
      PropertyColorGroup.brown => const Color(0xFF8B4513),
      PropertyColorGroup.lightBlue => const Color(0xFF87CEEB),
      PropertyColorGroup.pink => const Color(0xFFFF69B4),
      PropertyColorGroup.orange => const Color(0xFFFF8C00),
      PropertyColorGroup.red => const Color(0xFFDC143C),
      PropertyColorGroup.yellow => const Color(0xFFFFD700),
      PropertyColorGroup.green => const Color(0xFF228B22),
      PropertyColorGroup.blue => const Color(0xFF0000CD),
      PropertyColorGroup.utility => const Color(0xFF808080),
      PropertyColorGroup.special => const Color(0xFFD3D3D3),
      null => const Color(0xFFE0E0E0),
    };
  }

  /// Get a gradient of colors for the property strip (light to dark)
  Color getGroupColorVariant(int positionInGroup, int totalInGroup) {
    final baseColor = groupColor;
    // Calculate darkness factor: first tile is lighter, last is darker
    final factor = totalInGroup > 1
        ? 0.7 + (0.3 * positionInGroup / (totalInGroup - 1))
        : 0.85;

    return Color.fromARGB(
      baseColor.a.toInt(),
      (baseColor.r * factor).clamp(0, 255).toInt(),
      (baseColor.g * factor).clamp(0, 255).toInt(),
      (baseColor.b * factor).clamp(0, 255).toInt(),
    );
  }
}
