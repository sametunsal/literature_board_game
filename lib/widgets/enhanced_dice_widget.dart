import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player.dart';
// ignore: unused_import
import '../models/turn_phase.dart';
// ignore: unused_import
import '../models/turn_result.dart';
import '../providers/game_provider.dart';

/// Enhanced dice widget with rolling animation and active player highlight
/// Shows dice rolling before settling on result with visual effects
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

    // Start rolling animation
    await _rollController.forward();

    // Stop rolling and show result
    await _rollController.reverse();

    // Trigger playTurn() instead of rollDice() directly
    // This is the Phase 2 orchestration method
    ref.read(gameProvider.notifier).playTurn();

    setState(() {
      _isRolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final currentPlayer = gameState.players.isNotEmpty
        ? gameState.players[gameState.currentPlayerIndex]
        : null;
    final turnPhase = ref.watch(turnPhaseProvider);
    // ignore: unused_local_variable
    final lastTurnResult = ref.watch(lastTurnResultProvider);

    // Phase-aware logic: Dice is ONLY enabled during TurnPhase.start
    // In all other phases, dice is visually disabled (greyed out) and logically disabled (unclickable)
    final canRollDice = turnPhase == TurnPhase.start;

    // TODO: UI FEEDBACK - TurnPhase Reactions
    // - TurnPhase.start: Enable roll button, show "Your turn" indicator
    // - TurnPhase.diceRolled: Disable roll button, show rolling animation
    // - TurnPhase.moved: Keep dice result visible, disable roll button
    // - TurnPhase.tileResolved: Show tile effect feedback near dice
    // - TurnPhase.cardApplied: Show card effect icon overlay
    // - TurnPhase.questionResolved: Show question result feedback
    // - TurnPhase.taxResolved: Show tax payment feedback
    // - TurnPhase.turnEnded: Reset for next player

    // TODO: UI FEEDBACK - TurnResult Fields
    // - lastTurnResult.cardEffectType: Show card effect icon on dice area
    // - lastTurnResult.affectedPlayers: Highlight affected players in player list
    // - lastTurnResult.starDelta: Show star change summary (e.g., "+5 stars")
    // - lastTurnResult.skipNextTaxConsumed: Show tax skip badge
    // - lastTurnResult.easyQuestionNextConsumed: Show easy question badge
    // - lastTurnResult.taxSkippedMessage: Display tax skip message
    // - lastTurnResult.easyQuestionMessage: Display easy question message

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active player highlight
          if (currentPlayer != null)
            _ActivePlayerHighlight(player: currentPlayer),

          const SizedBox(height: 20),

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

          // Dice result indicator (static, no animation)
          if (turnPhase == TurnPhase.diceRolled &&
              gameState.lastDiceRoll != null) ...[
            const SizedBox(height: 12),
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

          const SizedBox(height: 20),

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: canRollDice ? 4 : 0,
              ),
              child: Text(
                _isRolling ? 'ZAR ATILIYOR...' : 'ZAR AT',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Active player highlight with pulsing animation
class _ActivePlayerHighlight extends StatefulWidget {
  final Player player;

  const _ActivePlayerHighlight({required this.player});

  @override
  State<_ActivePlayerHighlight> createState() => _ActivePlayerHighlightState();
}

class _ActivePlayerHighlightState extends State<_ActivePlayerHighlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(
                int.parse(widget.player.color.substring(1), radix: 16) +
                    0xFF000000,
              ).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Color(
                  int.parse(widget.player.color.substring(1), radix: 16) +
                      0xFF000000,
                ),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(
                    int.parse(widget.player.color.substring(1), radix: 16) +
                        0xFF000000,
                  ).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_arrow,
                  color: Color(
                    int.parse(widget.player.color.substring(1), radix: 16) +
                        0xFF000000,
                  ),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sıradaki: ${widget.player.name}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade900,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
      width: 80,
      height: 80,
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
