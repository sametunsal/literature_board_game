import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/game_theme.dart';
import '../data/models/literary_quote_model.dart';
import '../data/repositories/quote_repository.dart';
import '../providers/game_notifier.dart';

/// Shop dialog where players can spend stars to buy literary quotes
class ShopDialog extends ConsumerStatefulWidget {
  const ShopDialog({super.key});

  @override
  ConsumerState<ShopDialog> createState() => _ShopDialogState();
}

class _ShopDialogState extends ConsumerState<ShopDialog> {
  final QuoteRepository _quoteRepo = QuoteRepository();
  List<LiteraryQuoteModel> _quotes = [];
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
    setState(() {
      _quotes = quotes;
      _periods = periods;
      _isLoading = false;
    });
  }

  List<LiteraryQuoteModel> get _filteredQuotes {
    if (_selectedPeriod == null) return _quotes;
    return _quotes.where((q) => q.period == _selectedPeriod).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final player = state.currentPlayer;
    final ownedIds = player.inventory.toSet();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        height: 600,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              GameTheme.parchmentColor,
              GameTheme.parchmentColor.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: GameTheme.goldAccent.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(player.stars),

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GameTheme.copperAccent.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.store, color: GameTheme.copperAccent, size: 32),
          const SizedBox(width: 12),
          const Text(
            'KIRAATHANe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: GameTheme.textDark,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: GameTheme.goldAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  '$stars',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
          style: TextStyle(
            color: isSelected ? Colors.white : GameTheme.textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedPeriod = selected ? period : null);
        },
        selectedColor: GameTheme.copperAccent,
        backgroundColor: Colors.white.withValues(alpha: 0.5),
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildQuotesList(Set<String> ownedIds, int playerStars) {
    final quotes = _filteredQuotes;

    if (quotes.isEmpty) {
      return const Center(
        child: Text(
          'Bu dönemde söz bulunmuyor.',
          style: TextStyle(color: GameTheme.textDark),
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
        color: isOwned
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOwned
              ? Colors.green.withValues(alpha: 0.5)
              : GameTheme.copperAccent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          '"${quote.text}"',
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: isOwned ? Colors.grey : GameTheme.textDark,
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isOwned ? Colors.grey : GameTheme.copperAccent,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: GameTheme.goldAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(quote.period, style: const TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ),
        trailing: isOwned
            ? const Icon(Icons.check_circle, color: Colors.green, size: 32)
            : ElevatedButton(
                onPressed: canAfford ? () => _purchaseQuote(quote) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTheme.goldAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16),
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
        backgroundColor: Colors.green,
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
            backgroundColor: GameTheme.copperAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'KAPAT',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
