import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Stream<UserEntity?> get authStateChanges =>
      _dataSource.authStateChanges.map(_mapFirebaseUser);

  @override
  UserEntity? get currentUser => _mapFirebaseUser(_dataSource.currentUser);

  @override
  Future<UserEntity> signInAnonymously() async {
    final user = await _dataSource.signInAnonymously();
    return _mapFirebaseUser(user)!;
  }

  UserEntity? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return UserEntity(
      uid: user.uid,
      isAnonymous: user.isAnonymous,
      displayName: user.displayName,
    );
  }
}
