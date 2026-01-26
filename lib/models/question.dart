import 'game_enums.dart';

class Question {
  final String text;
  final List<String> options;
  final int correctIndex;
  final QuestionCategory category;
  final String difficulty; // 'easy', 'medium', 'hard'

  const Question({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.category,
    this.difficulty = 'medium',
  });
}
