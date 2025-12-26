import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tile.dart';
import '../providers/game_provider.dart';

// Reusable info panel widget to display current game state
class GameInfoPanel extends ConsumerWidget {
  const GameInfoPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final currentPlayer = ref.watch(currentPlayerProvider);
    final lastDiceRoll = ref.watch(lastDiceRollProvider);

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
}
