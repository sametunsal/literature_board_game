import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import '../models/turn_phase.dart';
import '../widgets/enhanced_tile_widget.dart';
import '../widgets/enhanced_dice_widget.dart';
import '../widgets/question_dialog.dart';
import '../widgets/copyright_purchase_dialog.dart';
import '../widgets/turn_summary_overlay.dart';
import '../widgets/turn_result_inspector.dart'; // DEV TOOL: Turn Result Inspector

class GameView extends ConsumerStatefulWidget {
  const GameView({super.key});

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> {
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final currentPlayer = gameState.currentPlayer;
    final questionState = ref.watch(questionStateProvider);
    final currentQuestion = ref.watch(currentQuestionProvider);
    final turnPhase = ref.watch(turnPhaseProvider);

    // Phase 2 Orchestration Listener - UI-controlled timing
    //
    // Separation of concerns:
    // - GameNotifier: Defines game rules (phase + player type → directive)
    // - UI: Controls timing execution (uses directive.delay)
    //
    // UI must NOT know about bot logic or delay categories.
    // UI only asks GameNotifier what to do based on current state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ask GameNotifier for auto-advance directive
      // GameNotifier decides based on phase + player type (including bot logic)
      final directive = ref
          .read(gameProvider.notifier)
          .getAutoAdvanceDirective();

      debugPrint('🎮 Auto-advance directive: $directive, Phase: $turnPhase');

      // Execute timing based on directive from GameNotifier
      // Auto-advance for both human and bot players
      if (directive != null) {
        // Slower delay to allow UI animations to complete
        Future.delayed(const Duration(milliseconds: 1500), () {
          debugPrint('🎮 Auto-advancing playTurn() for directive: $directive');
          ref.read(gameProvider.notifier).playTurn();
        });
      }
    });

    // Check if game is initialized
    if (gameState.tiles.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Edebiyat Oyunu',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Oyun yükleniyor...', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );
    }

    final tileCount = gameState.tiles.length;
    final currentPos = currentPlayer?.position;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edebiyat Oyunu',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Oyun tahtası - Horizontal scrollable with enhanced tiles
              // Note: Corner tiles (indices 0, 10, 20, 30) are 1.5x larger
              SizedBox(
                height: 180, // Accommodate larger corner tiles
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: tileCount,
                  itemBuilder: (context, index) {
                    final tile = gameState.tiles[index];
                    final isCurrent =
                        currentPos != null && currentPos == tile.id;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 4,
                      ),
                      child: EnhancedTileWidget(
                        tile: tile,
                        isHighlighted: isCurrent,
                        onTap: () {
                          // Handle tile tap if needed
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Enhanced dice widget and player info
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Enhanced Dice Widget
                      const EnhancedDiceWidget(),
                      const SizedBox(height: 16),

                      // Player cards
                      ...gameState.players.asMap().entries.map((entry) {
                        return _buildPlayerCard(
                          player: entry.value,
                          isCurrent:
                              currentPlayer != null &&
                              entry.value.id == currentPlayer.id,
                          ref: ref,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Question dialog overlay
          // Phase 3: UI is passive observer, QuestionDialog handles orchestration internally
          if (questionState == QuestionState.answering &&
              currentQuestion != null)
            QuestionDialog(question: currentQuestion),

          // Copyright purchase dialog overlay
          // Show when phase is copyrightPurchased
          if (turnPhase == TurnPhase.copyrightPurchased &&
              currentPlayer != null &&
              gameState.newPosition != null)
            CopyrightPurchaseDialog(
              tile: gameState.tiles.firstWhere(
                (t) => t.id == gameState.newPosition,
              ),
            ),

          // Phase 4: Turn Summary Overlay - Shows summary of completed turn
          // Visible ONLY during TurnPhase.turnEnded
          // Provides clear, concise summary of what just happened
          const TurnSummaryOverlay(),

          // DEV TOOL: Turn Result Inspector - Debug overlay for turn validation
          // ONLY visible in debug mode (kDebugMode == true)
          // Read-only inspection of lastTurnResult (never writes to game state)
          // Search for "DEV TOOL" to find all temporary debug widgets
          const TurnResultInspector(),
        ],
      ),
    );
  }

  Widget _buildPlayerCard({
    required Player player,
    required bool isCurrent,
    required WidgetRef ref,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.green.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? Colors.green.shade700 : Colors.black12,
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player name with color indicator
          Row(
            children: [
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
              Expanded(
                child: Text(
                  player.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCurrent ? Colors.green.shade900 : Colors.black87,
                  ),
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'AKTİF',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Player stats with animated stars
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.star,
                  label: 'Yıldız',
                  value: '${player.stars}',
                  color: Colors.amber,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.location_on,
                  label: 'Pozisyon',
                  value: '${player.position}',
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.casino,
                  label: 'Son Zar',
                  value: player.lastRoll?.toString() ?? '-',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
