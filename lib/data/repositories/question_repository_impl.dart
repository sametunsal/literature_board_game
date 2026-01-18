/// Implementation of QuestionRepository.
/// Uses QuestionsDataSource for loading questions.
/// Pure Dart - no Flutter dependencies (except Flutter services).

import 'dart:math';
import '../../domain/entities/question.dart';
import '../../domain/entities/game_enums.dart';
import '../../domain/repositories/question_repository.dart';
import '../datasources/questions_datasource.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final QuestionsDataSource _dataSource;

  List<Question>? _cachedQuestions;
  bool _isLoaded = false;

  QuestionRepositoryImpl({QuestionsDataSource? dataSource})
    : _dataSource = dataSource ?? QuestionsDataSource.instance;

  @override
  Future<List<Question>> getAllQuestions() async {
    if (_cachedQuestions == null) {
      await loadQuestions();
    }
    return _cachedQuestions ?? [];
  }

  @override
  Future<List<Question>> getQuestionsByCategory(
    QuestionCategory category,
  ) async {
    final allQuestions = await getAllQuestions();
    return allQuestions.where((q) => q.category == category).toList();
  }

  @override
  Future<Question> getRandomQuestion() async {
    final allQuestions = await getAllQuestions();
    if (allQuestions.isEmpty) {
      throw Exception('No questions available');
    }
    final random = Random();
    return allQuestions[random.nextInt(allQuestions.length)];
  }

  @override
  Future<Question?> getRandomQuestionByCategory(
    QuestionCategory category,
  ) async {
    final categoryQuestions = await getQuestionsByCategory(category);
    if (categoryQuestions.isEmpty) {
      return null;
    }
    final random = Random();
    return categoryQuestions[random.nextInt(categoryQuestions.length)];
  }

  @override
  Future<void> loadQuestions() async {
    // Load from data source
    // For now, use the data source's getQuestions method
    // In production, this would load from JSON file
    _cachedQuestions = _dataSource.getQuestions();
    _isLoaded = true;
  }

  @override
  Future<bool> isLoaded() async {
    return _isLoaded;
  }
}
