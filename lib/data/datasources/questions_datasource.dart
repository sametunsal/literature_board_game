/// Data source for questions.
/// Integrates with Firebase Firestore with auto-seeding from local JSON.

import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/game_enums.dart';
import '../models/question_model.dart';

class QuestionsDataSource {
  final FirebaseFirestore _firestore;

  QuestionsDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Singleton for backward compatibility
  static QuestionsDataSource? _instance;
  static QuestionsDataSource get instance {
    _instance ??= QuestionsDataSource();
    return _instance!;
  }

  /// Main entry point: Fetch questions from Firestore with auto-seed
  /// - Checks if 'questions' collection is empty
  /// - If empty, seeds from local JSON
  /// - Returns all questions from Firestore
  Future<List<QuestionModel>> fetchQuestionsFromFirestore() async {
    debugPrint('[QuestionsDataSource] fetchQuestionsFromFirestore() STARTED');

    try {
      final collection = _firestore.collection('questions');
      debugPrint(
        '[QuestionsDataSource] Checking if "questions" collection is empty...',
      );

      // 1. Check if collection is empty
      final snapshot = await collection.limit(1).get();
      final isEmpty = snapshot.docs.isEmpty;
      debugPrint(
        '[QuestionsDataSource] Collection empty? $isEmpty (found ${snapshot.docs.length} docs in limit check)',
      );

      // 2. If empty, auto-seed from local JSON
      if (isEmpty) {
        debugPrint(
          '[QuestionsDataSource] Collection is EMPTY - starting auto-seed...',
        );
        await _seedQuestionsToFirestore(collection);
      } else {
        debugPrint(
          '[QuestionsDataSource] Collection already has data - skipping seed',
        );
      }

      // 3. Fetch all questions from Firestore
      debugPrint(
        '[QuestionsDataSource] Fetching all questions from Firestore...',
      );
      final allDocs = await collection.get();
      debugPrint(
        '[QuestionsDataSource] Fetched ${allDocs.docs.length} questions from Firestore',
      );

      return allDocs.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Inject document ID
        return QuestionModel.fromJson(data);
      }).toList();
    } catch (e, stackTrace) {
      debugPrint(
        '[QuestionsDataSource] ERROR in fetchQuestionsFromFirestore: $e',
      );
      debugPrint('[QuestionsDataSource] Stack trace:\n$stackTrace');
      rethrow;
    }
  }

  /// Seed questions from local JSON to Firestore (batch write)
  Future<void> _seedQuestionsToFirestore(CollectionReference collection) async {
    debugPrint('[QuestionsDataSource] _seedQuestionsToFirestore() STARTED');

    try {
      final localQuestions = await loadQuestionsFromJson(
        'assets/data/questions.json',
      );

      if (localQuestions.isEmpty) {
        debugPrint(
          '[QuestionsDataSource] WARNING: No questions loaded from local JSON - aborting seed',
        );
        return;
      }

      debugPrint(
        '[QuestionsDataSource] Loaded ${localQuestions.length} questions from local JSON',
      );
      debugPrint('[QuestionsDataSource] Starting batch write to Firestore...');

      // Use batch for efficient writes (max 500 per batch)
      final batch = _firestore.batch();

      for (final question in localQuestions) {
        final docRef = collection.doc(question.id);
        batch.set(docRef, question.toJson());
      }

      await batch.commit();
      debugPrint(
        '[QuestionsDataSource] ✅ SUCCESS: batch.commit() completed - ${localQuestions.length} questions seeded to Firestore',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[QuestionsDataSource] ❌ ERROR in _seedQuestionsToFirestore: $e',
      );
      debugPrint('[QuestionsDataSource] Stack trace:\n$stackTrace');
      rethrow;
    }
  }

  /// Load questions from local JSON asset
  Future<List<QuestionModel>> loadQuestionsFromJson(String assetPath) async {
    debugPrint(
      '[QuestionsDataSource] loadQuestionsFromJson("$assetPath") STARTED',
    );

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      final models = jsonList
          .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
          .toList();
      debugPrint(
        '[QuestionsDataSource] Parsed ${models.length} questions from JSON',
      );
      return models;
    } catch (e, stackTrace) {
      debugPrint('[QuestionsDataSource] ❌ ERROR loading JSON: $e');
      debugPrint('[QuestionsDataSource] Stack trace:\n$stackTrace');
      return [];
    }
  }

  // --- Legacy methods for backward compatibility ---

  /// Get all questions as domain entities (synchronous - deprecated)
  List<Question> getQuestions() {
    // This method is synchronous and cannot fetch from Firestore
    // Use fetchQuestionsFromFirestore() instead
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
    return questions[(questions.length * DateTime.now().millisecond) %
        questions.length];
  }
}
