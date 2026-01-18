/// Data Transfer Object for GameCard entity.
/// Used for JSON serialization and persistence.
/// Pure Dart - no Flutter dependencies.

enum CardEffectTypeModel {
  moneyChange, // Para kazan/kaybet
  move, // Bir yere git
  jail, // Kütüphane nöbetine git
  globalMoney, // Diğer oyunculardan para al/ver (Kader kartı özelliği)
}

enum CardTypeModel { sans, kader }

class GameCardModel {
  final String description;
  final CardTypeModel type; // Şans veya Kader
  final CardEffectTypeModel effectType;
  final int value; // Para miktarı veya Gidilecek Tile ID'si

  GameCardModel({
    required this.description,
    required this.type,
    required this.effectType,
    this.value = 0,
  });

  factory GameCardModel.fromJson(Map<String, dynamic> json) {
    return GameCardModel(
      description: json['description'] as String,
      type: CardTypeModel.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CardTypeModel.sans,
      ),
      effectType: CardEffectTypeModel.values.firstWhere(
        (e) => e.name == json['effectType'],
        orElse: () => CardEffectTypeModel.moneyChange,
      ),
      value: json['value'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'type': type.name,
      'effectType': effectType.name,
      'value': value,
    };
  }

  GameCardModel copyWith({
    String? description,
    CardTypeModel? type,
    CardEffectTypeModel? effectType,
    int? value,
  }) {
    return GameCardModel(
      description: description ?? this.description,
      type: type ?? this.type,
      effectType: effectType ?? this.effectType,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameCardModel &&
        other.description == description &&
        other.type == type &&
        other.effectType == effectType &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(description, type, effectType, value);

  @override
  String toString() {
    return 'GameCardModel(description: $description, type: $type, effectType: $effectType, value: $value)';
  }
}
