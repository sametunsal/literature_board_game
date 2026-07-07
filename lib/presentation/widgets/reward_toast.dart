import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium reward toast for in-game feedback: earned Akçe, Telif/Baskı/Cilt
/// progression, royalty payments, bonuses and penalties.
///
/// One shared layout for the whole notification family — a dark ink pill with
/// a gold-trimmed accent medallion — where the [color], [icon] and [title]
/// give each reward type its own identity. Animates in with a soft
/// slide/scale, holds briefly, then fades out (total ~2s, matching the
/// notifier's floating-effect timer).
class RewardToast extends StatelessWidget {
  final String text;
  final Color color;
  final String? title;
  final IconData? icon;
  final VoidCallback onComplete;

  const RewardToast({
    super.key,
    required this.text,
    required this.color,
    this.title,
    this.icon,
    required this.onComplete,
  });

  static const _ink = Color(0xFF241A10);
  static const _inkDeep = Color(0xFF17100A);
  static const _ivory = Color(0xFFF8EEDC);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child:
            Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_ink, _inkDeep],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withValues(alpha: 0.75),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.38),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: color.withValues(alpha: 0.28),
                        blurRadius: 22,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withValues(alpha: 0.16),
                              border: Border.all(
                                color: color.withValues(alpha: 0.8),
                                width: 1.2,
                              ),
                            ),
                            child: Icon(icon, size: 18, color: color),
                          ),
                          const SizedBox(width: 10),
                        ],
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: icon != null
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            children: [
                              if (title != null)
                                Text(
                                  title!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.6,
                                    color: color,
                                  ),
                                ),
                              if (title != null) const SizedBox(height: 1),
                              Text(
                                text,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  height: 1.2,
                                  fontWeight: FontWeight.w700,
                                  color: _ivory,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .animate(onComplete: (_) => onComplete())
                .fadeIn(duration: 200.ms, curve: Curves.easeOut)
                .slideY(
                  begin: 0.35,
                  end: 0,
                  duration: 320.ms,
                  curve: Curves.easeOutCubic,
                )
                .scale(
                  begin: const Offset(0.92, 0.92),
                  end: const Offset(1, 1),
                  duration: 320.ms,
                  curve: Curves.easeOutBack,
                )
                .then(delay: 1100.ms)
                .slideY(
                  begin: 0,
                  end: -0.2,
                  duration: 420.ms,
                  curve: Curves.easeIn,
                )
                .fadeOut(duration: 420.ms),
      ),
    );
  }
}
