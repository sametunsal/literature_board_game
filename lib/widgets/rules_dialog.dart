import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_notifier.dart';
import '../core/theme/game_theme.dart';

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
          width: 800,
          height: 500,
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
          child: DefaultTabController(
            length: 4,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
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
                      Text(
                        "NASIL OYNANIR?",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: tokens.accent,
                          letterSpacing: 2,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: tokens.textSecondary),
                      ),
                    ],
                  ),
                ),

                // Tabs
                TabBar(
                  labelColor: tokens.accent,
                  unselectedLabelColor: tokens.textSecondary,
                  indicatorColor: tokens.accent,
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(icon: Icon(Icons.flag), text: "AMAÇ"),
                    Tab(icon: Icon(Icons.directions_walk), text: "HAREKET"),
                    Tab(icon: Icon(Icons.auto_stories), text: "KARTLAR"),
                    Tab(icon: Icon(Icons.emoji_events), text: "KAZANMA"),
                  ],
                ),

                // Content
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTabContent(
                        tokens,
                        "Oyunun Amacı",
                        "Edebina'da amaç, Türk Edebiyatı'nın seçkin eserlerine ve yazarlarına sahip olarak en zengin koleksiyoner olmaktır.\n\n"
                            "• Eserleri satın alın ve kira geliri elde edin.\n"
                            "• Yayınevleri kurarak gücünüzü artırın.\n"
                            "• Rakibinizin iflas etmesini sağlayın veya belirlenen süre sonunda en yüksek puana sahip olun.",
                        Icons.flag_circle,
                      ),
                      _buildTabContent(
                        tokens,
                        "Oyun Akışı",
                        "• Sırası gelen oyuncu iki zar atar ve gelen sayı kadar ilerler.\n"
                            "• Geldiğiniz kare sahipsiz bir eserse, satın alabilirsiniz.\n"
                            "• Sahipli bir kareye gelirseniz, mülk sahibine kira ödersiniz.\n"
                            "• Çift zar atarsanız tekrar oynama hakkı kazanırsınız. Ancak 3 kez üst üste çift atarsanız 'Kütüphane Nöbeti'ne gidersiniz!",
                        Icons.directions_run,
                      ),
                      _buildTabContent(
                        tokens,
                        "Şans ve Kader",
                        "• 'Şans Kartı' karesine geldiğinizde, size beklenmedik bonuslar veya fırsatlar sunan bir kart çekersiniz.\n"
                            "• 'Kader Kartı' ise oyunun gidişatını değiştirebilecek, bazen olumlu bazen riskli durumlar yaratır.\n"
                            "• Ayrıca 'İmza Günü', 'Edebiyat Sınavı' gibi özel kareler de sürpriz etkiler yaratabilir.",
                        Icons.style,
                      ),
                      _buildTabContent(
                        tokens,
                        "Bitiş ve Kazanma",
                        "Oyun iki şekilde biter:\n\n"
                            "1. İflas: Bir oyuncunun parası (puanı) 0'ın altına düşerse iflas eder ve oyun biter. Kalan oyuncular arasında en zengin olan kazanır.\n\n"
                            "2. Süre/Tur Limiti: Belirlenen tur sayısı tamamlandığında oyun biter ve en çok varlığa sahip olan oyuncu kazanır.",
                        Icons.emoji_events,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    ThemeTokens tokens,
    String title,
    String description,
    IconData icon,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: tokens.accent.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: tokens.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
