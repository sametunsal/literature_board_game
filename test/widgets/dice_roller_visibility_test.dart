import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/data/game_cards.dart';
import 'package:literature_board_game/models/game_card.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/presentation/widgets/dice_roller.dart';
import 'package:literature_board_game/providers/dialog_provider.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('roll button is visible before rolling', (tester) async {
    final container = _containerWith(_gameState());
    addTearDown(container.dispose);

    await tester.pumpWidget(_app(container));

    expect(find.text('ZAR AT'), findsWidgets);
  });

  testWidgets('roll button is unavailable during dice rolling', (tester) async {
    final container = _containerWith(_gameState(isDiceRolling: true));
    addTearDown(container.dispose);

    await tester.pumpWidget(_app(container));

    expect(find.text('ZAR AT'), findsNothing);
  });

  testWidgets('roll button is unavailable after roll result is produced', (
    tester,
  ) async {
    final container = _containerWith(
      _gameState(dice1: 3, dice2: 4, diceTotal: 7, isDiceRolled: true),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_app(container));

    expect(find.text('ZAR AT'), findsNothing);
  });

  testWidgets('roll-again card restores roll button for same player', (
    tester,
  ) async {
    final container = _containerWith(
      _gameState(dice1: 3, dice2: 4, diceTotal: 7, isDiceRolled: true),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_app(container));
    expect(find.text('ZAR AT'), findsNothing);

    final card = GameCards.sansCards.singleWhere(
      (card) => card.effectType == CardEffectType.rollAgain,
    );
    container.read(dialogProvider.notifier).showCard(card);
    container.read(gameProvider.notifier).closeCardDialog();

    await tester.pump();

    expect(container.read(gameProvider).currentPlayer.id, 'p1');
    expect(container.read(gameProvider).isDiceRolled, isFalse);
    expect(find.text('ZAR AT'), findsWidgets);
  });
}

ProviderContainer _containerWith(GameState state) {
  final container = ProviderContainer();
  container.read(gameProvider.notifier).updateState(state);
  return container;
}

Widget _app(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      home: Scaffold(body: Center(child: DiceRoller())),
    ),
  );
}

GameState _gameState({
  int dice1 = 0,
  int dice2 = 0,
  int diceTotal = 0,
  bool isDiceRolled = false,
  bool isDiceRolling = false,
}) {
  return GameState(
    players: const [
      Player(id: 'p1', name: 'Player 1', color: Colors.red, iconIndex: 0),
      Player(id: 'p2', name: 'Player 2', color: Colors.blue, iconIndex: 1),
    ],
    tiles: BoardConfig.tiles,
    currentPlayerIndex: 0,
    dice1: dice1,
    dice2: dice2,
    diceTotal: diceTotal,
    isDiceRolled: isDiceRolled,
    isDiceRolling: isDiceRolling,
    phase: GamePhase.playerTurn,
  );
}
