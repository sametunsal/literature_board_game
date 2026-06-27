import 'dart:math' as math;

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
      'icon': Icons.emoji_events_rounded,
      'color': Color(0xFF6A1B9A),
      'content':
          "Edebina'da ana hedef yayıncılıktır.\n\n"
          '${GameConstants.publishingCiltBooksToWin} Cilt kitaba sahip olan ilk oyuncu oyunu kazanır.\n\n'
          'Söz kartları ve alıntılar koleksiyon tadındadır; kazanma şartı değildir.',
    },
    {
      'title': 'YAYINCILIK',
      'icon': Icons.library_books_rounded,
      'color': Color(0xFF1E3A8A),
      'content':
          'Kitap karelerine gelince soru cevaplanır.\n\n'
          'Sahipsiz bir kitapta doğru cevap verirsen Telif alırsın.\n\n'
          'Kendi kitabını doğru cevaplarla ve Akçe harcayarak geliştirirsin:\n'
          'Telif -> Baskı -> Cilt.',
    },
    {
      'title': 'AKÇE VE USTALIK',
      'icon': Icons.payments_rounded,
      'color': Color(0xFFB7791F),
      'content':
          'Akçe doğru cevaplardan ve bazı bonuslardan kazanılır.\n\n'
          'Baskı, Cilt ve Meşk için Akçe harcarsın. Baskı ve Cilt bedeli kitaba göre değişir.\n\n'
          'Kategoriler doğru cevaplarla ilerler: Acemi, Çırak, Kalfa, Usta.\n\n'
          'Bir kitabı Cilt yapmak için ilgili kategoride en az Kalfa olman gerekir.',
    },
    {
      'title': 'KARELER',
      'icon': Icons.grid_view_rounded,
      'color': Color(0xFF047857),
      'content':
          'Telif, Baskı ve Cilt kareleri yayıncılık yolunu gösterir.\n\n'
          'Royalty karelerinde rakip sahipliği önemlidir: rakibin kitabında yanlış cevap verirsen ödeme yaparsın.\n\n'
          'Akçe kareleri bonus kazandırabilir. Şans ve Kader kartları olumlu ya da olumsuz özel olaylar getirir.\n\n'
          'Kütüphane bekleme/ceza etkisi yaratabilir. Başlangıçtan geçince Akçe bonusu alınır.',
    },
    {
      'title': 'KIRAATHANE',
      'icon': Icons.local_cafe_rounded,
      'color': Color(0xFF8D4B20),
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
    final screenSize = MediaQuery.sizeOf(context);
    final isCompact = screenSize.height < 420 || screenSize.width < 380;
    final dialogWidth = math.max(280.0, math.min(560.0, screenSize.width - 32));
    final dialogHeight = math.max(
      220.0,
      math.min(isCompact ? 360.0 : 540.0, screenSize.height - 32),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.26),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: isCompact ? 9 : 16,
                  horizontal: isCompact ? 14 : 24,
                ),
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
                    Icon(
                      Icons.menu_book,
                      color: Colors.amber.shade100,
                      size: isCompact ? 20 : 24,
                    ),
                    SizedBox(width: isCompact ? 8 : 12),
                    Flexible(
                      child: Text(
                        'OYUN REHBERİ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: isCompact ? 18 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade100,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return _GuidePageCard(
                      title: page['title'] as String,
                      content: page['content'] as String,
                      icon: page['icon'] as IconData,
                      color: page['color'] as Color,
                      isCompact: isCompact,
                    );
                  },
                ),
              ),
              _GuideNavigation(
                currentPage: _currentPage,
                pageCount: _pages.length,
                coverColor: coverColor,
                isCompact: isCompact,
                onPrevious: _prevPage,
                onNext: _nextPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideNavigation extends StatelessWidget {
  const _GuideNavigation({
    required this.currentPage,
    required this.pageCount,
    required this.coverColor,
    required this.isCompact,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int pageCount;
  final Color coverColor;
  final bool isCompact;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = TextButton.styleFrom(
      foregroundColor: coverColor,
      minimumSize: const Size(0, 34),
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 12),
      textStyle: GoogleFonts.poppins(
        fontSize: isCompact ? 11.5 : 12.5,
        fontWeight: FontWeight.w700,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          height: 1,
          thickness: 1,
          indent: isCompact ? 16 : 32,
          endIndent: isCompact ? 16 : 32,
          color: coverColor.withValues(alpha: 0.12),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            isCompact ? 12 : 24,
            isCompact ? 6 : 10,
            isCompact ? 12 : 24,
            isCompact ? 2 : 4,
          ),
          child: DefaultTextStyle(
            style: GoogleFonts.poppins(
              fontSize: isCompact ? 10.5 : 11.5,
              fontWeight: FontWeight.w600,
              color: coverColor.withValues(alpha: 0.56),
            ),
            child: Row(
              children: [
                const Expanded(child: Text('← Kaydır')),
                Text('${currentPage + 1} / $pageCount'),
                const Expanded(
                  child: Text('Kaydır →', textAlign: TextAlign.right),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            isCompact ? 12 : 24,
            0,
            isCompact ? 12 : 24,
            isCompact ? 8 : 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: currentPage > 0
                      ? TextButton.icon(
                          onPressed: onPrevious,
                          icon: const Icon(Icons.arrow_back_ios, size: 15),
                          label: const Text('GERİ'),
                          style: buttonStyle,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              Semantics(
                label: 'Rehber sayfa göstergesi',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(pageCount, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: currentPage == index ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: currentPage == index
                            ? coverColor
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: currentPage < pageCount - 1
                      ? TextButton.icon(
                          onPressed: onNext,
                          icon: const Icon(Icons.arrow_forward_ios, size: 15),
                          label: const Text('İLERİ'),
                          style: buttonStyle,
                        )
                      : TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('ANLADIM'),
                          style: buttonStyle.copyWith(
                            foregroundColor: WidgetStatePropertyAll(
                              Colors.green.shade800,
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              Colors.green.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuidePageCard extends StatefulWidget {
  const _GuidePageCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
    required this.isCompact,
  });

  final String title;
  final String content;
  final IconData icon;
  final Color color;
  final bool isCompact;

  @override
  State<_GuidePageCard> createState() => _GuidePageCardState();
}

class _GuidePageCardState extends State<_GuidePageCard> {
  final ScrollController _scrollController = ScrollController();
  bool _canScroll = false;
  bool _isAtEnd = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollHint);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollHint());
  }

  @override
  void didUpdateWidget(covariant _GuidePageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollHint());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateScrollHint)
      ..dispose();
    super.dispose();
  }

  void _updateScrollHint() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final canScroll = position.maxScrollExtent > 1;
    final isAtEnd = position.pixels >= position.maxScrollExtent - 8;
    if (canScroll != _canScroll || isAtEnd != _isAtEnd) {
      setState(() {
        _canScroll = canScroll;
        _isAtEnd = isAtEnd;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.isCompact;
    final cardPadding = EdgeInsets.fromLTRB(
      compact ? 14 : 24,
      compact ? 12 : 22,
      compact ? 14 : 24,
      compact ? 10 : 18,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 10 : 26,
        compact ? 8 : 24,
        compact ? 10 : 26,
        compact ? 4 : 6,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.color.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.075),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: widget.color.withValues(alpha: 0.05),
              blurRadius: 28,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: cardPadding,
          child: Column(
            children: [
              _GuidePageHeader(
                title: widget.title,
                icon: widget.icon,
                color: widget.color,
                isCompact: compact,
              ),
              SizedBox(height: compact ? 8 : 16),
              Expanded(
                child: Stack(
                  children: [
                    Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: _canScroll,
                      child: SingleChildScrollView(
                        key: const ValueKey('how_to_play_card_scroll_view'),
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(
                          compact ? 2 : 4,
                          compact ? 2 : 4,
                          compact ? 2 : 4,
                          _canScroll ? (compact ? 28 : 34) : 4,
                        ),
                        physics: const ClampingScrollPhysics(),
                        child: _GuideContentBlocks(
                          content: widget.content,
                          color: widget.color,
                          isCompact: compact,
                        ),
                      ),
                    ),
                    if (_canScroll && !_isAtEnd)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0x00FFFFFF), Color(0xF9FFFFFF)],
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: compact ? 18 : 24,
                                bottom: compact ? 1 : 2,
                              ),
                              child: Text(
                                'Devamı için yukarı kaydır',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: compact ? 10.5 : 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: widget.color.withValues(alpha: 0.72),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideContentBlocks extends StatelessWidget {
  const _GuideContentBlocks({
    required this.content,
    required this.color,
    required this.isCompact,
  });

  final String content;
  final Color color;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final blocks = content.split('\n\n');
    final intro = blocks.first;
    final details = blocks.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _IntroBlock(text: intro, color: color, isCompact: isCompact),
        if (details.isNotEmpty) SizedBox(height: isCompact ? 8 : 12),
        for (var index = 0; index < details.length; index++) ...[
          _InfoBlock(
            text: details[index],
            color: color,
            isCompact: isCompact,
            isNote: index == details.length - 1 && details.length > 2,
          ),
          if (index != details.length - 1) SizedBox(height: isCompact ? 8 : 10),
        ],
      ],
    );
  }
}

class _IntroBlock extends StatelessWidget {
  const _IntroBlock({
    required this.text,
    required this.color,
    required this.isCompact,
  });

  final String text;
  final Color color;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 10 : 14,
          vertical: isCompact ? 8 : 12,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: isCompact ? 12.5 : 14.5,
            height: isCompact ? 1.36 : 1.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xF01D1713),
          ),
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.text,
    required this.color,
    required this.isCompact,
    required this.isNote,
  });

  final String text;
  final Color color;
  final bool isCompact;
  final bool isNote;

  @override
  Widget build(BuildContext context) {
    final items = text.split('\n').where((line) => line.trim().isNotEmpty);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isNote
            ? const Color(0xFFF8F5EF)
            : const Color(0xFFFFFFFF).withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isNote
              ? const Color(0xFF5D4037).withValues(alpha: 0.12)
              : color.withValues(alpha: 0.1),
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isCompact ? 10 : 12,
            isCompact ? 8 : 10,
            isCompact ? 10 : 12,
            isCompact ? 8 : 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in items) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: isCompact ? 6 : 7),
                      child: Icon(
                        isNote ? Icons.info_outline_rounded : Icons.circle,
                        size: isNote ? 13 : 6,
                        color: color.withValues(alpha: isNote ? 0.78 : 0.7),
                      ),
                    ),
                    SizedBox(width: isCompact ? 8 : 10),
                    Expanded(
                      child: Text(
                        item.trim(),
                        style: GoogleFonts.poppins(
                          fontSize: isCompact ? 12 : 13.5,
                          height: isCompact ? 1.35 : 1.48,
                          fontWeight: isNote
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: const Color(0xDE1D1713),
                        ),
                      ),
                    ),
                  ],
                ),
                if (item != items.last) SizedBox(height: isCompact ? 6 : 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidePageHeader extends StatelessWidget {
  const _GuidePageHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.isCompact,
  });

  final String title;
  final IconData icon;
  final Color color;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isCompact ? 10 : 14,
          isCompact ? 8 : 12,
          isCompact ? 10 : 14,
          isCompact ? 8 : 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: isCompact ? 34 : 42,
              height: isCompact ? 34 : 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.16)),
              ),
              child: Icon(icon, size: isCompact ? 20 : 24, color: color),
            ),
            SizedBox(width: isCompact ? 10 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: isCompact ? 21 : 28,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  SizedBox(height: isCompact ? 5 : 7),
                  FractionallySizedBox(
                    widthFactor: isCompact ? 0.44 : 0.32,
                    child: Divider(
                      color: color.withValues(alpha: 0.36),
                      thickness: 1.4,
                      height: 1,
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
