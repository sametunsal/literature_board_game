import 'package:equatable/equatable.dart';

/// Domain entity representing a Firebase user.
/// Pure Dart - no Flutter dependencies.
class UserEntity extends Equatable {
  final String uid;
  final bool isAnonymous;
  final String? displayName;
  final DateTime? createdAt;
  final DateTime? lastSeenAt;

  const UserEntity({
    required this.uid,
    required this.isAnonymous,
    this.displayName,
    this.createdAt,
    this.lastSeenAt,
  });

  @override
  List<Object?> get props => [
    uid,
    isAnonymous,
    displayName,
    createdAt,
    lastSeenAt,
  ];
}
