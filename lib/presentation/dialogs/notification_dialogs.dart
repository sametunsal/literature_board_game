import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/game_notifier.dart';
import '../../core/theme/game_theme.dart';
import '../../providers/theme_notifier.dart';

/// Base layout for all notification dialogs to prevent code duplication
class NotificationDialogBase extends ConsumerWidget {
  final IconData icon;
  final Color baseColor;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  const NotificationDialogBase({
    super.key,
    required this.icon,
    required this.baseColor,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider).isDarkMode;

    return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320, maxHeight: 400),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: GameTheme.cardDecorationFor(
              isDarkMode,
            ).copyWith(color: GameTheme.parchmentColor),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICON
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: baseColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 40, color: baseColor),
                  ),
                  const SizedBox(height: 16),

                  // TITLE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // MESSAGE
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: GameTheme.textDark,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // BUTTON
                  ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameTheme.goldAccent,
                      foregroundColor: GameTheme.textDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
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

/// Library penalty notification dialog
class LibraryPenaltyDialog extends ConsumerWidget {
  const LibraryPenaltyDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationDialogBase(
      icon: Icons.local_library,
      baseColor: Colors.brown,
      title: "KÜTÜPHANE NÖBETİ",
      message: "Kütüphane nöbeti sırası sana geldi.\n2 Tur cezası!",
      buttonText: "TAMAM",
      onPressed: () =>
          ref.read(gameProvider.notifier).closeLibraryPenaltyDialog(),
    );
  }
}

/// İmza Günü notification dialog (informative only)
class ImzaGunuDialog extends ConsumerWidget {
  const ImzaGunuDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationDialogBase(
      icon: Icons.edit,
      baseColor: Colors.purple,
      title: "İMZA GÜNÜ",
      message:
          "Okurlarınla imza günü düzenledin!\nHarika bir etkinlik oldu. 🎉",
      buttonText: "TAMAM",
      onPressed: () => ref.read(gameProvider.notifier).closeImzaGunuDialog(),
    );
  }
}

/// Turn Skipped notification dialog
class TurnSkippedDialog extends ConsumerWidget {
  const TurnSkippedDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turnsToSkip = ref.watch(
      gameProvider.select((s) => s.currentPlayer.turnsToSkip),
    );

    return NotificationDialogBase(
      icon: Icons.block,
      baseColor: Colors.red,
      title: "SIRA ATLANDI",
      message:
          "Cezalı olduğun için bu turu oynayamıyorsun.\nKalan Ceza: $turnsToSkip Tur",
      buttonText: "DEVAM ET",
      onPressed: () => ref.read(gameProvider.notifier).closeTurnSkippedDialog(),
    );
  }
}
