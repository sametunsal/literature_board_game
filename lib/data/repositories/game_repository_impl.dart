/// Implementation of GameRepository.
/// Uses SharedPreferences for persistence.
/// Pure Dart - no Flutter dependencies (except SharedPreferences).

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/player.dart';
import '../../models/board_tile.dart';
import '../../models/game_enums.dart';
import '../../domain/repositories/game_repository.dart';
import '../models/player_model.dart';
import '../models/board_tile_model.dart';
import '../mappers/player_mapper.dart';
import '../mappers/tile_mapper.dart';

class GameRepositoryImpl implements GameRepository {
  static const String _gameStateKey = 'game_state';

  GameRepositoryImpl();

  @override
  Future<void> saveGameState({
    required List<Player> players,
    required List<BoardTile> tiles,
    required int currentPlayerIndex,
    required GamePhase phase,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert domain entities to data models
      final playerModels = PlayerMapper.toDataList(players);
      final tileModels = TileMapper.toDataList(tiles);

      final gameState = {
        'players': playerModels.map((p) => p.toJson()).toList(),
        'tiles': tileModels.map((t) => t.toJson()).toList(),
        'currentPlayerIndex': currentPlayerIndex,
        'phase': phase.name,
      };

      await prefs.setString(_gameStateKey, json.encode(gameState));
    } catch (e) {
      // Handle error silently for now
      rethrow;
    }
  }

  @override
  Future<GameStateData?> loadGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_gameStateKey);

      if (jsonString == null) return null;

      final decodedJson = json.decode(jsonString) as Map<String, dynamic>;

      // Convert data models to domain entities
      final playerModels = (decodedJson['players'] as List<dynamic>)
          .map((e) => PlayerModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final tileModels = (decodedJson['tiles'] as List<dynamic>)
          .map((e) => BoardTileModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final players = PlayerMapper.toDomainList(playerModels);
      final tiles = TileMapper.toDomainList(tileModels);

      final phase = GamePhase.values.firstWhere(
        (e) => e.name == decodedJson['phase'],
        orElse: () => GamePhase.setup,
      );

      return GameStateData(
        players: players,
        tiles: tiles,
        currentPlayerIndex: decodedJson['currentPlayerIndex'] as int,
        phase: phase,
      );
    } catch (e) {
      // Handle error silently for now
      return null;
    }
  }

  @override
  Future<void> clearGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_gameStateKey);
    } catch (e) {
      // Handle error silently for now
      rethrow;
    }
  }

  @override
  Future<bool> hasSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_gameStateKey);
    } catch (e) {
      return false;
    }
  }
}
