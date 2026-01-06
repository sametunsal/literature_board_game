import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/card.dart' as game_models;
import '../models/player_type.dart';
import '../providers/game_provider.dart';

/// Dialog for displaying Chance (Sans) and Fate (Kader) cards
class CardDialog extends ConsumerStatefulWidget {
  final game_models.Card card;

  const CardDialog({super.key, required this.card});

  @override
  ConsumerState<CardDialog> createState() => _CardDialogState();
}

class _CardDialogState extends ConsumerState<CardDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyCard() {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final gameNotifier = ref.read(gameProvider.notifier);
    gameNotifier.applyCardEffect(widget.card);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final currentPlayer = gameState.currentPlayer;

    // Bot auto-apply - Dialog not rendered for bots
    // Bots always auto-apply card effect without showing dialog
    if (currentPlayer?.type == PlayerType.bot) {
      // Bot auto-applies with delay
      Future.delayed(const Duration(milliseconds: 500), () {
        // Guard: Check if widget is still mounted before using ref
        if (!mounted) return;

        // Trigger playTurn which will apply card effect via bot logic
        ref.read(gameProvider.notifier).playTurn();
      });
      return const SizedBox.shrink();
    }

    final isSans = widget.card.type == game_models.CardType.sans;
    final isPositive = widget.card.isPositiveForPlayer;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSans
                    ? [Colors.amber.shade100, Colors.amber.shade200]
                    : [Colors.purple.shade100, Colors.purple.shade200],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: isSans
                        ? Colors.amber.shade700
                        : Colors.purple.shade700,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isSans ? Icons.casino : Icons.auto_fix_high,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isSans ? 'ŞANS KARTI' : 'KADER KARTI',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Card description
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          widget.card.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Effect indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isPositive
                                ? Colors.green.shade400
                                : Colors.red.shade400,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: isPositive
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isPositive ? 'OLUMLU ETKİ' : 'OLUMSUZ ETKİ',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isPositive
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Apply button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _applyCard,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSans
                                ? Colors.amber.shade700
                                : Colors.purple.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'ETKİYİ UYGULA',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
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
      ),
    );
  }
}
