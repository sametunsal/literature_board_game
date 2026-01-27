/// Mapper for converting between Player (domain layer) and data layer.

import 'package:flutter/material.dart';
import '../../models/player.dart';

class PlayerMapper {
  PlayerMapper._();

  /// Convert Player domain entity to data layer JSON
  static Map<String, dynamic> toData(Player entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'color': entity.color.value.toString(),
      'iconIndex': entity.iconIndex,
      'stars': entity.stars,
      'position': entity.position,
      'collectedQuotes': entity.collectedQuotes,
      'inJail': entity.inJail,
      'turnsToSkip': entity.turnsToSkip,
      'categoryLevels': entity.categoryLevels,
      'mainTitle': entity.mainTitle,
      'correctAnswers': entity.correctAnswers,
    };
  }

  /// Convert data layer JSON to Player domain entity
  static Player toDomain(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(int.parse(json['color'] as String)),
      iconIndex: json['iconIndex'] as int,
      stars: json['stars'] as int,
      position: json['position'] as int? ?? 0,
      collectedQuotes:
          (json['collectedQuotes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      inJail: json['inJail'] as bool? ?? false,
      turnsToSkip: json['turnsToSkip'] as int? ?? 0,
      categoryLevels:
          (json['categoryLevels'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
      mainTitle: json['mainTitle'] as String? ?? 'Çaylak',
      correctAnswers:
          (json['correctAnswers'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
    );
  }

  /// Convert list of Player to list of JSON objects
  static List<Map<String, dynamic>> toDataList(List<Player> entities) {
    return entities.map((entity) => toData(entity)).toList();
  }

  /// Convert list of JSON objects to list of Player
  static List<Player> toDomainList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => toDomain(json)).toList();
  }
}
