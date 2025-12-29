import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tile.dart';
import '../models/turn_phase.dart';
import '../providers/game_provider.dart';

// Reusable info panel widget to display current game state
class GameInfoPanel extends ConsumerWidget {
  const GameInfoPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final currentPlayer = ref.watch(currentPlayerProvider);
    final lastDiceRoll = ref.watch(lastDiceRollProvider);
    final turnPhase = ref.watch(turnPhaseProvider);

    // Get current tile name from position (1-40)
    Tile? currentTile;
    if (currentPlayer != null &&
        currentPlayer.position >= 1 &&
        currentPlayer.position <= gameState.tiles.length) {
      currentTile = gameState.tiles.firstWhere(
        (t) => t.id == currentPlayer.position,
        orElse: () => Tile(
          id: currentPlayer.position,
          name: 'Kutucuk ${currentPlayer.position}',
          type: TileType.book,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.brown.shade800, size: 24),
              const SizedBox(width: 8),
              Text(
                'Oyun Durumu',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Active player name
          _buildInfoRow(
            icon: Icons.person,
            label: 'Aktif Oyuncu:',
            value: currentPlayer?.name ?? 'Yok',
            valueStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade900,
            ),
          ),
          const SizedBox(height: 8),

          // Stars
          _buildInfoRow(
            icon: Icons.star,
            label: 'Yıldız:',
            value: '${currentPlayer?.stars ?? 0}',
            valueStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade700,
            ),
          ),
          const SizedBox(height: 8),

          // Current position
          _buildInfoRow(
            icon: Icons.location_on,
            label: 'Konum:',
            value: '${currentPlayer?.position ?? 0}',
            valueStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),

          // Current tile name
          _buildInfoRow(
            icon: Icons.place,
            label: 'Kutucuk:',
            value: currentTile?.name ?? 'Bilinmiyor',
            valueStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.brown.shade800,
            ),
          ),
          const SizedBox(height: 8),

          // Last dice roll
          if (lastDiceRoll != null) ...[
            _buildInfoRow(
              icon: Icons.casino,
              label: 'Son Zar:',
              value:
                  '${lastDiceRoll.die1} + ${lastDiceRoll.die2} = ${lastDiceRoll.total}',
              valueStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade700,
              ),
            ),
            if (lastDiceRoll.isDouble)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.purple, width: 1),
                  ),
                  child: Text(
                    'ÇİFT ZAR!',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade900,
                    ),
                  ),
                ),
              ),
          ],

          // Turn Feedback Section
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Tur Bilgisi',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade900,
            ),
          ),
          const SizedBox(height: 8),

          // Turn Phase Feedback
          _buildTurnFeedback(turnPhase, gameState),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required TextStyle valueStyle,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.brown.shade700, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: valueStyle,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTurnFeedback(TurnPhase turnPhase, GameState gameState) {
    final currentPlayer = gameState.currentPlayer;

    switch (turnPhase) {
      case TurnPhase.start:
        return _buildFeedbackSection(
          icon: '🎯',
          title: 'Tur Başlangıcı',
          color: Colors.grey.shade700,
          children: [
            Text(
              'Zar atmaya hazır',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        );

      case TurnPhase.diceRolled:
        final diceRoll = gameState.lastDiceRoll;
        if (diceRoll != null) {
          return _buildFeedbackSection(
            icon: '🎲',
            title: 'Zar Atıldı',
            color: Colors.purple.shade700,
            children: [
              Text(
                'Zar: ${diceRoll.die1} + ${diceRoll.die2} = ${diceRoll.total}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.purple.shade700,
                ),
              ),
              if (diceRoll.isDouble)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '✨ Çift zar attı!',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.purple.shade900,
                    ),
                  ),
                ),
            ],
          );
        }
        return const SizedBox.shrink();

      case TurnPhase.moved:
        final oldPos = gameState.oldPosition;
        final newPos = gameState.newPosition;
        if (oldPos != null && newPos != null) {
          return _buildFeedbackSection(
            icon: '🚀',
            title: 'Hareket',
            color: Colors.blue.shade700,
            children: [
              Text(
                'Konum: $oldPos → $newPos',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.blue.shade700,
                ),
              ),
              if (gameState.passedStart)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '⭐ Başlangıçtan geçti! +10 yıldız',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ),
            ],
          );
        }
        return const SizedBox.shrink();

      case TurnPhase.tileResolved:
        final tile = gameState.tiles.firstWhere(
          (t) => t.id == (gameState.newPosition ?? currentPlayer?.position),
          orElse: () => Tile(
            id: gameState.newPosition ?? currentPlayer?.position ?? 0,
            name: 'Bilinmiyor',
            type: TileType.book,
          ),
        );
        return _buildFeedbackSection(
          icon: '📍',
          title: 'Kutucuk',
          color: Colors.brown.shade800,
          children: [
            Text(
              tile.name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.brown.shade800,
              ),
            ),
            Text(
              'Tür: ${tile.type.toString().split('.').last}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );

      case TurnPhase.cardApplied:
        return _buildFeedbackSection(
          icon: '🃏',
          title: 'Kart Etkisi',
          color: Colors.orange.shade700,
          children: [
            Text(
              'Kart etkisi uygulandı',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.orange.shade700,
              ),
            ),
            // Card effect details are logged in game log
            Text(
              'Detaylar için oyun günlüğüne bakın',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );

      case TurnPhase.questionWaiting:
        return _buildFeedbackSection(
          icon: '❓',
          title: 'Soru Bekleniyor',
          color: Colors.blue.shade700,
          children: [
            Text(
              'Cevap bekleniyor...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        );

      case TurnPhase.questionResolved:
        return _buildFeedbackSection(
          icon: '❓',
          title: 'Soru',
          color: Colors.blue.shade700,
          children: [
            if (gameState.questionState == QuestionState.correct)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '✅ Doğru cevap! +${gameState.currentQuestion?.starReward ?? 0} yıldız',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            if (gameState.questionState == QuestionState.wrong)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '❌ Yanlış cevap! -${gameState.wrongAnswers > 0 ? '5' : '0'} yıldız',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            if (gameState.questionState == QuestionState.skipped)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '⏭️ Soru atlandı',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
          ],
        );

      case TurnPhase.copyrightPurchased:
        return _buildFeedbackSection(
          icon: '📜',
          title: 'Telif Satın Alma',
          color: Colors.orange.shade700,
          children: [
            Text(
              'Telif satın alma aşaması',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.orange.shade700,
              ),
            ),
            Text(
              'Detaylar için oyun günlüğüne bakın',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );

      case TurnPhase.taxResolved:
        // Check if tax was skipped by looking at the last log message
        final taxSkipped =
            gameState.logMessages.isNotEmpty &&
            gameState.logMessages.last.contains('atlandı');

        return _buildFeedbackSection(
          icon: '💰',
          title: 'Vergi',
          color: Colors.red.shade700,
          children: [
            if (taxSkipped)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '✅ Vergi atlandı (kart kullanıldı)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            if (!taxSkipped)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '💸 Vergi ödendi',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
          ],
        );

      case TurnPhase.turnEnded:
        return _buildFeedbackSection(
          icon: '🏁',
          title: 'Tur Sonu',
          color: Colors.brown.shade800,
          children: [
            Text(
              'Tur tamamlandı',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.brown.shade800,
              ),
            ),
            // Star changes are logged in game log
            Text(
              'Yıldız değişiklikleri için oyun günlüğüne bakın',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildFeedbackSection({
    required String icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with icon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Content
        ...children,
      ],
    );
  }
}
