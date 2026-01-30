import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/game_notifier.dart';
import '../../core/theme/game_theme.dart';
import '../../providers/theme_notifier.dart';

/// Rent notification dialog - REMOVED in Quiz RPG mode
/// This dialog is no longer needed as there are no rent payments in the new game
// class RentNotificationDialog extends ConsumerWidget {
//   final String ownerName;
//   final int rentAmount;

//   const RentNotificationDialog({
//     super.key,
//     required this.ownerName,
//     required this.rentAmount,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 320, maxHeight: 400),
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             decoration: GameTheme.cardDecorationFor(
//               ref.watch(themeProvider).isDarkMode,
//             ).copyWith(color: GameTheme.parchmentColor),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // ICON
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.withValues(alpha: 0.15),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.currency_lira,
//                     size: 40,
//                     color: Colors.orange,
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // TITLE
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.orange,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     "KİRA BİLDİRİMİ",
//                     style: GoogleFonts.playfairDisplay(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // MESSAGE
//                 RichText(
//                   textAlign: TextAlign.center,
//                   text: TextSpan(
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: GameTheme.textDark,
//                       height: 1.5,
//                     ),
//                     children: [
//                       const TextSpan(text: "Burası "),
//                       TextSpan(
//                         text: ownerName,
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const TextSpan(text: " kişisinin mülkü.\nKira "),
//                       TextSpan(
//                         text: "₺$rentAmount",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.red,
//                         ),
//                       ),
//                       const TextSpan(text: " ödendi!"),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // BUTTON
//                 ElevatedButton(
//                   onPressed: () =>
//                       ref.read(gameProvider.notifier).closeRentDialog(),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: GameTheme.goldAccent,
//                     foregroundColor: GameTheme.textDark,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 32,
//                       vertical: 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(
//                     "TAMAM",
//                     style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         )
//         .animate()
//         .fadeIn(duration: 300.ms)
//         .scale(
//           begin: const Offset(0.9, 0.9),
//           end: const Offset(1.0, 1.0),
//           duration: 400.ms,
//           curve: Curves.elasticOut,
//         );
//   }
// }

/// Library penalty notification dialog
class LibraryPenaltyDialog extends ConsumerWidget {
  const LibraryPenaltyDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                // ICON
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_library,
                    size: 40,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 16),

                // TITLE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "KÜTÜPHANE NÖBETİ",
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
                  "Kütüphane nöbeti sırası sana geldi.\n2 Tur cezası!",
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
                  onPressed: () => ref
                      .read(gameProvider.notifier)
                      .closeLibraryPenaltyDialog(),
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
                    "TAMAM",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
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

/// İmza Günü notification dialog (informative only)
class ImzaGunuDialog extends ConsumerWidget {
  const ImzaGunuDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                // ICON
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 40, color: Colors.purple),
                ),
                const SizedBox(height: 16),

                // TITLE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "İMZA GÜNÜ",
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
                  "Okurlarınla imza günü düzenledin!\nHarika bir etkinlik oldu. 🎉",
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
                  onPressed: () =>
                      ref.read(gameProvider.notifier).closeImzaGunuDialog(),
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
                    "TAMAM",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
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

/// Turn Skipped notification dialog
class TurnSkippedDialog extends ConsumerWidget {
  const TurnSkippedDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Current player is ALREADY updated to the one who is skipping
    // Turns to skip already decremented by 1 before showing this
    final turnsToSkip = ref.watch(
      gameProvider.select((s) => s.currentPlayer.turnsToSkip),
    );

    return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320, maxHeight: 400),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: GameTheme.cardDecorationFor(
              ref.watch(themeProvider).isDarkMode,
            ).copyWith(color: GameTheme.parchmentColor),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICON
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.block, size: 40, color: Colors.red),
                  ),
                  const SizedBox(height: 16),

                  // TITLE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "SIRA ATLANDI",
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
                    "Cezalı olduğun için bu turu oynayamıyorsun.\nKalan Ceza: $turnsToSkip Tur",
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
                    onPressed: () => ref
                        .read(gameProvider.notifier)
                        .closeTurnSkippedDialog(),
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
                      "DEVAM ET",
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
