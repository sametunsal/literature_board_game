import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/game_theme.dart';
import '../../core/constants/game_constants.dart';
import '../../data/models/literary_quote_model.dart';
import '../../data/repositories/quote_repository.dart';
import '../../models/player.dart';
import '../../providers/theme_notifier.dart';

/// Collection screen showing all quotes owned by players, grouped by era
/// Uses Tabs to switch between players
class CollectionScreen extends ConsumerStatefulWidget {
  final List<Player> players;
  final int initialPlayerIndex;

  const CollectionScreen({
    super.key,
    required this.players,
    this.initialPlayerIndex = 0,
  });

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen>
    with SingleTickerProviderStateMixin {
  final QuoteRepository _quoteRepo = QuoteRepository();
  List<LiteraryQuoteModel> _allQuotes = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.players.length,
      initialIndex: widget.initialPlayerIndex.clamp(
        0,
        widget.players.length - 1,
      ),
      vsync: this,
    );
    _loadQuotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadQuotes() async {
    final allQuotes = await _quoteRepo.getAllQuotes();
    if (mounted) {
      setState(() {
        _allQuotes = allQuotes;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final tokens = themeState.tokens;
    final isDark = themeState.isDarkMode;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.surface,
        foregroundColor: tokens.textPrimary,
        elevation: 0,
        title: Text(
          'Koleksiyonlar',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: tokens.accent,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: tokens.accent,
          unselectedLabelColor: tokens.textSecondary,
          indicatorColor: tokens.accent,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: widget.players.map((p) => Tab(text: p.name)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: widget.players.map((player) {
                return _buildPlayerCollection(player, tokens, isDark);
              }).toList(),
            ),
    );
  }

  Widget _buildPlayerCollection(
    Player player,
    ThemeTokens tokens,
    bool isDark,
  ) {
    // Filter quotes for this player
    final ownedQuotes = _allQuotes
        .where((q) => player.collectedQuotes.contains(q.id))
        .toList();

    // Group by era
    final Map<String, List<LiteraryQuoteModel>> quotesByEra = {};
    for (final quote in ownedQuotes) {
      quotesByEra.putIfAbsent(quote.period, () => []).add(quote);
    }

    final totalOwned = ownedQuotes.length;
    final progress = totalOwned / GameConstants.quotesToCollect;

    return Column(
      children: [
        // Progress header
        _buildProgressHeader(player, tokens, isDark, totalOwned, progress),

        // Quotes list
        Expanded(
          child: quotesByEra.isEmpty
              ? _buildEmptyState(tokens, player.name)
              : _buildQuotesList(quotesByEra, tokens, isDark),
        ),
      ],
    );
  }

  Widget _buildProgressHeader(
    Player player,
    ThemeTokens tokens,
    bool isDark,
    int totalOwned,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.collections_bookmark, color: tokens.accent, size: 28),
              const SizedBox(width: 12),
              Text(
                '${player.name} Koleksiyonu',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: tokens.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$totalOwned / ${GameConstants.quotesToCollect} Söz',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: tokens.textSecondary,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: tokens.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: tokens.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? Colors.green : tokens.accent,
                  ),
                ),
              ),
              if (progress >= 1.0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '🎉 50 Söz Hedefine Ulaştın!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeTokens tokens, String playerName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: tokens.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '$playerName henüz söz toplamadı',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kıraathane\'den edebi söz satın alınabilir!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: tokens.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotesList(
    Map<String, List<LiteraryQuoteModel>> quotesByEra,
    ThemeTokens tokens,
    bool isDark,
  ) {
    final eras = quotesByEra.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: eras.length,
      itemBuilder: (context, index) {
        final era = eras[index];
        final quotes = quotesByEra[era]!;
        return _buildEraSection(era, quotes, tokens, isDark);
      },
    );
  }

  Widget _buildEraSection(
    String era,
    List<LiteraryQuoteModel> quotes,
    ThemeTokens tokens,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: GameTheme.goldAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                era,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: GameTheme.goldAccent,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${quotes.length} söz',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: tokens.textSecondary,
              ),
            ),
          ],
        ),
        children: quotes
            .map((quote) => _buildQuoteCard(quote, tokens))
            .toList(),
      ),
    );
  }

  Widget _buildQuoteCard(LiteraryQuoteModel quote, ThemeTokens tokens) {
    return GestureDetector(
      onTap: () => _showQuoteDetail(quote),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tokens.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GameTheme.copperAccent.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${quote.text}"',
              style: GoogleFonts.playfairDisplay(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: tokens.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: GameTheme.copperAccent),
                const SizedBox(width: 6),
                Text(
                  quote.author,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: GameTheme.copperAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show quote detail dialog with full text
  void _showQuoteDetail(LiteraryQuoteModel quote) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                GameTheme.parchmentColor.withValues(alpha: 0.95),
                GameTheme.parchmentColor,
              ],
            ),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    quote.period,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: GameTheme.goldAccent,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Full quote text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    '"${quote.text}"',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Author
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 20,
                    color: GameTheme.copperAccent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    quote.author,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
