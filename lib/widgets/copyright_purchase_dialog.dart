import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tile.dart';
import '../models/turn_phase.dart';
import '../providers/game_provider.dart';

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
  void initState() {
    super.initState();
    // Listen for phase changes to auto-close dialog
    ref.listen<TurnPhase>(turnPhaseProvider, (previous, next) {
      // Close dialog when phase changes away from copyrightPurchased
      if (previous == TurnPhase.copyrightPurchased &&
          next != TurnPhase.copyrightPurchased) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final currentPlayer = gameState.currentPlayer;

    if (currentPlayer == null) {
      return const SizedBox.shrink();
    }

    final canAfford = currentPlayer.stars >= (widget.tile.purchasePrice ?? 0);
    final price = widget.tile.purchasePrice ?? 0;

    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title bar
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.copyright,
                      color: Colors.deepPurple.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Telif Satın Al',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              // Content area - scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tile information
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(10),
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
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.tile.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Tile type
                            Row(
                              children: [
                                Icon(
                                  Icons.category,
                                  color: Colors.deepPurple.shade700,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getTileTypeName(widget.tile.type),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.deepPurple.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Divider(color: Colors.deepPurple.shade200),
                            const SizedBox(height: 10),

                            // Price
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Fiyat',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.deepPurple.shade800,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber.shade600,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '$price',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
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
                      const SizedBox(height: 12),

                      // Player information
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.blue.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentPlayer.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber.shade600,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${currentPlayer.stars} yıldız',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
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
                      const SizedBox(height: 12),

                      // Validation message
                      if (!canAfford)
                        Container(
                          padding: const EdgeInsets.all(10),
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
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Yetersiz bakiye!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
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
              ),

              // Actions area
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Skip button
                    TextButton.icon(
                      onPressed: () {
                        final gameNotifier = ref.read(gameProvider.notifier);
                        gameNotifier.declineCopyrightPurchase();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          gameNotifier.playTurn();
                        });
                      },
                      icon: const Icon(Icons.close),
                      label: Text(
                        'Atla',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Purchase button
                    ElevatedButton.icon(
                      onPressed: canAfford
                          ? () {
                              final gameNotifier = ref.read(
                                gameProvider.notifier,
                              );
                              gameNotifier.completeCopyrightPurchase();
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                gameNotifier.playTurn();
                              });
                            }
                          : null,
                      icon: const Icon(Icons.shopping_cart),
                      label: Text(
                        'Satın Al',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
