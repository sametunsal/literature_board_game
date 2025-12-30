import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/question.dart';

/// Repository for literature questions loaded from JSON asset
class QuestionRepository {
  static List<Question>? _cachedQuestions;
  static bool _isLoading = false;

  /// Load questions from JSON asset (call once at app startup)
  static Future<void> loadQuestions() async {
    if (_cachedQuestions != null || _isLoading) return;

    _isLoading = true;

    try {
      // Load JSON from assets
      final String jsonString = await rootBundle.loadString(
        'assets/data/questions.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      // Parse questions
      _cachedQuestions = jsonList.map((json) {
        return Question(
          id: json['id'] as String,
          category: _parseCategory(json['category'] as String),
          difficulty: _parseDifficulty(json['difficulty'] as String),
          question: json['question'] as String,
          answer: json['answer'] as String,
          options: json['options'] != null
              ? List<String>.from(json['options'] as List)
              : null,
          hint: json['hint'] as String?,
        );
      }).toList();

      print('✅ Loaded ${_cachedQuestions!.length} questions from JSON');
    } catch (e) {
      print('❌ Error loading questions from JSON: $e');
      // Fallback to minimal hardcoded list if JSON fails
      _cachedQuestions = _getFallbackQuestions();
    } finally {
      _isLoading = false;
    }
  }

  /// Get a random question from specified category
  static Question getRandomQuestion(QuestionCategory category) {
    if (_cachedQuestions == null) {
      print('⚠️ Questions not loaded yet, using fallback');
      _cachedQuestions = _getFallbackQuestions();
    }

    final questions = _getQuestionsByCategory(category);
    if (questions.isEmpty) {
      print('⚠️ No questions found for category $category');
      // Return a generic fallback question
      return Question(
        id: 'fallback',
        category: category,
        difficulty: Difficulty.easy,
        question: 'Bu kategori için soru bulunamadı.',
        answer: 'Tekrar Deneyin',
        options: ['Tekrar Deneyin', 'İptal', 'Geri', 'Çıkış'],
      );
    }

    final random = DateTime.now().millisecond % questions.length;
    return questions[random];
  }

  /// Get all questions for a category
  static List<Question> _getQuestionsByCategory(QuestionCategory category) {
    if (_cachedQuestions == null) return [];

    return _cachedQuestions!.where((q) => q.category == category).toList();
  }

  /// Get all questions as a pool
  static List<Question> getAllQuestions() {
    return _cachedQuestions ?? _getFallbackQuestions();
  }

  /// Parse category string to enum
  static QuestionCategory _parseCategory(String category) {
    switch (category) {
      case 'benKimim':
        return QuestionCategory.benKimim;
      case 'turkEdebiyatindaIlkler':
        return QuestionCategory.turkEdebiyatindaIlkler;
      case 'edebiyatAkimlari':
        return QuestionCategory.edebiyatAkimlari;
      case 'edebiyatSanatlari':
        return QuestionCategory.edebiyatSanatlari;
      case 'eserKarakter':
        return QuestionCategory.eserKarakter;
      default:
        print('⚠️ Unknown category: $category, defaulting to benKimim');
        return QuestionCategory.benKimim;
    }
  }

  /// Parse difficulty string to enum
  static Difficulty _parseDifficulty(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Difficulty.easy;
      case 'medium':
        return Difficulty.medium;
      case 'hard':
        return Difficulty.hard;
      default:
        print('⚠️ Unknown difficulty: $difficulty, defaulting to easy');
        return Difficulty.easy;
    }
  }

  /// Fallback questions if JSON loading fails
  static List<Question> _getFallbackQuestions() {
    return [
      Question(
        id: 'fb_001',
        category: QuestionCategory.benKimim,
        difficulty: Difficulty.easy,
        question: 'Hangi yazar Tutunamayanlar romanının yazarıdır?',
        answer: 'Oğuz Atay',
        options: [
          'Oğuz Atay',
          'Yaşar Kemal',
          'Sabahattin Ali',
          'Sait Faik Abasıyanık',
        ],
      ),
      Question(
        id: 'fb_002',
        category: QuestionCategory.turkEdebiyatindaIlkler,
        difficulty: Difficulty.easy,
        question: 'Türk edebiyatında ilk roman hangisidir?',
        answer: 'İntibah',
        options: [
          'İntibah',
          'Araba Sevdası',
          'Taaşşuk-ı Talat ve Fitnat',
          'İnce Memed',
        ],
      ),
      Question(
        id: 'fb_003',
        category: QuestionCategory.edebiyatAkimlari,
        difficulty: Difficulty.easy,
        question: 'Servet-i Fünun dergisi hangi edebi akımı temsil eder?',
        answer: 'Servet-i Fünun Edebiyatı',
        options: [
          'Servet-i Fünun Edebiyatı',
          'Milli Edebiyat',
          'Yedi Meşale',
          'Garip Akımı',
        ],
      ),
      Question(
        id: 'fb_004',
        category: QuestionCategory.edebiyatSanatlari,
        difficulty: Difficulty.easy,
        question: 'Divan edebiyatında beyit kaç dizeden oluşur?',
        answer: '2',
        options: ['2', '3', '4', '5'],
      ),
      Question(
        id: 'fb_005',
        category: QuestionCategory.eserKarakter,
        difficulty: Difficulty.easy,
        question: 'İnce Memed romanında ana karakterin sevgilisinin adı nedir?',
        answer: 'Hatçe',
        options: ['Hatçe', 'Meleke', 'Çakırcı Mehmet', 'Işık'],
      ),
    ];
  }
}
