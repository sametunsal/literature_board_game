import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../core/theme/game_theme.dart';
import '../core/motion/motion_constants.dart';
import '../models/game_enums.dart';
import '../providers/game_notifier.dart';
import '../providers/theme_notifier.dart';
import '../utils/sound_manager.dart';

/// Premium dice roller with TWO separate Lottie dice animations
class DiceRoller extends ConsumerStatefulWidget {
  const DiceRoller({super.key});

  @override
  ConsumerState<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends ConsumerState<DiceRoller>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  bool _isAnimating = false;
  bool _showResult = false;
  int _dice1 = 0;
  int _dice2 = 0;
  final _random = math.Random();
  Timer? _hapticTimer; // For haptic feedback during dice roll

  // Dice Juice animation states
  double _diceScale = 1.0;
  bool _showGlow = false;
  bool _resultBounce = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
      duration: MotionDurations.dice.safe,
    );

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Stop haptic timer and deliver heavy "thud" on landing
        _hapticTimer?.cancel();
        HapticFeedback.heavyImpact();
        SoundManager.instance.playDiceLand(); // Dice landing sound

        setState(() {
          _isAnimating = false;
          _showResult = true;
          _diceScale = 1.0; // Reset scale
          _showGlow = false; // Remove glow
          _resultBounce = true; // Trigger result bounce
        });

        // Reset bounce state after animation
        Future.delayed(MotionDurations.fast, () {
          if (mounted) {
            setState(() => _resultBounce = false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _hapticTimer?.cancel();
    _lottieController.dispose();
    super.dispose();
  }

  /// Split total (2-12) into two valid dice values
  void _splitDiceValues(int total) {
    // Generate valid dice combinations
    _dice1 = _random.nextInt(6) + 1; // 1-6
    _dice2 = total - _dice1;

    // Ensure dice2 is valid (1-6)
    if (_dice2 < 1) {
      _dice2 = 1;
      _dice1 = total - 1;
    } else if (_dice2 > 6) {
      _dice2 = 6;
      _dice1 = total - 6;
    }

    // Clamp to valid range
    _dice1 = _dice1.clamp(1, 6);
    _dice2 = _dice2.clamp(1, 6);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final themeState = ref.watch(themeProvider);
    final tokens = themeState.tokens;

    // When dice is rolled, start animation
    if (state.isDiceRolled &&
        state.diceTotal > 0 &&
        !_isAnimating &&
        !_showResult) {
      _splitDiceValues(state.diceTotal);
      _startAnimation();
    }

    // Reset when dice is no longer shown
    if (!state.isDiceRolled && _showResult) {
      _resetState();
    }

    // Show dice result after roll
    if (state.isDiceRolled && state.diceTotal > 0) {
      return _buildDiceDisplay(state.diceTotal, tokens);
    }

    // Show roll button
    return _buildRollButton(state.phase);
  }

  void _startAnimation() {
    setState(() {
      _isAnimating = true;
      _showResult = false;
      _diceScale = 1.1; // Scale up for "juice"
      _showGlow = true; // Enable glow
    });

    // Start haptic feedback during animation - random light taps
    _hapticTimer = Timer.periodic(MotionDurations.fast, (timer) {
      if (_isAnimating) {
        HapticFeedback.lightImpact();
      } else {
        timer.cancel();
      }
    });

    _lottieController.forward(from: 0);
  }

  void _resetState() {
    setState(() {
      _showResult = false;
      _isAnimating = false;
      _diceScale = 1.0;
      _showGlow = false;
      _resultBounce = false;
    });
    _lottieController.reset();
  }

  /// Build TWO dice side by side with individual numbers below
  Widget _buildDiceDisplay(int total, ThemeTokens tokens) {
    // Calculate bounce scale for result appearance
    final displayScale = _resultBounce ? 1.12 : 1.0;

    return AnimatedScale(
      scale: _diceScale * displayScale,
      duration: MotionDurations.fast.safe,
      curve: MotionCurves.standard,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: _showGlow
              ? [
                  BoxShadow(
                    color: tokens.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: tokens.primary.withValues(alpha: 0.2),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TWO DICE - Spaced evenly
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // DICE 1
                _buildSingleDie(_dice1),
                const SizedBox(width: 16),
                // DICE 2
                _buildSingleDie(_dice2),
              ],
            ),

            const SizedBox(height: 12),

            // TOTAL display below both dice - V2.5 styled
            if (_showResult)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [GameTheme.copperAccent, GameTheme.goldAccent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: GameTheme.goldAccent.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(3, 4),
                    ),
                    BoxShadow(
                      color: GameTheme.goldAccent.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Text(
                  "TOPLAM: $total",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: GameTheme
                        .tableBackgroundColor, // Dark text for contrast
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build a single die with Lottie animation and number below - V2.5 Tactile Rebellion
  Widget _buildSingleDie(int value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lottie animation
        SizedBox(
          width: 80,
          height: 80,
          child: Lottie.asset(
            'assets/animations/dice.json',
            controller: _lottieController,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackDie(value);
            },
          ),
        ),

        const SizedBox(height: 6),

        // Individual die value BELOW - V2.5 styled with gradient
        if (_showResult)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              // Copper to Gold gradient for tactile feel
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [GameTheme.copperAccent, GameTheme.goldAccent],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: GameTheme.goldAccent.withValues(alpha: 0.8),
                width: 2,
              ),
              // Heavy 3D shadow for raised effect
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(4, 4),
                ),
                BoxShadow(
                  color: GameTheme.goldAccent.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: -1,
                  offset: const Offset(-1, -1),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Paper texture overlay
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Opacity(
                    opacity: 0.05,
                    child: Image.asset(
                      'assets/images/paper_noise.png',
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                      colorBlendMode: BlendMode.overlay,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Pip number - dark for contrast
                Center(
                  child: Text(
                    '$value',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: GameTheme.tableBackgroundColor, // Dark pips
                      shadows: [
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          blurRadius: 1,
                          offset: const Offset(0.5, 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Fallback die display if Lottie fails - V2.5 Tactile Rebellion style
  Widget _buildFallbackDie(int value) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        // Copper to Gold gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [GameTheme.copperAccent, GameTheme.goldAccent],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: GameTheme.goldAccent.withValues(alpha: 0.8),
          width: 2,
        ),
        // Heavy 3D shadow for raised effect
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
          BoxShadow(
            color: GameTheme.goldAccent.withValues(alpha: 0.2),
            blurRadius: 4,
            spreadRadius: -2,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Paper texture overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/paper_noise.png',
                fit: BoxFit.cover,
                width: 60,
                height: 60,
                colorBlendMode: BlendMode.overlay,
                color: Colors.white,
              ),
            ),
          ),
          // Pip number - dark for contrast
          Center(
            child: Text(
              '$value',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: GameTheme.tableBackgroundColor, // Dark pips
                shadows: [
                  Shadow(
                    color: Colors.white.withValues(alpha: 0.4),
                    blurRadius: 1,
                    offset: const Offset(0.5, 0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build stylized roll button - V2.5 Tactile Rebellion
  Widget _buildRollButton(GamePhase phase) {
    // Determine button label based on phase
    final String buttonLabel = phase == GamePhase.rollingForOrder
        ? "SIRA İÇİN ZAR AT"
        : "ZAR AT";

    return Container(
      decoration: BoxDecoration(
        // Copper to Gold gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [GameTheme.copperAccent, GameTheme.goldAccent],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: GameTheme.goldAccent.withValues(alpha: 0.6),
          width: 1.5,
        ),
        // Heavy 3D shadow for raised effect
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
          BoxShadow(
            color: GameTheme.goldAccent.withValues(alpha: 0.3),
            blurRadius: 6,
            spreadRadius: -2,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            SoundManager.instance.playDiceRoll(); // Start roll sound
            // Route based on phase
            if (phase == GamePhase.rollingForOrder) {
              ref.read(gameProvider.notifier).rollForTurnOrder();
            } else {
              ref.read(gameProvider.notifier).rollDice();
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.casino,
                  size: 24,
                  color: GameTheme.tableBackgroundColor, // Dark icon
                ),
                const SizedBox(width: 8),
                Text(
                  buttonLabel,
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: GameTheme.tableBackgroundColor, // Dark text
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
