import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/game_notifier.dart';
import 'publication_badge.dart';

/// Centered, richer celebration shown when a book advances a publishing level
/// (Telif → Baskı or Baskı → Cilt). Unlike the pawn-anchored reward toast, it
/// spells out the royalty upgrade and the player's Cilt progress so the path
/// to victory stays legible. Self-dismissing; the notifier clears it.
class ProgressionCelebrationDialog extends StatelessWidget {
  final ProgressionCelebration celebration;
  final VoidCallback onComplete;

  const ProgressionCelebrationDialog({
    super.key,
    required this.celebration,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        (celebration.ciltCount / celebration.ciltTarget).clamp(0.0, 1.0);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_ink, _inkDeep],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _gold.withValues(alpha: 0.85), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: celebration.ownerColor.withValues(alpha: 0.35),
                blurRadius: 30,
                spreadRadius: -3,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Headline: badge + level reached + book title.
              Row(
                children: [
                  PublicationBadge(
                    level: celebration.toLevel,
                    ownerColor: celebration.ownerColor,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${celebration.levelLabel} tamamlandı!',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _gold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '📚 ${celebration.bookTitle}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _ivory.withValues(alpha: 0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InfoRow(
                label: 'Royalty',
                value:
                    '${celebration.royaltyBefore}  →  ${celebration.royaltyAfter}',
                valueColor: Colors.greenAccent,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cilt İlerleme',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: _ivory.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '${celebration.ciltCount} / ${celebration.ciltTarget}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: _ivory.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    celebration.ownerColor,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate(onComplete: (_) => onComplete())
            .fadeIn(duration: 220.ms, curve: Curves.easeOut)
            .scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1, 1),
              duration: 320.ms,
              curve: Curves.easeOutBack,
            )
            .then(delay: 2200.ms)
            .slideY(
              begin: 0,
              end: -0.15,
              duration: 420.ms,
              curve: Curves.easeIn,
            )
            .fadeOut(duration: 420.ms),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: _ivory.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

const _ink = Color(0xFF241A10);
const _inkDeep = Color(0xFF17100A);
const _gold = Color(0xFFFFD54F);
const _ivory = Color(0xFFF8EEDC);
