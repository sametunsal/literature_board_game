import 'dart:async';
import 'dart:math';
import '../constants/game_constants.dart';
import '../managers/audio_manager.dart';
import '../../data/board_config.dart';
import '../../models/player.dart';
import '../../models/board_tile.dart';
import '../../providers/game_notifier.dart';

/// Service responsible for handling pawn movement on the board.
class MovementService {
  final Random _random = Random();

  /// Execute a step-by-step movement
  Future<void> executeMovement({
    required GameNotifier notifier,
    required GameState state,
    required int steps,
    required bool isBotPlaying,
    required Future<void> Function(BoardTile tile) onTileArrival,
    required void Function() endTurn,
  }) async {
    notifier.logBot('MovementService.executeMovement() START - steps: $steps');
    try {
      var player = state.currentPlayer;
      notifier.logBot(
        'Current position: ${player.position}, target: ${(player.position + steps) % BoardConfig.boardSize}',
      );

      if (player.inJail) {
        notifier.logBot('Player is in jail');
        if (_random.nextBool()) {
          List<Player> newPlayers = List.from(state.players);
          newPlayers[state.currentPlayerIndex] = player.copyWith(inJail: false);
          notifier.updateState(state.copyWith(players: newPlayers));
          notifier.addLog("Nöbetten erken çıktın!", type: 'success');
        } else {
          notifier.addLog("Hâlâ nöbettesin. Tur geçti.", type: 'error');
          endTurn();
          return;
        }
      }

      // Step-by-step hopping movement
      int currentPos = player.position;

      for (int i = 0; i < steps; i++) {
        currentPos = (currentPos + 1) % BoardConfig.boardSize;

        // Check if passed start
        if (currentPos == BoardConfig.startPosition) {
          // Award stars for passing start
          List<Player> startPlayers = List.from(notifier.currentState.players);
          startPlayers[notifier.currentState.currentPlayerIndex] = player
              .copyWith(stars: player.stars + GameConstants.passingStartBonus);
          notifier.updateState(
            notifier.currentState.copyWith(players: startPlayers),
          );
          player = notifier.currentState.currentPlayer;

          notifier.addLog(
            "Başlangıçtan geçtin: +${GameConstants.passingStartBonus} Yıldız",
            type: 'purchase',
          );
        }

        // Update position for each step
        List<Player> stepPlayers = List.from(notifier.currentState.players);
        stepPlayers[notifier.currentState.currentPlayerIndex] = player.copyWith(
          position: currentPos,
        );
        notifier.updateState(
          notifier.currentState.copyWith(players: stepPlayers),
        );
        player = notifier.currentState.currentPlayer;

        // Wait for hop animation (faster in bot mode)
        final hopDelay = isBotPlaying ? 50 : GameConstants.hopAnimationDelay;
        AudioManager.instance.playSfx('audio/pawn_step.wav');
        await Future.delayed(Duration(milliseconds: hopDelay));
      }

      // SAFETY: Bounds check to prevent crashes if position goes out of bounds
      if (currentPos < 0 || currentPos >= notifier.currentState.tiles.length) {
        notifier.logBot(
          '🚨 CRITICAL ERROR: Out of bounds array sequence detected in MovementService! currentPos: $currentPos, Limit: ${notifier.currentState.tiles.length}',
        );
        notifier.addLog(
          'Ölümcül Hata: Tahta sınırı aşıldı! Başlangıca döndürülüyorsun.',
          type: 'error',
        );
        currentPos = BoardConfig.startPosition; // Safe fallback
      }

      final tile = notifier.currentState.tiles[currentPos];

      notifier.updateState(notifier.currentState.copyWith(currentTile: tile));
      notifier.addLog("${tile.name} karesine gelindi.");
      notifier.logBot('Landed on tile: ${tile.name} (type: ${tile.type})');

      await onTileArrival(tile);
    } catch (e) {
      notifier.addLog('Hareket hatası: $e', type: 'error');
      notifier.logBot('🚨 ERROR in MovementService.executeMovement: $e');
      endTurn();
    }
  }
}
