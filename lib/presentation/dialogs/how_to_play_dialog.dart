import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/game_constants.dart';

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
      'title': 'GİRİŞ',
      'icon': Icons.auto_stories_rounded,
      'color': Color(0xFF00695C),
      'content':
          "Edebina'da ana hedef yayıncılıktır.\n\n"
          '${GameConstants.publishingCiltBooksToWin} Cilt kitaba sahip olan ilk oyuncu oyunu kazanır.\n\n'
          'Söz kartları ve alıntılar koleksiyon tadındadır; kazanma şartı değildir.',
    },
    {
      'title': 'YAYINCILIK',
      'icon': Icons.library_books_rounded,
      'color': Color(0xFF3949AB),
      'content':
          'Kitap karelerine gelince soru cevaplanır.\n\n'
          'Sahipsiz bir kitapta doğru cevap verirsen Telif alırsın.\n\n'
          'Kendi kitabını doğru cevaplarla ve Akçe harcayarak geliştirirsin:\n'
          'Telif -> Baskı -> Cilt.',
    },
    {
      'title': 'AKÇE VE USTALIK',
      'icon': Icons.trending_up_rounded,
      'color': Color(0xFFD84315),
      'content':
          'Akçe doğru cevaplardan ve bazı bonuslardan kazanılır.\n\n'
          'Baskı, Cilt ve Meşk için Akçe harcarsın. Baskı ve Cilt bedeli kitaba göre değişir.\n\n'
          'Kategoriler doğru cevaplarla ilerler: Acemi, Çırak, Kalfa, Usta.\n\n'
          'Bir kitabı Cilt yapmak için ilgili kategoride en az Kalfa olman gerekir.',
    },
    {
      'title': 'KARELER',
      'icon': Icons.map_rounded,
      'color': Color(0xFF455A64),
      'content':
          'Telif, Baskı ve Cilt kareleri yayıncılık yolunu gösterir.\n\n'
          'Royalty karelerinde rakip sahipliği önemlidir: rakibin kitabında yanlış cevap verirsen ödeme yaparsın.\n\n'
          'Akçe kareleri bonus kazandırabilir. Şans ve Kader kartları olumlu ya da olumsuz özel olaylar getirir.\n\n'
          'Kütüphane bekleme/ceza etkisi yaratabilir. Başlangıçtan geçince Akçe bonusu alınır.',
    },
    {
      'title': 'KIRAATHANE',
      'icon': Icons.local_cafe_rounded,
      'color': Color(0xFF6A1B9A),
      'content':
          'Kıraathane doğrudan Meşk açar.\n\n'
          'Meşk ${GameConstants.meskCostAkce} Akçe tutar. Bir kategori seçer ve soru cevaplarsın.\n\n'
          'Meşk doğru cevapta yalnızca ustalık ilerlemesi verir; Akçe, Telif veya Royalty oluşturmaz.\n\n'
          'Tahtada sahip çipi kitabın sahibini, T/B/C işaretleri de Telif, Baskı ve Cilt seviyesini gösterir.',
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
    const bgColor = Color(0xFFF9F7F2);
    const coverColor = Color(0xFF5D4037);

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
                    'OYUN REHBERİ',
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
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (page['color'] as Color).withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page['icon'] as IconData,
                            size: 48,
                            color: page['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: page['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(
                          color: (page['color'] as Color).withValues(
                            alpha: 0.2,
                          ),
                          thickness: 1,
                          indent: 60,
                          endIndent: 60,
                        ),
                        const SizedBox(height: 24),
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton.icon(
                      onPressed: _prevPage,
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      label: const Text('GERİ'),
                      style: TextButton.styleFrom(foregroundColor: coverColor),
                    )
                  else
                    const SizedBox(width: 80),
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
                  if (_currentPage < _pages.length - 1)
                    TextButton.icon(
                      onPressed: _nextPage,
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      label: const Text('İLERİ'),
                      style: TextButton.styleFrom(foregroundColor: coverColor),
                    )
                  else
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('ANLADIM'),
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
