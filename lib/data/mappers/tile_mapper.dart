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
      TileTypeModel.publisher => TileType.publisher,
      TileTypeModel.chance => TileType.chance,
      TileTypeModel.fate => TileType.fate,
      TileTypeModel.libraryWatch => TileType.libraryWatch,
      TileTypeModel.autographDay => TileType.autographDay,
      TileTypeModel.bankruptcyRisk => TileType.bankruptcyRisk,
      TileTypeModel.writingSchool => TileType.writingSchool,
      TileTypeModel.educationFoundation => TileType.educationFoundation,
      TileTypeModel.incomeTax => TileType.incomeTax,
      TileTypeModel.writingTax => TileType.writingTax,
    };
  }

  /// Convert TileType to TileTypeModel
  static TileTypeModel _mapTileTypeModel(TileType domainType) {
    return switch (domainType) {
      TileType.start => TileTypeModel.start,
      TileType.property => TileTypeModel.property,
      TileType.publisher => TileTypeModel.publisher,
      TileType.chance => TileTypeModel.chance,
      TileType.fate => TileTypeModel.fate,
      TileType.libraryWatch => TileTypeModel.libraryWatch,
      TileType.autographDay => TileTypeModel.autographDay,
      TileType.bankruptcyRisk => TileTypeModel.bankruptcyRisk,
      TileType.writingSchool => TileTypeModel.writingSchool,
      TileType.educationFoundation => TileTypeModel.educationFoundation,
      TileType.incomeTax => TileTypeModel.incomeTax,
      TileType.writingTax => TileTypeModel.writingTax,
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
      QuestionCategoryModel.bonusBilgiler => QuestionCategory.bonusBilgiler,
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
      QuestionCategory.bonusBilgiler => QuestionCategoryModel.bonusBilgiler,
    };
  }

  /// Convert PropertyColorGroupModel to PropertyColorGroup
  static PropertyColorGroup? _mapPropertyColorGroup(
    PropertyColorGroupModel? modelGroup,
  ) {
    if (modelGroup == null) return null;
    return switch (modelGroup) {
      PropertyColorGroupModel.brown => PropertyColorGroup.brown,
      PropertyColorGroupModel.lightBlue => PropertyColorGroup.lightBlue,
      PropertyColorGroupModel.pink => PropertyColorGroup.pink,
      PropertyColorGroupModel.orange => PropertyColorGroup.orange,
      PropertyColorGroupModel.red => PropertyColorGroup.red,
      PropertyColorGroupModel.yellow => PropertyColorGroup.yellow,
      PropertyColorGroupModel.green => PropertyColorGroup.green,
      PropertyColorGroupModel.blue => PropertyColorGroup.blue,
      PropertyColorGroupModel.utility => PropertyColorGroup.utility,
      PropertyColorGroupModel.special => PropertyColorGroup.special,
    };
  }

  /// Convert PropertyColorGroup to PropertyColorGroupModel
  static PropertyColorGroupModel? _mapPropertyColorGroupModel(
    PropertyColorGroup? domainGroup,
  ) {
    if (domainGroup == null) return null;
    return switch (domainGroup) {
      PropertyColorGroup.brown => PropertyColorGroupModel.brown,
      PropertyColorGroup.lightBlue => PropertyColorGroupModel.lightBlue,
      PropertyColorGroup.pink => PropertyColorGroupModel.pink,
      PropertyColorGroup.orange => PropertyColorGroupModel.orange,
      PropertyColorGroup.red => PropertyColorGroupModel.red,
      PropertyColorGroup.yellow => PropertyColorGroupModel.yellow,
      PropertyColorGroup.green => PropertyColorGroupModel.green,
      PropertyColorGroup.blue => PropertyColorGroupModel.blue,
      PropertyColorGroup.utility => PropertyColorGroupModel.utility,
      PropertyColorGroup.special => PropertyColorGroupModel.special,
    };
  }

  /// Convert BoardTileModel to BoardTile domain entity
  static BoardTile toDomain(BoardTileModel model) {
    return BoardTile(
      id: model.id,
      title: model.title,
      type: _mapTileType(model.type),
      price: model.price,
      baseRent: model.baseRent,
      category: _mapQuestionCategory(model.category),
      isUtility: model.isUtility,
      upgradeLevel: model.upgradeLevel,
      colorGroup: _mapPropertyColorGroup(model.colorGroup),
    );
  }

  /// Convert BoardTile domain entity to BoardTileModel
  static BoardTileModel toData(BoardTile entity) {
    return BoardTileModel(
      id: entity.id,
      title: entity.title,
      type: _mapTileTypeModel(entity.type),
      price: entity.price,
      baseRent: entity.baseRent,
      category: _mapQuestionCategoryModel(entity.category),
      isUtility: entity.isUtility,
      upgradeLevel: entity.upgradeLevel,
      colorGroup: _mapPropertyColorGroupModel(entity.colorGroup),
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
