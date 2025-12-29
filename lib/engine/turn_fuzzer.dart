import 'dart:math' as math;
import '../models/turn_result.dart';
import '../models/turn_phase.dart';
import 'turn_replay_engine.dart';

/// ============================================================================
/// TURN FUZZER - Property-Based Testing Tool
/// ============================================================================
///
/// This tool generates random but VALID turn scenarios to stress-test
/// the TurnReplayEngine and validate correctness across edge cases.
///
/// USE CASES:
/// - Stress-test TurnReplayEngine with thousands of scenarios
/// - Find edge cases and corner scenarios
/// - Validate replay engine determinism
/// - Ensure transcript completeness
///
/// ARCHITECTURE:
/// - Pure Dart (no Flutter, no providers)
/// - Random generation of valid turn scenarios
/// - Automatic validation of each scenario
/// - Detailed failure reporting with full context
///
/// TESTING PHILOSOPHY:
/// - Property-based testing: Test invariants across random inputs
/// - "If it looks like a turn and walks like a turn, it should validate"
/// - Find bugs by generating unlikely scenarios
///
/// This is a developer testing tool, NOT production code.

/// Configuration for turn fuzzer
class TurnFuzzerConfig {
  final int iterations;
  final int boardSize;
  final int startBonus;
  final int maxStars;
  final int minDice;
  final int maxDice;
  final bool includeCardEffects;
  final bool includeQuestions;
  final bool includeTax;
  final bool seed;

  const TurnFuzzerConfig({
    this.iterations = 100,
    this.boardSize = 40,
    this.startBonus = 50,
    this.maxStars = 1000,
    this.minDice = 1,
    this.maxDice = 6,
    this.includeCardEffects = true,
    this.includeQuestions = true,
    this.includeTax = true,
    this.seed = true,
  });

  /// Create config for quick testing
  const TurnFuzzerConfig.quick()
    : iterations = 10,
      boardSize = 40,
      startBonus = 50,
      maxStars = 500,
      minDice = 1,
      maxDice = 6,
      includeCardEffects = true,
      includeQuestions = true,
      includeTax = true,
      seed = true;

  /// Create config for stress testing
  const TurnFuzzerConfig.stress()
    : iterations = 1000,
      boardSize = 40,
      startBonus = 50,
      maxStars = 10000,
      minDice = 1,
      maxDice = 6,
      includeCardEffects = true,
      includeQuestions = true,
      includeTax = true,
      seed = true;
}

/// Generated turn scenario with snapshot, transcript, and result
class GeneratedTurnScenario {
  final int scenarioIndex;
  final TurnSnapshot snapshot;
  final TurnTranscript transcript;
  final TurnResult result;

  const GeneratedTurnScenario({
    required this.scenarioIndex,
    required this.snapshot,
    required this.transcript,
    required this.result,
  });
}

/// Property-based turn fuzzer
///
/// Generates random turn scenarios and validates them against TurnReplayEngine.
class TurnFuzzer {
  final TurnFuzzerConfig config;
  final math.Random _random;

  TurnFuzzer({this.config = const TurnFuzzerConfig()})
    : _random = config.seed ? math.Random(42) : math.Random();

  /// Run N iterations of fuzz testing
  ///
  /// Returns true if all scenarios pass validation.
  /// Stops at first failure and prints detailed failure report.
  bool run() {
    print('🔬 Turn Fuzzer: Starting property-based testing');
    print('   Iterations: ${config.iterations}');
    print('   Board size: ${config.boardSize}');
    print('   START bonus: ${config.startBonus}');
    print('   Include card effects: ${config.includeCardEffects}');
    print('   Include questions: ${config.includeQuestions}');
    print('   Include tax: ${config.includeTax}');
    print('');

    int passed = 0;
    int failed = 0;

    for (int i = 0; i < config.iterations; i++) {
      final scenario = _generateTurnScenario(i + 1);
      final validation = TurnReplayEngine.replayAndValidate(
        turnResult: scenario.result,
        turnSnapshot: scenario.snapshot,
        throwOnError: false,
      );

      if (validation.isValid) {
        passed++;
        print('✅ Scenario ${i + 1}: PASSED');
      } else {
        failed++;
        print('❌ Scenario ${i + 1}: FAILED');
        _printFailureReport(scenario, validation);
        return false; // Stop at first failure
      }
    }

    print('');
    print('📊 Fuzzer Results:');
    print('   Total: ${config.iterations}');
    print('   Passed: $passed');
    print('   Failed: $failed');
    print(
      '   Success rate: ${(passed / config.iterations * 100).toStringAsFixed(1)}%',
    );
    print('');

    if (failed == 0) {
      print('🎉 All scenarios passed!');
      return true;
    } else {
      print('💥 Some scenarios failed!');
      return false;
    }
  }

  /// Generate a random but valid turn scenario
  GeneratedTurnScenario _generateTurnScenario(int scenarioIndex) {
    // Generate random start state
    final playerIndex = 0;
    final startPosition = _random.nextInt(config.boardSize) + 1;
    final startStars = _random.nextInt(config.maxStars);

    // Roll dice
    final die1 = _random.nextInt(config.maxDice) + 1;
    final die2 = _random.nextInt(config.maxDice) + 1;
    final diceTotal = die1 + die2;
    final isDouble = die1 == die2;

    // Calculate movement
    var newPosition = (startPosition + diceTotal - 1) % config.boardSize + 1;
    var currentStars = startStars;

    // Check if passed START (simplified: passed if wrap-around)
    bool passedStart = (startPosition + diceTotal) > config.boardSize;
    if (passedStart) {
      currentStars += config.startBonus;
    }

    // Build transcript
    final transcriptBuilder = TurnTranscriptBuilder();

    // Add transition events
    transcriptBuilder.addTransition(
      'diceRoll',
      TurnPhase.start,
      TurnPhase.diceRolled,
    );
    transcriptBuilder.addTransition(
      'move',
      TurnPhase.diceRolled,
      TurnPhase.moved,
    );
    transcriptBuilder.addTransition(
      'tileResolved',
      TurnPhase.moved,
      TurnPhase.tileResolved,
    );

    // Add dice roll event
    transcriptBuilder.addDiceRoll(die1, die2, diceTotal, isDouble);

    // Add move event
    transcriptBuilder.addMove(startPosition, newPosition, passedStart);

    // Add tile resolved event
    transcriptBuilder.addTileResolved(
      newPosition,
      'Tile$newPosition',
      'TileType.special',
    );

    // Optionally add card effects
    if (config.includeCardEffects && _random.nextBool()) {
      _generateCardEffect(transcriptBuilder);
    }

    // Optionally add question
    if (config.includeQuestions && _random.nextBool()) {
      _generateQuestion(transcriptBuilder, currentStars);
    }

    // Optionally add tax
    if (config.includeTax && _random.nextBool()) {
      final taxAmount = _generateTaxAmount(currentStars);
      currentStars -= taxAmount;
      transcriptBuilder.addTaxPaid('TaxType.gelirVergisi', taxAmount);
    }

    // Add final transition
    transcriptBuilder.addTransition(
      'endTurn',
      TurnPhase.tileResolved,
      TurnPhase.turnEnded,
    );

    // Calculate deltas
    final starsDelta = currentStars - startStars;
    final positionDelta = newPosition - startPosition;

    // Create snapshot
    final snapshot = TurnSnapshot(
      playerIndex: playerIndex,
      startStars: startStars,
      startPosition: startPosition,
    );

    // Create transcript
    final transcript = transcriptBuilder.build(playerIndex);

    // Create result (CLAIM)
    final result = TurnResult(
      playerIndex: playerIndex,
      startPosition: startPosition,
      endPosition: newPosition,
      diceTotal: diceTotal,
      isDouble: isDouble,
      starsDelta: starsDelta,
      tileType: 'TileType.special',
      transcript: transcript,
    );

    return GeneratedTurnScenario(
      scenarioIndex: scenarioIndex,
      snapshot: snapshot,
      transcript: transcript,
      result: result,
    );
  }

  /// Generate random card effect
  void _generateCardEffect(TurnTranscriptBuilder builder) {
    final cardType = _random.nextBool() ? 'ŞANS' : 'KADER';
    final starChange = _random.nextInt(100) - 50; // -50 to +50

    builder.addCardDrawn(cardType, '$cardType card effect');

    if (starChange != 0) {
      builder.addCardApplied(cardType, '$cardType effect', starChange);
    }
  }

  /// Generate random question outcome
  void _generateQuestion(TurnTranscriptBuilder builder, int currentStars) {
    final isCorrect = _random.nextBool();
    final starChange = isCorrect ? 10 : -5;

    builder.addQuestionAsked('Random question?', 'QuestionCategory.benKimim');

    if (isCorrect) {
      builder.addQuestionAnswered('correct', starChange);
    } else {
      builder.addQuestionAnswered('wrong', starChange);
    }
  }

  /// Generate random tax amount
  int _generateTaxAmount(int currentStars) {
    final percentage = _random.nextBool() ? 10 : 15;
    final percentageTax = (currentStars * percentage) ~/ 100;
    final minTax = percentage == 10 ? 20 : 30;
    return percentageTax > minTax ? percentageTax : minTax;
  }

  /// Print detailed failure report
  void _printFailureReport(
    GeneratedTurnScenario scenario,
    ReplayValidationResult validation,
  ) {
    print('');
    print('═' * 70);
    print('❌ FUZZER FAILURE REPORT');
    print('═' * 70);
    print('');
    print('Scenario Index: ${scenario.scenarioIndex}');
    print('');
    print('📸 TURN SNAPSHOT:');
    print('   Player index: ${scenario.snapshot.playerIndex}');
    print('   Start stars: ${scenario.snapshot.startStars}');
    print('   Start position: ${scenario.snapshot.startPosition}');
    print('');
    print('📋 TRANSCRIPT (${scenario.transcript.events.length} events):');

    for (int i = 0; i < scenario.transcript.events.length; i++) {
      final event = scenario.transcript.events[i];
      print('   ${i + 1}. [${event.type}] ${event.description ?? ''}');
      if (event.data.isNotEmpty) {
        print('      Data: ${event.data}');
      }
    }

    print('');
    print('📊 CLAIMED RESULT (TurnResult):');
    print('   Player index: ${scenario.result.playerIndex}');
    print('   Start position: ${scenario.result.startPosition}');
    print('   End position: ${scenario.result.endPosition}');
    print(
      '   Position delta: ${scenario.result.endPosition - scenario.result.startPosition}',
    );
    print('   Stars delta: ${scenario.result.starsDelta}');
    print('   Dice total: ${scenario.result.diceTotal}');
    print('   Is double: ${scenario.result.isDouble}');
    print('');

    print('❌ VALIDATION ERROR:');
    print(validation.errorMessage ?? 'No error message');
    print('');
    print('═' * 70);
  }
}

/// Builder for constructing TurnTranscript
///
/// Provides fluent API for building transcripts with all event types.
class TurnTranscriptBuilder {
  final List<TurnEvent> _events = [];

  /// Add a transition event
  TurnTranscriptBuilder addTransition(
    String name,
    TurnPhase from,
    TurnPhase to,
  ) {
    _events.add(
      TurnEvent(
        type: TurnEventType.transition,
        description: '$name ($from → $to)',
        data: {
          'transitionName': name,
          'from': from.toString(),
          'to': to.toString(),
        },
      ),
    );
    return this;
  }

  /// Add a dice roll event
  TurnTranscriptBuilder addDiceRoll(
    int die1,
    int die2,
    int total,
    bool isDouble,
  ) {
    _events.add(
      TurnEvent(
        type: TurnEventType.diceRoll,
        description:
            'Rolled $die1 + $die2 = $total${isDouble ? ' (DOUBLE!)' : ''}',
        data: {
          'die1': die1,
          'die2': die2,
          'total': total,
          'isDouble': isDouble,
        },
      ),
    );
    return this;
  }

  /// Add a move event
  TurnTranscriptBuilder addMove(int from, int to, bool passedStart) {
    _events.add(
      TurnEvent(
        type: TurnEventType.move,
        description:
            'Moved from $from to $to${passedStart ? ' (passed START)' : ''}',
        data: {'from': from, 'to': to, 'passedStart': passedStart},
      ),
    );
    return this;
  }

  /// Add a tile resolved event
  TurnTranscriptBuilder addTileResolved(
    int tileId,
    String tileName,
    String tileType,
  ) {
    _events.add(
      TurnEvent(
        type: TurnEventType.tileResolved,
        description: 'Landed on tile $tileId: $tileName ($tileType)',
        data: {'tileId': tileId, 'tileName': tileName, 'tileType': tileType},
      ),
    );
    return this;
  }

  /// Add a card drawn event
  TurnTranscriptBuilder addCardDrawn(String cardType, String description) {
    _events.add(
      TurnEvent(
        type: TurnEventType.cardDrawn,
        description: 'Drew $cardType card: $description',
        data: {'cardType': cardType, 'description': description},
      ),
    );
    return this;
  }

  /// Add a card applied event
  TurnTranscriptBuilder addCardApplied(
    String cardType,
    String description,
    int? starChange,
  ) {
    _events.add(
      TurnEvent(
        type: TurnEventType.cardApplied,
        description:
            'Applied $cardType card: $description${starChange != null ? ' (${starChange > 0 ? '+' : ''}$starChange stars)' : ''}',
        data: {
          'cardType': cardType,
          'description': description,
          'starChange': starChange,
        },
      ),
    );
    return this;
  }

  /// Add a question asked event
  TurnTranscriptBuilder addQuestionAsked(String question, String category) {
    _events.add(
      TurnEvent(
        type: TurnEventType.questionAsked,
        description: 'Question asked: $question',
        data: {'question': question, 'category': category},
      ),
    );
    return this;
  }

  /// Add a question answered event
  TurnTranscriptBuilder addQuestionAnswered(
    String answerResult,
    int starChange,
  ) {
    _events.add(
      TurnEvent(
        type: TurnEventType.questionAnswered,
        description:
            'Answered $answerResult (${starChange > 0 ? '+' : ''}$starChange stars)',
        data: {'answerResult': answerResult, 'starChange': starChange},
      ),
    );
    return this;
  }

  /// Add a tax paid event
  TurnTranscriptBuilder addTaxPaid(String taxType, int amount) {
    _events.add(
      TurnEvent(
        type: TurnEventType.taxPaid,
        description: 'Paid $taxType tax: $amount stars',
        data: {'taxType': taxType, 'amount': amount},
      ),
    );
    return this;
  }

  /// Add a bankruptcy event
  TurnTranscriptBuilder addBankruptcy(String playerName) {
    _events.add(
      TurnEvent(
        type: TurnEventType.bankruptcy,
        description: '$playerName went bankrupt!',
        data: {'playerName': playerName},
      ),
    );
    return this;
  }

  /// Add a star change event
  TurnTranscriptBuilder addStarChange(String source, int delta) {
    _events.add(
      TurnEvent(
        type: TurnEventType.starChange,
        description: 'Stars ${delta > 0 ? '+' : ''}$delta from $source',
        data: {'source': source, 'delta': delta},
      ),
    );
    return this;
  }

  /// Build the final TurnTranscript
  TurnTranscript build(int playerIndex) {
    return TurnTranscript(
      playerIndex: playerIndex,
      events: List.unmodifiable(_events),
    );
  }
}

/// Convenience function to run quick fuzzer test
bool runQuickFuzzer() {
  final fuzzer = TurnFuzzer(config: const TurnFuzzerConfig.quick());
  return fuzzer.run();
}

/// Convenience function to run stress test
bool runStressTest() {
  final fuzzer = TurnFuzzer(config: const TurnFuzzerConfig.stress());
  return fuzzer.run();
}
