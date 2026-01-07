import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/turn_phase.dart';
import '../providers/game_provider.dart';

/// Pure dice widget with rolling animation
/// Responsibility: ONLY render the Dice Animation and "Roll" button
/// No player info or turn management logic - that belongs in the parent
class EnhancedDiceWidget extends ConsumerStatefulWidget {
  const EnhancedDiceWidget({super.key});

  @override
  ConsumerState<EnhancedDiceWidget> createState() => _EnhancedDiceWidgetState();
}

class _EnhancedDiceWidgetState extends ConsumerState<EnhancedDiceWidget>
    with TickerProviderStateMixin {
  late AnimationController _rollController;
  late Animation<double> _rollAnimation;
  late Animation<double> _scaleAnimation;

  bool _isRolling = false;

  @override
  void initState() {
    super.initState();

    _rollController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rollAnimation = Tween<double>(
      begin: 0,
      end: 4 * math.pi,
    ).animate(CurvedAnimation(parent: _rollController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _rollController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _rollController.dispose();
    super.dispose();
  }

  Future<void> _rollDice() async {
    if (_isRolling) return;

    setState(() => _isRolling = true);

    // Trigger rollDice() which will:
    // 1. Set phase to diceRolled
    // 2. Set isDiceAnimationComplete to false
    // 3. Generate and record the dice roll
    ref.read(gameProvider.notifier).playTurn();

    // Start rolling animation
    await _rollController.forward();

    // Stop rolling and show result
    await _rollController.reverse();

    setState(() {
      _isRolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final turnPhase = ref.watch(turnPhaseProvider);
    final currentCard = ref.watch(currentCardProvider);

    // Phase-aware logic: Dice is ONLY enabled during TurnPhase.start AND when no card dialog is open
    // In all other phases, dice is visually disabled (greyed out) and logically disabled (unclickable)
    final canRollDice = turnPhase == TurnPhase.start && currentCard == null;

    // No top-level Container with fixed dimensions - let parent determine constraints
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated dice
        AnimatedBuilder(
          animation: _rollAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rollAnimation.value,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _DiceFace(
                  value: _isRolling
                      ? (math.Random().nextInt(6) + 1)
                      : (gameState.lastDiceRoll?.total ?? 1),
                  isRolling: _isRolling,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Dice result indicator (static, no animation)
        if (turnPhase == TurnPhase.diceRolled &&
            gameState.lastDiceRoll != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.shade300, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎲', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '${gameState.lastDiceRoll?.total}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade900,
                  ),
                ),
                if (gameState.lastDiceRoll?.isDouble == true) ...[
                  const SizedBox(width: 6),
                  const Text('✨', style: TextStyle(fontSize: 14)),
                ],
              ],
            ),
          ),
        ],

        const SizedBox(height: 8),

        // Roll button - Phase-aware: ONLY enabled during TurnPhase.start
        // Visually and logically disabled in all other phases
        Opacity(
          opacity: canRollDice ? 1.0 : 0.5,
          child: ElevatedButton(
            onPressed: (_isRolling || !canRollDice) ? null : _rollDice,
            style: ElevatedButton.styleFrom(
              backgroundColor: canRollDice
                  ? Colors.brown.shade700
                  : Colors.grey.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: canRollDice ? 4 : 0,
            ),
            child: Text(
              _isRolling ? 'ZAR ATILIYOR...' : 'ZAR AT',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated dice face with dots
class _DiceFace extends StatelessWidget {
  final int value;
  final bool isRolling;

  const _DiceFace({required this.value, this.isRolling = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isRolling ? Colors.orange.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRolling ? Colors.orange.shade600 : Colors.brown.shade700,
          width: 3,
        ),
        boxShadow: isRolling
            ? [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(child: _buildDiceDots(value)),
    );
  }

  Widget _buildDiceDots(int value) {
    final dotSize = 12.0;
    final dotColor = Colors.brown.shade800;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        final center = size / 2;
        final quarter = size / 4;
        final threeQuarter = size * 0.75;

        return Stack(
          children: [
            if (value % 2 == 1) // Center dot (1, 3, 5)
              Positioned(
                left: center - dotSize / 2,
                top: center - dotSize / 2,
                child: _Dot(size: dotSize, color: dotColor),
              ),
            if (value > 1) // Top-left and bottom-right (2, 3, 4, 5, 6)
            ...[
              Positioned(
                left: quarter - dotSize / 2,
                top: quarter - dotSize / 2,
                child: _Dot(size: dotSize, color: dotColor),
              ),
              Positioned(
                left: threeQuarter - dotSize / 2,
                top: threeQuarter - dotSize / 2,
                child: _Dot(size: dotSize, color: dotColor),
              ),
            ],
            if (value > 3) // Top-right and bottom-left (4, 5, 6)
            ...[
              Positioned(
                left: threeQuarter - dotSize / 2,
                top: quarter - dotSize / 2,
                child: _Dot(size: dotSize, color: dotColor),
              ),
              Positioned(
                left: quarter - dotSize / 2,
                top: threeQuarter - dotSize / 2,
                child: _Dot(size: dotSize, color: dotColor),
              ),
            ],
            if (value == 6) // Middle-left and middle-right (6)
            ...[
              Positioned(
                left: quarter - dotSize / 2,
                top: center - dotSize / 2,
                child: _Dot(size: dotSize, color: dotColor),
              ),
              Positioned(
                left: threeQuarter - dotSize / 2,
                top: center - dotSize / 2,
                child: _Dot(size: dotSize, color: dotColor),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Single dot on dice face
class _Dot extends StatelessWidget {
  final double size;
  final Color color;

  const _Dot({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
