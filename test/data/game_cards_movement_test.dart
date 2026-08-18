import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/services/card_effect_service.dart';
import 'package:literature_board_game/core/services/economy_service.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/data/game_cards.dart';
import 'package:literature_board_game/models/game_card.dart';
import 'package:literature_board_game/models/player.dart';

/// Regression tests for the Şans/Kader movement cards.
///
/// History: commit d2a6ded deliberately rebalanced all card values
/// (movement 2→1, -2→-1, -3→-2) but the card texts kept communicating the
/// old counts ("2 kare ileri git" while the engine moved 1 tile). These
/// tests pin card text ↔ effect value ↔ applied movement so the three can
/// never drift apart again.
void main() {
  final RegExp kareCountPattern = RegExp(r'(\d+)\s*kare');

  group('card text ↔ movement value consistency', () {
    test('every moveRelative card communicates its exact tile count', () {
      final movementCards = [
        ...GameCards.sansCards,
        ...GameCards.kaderCards,
      ].where((card) => card.effectType == CardEffectType.moveRelative);

      expect(movementCards, isNotEmpty);

      for (final card in movementCards) {
        final match = kareCountPattern.firstMatch(card.description);
        expect(
          match,
          isNotNull,
          reason:
              'moveRelative card must state its tile count: "${card.description}"',
        );
        final communicatedCount = int.parse(match!.group(1)!);
        expect(
          communicatedCount,
          card.value.abs(),
          reason:
              'Card text promises $communicatedCount kare but the effect moves '
              '${card.value.abs()} tiles: "${card.description}"',
        );

        if (card.description.contains('ileri')) {
          expect(
            card.value,
            greaterThan(0),
            reason: '"ileri" card must move forward: "${card.description}"',
          );
        }
        if (card.description.contains('geri')) {
          expect(
            card.value,
            lessThan(0),
            reason: '"geri" card must move backward: "${card.description}"',
          );
        }
      }
    });

    test('Şans movement cards move exactly one tile forward', () {
      final forwardCards = GameCards.sansCards
          .where((card) => card.effectType == CardEffectType.moveRelative)
          .toList();
      expect(forwardCards, hasLength(2));
      for (final card in forwardCards) {
        expect(card.value, 1, reason: card.description);
      }
    });

    test('Kader movement cards move exactly one and two tiles back', () {
      final backwardValues = GameCards.kaderCards
          .where((card) => card.effectType == CardEffectType.moveRelative)
          .map((card) => card.value)
          .toList()
        ..sort();
      expect(backwardValues, [-2, -1]);
    });
  });

  group('moveRelative application trace', () {
    final service = const CardEffectService(EconomyService());

    Player playerAt(int position) => Player(
          id: 'p1',
          name: 'Player 1',
          color: Colors.red,
          iconIndex: 0,
          position: position,
        );

    int destinationOf(GameCard card, int from) {
      final result = service.apply(
        card: card,
        players: [playerAt(from)],
        currentPlayerIndex: 0,
      );
      return result.updatedPlayers[0].position;
    }

    test('forward card moves exactly the communicated count', () {
      final card = GameCards.sansCards.firstWhere(
        (card) => card.effectType == CardEffectType.moveRelative,
      );
      expect(destinationOf(card, 17), 18);
      // Wraps past start back to tile 0.
      expect(destinationOf(card, BoardConfig.boardSize - 1), 0);
    });

    test('one-tile-back card moves exactly one tile', () {
      final card = GameCards.kaderCards.singleWhere(
        (card) => card.description.contains('tekzip'),
      );
      expect(card.value, -1);
      expect(destinationOf(card, 5), 4);
    });

    test('two-tile-back card moves exactly two tiles including board wrap',
        () {
      final card = GameCards.kaderCards.singleWhere(
        (card) => card.description.contains('eleştirildi'),
      );
      expect(card.value, -2);
      expect(destinationOf(card, 10), 8);
      // (1 - 2) % 26 == -1 -> wraps to the last tile.
      expect(destinationOf(card, 1), BoardConfig.boardSize - 1);
    });
  });
}
