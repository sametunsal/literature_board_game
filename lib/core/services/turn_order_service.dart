import 'dart:async';
import 'dart:math';
import '../../models/player.dart';
import '../../models/game_enums.dart';
import '../../core/utils/logger.dart';
import '../managers/audio_manager.dart';
import '../../providers/game_notifier.dart';
import '../../providers/dialog_provider.dart';

class TurnOrderService {
  final _random = Random();

  /// Start the fully automated turn order determination.
  /// This method handles EVERYTHING - initial rolls, tie detection, and recursive tie-breaks.
  /// No user interaction required until the final order is displayed.
  Future<void> execute(
    GameNotifier notifier, {
    List<Player>? playersToRoll,
    int depth = 0,
  }) async {
    // Prevent re-entry at root level
    if (notifier.isProcessing && depth == 0) {
      notifier.logBot('startAutomatedTurnOrder() BLOCKED - already processing');
      return;
    }
    if (depth == 0) notifier.setProcessing(true);

    try {
      // Access generic state
      var state = notifier.currentState;

      final candidates = playersToRoll ?? state.players;
      final isRootCall = depth == 0;
      final isTieBreak = depth > 0;

      // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
      // PHASE 1: LOG START & SWITCH TO GAME BGM
      // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
      if (isRootCall) {
        // Switch to in-game BGM (seamless transition from menu music)
        await AudioManager.instance.playInGameBgm();

        notifier.addLog(
          'ğŸ² Otomatik sÄ±ra belirleme baÅŸlÄ±yor...',
          type: 'dice',
        );
        state = state.copyWith(
          phase: GamePhase.rollingForOrder,
          orderRolls: {},
          lastAction: 'SÄ±ra belirleniyor - TÃ¼m oyuncular zar atÄ±yor...',
        );
        notifier.updateState(state);
      } else {
        final tiedNames = candidates.map((p) => p.name).join(', ');
        notifier.addLog(
          'ğŸ”„ Beraberlik! $tiedNames iÃ§in $depth. tie-break turu...',
          type: 'warning',
        );
        state = state.copyWith(
          phase: GamePhase.tieBreaker,
          tieBreakRound: depth,
          lastAction: 'ğŸ”„ Tie-break: $tiedNames tekrar atÄ±yor...',
        );
        notifier.updateState(state);
      }

      // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
      // PHASE 2: AUTO-ROLL ALL CANDIDATES (Sequential with Animation)
      // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
      final Map<String, int> roundRolls = {}; // Rolls for THIS round only

      for (int i = 0; i < candidates.length; i++) {
        final player = candidates[i];

        // PAUSE GUARD: Wait if game is paused
        await notifier.checkPauseStatus();

        // Safe re-read of state in case it changed during await
        state = notifier.currentState;

        // Highlight current player
        final playerGlobalIndex = state.players.indexOf(player);
        state = state.copyWith(
          currentPlayerIndex: playerGlobalIndex >= 0 ? playerGlobalIndex : 0,
          isDiceRolled: false,
          isDiceRolling: false,
          diceTotal: 0,
          dice1: 0,
          dice2: 0,
        );
        notifier.updateState(state);

        // Pre-roll delay (build anticipation) - shorter in bot mode
        final preDelay = notifier.isBotPlaying
            ? const Duration(milliseconds: 200)
            : const Duration(milliseconds: 600);
        await Future.delayed(preDelay);

        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        // ANIMATION: Start dice rolling
        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        state = state.copyWith(isDiceRolling: true);
        notifier.updateState(state);
        AudioManager.instance.playSfx('audio/dice_roll.wav');

        // Animation duration - shorter in bot mode
        final animDelay = notifier.isBotPlaying
            ? const Duration(milliseconds: 400)
            : const Duration(milliseconds: 1200);
        await Future.delayed(animDelay);

        // PAUSE GUARD
        await notifier.checkPauseStatus();

        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        // ROLL: Generate dice values
        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        final int d1 = _random.nextInt(6) + 1;
        final int d2 = _random.nextInt(6) + 1;
        final int roll = d1 + d2;

        // Store roll for this round
        roundRolls[player.id] = roll;

        // Re-read state in case async happened
        state = notifier.currentState;

        // Update global orderRolls (for final sorting)
        final updatedGlobalRolls = Map<String, int>.from(state.orderRolls);
        updatedGlobalRolls[player.id] = roll;

        // Update state with results
        state = state.copyWith(
          isDiceRolling: false,
          isDiceRolled: true,
          diceTotal: roll,
          dice1: d1,
          dice2: d2,
          orderRolls: updatedGlobalRolls,
        );
        notifier.updateState(state);

        notifier.addLog(
          '${player.name}: $roll ($d1+$d2)',
          type: isTieBreak ? 'warning' : 'success',
        );

        // Post-roll display delay - shorter in bot mode
        final postDelay = notifier.isBotPlaying
            ? const Duration(milliseconds: 300)
            : const Duration(milliseconds: 800);
        await Future.delayed(postDelay);
      }

      // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
      // PHASE 3: EVALUATION - Find max roll and detect ties
      // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
      int maxRoll = 0;
      for (final roll in roundRolls.values) {
        if (roll > maxRoll) maxRoll = roll;
      }

      // Find all players tied for the maximum roll
      final List<Player> tiedForMax = [];
      for (final player in candidates) {
        if ((roundRolls[player.id] ?? 0) == maxRoll) {
          tiedForMax.add(player);
        }
      }

      notifier.logBot(
        'Evaluation: Max roll = $maxRoll, Winners = ${tiedForMax.length} (${tiedForMax.map((p) => p.name).join(", ")})',
      );

      // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
      // PHASE 4: DECISION - Single winner or recurse for tie-break
      // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
      if (tiedForMax.length > 1) {
        // CASE B: Multiple winners - RECURSE for tie-break
        notifier.addLog(
          'âš–ï¸ Beraberlik: ${tiedForMax.map((p) => p.name).join(", ")} ($maxRoll)',
          type: 'warning',
        );

        // Brief pause before tie-break
        await Future.delayed(const Duration(milliseconds: 1000));

        // RECURSIVE CALL - only tied players re-roll
        await execute(notifier, playersToRoll: tiedForMax, depth: depth + 1);
        return; // Exit after recursion completes
      }

      // CASE A: Single winner (or all players unique after root call)
      // Only finalize at root level (depth == 0)
      if (isRootCall) {
        await _finalizeTurnOrderFromRolls(
          notifier,
          notifier.currentState.orderRolls,
        );
      }
      // For tie-break calls (depth > 0), the winner is now known
      // The root call will handle finalization
    } catch (e, stackTrace) {
      safePrint('ğŸš¨ ERROR in startAutomatedTurnOrder: $e');
      safePrint('Stack trace: $stackTrace');
      notifier.addLog('SÄ±ra belirleme hatasÄ±: $e', type: 'error');
      notifier.logBot('ğŸš¨ ERROR in startAutomatedTurnOrder: $e');
    } finally {
      if (depth == 0) {
        notifier.setProcessing(false);
        notifier.logBot(
          'startAutomatedTurnOrder() COMPLETED - processing flag reset',
        );
      }
    }
  }

  /// Finalize turn order from collected rolls.
  /// Sorts all players by their roll values (descending) and transitions to playerTurn phase.
  Future<void> _finalizeTurnOrderFromRolls(
    GameNotifier notifier,
    Map<String, int> rolls,
  ) async {
    notifier.logBot('_finalizeTurnOrderFromRolls() - Finalizing order');

    var state = notifier.currentState;

    // Sort players by roll (highest first)
    final sortedPlayers = List<Player>.from(state.players);
    sortedPlayers.sort((a, b) {
      final rollA = rolls[a.id] ?? 0;
      final rollB = rolls[b.id] ?? 0;
      return rollB.compareTo(rollA);
    });

    // Build order summary for log
    final orderSummary = StringBuffer();
    for (int i = 0; i < sortedPlayers.length; i++) {
      final player = sortedPlayers[i];
      final roll = rolls[player.id] ?? 0;
      orderSummary.writeln('  ${i + 1}. ${player.name} ($roll)');
    }

    notifier.addLog('âœ… SÄ±ra belirlendi!');
    notifier.addLog(orderSummary.toString());

    // Transition to playerTurn phase
    state = state.copyWith(
      players: sortedPlayers,
      currentPlayerIndex: 0,
      phase: GamePhase.playerTurn,
      isDiceRolled: false,
      isDiceRolling: false,
      diceTotal: 0,
      dice1: 0,
      dice2: 0,
      lastAction: 'SÄ±ra belirlendi! ${sortedPlayers.first.name} baÅŸlÄ±yor.',
      // Clear tie-breaker state
      finalizedOrder: [],
      pendingTieBreakPlayers: [],
      tieBreakerGroups: {},
      tieBreakRound: 0,
      tieBreakRoundRolls: {},
    );
    notifier.updateState(state);
    // Show Dialog
    notifier.ref.read(dialogProvider.notifier).showTurnOrder();

    notifier.logBot(
      '_finalizeTurnOrderFromRolls() COMPLETED - First player: ${sortedPlayers.first.name}',
    );
  }
}
