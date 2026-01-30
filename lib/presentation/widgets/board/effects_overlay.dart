import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/motion/motion_constants.dart';
import '../../../core/theme/game_theme.dart';
import '../../../core/utils/board_layout_config.dart';
import '../../../core/utils/board_layout_helper.dart';
import '../../../models/game_enums.dart';
import '../../../providers/game_notifier.dart';
import '../floating_score.dart';
import '../../dialogs/modern_question_dialog.dart';
import '../../dialogs/card_dialog.dart';
import '../../dialogs/notification_dialogs.dart';
import '../../dialogs/shop_dialog.dart';

/// Overlay widget containing all effects and dialogs
class EffectsOverlay extends StatelessWidget {
  final GameState state;
  final BoardLayoutConfig layout;
  final ConfettiController confettiController;
  final VoidCallback? onQuestionConfirm;
  final VoidCallback? onQuestionCancel;

  const EffectsOverlay({
    super.key,
    required this.state,
    required this.layout,
    required this.confettiController,
    this.onQuestionConfirm,
    this.onQuestionCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: _buildEffectsAndDialogs(context));
  }

  /// Build all overlay effects and modal dialogs
  List<Widget> _buildEffectsAndDialogs(BuildContext context) {
    return [
      // Confetti effect - shoots from bottom center with celebratory colors
      Align(
        alignment: Alignment.bottomCenter,
        child: ConfettiWidget(
          confettiController: confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          blastDirection: -3.14159 / 2, // Shoots upward (π/2 radians)
          emissionFrequency: 0.05,
          numberOfParticles: 30,
          maxBlastForce: 40,
          minBlastForce: 20,
          gravity: 0.1,
          particleDrag: 0.05,
          colors: const [
            Color(0xFFD4AF37), // Gold
            Color(0xFF1976D2), // Blue
            Color(0xFFD32F2F), // Red
            Color(0xFF388E3C), // Green
            Color(0xFFFFFFFF), // White
            Color(0xFFE91E63), // Pink
          ],
          createParticlePath: _drawStar,
        ),
      ),
      // Secondary confetti from top for rain effect
      Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: confettiController,
          blastDirectionality: BlastDirectionality.directional,
          blastDirection: 3.14159 / 2, // Shoots downward
          emissionFrequency: 0.03,
          numberOfParticles: 15,
          maxBlastForce: 10,
          minBlastForce: 5,
          gravity: 0.15,
          particleDrag: 0.02,
          colors: const [
            Color(0xFFD4AF37), // Gold
            Color(0xFF1976D2), // Blue
            Color(0xFFD32F2F), // Red
            Color(0xFF388E3C), // Green
          ],
        ),
      ),

      // Modal dialogs
      if (state.showQuestionDialog && state.currentQuestion != null)
        _buildDialogOverlay(
          ModernQuestionDialog(
            question: state.currentQuestion!.text,
            answer: state
                .currentQuestion!
                .options[state.currentQuestion!.correctIndex],
            category: _getCategoryString(state.currentQuestion!.category),
            onConfirm: onQuestionConfirm ?? () {},
            onCancel: onQuestionCancel ?? () {},
          ),
        ),

      if (state.showCardDialog && state.currentCard != null)
        _buildDialogOverlay(CardDialog(card: state.currentCard!)),

      // Notification dialogs
      if (state.showLibraryPenaltyDialog)
        _buildDialogOverlay(const LibraryPenaltyDialog()),

      if (state.showTurnSkippedDialog)
        _buildDialogOverlay(const TurnSkippedDialog()),

      if (state.showImzaGunuDialog) _buildDialogOverlay(const ImzaGunuDialog()),

      // Shop Dialog (Kıraathane)
      if (state.showShopDialog) _buildDialogOverlay(const ShopDialog()),

      // Floating Score Effect (stars changes)
      if (state.floatingEffect != null) _buildFloatingScore(state),
    ];
  }

  /// Wrap dialog in overlay with animation
  Widget _buildDialogOverlay(Widget dialog) {
    return Container(
      color: GameTheme.dialogOverlayColor,
      child: Center(
        child: dialog
            .animate()
            .scale(
              duration: MotionDurations.dialog.safe,
              curve: MotionCurves.emphasized,
            )
            .fadeIn(),
      ),
    );
  }

  /// Build floating score effect positioned over current player's pawn
  Widget _buildFloatingScore(GameState state) {
    final effect = state.floatingEffect!;
    final playerPosition = state.currentPlayer.position;
    final pawnCenter = BoardLayoutHelper.getTileCenter(playerPosition, layout);

    // Determine if score is positive based on text (starts with +)
    final isPositive = effect.text.startsWith('+');

    return Positioned(
      left: pawnCenter.dx - 60, // Center horizontally (approx text width/2)
      top: pawnCenter.dy - 80, // Position above pawn
      child: FloatingScore(
        key: ValueKey(
          'score_${effect.text}_${DateTime.now().millisecondsSinceEpoch}',
        ),
        text: effect.text,
        color: effect.color,
        isPositive: isPositive,
        onComplete: () {
          // Effect is auto-cleared by game_notifier after delay
          // No action needed here
        },
      ),
    );
  }

  /// Convert QuestionCategory enum to display string
  String _getCategoryString(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.benKimim:
        return 'Ben Kimim?';
      case QuestionCategory.turkEdebiyatindaIlkler:
        return 'İlkler';
      case QuestionCategory.edebiyatAkimlari:
        return 'Edebi Akımlar';
      case QuestionCategory.edebiSanatlar:
        return 'Edebi Sanatlar';
      case QuestionCategory.eserKarakter:
        return 'Eser & Karakter';
      case QuestionCategory.tesvik:
        return 'Teşvik';
    }
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
