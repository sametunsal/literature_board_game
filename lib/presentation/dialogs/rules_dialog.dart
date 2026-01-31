import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_notifier.dart';
import '../../core/theme/game_theme.dart';

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
              // Header
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
                        Text(
                          "Oyun Kuralları",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: tokens.accent,
                            letterSpacing: 1.5,
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

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(tokens, "Oyunun Amacı", Icons.flag, [
                        "Nihai hedef \"Ehil\" unvanını kazanmaktır.",
                        "Bunun için 6 farklı kategoride (İlkler, Edebi Sanatlar, vb.) \"Usta\" seviyesine ulaşmalısınız.",
                        "Ayrıca \"Kıraathane\"den (Mağaza) 50 adet Edebi Söz Kartı biriktirmelisiniz.",
                      ]),
                      const SizedBox(height: 24),
                      _buildSection(
                        tokens,
                        "Nasıl Oynanır?",
                        Icons.directions_walk,
                        [
                          "Sırası gelen oyuncu zar atar ve piyonunu ilerletir.",
                          "Üzerine geldiğiniz kutucuktaki kategoriden bir soru sorulur.",
                          "Soruyu doğru bilirseniz \"Yıldız\" (⭐) kazanırsınız ve o kategorideki ustalığınız artar.",
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSection(tokens, "Seviye Sistemi", Icons.trending_up, [
                        "Her kategori için sırasıyla: Acemi → Çırak → Kalfa → Usta seviyeleri vardır.",
                        "Soruları bildikçe seviye atlarsınız.",
                        "Zorluk seviyesi arttıkça kazanılan Yıldız miktarı da artar.",
                      ]),
                      const SizedBox(height: 24),
                      _buildSection(
                        tokens,
                        "Yıldızlar ve Kıraathane",
                        Icons.store,
                        [
                          "Kazandığınız yıldızları \"Kıraathane\" bölümünde harcayabilirsiniz.",
                          "Buradan farklı dönemlere ait \"Edebi Söz Kartları\" satın alarak koleksiyonunuzu genişletin.",
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSection(tokens, "Şans ve Kader", Icons.casino, [
                        "Köşelerdeki Şans ve Kader kutucukları size sürpriz avantajlar veya dezavantajlar sağlayabilir.",
                      ]),
                    ],
                  ),
                ),
              ),

              // Footer
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
                    "Bol şans, edebiyat yolculuğunuzda!",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: tokens.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
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
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: tokens.textPrimary,
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
