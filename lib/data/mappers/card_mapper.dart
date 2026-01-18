/// Mapper for converting between GameCardModel (data layer) and GameCard (domain layer).
/// Pure Dart - no Flutter dependencies.

import '../../domain/entities/game_card.dart';
import '../../domain/entities/game_enums.dart';
import '../models/game_card_model.dart';

class CardMapper {
  CardMapper._();

  /// Convert CardEffectTypeModel to CardEffectType
  static CardEffectType _mapCardEffectType(CardEffectTypeModel modelType) {
    return switch (modelType) {
      CardEffectTypeModel.moneyChange => CardEffectType.moneyChange,
      CardEffectTypeModel.move => CardEffectType.move,
      CardEffectTypeModel.jail => CardEffectType.jail,
      CardEffectTypeModel.globalMoney => CardEffectType.globalMoney,
    };
  }

  /// Convert CardEffectType to CardEffectTypeModel
  static CardEffectTypeModel _mapCardEffectTypeModel(
    CardEffectType domainType,
  ) {
    return switch (domainType) {
      CardEffectType.moneyChange => CardEffectTypeModel.moneyChange,
      CardEffectType.move => CardEffectTypeModel.move,
      CardEffectType.jail => CardEffectTypeModel.jail,
      CardEffectType.globalMoney => CardEffectTypeModel.globalMoney,
    };
  }

  /// Convert CardTypeModel to CardType
  static CardType _mapCardType(CardTypeModel modelType) {
    return switch (modelType) {
      CardTypeModel.sans => CardType.sans,
      CardTypeModel.kader => CardType.kader,
    };
  }

  /// Convert CardType to CardTypeModel
  static CardTypeModel _mapCardTypeModel(CardType domainType) {
    return switch (domainType) {
      CardType.sans => CardTypeModel.sans,
      CardType.kader => CardTypeModel.kader,
    };
  }

  /// Convert GameCardModel to GameCard domain entity
  static GameCard toDomain(GameCardModel model) {
    return GameCard(
      description: model.description,
      type: _mapCardType(model.type),
      effectType: _mapCardEffectType(model.effectType),
      value: model.value,
    );
  }

  /// Convert GameCard domain entity to GameCardModel
  static GameCardModel toData(GameCard entity) {
    return GameCardModel(
      description: entity.description,
      type: _mapCardTypeModel(entity.type),
      effectType: _mapCardEffectTypeModel(entity.effectType),
      value: entity.value,
    );
  }

  /// Convert list of GameCardModel to list of GameCard
  static List<GameCard> toDomainList(List<GameCardModel> models) {
    return models.map((model) => toDomain(model)).toList();
  }

  /// Convert list of GameCard to list of GameCardModel
  static List<GameCardModel> toDataList(List<GameCard> entities) {
    return entities.map((entity) => toData(entity)).toList();
  }
}
