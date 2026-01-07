import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../models/player_type.dart';
import '../models/turn_phase.dart';
import '../widgets/enhanced_dice_widget.dart';
import '../widgets/square_board_widget.dart';
import '../widgets/question_dialog.dart';
import '../widgets/copyright_purchase_dialog.dart';
import '../widgets/turn_summary_overlay.dart';
import '../widgets/card_dialog.dart';
import '../widgets/game_log.dart';
import '../widgets/game_over_dialog.dart';

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
    final currentCard = ref.watch(currentCardProvider);
    final isGameOver = ref.watch(isGameOverProvider);

    // Phase 2 Orchestration Listener - UI-controlled timing
    //
    // Separation of concerns:
    // - GameNotifier: Defines game rules (phase + player type -> directive)
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
      // CRITICAL: Never auto-advance for human players at TurnPhase.start
      if (directive != null) {
        // Guard: Don't auto-play human's turn start phase
        if (directive == 'rollDice' &&
            currentPlayer?.type == PlayerType.human) {
          debugPrint(
            '🛑 Human player at start phase - waiting for manual roll',
          );
          return;
        }

        // Slower delay to allow UI animations to complete
        Future.delayed(const Duration(milliseconds: 1500), () {
          // CRITICAL FIX: Check if widget is still mounted before using ref
          if (!mounted) return;

          final notifier = ref.read(gameProvider.notifier);
          final state = ref.read(gameProvider);

          // SAFETY CHECK: Ensure we still have a directive after delay!
          // This prevents stale timers from auto-playing for humans.
          final freshDirective = notifier.getAutoAdvanceDirective();
          if (freshDirective == null) return;

          notifier.playTurn();
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

    return Scaffold(
      body: Stack(
        children: [
          // STRICT ROW-BASED LANDSCAPE LAYOUT
          // Left: Board (flex: 7), Right: Control Panel (flex: 3)
          Row(
            children: [
              // LEFT PANEL: The Board
              // Wrapped in AspectRatio(1.0) to maintain square shape
              Expanded(
                flex: 7,
                child: Container(
                  padding: EdgeInsets.zero,
                  child: const Center(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: SquareBoardWidget(),
                    ),
                  ),
                ),
              ),

              // RIGHT PANEL: Control Center
              // Strict proportional layout: Header (fixed) + PlayerList (flex) + GameLog (fixed) + Dice (fixed)
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // SECTION 1: HEADER - Current Player Info
                      // Fixed height, no expansion
                      Container(
                        height: 60, // Fixed height for header
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(
                                int.parse(
                                  currentPlayer?.color.replaceFirst(
                                        '#',
                                        '0xFF',
                                      ) ??
                                      '0xFF000000',
                                ),
                              ),
                              child: Text(
                                currentPlayer?.name[0] ?? "?",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentPlayer?.name ?? "...",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (currentPlayer?.type == PlayerType.human)
                                    const Text(
                                      "Senin Sıran",
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (currentPlayer?.type == PlayerType.human)
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade700,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'AKTİF',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      // SECTION 2: BODY - Player List
                      // Fixed height to prevent overlap with GameLog
                      SizedBox(
                        height: 140,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: gameState.players.length,
                          separatorBuilder: (c, i) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final p = gameState.players[index];
                            final isCurrent =
                                index == gameState.currentPlayerIndex;
                            return ListTile(
                              visualDensity: VisualDensity.compact,
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              leading: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Color(
                                    int.parse(
                                      p.color.replaceFirst('#', '0xFF'),
                                    ),
                                  ),
                                  shape: BoxShape.circle,
                                  border: isCurrent
                                      ? Border.all(
                                          color: Colors.black,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    p.name[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      p.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: isCurrent
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.amber.shade600,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    "${p.stars}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isCurrent
                                          ? Colors.brown.shade900
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: isCurrent
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.green.shade700,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'Sıra',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                      ),

                      const Divider(height: 1),

                      // SECTION 2.5: GAME LOG - Activity History
                      // Fixed height compact log viewer
                      SizedBox(
                        height: 70,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: const GameLogWidget(),
                        ),
                      ),

                      const Divider(height: 1),

                      // SECTION 3: FOOTER - Dice Area
                      // Fixed height to complete proportional layout
                      // Total: 60 (header) + 140 (list) + 70 (log) + 120 (dice) = 390px for vertical fill
                      Container(
                        width: double.infinity,
                        height: 120, // Fixed height for dice widget
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // FittedBox safety wrapper - shrinks instead of crashing on overflow
                            const Expanded(
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: EnhancedDiceWidget(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Instruction text
                            Text(
                              turnPhase == TurnPhase.start &&
                                      currentPlayer?.type == PlayerType.human
                                  ? "ZAR AT!"
                                  : "BEKLENİYOR...",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
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

          // Card dialog overlay
          // Show when a card is drawn with strict validation
          // Must be in cardWaiting phase, card must belong to current player, and player must be human
          if (gameState.currentCard != null &&
              gameState.turnPhase == TurnPhase.cardWaiting &&
              gameState.currentCardOwnerId == gameState.currentPlayer?.id &&
              gameState.currentPlayer?.type == PlayerType.human)
            CardDialog(
              key: ValueKey(gameState.currentCard?.id),
              card: gameState.currentCard!,
            ),

          // Phase 4: Turn Summary Overlay - Shows summary of completed turn
          // Visible ONLY during TurnPhase.turnEnded
          // Provides clear, concise summary of what just happened
          if (turnPhase == TurnPhase.turnEnded) const TurnSummaryOverlay(),

          // Phase 6.1: Game Over Dialog - Final overlay showing winner and leaderboard
          // Visible ONLY when game is over (isGameOver == true)
          // Appears on top of all other dialogs to ensure visibility
          // Shows winner, final scores, and restart option
          if (isGameOver) const GameOverDialog(),

          // DEV TOOL: Turn Result Inspector - Debug overlay for turn validation
          // Read-only inspection of lastTurnResult (never writes to game state)
          // Search for "DEV TOOL" to find all temporary debug widgets
          // const TurnResultInspector(), // <--- DISABLED: Was blocking UI interactions
        ],
      ),
    );
  }
}
