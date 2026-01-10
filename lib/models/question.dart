import 'game_enums.dart';

class Question {
  final String text;
  final List<String> options;
  final int correctIndex;
  final QuestionCategory category;

  const Question({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.category,
  });
}
