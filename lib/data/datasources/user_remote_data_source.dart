/// Local user data source.
/// No-op implementation - no remote server connection.
library;

import '../../models/user_entity.dart';

abstract class UserDataSource {
  Future<void> createUser(UserEntity user);
  Future<void> updateLastSeen(String uid);
  Future<UserEntity?> getUser(String uid);
}

class LocalUserDataSource implements UserDataSource {
  UserEntity? _storedUser;

  @override
  Future<void> createUser(UserEntity user) async {
    _storedUser = user;
  }

  @override
  Future<void> updateLastSeen(String uid) async {
    if (_storedUser != null && _storedUser!.uid == uid) {
      _storedUser = UserEntity(
        uid: _storedUser!.uid,
        isAnonymous: _storedUser!.isAnonymous,
        displayName: _storedUser!.displayName,
        createdAt: _storedUser!.createdAt,
        lastSeenAt: DateTime.now(),
      );
    }
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    if (_storedUser != null && _storedUser!.uid == uid) {
      return _storedUser;
    }
    return null;
  }
}
