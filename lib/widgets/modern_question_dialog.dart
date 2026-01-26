import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../core/theme/game_theme.dart';
import '../core/motion/motion_constants.dart';
import '../presentation/widgets/common/game_button.dart';

/// Modern Question Dialog Widget - Flashcard Style
/// Shows question, then reveals answer on user request.
/// User self-assesses with BİLDİN / BİLEMEDİN buttons.
class ModernQuestionDialog extends StatefulWidget {
  final String question;
  final String answer;
  final String category;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ModernQuestionDialog({
    super.key,
    required this.question,
    required this.answer,
    required this.category,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<ModernQuestionDialog> createState() => _ModernQuestionDialogState();
}

class _ModernQuestionDialogState extends State<ModernQuestionDialog> {
  late ConfettiController _confettiController;
  bool _isShaking = false;
  bool _isAnswerRevealed = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: MotionDurations.confetti,
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// Reveal the answer
  void _revealAnswer() {
    setState(() {
      _isAnswerRevealed = true;
    });
  }

  /// Handle correct answer - trigger confetti
  void _handleCorrectAnswer() {
    _confettiController.play();
    Future.delayed(MotionDurations.dice, () {
      if (mounted) {
        widget.onConfirm();
      }
    });
  }

  /// Handle wrong answer - trigger shake animation
  void _handleWrongAnswer() {
    setState(() {
      _isShaking = true;
    });
    Future.delayed(MotionDurations.slow, () {
      if (mounted) {
        setState(() {
          _isShaking = false;
        });
        widget.onCancel();
      }
    });
  }

  /// Get dynamic accent color based on category
  Color _getCategoryColor(String category) {
    return switch (category.toLowerCase()) {
      'ben kimim?' => const Color(0xFF7B1FA2),
      'ilkler' => const Color(0xFF1976D2),
      'edebi akımlar' => const Color(0xFFD32F2F),
      'edebi sanatlar' => const Color(0xFF388E3C),
      'eser & karakter' => const Color(0xFFFF8C00),
      'bonus bilgiler' => const Color(0xFF9C27B0),
      _ => GameTheme.goldAccent,
    };
  }

  /// Get icon based on category
  IconData _getCategoryIcon(String category) {
    return switch (category.toLowerCase()) {
      'ben kimim?' => Icons.person_search,
      'ilkler' => Icons.emoji_events,
      'edebi akımlar' => Icons.auto_stories,
      'edebi sanatlar' => Icons.brush,
      'eser & karakter' => Icons.menu_book,
      'bonus bilgiler' => Icons.lightbulb,
      _ => Icons.help_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(widget.category);
    final categoryIcon = _getCategoryIcon(widget.category);

    Widget dialogContainer =
        Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: GameTheme.tableBackgroundColor.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: categoryColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: categoryColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: -2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(categoryColor, categoryIcon),
                    Flexible(child: _buildQuestionContent()),
                    if (!_isAnswerRevealed)
                      _buildRevealButton(categoryColor)
                    else
                      _buildAnswerRevealedSection(categoryColor),
                  ],
                ),
              ),
            )
            .animate()
            .fadeIn(
              duration: MotionDurations.dialog.safe,
              curve: MotionCurves.standard,
            )
            .slideY(
              begin: 0.3,
              end: 0,
              duration: MotionDurations.dialog.safe,
              curve: MotionCurves.standard,
            )
            .scale(
              begin: const Offset(0.92, 0.92),
              end: const Offset(1.0, 1.0),
              duration: MotionDurations.dialog.safe,
              curve: MotionCurves.emphasized,
            );

    if (_isShaking) {
      dialogContainer = dialogContainer
          .animate(key: const ValueKey('shake'))
          .shake(
            duration: MotionDurations.slow,
            hz: 5,
            curve: Curves.easeInOut,
            offset: const Offset(10, 0),
          );
    }

    return Stack(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 580),
            child: dialogContainer,
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            maxBlastForce: 25,
            minBlastForce: 10,
            gravity: 0.2,
            colors: const [
              Color(0xFFFFD700),
              Color(0xFF1E88E5),
              Color(0xFFEC407A),
              Color(0xFF43A047),
              Color(0xFFFF9800),
              Color(0xFF9C27B0),
            ],
            createParticlePath: _drawStar,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Color categoryColor, IconData categoryIcon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [categoryColor, categoryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(categoryIcon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            widget.category.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.help_outline, color: GameTheme.goldAccent, size: 40),
          const SizedBox(height: 16),
          Text(
            widget.question,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 17,
              height: 1.6,
              color: GameTheme.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// "CEVABI GÖSTER" button - shown before answer is revealed
  Widget _buildRevealButton(Color categoryColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            "Cevabı düşün, hazır olunca aç:",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: GameTheme.textDark.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _revealAnswer,
              icon: const Icon(Icons.visibility, size: 26),
              label: Text(
                "CEVABI GÖSTER",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: categoryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Answer revealed section - shows answer + BİLDİN/BİLEMEDİN buttons
  Widget _buildAnswerRevealedSection(Color categoryColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // CORRECT ANSWER DISPLAY
          Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF388E3C).withValues(alpha: 0.95),
                      const Color(0xFF2E7D32).withValues(alpha: 0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF388E3C).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "DOĞRU CEVAP",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.answer,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.0, 1.0),
                duration: 300.ms,
                curve: Curves.easeOut,
              ),

          const SizedBox(height: 16),

          Text(
            "Doğru bildin mi?",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: GameTheme.textDark.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          // BİLDİN / BİLEMEDİN BUTTONS
          Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: GameButton(
                        label: 'BİLEMEDİN',
                        icon: Icons.close,
                        variant: GameButtonVariant.secondary,
                        isFullWidth: true,
                        isDisabled: _isShaking,
                        customColor: const Color(0xFFD32F2F),
                        customTextColor: Colors.white,
                        onPressed: _handleWrongAnswer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: GameButton(
                        label: 'BİLDİN!',
                        icon: Icons.check,
                        variant: GameButtonVariant.primary,
                        isFullWidth: true,
                        isDisabled: _isShaking,
                        customColor: const Color(0xFF388E3C),
                        customTextColor: Colors.white,
                        onPressed: _handleCorrectAnswer,
                      ),
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 300.ms, delay: 150.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Path _drawStar(Size size) {
    final path = Path();
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double outerRadius = size.width / 2;
    final double innerRadius = size.width / 4;
    const int points = 5;
    const double rotation = -math.pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final double radius = i.isEven ? outerRadius : innerRadius;
      final double angle = rotation + (i * math.pi / points);
      final double x = centerX + radius * math.cos(angle);
      final double y = centerY + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }
}
