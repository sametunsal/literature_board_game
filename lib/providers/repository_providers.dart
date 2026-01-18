/// Provider definitions for repository implementations.
/// Makes repositories injectable throughout the app.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/game_repository.dart';
import '../domain/repositories/player_repository.dart';
import '../domain/repositories/question_repository.dart';
import '../data/repositories/game_repository_impl.dart';
import '../data/repositories/player_repository_impl.dart';
import '../data/repositories/question_repository_impl.dart';

/// Provider for GameRepository implementation
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl();
});

/// Provider for PlayerRepository implementation
final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepositoryImpl();
});

/// Provider for QuestionRepository implementation
final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepositoryImpl();
});
