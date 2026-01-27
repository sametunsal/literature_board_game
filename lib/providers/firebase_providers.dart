import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/auth_data_source.dart';
import '../data/datasources/user_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/usecases/ensure_signed_in_anonymously.dart';
import '../models/user_entity.dart';

// --- Firebase Instances ---
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// --- Data Sources ---
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDataSourceImpl(ref.watch(firebaseAuthProvider));
});

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSourceImpl(ref.watch(firestoreProvider));
});

// --- Repositories ---
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDataSourceProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(userRemoteDataSourceProvider));
});

// --- Use Cases ---
final ensureSignedInAnonymouslyProvider = Provider<EnsureSignedInAnonymously>((
  ref,
) {
  return EnsureSignedInAnonymously(
    ref.watch(authRepositoryProvider),
    ref.watch(userRepositoryProvider),
  );
});

// --- Auth State ---
final authStateChangesProvider = StreamProvider.autoDispose<UserEntity?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUser;
});
