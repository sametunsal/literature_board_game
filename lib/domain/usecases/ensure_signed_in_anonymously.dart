import '../../models/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

class EnsureSignedInAnonymously {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  EnsureSignedInAnonymously(this._authRepository, this._userRepository);

  Future<UserEntity> call() async {
    final currentUser = _authRepository.currentUser;

    if (currentUser != null) {
      // User is already signed in, just update last seen
      await _userRepository.updateUserLastSeen(currentUser.uid);
      return currentUser;
    }

    // Sign in anonymously
    final user = await _authRepository.signInAnonymously();

    // Create initial profile
    await _userRepository.createUserProfile(user);

    return user;
  }
}
