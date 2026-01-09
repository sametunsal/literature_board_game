import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../models/turn_phase.dart';
import '../models/player.dart';
import '../widgets/board_widget.dart';
import '../widgets/player_info_panel.dart';
import '../widgets/game_log.dart';
import '../widgets/question_dialog.dart';
import '../widgets/card_dialog.dart';

class BoardView extends ConsumerWidget {
  const BoardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final currentPlayer = ref.watch(currentPlayerProvider);
    final isGameOver = ref.watch(isGameOverProvider);

    // Dialog Listeners
    ref.listen(gameProvider, (previous, next) {
      // Soru Dialog Tetikleyicisi
      // Sadece 'questionWaiting' fazına YENİ geçildiğinde çalışır.
      final didPhaseChangeToQuestion =
          previous?.turnPhase != TurnPhase.questionWaiting &&
          next.turnPhase == TurnPhase.questionWaiting;

      if (didPhaseChangeToQuestion && next.currentQuestion != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => QuestionDialog(
            question: next.currentQuestion!,
            onAnswer: (isCorrect) {
              Navigator.of(context).pop(); // Pencereyi kapat
              // Cevabı işle
              if (isCorrect) {
                ref.read(gameProvider.notifier).answerQuestionCorrect();
              } else {
                ref.read(gameProvider.notifier).answerQuestionWrong();
              }
            },
          ),
        );
      }

      // Kart Dialog Tetikleyicisi
      // Sadece 'cardWaiting' fazına YENİ geçildiğinde çalışır.
      final didPhaseChangeToCard =
          previous?.turnPhase != TurnPhase.cardWaiting &&
          next.turnPhase == TurnPhase.cardWaiting;

      if (didPhaseChangeToCard && next.currentCard != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => CardDialog(
            card: next.currentCard!,
            onDismiss: () {
              Navigator.of(context).pop();
              ref
                  .read(gameProvider.notifier)
                  .applyCardEffect(next.currentCard!);
            },
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFD7CCC8),
      appBar: AppBar(
        title: const Text('Edebiyat Oyunu'),
        backgroundColor: Colors.brown[800],
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              isGameOver
                  ? "OYUN BİTTİ"
                  : "Sıra: ${currentPlayer?.name ?? '...'}",
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildPlayersInfoBar(gameState.players, currentPlayer),
              Expanded(
                child: Row(
                  children: [
                    const Expanded(flex: 2, child: GameLogWidget()),
                    const Expanded(flex: 5, child: BoardWidget()),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          if (currentPlayer != null)
                            PlayerInfoPanel(player: currentPlayer),
                          const Spacer(),
                          _buildControlPanel(ref, gameState),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (gameState.turnPhase == TurnPhase.turnEnded)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(gameProvider.notifier).startNextTurn(),
                    child: const Text("Sıradaki Oyuncu"),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayersInfoBar(List<Player> players, Player? currentPlayer) {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: players.map((player) {
          final isTurn = player.id == currentPlayer?.id;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: isTurn
                  ? Border(
                      bottom: BorderSide(color: Colors.brown[800]!, width: 4),
                    )
                  : null,
              color: player.isBankrupt ? Colors.grey[300] : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("${player.stars} Yıldız"),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildControlPanel(WidgetRef ref, GameState state) {
    final canRoll = state.turnPhase == TurnPhase.start && !state.isGameOver;
    return ElevatedButton.icon(
      icon: const Icon(Icons.casino),
      label: const Text("ZAR AT"),
      style: ElevatedButton.styleFrom(
        backgroundColor: canRoll ? Colors.green : Colors.grey,
      ),
      onPressed: canRoll
          ? () => ref.read(gameProvider.notifier).rollDice()
          : null,
    );
  }
}
