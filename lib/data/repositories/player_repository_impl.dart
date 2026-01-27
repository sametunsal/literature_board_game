/// Implementation of PlayerRepository.
/// Uses SharedPreferences for persistence.
/// Pure Dart - no Flutter dependencies (except SharedPreferences).

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/player.dart';
import '../../domain/repositories/player_repository.dart';

import '../models/player_model.dart';
import '../mappers/player_mapper.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  static const String _playersKey = 'players';

  PlayerRepositoryImpl();

  @override
  Future<List<Player>> getPlayers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_playersKey);

      if (jsonString == null) return [];

      final jsonList = json.decode(jsonString) as List<dynamic>;
      final playerModels = jsonList
          .map((e) => PlayerModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return PlayerMapper.toDomainList(playerModels);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> updatePlayer(Player player) async {
    try {
      final players = await getPlayers();
      final index = players.indexWhere((p) => p?.id == player.id);

      if (index >= 0) {
        players[index] = player;
      } else {
        players.add(player);
      }

      await _savePlayers(players);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Player?> getPlayer(String id) async {
    try {
      final players = await getPlayers();
      for (var player in players) {
        if (player.id == id) return player;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Player?> getCurrentPlayer(int index) async {
    try {
      final players = await getPlayers();
      if (index >= 0 && index < players.length) {
        return players[index];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _savePlayers(List<Player> players) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playerModels = PlayerMapper.toDataList(players);
      final jsonString = json.encode(
        playerModels.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(_playersKey, jsonString);
    } catch (e) {
      rethrow;
    }
  }
}
