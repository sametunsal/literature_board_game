import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/turn_result.dart';
import '../providers/game_provider.dart';

/// ============================================================================
/// DEV TOOL: Turn Result Inspector
/// ============================================================================
///
/// This is a TEMPORARY debug/inspection tool for developers to validate
/// that the Turn Transcript system is working correctly.
///
/// Displays the last completed turn's TurnResult in a readable format.
///
/// USAGE:
/// - Add TurnResultInspector to GameView as a Stack overlay
/// - Widget only visible when kDebugMode == true
/// - Read-only inspection (never writes to game state)
///
/// CLEANUP:
/// - Remove this widget when Turn Transcript system is fully validated
/// - Search for "DEV TOOL" to find all temporary debug widgets

/// Lightweight overlay to inspect last completed turn
///
/// Displays TurnResult information including transcript events.
/// Only visible in debug mode to avoid affecting user experience.
class TurnResultInspector extends StatelessWidget {
  const TurnResultInspector({super.key});

  @override
  Widget build(BuildContext context) {
    // DEV TOOL: Only show in debug mode
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Consumer(
      builder: (context, ref, child) {
        final lastResult = ref.watch(gameProvider).lastTurnResult;

        // Handle case where no turn has been completed yet
        if (lastResult.playerIndex == -1) {
          return const SizedBox.shrink();
        }

        return Positioned(
          // Position in bottom-right corner
          bottom: 16,
          right: 16,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            color: Colors.black87,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320, maxHeight: 400),
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    _buildTurnInfo(lastResult),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    _buildPhaseTimeline(lastResult.transcript),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    _buildTranscriptSection(lastResult.transcript),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build inspector header
  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.bug_report, color: Colors.amber, size: 20),
        const SizedBox(width: 8),
        const Text(
          'DEV: Turn Result Inspector',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        const Text(
          '(DEBUG ONLY)',
          style: TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  /// Build turn summary information
  Widget _buildTurnInfo(TurnResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Player', '#${result.playerIndex}'),
        const SizedBox(height: 4),
        _buildInfoRow(
          'Dice',
          '${result.diceTotal}${result.isDouble ? ' (DOUBLE!)' : ''}',
          highlight: result.isDouble,
        ),
        const SizedBox(height: 4),
        _buildInfoRow(
          'Position',
          '${result.startPosition} → ${result.endPosition}',
          subtext: result.endPosition - result.startPosition != 0
              ? '${result.endPosition - result.startPosition > 0 ? '+' : ''}${result.endPosition - result.startPosition}'
              : null,
        ),
        const SizedBox(height: 4),
        _buildInfoRow(
          'Stars',
          '${result.starsDelta > 0 ? '+' : ''}${result.starsDelta}',
          subtext: 'delta',
          highlightColor: result.starsDelta > 0
              ? Colors.greenAccent
              : result.starsDelta < 0
              ? Colors.redAccent
              : null,
        ),
        const SizedBox(height: 4),
        _buildInfoRow('Tile', result.tileType),
        const SizedBox(height: 4),
        if (result.questionAnsweredCorrectly != null)
          _buildInfoRow(
            'Question',
            result.questionAnsweredCorrectly! ? 'Correct' : 'Wrong',
            highlightColor: result.questionAnsweredCorrectly!
                ? Colors.greenAccent
                : Colors.redAccent,
          ),
        if (result.taxPaid != null && result.taxPaid!)
          _buildInfoRow('Tax', 'Paid'),
      ],
    );
  }

  /// Build a single info row
  Widget _buildInfoRow(
    String label,
    String value, {
    String? subtext,
    bool highlight = false,
    Color? highlightColor,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: highlightColor ?? Colors.white,
                  fontSize: 12,
                  fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (subtext != null)
                Text(
                  subtext,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build phase timeline showing turn progression
  ///
  /// Extracts phase transitions from transcript and displays them
  /// as a horizontal timeline for quick visual inspection.
  Widget _buildPhaseTimeline(TurnTranscript transcript) {
    // Extract phase transitions from transcript events
    final phaseSteps = _extractPhaseSteps(transcript);

    if (phaseSteps.isEmpty) {
      return const Text(
        'No phase transitions recorded',
        style: TextStyle(color: Colors.white54, fontSize: 11),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phase Timeline',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: phaseSteps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == phaseSteps.length - 1;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPhaseStep(step, index == phaseSteps.length - 1),
                  if (!isLast) _buildArrowConnector(),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Extract phase steps from transcript
  List<_PhaseStep> _extractPhaseSteps(TurnTranscript transcript) {
    final steps = <_PhaseStep>[];

    // Find all transition events and extract phase information
    for (final event in transcript.events) {
      if (event.type == TurnEventType.transition) {
        // Extract transition name and phases from event data
        final transitionName = event.data['transitionName'] as String?;
        final toPhaseStr = event.data['to'] as String?;

        if (transitionName != null && toPhaseStr != null) {
          // Parse the phase from string (e.g., "TurnPhase.diceRolled" -> "diceRolled")
          final phaseName = toPhaseStr.replaceFirst('TurnPhase.', '');
          steps.add(
            _PhaseStep(
              phaseName: phaseName,
              transitionName: transitionName,
              isActive: true,
            ),
          );
        }
      }
    }

    // If no transitions found, create a default timeline based on transcript
    if (steps.isEmpty) {
      // Try to infer phases from event types
      if (transcript.events.any((e) => e.type == TurnEventType.diceRoll)) {
        steps.add(
          _PhaseStep(
            phaseName: 'diceRolled',
            transitionName: 'roll_dice',
            isActive: true,
          ),
        );
      }
      if (transcript.events.any((e) => e.type == TurnEventType.move)) {
        steps.add(
          _PhaseStep(
            phaseName: 'moved',
            transitionName: 'move_player',
            isActive: true,
          ),
        );
      }
      if (transcript.events.any((e) => e.type == TurnEventType.tileResolved)) {
        steps.add(
          _PhaseStep(
            phaseName: 'tileResolved',
            transitionName: 'resolve_tile',
            isActive: true,
          ),
        );
      }
      if (transcript.events.any((e) => e.type == TurnEventType.cardApplied)) {
        steps.add(
          _PhaseStep(
            phaseName: 'cardApplied',
            transitionName: 'apply_card',
            isActive: true,
          ),
        );
      }
      if (transcript.events.any(
        (e) => e.type == TurnEventType.questionAnswered,
      )) {
        steps.add(
          _PhaseStep(
            phaseName: 'questionResolved',
            transitionName: 'answer_question',
            isActive: true,
          ),
        );
      }
      if (transcript.events.any((e) => e.type == TurnEventType.taxPaid)) {
        steps.add(
          _PhaseStep(
            phaseName: 'taxResolved',
            transitionName: 'pay_tax',
            isActive: true,
          ),
        );
      }
      steps.add(
        _PhaseStep(
          phaseName: 'turnEnded',
          transitionName: 'end_turn',
          isActive: true,
        ),
      );
    }

    return steps;
  }

  /// Build a single phase step in the timeline
  Widget _buildPhaseStep(_PhaseStep step, bool isCurrent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Phase indicator circle
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent
                ? Colors.amber
                : Colors.blue.withValues(alpha: 0.3),
            border: Border.all(
              color: isCurrent ? Colors.amber : Colors.blue,
              width: 2,
            ),
          ),
          child: Center(
            child: isCurrent
                ? const Icon(Icons.check, color: Colors.black, size: 14)
                : Icon(Icons.circle, color: Colors.blue, size: 8),
          ),
        ),
        const SizedBox(height: 4),
        // Transition name
        Container(
          constraints: const BoxConstraints(maxWidth: 80),
          child: Text(
            step.transitionName,
            style: const TextStyle(color: Colors.cyanAccent, fontSize: 9),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2),
        // Phase name
        Container(
          constraints: const BoxConstraints(maxWidth: 80),
          child: Text(
            step.phaseName,
            style: TextStyle(
              color: isCurrent ? Colors.amber : Colors.white70,
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Build arrow connector between phase steps
  Widget _buildArrowConnector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(Icons.arrow_forward, color: Colors.white38, size: 16)],
      ),
    );
  }

  /// Build transcript section with collapsible events
  Widget _buildTranscriptSection(TurnTranscript transcript) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transcript (${transcript.events.length} events)',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...transcript.events.map((event) => _buildEventItem(event)),
      ],
    );
  }

  /// Build a single transcript event item
  Widget _buildEventItem(TurnEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: _getEventColor(event.type),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.type.toString(),
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (event.description != null)
                  Text(
                    event.description!,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get color for event type
  Color _getEventColor(TurnEventType type) {
    switch (type) {
      case TurnEventType.transition:
        return Colors.blueAccent;
      case TurnEventType.diceRoll:
        return Colors.purpleAccent;
      case TurnEventType.move:
        return Colors.greenAccent;
      case TurnEventType.tileResolved:
        return Colors.orangeAccent;
      case TurnEventType.cardDrawn:
      case TurnEventType.cardApplied:
        return Colors.pinkAccent;
      case TurnEventType.questionAsked:
      case TurnEventType.questionAnswered:
        return Colors.cyanAccent;
      case TurnEventType.taxPaid:
        return Colors.redAccent;
      case TurnEventType.bankruptcy:
        return Colors.red;
      case TurnEventType.starChange:
        return Colors.amberAccent;
      case TurnEventType.copyrightPurchased:
        return Colors.deepPurpleAccent;
      case TurnEventType.rentPaid:
        return Colors.deepOrangeAccent;
      case TurnEventType.bonusReceived:
        return Colors.lightGreenAccent;
    }
  }
}

/// Helper class to represent a phase step in the timeline
class _PhaseStep {
  final String phaseName;
  final String transitionName;
  final bool isActive;

  const _PhaseStep({
    required this.phaseName,
    required this.transitionName,
    required this.isActive,
  });
}
