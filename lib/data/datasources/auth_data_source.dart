import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthDataSource {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<User> signInAnonymously();
}

class AuthDataSourceImpl implements AuthDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthDataSourceImpl(this._firebaseAuth);

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<User> signInAnonymously() async {
    final credential = await _firebaseAuth.signInAnonymously();
    return credential.user!;
  }
}
