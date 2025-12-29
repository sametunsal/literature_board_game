import '../models/tile.dart';

// 40-tile board data provider - EXACT MATCH TO SPECIFICATIONS
// Tiles are indexed 0-39, Clockwise starting from Bottom-Left (START)
// Direction: Bottom-Left (0) → Up → Top-Left (10) → Right → Top-Right (20) → Down → Bottom-Right (30) → Left → Bottom-Left (0)
List<Tile> generateTiles() {
  return [
    // === BOTTOM ROW (Right to Left: 0-9) ===

    // Tile 0: START (Bottom-Left Corner) - Collect points on pass
    Tile(
      id: 0,
      name: 'START',
      type: TileType.corner,
      cornerEffect: CornerEffect.baslangic,
    ),

    // Tile 1: Book Group 1
    Tile(
      id: 1,
      name: 'Siyah İnci',
      type: TileType.book,
      group: 1,
      copyrightFee: 4,
      purchasePrice: 60,
    ),

    // Tile 2: FATE Card (Community Chest equivalent)
    Tile(id: 2, name: 'KADER', type: TileType.fate),

    // Tile 3: Book Group 1
    Tile(
      id: 3,
      name: 'Tutunamayanlar',
      type: TileType.book,
      group: 1,
      copyrightFee: 8,
      purchasePrice: 60,
    ),

    // Tile 4: INCOME TAX
    Tile(
      id: 4,
      name: 'GELİR VERGİSİ',
      type: TileType.tax,
      taxType: TaxType.gelirVergisi,
      taxRate: 10,
    ),

    // Tile 5: PUBLISHER 1 (Railroad equivalent)
    Tile(
      id: 5,
      name: 'YAYINEVİ 1',
      type: TileType.publisher,
      group: 5,
      copyrightFee: 25,
      purchasePrice: 200,
    ),

    // Tile 6: Book Group 2
    Tile(
      id: 6,
      name: 'İnce Memed',
      type: TileType.book,
      group: 2,
      copyrightFee: 10,
      purchasePrice: 100,
    ),

    // Tile 7: CHANCE Card
    Tile(id: 7, name: 'ŞANS', type: TileType.chance),

    // Tile 8: Book Group 2
    Tile(
      id: 8,
      name: 'Kürk Mantolu Madonna',
      type: TileType.book,
      group: 2,
      copyrightFee: 12,
      purchasePrice: 100,
    ),

    // Tile 9: Book Group 2
    Tile(
      id: 9,
      name: 'Yer Demir Gök Bakır',
      type: TileType.book,
      group: 2,
      copyrightFee: 14,
      purchasePrice: 120,
    ),

    // === LEFT COLUMN (Bottom to Top: 10-19) ===

    // Tile 10: LIBRARY DUTY (Top-Left Corner / Jail) - No actions for current + next turn
    Tile(
      id: 10,
      name: 'KÜTÜPHANE NÖBETİ',
      type: TileType.corner,
      cornerEffect: CornerEffect.kutuphaneNobeti,
    ),

    // Tile 11: Book Group 3
    Tile(
      id: 11,
      name: 'Saatleri Ayarlama Enstitüsü',
      type: TileType.book,
      group: 3,
      copyrightFee: 16,
      purchasePrice: 140,
    ),

    // Tile 12: WRITING SCHOOL
    Tile(
      id: 12,
      name: 'YAZARLIK OKULU',
      type: TileType.special,
      specialType: SpecialType.yazarlikOkulu,
    ),

    // Tile 13: Book Group 3
    Tile(
      id: 13,
      name: 'Kırlangıç Yuvası',
      type: TileType.book,
      group: 3,
      copyrightFee: 16,
      purchasePrice: 160,
    ),

    // Tile 14: Book Group 3
    Tile(
      id: 14,
      name: 'Tuhaf Bir Hikâye',
      type: TileType.book,
      group: 3,
      copyrightFee: 18,
      purchasePrice: 180,
    ),

    // Tile 15: PUBLISHER 2
    Tile(
      id: 15,
      name: 'YAYINEVİ 2',
      type: TileType.publisher,
      group: 5,
      copyrightFee: 25,
      purchasePrice: 200,
    ),

    // Tile 16: Book Group 4
    Tile(
      id: 16,
      name: 'Tersane İstanbul\'da',
      type: TileType.book,
      group: 4,
      copyrightFee: 20,
      purchasePrice: 200,
    ),

    // Tile 17: FATE Card
    Tile(id: 17, name: 'KADER', type: TileType.fate),

    // Tile 18: Book Group 4
    Tile(
      id: 18,
      name: 'Yılanların Öcü',
      type: TileType.book,
      group: 4,
      copyrightFee: 22,
      purchasePrice: 220,
    ),

    // Tile 19: Book Group 4
    Tile(
      id: 19,
      name: 'Bir Delinin Hatıra Defteri',
      type: TileType.book,
      group: 4,
      copyrightFee: 24,
      purchasePrice: 240,
    ),

    // === TOP ROW (Left to Right: 20-29) ===

    // Tile 20: SIGNING DAY (Top-Right Corner / Free Parking) - No action, safe spot
    Tile(
      id: 20,
      name: 'İMZA GÜNÜ',
      type: TileType.corner,
      cornerEffect: CornerEffect.imzaGunu,
    ),

    // Tile 21: Book Group 5
    Tile(
      id: 21,
      name: 'Gergin Anlar',
      type: TileType.book,
      group: 5,
      copyrightFee: 28,
      purchasePrice: 260,
    ),

    // Tile 22: CHANCE Card
    Tile(id: 22, name: 'ŞANS', type: TileType.chance),

    // Tile 23: Book Group 5
    Tile(
      id: 23,
      name: 'Mutsuzluk',
      type: TileType.book,
      group: 5,
      copyrightFee: 28,
      purchasePrice: 280,
    ),

    // Tile 24: Book Group 5
    Tile(
      id: 24,
      name: 'Fareler ve İnsanlar',
      type: TileType.book,
      group: 5,
      copyrightFee: 30,
      purchasePrice: 300,
    ),

    // Tile 25: PUBLISHER 3
    Tile(
      id: 25,
      name: 'YAYINEVİ 3',
      type: TileType.publisher,
      group: 5,
      copyrightFee: 25,
      purchasePrice: 200,
    ),

    // Tile 26: Book Group 6
    Tile(
      id: 26,
      name: 'Dönüşüm',
      type: TileType.book,
      group: 6,
      copyrightFee: 32,
      purchasePrice: 320,
    ),

    // Tile 27: Book Group 6
    Tile(
      id: 27,
      name: 'Suç ve Ceza',
      type: TileType.book,
      group: 6,
      copyrightFee: 35,
      purchasePrice: 350,
    ),

    // Tile 28: EDUCATION FOUNDATION
    Tile(
      id: 28,
      name: 'EĞİTİM VAKFI',
      type: TileType.special,
      specialType: SpecialType.deEgitimVakfi,
    ),

    // Tile 29: Book Group 6
    Tile(
      id: 29,
      name: 'Savaş ve Barış',
      type: TileType.book,
      group: 6,
      copyrightFee: 35,
      purchasePrice: 350,
    ),

    // === RIGHT COLUMN (Top to Bottom: 30-39) ===

    // Tile 30: BANKRUPTCY RISK (Bottom-Right Corner / Go to Jail) - Lose 50% points, go to LIBRARY DUTY immediately
    Tile(
      id: 30,
      name: 'İFLAS RİSKİ',
      type: TileType.corner,
      cornerEffect: CornerEffect.iflasRiski,
    ),

    // Tile 31: Book Group 7
    Tile(
      id: 31,
      name: 'Sefiller',
      type: TileType.book,
      group: 7,
      copyrightFee: 40,
      purchasePrice: 400,
    ),

    // Tile 32: Book Group 7
    Tile(
      id: 32,
      name: 'Notre Dame\'ın Kamburu',
      type: TileType.book,
      group: 7,
      copyrightFee: 42,
      purchasePrice: 420,
    ),

    // Tile 33: FATE Card
    Tile(id: 33, name: 'KADER', type: TileType.fate),

    // Tile 34: Book Group 7
    Tile(
      id: 34,
      name: 'Bir İdam Mahkemesinin Anıları',
      type: TileType.book,
      group: 7,
      copyrightFee: 45,
      purchasePrice: 450,
    ),

    // Tile 35: PUBLISHER 4
    Tile(
      id: 35,
      name: 'YAYINEVİ 4',
      type: TileType.publisher,
      group: 5,
      copyrightFee: 25,
      purchasePrice: 200,
    ),

    // Tile 36: CHANCE Card
    Tile(id: 36, name: 'ŞANS', type: TileType.chance),

    // Tile 37: Book Group 8
    Tile(
      id: 37,
      name: 'Saat',
      type: TileType.book,
      group: 8,
      copyrightFee: 50,
      purchasePrice: 500,
    ),

    // Tile 38: AUTHOR TAX
    Tile(
      id: 38,
      name: 'YAZARLIK VERGİSİ',
      type: TileType.tax,
      taxType: TaxType.yazarlikVergisi,
      taxRate: 15,
    ),

    // Tile 39: Book Group 8
    Tile(
      id: 39,
      name: 'Kafkas Telemefi',
      type: TileType.book,
      group: 8,
      copyrightFee: 55,
      purchasePrice: 550,
    ),
  ];
}
