import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/motion/motion_constants.dart';
import '../../../providers/theme_notifier.dart';

class GameDialog extends ConsumerWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final double? width;
  final VoidCallback? onClose;

  const GameDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.width = 340,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final tokens = themeState.tokens;
    final isDarkMode = themeState.isDarkMode;

    return Center(
          child: Container(
            width: width,
            padding: const EdgeInsets.all(24),
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
                if (title != null) ...[
                  Text(
                    title!,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: tokens.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Flexible(child: content),
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(children: actions!),
                ],
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: MotionDurations.dialog.safe,
          curve: MotionCurves.standard,
        )
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1.0, 1.0),
          duration: MotionDurations.dialog.safe,
          curve: MotionCurves.emphasized,
        );
  }
}
