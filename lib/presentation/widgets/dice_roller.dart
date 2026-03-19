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
    final screenSize = MediaQuery.of(context).size;

    // Show rolling animation (SKIP if rolling for order, as we show status in button)
    if (state.isDiceRolling && state.phase != GamePhase.rollingForOrder) {
      return _buildRollingIndicator(tokens, currentPlayerName, screenSize);
    }

    // Show dice result after roll
    if (state.isDiceRolled && state.diceTotal > 0) {
      return _buildDiceDisplay(
        state.diceTotal,
        tokens,
        currentPlayerName,
        state.dice1,
        state.dice2,
        screenSize,
      );
    }

    // Show roll button
    return _buildRollButton(state, tokens, currentPlayerName, ref, screenSize);
  }

  /// Build rolling indicator with spinning animation
  Widget _buildRollingIndicator(ThemeTokens tokens, String playerName, Size screenSize) {
    final iconSize = screenSize.width * 0.12; // 12% of screen width

    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.02),
      constraints: const BoxConstraints(maxWidth: 280),
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
              fontSize: screenSize.width * 0.018,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenSize.width * 0.02),
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
            child: Icon(Icons.casino_rounded, size: iconSize, color: tokens.primary),
          ),
          SizedBox(height: screenSize.width * 0.02),
          Text(
            'Zarlar dönüyor...',
            style: GoogleFonts.poppins(
              fontSize: screenSize.width * 0.015,
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
    Size screenSize,
  ) {
    final dieSize = screenSize.width * 0.10; // 10% of screen width for each die

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
        padding: EdgeInsets.all(screenSize.width * 0.03),
        constraints: const BoxConstraints(maxWidth: 320),
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
                fontSize: screenSize.width * 0.018,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenSize.width * 0.01),
            Text(
              '$dice1 + $dice2 = $total',
              style: GoogleFonts.poppins(
                fontSize: screenSize.width * 0.03,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenSize.width * 0.02),
            // TWO DICE - Spaced evenly
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStaticDie(dice1, tokens, dieSize),
                SizedBox(width: screenSize.width * 0.02),
                _buildStaticDie(dice2, tokens, dieSize),
              ],
            ),
            SizedBox(height: screenSize.width * 0.015),
            // TOTAL display
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.025,
                vertical: screenSize.width * 0.012,
              ),
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
                  fontSize: screenSize.width * 0.02,
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
  Widget _buildStaticDie(int value, ThemeTokens tokens, double size) {
    return Container(
      width: size,
      height: size,
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
            fontSize: size * 0.45,
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
    Size screenSize,
  ) {
    final phase = state.phase;
    final isDoubleTurn = state.isDoubleTurn;
    final isTieBreaker = phase == GamePhase.tieBreaker;
    final isMobile = screenSize.width < 600;

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
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.02,
            vertical: screenSize.width * 0.01,
          ),
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
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isTieBreaker
                      ? '🔄 Tie-Breaker! ${state.tieBreakRound}. Tur'
                      : 'Sıra: $currentPlayerName',
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? screenSize.width * 0.025 : 18,
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
              ),
              if (phase == GamePhase.rollingForOrder)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Sıralama için zar atılıyor...',
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? screenSize.width * 0.015 : 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                )
              else if (isTieBreaker)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    canRollInTieBreaker
                        ? '$currentPlayerName için zar at!'
                        : 'Diğer oyuncular zar atıyor...',
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? screenSize.width * 0.016 : 13,
                      fontWeight: FontWeight.w600,
                      color: canRollInTieBreaker
                          ? Colors.red.shade900
                          : Colors.black54,
                    ),
                  ),
                )
              else if (isDoubleTurn)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Sıra Yine Sende! 🎲',
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? screenSize.width * 0.018 : 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.deepOrange.shade900,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: screenSize.width * 0.02),
        // Show pending tie-breaker players list
        if (isTieBreaker && state.pendingTieBreakPlayers.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.015,
              vertical: screenSize.width * 0.01,
            ),
            margin: EdgeInsets.only(bottom: screenSize.width * 0.015),
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Beraber kalan oyuncular:',
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? screenSize.width * 0.014 : 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: screenSize.width * 0.008),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: state.pendingTieBreakPlayers
                      .map(
                        (p) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.012,
                            vertical: screenSize.width * 0.008,
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
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              p.name,
                              style: GoogleFonts.poppins(
                                fontSize: isMobile ? screenSize.width * 0.014 : 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
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
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? screenSize.width * 0.04 : 32,
                  vertical: isMobile ? screenSize.width * 0.025 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.casino_rounded, size: isMobile ? screenSize.width * 0.04 : 24),
                  SizedBox(width: isMobile ? screenSize.width * 0.015 : 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        buttonLabel,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? screenSize.width * 0.028 : 18,
                        ),
                      ),
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
