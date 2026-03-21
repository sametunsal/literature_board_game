/// Local authentication data source.
/// Returns a dummy guest user - no server connection.
library;

import '../../models/user_entity.dart';

abstract class AuthDataSource {
  UserEntity? get currentUser;
  Future<UserEntity> signInAnonymously();
}

class LocalAuthDataSource implements AuthDataSource {
  static const String _guestUid = 'local_guest_user';

  UserEntity? _currentUser;

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  Future<UserEntity> signInAnonymously() async {
    _currentUser = UserEntity(
      uid: _guestUid,
      isAnonymous: true,
      displayName: 'Misafir',
      createdAt: DateTime.now(),
      lastSeenAt: DateTime.now(),
    );
    return _currentUser!;
  }
}
