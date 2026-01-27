/// Mapper for converting between GameCard (domain layer) and JSON (data layer).
/// Pure Dart - no Flutter dependencies.

import '../../models/game_card.dart';
import '../../models/game_enums.dart';

class CardMapper {
  CardMapper._();

  /// Convert GameCard domain entity to data layer JSON
  static Map<String, dynamic> toData(GameCard entity) {
    return {
      'description': entity.description,
      'type': entity.type.name,
      'effectType': entity.effectType.name,
      'value': entity.value,
    };
  }

  /// Convert data layer JSON to GameCard domain entity
  static GameCard toDomain(Map<String, dynamic> json) {
    return GameCard(
      description: json['description'] as String,
      type: CardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CardType.sans,
      ),
      effectType: CardEffectType.values.firstWhere(
        (e) => e.name == json['effectType'],
        orElse: () => CardEffectType.moneyChange,
      ),
      value: json['value'] as int? ?? 0,
    );
  }

  /// Convert list of GameCard to list of JSON objects
  static List<Map<String, dynamic>> toDataList(List<GameCard> entities) {
    return entities.map((entity) => toData(entity)).toList();
  }

  /// Convert list of JSON objects to list of GameCard
  static List<GameCard> toDomainList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => toDomain(json)).toList();
  }
}
