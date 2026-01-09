import 'package:flutter/material.dart';

class Player {
  final String id;
  final String name;
  final int balance;
  final int position;
  final List<int> ownedTiles;
  final bool inJail;
  final Color color;
  final int iconIndex; // Setup ekranında seçilen ikonun indexi

  const Player({
    required this.id,
    required this.name,
    required this.color,
    required this.iconIndex,
    this.balance = 1000,
    this.position = 0,
    this.ownedTiles = const [],
    this.inJail = false,
  });

  Player copyWith({
    String? name,
    Color? color,
    int? iconIndex,
    int? balance,
    int? position,
    List<int>? ownedTiles,
    bool? inJail,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      iconIndex: iconIndex ?? this.iconIndex,
      balance: balance ?? this.balance,
      position: position ?? this.position,
      ownedTiles: ownedTiles ?? this.ownedTiles,
      inJail: inJail ?? this.inJail,
    );
  }
}
