enum TileType {
  corner,
  book,
  publisher,
  chance,
  fate,
  tax,
  special,
}

enum CornerEffect {
  baslangic,
  kutuphaneNobeti,
  imzaGunu,
  iflasRiski,
}

enum TaxType {
  gelirVergisi,
  yazarlikVergisi,
}

enum SpecialType {
  yazarlikOkulu,
  deEgitimVakfi,
}

class Tile {
  final int id;
  final String name;
  final TileType type;

  // Corner tile attributes
  final CornerEffect? cornerEffect;

  // Book/Publisher tile attributes
  final int? group;
  final int? copyrightFee;
  final int? purchasePrice;

  // Tax tile attributes
  final TaxType? taxType;
  final int? taxRate; // Percentage (e.g., 10 for 10%)

  // Special tile attributes
  final SpecialType? specialType;

  const Tile({
    required this.id,
    required this.name,
    required this.type,
    this.cornerEffect,
    this.group,
    this.copyrightFee,
    this.purchasePrice,
    this.taxType,
    this.taxRate,
    this.specialType,
  });

  // Helper getters for tile type checking
  bool get isCorner => type == TileType.corner;
  bool get isBook => type == TileType.book;
  bool get isPublisher => type == TileType.publisher;
  bool get isChance => type == TileType.chance;
  bool get isFate => type == TileType.fate;
  bool get isTax => type == TileType.tax;
  bool get isSpecial => type == TileType.special;

  // Check if tile can be owned
  bool get canBeOwned => isBook || isPublisher;

  // Check if tile has question
  bool get hasQuestion => isBook || isPublisher || (isSpecial && specialType == SpecialType.yazarlikOkulu);

  // Check if tile causes turn skip
  bool get causesTurnSkip => 
    (isCorner && cornerEffect == CornerEffect.kutuphaneNobeti);

  // Check if tile causes star loss
  bool get causesStarLoss =>
    (isCorner && cornerEffect == CornerEffect.iflasRiski) ||
    isTax;
}
