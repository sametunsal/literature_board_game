/// Data source for questions.
/// Wraps existing mock_questions.dart data.
/// Pure Dart - no Flutter dependencies.

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/entities/question.dart';
import '../../domain/entities/game_enums.dart';
import '../models/question_model.dart';

class QuestionsDataSource {
  QuestionsDataSource._();

  static final QuestionsDataSource _instance = QuestionsDataSource._();
  static QuestionsDataSource get instance => _instance;

  /// Get all questions as domain entities
  List<Question> getQuestions() {
    // This will be used by the repository implementation
    // For now, return empty list - will be implemented with existing data
    return [];
  }

  /// Get questions by category
  List<Question> getQuestionsByCategory(QuestionCategory category) {
    return getQuestions().where((q) => q.category == category).toList();
  }

  /// Get a random question by category
  Question? getRandomQuestion(QuestionCategory category) {
    final questions = getQuestionsByCategory(category);
    if (questions.isEmpty) return null;
    // Simple random selection - in production, use proper random
    return questions[(questions.length * DateTime.now().millisecond) %
        questions.length];
  }

  /// Load questions from JSON file
  Future<List<QuestionModel>> loadQuestionsFromJson(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
