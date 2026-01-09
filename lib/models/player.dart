import 'package:flutter/material.dart';

class Player {
  final String id;
  final String name;
  final int balance;
  final int position;
  final List<int> ownedTiles; // Satın alınan kutucuk ID'leri
  final bool inJail;
  final Color color; // Oyuncu rengi
  final IconData icon; // Oyuncu ikonu

  const Player({
    required this.id,
    required this.name,
    required this.color,
    this.icon = Icons.person, // Varsayılan ikon
    this.balance = 1000,
    this.position = 0,
    this.ownedTiles = const [],
    this.inJail = false,
  });

  Player copyWith({
    String? name,
    Color? color,
    IconData? icon,
    int? balance,
    int? position,
    List<int>? ownedTiles,
    bool? inJail,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      balance: balance ?? this.balance,
      position: position ?? this.position,
      ownedTiles: ownedTiles ?? this.ownedTiles,
      inJail: inJail ?? this.inJail,
    );
  }
}
