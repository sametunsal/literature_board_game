/// Implementation of QuestionRepository.
/// Uses QuestionsDataSource for loading questions from Firestore.

import 'dart:math';
import '../../models/question.dart';
import '../../models/game_enums.dart';
import '../../domain/repositories/question_repository.dart';
import '../datasources/questions_datasource.dart';
import '../mappers/question_mapper.dart';

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
    return allQuestions.where((q) => q?.category == category).toList();
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
    // Fetch from Firestore (with auto-seed on first run)
    final models = await _dataSource.fetchQuestionsFromFirestore();

    // Convert to domain entities using mapper
    _cachedQuestions = QuestionMapper.toDomainList(models);
    _isLoaded = true;
  }

  @override
  Future<bool> isLoaded() async {
    return _isLoaded;
  }
}
