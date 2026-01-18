import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../core/theme/game_theme.dart';
import '../core/motion/motion_constants.dart';
import '../presentation/widgets/common/game_button.dart';

/// Modern Question Dialog Widget
/// A standalone UI component with modern card design, animations, and dynamic category-based colors.
class ModernQuestionDialog extends StatefulWidget {
  final String question;
  final String category;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ModernQuestionDialog({
    super.key,
    required this.question,
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

  /// Handle correct answer - trigger confetti
  void _handleCorrectAnswer() {
    // Trigger confetti explosion
    _confettiController.play();

    // Wait for confetti to start before calling callback
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

    // Reset shake state and call callback after animation
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
      'novel' || 'roman' => const Color(0xFF1E88E5), // Blue
      'poetry' || 'şiir' => const Color(0xFFEC407A), // Pink
      'story' || 'hikaye' => const Color(0xFF9C27B0), // Purple
      'play' || 'tiyatro' => const Color(0xFF43A047), // Green
      'essay' || 'deneme' => const Color(0xFFFF9800), // Orange
      _ => GameTheme.goldAccent, // Default Gold
    };
  }

  /// Get icon based on category
  IconData _getCategoryIcon(String category) {
    return switch (category.toLowerCase()) {
      'novel' || 'roman' => Icons.menu_book,
      'poetry' || 'şiir' => Icons.auto_stories,
      'story' || 'hikaye' => Icons.book,
      'play' || 'tiyatro' => Icons.theater_comedy,
      'essay' || 'deneme' => Icons.edit_note,
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
                    // Header with Category
                    _buildHeader(categoryColor, categoryIcon),

                    // Question Content
                    Flexible(child: _buildQuestionContent()),

                    // Action Buttons
                    _buildActionButtons(categoryColor),
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

    // Apply shake animation when wrong answer
    if (_isShaking) {
      dialogContainer = dialogContainer
          .animate(key: const ValueKey('shake'))
          .shake(
            duration: MotionDurations.slow,
            hz: 5,
            curve: Curves.easeInOut,
            offset: const Offset(10, 0), // Horizontal shake
          );
    }

    return Stack(
      children: [
        // Dialog
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
            child: dialogContainer,
          ),
        ),

        // Confetti overlay (centered)
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
              Color(0xFFFFD700), // Gold
              Color(0xFF1E88E5), // Blue
              Color(0xFFEC407A), // Pink
              Color(0xFF43A047), // Green
              Color(0xFFFF9800), // Orange
              Color(0xFF9C27B0), // Purple
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
              fontSize: 16,
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
          Icon(Icons.help_outline, color: GameTheme.goldAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            widget.question,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              height: 1.6,
              color: GameTheme.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Color categoryColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Cancel Button (Wrong Answer)
          Expanded(
            child: GameButton(
              label: 'BİLMEDİM',
              icon: Icons.close,
              variant: GameButtonVariant.secondary,
              isFullWidth: true,
              isDisabled: _isShaking,
              customColor: GameTheme.parchmentColor,
              customTextColor: GameTheme.textDark,
              onPressed: _handleWrongAnswer,
            ),
          ),
          const SizedBox(width: 12),

          // Confirm Button (Correct Answer)
          Expanded(
            child: GameButton(
              label: 'BİLDİM!',
              icon: Icons.check,
              variant: GameButtonVariant.primary,
              isFullWidth: true,
              isDisabled: _isShaking,
              customColor: categoryColor,
              customTextColor: Colors.white,
              onPressed: _handleCorrectAnswer,
            ),
          ),
        ],
      ),
    );
  }

  /// Custom star-shaped particle path for confetti
  Path _drawStar(Size size) {
    final path = Path();
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double outerRadius = size.width / 2;
    final double innerRadius = size.width / 4;
    const int points = 5;
    const double rotation = -math.pi / 2; // Start from top

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
