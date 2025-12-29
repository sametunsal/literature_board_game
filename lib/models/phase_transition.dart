import 'turn_phase.dart';
import 'tile.dart';
import 'turn_result.dart';
import '../providers/game_provider.dart';

/// Represents a single phase transition in game state machine
///
/// This makes phase transitions explicit and declarative:
/// - From → To phases are clearly declared
/// - Semantic name provides logging/debugging context
/// - Guard function validates if transition can execute
/// - Expected event types validate semantic consistency with transcript
class PhaseTransition {
  /// Source phase (where transition starts)
  final TurnPhase from;

  /// Destination phase (where transition ends)
  final TurnPhase to;

  /// Semantic name for this transition (e.g., "roll_dice", "resolve_tile")
  /// Used for logging and debugging
  final String name;

  /// Guard: can this transition execute in the current game state?
  /// Returns true if all preconditions are met (e.g., player can roll, tile type matches)
  final bool Function(GameState state) canExecute;

  /// Expected transcript event types for this transition
  ///
  /// Used for validation to ensure semantic consistency between
  /// phase transitions and transcript events. If a transition
  /// executes, these event types should appear in the transcript.
  ///
  /// Validation rules:
  /// - If multiple events expected, ALL must be present
  /// - If no events expected (empty list), validation passes
  /// - Validation is debug-only, fails loudly with assertion
  final List<TurnEventType> expectedEventTypes;

  const PhaseTransition({
    required this.from,
    required this.to,
    required this.name,
    required this.canExecute,
    this.expectedEventTypes = const [],
  });
}

/// Central registry of all valid phase transitions in the game
///
/// This serves as the explicit state machine for the game.
/// All valid transitions are declared here, making the complete flow
/// visible, testable, and modifiable in one place.
///
/// Key design decisions:
/// - Multiple transitions can exist from a single phase (for branching)
/// - Transitions are evaluated in order; first matching transition wins
/// - This allows tileResolved to branch based on tile type without complex logic
/// - No new game rules are introduced; existing methods are reused
class PhaseTransitionMap {
  /// All valid phase transitions in the game
  ///
  /// Transitions are evaluated in order when finding a transition from a phase.
  /// This allows branching (e.g., tileResolved → cardApplied vs questionResolved)
  /// based on game state (tile type, player flags, etc.).
  static final List<PhaseTransition> transitions = [
    // ==========================================================================
    // START → DICEROLLED: Roll the dice
    // ==========================================================================
    PhaseTransition(
      from: TurnPhase.start,
      to: TurnPhase.diceRolled,
      name: 'roll_dice',
      canExecute: (state) {
        // Check if player can roll
        if (!state.canRoll) {
          return false;
        }
        if (state.currentPlayer == null) {
          return false;
        }
        return true;
      },
      expectedEventTypes: [TurnEventType.diceRoll],
    ),

    // ==========================================================================
    // DICEROLLED → MOVED: Move player based on dice roll
    // ==========================================================================
    PhaseTransition(
      from: TurnPhase.diceRolled,
      to: TurnPhase.moved,
      name: 'move_player',
      canExecute: (state) => state.lastDiceRoll != null,
      expectedEventTypes: [TurnEventType.move],
    ),

    // ==========================================================================
    // MOVED → TILERESOLVED: Resolve tile effects
    // ==========================================================================
    PhaseTransition(
      from: TurnPhase.moved,
      to: TurnPhase.tileResolved,
      name: 'resolve_tile',
      canExecute: (state) => state.currentPlayer != null,
      expectedEventTypes: [TurnEventType.tileResolved],
    ),

    // ==========================================================================
    // TILERESOLVED → CARDAPPLIED: Draw and apply chance/fate card
    // ==========================================================================
    PhaseTransition(
      from: TurnPhase.tileResolved,
      to: TurnPhase.cardApplied,
      name: 'draw_and_apply_card',
      canExecute: (state) {
        if (state.newPosition == null || state.currentPlayer == null) {
          return false;
        }
        final tile = state.tiles.firstWhere((t) => t.id == state.newPosition);
        return tile.type == TileType.chance || tile.type == TileType.fate;
      },
      expectedEventTypes: [TurnEventType.cardDrawn, TurnEventType.cardApplied],
    ),

    // ==========================================================================
    // TILERESOLVED → QUESTIONRESOLVED: Show question for book/publisher
    // ==========================================================================
    PhaseTransition(
      from: TurnPhase.tileResolved,
      to: TurnPhase.questionResolved,
      name: 'show_question',
      canExecute: (state) {
        if (state.newPosition == null || state.currentPlayer == null) {
          return false;
        }
        final tile = state.tiles.firstWhere((t) => t.id == state.newPosition);
        return tile.type == TileType.book || tile.type == TileType.publisher;
      },
      expectedEventTypes: [TurnEventType.questionAsked],
    ),

    // ==========================================================================
    // TILERESOLVED → TAXRESOLVED: Handle tax payment
    // ==========================================================================
    PhaseTransition(
      from: TurnPhase.tileResolved,
      to: TurnPhase.taxResolved,
      name: 'handle_tax',
      canExecute: (state) {
        if (state.newPosition == null || state.currentPlayer == null) {
          return false;
        }
        final tile = state.tiles.firstWhere((t) => t.id == state.newPosition);
        return tile.type == TileType.tax;
      },
      expectedEventTypes: [TurnEventType.taxPaid],
    ),

    // ==========================================================================
    // TILERESOLVED → TURNENDED: Corner/special tiles (no additional action)
    // ==========================================================================
    PhaseTransition(
      from: TurnPhase.tileResolved,
      to: TurnPhase.turnEnded,
      name: 'resolve_corner_or_special',
      canExecute: (state) {
        if (state.newPosition == null || state.currentPlayer == null) {
          return false;
        }
        final tile = state.tiles.firstWhere((t) => t.id == state.newPosition);
        return tile.type == TileType.corner || tile.type == TileType.special;
      },
      expectedEventTypes: const [],
    ),

    // ==========================================================================
    // QUESTIONRESOLVED → COPYRIGHTPURCHASED: Show copyright purchase option
    // ==========================================================================
    PhaseTransition(
      from: TurnPhase.questionResolved,
      to: TurnPhase.copyrightPurchased,
      name: 'show_copyright_purchase',
      canExecute: (state) {
        if (state.newPosition == null || state.currentPlayer == null) {
          return false;
        }
        final tile = state.tiles.firstWhere((t) => t.id == state.newPosition);
        // Only show purchase option for book/publisher tiles
        if (tile.type != TileType.book && tile.type != TileType.publisher) {
          return false;
        }
        // Only show if tile can be owned and is unowned
        if (!tile.canBeOwned || tile.owner != null) {
          return false;
        }
        return true;
      },
      expectedEventTypes: [TurnEventType.questionAnswered],
    ),

    // ==========================================================================
    // COPYRIGHTPURCHASED → TURNENDED: Copyright purchase complete, end turn
    // ==========================================================================
    PhaseTransition(
      from: TurnPhase.copyrightPurchased,
      to: TurnPhase.turnEnded,
      name: 'end_turn_after_purchase',
      canExecute: (state) => state.currentPlayer != null,
      expectedEventTypes: const [],
    ),

    // ==========================================================================
    // QUESTIONRESOLVED → TURNENDED: Question answered, end turn (no purchase option)
    // ==========================================================================
    PhaseTransition(
      from: TurnPhase.questionResolved,
      to: TurnPhase.turnEnded,
      name: 'end_turn_after_question',
      canExecute: (state) {
        if (state.newPosition == null || state.currentPlayer == null) {
          return false;
        }
        final tile = state.tiles.firstWhere((t) => t.id == state.newPosition);
        // End turn if tile is NOT book/publisher or tile is already owned
        return tile.type != TileType.book && tile.type != TileType.publisher ||
            (tile.canBeOwned && tile.owner != null) ||
            (!tile.canBeOwned);
      },
      expectedEventTypes: [TurnEventType.questionAnswered],
    ),

    // ==========================================================================
    // CARDAPPLIED → TURNENDED: Card effect complete, end turn
    // ==========================================================================
    PhaseTransition(
      from: TurnPhase.cardApplied,
      to: TurnPhase.turnEnded,
      name: 'end_turn_after_card',
      canExecute: (state) => state.currentPlayer != null,
      expectedEventTypes: const [],
    ),

    // ==========================================================================
    // TAXRESOLVED → TURNENDED: Tax paid, end turn
    // ==========================================================================
    PhaseTransition(
      from: TurnPhase.taxResolved,
      to: TurnPhase.turnEnded,
      name: 'end_turn_after_tax',
      canExecute: (state) => state.currentPlayer != null,
      expectedEventTypes: const [],
    ),
  ];

  /// Find transition to execute from current phase
  ///
  /// Returns the first matching transition whose guard evaluates to true.
  /// Returns null if no valid transition exists from this phase in the current state.
  static PhaseTransition? findTransition(TurnPhase from, GameState state) {
    for (final transition in transitions) {
      if (transition.from == from && transition.canExecute(state)) {
        return transition;
      }
    }
    return null;
  }

  /// Get all possible transitions from a specific phase
  ///
  /// Useful for debugging and visualization.
  /// Returns all transitions regardless of guard conditions.
  static List<PhaseTransition> getTransitionsFrom(TurnPhase from) {
    return transitions.where((t) => t.from == from).toList();
  }

  /// Check if a specific transition is valid in the current state
  ///
  /// Returns true if there exists a transition from 'from' to 'to'
  /// and its guard condition is satisfied.
  static bool canTransitionTo(TurnPhase from, TurnPhase to, GameState state) {
    for (final transition in transitions) {
      if (transition.from == from &&
          transition.to == to &&
          transition.canExecute(state)) {
        return true;
      }
    }
    return false;
  }

  /// Get name of a transition from→to (for logging)
  ///
  /// Returns null if no such transition exists.
  static String? getTransitionName(TurnPhase from, TurnPhase to) {
    for (final transition in transitions) {
      if (transition.from == from && transition.to == to) {
        return transition.name;
      }
    }
    return null;
  }

  /// Validate that a transition's expected event types exist in transcript
  ///
  /// This ensures semantic consistency between phase transitions and
  /// transcript events. If a transition executes, its expected
  /// event types should appear in the transcript.
  ///
  /// Validation rules:
  /// - If multiple events expected, ALL must be present
  /// - If no events expected (empty list), validation passes
  /// - Validation is debug-only, fails loudly with assertion
  ///
  /// Returns a validation result with details about what was found/missing.
  static TransitionValidationResult validateTransitionEvents(
    PhaseTransition transition,
    TurnTranscript transcript,
  ) {
    // Get all event types in transcript (exclude transition events themselves)
    final transcriptEventTypes = transcript.events
        .where((event) => event.type != TurnEventType.transition)
        .map((event) => event.type)
        .toSet();

    // Check each expected event type
    final List<String> missingEvents = [];
    final List<String> foundEvents = [];

    for (final expectedType in transition.expectedEventTypes) {
      if (transcriptEventTypes.contains(expectedType)) {
        foundEvents.add(expectedType.toString());
      } else {
        missingEvents.add(expectedType.toString());
      }
    }

    final bool isValid = missingEvents.isEmpty;

    return TransitionValidationResult(
      transitionName: transition.name,
      from: transition.from,
      to: transition.to,
      isValid: isValid,
      foundEvents: foundEvents,
      missingEvents: missingEvents,
    );
  }
}

/// Result of validating transition events against transcript
///
/// Provides detailed information about which expected events
/// were found and which are missing.
class TransitionValidationResult {
  /// Name of the transition being validated
  final String transitionName;

  /// Source phase
  final TurnPhase from;

  /// Destination phase
  final TurnPhase to;

  /// Whether validation passed (all expected events found)
  final bool isValid;

  /// Expected events that were found in transcript
  final List<String> foundEvents;

  /// Expected events that were missing from transcript
  final List<String> missingEvents;

  const TransitionValidationResult({
    required this.transitionName,
    required this.from,
    required this.to,
    required this.isValid,
    required this.foundEvents,
    required this.missingEvents,
  });

  @override
  String toString() {
    if (isValid) {
      return '✅ Transition: $transitionName ($from → $to) - All expected events found';
    } else {
      return '❌ Transition: $transitionName ($from → $to) - Missing events: ${missingEvents.join(", ")}';
    }
  }
}
