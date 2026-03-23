import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/game_notifier.dart';
import '../../core/theme/game_theme.dart';
import '../../providers/theme_notifier.dart';

/// İmza Günü — biraz daha yüksek dikey kart
Size _imzaCardSize(BuildContext context) {
  final s = MediaQuery.sizeOf(context);
  return Size(
    math.min(s.width * 0.90, 400),
    math.min(s.height * 0.78, 560),
  );
}

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

/// Kütüphane — kompakt dikey kart, otomatik kapanır ve sıra geçer
class LibraryPenaltyDialog extends ConsumerStatefulWidget {
  const LibraryPenaltyDialog({super.key});

  @override
  ConsumerState<LibraryPenaltyDialog> createState() =>
      _LibraryPenaltyDialogState();
}

class _LibraryPenaltyDialogState extends ConsumerState<LibraryPenaltyDialog> {
  static const _ink = Color(0xFF3E2723);
  static const _wood = Color(0xFF5D4037);
  static const _parchment = Color(0xFFF2EBDD);
  static const _accent = Color(0xFF8D6E63);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        ref.read(gameProvider.notifier).closeLibraryPenaltyDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cardW = math.min(size.width * 0.52, 260.0);
    final cardH = math.min(size.height * 0.48, 320.0);

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: cardW,
        height: cardH,
        child: Container(
          decoration: BoxDecoration(
            color: _wood,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2D1F18), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _parchment,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _accent, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                    decoration: const BoxDecoration(
                      color: _ink,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_rounded,
                            color: Colors.amber.shade200, size: 20),
                        const SizedBox(width: 7),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'KÜTÜPHANE NÖBETİ',
                              style: GoogleFonts.crimsonText(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 2, color: _accent),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_library_rounded,
                              color: _wood, size: 32),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Raflar arasında 2 tur\nboyunca bekleyeceksin.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.crimsonText(
                                fontSize: 13,
                                height: 1.35,
                                color: _ink,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Sıra otomatik olarak geçiyor…',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: _accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 280.ms)
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          duration: 380.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

/// İmza günü — mürekkep & davetiye tonları (soru kartı boyutu)
class ImzaGunuDialog extends ConsumerWidget {
  const ImzaGunuDialog({super.key});

  static const _plum = Color(0xFF4A148C);
  static const _plumLight = Color(0xFF6A1B9A);
  static const _gold = Color(0xFFC9A227);
  static const _ivory = Color(0xFFFFF8F5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sz = _imzaCardSize(context);
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: sz.width,
        height: sz.height,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_plumLight, _plum],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _gold, width: 3),
            boxShadow: [
              BoxShadow(
                color: _plum.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: _ivory,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _gold.withValues(alpha: 0.7), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_fix_high_rounded, color: _plum, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'İMZA GÜNÜ',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _plum,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          _gold,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
                    child: Column(
                      children: [
                        Text(
                          '“Okurlarınla buluştun.”',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: _plumLight,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: Center(
                            child: Text(
                              'İmza masasında harika bir gün geçirdin. Kitapların mürekkebi kurumadan anılar kaldı! 🖋️',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lora(
                                fontSize: 16,
                                height: 1.5,
                                color: const Color(0xFF37474F),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => ref
                                .read(gameProvider.notifier)
                                .closeImzaGunuDialog(),
                            style: FilledButton.styleFrom(
                              backgroundColor: _plum,
                              foregroundColor: _gold,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: _gold, width: 1.5),
                              ),
                            ),
                            child: Text(
                              'HARİKA!',
                              style: GoogleFonts.playfairDisplay(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 280.ms)
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          duration: 380.ms,
          curve: Curves.easeOutBack,
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
    final size = MediaQuery.sizeOf(context);

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: math.min(size.width * 0.5, 280),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F1E3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF8D6E63), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8D8C2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 36,
                  color: Color(0xFF5D4037),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'KÜTÜPHANE CEZASI',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3E2723),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Bu tur sessizlikte bekliyorsun.\nSıra otomatik olarak diğer oyuncuya geçiyor.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.5,
                  color: const Color(0xFF4E342E),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEBE9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  turnsToSkip > 0
                      ? 'Kalan ceza: $turnsToSkip tur'
                      : 'Ceza bu tur bitiyor',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6D4C41),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 220.ms)
        .scale(
          begin: const Offset(0.94, 0.94),
          end: const Offset(1, 1),
          duration: 260.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
