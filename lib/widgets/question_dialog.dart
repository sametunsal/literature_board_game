import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question.dart';
import '../models/game_enums.dart';
import '../providers/game_notifier.dart';
import '../core/theme/game_theme.dart';

/// Question dialog with 45-second timer and CEVAPLA -> BİLDİN/BİLEMEDİN flow
class QuestionDialog extends ConsumerStatefulWidget {
  final Question question;
  const QuestionDialog({super.key, required this.question});

  @override
  ConsumerState<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends ConsumerState<QuestionDialog> {
  static const int _totalSeconds = 45;
  int _remainingSeconds = _totalSeconds;
  Timer? _timer;
  bool _showAnswerButtons = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= 0) {
            _timer?.cancel();
            _showAnswerButtons = true;
          }
        });
      }
    });
  }

  void _onCevapla() {
    _timer?.cancel();
    setState(() {
      _showAnswerButtons = true;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Get display name for category
  String _getCategoryDisplayName(QuestionCategory? category) {
    return switch (category) {
      QuestionCategory.benKimim => "BEN KİMİM?",
      QuestionCategory.turkEdebiyatindaIlkler => "TÜRK EDEBİYATINDA İLKLER",
      QuestionCategory.edebiyatAkimlari => "EDEBİYAT AKIMLARI",
      QuestionCategory.edebiSanatlar => "EDEBİ SANATLAR",
      QuestionCategory.eserKarakter => "ESER-KARAKTER",
      null => "GENEL",
    };
  }

  /// Get color for category
  Color _getCategoryColor(QuestionCategory? category) {
    return switch (category) {
      QuestionCategory.benKimim => const Color(0xFF7B1FA2),
      QuestionCategory.turkEdebiyatindaIlkler => const Color(0xFF1976D2),
      QuestionCategory.edebiyatAkimlari => const Color(0xFFD32F2F),
      QuestionCategory.edebiSanatlar => const Color(0xFF388E3C),
      QuestionCategory.eserKarakter => const Color(0xFFFF8C00),
      null => GameTheme.goldAccent,
    };
  }

  /// Get icon for category
  IconData _getCategoryIcon(QuestionCategory? category) {
    return switch (category) {
      QuestionCategory.benKimim => Icons.person_search,
      QuestionCategory.turkEdebiyatindaIlkler => Icons.emoji_events,
      QuestionCategory.edebiyatAkimlari => Icons.auto_stories,
      QuestionCategory.edebiSanatlar => Icons.brush,
      QuestionCategory.eserKarakter => Icons.menu_book,
      null => Icons.help_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final categoryColor = _getCategoryColor(question.category);
    final categoryName = _getCategoryDisplayName(question.category);

    // Timer color based on remaining time
    final timerColor = _remainingSeconds <= 10
        ? Colors.red
        : (_remainingSeconds <= 20 ? Colors.orange : GameTheme.textDark);

    return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: GameTheme.cardDecoration.copyWith(
              color: GameTheme.parchmentColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TIMER DISPLAY
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: timerColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: timerColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, color: timerColor, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '$_remainingSeconds',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: timerColor,
                        ),
                      ),
                      Text(
                        's',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: timerColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // CATEGORY BADGE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getCategoryIcon(question.category),
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        categoryName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // QUESTION TEXT
                Flexible(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: categoryColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        question.text,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: GameTheme.textDark,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // BUTTONS
                if (!_showAnswerButtons)
                  // CEVAPLA BUTTON (before timer ends)
                  _buildCevaplaButton()
                else
                  // BİLDİN / BİLEMEDİN BUTTONS (after CEVAPLA or timeout)
                  _buildAnswerButtons(),
              ],
            ),
          ),
        )
        .animate()
        // Paper sliding on table feel
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.6,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        )
        // Slight tilt during slide (not perfectly flat)
        .rotate(
          begin: 0.03, // Start with slight tilt
          end: 0,
          duration: 450.ms,
          curve: Curves.easeOut,
        )
        // Scale pulse: start smaller, overshoot slightly, then settle
        .scale(
          begin: const Offset(0.88, 0.88),
          end: const Offset(1.02, 1.02), // Slight overshoot
          delay: 50.ms,
          duration: 350.ms,
          curve: Curves.easeOut,
        )
        .then() // Chain for the settle
        .scale(
          begin: const Offset(1.02, 1.02),
          end: const Offset(1.0, 1.0),
          duration: 150.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildCevaplaButton() {
    return Column(
      children: [
        Text(
          "Soruyu sesli oku ve cevapla:",
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: GameTheme.textDark.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _onCevapla,
            icon: const Icon(Icons.mic, size: 22),
            label: Text(
              "CEVAPLA",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: GameTheme.goldAccent,
              foregroundColor: GameTheme.textDark,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerButtons() {
    return Column(
      children: [
        Text(
          "Cevap doğru muydu?",
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: GameTheme.textDark.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // BİLEMEDİN (Wrong)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () =>
                    ref.read(gameProvider.notifier).answerQuestion(false),
                icon: const Icon(Icons.close, size: 20),
                label: Text(
                  "BİLEMEDİN",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // BİLDİN (Correct)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () =>
                    ref.read(gameProvider.notifier).answerQuestion(true),
                icon: const Icon(Icons.check, size: 20),
                label: Text(
                  "BİLDİN",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }
}
