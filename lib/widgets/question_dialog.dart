import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question.dart';

class QuestionDialog extends StatelessWidget {
  final Question question;
  final Function(bool isCorrect) onAnswer;
  final int remainingTime;

  const QuestionDialog({
    super.key,
    required this.question,
    required this.onAnswer,
    this.remainingTime = 30,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.quiz, color: Colors.brown.shade700, size: 28),
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
                      _getCategoryName(question.category),
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
                          _getDifficultyName(question.difficulty),
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

                  // Timer
                  if (remainingTime > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: remainingTime <= 10
                            ? Colors.red.shade500
                            : Colors.blue.shade500,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$remainingTime s',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Question text
              Text(
                question.question,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),

              // Hint
              if (question.hint != null && question.hint!.isNotEmpty) ...[
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
                          'İpucu: ${question.hint}',
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
              ...question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isCorrectAnswer = option == question.answer;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton(
                      onPressed: () => onAnswer(isCorrectAnswer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCorrectAnswer
                            ? Colors.green.shade600
                            : Colors.white,
                        foregroundColor: isCorrectAnswer
                            ? Colors.white
                            : Colors.brown.shade900,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.brown.shade300,
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
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => onAnswer(false), // Skip = wrong
          icon: const Icon(Icons.skip_next),
          label: Text(
            'Atla',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
        ),
      ],
    );
  }

  Color _getCategoryColor() {
    switch (question.category) {
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
  }

  Color _getDifficultyColor() {
    switch (question.difficulty) {
      case Difficulty.easy:
        return Colors.green.shade500;
      case Difficulty.medium:
        return Colors.orange.shade500;
      case Difficulty.hard:
        return Colors.red.shade500;
    }
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
