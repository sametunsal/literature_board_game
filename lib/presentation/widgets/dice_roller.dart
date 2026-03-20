import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/game_theme.dart';
import '../../core/motion/motion_constants.dart';
import '../../models/game_enums.dart';
import '../../providers/game_notifier.dart';
import '../../providers/theme_notifier.dart';

/// Animated single die with shake and rotation effects
class AnimatedDie extends StatefulWidget {
  final int value;
  final double size;
  final ThemeTokens tokens;
  final bool isRolling;

  const AnimatedDie({
    super.key,
    required this.value,
    required this.size,
    required this.tokens,
    this.isRolling = false,
  });

  @override
  State<AnimatedDie> createState() => _AnimatedDieState();
}

class _AnimatedDieState extends State<AnimatedDie>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Shake animation (left-right movement)
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Rotation animation (slight tilt)
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Scale animation (pulse effect)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(AnimatedDie oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start animation when rolling state changes to true
    if (widget.isRolling && !oldWidget.isRolling) {
      _startRollingAnimation();
    }
  }

  void _startRollingAnimation() {
    // Create shake effect with random direction
    final random = math.Random();
    final shakeDirection = random.nextBool() ? 1.0 : -1.0;

    _shakeAnimation = Tween<double>(begin: 0, end: 15.0 * shakeDirection)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
          ),
        );

    // Add rotation
    _rotationAnimation = Tween<double>(begin: 0, end: 0.3 * shakeDirection)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
          ),
        );

    // Add scale pulse
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0),
        weight: 0.5,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            ),
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: widget.tokens.border, width: 2),
            boxShadow: [
              BoxShadow(
                color: widget.tokens.shadow.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.isRolling ? '?' : '${widget.value}',
              style: GoogleFonts.poppins(
                fontSize: widget.size * 0.45,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
    final shortestSide = screenSize.shortestSide;

    // Show rolling animation (SKIP if rolling for order, as we show status in button)
    if (state.isDiceRolling && state.phase != GamePhase.rollingForOrder) {
      return _buildRollingIndicator(tokens, currentPlayerName, shortestSide);
    }

    // Show dice result after roll
    if (state.isDiceRolled && state.diceTotal > 0) {
      return _buildDiceDisplay(
        state.diceTotal,
        tokens,
        currentPlayerName,
        state.dice1,
        state.dice2,
        shortestSide,
      );
    }

    // Show roll button
    return _buildRollButton(
      state,
      tokens,
      currentPlayerName,
      ref,
      shortestSide,
    );
  }

  /// Build rolling indicator with animated dice
  Widget _buildRollingIndicator(
    ThemeTokens tokens,
    String playerName,
    double shortestSide,
  ) {
    final dieSize = shortestSide * 0.10; // 10% of shortest side

    return FittedBox(
      fit: BoxFit.contain,
      child: Container(
        padding: EdgeInsets.all(shortestSide * 0.02),
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
                fontSize: shortestSide * 0.018,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: shortestSide * 0.02),
            // Animated rolling dice
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedDie(
                  value: 1, // Placeholder value, will show '?' while rolling
                  size: dieSize,
                  tokens: tokens,
                  isRolling: true,
                ),
                SizedBox(width: shortestSide * 0.02),
                AnimatedDie(
                  value: 1, // Placeholder value, will show '?' while rolling
                  size: dieSize,
                  tokens: tokens,
                  isRolling: true,
                ),
              ],
            ),
            SizedBox(height: shortestSide * 0.02),
            Text(
              'Zarlar dönüyor...',
              style: GoogleFonts.poppins(
                fontSize: shortestSide * 0.015,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
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
    double shortestSide,
  ) {
    final dieSize = shortestSide * 0.10; // 10% of shortest side for each die

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
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          padding: EdgeInsets.all(shortestSide * 0.03),
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
                  fontSize: shortestSide * 0.018,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: shortestSide * 0.01),
              Text(
                '$dice1 + $dice2 = $total',
                style: GoogleFonts.poppins(
                  fontSize: shortestSide * 0.03,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: shortestSide * 0.02),
              // TWO DICE - Spaced evenly with AnimatedDie widgets
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedDie(
                    value: dice1,
                    size: dieSize,
                    tokens: tokens,
                    isRolling: false, // Already rolled, show static
                  ),
                  SizedBox(width: shortestSide * 0.02),
                  AnimatedDie(
                    value: dice2,
                    size: dieSize,
                    tokens: tokens,
                    isRolling: false, // Already rolled, show static
                  ),
                ],
              ),
              SizedBox(height: shortestSide * 0.015),
              // TOTAL display
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: shortestSide * 0.025,
                  vertical: shortestSide * 0.012,
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
                    fontSize: shortestSide * 0.02,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
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
    double shortestSide,
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

    return FittedBox(
      fit: BoxFit.contain,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current player indicator
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: shortestSide * 0.02,
              vertical: shortestSide * 0.01,
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
                      fontSize: shortestSide * 0.025,
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
                        fontSize: shortestSide * 0.015,
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
                        fontSize: shortestSide * 0.016,
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
                        fontSize: shortestSide * 0.018,
                        fontWeight: FontWeight.w700,
                        color: Colors.deepOrange.shade900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: shortestSide * 0.02),
          // Show pending tie-breaker players list
          if (isTieBreaker && state.pendingTieBreakPlayers.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: shortestSide * 0.015,
                vertical: shortestSide * 0.01,
              ),
              margin: EdgeInsets.only(bottom: shortestSide * 0.015),
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
                        fontSize: shortestSide * 0.014,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: shortestSide * 0.008),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: state.pendingTieBreakPlayers
                        .map(
                          (p) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: shortestSide * 0.012,
                              vertical: shortestSide * 0.008,
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
                                  fontSize: shortestSide * 0.014,
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
                    horizontal: shortestSide * 0.04,
                    vertical: shortestSide * 0.025,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.casino_rounded, size: shortestSide * 0.04),
                    SizedBox(width: shortestSide * 0.015),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          buttonLabel,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: shortestSide * 0.028,
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
      ),
    );
  }
}
