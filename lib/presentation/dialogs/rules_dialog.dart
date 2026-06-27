import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/game_constants.dart';
import '../../core/services/book_progression_service.dart';
import '../../core/theme/game_theme.dart';
import '../../models/book_level.dart';
import '../../providers/theme_notifier.dart';

class RulesDialog extends ConsumerWidget {
  const RulesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final tokens = themeState.tokens;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          constraints: BoxConstraints(
            maxWidth: 700,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: tokens.dialogBackground.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: tokens.accent.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: tokens.border.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book, color: tokens.accent, size: 32),
                        const SizedBox(width: 12),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Oyun Kuralları',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: tokens.accent,
                                letterSpacing: 1.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: tokens.textSecondary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(tokens, 'Amaç', Icons.flag, [
                        '${GameConstants.publishingCiltBooksToWin} Cilt kitaba sahip olan ilk oyuncu kazanır.',
                        'Telif ve Baskı ilerleme basamaklarıdır; yalnızca Cilt kitaplar zafere sayılır.',
                        'Söz kartları ve alıntılar koleksiyon/flavor içindir, kazanma şartı değildir.',
                      ]),
                      const SizedBox(height: 24),
                      _buildSection(
                        tokens,
                        'Yayıncılık Akışı',
                        Icons.library_books,
                        [
                          'Zar at, ilerle ve kitap karesine geldiğinde soruyu cevapla.',
                          'Sahipsiz kitapta doğru cevap Telif kazandırır.',
                          'Kendi kitabını Akçe harcayarak Telif -> Baskı -> Cilt şeklinde yükseltirsin.',
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSection(tokens, 'Akçe ve Ustalık', Icons.trending_up, [
                        'Akçe doğru cevaplardan ve bazı bonuslardan kazanılır.',
                        'Akçe Baskı, Cilt ve Meşk için harcanır.',
                        'Kategoriler doğru cevaplarla Acemi, Çırak, Kalfa, Usta diye ilerler.',
                        'Cilt yükseltmesi için ilgili kategoride en az Kalfa gerekir.',
                      ]),
                      const SizedBox(height: 24),
                      _buildSection(tokens, 'Royalty', Icons.payments, [
                        'Rakibin kitabında yanlış cevap verirsen sahibine Royalty ödersin.',
                        'Telif: ${BookProgressionService.royaltyForLevel(BookLevel.telif)} Akçe, Baskı: ${BookProgressionService.royaltyForLevel(BookLevel.baski)} Akçe, Cilt: ${BookProgressionService.royaltyForLevel(BookLevel.cilt)} Akçe.',
                        'Doğru cevapta Royalty ödenmez.',
                      ]),
                      const SizedBox(height: 24),
                      _buildSection(tokens, 'Kıraathane ve Meşk', Icons.store, [
                        'Kıraathane doğrudan Meşk açar.',
                        'Meşk ${GameConstants.meskCostAkce} Akçe tutar ve seçtiğin kategoriden soru sorar.',
                        'Meşk doğru cevapta yalnızca ustalık ilerlemesi verir; Akçe, Telif veya Royalty oluşturmaz.',
                      ]),
                      const SizedBox(height: 24),
                      _buildSection(tokens, 'Özel Kareler', Icons.casino, [
                        'Şans ve Kader kartları olumlu ya da olumsuz özel olaylar getirir.',
                        'Kütüphane bekleme/ceza etkisi yaratabilir.',
                        'Başlangıçtan geçince Akçe bonusu alınır.',
                        'Tahtadaki sahip çipi kitabın sahibini, T/B/C işaretleri seviyesini gösterir.',
                      ]),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: tokens.border.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'İyi oyunlar, yayıncılık yolculuğunuzda başarılar!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: tokens.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    ThemeTokens tokens,
    String title,
    IconData icon,
    List<String> points,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tokens.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tokens.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: tokens.accent, size: 24),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: tokens.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: tokens.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: tokens.textSecondary,
                        height: 1.5,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
