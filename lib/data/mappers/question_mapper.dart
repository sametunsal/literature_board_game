/// Mapper for converting between QuestionModel (data layer) and Question (domain layer).
/// Pure Dart - no Flutter dependencies.

import '../../domain/entities/question.dart';
import '../../domain/entities/game_enums.dart';
import '../models/question_model.dart';

class QuestionMapper {
  QuestionMapper._();

  /// Convert QuestionCategoryModel to QuestionCategory
  static QuestionCategory _mapQuestionCategory(
    QuestionCategoryModel modelCategory,
  ) {
    return switch (modelCategory) {
      QuestionCategoryModel.benKimim => QuestionCategory.benKimim,
      QuestionCategoryModel.turkEdebiyatindaIlkler =>
        QuestionCategory.turkEdebiyatindaIlkler,
      QuestionCategoryModel.edebiyatAkimlari =>
        QuestionCategory.edebiyatAkimlari,
      QuestionCategoryModel.edebiSanatlar => QuestionCategory.edebiSanatlar,
      QuestionCategoryModel.eserKarakter => QuestionCategory.eserKarakter,
      QuestionCategoryModel.tesvik => QuestionCategory.tesvik,
    };
  }

  /// Convert QuestionCategory to QuestionCategoryModel
  static QuestionCategoryModel _mapQuestionCategoryModel(
    QuestionCategory domainCategory,
  ) {
    return switch (domainCategory) {
      QuestionCategory.benKimim => QuestionCategoryModel.benKimim,
      QuestionCategory.turkEdebiyatindaIlkler =>
        QuestionCategoryModel.turkEdebiyatindaIlkler,
      QuestionCategory.edebiyatAkimlari =>
        QuestionCategoryModel.edebiyatAkimlari,
      QuestionCategory.edebiSanatlar => QuestionCategoryModel.edebiSanatlar,
      QuestionCategory.eserKarakter => QuestionCategoryModel.eserKarakter,
      QuestionCategory.tesvik => QuestionCategoryModel.tesvik,
    };
  }

  /// Convert QuestionModel to Question domain entity
  static Question toDomain(QuestionModel model) {
    return Question(
      text: model.question,
      options: model.options,
      correctIndex: model.correctIndex,
      category: _mapQuestionCategory(model.category),
      difficulty: model.difficulty.name, // Pass difficulty as string
    );
  }

  /// Convert Question domain entity to QuestionModel
  static QuestionModel toData(Question entity, {String? id}) {
    return QuestionModel(
      id: id ?? '',
      question: entity.text,
      answer: entity.options[entity.correctIndex],
      options: entity.options,
      category: _mapQuestionCategoryModel(entity.category),
      difficulty: QuestionDifficultyModel.medium,
    );
  }

  /// Convert list of QuestionModel to list of Question
  static List<Question> toDomainList(List<QuestionModel> models) {
    return models.map((model) => toDomain(model)).toList();
  }

  /// Convert list of Question to list of QuestionModel
  static List<QuestionModel> toDataList(List<Question> entities) {
    return entities.map((entity) => toData(entity)).toList();
  }
}
