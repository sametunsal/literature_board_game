import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question.dart';
// ignore: unused_import
import '../models/turn_phase.dart';
import '../models/player_type.dart';
// ignore: unused_import
import '../models/turn_result.dart';
import '../providers/game_provider.dart';

/// Question dialog - Phase 3 adaptation with timer integration
///
/// Phase 3 Orchestration:
/// - UI is PASSIVE observer (watches turnPhase, questionState)
/// - UI calls ONLY playTurn() via _handleAnswer()
/// - Buttons are GATED by TurnPhase.questionResolved
/// - No direct game logic method calls (answerQuestionCorrect/answerQuestionWrong are internal)
///
/// Flow:
/// 1. User selects answer (or skips)
/// 2. _handleAnswer() sets answer state
/// 3. _handleAnswer() calls playTurn()
/// 4. playTurn() advances to next phase (turnEnded)
///
/// Phase 3 Timer Integration:
/// - Timer starts when dialog is created
/// - Timer decrements every second via Timer.periodic
/// - Calls tickQuestionTimer() from game provider
/// - Auto-fails when timer reaches 0
/// - Visual warning at <10s (orange), <5s (red)
class QuestionDialog extends ConsumerStatefulWidget {
  final Question question;

  const QuestionDialog({super.key, required this.question});

  @override
  ConsumerState<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends ConsumerState<QuestionDialog> {
  Timer? _timer;
  int _remainingTime = 30;
  bool _timerRunning = false;

  @override
  void initState() {
    super.initState();
    // Start timer when dialog is created
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timerRunning) return;
    _timerRunning = true;
    _remainingTime = ref.read(questionTimerProvider);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Check if dialog is still active
      final gameState = ref.read(gameProvider);
      if (gameState.questionState != QuestionState.answering) {
        timer.cancel();
        _timerRunning = false;
        return;
      }

      // Decrement timer via game provider
      ref.read(gameProvider.notifier).tickQuestionTimer();

      // Update local state
      setState(() {
        _remainingTime = ref.read(questionTimerProvider);
      });

      // Auto-fail when timer reaches 0
      if (_remainingTime <= 0) {
        timer.cancel();
        _timerRunning = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final turnPhase = ref.watch(turnPhaseProvider);
    final questionTimer = ref.watch(questionTimerProvider);
    // ignore: unused_local_variable
    final lastTurnResult = ref.watch(lastTurnResultProvider);

    final currentPlayer = gameState.currentPlayer;
    _remainingTime = questionTimer;

    // Phase 5.1: Bot auto-resolve - Dialog not rendered for bots
    // Bot always answers wrong (dummy logic)
    if (currentPlayer?.type == PlayerType.bot) {
      // Bot auto-resolves with delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleAnswer(false); // Always wrong
      });
      return const SizedBox.shrink();
    }

    // Question dialog buttons are only enabled during TurnPhase.questionResolved
    final canAnswer = turnPhase == TurnPhase.questionResolved;
    return AlertDialog(
      title: Row(
        children: [
          const Text('❓', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            'Soru',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category and Difficulty row
              Row(
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCategoryName(widget.question.category),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Difficulty badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _getDifficultyName(widget.question.difficulty),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Timer with visual warning
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getTimerColor(_remainingTime),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getTimerIcon(_remainingTime),
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_remainingTime s',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Question text
              Text(
                widget.question.question,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),

              // Hint
              if (widget.question.hint != null &&
                  widget.question.hint!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'İpucu: ${widget.question.hint}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.amber.shade900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Answer options
              ...(widget.question.options ?? []).asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isCorrectAnswer = option == widget.question.answer;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Opacity(
                      opacity: canAnswer ? 1.0 : 0.5,
                      child: ElevatedButton(
                        onPressed: canAnswer
                            ? () => _handleAnswer(isCorrectAnswer)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCorrectAnswer
                              ? Colors.green.shade600
                              : Colors.white,
                          foregroundColor: isCorrectAnswer
                              ? Colors.white
                              : Colors.brown.shade900,
                          elevation: canAnswer ? 2 : 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: canAnswer
                                  ? Colors.brown.shade300
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isCorrectAnswer
                                    ? Colors.white
                                    : Colors.brown.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index), // A, B, C, D
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: isCorrectAnswer
                                        ? Colors.green.shade600
                                        : Colors.brown.shade700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        Opacity(
          opacity: canAnswer ? 1.0 : 0.5,
          child: TextButton.icon(
            onPressed: canAnswer
                ? () => _handleAnswer(false)
                : null, // Skip = wrong
            icon: const Icon(Icons.skip_next),
            label: Text(
              'Atla',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            style: TextButton.styleFrom(
              foregroundColor: canAnswer
                  ? Colors.grey.shade700
                  : Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }

  // Get timer color based on remaining time
  Color _getTimerColor(int remainingTime) {
    if (remainingTime <= 0) {
      return Colors.grey.shade400;
    } else if (remainingTime <= 5) {
      return Colors.red.shade600;
    } else if (remainingTime <= 10) {
      return Colors.orange.shade500;
    } else if (remainingTime <= 20) {
      return Colors.blue.shade500;
    } else {
      return Colors.green.shade500;
    }
  }

  // Get timer icon based on remaining time
  IconData _getTimerIcon(int remainingTime) {
    if (remainingTime <= 5) {
      return Icons.error;
    } else if (remainingTime <= 10) {
      return Icons.warning;
    } else if (remainingTime <= 20) {
      return Icons.timer;
    } else {
      return Icons.schedule;
    }
  }

  // Handles answer selection and triggers Phase 2 orchestration
  // Phase 2: UI only calls playTurn(), no direct game logic
  void _handleAnswer(bool isCorrect) {
    // Set answer state (this updates game state)
    if (isCorrect) {
      ref.read(gameProvider.notifier).answerQuestionCorrect();
    } else {
      ref.read(gameProvider.notifier).answerQuestionWrong();
    }

    // Trigger Phase 2 orchestration
    // playTurn() will handle next phase progression
    ref.read(gameProvider.notifier).playTurn();
  }

  Color _getCategoryColor() {
    switch (widget.question.category) {
      case QuestionCategory.benKimim:
        return Colors.purple.shade600;
      case QuestionCategory.turkEdebiyatindaIlkler:
        return Colors.blue.shade600;
      case QuestionCategory.edebiyatAkillari:
        return Colors.green.shade600;
      case QuestionCategory.edebiyatSanatlari:
        return Colors.orange.shade600;
      case QuestionCategory.eserKarakter:
        return Colors.teal.shade600;
    }
    return Colors.grey.shade600; // Default fallback
  }

  Color _getDifficultyColor() {
    switch (widget.question.difficulty) {
      case Difficulty.easy:
        return Colors.green.shade500;
      case Difficulty.medium:
        return Colors.orange.shade500;
      case Difficulty.hard:
        return Colors.red.shade500;
    }
    return Colors.grey.shade500; // Default fallback
  }

  String _getCategoryName(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.benKimim:
        return 'Ben Kimim?';
      case QuestionCategory.turkEdebiyatindaIlkler:
        return 'Türk Edebiyatında İlkler';
      case QuestionCategory.edebiyatAkillari:
        return 'Edebiyat Akilları';
      case QuestionCategory.edebiyatSanatlari:
        return 'Edebiyat Sanatları';
      case QuestionCategory.eserKarakter:
        return 'Eser/Karakter';
    }
  }

  String _getDifficultyName(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Kolay';
      case Difficulty.medium:
        return 'Orta';
      case Difficulty.hard:
        return 'Zor';
    }
  }
}
