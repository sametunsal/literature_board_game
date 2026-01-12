import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../core/theme/game_theme.dart';
import '../providers/game_notifier.dart';
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

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
          _showResult = true;
        });
      }
    });
  }

  @override
  void dispose() {
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
      return _buildDiceDisplay(state.diceTotal);
    }

    // Show roll button
    return _buildRollButton();
  }

  void _startAnimation() {
    setState(() {
      _isAnimating = true;
      _showResult = false;
    });
    _lottieController.forward(from: 0);
  }

  void _resetState() {
    setState(() {
      _showResult = false;
      _isAnimating = false;
    });
    _lottieController.reset();
  }

  /// Build the TWO dice side by side with individual numbers below
  Widget _buildDiceDisplay(int total) {
    return Column(
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

        // TOTAL display below both dice
        if (_showResult)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: GameTheme.goldAccent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              "TOPLAM: $total",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: GameTheme.textDark,
              ),
            ),
          ),
      ],
    );
  }

  /// Build a single die with Lottie animation and number below
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

        // Individual die value BELOW (not overlapping)
        if (_showResult)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GameTheme.goldAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$value',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: GameTheme.textDark,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Fallback die display if Lottie fails
  Widget _buildFallbackDie(int value) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$value',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: GameTheme.textDark,
          ),
        ),
      ),
    );
  }

  /// Build the stylized roll button
  Widget _buildRollButton() {
    return ElevatedButton.icon(
      onPressed: () {
        SoundManager.instance.playDice();
        ref.read(gameProvider.notifier).rollDice();
      },
      icon: const Icon(Icons.casino, size: 24),
      label: Text(
        "ZAR AT",
        style: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: GameTheme.goldAccent,
        foregroundColor: GameTheme.textDark,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
    );
  }
}
