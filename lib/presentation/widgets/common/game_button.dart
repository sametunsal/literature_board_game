import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/game_theme.dart';
import '../../../providers/theme_notifier.dart';
import '../../../core/managers/audio_manager.dart';

enum GameButtonVariant { primary, secondary, danger, success }
enum GameButtonSize { normal, compact }

class GameButton extends ConsumerWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final GameButtonVariant variant;
  final GameButtonSize size;
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
    this.size = GameButtonSize.normal,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isDisabled = false,
    this.customColor,
    this.customTextColor,
    this.maxLines = 1,
  });

  final int? maxLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final tokens = themeState.tokens;

    final backgroundColor = customColor ?? _getBackgroundColor(variant, tokens);
    final foregroundColor =
        customTextColor ?? _getForegroundColor(variant, tokens);

    // Size bazlı değerler
    final isCompact = size == GameButtonSize.compact;
    final verticalPad = isCompact ? 8.0 : 14.0;
    final horizontalPad = isCompact ? 10.0 : 16.0;
    final iconSize = isCompact ? 16.0 : 22.0;
    final fontSize = isCompact ? 11.0 : 15.0;
    final borderRadius = isCompact ? 8.0 : 12.0;
    final elevation = isCompact ? 2.0 : 4.0;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isDisabled || isLoading
            ? null
            : () {
                AudioManager.instance.playSfx('audio/ui_click.wav');
                onPressed();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
          padding: EdgeInsets.symmetric(
            vertical: verticalPad,
            horizontal: horizontalPad,
          ),
          elevation: elevation,
          shadowColor: backgroundColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: isCompact ? 16 : 20,
                height: isCompact ? 16 : 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: iconSize, color: foregroundColor),
                    SizedBox(width: isCompact ? 5 : 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: maxLines,
                      style: GoogleFonts.poppins(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: isCompact ? 0.3 : 0.5,
                        color: foregroundColor,
                        height: 1.2,
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
