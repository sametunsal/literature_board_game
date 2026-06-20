import 'package:flutter/material.dart';

import '../../models/game_enums.dart';

/// Presentation-only visual identity shared by deck backs and drawn cards.
@immutable
class CardVisualTheme {
  const CardVisualTheme({
    required this.background,
    required this.surface,
    required this.foreground,
    required this.mutedForeground,
    required this.accent,
    required this.metallic,
    required this.shadow,
    required this.icon,
    required this.title,
  });

  final List<Color> background;
  final Color surface;
  final Color foreground;
  final Color mutedForeground;
  final Color accent;
  final Color metallic;
  final Color shadow;
  final IconData icon;
  final String title;

  static CardVisualTheme forType(CardType type) {
    switch (type) {
      case CardType.sans:
        return const CardVisualTheme(
          background: [Color(0xFFFFFBEC), Color(0xFFF6E6B8), Color(0xFFD6AD55)],
          surface: Color(0xFFFFF7DE),
          foreground: Color(0xFF4B3218),
          mutedForeground: Color(0xFF765A32),
          accent: Color(0xFFB77A18),
          metallic: Color(0xFFD8B667),
          shadow: Color(0xFF7A5118),
          icon: Icons.wb_sunny_rounded,
          title: 'ŞANS KARTI',
        );
      case CardType.kader:
        return const CardVisualTheme(
          background: [Color(0xFF31152A), Color(0xFF1B1C35), Color(0xFF090E1C)],
          surface: Color(0xFF17172A),
          foreground: Color(0xFFF8EEDC),
          mutedForeground: Color(0xFFC9BDAE),
          accent: Color(0xFF7B263D),
          metallic: Color(0xFFC2A66B),
          shadow: Color(0xFF070913),
          icon: Icons.nights_stay_rounded,
          title: 'KADER KARTI',
        );
    }
  }
}
