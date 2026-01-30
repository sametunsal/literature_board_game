import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_card.dart';
import '../../models/game_enums.dart';
import '../../providers/game_notifier.dart';
import '../../core/theme/game_theme.dart';
import '../../providers/theme_notifier.dart';

/// Card dialog with auto-dismiss timer (3 seconds)
class CardDialog extends ConsumerStatefulWidget {
  final GameCard card;
  const CardDialog({super.key, required this.card});

  @override
  ConsumerState<CardDialog> createState() => _CardDialogState();
}

class _CardDialogState extends ConsumerState<CardDialog> {
  Timer? _autoDismissTimer;
  double _progress = 1.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _startAutoDismiss();
  }

  void _startAutoDismiss() {
    // Progress bar animation
    const duration = Duration(milliseconds: 3000);
    const tickRate = Duration(milliseconds: 50);
    final totalTicks = duration.inMilliseconds / tickRate.inMilliseconds;
    int currentTick = 0;

    _progressTimer = Timer.periodic(tickRate, (timer) {
      currentTick++;
      if (mounted) {
        setState(() {
          _progress = 1.0 - (currentTick / totalTicks);
        });
      }
    });

    // Auto dismiss after 3 seconds
    _autoDismissTimer = Timer(duration, () {
      if (mounted) {
        ref.read(gameProvider.notifier).closeCardDialog();
      }
    });
  }

  void _cancelTimerAndDismiss() {
    _autoDismissTimer?.cancel();
    _progressTimer?.cancel();
    ref.read(gameProvider.notifier).closeCardDialog();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final isSans = card.type == CardType.sans;
    final cardColor = isSans
        ? const Color(0xFFE91E63)
        : const Color(0xFF00897B);
    final cardTitle = isSans ? "ŞANS KARTI" : "KADER KARTI";
    final cardIcon = isSans ? Icons.star : Icons.bolt;

    return GestureDetector(
      onTap: _cancelTimerAndDismiss,
      child:
          ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 320,
                  maxHeight: 450,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: GameTheme.cardDecorationFor(
                    ref.watch(themeProvider).isDarkMode,
                  ).copyWith(color: GameTheme.parchmentColor),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // PROGRESS BAR (auto-dismiss indicator)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(cardColor),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // CARD ICON with glow effect
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: cardColor.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(cardIcon, size: 50, color: cardColor),
                      ),
                      const SizedBox(height: 16),

                      // TITLE with styled badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          cardTitle,
                          style: GoogleFonts.playfairDisplay(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // DESCRIPTION
                      Flexible(
                        child: SingleChildScrollView(
                          child: Text(
                            card.description,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: GameTheme.textDark,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TAP TO DISMISS HINT
                      Text(
                        "Kapatmak için dokun",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: GameTheme.textDark.withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .move(
                begin: isSans
                    ? const Offset(-200, -200)
                    : const Offset(200, 200),
                end: Offset.zero,
                duration: 600.ms,
                curve: Curves.easeOutCubic,
              )
              .scale(
                begin: const Offset(0.2, 0.2),
                end: const Offset(1.0, 1.0),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              )
              .rotate(
                begin: isSans ? -0.2 : 0.2,
                end: 0,
                duration: 600.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(duration: 200.ms),
    );
  }
}
