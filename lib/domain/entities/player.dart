/// Domain entity representing a player in the game.
/// Pure Dart - no Flutter dependencies.

class Player {
  final String id;
  final String name;
  final int balance;
  final int position;
  final List<int> ownedTiles;
  final bool inJail;
  final int iconIndex;
  final int turnsToSkip; // Library watch penalty turns remaining

  const Player({
    required this.id,
    required this.name,
    required this.iconIndex,
    this.balance = 2500,
    this.position = 0,
    this.ownedTiles = const [],
    this.inJail = false,
    this.turnsToSkip = 0,
  });

  Player copyWith({
    String? name,
    int? iconIndex,
    int? balance,
    int? position,
    List<int>? ownedTiles,
    bool? inJail,
    int? turnsToSkip,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      iconIndex: iconIndex ?? this.iconIndex,
      balance: balance ?? this.balance,
      position: position ?? this.position,
      ownedTiles: ownedTiles ?? this.ownedTiles,
      inJail: inJail ?? this.inJail,
      turnsToSkip: turnsToSkip ?? this.turnsToSkip,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Player(id: $id, name: $name, balance: $balance, position: $position, '
        'ownedTiles: $ownedTiles, inJail: $inJail, turnsToSkip: $turnsToSkip)';
  }
}
