/// Mapper for converting between PlayerModel (data layer) and Player (domain layer).
/// Pure Dart - no Flutter dependencies.

import '../../domain/entities/player.dart';
import '../models/player_model.dart';

class PlayerMapper {
  PlayerMapper._();

  /// Convert PlayerModel to Player domain entity
  static Player toDomain(PlayerModel model) {
    return Player(
      id: model.id,
      name: model.name,
      iconIndex: model.iconIndex,
      balance: model.balance,
      position: model.position,
      ownedTiles: model.ownedTiles,
      inJail: model.inJail,
      turnsToSkip: model.turnsToSkip,
    );
  }

  /// Convert Player domain entity to PlayerModel
  static PlayerModel toData(Player entity) {
    return PlayerModel(
      id: entity.id,
      name: entity.name,
      iconIndex: entity.iconIndex,
      balance: entity.balance,
      position: entity.position,
      ownedTiles: entity.ownedTiles,
      inJail: entity.inJail,
      turnsToSkip: entity.turnsToSkip,
    );
  }

  /// Convert list of PlayerModel to list of Player
  static List<Player> toDomainList(List<PlayerModel> models) {
    return models.map((model) => toDomain(model)).toList();
  }

  /// Convert list of Player to list of PlayerModel
  static List<PlayerModel> toDataList(List<Player> entities) {
    return entities.map((entity) => toData(entity)).toList();
  }
}
