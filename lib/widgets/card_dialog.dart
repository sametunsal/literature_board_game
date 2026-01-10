import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_card.dart';
import '../models/game_enums.dart';
import '../providers/game_notifier.dart';
import '../core/theme/game_theme.dart';

class CardDialog extends ConsumerWidget {
  final GameCard card;
  const CardDialog({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSans = card.type == CardType.sans;
    final cardColor = isSans
        ? const Color(0xFFE91E63)
        : const Color(0xFF00897B);
    final cardTitle = isSans ? "ŞANS KARTI" : "KADER KARTI";
    final cardIcon = isSans ? Icons.star : Icons.bolt;

    return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320, maxHeight: 450),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: GameTheme.cardDecoration.copyWith(
              color: GameTheme.parchmentColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // CARD ICON with glow effect
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: cardColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(cardIcon, size: 50, color: cardColor),
                ),
                const SizedBox(height: 16),

                // TITLE with styled badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    cardTitle,
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // DESCRIPTION
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      card.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: GameTheme.textDark,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ACTION BUTTON
                _ThemedButton(
                  text: "TAMAM",
                  onPressed: () =>
                      ref.read(gameProvider.notifier).closeCardDialog(),
                  color: GameTheme.goldAccent,
                  textColor: GameTheme.textDark,
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          curve: Curves.elasticOut,
        );
  }
}

/// Themed action button with gold border style
class _ThemedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;

  const _ThemedButton({
    required this.text,
    required this.onPressed,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
