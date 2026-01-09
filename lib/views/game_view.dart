import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
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
  bool _isDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final currentPlayer = gameState.currentPlayer;
    final turnPhase = ref.watch(turnPhaseProvider);
    final currentCard = ref.watch(currentCardProvider);
    final isGameOver = ref.watch(isGameOverProvider);

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
          Row(
            children: [
              // LEFT PANEL: The Board
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
                      Container(
                        height: 60,
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Divider(height: 30),

                      // SECTION 2: BODY - Player List
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
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade700,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.green.shade700,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Sıra',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 1),

                      // SECTION 2.5: GAME LOG - Activity History
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
                      Container(
                        width: double.infinity,
                        height: 120,
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
                            const Expanded(
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: EnhancedDiceWidget(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              turnPhase == TurnPhase.start
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

          // Copyright purchase dialog overlay
          if (turnPhase == TurnPhase.copyrightPurchased &&
              currentPlayer != null &&
              gameState.newPosition != null)
            CopyrightPurchaseDialog(
              tile: gameState.tiles.firstWhere(
                (t) => t.id == gameState.newPosition,
              ),
            ),

          // Phase 4: Turn Summary Overlay - Shows summary of completed turn
          if (turnPhase == TurnPhase.turnEnded) const TurnSummaryOverlay(),

          // Phase 6.1: Game Over Dialog - Final overlay showing winner and leaderboard
          if (isGameOver) const GameOverDialog(),
        ],
      ),
    );
  }
}
