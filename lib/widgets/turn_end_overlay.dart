import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/turn_phase.dart';
import '../models/player_type.dart';
import '../providers/game_provider.dart';

/// Turn End Overlay - Phase 4 implementation
///
/// Purpose: Provides clear, intentional transition from turnEnded → start
///
/// Phase 4 Rules:
/// - Visible ONLY when TurnPhase.turnEnded
/// - UI is PASSIVE observer (watches turnPhase)
/// - UI calls ONLY playTurn() via _handleContinue()
/// - Button is GATED by TurnPhase.turnEnded
/// - No automatic transitions, requires manual "Devam" button press
///
/// Visual Language:
/// - Calm, neutral design
/// - Semi-transparent overlay
/// - Static (no animations required)
///
/// This overlay is the ONLY manual step between turns
class TurnEndOverlay extends ConsumerWidget {
  const TurnEndOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turnPhase = ref.watch(turnPhaseProvider);
    final gameState = ref.watch(gameProvider);
    final lastTurnResult = ref.watch(lastTurnResultProvider);

    final currentPlayer = gameState.currentPlayer;

    // Phase 5.1: Bot skip - TurnEndOverlay is hidden for bot players
    // Bot turns auto-progress, no manual "Devam" button needed
    if (currentPlayer?.type == PlayerType.bot) {
      return const SizedBox.shrink();
    }

    // Overlay is visible ONLY during TurnPhase.turnEnded
    final isVisible = turnPhase == TurnPhase.turnEnded;

    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Colors.brown.shade700,
              ),
              const SizedBox(height: 16),

              Text(
                'Tur Bitti',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade900,
                ),
              ),
              const SizedBox(height: 8),

              // Current player info
              if (currentPlayer != null) ...[
                Text(
                  'Sıradaki Oyuncu:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(currentPlayer.color.substring(1), radix: 16) +
                          0xFF000000,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(
                        int.parse(currentPlayer.color.substring(1), radix: 16) +
                            0xFF000000,
                      ),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(
                            int.parse(
                                  currentPlayer.color.substring(1),
                                  radix: 16,
                                ) +
                                0xFF000000,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currentPlayer.name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Star change summary (if available)
              if (lastTurnResult.starsDelta != 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: lastTurnResult.starsDelta >= 0
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: lastTurnResult.starsDelta >= 0
                          ? Colors.green.shade300
                          : Colors.red.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        lastTurnResult.starsDelta >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: lastTurnResult.starsDelta >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${lastTurnResult.starsDelta >= 0 ? "+" : ""}${lastTurnResult.starsDelta} yıldız',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: lastTurnResult.starsDelta >= 0
                              ? Colors.green.shade900
                              : Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ] else
                const SizedBox(height: 24),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleContinue(ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Devam',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handles continue button and triggers Phase 2 orchestration
  // Phase 4: This is the ONLY manual step between turns
  // Calls playTurn() to advance from turnEnded → start
  static void _handleContinue(WidgetRef ref) {
    // Trigger Phase 2 orchestration
    // playTurn() will handle phase progression: turnEnded → start
    ref.read(gameProvider.notifier).playTurn();
  }
}
