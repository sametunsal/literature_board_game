import 'dart:async';
import 'package:flutter/material.dart' hide Card;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card.dart' as game_model;
import '../models/turn_phase.dart';
import '../models/player_type.dart';
// ignore: unused_import
import '../models/turn_result.dart';
import '../providers/game_provider.dart';

/// Card dialog - Phase 3 adaptation
///
/// Phase 3 Orchestration:
/// - UI is PASSIVE observer (watches turnPhase, cardState)
/// - UI calls ONLY playTurn() via _handleDismiss()
/// - Buttons are GATED by TurnPhase.cardApplied
/// - No direct game logic method calls
///
/// Flow:
/// 1. User views card effect
/// 2. User dismisses dialog (Tamam button)
/// 3. _handleDismiss() calls playTurn()
/// 4. playTurn() advances to next phase (turnEnded)
class CardDialog extends ConsumerWidget {
  final game_model.Card card;

  const CardDialog({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final turnPhase = ref.watch(turnPhaseProvider);
    // ignore: unused_local_variable
    final lastTurnResult = ref.watch(lastTurnResultProvider);

    final currentPlayer = gameState.currentPlayer;

    // Phase 5.1: Bot auto-resolve - Dialog not rendered for bots
    // Bot dismisses immediately (dummy logic)
    if (currentPlayer?.type == PlayerType.bot) {
      // Bot auto-resolves with delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleDismiss(ref);
      });
      return const SizedBox.shrink();
    }

    // Card dialog buttons are only enabled during TurnPhase.cardApplied
    final canDismiss = turnPhase == TurnPhase.cardApplied;

    // TODO: UI FEEDBACK - TurnPhase Reactions
    // - TurnPhase.cardApplied: Show card dialog with animation, enable dismiss button
    // - Other phases: Card dialog should not be visible

    // TODO: UI FEEDBACK - TurnResult Fields
    // - lastTurnResult.cardEffectType: Display effect type icon and description
    // - lastTurnResult.affectedPlayers: List affected players in dialog
    // - lastTurnResult.starDelta: Show star changes for each affected player
    // - lastTurnResult.skipNextTaxConsumed: Show tax skip notification
    // - lastTurnResult.easyQuestionNextConsumed: Show easy question notification

    Color backgroundColor;
    IconData icon;
    String title;

    switch (card.type) {
      case game_model.CardType.sans:
        backgroundColor = Colors.amber.shade100;
        icon = Icons.star;
        title = 'ŞANS Kartı';
        break;
      case game_model.CardType.kader:
        backgroundColor = Colors.red.shade100;
        icon = Icons.auto_awesome;
        title = 'KADER Kartı';
        break;
    }

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Row(
        children: [
          Icon(icon, color: Colors.brown.shade900),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade900,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.brown.shade300),
              ),
              child: Text(
                card.description,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.brown.shade900,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Effect description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.brown.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getEffectDescription(card.effect),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.brown.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Star amount if applicable
            if (card.starAmount != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${card.starAmount!} yıldız',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        Opacity(
          opacity: canDismiss ? 1.0 : 0.5,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canDismiss ? () => _handleDismiss(ref) : null,
              icon: const Icon(Icons.check),
              label: Text(
                'Tamam',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: canDismiss
                    ? Colors.brown.shade800
                    : Colors.grey.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: canDismiss ? 2 : 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Handles card dismissal and triggers Phase 2 orchestration
  // Phase 2: UI only calls playTurn(), no direct game logic
  static void _handleDismiss(WidgetRef ref) {
    // Trigger Phase 2 orchestration
    // playTurn() will handle next phase progression
    ref.read(gameProvider.notifier).playTurn();
  }

  String _getEffectDescription(game_model.CardEffect effect) {
    switch (effect) {
      case game_model.CardEffect.gainStars:
        return 'Yıldız kazan';
      case game_model.CardEffect.loseStars:
        return 'Yıldız kaybet';
      case game_model.CardEffect.skipNextTax:
        return 'Sonraki vergiyi atla';
      case game_model.CardEffect.freeTurn:
        return 'Ücretsiz tur';
      case game_model.CardEffect.easyQuestionNext:
        return 'Sonraki soru kolay';
      case game_model.CardEffect.allPlayersGainStars:
        return 'Tüm oyuncular yıldız kazanır';
      case game_model.CardEffect.allPlayersLoseStars:
        return 'Tüm oyuncular yıldız kaybeder';
      case game_model.CardEffect.publisherOwnersLose:
        return 'Yayınevi sahipleri yıldız kaybeder';
      case game_model.CardEffect.taxWaiver:
        return 'Tüm oyuncular vergi ödemez';
      case game_model.CardEffect.richPlayerPays:
        return 'En zengin oyuncu öder';
      case game_model.CardEffect.allPlayersEasyQuestion:
        return 'Tüm oyuncular kolay soru alır';
    }
  }
}
