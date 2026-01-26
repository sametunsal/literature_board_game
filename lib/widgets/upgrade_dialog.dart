import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/board_tile.dart';
import '../providers/game_notifier.dart';
import '../core/theme/game_theme.dart';
import '../providers/theme_notifier.dart';
import '../utils/sound_manager.dart';
import '../presentation/widgets/common/game_button.dart';

class UpgradeDialog extends ConsumerWidget {
  final BoardTile tile;
  const UpgradeDialog({super.key, required this.tile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate cost (same logic as in GameNotifier)
    int cost = (tile.price ?? 100) ~/ 2;
    if (tile.upgradeLevel == 3) cost = (tile.price ?? 100) * 2;

    String upgradeName = "Baskı";
    if (tile.upgradeLevel == 3) upgradeName = "Cilt (Yıldız)";

    return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320, maxHeight: 400),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: GameTheme.cardDecorationFor(
              ref.watch(themeProvider).isDarkMode,
            ).copyWith(color: GameTheme.parchmentColor),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ICON with background
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    size: 40,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 16),

                // HEADER BADGE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple,
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
                    "GELİŞTİRME",
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // PROPERTY NAME
                Text(
                  "${tile.title}\n($upgradeName Yükseltmesi)",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: GameTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),

                // COST TAG
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.purple.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.purple),
                      const SizedBox(width: 6),
                      Text(
                        "Maliyet: $cost Puan",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: GameTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ACTION BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // DECLINE BUTTON
                    Expanded(
                      child: GameButton(
                        label: "İPTAL",
                        icon: Icons.close,
                        variant: GameButtonVariant.danger,
                        customColor: const Color(0xFFD32F2F),
                        customTextColor: Colors.white,
                        onPressed: () =>
                            ref.read(gameProvider.notifier).declineUpgrade(),
                      ),
                    ),

                    // PURCHASE BUTTON
                    Expanded(
                      child: GameButton(
                        label: "YÜKSELT",
                        icon: Icons.check,
                        variant: GameButtonVariant.success,
                        customColor: const Color(0xFF388E3C),
                        customTextColor: Colors.white,
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          Future.delayed(const Duration(milliseconds: 80), () {
                            HapticFeedback.lightImpact();
                          });
                          SoundManager.instance.playPurchase();
                          ref.read(gameProvider.notifier).upgradeProperty();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          curve: Curves.elasticOut,
        );
  }
}
