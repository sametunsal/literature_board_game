import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
/// Features "Game Juice" animations: shake before roll, bounce on land,
/// sound sync, and colorful glow effects.
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
  Timer? _hapticTimer;

  // Animation trigger keys for flutter_animate
  bool _triggerShake = false;
  bool _triggerBounce = false;
  bool _showGlow = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
      duration: MotionDurations.dice.safe,
    );

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onDiceLanded();
      }
    });
  }

  void _onDiceLanded() {
    // Stop haptic timer and deliver heavy "thud" on landing
    _hapticTimer?.cancel();
    HapticFeedback.heavyImpact();

    // Trigger landing sound and animations
    SoundManager.instance.playDiceLand();

    setState(() {
      _isAnimating = false;
      _showResult = true;
      _showGlow = true;
      _triggerBounce = true;
    });

    // Reset glow after landing animation completes
    Future.delayed(MotionDurations.medium.safe, () {
      if (mounted) {
        setState(() => _showGlow = false);
      }
    });
  }

  @override
  void dispose() {
    _hapticTimer?.cancel();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final themeState = ref.watch(themeProvider);
    final tokens = themeState.tokens;

    // Listen to dice state changes
    ref.listen<GameState>(gameProvider, (previous, next) {
      if (next.isDiceRolled &&
          next.diceTotal > 0 &&
          !_isAnimating &&
          !_showResult) {
        setState(() {
          _dice1 = next.dice1;
          _dice2 = next.dice2;
        });
        _startAnimation();
      }

      if (!next.isDiceRolled && _showResult) {
        _resetState();
      }
    });

    // Show dice result after roll
    if (state.isDiceRolled && state.diceTotal > 0) {
      return _buildDiceDisplay(state.diceTotal, tokens);
    }

    // Show roll button
    return _buildRollButton(state.phase, tokens);
  }

  void _startAnimation() {
    setState(() {
      _isAnimating = true;
      _showResult = false;
      _triggerShake = true;
      _triggerBounce = false;
    });

    // Play roll sound at the start
    SoundManager.instance.playDiceRoll();

    // Start haptic feedback during animation - random light taps
    _hapticTimer = Timer.periodic(MotionDurations.fast, (timer) {
      if (_isAnimating) {
        HapticFeedback.lightImpact();
      } else {
        timer.cancel();
      }
    });

    // Reset shake trigger after shake completes, then start Lottie
    Future.delayed(MotionDurations.medium.safe, () {
      if (mounted) {
        setState(() => _triggerShake = false);
        _lottieController.forward(from: 0);
      }
    });
  }

  void _resetState() {
    setState(() {
      _showResult = false;
      _isAnimating = false;
      _triggerShake = false;
      _triggerBounce = false;
      _showGlow = false;
    });
    _lottieController.reset();
  }

  /// Build TWO dice side by side with individual numbers below
  Widget _buildDiceDisplay(int total, ThemeTokens tokens) {
    // Apply shake animation when triggerShake is true
    // Apply bounce animation when triggerBounce is true
    return Animate(
      key: ValueKey('dice_container_$_triggerShake$_triggerBounce'),
      effects: _triggerShake
          ? [
              // Shake effect before roll - simulates dice shaking in hand
              ShakeEffect(
                duration: MotionDurations.medium.safe,
                hz: 8,
                curve: Curves.easeInOut,
              ),
            ]
          : _triggerBounce
          ? [
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
            ]
          : [],
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _showGlow
              ? [
                  // Colorful amber glow during landing
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
                ]
              : [
                  BoxShadow(
                    color: tokens.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                _buildSingleDie(_dice1, tokens),
                const SizedBox(width: 16),
                // DICE 2
                _buildSingleDie(_dice2, tokens),
              ],
            ),

            const SizedBox(height: 12),

            // TOTAL display below both dice - Modern flat style
            if (_showResult)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
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

  /// Build a single die with Lottie animation and number below - Modern flat style
  Widget _buildSingleDie(int value, ThemeTokens tokens) {
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

        // Individual die value BELOW - Modern flat style with bounce
        if (_showResult)
          Animate(
            effects: [
              ScaleEffect(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                duration: MotionDurations.medium.safe,
                curve: Curves.elasticOut,
              ),
              FadeEffect(
                begin: 0.0,
                end: 1.0,
                duration: MotionDurations.fast.safe,
              ),
            ],
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: tokens.border, width: 1.5),
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
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Fallback die display if Lottie fails - Modern flat style
  Widget _buildFallbackDie(int value) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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

  /// Build modern roll button - Flat design
  Widget _buildRollButton(GamePhase phase, ThemeTokens tokens) {
    // Determine button label based on phase
    final String buttonLabel = phase == GamePhase.rollingForOrder
        ? "SIRA İÇİN ZAR AT"
        : "ZAR AT";

    return ElevatedButton(
      onPressed: () {
        // Route based on phase - sound will play when animation starts
        // For turn order, just roll dice (the order is determined by dice values)
        ref.read(gameProvider.notifier).rollDice();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: tokens.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: tokens.primary.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    );
  }
}
