import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/theme_notifier.dart';

class GameCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isInteractive;

  const GameCard({
    super.key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final tokens = themeState.tokens;
    final isDarkMode = themeState.isDarkMode;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: tokens.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow.withValues(alpha: isDarkMode ? 0.3 : 0.15),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: tokens.shadow.withValues(alpha: isDarkMode ? 0.4 : 0.1),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: isInteractive
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8.0),
              child: child,
            )
          : child,
    );
  }
}
