import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/game_notifier.dart';
import '../widgets/publishing_portfolio_panel.dart';

class PublishingPortfolioDialog extends ConsumerWidget {
  const PublishingPortfolioDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = math.min(size.width * 0.88, 760.0);
    final dialogHeight = math.min(size.height * 0.88, 560.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F1E8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFC9A227).withValues(alpha: 0.75),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.32),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.library_books_rounded,
                      color: Color(0xFF1A4D42),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Yay\u0131n Portf\u00f6y\u00fc',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A4D42),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Portf\u00f6y\u00fc kapat',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: const Color(0xFF1A4D42),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFD4C4A8)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: PublishingPortfolioPanel(
                    players: state.players,
                    bookOwnerships: state.bookOwnerships,
                    currentPlayerIndex: state.currentPlayerIndex,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
