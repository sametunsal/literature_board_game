import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../models/turn_phase.dart';
import '../models/turn_result.dart';
import '../models/player_type.dart';
import '../models/turn_history.dart';
import '../providers/game_provider.dart';
import '../utils/turn_summary_generator.dart';

/// Turn Summary Overlay - Player-facing turn summary
///
/// Shows a clear, concise summary of the last completed turn.
/// This is NOT a debug tool - it's real game UI.
///
/// When to Show:
/// - Overlay appears only when TurnPhase == turnEnded
/// - After summary is dismissed, game proceeds normally
/// - Bot turns auto-dismiss after a short delay (~800ms)
///
/// Data Source:
/// - Reads from gameProvider.state.lastTurnResult
/// - Does NOT create new models or modify existing ones
///
/// Visual Style:
/// - Clean, readable, non-debug
/// - Semi-transparent dark background
/// - Centered card
/// - Clear hierarchy (dice → movement → result)
/// - Mobile-first layout
class TurnSummaryOverlay extends ConsumerStatefulWidget {
  const TurnSummaryOverlay({super.key});

  @override
  ConsumerState<TurnSummaryOverlay> createState() => _TurnSummaryOverlayState();
}

class _TurnSummaryOverlayState extends ConsumerState<TurnSummaryOverlay> {
  bool _isVisible = false;
  bool _showDebugTimeline = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final turnPhase = ref.watch(turnPhaseProvider);
    final gameState = ref.watch(gameProvider);

    // Check if we should show the overlay
    final shouldShow =
        turnPhase == TurnPhase.turnEnded &&
        gameState.lastTurnResult.playerIndex >= 0;

    // Get the player who completed the turn (not necessarily the current player)
    final turnPlayerIndex = gameState.lastTurnResult.playerIndex;
    final turnPlayer =
        turnPlayerIndex >= 0 && turnPlayerIndex < gameState.players.length
        ? gameState.players[turnPlayerIndex]
        : null;

    if (shouldShow && !_isVisible) {
      setState(() {
        _isVisible = true;
      });

      // Auto-dismiss for bot players after 600-800ms
      // Check the turn player type, not current player
      if (turnPlayer?.type == PlayerType.bot) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted && _isVisible) {
            _handleContinue();
          }
        });
      }
    } else if (!shouldShow && _isVisible) {
      setState(() {
        _isVisible = false;
      });
    }
  }

  void _handleContinue() {
    // Close the overlay
    setState(() {
      _isVisible = false;
    });

    // CRITICAL FIX: Call startNextTurn() to advance to the next player
    // This allows the turn summary to be shown before the game continues
    ref.read(gameProvider.notifier).startNextTurn();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final lastTurnResult = gameState.lastTurnResult;
    final currentPlayer = gameState.currentPlayer;
    final turnHistory = gameState.turnHistory;

    // Don't show if no valid turn result or not visible
    if (!_isVisible || lastTurnResult.playerIndex < 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      // Block taps outside from dismissing
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 16),

                // Debug toggle (debug mode only)
                if (kDebugMode) ...[
                  _buildDebugToggle(),
                  const SizedBox(height: 12),
                ],

                // Turn summaries (scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: _buildTurnSummaries(turnHistory, gameState),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Continue button (human players only)
                if (currentPlayer?.type != PlayerType.bot)
                  _buildContinueButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTurnSummaries(
    TurnHistory turnHistory,
    GameState gameState,
  ) {
    final List<Widget> summaries = [];

    // Get all turns in chronological order (most recent first)
    final turns = turnHistory.all.reversed.toList();

    for (int i = 0; i < turns.length; i++) {
      final turnResult = turns[i];
      final turnNumber = turnHistory.totalTurns - i;

      // Get player who completed the turn
      final player = turnResult.playerIndex < gameState.players.length
          ? gameState.players[turnResult.playerIndex]
          : null;

      // Get tile name
      String? tileName;
      if (gameState.tiles.isNotEmpty) {
        try {
          final tile = gameState.tiles.firstWhere(
            (t) => t.id == turnResult.endPosition,
          );
          tileName = tile.name;
        } catch (e) {
          // Tile not found, continue without it
        }
      }

      // Generate summary text
      final summaryText = TurnSummaryGenerator.generateTurnSummary(
        turnResult,
        playerName: player?.name,
        tileName: tileName,
      );

      summaries.add(
        _buildTurnSummaryCard(
          turnNumber: turnNumber,
          player: player,
          summaryText: summaryText,
          turnResult: turnResult,
          isLast: i == 0, // Most recent turn
        ),
      );

      if (i < turns.length - 1) {
        summaries.add(const SizedBox(height: 12));
      }
    }

    return summaries;
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tur Özeti',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.brown.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${ref.watch(turnHistoryProvider).totalTurns} Tur',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.brown.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDebugToggle() {
    return Row(
      children: [
        Icon(
          Icons.bug_report,
          size: 16,
          color: _showDebugTimeline
              ? Colors.orange.shade700
              : Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Switch(
          value: _showDebugTimeline,
          onChanged: (value) {
            setState(() {
              _showDebugTimeline = value;
            });
          },
        ),
        const SizedBox(width: 8),
        Text(
          'Detaylı Zaman Çizelgesi',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildTurnSummaryCard({
    required int turnNumber,
    required Player? player,
    required String summaryText,
    required TurnResult turnResult,
    required bool isLast,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLast ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLast ? Colors.blue.shade200 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Turn number and player header
          Row(
            children: [
              if (player != null) ...[
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(player.color.substring(1), radix: 16) +
                          0xFF000000,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                'Tur $turnNumber',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              if (player != null) ...[
                const SizedBox(width: 4),
                Text(
                  '- ${player.name}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              const Spacer(),
              if (isLast)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Son',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Summary text
          Text(
            summaryText,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),

          // Highlight changes
          _buildChangeHighlights(turnResult),

          // Debug timeline (if enabled)
          if (_showDebugTimeline &&
              turnResult.transcript.events.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDebugTimeline(turnResult.transcript),
          ],
        ],
      ),
    );
  }

  Widget _buildChangeHighlights(TurnResult result) {
    final highlights = <Widget>[];

    // Stars change
    if (result.starsDelta != 0) {
      final isPositive = result.starsDelta > 0;
      highlights.add(
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPositive ? Colors.green.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositive ? Icons.add : Icons.remove,
                size: 14,
                color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                '${isPositive ? "+" : ""}${result.starsDelta} ⭐',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPositive
                      ? Colors.green.shade900
                      : Colors.red.shade900,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Position change
    if (result.startPosition != result.endPosition) {
      highlights.add(
        Container(
          margin: const EdgeInsets.only(top: 6, left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.route, size: 14, color: Colors.blue.shade700),
              const SizedBox(width: 4),
              Text(
                '${result.startPosition} → ${result.endPosition}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Special events (question, tax, double)
    if (result.questionAnsweredCorrectly != null) {
      final isCorrect = result.questionAnsweredCorrectly!;
      highlights.add(
        Container(
          margin: const EdgeInsets.only(top: 6, left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                size: 14,
                color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                isCorrect ? 'Doğru' : 'Yanlış',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isCorrect
                      ? Colors.green.shade900
                      : Colors.red.shade900,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (result.taxPaid == true) {
      highlights.add(
        Container(
          margin: const EdgeInsets.only(top: 6, left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.attach_money, size: 14, color: Colors.orange.shade700),
              const SizedBox(width: 4),
              Text(
                'Vergi',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (result.isDouble) {
      highlights.add(
        Container(
          margin: const EdgeInsets.only(top: 6, left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.casino, size: 14, color: Colors.purple.shade700),
              const SizedBox(width: 4),
              Text(
                'Çift Zar',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple.shade900,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Phase 3: Copyright purchased
    for (final event in result.transcript.events) {
      if (event.type == TurnEventType.copyrightPurchased) {
        final tileName =
            event.data['tileName'] as String? ?? 'Bilinmeyen Kutucuk';
        highlights.add(
          Container(
            margin: const EdgeInsets.only(top: 6, left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.copyright,
                  size: 14,
                  color: Colors.deepPurple.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  'Telif: $tileName',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple.shade900,
                  ),
                ),
              ],
            ),
          ),
        );
        break; // Only show once per turn
      }
    }

    // Phase 3: Rent paid
    for (final event in result.transcript.events) {
      if (event.type == TurnEventType.rentPaid) {
        final tileName =
            event.data['tileName'] as String? ?? 'Bilinmeyen Kutucuk';
        final amount = event.data['amount'] as int? ?? 0;
        highlights.add(
          Container(
            margin: const EdgeInsets.only(top: 6, left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.money_off,
                  size: 14,
                  color: Colors.deepOrange.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  'Kira: $tileName (-$amount)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepOrange.shade900,
                  ),
                ),
              ],
            ),
          ),
        );
        break; // Only show once per turn
      }
    }

    // Phase 3: Bonus received
    for (final event in result.transcript.events) {
      if (event.type == TurnEventType.bonusReceived) {
        final tileName =
            event.data['tileName'] as String? ?? 'Bilinmeyen Kutucuk';
        final amount = event.data['amount'] as int? ?? 0;
        highlights.add(
          Container(
            margin: const EdgeInsets.only(top: 6, left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.lightGreen.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.card_giftcard,
                  size: 14,
                  color: Colors.lightGreen.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  'Bonus: $tileName (+$amount)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.lightGreen.shade900,
                  ),
                ),
              ],
            ),
          ),
        );
        break; // Only show once per turn
      }
    }

    if (highlights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(spacing: 6, runSpacing: 6, children: highlights);
  }

  Widget _buildDebugTimeline(TurnTranscript transcript) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zaman Çizelgesi',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade400,
            ),
          ),
          const SizedBox(height: 6),
          ...transcript.events.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.description ?? event.type.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade300,
                        height: 1.3,
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

  Widget _buildPlayerHeader(Player player) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Color(
              int.parse(player.color.substring(1), radix: 16) + 0xFF000000,
            ),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            player.name,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Oyuncu $lastTurnPlayerIndex',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiceResult(TurnResult result) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎲', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(
            '${result.diceTotal}',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade900,
            ),
          ),
          if (result.isDouble) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade500,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ÇİFT!',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMovementSummary(TurnResult result) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Text(
            '${result.startPosition}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          Icon(Icons.arrow_forward, color: Colors.blue.shade700, size: 16),
          const SizedBox(width: 4),
          Text(
            '${result.endPosition}',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarsChange(TurnResult result) {
    final delta = result.starsDelta;
    final isPositive = delta >= 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive ? Colors.green.shade300 : Colors.red.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPositive ? Icons.star : Icons.star_border,
            color: isPositive ? Colors.amber.shade600 : Colors.red.shade700,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            '${isPositive ? "+" : ""}$delta',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green.shade900 : Colors.red.shade900,
            ),
          ),
          const SizedBox(width: 4),
          Text('⭐', style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildTileInfo(Tile tile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            _getTileIcon(tile.type),
            color: Colors.orange.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tile.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getTileTypeLabel(tile.type),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionResult(TurnResult result) {
    final isCorrect = result.questionAnsweredCorrectly ?? false;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCorrect ? Colors.green.shade300 : Colors.red.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isCorrect ? 'Doğru cevap' : 'Yanlış cevap',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isCorrect ? Colors.green.shade900 : Colors.red.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxResult(TurnResult result) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade300, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_money, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Text(
            '💸 Vergi ödendi',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseFlow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPhaseStep('Zar', true),
        _buildPhaseArrow(),
        _buildPhaseStep('Hareket', true),
        _buildPhaseArrow(),
        _buildPhaseStep('Çözüm', true),
        _buildPhaseArrow(),
        _buildPhaseStep('Bitiş', true),
      ],
    );
  }

  Widget _buildPhaseStep(String label, bool completed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: completed ? Colors.brown.shade700 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: completed ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildPhaseArrow() {
    return Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20);
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Devam',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  int get lastTurnPlayerIndex {
    final result = ref.watch(lastTurnResultProvider);
    return result.playerIndex + 1; // Display as 1-indexed
  }

  IconData _getTileIcon(TileType type) {
    switch (type) {
      case TileType.corner:
        return Icons.crop_square;
      case TileType.book:
        return Icons.menu_book;
      case TileType.publisher:
        return Icons.business;
      case TileType.chance:
        return Icons.auto_awesome;
      case TileType.fate:
        return Icons.psychology;
      case TileType.tax:
        return Icons.account_balance;
      case TileType.special:
        return Icons.star;
    }
  }

  String _getTileTypeLabel(TileType type) {
    switch (type) {
      case TileType.corner:
        return 'Özel Kutucuk';
      case TileType.book:
        return 'Kitap';
      case TileType.publisher:
        return 'Yayınevi';
      case TileType.chance:
        return 'Şans Kartı';
      case TileType.fate:
        return 'Kader Kartı';
      case TileType.tax:
        return 'Vergi';
      case TileType.special:
        return 'Özel';
    }
  }
}
