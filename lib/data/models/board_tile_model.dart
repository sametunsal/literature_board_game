/// Data Transfer Object for BoardTile entity.
/// Used for JSON serialization and persistence.
/// Pure Dart - no Flutter dependencies.

/// Color group identifiers for Monopoly-style property grouping
enum PropertyColorGroupModel {
  brown, // Group 1: Near Start
  lightBlue, // Group 2
  pink, // Group 3
  orange, // Group 4
  red, // Group 5
  yellow, // Group 6
  green, // Group 7
  blue, // Group 8: Most expensive
  utility, // Publishers, Schools, Foundations
  special, // Corners, Tax, Cards
}

enum TileTypeModel {
  start,
  property,
  publisher,
  chance,
  fate,
  libraryWatch,
  autographDay,
  bankruptcyRisk,
  writingSchool,
  educationFoundation,
  incomeTax,
  writingTax,
}

enum QuestionCategoryModel {
  benKimim,
  turkEdebiyatindaIlkler,
  edebiyatAkimlari,
  edebiyatSanatlari,
  eserKarakter,
}

class BoardTileModel {
  final int id;
  final String title;
  final TileTypeModel type;
  final int? price;
  final int? baseRent;
  final QuestionCategoryModel? category;
  final bool isUtility;
  final int upgradeLevel;
  final PropertyColorGroupModel? colorGroup;

  BoardTileModel({
    required this.id,
    required this.title,
    required this.type,
    this.price,
    this.baseRent,
    this.category,
    this.isUtility = false,
    this.upgradeLevel = 0,
    this.colorGroup,
  });

  factory BoardTileModel.fromJson(Map<String, dynamic> json) {
    return BoardTileModel(
      id: json['id'] as int,
      title: json['title'] as String,
      type: TileTypeModel.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TileTypeModel.start,
      ),
      price: json['price'] as int?,
      baseRent: json['baseRent'] as int?,
      category: json['category'] != null
          ? QuestionCategoryModel.values.firstWhere(
              (e) => e.name == json['category'],
              orElse: () => QuestionCategoryModel.benKimim,
            )
          : null,
      isUtility: json['isUtility'] as bool? ?? false,
      upgradeLevel: json['upgradeLevel'] as int? ?? 0,
      colorGroup: json['colorGroup'] != null
          ? PropertyColorGroupModel.values.firstWhere(
              (e) => e.name == json['colorGroup'],
              orElse: () => PropertyColorGroupModel.special,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'price': price,
      'baseRent': baseRent,
      'category': category?.name,
      'isUtility': isUtility,
      'upgradeLevel': upgradeLevel,
      'colorGroup': colorGroup?.name,
    };
  }

  BoardTileModel copyWith({int? upgradeLevel}) {
    return BoardTileModel(
      id: id,
      title: title,
      type: type,
      price: price,
      baseRent: baseRent,
      category: category,
      isUtility: isUtility,
      upgradeLevel: upgradeLevel ?? this.upgradeLevel,
      colorGroup: colorGroup,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoardTileModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BoardTileModel(id: $id, title: $title, type: $type, price: $price, '
        'baseRent: $baseRent, category: $category, isUtility: $isUtility, '
        'upgradeLevel: $upgradeLevel, colorGroup: $colorGroup)';
  }
}
