import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

/// Unit tests for TurnOrderService and related turn order logic.
///
/// Note: Tests that call TurnOrderService.execute() are omitted because:
/// 1. The service uses AudioManager singleton which requires platform channels
/// 2. Platform channels are not available in unit tests
/// 3. Integration or widget tests are needed for full coverage of execute()
///
/// The tests below verify the state management structures (GameState, GamePhase)
/// which are essential for the turn order logic.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameState - turn order state management', () {
    test('GameState correctly stores turn order data', () {
      // Arrange
      final players = [
        const Player(
          id: 'p1',
          name: 'Alice',
          color: Color(0xFF0000FF),
          iconIndex: 0,
        ),
        const Player(
          id: 'p2',
          name: 'Bob',
          color: Color(0xFFFF0000),
          iconIndex: 1,
        ),
      ];
      final rolls = {'p1': 10, 'p2': 7};

      // Act
      final state = GameState(
        players: players,
        phase: GamePhase.playerTurn,
        orderRolls: rolls,
      );

      // Assert
      expect(state.players.length, 2);
      expect(state.orderRolls['p1'], 10);
      expect(state.orderRolls['p2'], 7);
      expect(state.phase, GamePhase.playerTurn);
    });

    test('GameState copyWith preserves turn order state', () {
      // Arrange
      final initialState = GameState(
        players: const [
          Player(
            id: 'p1',
            name: 'Alice',
            color: Color(0xFF0000FF),
            iconIndex: 0,
          ),
        ],
        phase: GamePhase.rollingForOrder,
        orderRolls: {'p1': 8},
      );

      // Act
      final updatedState = initialState.copyWith(phase: GamePhase.playerTurn);

      // Assert
      expect(updatedState.phase, GamePhase.playerTurn);
      expect(updatedState.orderRolls['p1'], 8); // Preserved
      expect(updatedState.players.first.id, 'p1'); // Preserved
    });

    test('GameState stores all tie-breaker related fields', () {
      // Arrange
      final tieGroups = {
        12: ['p1', 'p2'],
      };
      final finalized = [
        const Player(
          id: 'p3',
          name: 'Charlie',
          color: Color(0xFF00FF00),
          iconIndex: 2,
        ),
      ];
      final pending = [
        const Player(
          id: 'p1',
          name: 'Alice',
          color: Color(0xFF0000FF),
          iconIndex: 0,
        ),
      ];

      // Act
      final state = GameState(
        players: finalized + pending,
        phase: GamePhase.tieBreaker,
        tieBreakerGroups: tieGroups,
        finalizedOrder: finalized,
        pendingTieBreakPlayers: pending,
        tieBreakRound: 2,
        tieBreakRoundRolls: {'p1': 6, 'p2': 6},
      );

      // Assert
      expect(state.phase, GamePhase.tieBreaker);
      expect(state.tieBreakerGroups[12], ['p1', 'p2']);
      expect(state.finalizedOrder.length, 1);
      expect(state.finalizedOrder.first.id, 'p3');
      expect(state.pendingTieBreakPlayers.length, 1);
      expect(state.tieBreakRound, 2);
      expect(state.tieBreakRoundRolls['p1'], 6);
    });

    test('GameState default values for turn order fields', () {
      // Act
      final state = GameState(
        players: const [
          Player(
            id: 'p1',
            name: 'Alice',
            color: Color(0xFF0000FF),
            iconIndex: 0,
          ),
        ],
      );

      // Assert - default values
      expect(state.orderRolls, isEmpty);
      expect(state.tieBreakerGroups, isEmpty);
      expect(state.finalizedOrder, isEmpty);
      expect(state.pendingTieBreakPlayers, isEmpty);
      expect(state.tieBreakRound, 0);
      expect(state.tieBreakRoundRolls, isEmpty);
    });

    test('GameState stores currentPlayerIndex for turn tracking', () {
      // Act
      final state = GameState(
        players: const [
          Player(
            id: 'p1',
            name: 'Alice',
            color: Color(0xFF0000FF),
            iconIndex: 0,
          ),
          Player(id: 'p2', name: 'Bob', color: Color(0xFFFF0000), iconIndex: 1),
        ],
        currentPlayerIndex: 1,
      );

      // Assert
      expect(state.currentPlayerIndex, 1);
    });
  });

  group('GamePhase - turn order phases', () {
    test('rollingForOrder phase exists', () {
      expect(GamePhase.rollingForOrder, isNotNull);
      expect(GamePhase.rollingForOrder.name, 'rollingForOrder');
    });

    test('tieBreaker phase exists', () {
      expect(GamePhase.tieBreaker, isNotNull);
      expect(GamePhase.tieBreaker.name, 'tieBreaker');
    });

    test('playerTurn phase exists', () {
      expect(GamePhase.playerTurn, isNotNull);
      expect(GamePhase.playerTurn.name, 'playerTurn');
    });

    test('setup phase exists', () {
      expect(GamePhase.setup, isNotNull);
      expect(GamePhase.setup.name, 'setup');
    });
  });

  group('Player model - turn order support', () {
    test('Player can be created with required fields for turn order', () {
      // Act
      final player = const Player(
        id: 'p1',
        name: 'Alice',
        color: Color(0xFF0000FF),
        iconIndex: 0,
      );

      // Assert
      expect(player.id, 'p1');
      expect(player.name, 'Alice');
      expect(player.color, const Color(0xFF0000FF));
      expect(player.iconIndex, 0);
    });

    test('Players with different IDs are distinguishable', () {
      // Arrange
      final player1 = const Player(
        id: 'p1',
        name: 'Alice',
        color: Color(0xFF0000FF),
        iconIndex: 0,
      );
      final player2 = const Player(
        id: 'p2',
        name: 'Bob',
        color: Color(0xFFFF0000),
        iconIndex: 1,
      );

      // Assert
      expect(player1.id, isNot(equals(player2.id)));
      expect(player1 == player2, false);
    });

    test('Players can be sorted by properties for turn order', () {
      // Arrange
      final players = [
        const Player(
          id: 'p2',
          name: 'Bob',
          color: Color(0xFFFF0000),
          iconIndex: 1,
        ),
        const Player(
          id: 'p1',
          name: 'Alice',
          color: Color(0xFF0000FF),
          iconIndex: 0,
        ),
      ];

      // Act - sort by name
      final sortedPlayers = List.from(players)
        ..sort((a, b) => a.name.compareTo(b.name));

      // Assert
      expect(sortedPlayers.first.id, 'p1');
      expect(sortedPlayers.last.id, 'p2');
    });
  });
}
