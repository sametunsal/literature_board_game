/// Domain entity representing a trivia question.
/// Pure Dart - no Flutter dependencies.

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question &&
        other.text == text &&
        other.correctIndex == correctIndex &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(text, correctIndex, category);

  @override
  String toString() {
    return 'Question(text: $text, options: $options, correctIndex: $correctIndex, category: $category)';
  }
}
