/// Data Transfer Object for Player entity.
/// Used for JSON serialization and persistence.
/// Pure Dart - no Flutter dependencies.

class PlayerModel {
  final String id;
  final String name;
  final int balance;
  final int position;
  final List<int> ownedTiles;
  final bool inJail;
  final int iconIndex;
  final int turnsToSkip; // Library watch penalty turns remaining

  PlayerModel({
    required this.id,
    required this.name,
    required this.iconIndex,
    this.balance = 2500,
    this.position = 0,
    this.ownedTiles = const [],
    this.inJail = false,
    this.turnsToSkip = 0,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: json['balance'] as int? ?? 2500,
      position: json['position'] as int? ?? 0,
      ownedTiles:
          (json['ownedTiles'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      inJail: json['inJail'] as bool? ?? false,
      iconIndex: json['iconIndex'] as int,
      turnsToSkip: json['turnsToSkip'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'position': position,
      'ownedTiles': ownedTiles,
      'inJail': inJail,
      'iconIndex': iconIndex,
      'turnsToSkip': turnsToSkip,
    };
  }

  PlayerModel copyWith({
    String? id,
    String? name,
    int? balance,
    int? position,
    List<int>? ownedTiles,
    bool? inJail,
    int? iconIndex,
    int? turnsToSkip,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      position: position ?? this.position,
      ownedTiles: ownedTiles ?? this.ownedTiles,
      inJail: inJail ?? this.inJail,
      iconIndex: iconIndex ?? this.iconIndex,
      turnsToSkip: turnsToSkip ?? this.turnsToSkip,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PlayerModel(id: $id, name: $name, balance: $balance, position: $position, '
        'ownedTiles: $ownedTiles, inJail: $inJail, iconIndex: $iconIndex, turnsToSkip: $turnsToSkip)';
  }
}
