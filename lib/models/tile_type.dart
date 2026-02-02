/// Tile types on the game board
enum TileType {
  start,
  category,
  corner,
  shop,
  collection,
  library,
  signingDay,
  chance, // ŞANS - Chance tile
  fate, // KADER - Fate tile
  tesvik, // TEŞVİK - Incentive/Bonus tile
}

/// Extension to get display name for tile type
extension TileTypeExtension on TileType {
  String get displayName {
    switch (this) {
      case TileType.start:
        return 'Başlangıç';
      case TileType.category:
        return 'Kategori';
      case TileType.corner:
        return 'Köşe';
      case TileType.shop:
        return 'Kıraathane';
      case TileType.collection:
        return 'Koleksiyon';
      case TileType.library:
        return 'Kütüphane';
      case TileType.signingDay:
        return 'İmza Günü';
      case TileType.chance:
        return 'Şans';
      case TileType.fate:
        return 'Kader';
      case TileType.tesvik:
        return 'Teşvik';
    }
  }
}
