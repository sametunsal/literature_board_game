import '../models/tile.dart';

// 40-tile board data provider
List<Tile> generateTiles() {
  return [
    // Tile 1: BAŞLANGIÇ (Corner)
    Tile(
      id: 1,
      name: 'BAŞLANGIÇ',
      type: TileType.corner,
      cornerEffect: CornerEffect.baslangic,
    ),
    
    // Group 1: Books (Tiles 2-4)
    Tile(
      id: 2,
      name: 'Siyah İnci',
      type: TileType.book,
      group: 1,
      copyrightFee: 2,
      purchasePrice: 60,
    ),
    Tile(
      id: 3,
      name: 'Tutunamayanlar',
      type: TileType.book,
      group: 1,
      copyrightFee: 4,
      purchasePrice: 60,
    ),
    Tile(
      id: 4,
      name: 'Huzur',
      type: TileType.book,
      group: 1,
      copyrightFee: 6,
      purchasePrice: 60,
    ),
    
    // Tile 5: Tax
    Tile(
      id: 5,
      name: 'GELİR VERGİSİ',
      type: TileType.tax,
      taxType: TaxType.gelirVergisi,
      taxRate: 10,
    ),
    
    // Tiles 6-9: Books
    Tile(
      id: 6,
      name: 'İnce Memed',
      type: TileType.book,
      group: 2,
      copyrightFee: 8,
      purchasePrice: 100,
    ),
    Tile(
      id: 7,
      name: 'Madonna',
      type: TileType.book,
      group: 2,
      copyrightFee: 10,
      purchasePrice: 100,
    ),
    Tile(
      id: 8,
      name: 'Kürk Mantolu Madonna',
      type: TileType.book,
      group: 2,
      copyrightFee: 12,
      purchasePrice: 120,
    ),
    Tile(
      id: 9,
      name: 'Yer Demir Gök Bakır',
      type: TileType.book,
      group: 2,
      copyrightFee: 14,
      purchasePrice: 140,
    ),
    
    // Tile 10: FATE
    Tile(
      id: 10,
      name: 'KADER',
      type: TileType.fate,
    ),
    
    // Tile 11: KÜTÜPHANE NÖBETİ (Corner)
    Tile(
      id: 11,
      name: 'KÜTÜPHANE NÖBETİ',
      type: TileType.corner,
      cornerEffect: CornerEffect.kutuphaneNobeti,
    ),
    
    // Group 2: Books (Tiles 12-14)
    Tile(
      id: 12,
      name: 'Saatleri Ayarlama Enstitüsü',
      type: TileType.book,
      group: 3,
      copyrightFee: 16,
      purchasePrice: 160,
    ),
    Tile(
      id: 13,
      name: 'Kırlangıç Yuvası',
      type: TileType.book,
      group: 3,
      copyrightFee: 16,
      purchasePrice: 160,
    ),
    Tile(
      id: 14,
      name: 'Tuhaf Bir Hikâye',
      type: TileType.book,
      group: 3,
      copyrightFee: 18,
      purchasePrice: 180,
    ),
    
    // Tile 15: Tax
    Tile(
      id: 15,
      name: 'YAZARLIK VERGİSİ',
      type: TileType.tax,
      taxType: TaxType.yazarlikVergisi,
      taxRate: 15,
    ),
    
    // Tiles 16-19: Books
    Tile(
      id: 16,
      name: 'Tersane İstanbul\'da',
      type: TileType.book,
      group: 4,
      copyrightFee: 20,
      purchasePrice: 200,
    ),
    Tile(
      id: 17,
      name: 'Yılanların Öcü',
      type: TileType.book,
      group: 4,
      copyrightFee: 22,
      purchasePrice: 220,
    ),
    Tile(
      id: 18,
      name: 'Bir Delinin Hatıra Defteri',
      type: TileType.book,
      group: 4,
      copyrightFee: 24,
      purchasePrice: 240,
    ),
    Tile(
      id: 19,
      name: 'Yüzsüz',
      type: TileType.book,
      group: 4,
      copyrightFee: 26,
      purchasePrice: 260,
    ),
    
    // Tile 20: CHANCE
    Tile(
      id: 20,
      name: 'ŞANS',
      type: TileType.chance,
    ),
    
    // Tile 21: İMZA GÜNÜ (Corner)
    Tile(
      id: 21,
      name: 'İMZA GÜNÜ',
      type: TileType.corner,
      cornerEffect: CornerEffect.imzaGunu,
    ),
    
    // Group 3: Books (Tiles 22-24)
    Tile(
      id: 22,
      name: 'Gergin Anlar',
      type: TileType.book,
      group: 5,
      copyrightFee: 28,
      purchasePrice: 280,
    ),
    Tile(
      id: 23,
      name: 'Mutsuzluk',
      type: TileType.book,
      group: 5,
      copyrightFee: 28,
      purchasePrice: 280,
    ),
    Tile(
      id: 24,
      name: 'Fareler ve İnsanlar',
      type: TileType.book,
      group: 5,
      copyrightFee: 30,
      purchasePrice: 300,
    ),
    
    // Tile 25: Tax
    Tile(
      id: 25,
      name: 'GELİR VERGİSİ',
      type: TileType.tax,
      taxType: TaxType.gelirVergisi,
      taxRate: 10,
    ),
    
    // Tiles 26-29: Books
    Tile(
      id: 26,
      name: 'Dönüşüm',
      type: TileType.book,
      group: 6,
      copyrightFee: 32,
      purchasePrice: 320,
    ),
    Tile(
      id: 27,
      name: 'Suç ve Ceza',
      type: TileType.book,
      group: 6,
      copyrightFee: 35,
      purchasePrice: 350,
    ),
    Tile(
      id: 28,
      name: 'Savaş ve Barış',
      type: TileType.book,
      group: 6,
      copyrightFee: 35,
      purchasePrice: 350,
    ),
    Tile(
      id: 29,
      name: 'Anna Karenina',
      type: TileType.book,
      group: 6,
      copyrightFee: 35,
      purchasePrice: 400,
    ),
    
    // Tile 30: FATE
    Tile(
      id: 30,
      name: 'KADER',
      type: TileType.fate,
    ),
    
    // Tile 31: İFLAS RİSKİ (Corner)
    Tile(
      id: 31,
      name: 'İFLAS RİSKİ',
      type: TileType.corner,
      cornerEffect: CornerEffect.iflasRiski,
    ),
    
    // Group 4: Books (Tiles 32-34)
    Tile(
      id: 32,
      name: 'Sefiller',
      type: TileType.book,
      group: 7,
      copyrightFee: 40,
      purchasePrice: 400,
    ),
    Tile(
      id: 33,
      name: 'Notre Dame\'ın Kamburu',
      type: TileType.book,
      group: 7,
      copyrightFee: 42,
      purchasePrice: 420,
    ),
    Tile(
      id: 34,
      name: 'Bir İdam Mahkemesinin Anıları',
      type: TileType.book,
      group: 7,
      copyrightFee: 45,
      purchasePrice: 450,
    ),
    
    // Tile 35: Tax
    Tile(
      id: 35,
      name: 'YAZARLIK VERGİSİ',
      type: TileType.tax,
      taxType: TaxType.yazarlikVergisi,
      taxRate: 15,
    ),
    
    // Tiles 36-39: Books
    Tile(
      id: 36,
      name: 'Saat',
      type: TileType.book,
      group: 8,
      copyrightFee: 50,
      purchasePrice: 500,
    ),
    Tile(
      id: 37,
      name: 'Kafkas Telemefi',
      type: TileType.book,
      group: 8,
      copyrightFee: 55,
      purchasePrice: 550,
    ),
    Tile(
      id: 38,
      name: 'Körlük',
      type: TileType.book,
      group: 8,
      copyrightFee: 55,
      purchasePrice: 550,
    ),
    Tile(
      id: 39,
      name: 'Mavi Ve Maviye Karşı',
      type: TileType.book,
      group: 8,
      copyrightFee: 60,
      purchasePrice: 600,
    ),
    
    // Tile 40: CHANCE
    Tile(
      id: 40,
      name: 'ŞANS',
      type: TileType.chance,
    ),
  ];
}
