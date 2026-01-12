import '../models/board_tile.dart';
import '../models/game_enums.dart';

/// Board configuration with Monopoly-style color groups
/// Colors progress: Brown -> Light Blue -> Pink -> Orange -> Red -> Yellow -> Green -> Blue
/// Prices increase within each group and across groups
class BoardConfig {
  static List<BoardTile> tiles = [
    // ═══════════════════════════════════════════════════════════════════════════
    // CORNER 0 (BOTTOM-LEFT): START
    // ═══════════════════════════════════════════════════════════════════════════
    const BoardTile(
      id: 0,
      title: 'BAŞLANGIÇ',
      type: TileType.start,
      colorGroup: PropertyColorGroup.special,
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // LEFT EDGE (IDs 1-9): Going UP
    // ═══════════════════════════════════════════════════════════════════════════

    // GROUP 1: BROWN (2 properties)
    const BoardTile(
      id: 1,
      title: 'Çalıkuşu',
      type: TileType.property,
      price: 60,
      baseRent: 2,
      category: QuestionCategory.eserKarakter,
      colorGroup: PropertyColorGroup.brown,
    ),
    const BoardTile(
      id: 2,
      title: 'KADER KARTI',
      type: TileType.fate,
      colorGroup: PropertyColorGroup.special,
    ),
    const BoardTile(
      id: 3,
      title: 'Dudaktan Kalbe',
      type: TileType.property,
      price: 80,
      baseRent: 4,
      category: QuestionCategory.eserKarakter,
      colorGroup: PropertyColorGroup.brown,
    ),
    const BoardTile(
      id: 4,
      title: 'GELİR VERGİSİ',
      type: TileType.incomeTax,
      colorGroup: PropertyColorGroup.special,
    ),

    // UTILITY: Publisher 1
    const BoardTile(
      id: 5,
      title: '1. YAYINEVİ',
      type: TileType.publisher,
      price: 200,
      isUtility: true,
      colorGroup: PropertyColorGroup.utility,
    ),

    // GROUP 2: LIGHT BLUE (3 properties)
    const BoardTile(
      id: 6,
      title: 'Yaban',
      type: TileType.property,
      price: 100,
      baseRent: 6,
      category: QuestionCategory.turkEdebiyatindaIlkler,
      colorGroup: PropertyColorGroup.lightBlue,
    ),
    const BoardTile(
      id: 7,
      title: 'ŞANS KARTI',
      type: TileType.chance,
      colorGroup: PropertyColorGroup.special,
    ),
    const BoardTile(
      id: 8,
      title: 'Sinekli Bakkal',
      type: TileType.property,
      price: 120,
      baseRent: 6,
      category: QuestionCategory.turkEdebiyatindaIlkler,
      colorGroup: PropertyColorGroup.lightBlue,
    ),
    const BoardTile(
      id: 9,
      title: 'Kiralık Konak',
      type: TileType.property,
      price: 140,
      baseRent: 8,
      category: QuestionCategory.turkEdebiyatindaIlkler,
      colorGroup: PropertyColorGroup.lightBlue,
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // CORNER 1 (TOP-LEFT): LIBRARY WATCH
    // ═══════════════════════════════════════════════════════════════════════════
    const BoardTile(
      id: 10,
      title: 'KÜTÜPHANE\nNÖBETİ',
      type: TileType.libraryWatch,
      colorGroup: PropertyColorGroup.special,
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // TOP EDGE (IDs 11-19): Going RIGHT
    // ═══════════════════════════════════════════════════════════════════════════

    // GROUP 3: PINK (3 properties)
    const BoardTile(
      id: 11,
      title: 'Mai ve Siyah',
      type: TileType.property,
      price: 140,
      baseRent: 10,
      category: QuestionCategory.edebiyatAkimlari,
      colorGroup: PropertyColorGroup.pink,
    ),
    const BoardTile(
      id: 12,
      title: 'YAZARLIK OKULU',
      type: TileType.writingSchool,
      price: 150,
      isUtility: true,
      colorGroup: PropertyColorGroup.utility,
    ),
    const BoardTile(
      id: 13,
      title: 'Aşk-ı Memnu',
      type: TileType.property,
      price: 160,
      baseRent: 10,
      category: QuestionCategory.eserKarakter,
      colorGroup: PropertyColorGroup.pink,
    ),
    const BoardTile(
      id: 14,
      title: 'Eylül',
      type: TileType.property,
      price: 180,
      baseRent: 12,
      category: QuestionCategory.edebiSanatlar,
      colorGroup: PropertyColorGroup.pink,
    ),

    // UTILITY: Publisher 2
    const BoardTile(
      id: 15,
      title: '2. YAYINEVİ',
      type: TileType.publisher,
      price: 200,
      isUtility: true,
      colorGroup: PropertyColorGroup.utility,
    ),

    // GROUP 4: ORANGE (3 properties)
    const BoardTile(
      id: 16,
      title: 'İnce Memed',
      type: TileType.property,
      price: 180,
      baseRent: 14,
      category: QuestionCategory.benKimim,
      colorGroup: PropertyColorGroup.orange,
    ),
    const BoardTile(
      id: 17,
      title: 'KADER KARTI',
      type: TileType.fate,
      colorGroup: PropertyColorGroup.special,
    ),
    const BoardTile(
      id: 18,
      title: 'Yer Demir Gök Bakır',
      type: TileType.property,
      price: 200,
      baseRent: 14,
      category: QuestionCategory.benKimim,
      colorGroup: PropertyColorGroup.orange,
    ),
    const BoardTile(
      id: 19,
      title: 'Teneke',
      type: TileType.property,
      price: 220,
      baseRent: 16,
      category: QuestionCategory.benKimim,
      colorGroup: PropertyColorGroup.orange,
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // CORNER 2 (TOP-RIGHT): AUTOGRAPH DAY
    // ═══════════════════════════════════════════════════════════════════════════
    const BoardTile(
      id: 20,
      title: 'İMZA GÜNÜ',
      type: TileType.autographDay,
      colorGroup: PropertyColorGroup.special,
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // RIGHT EDGE (IDs 21-29): Going DOWN
    // ═══════════════════════════════════════════════════════════════════════════

    // GROUP 5: RED (3 properties)
    const BoardTile(
      id: 21,
      title: 'Saatleri Ayarlama',
      type: TileType.property,
      price: 220,
      baseRent: 18,
      category: QuestionCategory.eserKarakter,
      colorGroup: PropertyColorGroup.red,
    ),
    const BoardTile(
      id: 22,
      title: 'ŞANS KARTI',
      type: TileType.chance,
      colorGroup: PropertyColorGroup.special,
    ),
    const BoardTile(
      id: 23,
      title: 'Huzur',
      type: TileType.property,
      price: 240,
      baseRent: 18,
      category: QuestionCategory.eserKarakter,
      colorGroup: PropertyColorGroup.red,
    ),
    const BoardTile(
      id: 24,
      title: 'Beş Şehir',
      type: TileType.property,
      price: 260,
      baseRent: 20,
      category: QuestionCategory.edebiSanatlar,
      colorGroup: PropertyColorGroup.red,
    ),

    // UTILITY: Publisher 3
    const BoardTile(
      id: 25,
      title: '3. YAYINEVİ',
      type: TileType.publisher,
      price: 200,
      isUtility: true,
      colorGroup: PropertyColorGroup.utility,
    ),

    // GROUP 6: YELLOW (3 properties)
    const BoardTile(
      id: 26,
      title: 'Devlet Ana',
      type: TileType.property,
      price: 260,
      baseRent: 22,
      category: QuestionCategory.turkEdebiyatindaIlkler,
      colorGroup: PropertyColorGroup.yellow,
    ),
    const BoardTile(
      id: 27,
      title: 'Yorgun Savaşçı',
      type: TileType.property,
      price: 280,
      baseRent: 22,
      category: QuestionCategory.turkEdebiyatindaIlkler,
      colorGroup: PropertyColorGroup.yellow,
    ),
    const BoardTile(
      id: 28,
      title: 'EĞİTİM VAKFI',
      type: TileType.educationFoundation,
      price: 150,
      isUtility: true,
      colorGroup: PropertyColorGroup.utility,
    ),
    const BoardTile(
      id: 29,
      title: 'Esir Şehrin İnsanları',
      type: TileType.property,
      price: 300,
      baseRent: 24,
      category: QuestionCategory.turkEdebiyatindaIlkler,
      colorGroup: PropertyColorGroup.yellow,
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // CORNER 3 (BOTTOM-RIGHT): BANKRUPTCY RISK
    // ═══════════════════════════════════════════════════════════════════════════
    const BoardTile(
      id: 30,
      title: 'İFLAS RİSKİ',
      type: TileType.bankruptcyRisk,
      colorGroup: PropertyColorGroup.special,
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // BOTTOM EDGE (IDs 31-39): Going LEFT toward Start
    // ═══════════════════════════════════════════════════════════════════════════

    // GROUP 7: GREEN (3 properties)
    const BoardTile(
      id: 31,
      title: 'Tutunamayanlar',
      type: TileType.property,
      price: 300,
      baseRent: 26,
      category: QuestionCategory.edebiyatAkimlari,
      colorGroup: PropertyColorGroup.green,
    ),
    const BoardTile(
      id: 32,
      title: 'Tehlikeli Oyunlar',
      type: TileType.property,
      price: 320,
      baseRent: 26,
      category: QuestionCategory.edebiyatAkimlari,
      colorGroup: PropertyColorGroup.green,
    ),
    const BoardTile(
      id: 33,
      title: 'KADER KARTI',
      type: TileType.fate,
      colorGroup: PropertyColorGroup.special,
    ),
    const BoardTile(
      id: 34,
      title: 'Oyunlarla Yaşayanlar',
      type: TileType.property,
      price: 340,
      baseRent: 28,
      category: QuestionCategory.edebiyatAkimlari,
      colorGroup: PropertyColorGroup.green,
    ),

    // UTILITY: Publisher 4
    const BoardTile(
      id: 35,
      title: '4. YAYINEVİ',
      type: TileType.publisher,
      price: 200,
      isUtility: true,
      colorGroup: PropertyColorGroup.utility,
    ),

    // GROUP 8: BLUE (2 properties - most expensive)
    const BoardTile(
      id: 36,
      title: 'ŞANS KARTI',
      type: TileType.chance,
      colorGroup: PropertyColorGroup.special,
    ),
    const BoardTile(
      id: 37,
      title: 'Kara Kitap',
      type: TileType.property,
      price: 350,
      baseRent: 35,
      category: QuestionCategory.edebiSanatlar,
      colorGroup: PropertyColorGroup.blue,
    ),
    const BoardTile(
      id: 38,
      title: 'YAZARLIK VERGİSİ',
      type: TileType.writingTax,
      colorGroup: PropertyColorGroup.special,
    ),
    const BoardTile(
      id: 39,
      title: 'Benim Adım Kırmızı',
      type: TileType.property,
      price: 400,
      baseRent: 50,
      category: QuestionCategory.edebiSanatlar,
      colorGroup: PropertyColorGroup.blue,
    ),
  ];

  /// Get tile by ID
  static BoardTile getTile(int id) {
    if (id < 0 || id >= tiles.length) return tiles[0];
    return tiles[id];
  }

  /// Upgrade a tile's level (baskı/cilt)
  static void upgradeTile(int id) {
    var old = tiles[id];
    if (old.upgradeLevel < 4) {
      tiles[id] = old.copyWith(upgradeLevel: old.upgradeLevel + 1);
    }
  }

  /// Get all tiles in a specific color group
  static List<BoardTile> getTilesByGroup(PropertyColorGroup group) {
    return tiles.where((t) => t.colorGroup == group).toList();
  }
}
