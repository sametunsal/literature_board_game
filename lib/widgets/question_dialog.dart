import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question.dart';
import '../providers/game_notifier.dart';
import '../core/theme/game_theme.dart';

class QuestionDialog extends ConsumerWidget {
  final Question question;
  const QuestionDialog({super.key, required this.question});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320, maxHeight: 500),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: GameTheme.cardDecoration.copyWith(
              color: GameTheme.parchmentColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: GameTheme.goldAccent,
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
                    "SORU",
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: GameTheme.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // QUESTION TEXT
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      question.text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: GameTheme.textDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // OPTIONS
                ...List.generate(
                  question.options.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: SizedBox(
                      width: double.infinity,
                      child: _OptionButton(
                        text: question.options[index],
                        onPressed: () => ref
                            .read(gameProvider.notifier)
                            .answerQuestion(index),
                        index: index,
                      ),
                    ),
                  ),
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

/// Styled option button for question answers
class _OptionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final int index;

  const _OptionButton({
    required this.text,
    required this.onPressed,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Alternate colors for visual interest
    final colors = [
      const Color(0xFF7B1FA2), // Purple
      const Color(0xFF1976D2), // Blue
      const Color(0xFFD32F2F), // Red
      const Color(0xFF388E3C), // Green
    ];
    final color = colors[index % colors.length];

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}
