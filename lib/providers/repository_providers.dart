/// Provider definitions for repository implementations.
/// Makes repositories injectable throughout the app.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/game_repository.dart';
import '../domain/repositories/player_repository.dart';
import '../domain/repositories/question_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/user_repository.dart';
import '../data/repositories/game_repository_impl.dart';
import '../data/repositories/player_repository_impl.dart';
import '../data/repositories/question_repository_impl.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../data/datasources/auth_data_source.dart';
import '../data/datasources/user_remote_data_source.dart';
import '../domain/usecases/ensure_signed_in_anonymously.dart';
import '../models/user_entity.dart';

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

// --- Local Auth & User ---

final _authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return LocalAuthDataSource();
});

final _userDataSourceProvider = Provider<UserDataSource>((ref) {
  return LocalUserDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return LocalAuthRepository(ref.watch(_authDataSourceProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return LocalUserRepository(ref.watch(_userDataSourceProvider));
});

final ensureSignedInAnonymouslyProvider = Provider<EnsureSignedInAnonymously>((
  ref,
) {
  return EnsureSignedInAnonymously(
    ref.watch(authRepositoryProvider),
    ref.watch(userRepositoryProvider),
  );
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUser;
});
