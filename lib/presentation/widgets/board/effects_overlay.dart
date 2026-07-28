import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../../core/utils/board_layout_config.dart';
import '../../../core/utils/board_layout_helper.dart';

import '../../../providers/game_notifier.dart';
import '../../../providers/dialog_provider.dart';
import '../reward_toast.dart';

/// Overlay widget containing all effects and dialogs
class EffectsOverlay extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final dialog = ref.watch(dialogProvider);
    return Stack(children: _buildEffectsAndDialogs(context, dialog));
  }

  /// Build all overlay effects and modal dialogs
  List<Widget> _buildEffectsAndDialogs(
    BuildContext context,
    DialogState dialog,
  ) {
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

      // Floating Score Effect (stars changes)
      // NOTE: All dialogs moved to BoardView._buildFlatDialogLayer to prevent isometric transform inheritance
      if (state.floatingEffect != null) _buildFloatingScore(state),
    ];
  }

  /// Build the reward toast positioned above the current player's pawn,
  /// clamped so it never leaves the board.
  Widget _buildFloatingScore(GameState state) {
    final effect = state.floatingEffect!;
    // Anchor to the tile captured when the reward fired; the toast can
    // outlive the turn that earned it, so currentPlayer is only a fallback.
    final playerPosition =
        effect.anchorTilePosition ?? state.currentPlayer.position;
    final pawnCenter = BoardLayoutHelper.getTileCenter(playerPosition, layout);

    final margin = layout.kShortSide * 0.15;
    final boxWidth = math.min(300.0, layout.actualWidth - margin * 2);
    const boxHeight = 72.0;
    final rawLeft = pawnCenter.dx - boxWidth / 2;
    final rawTop = pawnCenter.dy - boxHeight - layout.kShortSide * 0.35;
    final maxLeft = math.max(margin, layout.actualWidth - boxWidth - margin);
    final maxTop = math.max(margin, layout.actualHeight - boxHeight - margin);
    final left = rawLeft.clamp(margin, maxLeft).toDouble();
    final top = rawTop.clamp(margin, maxTop).toDouble();

    return Positioned(
      left: left,
      top: top,
      child: SizedBox(
        width: boxWidth,
        height: boxHeight,
        child: RewardToast(
          // Keyed by the effect *instance*, never by wall-clock time. A
          // time-based key changes on every build, so any rebuild while the
          // toast was on screen (hiding the question dialog, ending the turn)
          // remounted it and replayed its entry animation — one reward read as
          // two popups. Identity keying matches the notifier, which clears the
          // toast only when `identical(state.floatingEffect, effect)`: the same
          // reward keeps one element and one animation, while a genuinely new
          // reward still gets a fresh element and a fresh animation.
          key: ObjectKey(effect),
          text: effect.text,
          color: effect.color,
          title: effect.title,
          icon: effect.icon,
          onComplete: () {
            // Effect is auto-cleared by game_notifier after delay
            // No action needed here
          },
        ),
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
