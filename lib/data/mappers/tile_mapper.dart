/// Mapper for converting between BoardTileModel (data layer) and BoardTile (domain layer).
/// Pure Dart - no Flutter dependencies.

import '../../domain/entities/board_tile.dart';
import '../../domain/entities/game_enums.dart';
import '../models/board_tile_model.dart';

class TileMapper {
  TileMapper._();

  /// Convert TileTypeModel to TileType
  static TileType _mapTileType(TileTypeModel modelType) {
    return switch (modelType) {
      TileTypeModel.start => TileType.start,
      TileTypeModel.property => TileType.property,
      TileTypeModel.chance => TileType.chance,
      TileTypeModel.fate => TileType.fate,
      TileTypeModel.kiraathane => TileType.kiraathane,
    };
  }

  /// Convert TileType to TileTypeModel
  static TileTypeModel _mapTileTypeModel(TileType domainType) {
    return switch (domainType) {
      TileType.start => TileTypeModel.start,
      TileType.property => TileTypeModel.property,
      TileType.chance => TileTypeModel.chance,
      TileType.fate => TileTypeModel.fate,
      TileType.kiraathane => TileTypeModel.kiraathane,
    };
  }

  /// Convert QuestionCategoryModel to QuestionCategory
  static QuestionCategory? _mapQuestionCategory(
    QuestionCategoryModel? modelCategory,
  ) {
    if (modelCategory == null) return null;
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
  static QuestionCategoryModel? _mapQuestionCategoryModel(
    QuestionCategory? domainCategory,
  ) {
    if (domainCategory == null) return null;
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

  /// Difficulty mapping
  static Difficulty _mapDifficulty(DifficultyModel model) {
    return switch (model) {
      DifficultyModel.easy => Difficulty.easy,
      DifficultyModel.medium => Difficulty.medium,
      DifficultyModel.hard => Difficulty.hard,
    };
  }

  static DifficultyModel _mapDifficultyModel(Difficulty domain) {
    return switch (domain) {
      Difficulty.easy => DifficultyModel.easy,
      Difficulty.medium => DifficultyModel.medium,
      Difficulty.hard => DifficultyModel.hard,
    };
  }

  /// Convert BoardTileModel to BoardTile domain entity
  static BoardTile toDomain(BoardTileModel model) {
    return BoardTile(
      id: model.id,
      title: model.title,
      type: _mapTileType(model.type),
      category: _mapQuestionCategory(model.category),
      difficulty: _mapDifficulty(model.difficulty),
    );
  }

  /// Convert BoardTile domain entity to BoardTileModel
  static BoardTileModel toData(BoardTile entity) {
    return BoardTileModel(
      id: entity.id,
      title: entity.title,
      type: _mapTileTypeModel(entity.type),
      category: _mapQuestionCategoryModel(entity.category),
      difficulty: _mapDifficultyModel(entity.difficulty),
    );
  }

  /// Convert list of BoardTileModel to list of BoardTile
  static List<BoardTile> toDomainList(List<BoardTileModel> models) {
    return models.map((model) => toDomain(model)).toList();
  }

  /// Convert list of BoardTile to list of BoardTileModel
  static List<BoardTileModel> toDataList(List<BoardTile> entities) {
    return entities.map((entity) => toData(entity)).toList();
  }
}
