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
    final isLandscape = size.width > size.height;
    
    // Landscape modda daha dar, portrait modda daha geniş
    final dialogWidth = isLandscape 
        ? math.min(size.width * 0.28, 280.0)
        : math.min(size.width * 0.75, 300.0);
    final dialogMaxHeight = isLandscape 
        ? size.height * 0.88
        : size.height * 0.80;

    return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogWidth,
                maxHeight: dialogMaxHeight,
              ),
              child: Container(
                width: dialogWidth,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: BorderRadius.circular(20),
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
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  // HEADER ICON - daha küçük
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: tokens.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pause_circle_filled,
                      size: 22,
                      color: tokens.accent,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // TITLE - daha küçük
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "OYUN DURAKLATILDI",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: tokens.textPrimary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),

                  // SUBTITLE
                  Text(
                    "Ne yapmak istersiniz?",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: tokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // THEME SELECTOR - kompakt
                  _buildThemeSelector(
                    context,
                    ref,
                    tokens,
                    isDarkMode,
                    currentPreset,
                  ),
                  const SizedBox(height: 6),

                  // DIVIDER
                  _buildDivider(tokens),
                  const SizedBox(height: 6),

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
                  const SizedBox(height: 5),

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
                  const SizedBox(height: 5),

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
                  const SizedBox(height: 5),

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
                  const SizedBox(height: 5),

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
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
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
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: tokens.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          // Options row - yatay yerleşim daha kompakt
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  label: "Sıcak",
                  icon: Icons.light_mode,
                  isSelected: currentPreset == ThemePreset.warmLibraryLight,
                  tokens: tokens,
                  isDarkMode: isDarkMode,
                  onTap: () => ref
                      .read(themeProvider.notifier)
                      .setPreset(ThemePreset.warmLibraryLight),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildThemeOption(
                  label: "Karanlık",
                  icon: Icons.dark_mode,
                  isSelected: currentPreset == ThemePreset.darkAcademia,
                  tokens: tokens,
                  isDarkMode: isDarkMode,
                  onTap: () => ref
                      .read(themeProvider.notifier)
                      .setPreset(ThemePreset.darkAcademia),
                ),
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? tokens.primary.withValues(alpha: isDarkMode ? 0.25 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? tokens.primary
                : tokens.border.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? tokens.primary : tokens.textSecondary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? tokens.primary : tokens.textSecondary,
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 2),
              Icon(Icons.check, size: 10, color: tokens.primary),
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
