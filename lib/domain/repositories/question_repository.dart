/// Repository interface for question loading.
/// Pure Dart - no Flutter dependencies.
library;

import '../../models/question.dart';
import '../../models/game_enums.dart';

abstract class QuestionRepository {
  /// Gets all questions.
  Future<List<Question>> getAllQuestions();

  /// Gets questions by category.
  Future<List<Question>> getQuestionsByCategory(QuestionCategory category);

  /// Gets a random question.
  Future<Question> getRandomQuestion();

  /// Gets a random question from a specific category.
  Future<Question?> getRandomQuestionByCategory(QuestionCategory category);

  /// Loads questions from a data source.
  Future<void> loadQuestions();

  /// Checks if questions are loaded.
  Future<bool> isLoaded();
}
