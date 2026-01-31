import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/literary_quote_model.dart';
import '../../data/repositories/quote_repository.dart';
import '../../providers/game_notifier.dart';

/// Shop dialog where players can spend stars to buy literary quotes
/// Features rotating stock system - shows only 6 random unowned quotes each visit
class ShopDialog extends ConsumerStatefulWidget {
  const ShopDialog({super.key});

  @override
  ConsumerState<ShopDialog> createState() => _ShopDialogState();
}

class _ShopDialogState extends ConsumerState<ShopDialog> {
  final QuoteRepository _quoteRepo = QuoteRepository();
  final _random = Random();

  List<LiteraryQuoteModel> _dailyQuotes =
      []; // Rotating stock - only 6 quotes shown
  String? _selectedPeriod;
  List<String> _periods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    final quotes = await _quoteRepo.getAllQuotes();
    final periods = await _quoteRepo.getAllPeriods();

    // Get current player to filter owned quotes
    final state = ref.read(gameProvider);
    final ownedIds = state.currentPlayer.collectedQuotes.toSet();

    // Filter out already owned quotes
    final availableQuotes = quotes
        .where((q) => !ownedIds.contains(q.id))
        .toList();

    // Shuffle available quotes for randomness
    availableQuotes.shuffle(_random);

    // Take top 6 (or fewer if not enough available)
    final dailyStock = availableQuotes.take(6).toList();

    setState(() {
      _dailyQuotes = dailyStock;
      _periods = periods;
      _isLoading = false;
    });
  }

  List<LiteraryQuoteModel> get _filteredQuotes {
    // Filter daily stock by period if selected
    if (_selectedPeriod == null) return _dailyQuotes;
    return _dailyQuotes.where((q) => q.period == _selectedPeriod).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final player = state.currentPlayer;
    final ownedIds = player.collectedQuotes.toSet();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(player.stars),

            // Daily Selection Banner
            _buildDailyBanner(),

            // Period Filter
            _buildPeriodFilter(),

            // Quotes List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildQuotesList(ownedIds, player.stars),
            ),

            // Close Button
            _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int stars) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(Icons.store_rounded, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          Text(
            'KIRAATHANE',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  '$stars',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: Colors.purple.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '📚 Günün Nadide Eserleri',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Tümü', null),
          ..._periods.map((p) => _buildFilterChip(p, p)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? period) {
    final isSelected = _selectedPeriod == period;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedPeriod = selected ? period : null);
        },
        selectedColor: Colors.amber,
        backgroundColor: Colors.grey.shade100,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildQuotesList(Set<String> ownedIds, int playerStars) {
    final quotes = _filteredQuotes;

    if (quotes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.celebration_rounded,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Tebrikler! Tüm eserleri topladın.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '🏆 EHİL oldun!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.amber.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quotes.length,
      itemBuilder: (context, index) {
        final quote = quotes[index];
        final isOwned = ownedIds.contains(quote.id);
        final canAfford = playerStars >= quote.starCost;

        return _buildQuoteCard(quote, isOwned, canAfford);
      },
    );
  }

  Widget _buildQuoteCard(
    LiteraryQuoteModel quote,
    bool isOwned,
    bool canAfford,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          '"${quote.text}"',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Text(
                '— ${quote.author}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  quote.period,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: isOwned
            ? Icon(Icons.check_circle_rounded, color: Colors.green, size: 28)
            : ElevatedButton(
                onPressed: canAfford ? () => _purchaseQuote(quote) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford
                      ? Colors.amber
                      : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('${quote.starCost}'),
                  ],
                ),
              ),
      ),
    );
  }

  void _purchaseQuote(LiteraryQuoteModel quote) {
    ref.read(gameProvider.notifier).purchaseQuote(quote.id, quote.starCost);

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${quote.author} sözü satın alındı!'),
        backgroundColor: Colors.amber,
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {}); // Refresh UI
  }

  Widget _buildCloseButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            ref.read(gameProvider.notifier).closeShopDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'KAPAT',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
