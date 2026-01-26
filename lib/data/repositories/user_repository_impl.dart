import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<void> createUserProfile(UserEntity user) =>
      _dataSource.createUser(user);

  @override
  Future<void> updateUserLastSeen(String uid) =>
      _dataSource.updateLastSeen(uid);

  @override
  Future<UserEntity?> getUserProfile(String uid) => _dataSource.getUser(uid);
}
