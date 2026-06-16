import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/data/game_cards.dart';
import 'package:literature_board_game/models/game_card.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/providers/dialog_provider.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

void main() {
  group('roll-again chance card', () {
    test('clears dice result state and keeps current player on same turn', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      notifier.updateState(
        GameState(
          players: const [
            Player(id: 'p1', name: 'Player 1', color: Colors.red, iconIndex: 0),
            Player(
              id: 'p2',
              name: 'Player 2',
              color: Colors.blue,
              iconIndex: 1,
            ),
          ],
          tiles: BoardConfig.tiles,
          currentPlayerIndex: 0,
          dice1: 3,
          dice2: 4,
          diceTotal: 7,
          isDiceRolled: true,
          isDiceRolling: false,
          phase: GamePhase.playerTurn,
        ),
      );

      final card = GameCards.sansCards.singleWhere(
        (card) => card.effectType == CardEffectType.rollAgain,
      );
      container.read(dialogProvider.notifier).showCard(card);

      notifier.closeCardDialog();

      final state = container.read(gameProvider);
      expect(container.read(dialogProvider).showCardDialog, isFalse);
      expect(state.currentPlayer.id, 'p1');
      expect(state.currentPlayerIndex, 0);
      expect(state.phase, GamePhase.playerTurn);
      expect(state.isDiceRolled, isFalse);
      expect(state.isDiceRolling, isFalse);
      expect(state.diceTotal, 7);
    });
  });
}
