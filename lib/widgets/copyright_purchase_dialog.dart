import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/turn_phase.dart';
import '../models/player_type.dart';
import '../providers/game_provider.dart';

/// Copyright purchase dialog - Phase 3 adaptation
///
/// Phase 3 Orchestration:
/// - UI is PASSIVE observer (watches turnPhase)
/// - UI calls ONLY playTurn() via _handleDecision()
/// - Buttons are GATED by TurnPhase.tileResolved
/// - No direct game logic method calls
///
/// Flow:
/// 1. User decides to buy or decline
/// 2. _handleDecision() processes decision (calls buy/decline methods)
/// 3. _handleDecision() calls playTurn()
/// 4. playTurn() advances to next phase (turnEnded)
class CopyrightPurchaseDialog extends ConsumerWidget {
  final String tileName;
  final int price;
  final int playerStars;

  const CopyrightPurchaseDialog({
    super.key,
    required this.tileName,
    required this.price,
    required this.playerStars,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final turnPhase = ref.watch(turnPhaseProvider);

    final currentPlayer = gameState.currentPlayer;

    // Phase 5.1: Bot auto-resolve - Dialog not rendered for bots
    // Bot always declines purchases (dummy logic)
    if (currentPlayer?.type == PlayerType.bot) {
      // Bot auto-resolves with delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleDecision(ref, false); // Always decline
      });
      return const SizedBox.shrink();
    }

    // Purchase dialog buttons are only enabled during TurnPhase.tileResolved
    final canPurchase = turnPhase == TurnPhase.tileResolved;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.bookmark_add, color: Colors.brown.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Telif Satın Al',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade900,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tile info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.brown.shade200, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eser Adı:',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.brown.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tileName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Price info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Fiyat:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.brown.shade700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$price',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Player balance
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.green,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bakiye:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.brown.shade700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$playerStars',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Remaining balance after purchase
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kalan Bakiye: ${playerStars - price}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Decline button
        Expanded(
          child: Opacity(
            opacity: canPurchase ? 1.0 : 0.5,
            child: OutlinedButton.icon(
              onPressed: canPurchase
                  ? () {
                      Navigator.of(context).pop();
                      _handleDecision(ref, false);
                    }
                  : null,
              icon: const Icon(Icons.close, size: 20),
              label: Text(
                'İptal',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: canPurchase
                    ? Colors.red.shade700
                    : Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(
                  color: canPurchase
                      ? Colors.red.shade300
                      : Colors.grey.shade300,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Accept button
        Expanded(
          child: Opacity(
            opacity: canPurchase ? 1.0 : 0.5,
            child: ElevatedButton.icon(
              onPressed: canPurchase
                  ? () {
                      Navigator.of(context).pop();
                      _handleDecision(ref, true);
                    }
                  : null,
              icon: const Icon(Icons.check, size: 20),
              label: Text(
                'Satın Al',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: canPurchase
                    ? Colors.green.shade600
                    : Colors.grey.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: canPurchase ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Handles purchase decision and triggers Phase 2 orchestration
  // Phase 2: UI only calls playTurn(), no direct game logic
  // Note: Copyright purchase game logic not yet implemented
  static void _handleDecision(WidgetRef ref, bool wantsToBuy) {
    // TODO: Add copyright purchase game logic when implemented
    // For now, just trigger Phase 2 orchestration
    // playTurn() will handle next phase progression
    ref.read(gameProvider.notifier).playTurn();
  }
}
