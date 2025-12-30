import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../models/turn_result.dart';
import '../models/player.dart';
import '../models/player_type.dart';
import '../models/turn_phase.dart'; // Import Phase enum
import '../utils/turn_summary_generator.dart';

class TurnSummaryOverlay extends ConsumerStatefulWidget {
  const TurnSummaryOverlay({super.key});

  @override
  ConsumerState<TurnSummaryOverlay> createState() => _TurnSummaryOverlayState();
}

class _TurnSummaryOverlayState extends ConsumerState<TurnSummaryOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleContinue() {
    // 1. Close animation explicitly
    _controller.reverse().then((_) {
      // 2. Advance game state ONLY after animation starts closing
      ref.read(gameProvider.notifier).startNextTurn();
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- CRITICAL LOGIC FIX ---
    // 1. Listen to the Phase
    final turnPhase = ref.watch(turnPhaseProvider);
    final turnResult = ref.watch(lastTurnResultProvider);
    final gameState = ref.watch(gameProvider);

    // 2. The Gatekeeper: Show ONLY if phase is turnEnded
    if (turnPhase != TurnPhase.turnEnded) {
      // Reset animation if we are hidden
      if (_controller.value > 0) _controller.reset();
      return const SizedBox.shrink();
    }

    // 3. Play animation if appearing
    if (_controller.value == 0) {
      _controller.forward();

      // Auto-advance for Bots
      final currentPlayer = ref.read(
        currentPlayerProvider,
      ); // Check current, or last turn player
      // Ideally check based on turnResult player index
      if (turnResult.playerIndex >= 0 &&
          turnResult.playerIndex < gameState.players.length) {
        final player = gameState.players[turnResult.playerIndex];
        if (player.type == PlayerType.bot) {
          Future.delayed(const Duration(milliseconds: 2500), () {
            if (mounted && ref.read(turnPhaseProvider) == TurnPhase.turnEnded) {
              _handleContinue();
            }
          });
        }
      }
    }

    // 4. Data Safety Checks
    if (turnResult.playerIndex < 0 ||
        turnResult.playerIndex >= gameState.players.length) {
      return const SizedBox.shrink();
    }

    final player = gameState.players[turnResult.playerIndex];

    // 5. Generate Summary
    final summaryText = TurnSummaryGenerator.generateTurnSummary(
      turnResult,
      playerName: player.name,
    );

    return Stack(
      children: [
        // Backdrop
        Positioned.fill(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(color: Colors.black54),
          ),
        ),

        // Card
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(
                      int.parse(player.color.replaceFirst('#', '0xFF')),
                    ),
                    child: Text(
                      player.name[0].toUpperCase(),
                      style: GoogleFonts.titanOne(
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "TUR TAMAMLANDI",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    player.name,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const Divider(height: 32),

                  Text(
                    summaryText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "DEVAM ET",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
