import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/game_theme.dart';
import '../../core/motion/motion_constants.dart';
import '../../providers/theme_notifier.dart';
import '../../core/managers/audio_manager.dart';
import '../widgets/common/game_button.dart';

/// Pause menu dialog with resume, settings, end game, and exit options
/// Styled to match the premium Literature Board Game theme - now theme-aware
class PauseDialog extends ConsumerWidget {
  final VoidCallback onResume;
  final VoidCallback onSettings;
  final VoidCallback onCollection;
  final VoidCallback onEndGame;
  final VoidCallback onExit;

  const PauseDialog({
    super.key,
    required this.onResume,
    required this.onSettings,
    required this.onCollection,
    required this.onEndGame,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Theme-aware tokens
    final themeState = ref.watch(themeProvider);
    final isDarkMode = themeState.isDarkMode;
    final tokens = themeState.tokens;
    final currentPreset = themeState.preset;

    final size = MediaQuery.of(context).size;

    return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 320,
                maxHeight: size.height * 0.92,
              ),
              child: Container(
                width: math.min(size.width * 0.42, 320),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: tokens.border.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: tokens.shadow.withValues(
                        alpha: isDarkMode ? 0.4 : 0.15,
                      ),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: tokens.shadow.withValues(
                        alpha: isDarkMode ? 0.2 : 0.08,
                      ),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                // HEADER ICON
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: tokens.accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pause_circle_filled,
                    size: 28,
                    color: tokens.accent,
                  ),
                ),
                const SizedBox(height: 10),

                // TITLE
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "OYUN DURAKLATILDI",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tokens.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // SUBTITLE
                Text(
                  "Ne yapmak istersiniz?",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),

                // THEME SELECTOR
                _buildThemeSelector(
                  context,
                  ref,
                  tokens,
                  isDarkMode,
                  currentPreset,
                ),
                const SizedBox(height: 8),

                // DIVIDER
                _buildDivider(tokens),
                const SizedBox(height: 8),

                // RESUME BUTTON
                GameButton(
                  label: "OYUNA DÖN",
                  icon: Icons.play_arrow,
                  variant: GameButtonVariant.success,
                  isFullWidth: true,
                  onPressed: () {
                    AudioManager.instance.playClick();
                    onResume();
                  },
                ),
                const SizedBox(height: 7),

                // SETTINGS BUTTON
                GameButton(
                  label: "AYARLAR",
                  icon: Icons.settings,
                  variant: GameButtonVariant.secondary,
                  isFullWidth: true,
                  onPressed: () {
                    AudioManager.instance.playClick();
                    onSettings();
                  },
                ),
                const SizedBox(height: 7),

                // COLLECTION BUTTON
                GameButton(
                  label: "KOLEKSİYONUM",
                  icon: Icons.collections_bookmark,
                  variant: GameButtonVariant.secondary,
                  isFullWidth: true,
                  onPressed: () {
                    AudioManager.instance.playClick();
                    onCollection();
                  },
                ),
                const SizedBox(height: 7),

                // END GAME BUTTON
                GameButton(
                  label: "OYUNU BİTİR",
                  icon: Icons.flag,
                  variant: GameButtonVariant.primary,
                  isFullWidth: true,
                  onPressed: () {
                    AudioManager.instance.playClick();
                    onEndGame();
                  },
                ),
                const SizedBox(height: 7),

                // EXIT BUTTON
                GameButton(
                  label: "ANA MENÜ",
                  icon: Icons.exit_to_app,
                  variant: GameButtonVariant.danger,
                  isFullWidth: true,
                  onPressed: () {
                    AudioManager.instance.playClick();
                    onExit();
                  },
                ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: MotionDurations.dialog.safe)
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1.0, 1.0),
          duration: MotionDurations.dialog.safe,
          curve: MotionCurves.emphasized,
        );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    WidgetRef ref,
    ThemeTokens tokens,
    bool isDarkMode,
    ThemePreset currentPreset,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: tokens.border.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Label
          Text(
            "TEMA",
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: tokens.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          // Options column
          Column(
            children: [
              _buildThemeOption(
                label: "Sıcak Kütüphane",
                icon: Icons.light_mode,
                isSelected: currentPreset == ThemePreset.warmLibraryLight,
                tokens: tokens,
                isDarkMode: isDarkMode,
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .setPreset(ThemePreset.warmLibraryLight),
              ),
              const SizedBox(height: 6),
              _buildThemeOption(
                label: "Karanlık Akademi",
                icon: Icons.dark_mode,
                isSelected: currentPreset == ThemePreset.darkAcademia,
                tokens: tokens,
                isDarkMode: isDarkMode,
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .setPreset(ThemePreset.darkAcademia),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required ThemeTokens tokens,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        AudioManager.instance.playClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: MotionDurations.fast.safe,
        curve: MotionCurves.standard,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? tokens.primary.withValues(alpha: isDarkMode ? 0.25 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? tokens.primary
                : tokens.border.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? tokens.primary : tokens.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? tokens.primary : tokens.textSecondary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(Icons.check_circle, size: 12, color: tokens.primary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeTokens tokens) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  tokens.border.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.menu_book,
            size: 16,
            color: tokens.accent.withValues(alpha: 0.6),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  tokens.border.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
