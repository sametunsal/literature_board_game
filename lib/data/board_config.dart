import '../models/board_tile.dart';
import '../models/game_enums.dart';

class BoardConfig {
  // Statik liste, oyun başladığında değiştirilebilir olacak (Baskı seviyeleri için)
  static List<BoardTile> tiles = [
    // --- 1. KENAR (ALT: SAĞDAN SOLA veya SOL ALT KÖŞEDEN BAŞLAYIP SAAT YÖNÜNE) ---
    // Bizim yapımız: 0 (Sol Alt) -> Saat Yönünde (Clockwise)

    // 0. BAŞLANGIÇ
    BoardTile(id: 0, title: 'BAŞLANGIÇ', type: TileType.start),

    // 1. Grup (Mor)
    BoardTile(
      id: 1,
      title: 'Çalıkuşu',
      type: TileType.property,
      price: 60,
      baseRent: 2,
      category: QuestionCategory.eserKarakter,
    ),
    BoardTile(id: 2, title: 'KADER KARTI', type: TileType.fate),
    BoardTile(
      id: 3,
      title: 'Dudaktan Kalbe',
      type: TileType.property,
      price: 60,
      baseRent: 4,
      category: QuestionCategory.eserKarakter,
    ),

    // Vergi
    BoardTile(id: 4, title: 'GELİR VERGİSİ', type: TileType.incomeTax),

    // Yayınevi (Utility)
    BoardTile(
      id: 5,
      title: '1. YAYINEVİ',
      type: TileType.publisher,
      price: 200,
      isUtility: true,
    ),

    // 2. Grup (Açık Mavi)
    BoardTile(
      id: 6,
      title: 'Yaban',
      type: TileType.property,
      price: 100,
      baseRent: 6,
      category: QuestionCategory.turkEdebiyatindaIlkler,
    ),
    BoardTile(id: 7, title: 'ŞANS KARTI', type: TileType.chance),
    BoardTile(
      id: 8,
      title: 'Sinekli Bakkal',
      type: TileType.property,
      price: 100,
      baseRent: 6,
      category: QuestionCategory.turkEdebiyatindaIlkler,
    ),
    BoardTile(
      id: 9,
      title: 'Kiralık Konak',
      type: TileType.property,
      price: 120,
      baseRent: 8,
      category: QuestionCategory.turkEdebiyatindaIlkler,
    ),

    // --- KÖŞE 1 (SOL ÜST) ---
    // 10. KÜTÜPHANE NÖBETİ
    BoardTile(id: 10, title: 'KÜTÜPHANE\nNÖBETİ', type: TileType.libraryWatch),

    // --- 2. KENAR (ÜST) ---
    // 3. Grup (Pembe)
    BoardTile(
      id: 11,
      title: 'Mai ve Siyah',
      type: TileType.property,
      price: 140,
      baseRent: 10,
      category: QuestionCategory.edebiyatAkimlari,
    ),
    BoardTile(
      id: 12,
      title: 'YAZARLIK OKULU',
      type: TileType.writingSchool,
      price: 150,
      isUtility: true,
    ),
    BoardTile(
      id: 13,
      title: 'Aşk-ı Memnu',
      type: TileType.property,
      price: 140,
      baseRent: 10,
      category: QuestionCategory.eserKarakter,
    ),
    BoardTile(
      id: 14,
      title: 'Eylül',
      type: TileType.property,
      price: 160,
      baseRent: 12,
      category: QuestionCategory.edebiSanatlar,
    ),

    // Yayınevi
    BoardTile(
      id: 15,
      title: '2. YAYINEVİ',
      type: TileType.publisher,
      price: 200,
      isUtility: true,
    ),

    // 4. Grup (Turuncu)
    BoardTile(
      id: 16,
      title: 'İnce Memed',
      type: TileType.property,
      price: 180,
      baseRent: 14,
      category: QuestionCategory.benKimim,
    ),
    BoardTile(id: 17, title: 'KADER KARTI', type: TileType.fate),
    BoardTile(
      id: 18,
      title: 'Yer Demir Gök Bakır',
      type: TileType.property,
      price: 180,
      baseRent: 14,
      category: QuestionCategory.benKimim,
    ),
    BoardTile(
      id: 19,
      title: 'Teneke',
      type: TileType.property,
      price: 200,
      baseRent: 16,
      category: QuestionCategory.benKimim,
    ),

    // --- KÖŞE 2 (SAĞ ÜST) ---
    // 20. İMZA GÜNÜ
    BoardTile(id: 20, title: 'İMZA GÜNÜ', type: TileType.autographDay),

    // --- 3. KENAR (SAĞ) ---
    // 5. Grup (Kırmızı)
    BoardTile(
      id: 21,
      title: 'Saatleri Ayarlama',
      type: TileType.property,
      price: 220,
      baseRent: 18,
      category: QuestionCategory.eserKarakter,
    ),
    BoardTile(id: 22, title: 'ŞANS KARTI', type: TileType.chance),
    BoardTile(
      id: 23,
      title: 'Huzur',
      type: TileType.property,
      price: 220,
      baseRent: 18,
      category: QuestionCategory.eserKarakter,
    ),
    BoardTile(
      id: 24,
      title: 'Beş Şehir',
      type: TileType.property,
      price: 240,
      baseRent: 20,
      category: QuestionCategory.edebiSanatlar,
    ),

    // Yayınevi
    BoardTile(
      id: 25,
      title: '3. YAYINEVİ',
      type: TileType.publisher,
      price: 200,
      isUtility: true,
    ),

    // 6. Grup (Sarı)
    BoardTile(
      id: 26,
      title: 'Devlet Ana',
      type: TileType.property,
      price: 260,
      baseRent: 22,
      category: QuestionCategory.turkEdebiyatindaIlkler,
    ),
    BoardTile(
      id: 27,
      title: 'Yorgun Savaşçı',
      type: TileType.property,
      price: 260,
      baseRent: 22,
      category: QuestionCategory.turkEdebiyatindaIlkler,
    ),
    BoardTile(
      id: 28,
      title: 'EĞİTİM VAKFI',
      type: TileType.educationFoundation,
      price: 150,
      isUtility: true,
    ),
    BoardTile(
      id: 29,
      title: 'Esir Şehrin İnsanları',
      type: TileType.property,
      price: 280,
      baseRent: 24,
      category: QuestionCategory.turkEdebiyatindaIlkler,
    ),

    // --- KÖŞE 3 (SAĞ ALT) ---
    // 30. İFLAS RİSKİ
    BoardTile(id: 30, title: 'İFLAS RİSKİ', type: TileType.bankruptcyRisk),

    // --- 4. KENAR (ALT) ---
    // 7. Grup (Yeşil)
    BoardTile(
      id: 31,
      title: 'Tutunamayanlar',
      type: TileType.property,
      price: 300,
      baseRent: 26,
      category: QuestionCategory.edebiyatAkimlari,
    ),
    BoardTile(
      id: 32,
      title: 'Tehlikeli Oyunlar',
      type: TileType.property,
      price: 300,
      baseRent: 26,
      category: QuestionCategory.edebiyatAkimlari,
    ),
    BoardTile(id: 33, title: 'KADER KARTI', type: TileType.fate),
    BoardTile(
      id: 34,
      title: 'Oyunlarla Yaşayanlar',
      type: TileType.property,
      price: 320,
      baseRent: 28,
      category: QuestionCategory.edebiyatAkimlari,
    ),

    // Yayınevi
    BoardTile(
      id: 35,
      title: '4. YAYINEVİ',
      type: TileType.publisher,
      price: 200,
      isUtility: true,
    ),

    // 8. Grup (Lacivert/Mavi)
    BoardTile(id: 36, title: 'ŞANS KARTI', type: TileType.chance),
    BoardTile(
      id: 37,
      title: 'Kara Kitap',
      type: TileType.property,
      price: 350,
      baseRent: 35,
      category: QuestionCategory.edebiSanatlar,
    ),
    BoardTile(id: 38, title: 'YAZARLIK VERGİSİ', type: TileType.writingTax),
    BoardTile(
      id: 39,
      title: 'Benim Adım Kırmızı',
      type: TileType.property,
      price: 400,
      baseRent: 50,
      category: QuestionCategory.edebiSanatlar,
    ),
  ];

  static BoardTile getTile(int id) {
    if (id < 0 || id >= tiles.length) return tiles[0];
    return tiles[id];
  }

  static void upgradeTile(int id) {
    var old = tiles[id];
    // Sadece level 4'ten küçükse artır
    if (old.upgradeLevel < 4) {
      tiles[id] = old.copyWith(upgradeLevel: old.upgradeLevel + 1);
    }
  }
}
