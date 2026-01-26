import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity> signInAnonymously();
  UserEntity? get currentUser;
}
