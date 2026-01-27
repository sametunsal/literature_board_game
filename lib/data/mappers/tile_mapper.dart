/// Mapper for converting between BoardTile (data layer) and BoardTile (domain layer).
/// Pure Dart - no Flutter dependencies.

import '../../models/board_tile.dart';
import '../../models/tile_type.dart';
import '../../models/difficulty.dart';

class TileMapper {
  TileMapper._();

  /// Convert TileType to TileTypeModel
  static TileTypeModel _mapTileTypeModel(TileType domainType) {
    return switch (domainType) {
      TileType.start => TileTypeModel.start,
      TileType.category => TileTypeModel.category,
      TileType.corner => TileTypeModel.corner,
      TileType.shop => TileTypeModel.shop,
      TileType.collection => TileTypeModel.collection,
    };
  }

  /// Convert TileTypeModel to TileType
  static TileType _mapTileTypeModel(TileTypeModel domainType) {
    return switch (domainType) {
      TileTypeModel.start => TileType.start,
      TileTypeModel.category => TileTypeModel.category,
      TileTypeModel.corner => TileTypeModel.corner,
      TileTypeModel.shop => TileTypeModel.shop,
      TileTypeModel.collection => TileTypeModel.collection,
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
  static DifficultyModel _mapDifficulty(Difficulty domain) {
    return switch (domain) {
      Difficulty.easy => DifficultyModel.easy,
      Difficulty.medium => DifficultyModel.medium,
      Difficulty.hard => DifficultyModel.hard,
    };
  }

  static DifficultyModel _mapDifficultyModel(Difficulty domain) {
    return switch (domain) {
      Difficulty.easy => DifficultyModel.easy,
      Difficulty.medium => DifficultyModel.medium,
      Difficulty.hard => DifficultyModel.hard,
    };
  }

  /// Convert BoardTile to BoardTile domain entity
  static BoardTile toDomain(BoardTile model) {
    return BoardTile(
      id: model.id,
      name: model.name,
      type: _mapTileTypeModel(model.type),
      category: _mapQuestionCategory(model.category),
      difficulty: _mapDifficultyModel(model.difficulty),
    );
  }

  /// Convert BoardTile domain entity to BoardTile
  static BoardTile toData(BoardTile entity) {
    return BoardTile(
      id: entity.id,
      name: entity.name,
      type: _mapTileTypeModel(entity.type),
      category: _mapQuestionCategoryModel(entity.category),
      difficulty: _mapDifficultyModel(entity.difficulty),
    );
  }

  /// Convert list of BoardTile to list of BoardTile
  static List<BoardTile> toDomainList(List<BoardTile> models) {
    return models.map((model) => toDomain(model)).toList();
  }

  /// Convert list of BoardTile to list of BoardTile
  static List<BoardTile> toDataList(List<BoardTile> entities) {
    return entities.map((entity) => toData(entity)).toList();
  }
}
