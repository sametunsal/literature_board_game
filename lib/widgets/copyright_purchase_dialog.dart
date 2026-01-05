import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tile.dart';
import '../models/player_type.dart';
import '../providers/game_provider.dart';

/// Copyright Purchase Dialog - Phase 4 Feature
///
/// Allows players to purchase copyrights on book/publisher tiles
/// after answering a question correctly.
///
/// Features:
/// - Display tile information (name, type, price)
/// - Show player's current stars
/// - Validate if player can afford purchase
/// - "Purchase" and "Skip" buttons
/// - Integration with game_provider.purchaseCopyright()
/// - Bot players auto-decline (dialog not rendered)
///
/// Flow:
/// 1. Dialog shown after correct answer on book/publisher tile
/// 2. User chooses "Purchase" or "Skip"
/// 3. If "Purchase" clicked, calls game_provider.purchaseCopyright()
/// 4. If "Skip" clicked, calls playTurn() to advance to next phase
/// 5. Turn continues normally after dialog closes
class CopyrightPurchaseDialog extends ConsumerStatefulWidget {
  final Tile tile;

  const CopyrightPurchaseDialog({super.key, required this.tile});

  @override
  ConsumerState<CopyrightPurchaseDialog> createState() =>
      _CopyrightPurchaseDialogState();
}

class _CopyrightPurchaseDialogState
    extends ConsumerState<CopyrightPurchaseDialog> {
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final currentPlayer = gameState.currentPlayer;

    if (currentPlayer == null) {
      return const SizedBox.shrink();
    }

    // Phase 4: Bot auto-decline - Dialog not rendered for bots
    // Bots always decline copyright purchase (dummy logic)
    if (currentPlayer.type == PlayerType.bot) {
      // Bot auto-declines with delay
      Future.delayed(const Duration(milliseconds: 500), () {
        // Guard: Check if widget is still mounted before using ref
        if (!mounted) return;
        // Call playTurn to advance to next phase (endTurn)
        ref.read(gameProvider.notifier).playTurn();
      });
      return const SizedBox.shrink();
    }

    final canAfford = currentPlayer.stars >= (widget.tile.purchasePrice ?? 0);
    final price = widget.tile.purchasePrice ?? 0;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.copyright, color: Colors.deepPurple.shade600, size: 28),
          const SizedBox(width: 12),
          Text(
            'Telif Satın Al',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tile information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tile name
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: Colors.deepPurple.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.tile.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Tile type
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        color: Colors.deepPurple.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getTileTypeName(widget.tile.type),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.deepPurple.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Divider
                  Divider(color: Colors.deepPurple.shade200),
                  const SizedBox(height: 12),

                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fiyat',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.deepPurple.shade800,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$price',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Player information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentPlayer.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${currentPlayer.stars} yıldız',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Validation message
            if (!canAfford)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Yetersiz bakiye! Bu telifi satın almak için yeterli yıldıza sahip değilsiniz.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        // Skip button
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            // Call playTurn to advance to next phase (endTurn)
            Future.delayed(const Duration(milliseconds: 100), () {
              if (!mounted) return;
              ref.read(gameProvider.notifier).playTurn();
            });
          },
          icon: const Icon(Icons.close),
          label: Text(
            'Atla',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
        ),

        const SizedBox(width: 8),

        // Purchase button
        ElevatedButton.icon(
          onPressed: canAfford
              ? () {
                  ref.read(gameProvider.notifier).purchaseCopyright();
                  Navigator.of(context).pop();
                  // Call playTurn to advance to next phase (endTurn)
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (!mounted) return;
                    ref.read(gameProvider.notifier).playTurn();
                  });
                }
              : null,
          icon: const Icon(Icons.shopping_cart),
          label: Text(
            'Satın Al',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: canAfford
                ? Colors.deepPurple.shade600
                : Colors.grey.shade400,
            foregroundColor: Colors.white,
            elevation: canAfford ? 2 : 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  // Get tile type name for display
  String _getTileTypeName(TileType type) {
    switch (type) {
      case TileType.book:
        return 'Kitap Kutucuğu';
      case TileType.publisher:
        return 'Yayınevi Kutucuğu';
      default:
        return 'Bilinmeyen Tip';
    }
  }
}
