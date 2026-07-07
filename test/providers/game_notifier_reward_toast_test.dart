import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/constants/game_constants.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

/// The reward toast pipeline: one entry point ([GameNotifier.showRewardToast]),
/// sticky across unrelated state updates, self-clearing without wiping a
/// newer toast, and anchored to the tile where the reward fired.
void main() {
  const toastDuration = Duration(
    seconds: GameConstants.floatingEffectDurationSeconds,
  );

  GameState baseState({int playerPosition = 0}) {
    return GameState(
      players: [
        Player(
          id: 'p1',
          name: 'Player 1',
          color: Colors.red,
          iconIndex: 0,
          position: playerPosition,
        ),
      ],
      tiles: BoardConfig.tiles,
      phase: GamePhase.gameOver,
    );
  }

  test('toast survives unrelated state updates until its timer fires', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(gameProvider.notifier);
    notifier.updateState(baseState());

    notifier.showRewardToast('+10 Akçe', Colors.amber, title: 'TEST');

    // Unrelated updates (movement steps, dice, logs) must not wipe the toast.
    notifier.updateState(container.read(gameProvider).copyWith(diceTotal: 7));
    notifier.updateState(
      container.read(gameProvider).copyWith(currentPlayerIndex: 0),
    );

    final effect = container.read(gameProvider).floatingEffect;
    expect(effect, isNotNull);
    expect(effect!.text, '+10 Akçe');
  });

  test('clearFloatingEffect removes the toast explicitly', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(gameProvider.notifier);
    notifier.updateState(baseState());

    notifier.showRewardToast('+10 Akçe', Colors.amber);
    expect(container.read(gameProvider).floatingEffect, isNotNull);

    notifier.updateState(
      container.read(gameProvider).copyWith(clearFloatingEffect: true),
    );
    expect(container.read(gameProvider).floatingEffect, isNull);
  });

  test('toast clears itself after its display duration', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(gameProvider.notifier);
    notifier.updateState(baseState());

    notifier.showRewardToast('+10 Akçe', Colors.amber);
    expect(container.read(gameProvider).floatingEffect, isNotNull);

    await Future.delayed(toastDuration + const Duration(milliseconds: 300));
    expect(container.read(gameProvider).floatingEffect, isNull);
  });

  test('an older toast timer never clears a newer toast', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(gameProvider.notifier);
    notifier.updateState(baseState());

    notifier.showRewardToast('first', Colors.amber);

    // Replace it just before the first timer fires.
    await Future.delayed(
      toastDuration - const Duration(milliseconds: 300),
    );
    notifier.showRewardToast('second', Colors.lightBlueAccent);

    // First timer fires here; the second toast must survive it.
    await Future.delayed(const Duration(milliseconds: 600));
    final effect = container.read(gameProvider).floatingEffect;
    expect(effect, isNotNull, reason: 'newer toast wiped by older timer');
    expect(effect!.text, 'second');

    // And the second toast still clears itself on schedule.
    await Future.delayed(toastDuration);
    expect(container.read(gameProvider).floatingEffect, isNull);
  });

  test('toast is anchored to the tile where the reward fired', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(gameProvider.notifier);
    notifier.updateState(baseState(playerPosition: 5));

    notifier.showRewardToast('Telif: Test', Colors.amberAccent);

    final effect = container.read(gameProvider).floatingEffect;
    expect(effect!.anchorTilePosition, 5);
  });
}
