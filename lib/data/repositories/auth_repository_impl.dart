/// Local auth repository implementation.
/// Returns a dummy guest user - no server connection.
library;

import 'dart:async';
import '../../models/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';

class LocalAuthRepository implements AuthRepository {
  final AuthDataSource _dataSource;
  final _authStateController = StreamController<UserEntity?>.broadcast();

  LocalAuthRepository(this._dataSource);

  @override
  Stream<UserEntity?> get authStateChanges => _authStateController.stream;

  @override
  UserEntity? get currentUser => _dataSource.currentUser;

  @override
  Future<UserEntity> signInAnonymously() async {
    final user = await _dataSource.signInAnonymously();
    _authStateController.add(user);
    return user;
  }

  void dispose() {
    _authStateController.close();
  }
}
