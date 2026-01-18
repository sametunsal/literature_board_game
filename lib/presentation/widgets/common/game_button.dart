import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/game_theme.dart';
import '../../../providers/theme_notifier.dart';

enum GameButtonVariant { primary, secondary, danger, success }

class GameButton extends ConsumerWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final GameButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final bool isDisabled;
  final Color? customColor;
  final Color? customTextColor;

  const GameButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.variant = GameButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isDisabled = false,
    this.customColor,
    this.customTextColor,
    this.maxLines = 1, // Default to single line
  });

  final int? maxLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final tokens = themeState.tokens;

    final backgroundColor = customColor ?? _getBackgroundColor(variant, tokens);
    final foregroundColor =
        customTextColor ?? _getForegroundColor(variant, tokens);

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ), // Reduced horizontal padding
          elevation: 4,
          shadowColor: backgroundColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 22, color: foregroundColor),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center, // Center text for multiline
                      maxLines: maxLines,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: foregroundColor,
                        height: 1.2, // Better line height for wrapping
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Color _getBackgroundColor(GameButtonVariant variant, ThemeTokens tokens) {
    switch (variant) {
      case GameButtonVariant.primary:
        return tokens.primary;
      case GameButtonVariant.secondary:
        return tokens.secondary;
      case GameButtonVariant.danger:
        return tokens.danger;
      case GameButtonVariant.success:
        return tokens.success;
    }
  }

  Color _getForegroundColor(GameButtonVariant variant, ThemeTokens tokens) {
    return tokens.textOnAccent;
  }
}
