/// Mapper for converting between BoardTile (domain layer) and data layer.
/// Pure Dart - no Flutter dependencies.
library;

import '../../models/board_tile.dart';
import '../../models/tile_type.dart';
import '../../models/difficulty.dart';

class TileMapper {
  TileMapper._();

  /// Convert BoardTile domain entity to data layer JSON
  static Map<String, dynamic> toData(BoardTile entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'position': entity.position,
      'type': entity.type.name,
      'category': entity.category,
      'difficulty': entity.difficulty.name,
    };
  }

  /// Convert data layer JSON to BoardTile domain entity
  static BoardTile toDomain(Map<String, dynamic> json) {
    return BoardTile(
      id: json['id'] as String,
      name: json['name'] as String,
      position: json['position'] as int,
      type: TileType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TileType.category,
      ),
      category: json['category'] as String?,
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => Difficulty.medium,
      ),
    );
  }

  /// Convert list of BoardTile to list of JSON objects
  static List<Map<String, dynamic>> toDataList(List<BoardTile> entities) {
    return entities.map((entity) => toData(entity)).toList();
  }

  /// Convert list of JSON objects to list of BoardTile
  static List<BoardTile> toDomainList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => toDomain(json)).toList();
  }
}
