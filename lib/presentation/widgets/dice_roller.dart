import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/game_theme.dart';
import '../../core/motion/motion_constants.dart';
import '../../models/game_enums.dart';
import '../../providers/game_notifier.dart';
import '../../providers/theme_notifier.dart';

/// Stateless Dice Roller controlled by GameState
/// Shows spinning animation while rolling, static dice when done
class DiceRoller extends ConsumerWidget {
  const DiceRoller({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final themeState = ref.watch(themeProvider);
    final tokens = themeState.tokens;
    final currentPlayerName = state.currentPlayer.name;

    // Show rolling animation (SKIP if rolling for order, as we show status in button)
    if (state.isDiceRolling && state.phase != GamePhase.rollingForOrder) {
      return _buildRollingIndicator(tokens, currentPlayerName);
    }

    // Show dice result after roll
    if (state.isDiceRolled && state.diceTotal > 0) {
      return _buildDiceDisplay(
        state.diceTotal,
        tokens,
        currentPlayerName,
        state.dice1,
        state.dice2,
      );
    }

    // Show roll button
    return _buildRollButton(state, tokens, currentPlayerName, ref);
  }

  /// Build rolling indicator with spinning animation
  Widget _buildRollingIndicator(ThemeTokens tokens, String playerName) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$playerName atıyor...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Spinning dice icon
          Animate(
            onPlay: (controller) => controller.repeat(),
            effects: [
              RotateEffect(
                begin: 0,
                end: 1,
                duration: const Duration(milliseconds: 800),
                curve: Curves.linear,
              ),
            ],
            child: Icon(Icons.casino_rounded, size: 64, color: tokens.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Zarlar dönüyor...',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build dice display with results
  Widget _buildDiceDisplay(
    int total,
    ThemeTokens tokens,
    String playerName,
    int dice1,
    int dice2,
  ) {
    return Animate(
      effects: [
        // Bounce on land - scale up to 1.5x then elastic back to 1.0x
        ScaleEffect(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.5, 1.5),
          duration: MotionDurations.fast.safe,
          curve: Curves.easeOut,
        ),
        ScaleEffect(
          begin: const Offset(1.5, 1.5),
          end: const Offset(1.0, 1.0),
          duration: MotionDurations.slow.safe,
          curve: Curves.elasticOut,
          delay: MotionDurations.fast.safe,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.5),
              blurRadius: 24,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Player name and roll result
            Text(
              '$playerName attı:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$dice1 + $dice2 = $total',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // TWO DICE - Spaced evenly
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStaticDie(dice1, tokens),
                const SizedBox(width: 16),
                _buildStaticDie(dice2, tokens),
              ],
            ),
            const SizedBox(height: 12),
            // TOTAL display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: tokens.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: tokens.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                "TOPLAM: $total",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a static die display
  Widget _buildStaticDie(int value, ThemeTokens tokens) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tokens.border, width: 2),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$value',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  /// Build modern roll button
  Widget _buildRollButton(
    GameState state,
    ThemeTokens tokens,
    String currentPlayerName,
    WidgetRef ref,
  ) {
    final phase = state.phase;
    final isDoubleTurn = state.isDoubleTurn;
    final isTieBreaker = phase == GamePhase.tieBreaker;

    // Check if current player is in pending tie-breaker list
    final bool canRollInTieBreaker =
        isTieBreaker &&
        state.pendingTieBreakPlayers.any((p) => p.id == state.currentPlayer.id);

    // Determine button label based on phase and double turn
    final String buttonLabel;
    final Color buttonColor;
    if (phase == GamePhase.rollingForOrder) {
      // If rolling/processing, show loading state
      if (state.isDiceRolling) {
        buttonLabel = "Belirleniyor...";
      } else {
        buttonLabel = "SIRALAMA BELİRLE";
      }
      buttonColor = tokens.primary;
    } else if (isTieBreaker) {
      buttonLabel = "TEKRAR AT (Beraberlik)";
      buttonColor = Colors.orange.shade600;
    } else if (isDoubleTurn) {
      buttonLabel = "ÇİFT GELDİ - TEKRAR AT";
      buttonColor = Colors.orange.shade600;
    } else {
      buttonLabel = "ZAR AT";
      buttonColor = tokens.primary;
    }

    // Determine if button should be enabled
    final bool buttonEnabled = !isTieBreaker || canRollInTieBreaker;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Current player indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: phase == GamePhase.rollingForOrder
                ? Colors.amber.withValues(alpha: 0.2)
                : isTieBreaker
                ? Colors.red.withValues(alpha: 0.15)
                : isDoubleTurn
                ? Colors.orange.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: phase == GamePhase.rollingForOrder
                  ? Colors.amber.withValues(alpha: 0.5)
                  : isTieBreaker
                  ? Colors.red.withValues(alpha: 0.5)
                  : isDoubleTurn
                  ? Colors.orange.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.3),
              width: (isTieBreaker || isDoubleTurn) ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                isTieBreaker
                    ? '🔄 Tie-Breaker! ${state.tieBreakRound}. Tur'
                    : 'Sıra: $currentPlayerName',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  shadows: [
                    Shadow(
                      color: Colors.white.withValues(alpha: 0.5),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              if (phase == GamePhase.rollingForOrder)
                Text(
                  'Sıralama için zar atılıyor...',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                )
              else if (isTieBreaker)
                Text(
                  canRollInTieBreaker
                      ? '$currentPlayerName için zar at!'
                      : 'Diğer oyuncular zar atıyor...',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: canRollInTieBreaker
                        ? Colors.red.shade900
                        : Colors.black54,
                  ),
                )
              else if (isDoubleTurn)
                Text(
                  'Sıra Yine Sende! 🎲',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.deepOrange.shade900,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Show pending tie-breaker players list
        if (isTieBreaker && state.pendingTieBreakPlayers.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Beraber kalan oyuncular:',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: state.pendingTieBreakPlayers
                      .map(
                        (p) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: p.id == state.currentPlayer.id
                                ? Colors.orange.withValues(alpha: 0.3)
                                : Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: p.id == state.currentPlayer.id
                                  ? Colors.orange.withValues(alpha: 0.6)
                                  : Colors.grey.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            p.name,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        // UI Lock Button: Checks if automated turn order is running
        Builder(
          builder: (context) {
            // CHECK IF AUTOMATED TURN ORDER IS RUNNING - LOCK THE UI
            final isTurnOrderInProgress = ref
                .read(gameProvider.notifier)
                .isTurnOrderProcessing;

            return ElevatedButton(
              onPressed:
                  // LOCKED if automated turn order is running OR if button is not enabled
                  (buttonEnabled &&
                      !isTurnOrderInProgress &&
                      (!state.isDiceRolling ||
                          phase != GamePhase.rollingForOrder))
                  ? () {
                      if (phase == GamePhase.rollingForOrder) {
                        ref
                            .read(gameProvider.notifier)
                            .startAutomatedTurnOrder();
                      } else {
                        ref.read(gameProvider.notifier).rollDice();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: buttonEnabled ? 4 : 0,
                shadowColor: buttonColor.withValues(alpha: 0.3),
                disabledBackgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.casino_rounded, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    buttonLabel,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ); // Close ElevatedButton
          }, // Close builder function
        ), // Close Builder widget
      ],
    );
  }
}
