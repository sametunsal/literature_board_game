import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_entity.dart';

abstract class UserRemoteDataSource {
  Future<void> createUser(UserEntity user);
  Future<void> updateLastSeen(String uid);
  Future<UserEntity?> getUser(String uid);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> createUser(UserEntity user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final now = FieldValue.serverTimestamp();

    await docRef.set({
      'uid': user.uid,
      'isAnonymous': user.isAnonymous,
      'createdAt': now,
      'lastSeenAt': now,
      if (user.displayName != null) 'displayName': user.displayName,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateLastSeen(String uid) async {
    final docRef = _firestore.collection('users').doc(uid);
    await docRef.update({'lastSeenAt': FieldValue.serverTimestamp()});
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return UserEntity(
      uid: data['uid'] as String,
      isAnonymous: data['isAnonymous'] as bool? ?? true,
      displayName: data['displayName'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastSeenAt: (data['lastSeenAt'] as Timestamp?)?.toDate(),
    );
  }
}
