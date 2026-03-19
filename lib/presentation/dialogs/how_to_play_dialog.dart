import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HowToPlayDialog extends StatefulWidget {
  const HowToPlayDialog({super.key});

  @override
  State<HowToPlayDialog> createState() => _HowToPlayDialogState();
}

class _HowToPlayDialogState extends State<HowToPlayDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      "title": "GİRİŞ",
      "icon": Icons.auto_stories_rounded,
      "color": Color(0xFF00695C),
      "content":
          "Hoş geldin! Edebina, edebiyat bilgisini stratejiyle birleştiren 3 boyutlu bir masa oyunudur.\n\n"
          "Amacınız: Edebi eserleri toplamak, soruları doğru cevaplamak ve haritadaki tüm durakları tamamlayarak Üniversite'ye ulaşan ilk kişi olmaktır.",
    },
    {
      "title": "KARTLAR",
      "icon": Icons.style_rounded,
      "color": Color(0xFF3949AB),
      "content":
          "Oyun iki ana kart destesiyle yönetilir:\n\n"
          "✨ ŞANS KARTLARI (Yeşil): Size beklenmedik avantajlar veya küçük sürprizler sunar.\n\n"
          "🔥 KADER KARTLARI (Mavi): Oyunun gidişatını değiştirebilecek zorlu sınavlar veya büyük ödüller içerir.",
    },
    {
      "title": "KARELER",
      "icon": Icons.map_rounded,
      "color": Color(0xFFD84315),
      "content":
          "Haritada farklı efektlere sahip kareler bulunur:\n\n"
          "📚 KÜTÜPHANE: Bilgi hazinesidir ama sessiz olunmalıdır. Sıra bekleyebilirsiniz.\n\n"
          "🏫 KİTAPÇI: Eser toplamak için en iyi yerdir.\n\n"
          "🎓 ÜNİVERSİTE: Oyunun final noktasıdır.",
    },
    {
      "title": "KURALLAR",
      "icon": Icons.gavel_rounded,
      "color": Color(0xFF455A64),
      "content":
          "1. Her tur sırasıyla zar atılır.\n"
          "2. Çift atan oyuncu tekrar oynar.\n"
          "3. Soruları doğru bilen ekstra puan kazanır.\n"
          "4. En çok eseri toplayan ve bitişe ulaşan kazanır!",
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Book Theme Colors
    const bgColor = Color(0xFFF9F7F2); // Paper
    const coverColor = Color(0xFF5D4037); // Leather Brown

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: 500,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // HEADER (Book Spine Look)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: const BoxDecoration(
                color: coverColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, color: Colors.amber.shade100),
                  const SizedBox(width: 12),
                  Text(
                    "OYUN REHBERİ",
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade100,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            // CONTENT (PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        // Section Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (page['color'] as Color).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page['icon'] as IconData,
                            size: 48,
                            color: page['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          page['title'] as String,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: page['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(
                          color: (page['color'] as Color).withValues(alpha: 0.2),
                          thickness: 1,
                          indent: 60,
                          endIndent: 60,
                        ),
                        const SizedBox(height: 24),

                        // Content
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              page['content'] as String,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // FOOTER (Navigation)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Prev Button
                  if (_currentPage > 0)
                    TextButton.icon(
                      onPressed: _prevPage,
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      label: const Text("GERİ"),
                      style: TextButton.styleFrom(foregroundColor: coverColor),
                    )
                  else
                    const SizedBox(width: 80),

                  // Page Indicator
                  Row(
                    children: List.generate(_pages.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? coverColor
                              : Colors.grey.withValues(alpha: 0.3),
                        ),
                      );
                    }),
                  ),

                  // Next/Close Button
                  if (_currentPage < _pages.length - 1)
                    TextButton.icon(
                      onPressed: _nextPage,
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      label: const Text("İLERİ"),
                      style: TextButton.styleFrom(foregroundColor: coverColor),
                    )
                  else
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text("ANLADIM"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green.shade800,
                        backgroundColor: Colors.green.withValues(alpha: 0.1),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
