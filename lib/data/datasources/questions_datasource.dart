/// Data source for questions.
/// Loads questions from local JSON asset only - no server connection.
library;

import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import '../models/question_model.dart';

class QuestionsDataSource {
  QuestionsDataSource._();

  static final QuestionsDataSource instance = QuestionsDataSource._();

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
      debugPrint('[QuestionsDataSource] ERROR loading JSON: $e');
      debugPrint('[QuestionsDataSource] Stack trace:\n$stackTrace');
      return [];
    }
  }
}
