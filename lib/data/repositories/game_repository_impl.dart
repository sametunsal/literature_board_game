/// Implementation of GameRepository.
/// Uses SharedPreferences for persistence.
/// Pure Dart - no Flutter dependencies (except SharedPreferences).

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/player.dart';
import '../../models/board_tile.dart';
import '../../models/game_enums.dart';
import '../../domain/repositories/game_repository.dart';
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

      // Convert domain entities to JSON
      final playerJson = PlayerMapper.toDataList(players);
      final tileJson = TileMapper.toDataList(tiles);

      final gameState = {
        'players': playerJson,
        'tiles': tileJson,
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

      // Convert JSON to domain entities using mappers
      final playerJson = (decodedJson['players'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final tileJson = (decodedJson['tiles'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      final players = PlayerMapper.toDomainList(playerJson);
      final tiles = TileMapper.toDomainList(tileJson);

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
