import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/game_theme.dart';
import '../providers/game_notifier.dart';

class DiceRoller extends ConsumerStatefulWidget {
  const DiceRoller({super.key});

  @override
  ConsumerState<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends ConsumerState<DiceRoller> {
  bool _isAnimating = false;
  int _previousDiceValue = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);

    // Trigger animation when dice value changes
    if (state.isDiceRolled &&
        state.diceTotal > 0 &&
        state.diceTotal != _previousDiceValue) {
      _previousDiceValue = state.diceTotal;
      _isAnimating = true;
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (mounted) setState(() => _isAnimating = false);
      });
    }

    // Show dice result after roll
    if (state.isDiceRolled && state.diceTotal > 0) {
      return _buildDiceResult(state.diceTotal);
    }

    // Show roll button
    return _buildRollButton();
  }

  /// Build the 3D dice result display with animation
  Widget _buildDiceResult(int value) {
    return Container(
      key: ValueKey('dice_$value'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 3D DICE FACE
          _DiceFace(value: value)
              .animate(target: _isAnimating ? 1 : 0)
              .shake(duration: 600.ms, hz: 4)
              .then()
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.2, 1.2),
                duration: 300.ms,
                curve: Curves.easeOut,
              )
              .then()
              .scale(
                begin: const Offset(1.2, 1.2),
                end: const Offset(1.0, 1.0),
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: 8),

          // Result text label
          Text(
            "SONUÇ: $value",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the stylized roll button
  Widget _buildRollButton() {
    return ElevatedButton.icon(
          onPressed: () {
            setState(() => _isAnimating = true);
            ref.read(gameProvider.notifier).rollDice();
          },
          icon: const Icon(Icons.casino, size: 22),
          label: Text(
            "ZAR AT",
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: GameTheme.goldAccent,
            foregroundColor: GameTheme.textDark,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          delay: 2000.ms,
          duration: 1200.ms,
          color: Colors.white.withValues(alpha: 0.4),
        );
  }
}

/// 3D Dice Face Widget with pips
class _DiceFace extends StatelessWidget {
  final int value;

  const _DiceFace({required this.value});

  @override
  Widget build(BuildContext context) {
    const double size = 70;
    const double pipSize = 12;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // 3D gradient for plastic/glass look
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF), // White
            Color(0xFFF5F5F5), // Light grey
            Color(0xFFE0E0E0), // Grey (bottom-right shadow)
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(12),
        // Deep shadows for physical weight
        boxShadow: [
          // Main drop shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(4, 6),
          ),
          // Ambient shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: -2,
          ),
          // Inner highlight (top-left)
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: _buildPips(value, pipSize),
    );
  }

  /// Build pip layout based on dice value (1-6)
  Widget _buildPips(int value, double pipSize) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: switch (value) {
        1 => _CenterPip(pipSize: pipSize),
        2 => _TwoPips(pipSize: pipSize),
        3 => _ThreePips(pipSize: pipSize),
        4 => _FourPips(pipSize: pipSize),
        5 => _FivePips(pipSize: pipSize),
        6 => _SixPips(pipSize: pipSize),
        _ => _buildMultiDice(value, pipSize),
      },
    );
  }

  /// For values > 6 (two dice combined), show the number
  Widget _buildMultiDice(int value, double pipSize) {
    return Center(
      child: Text(
        '$value',
        style: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: GameTheme.textDark,
        ),
      ),
    );
  }
}

/// Single pip widget (the dot)
class _Pip extends StatelessWidget {
  final double size;

  const _Pip({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A1A1A), // Near black
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PIP LAYOUTS FOR EACH DICE VALUE
// ════════════════════════════════════════════════════════════════════════════

class _CenterPip extends StatelessWidget {
  final double pipSize;
  const _CenterPip({required this.pipSize});

  @override
  Widget build(BuildContext context) {
    return Center(child: _Pip(size: pipSize));
  }
}

class _TwoPips extends StatelessWidget {
  final double pipSize;
  const _TwoPips({required this.pipSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: _Pip(size: pipSize),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: _Pip(size: pipSize),
        ),
      ],
    );
  }
}

class _ThreePips extends StatelessWidget {
  final double pipSize;
  const _ThreePips({required this.pipSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: _Pip(size: pipSize),
        ),
        Align(
          alignment: Alignment.center,
          child: _Pip(size: pipSize),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: _Pip(size: pipSize),
        ),
      ],
    );
  }
}

class _FourPips extends StatelessWidget {
  final double pipSize;
  const _FourPips({required this.pipSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Pip(size: pipSize),
            _Pip(size: pipSize),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Pip(size: pipSize),
            _Pip(size: pipSize),
          ],
        ),
      ],
    );
  }
}

class _FivePips extends StatelessWidget {
  final double pipSize;
  const _FivePips({required this.pipSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Pip(size: pipSize),
                _Pip(size: pipSize),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Pip(size: pipSize),
                _Pip(size: pipSize),
              ],
            ),
          ],
        ),
        Center(child: _Pip(size: pipSize)),
      ],
    );
  }
}

class _SixPips extends StatelessWidget {
  final double pipSize;
  const _SixPips({required this.pipSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Pip(size: pipSize),
            _Pip(size: pipSize),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Pip(size: pipSize),
            _Pip(size: pipSize),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Pip(size: pipSize),
            _Pip(size: pipSize),
          ],
        ),
      ],
    );
  }
}
