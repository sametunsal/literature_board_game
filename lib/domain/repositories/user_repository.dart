import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<void> createUserProfile(UserEntity user);
  Future<void> updateUserLastSeen(String uid);
  Future<UserEntity?> getUserProfile(String uid);
}
