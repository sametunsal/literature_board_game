import '../models/game_enums.dart';
import '../models/board_tile.dart';

class BoardConfig {
  static const List<BoardTile> tiles = [
    // 1. BAŞLANGIÇ (Index 0)
    BoardTile(id: 0, title: 'BAŞLANGIÇ', type: TileType.start),

    // 1. GRUP KİTAPLAR
    BoardTile(
      id: 1,
      title: 'Çalıkuşu',
      type: TileType.property,
      price: 100,
      baseRent: 10,
      questionCategory: QuestionCategory.eserKarakter,
    ),
    BoardTile(id: 2, title: 'KADER KARTI', type: TileType.fate),
    BoardTile(
      id: 3,
      title: 'Eylül',
      type: TileType.property,
      price: 120,
      baseRent: 12,
      questionCategory: QuestionCategory.turkEdebiyatindaIlkler,
    ),

    // VERGİ & YAYINEVİ
    BoardTile(id: 4, title: 'GELİR VERGİSİ', type: TileType.incomeTax),
    BoardTile(
      id: 5,
      title: '1. YAYINEVİ (Can)',
      type: TileType.publisher,
      price: 200,
      baseRent: 25,
      isUtilities: true,
    ),

    // 2. GRUP KİTAPLAR
    BoardTile(
      id: 6,
      title: 'Yaban',
      type: TileType.property,
      price: 140,
      baseRent: 14,
      questionCategory: QuestionCategory.benKimim,
    ),
    BoardTile(id: 7, title: 'ŞANS KARTI', type: TileType.chance),
    BoardTile(
      id: 8,
      title: 'Sinekli Bakkal',
      type: TileType.property,
      price: 140,
      baseRent: 14,
      questionCategory: QuestionCategory.eserKarakter,
    ),
    BoardTile(
      id: 9,
      title: 'Kiralık Konak',
      type: TileType.property,
      price: 160,
      baseRent: 16,
      questionCategory: QuestionCategory.benKimim,
    ),

    // 11. KÜTÜPHANE NÖBETİ (Index 10)
    BoardTile(id: 10, title: 'KÜTÜPHANE NÖBETİ', type: TileType.libraryWatch),

    // 3. GRUP KİTAPLAR
    BoardTile(
      id: 11,
      title: 'Mai ve Siyah',
      type: TileType.property,
      price: 180,
      baseRent: 18,
      questionCategory: QuestionCategory.edebiyatAkimlari,
    ),
    BoardTile(
      id: 12,
      title: 'YAZARLIK OKULU',
      type: TileType.writingSchool,
      price: 150,
    ),
    BoardTile(
      id: 13,
      title: 'Aşk-ı Memnu',
      type: TileType.property,
      price: 180,
      baseRent: 18,
      questionCategory: QuestionCategory.eserKarakter,
    ),
    BoardTile(
      id: 14,
      title: 'Araba Sevdası',
      type: TileType.property,
      price: 200,
      baseRent: 20,
      questionCategory: QuestionCategory.turkEdebiyatindaIlkler,
    ),

    BoardTile(
      id: 15,
      title: '2. YAYINEVİ (İletişim)',
      type: TileType.publisher,
      price: 200,
      baseRent: 25,
      isUtilities: true,
    ),

    // 4. GRUP KİTAPLAR
    BoardTile(
      id: 16,
      title: 'İnce Memed',
      type: TileType.property,
      price: 220,
      baseRent: 22,
      questionCategory: QuestionCategory.benKimim,
    ),
    BoardTile(id: 17, title: 'KADER KARTI', type: TileType.fate),
    BoardTile(
      id: 18,
      title: 'Saatleri Ayarlama',
      type: TileType.property,
      price: 220,
      baseRent: 22,
      questionCategory: QuestionCategory.edebiSanatlar,
    ),
    BoardTile(
      id: 19,
      title: 'Huzur',
      type: TileType.property,
      price: 240,
      baseRent: 24,
      questionCategory: QuestionCategory.edebiSanatlar,
    ),

    // 21. İMZA GÜNÜ (Index 20)
    BoardTile(id: 20, title: 'İMZA GÜNÜ', type: TileType.autographDay),

    // 5. GRUP KİTAPLAR
    BoardTile(
      id: 21,
      title: 'Dokuzuncu Hariciye',
      type: TileType.property,
      price: 260,
      baseRent: 26,
      questionCategory: QuestionCategory.benKimim,
    ),
    BoardTile(id: 22, title: 'ŞANS KARTI', type: TileType.chance),
    BoardTile(
      id: 23,
      title: 'Fatih-Harbiye',
      type: TileType.property,
      price: 260,
      baseRent: 26,
      questionCategory: QuestionCategory.eserKarakter,
    ),
    BoardTile(
      id: 24,
      title: 'Kuyucaklı Yusuf',
      type: TileType.property,
      price: 280,
      baseRent: 28,
      questionCategory: QuestionCategory.benKimim,
    ),

    BoardTile(
      id: 25,
      title: '3. YAYINEVİ (Yapı Kredi)',
      type: TileType.publisher,
      price: 200,
      baseRent: 25,
      isUtilities: true,
    ),

    // 6. GRUP KİTAPLAR
    BoardTile(
      id: 26,
      title: 'Devlet Ana',
      type: TileType.property,
      price: 300,
      baseRent: 30,
      questionCategory: QuestionCategory.turkEdebiyatindaIlkler,
    ),
    BoardTile(
      id: 27,
      title: 'Yorgun Savaşçı',
      type: TileType.property,
      price: 300,
      baseRent: 30,
      questionCategory: QuestionCategory.turkEdebiyatindaIlkler,
    ),
    BoardTile(
      id: 28,
      title: 'EĞİTİM VAKFI',
      type: TileType.educationFoundation,
      price: 150,
      isUtilities: true,
    ),
    BoardTile(
      id: 29,
      title: 'Aylak Adam',
      type: TileType.property,
      price: 320,
      baseRent: 32,
      questionCategory: QuestionCategory.edebiyatAkimlari,
    ),

    // 31. İFLAS RİSKİ (Index 30)
    BoardTile(id: 30, title: 'İFLAS RİSKİ', type: TileType.bankruptcyRisk),

    // 7. GRUP KİTAPLAR
    BoardTile(
      id: 31,
      title: 'Tutunamayanlar',
      type: TileType.property,
      price: 350,
      baseRent: 35,
      questionCategory: QuestionCategory.edebiyatAkimlari,
    ),
    BoardTile(
      id: 32,
      title: 'Tehlikeli Oyunlar',
      type: TileType.property,
      price: 350,
      baseRent: 35,
      questionCategory: QuestionCategory.edebiyatAkimlari,
    ),
    BoardTile(id: 33, title: 'KADER KARTI', type: TileType.fate),
    BoardTile(
      id: 34,
      title: 'Kara Kitap',
      type: TileType.property,
      price: 380,
      baseRent: 40,
      questionCategory: QuestionCategory.edebiSanatlar,
    ),

    BoardTile(
      id: 35,
      title: '4. YAYINEVİ (Alfa)',
      type: TileType.publisher,
      price: 200,
      baseRent: 25,
      isUtilities: true,
    ),

    BoardTile(id: 36, title: 'ŞANS KARTI', type: TileType.chance),

    // 8. GRUP KİTAPLAR
    BoardTile(
      id: 37,
      title: 'Benim Adım Kırmızı',
      type: TileType.property,
      price: 400,
      baseRent: 50,
      questionCategory: QuestionCategory.benKimim,
    ),
    BoardTile(id: 38, title: 'YAZARLIK VERGİSİ', type: TileType.writingTax),
    BoardTile(
      id: 39,
      title: 'Masumiyet Müzesi',
      type: TileType.property,
      price: 420,
      baseRent: 60,
      questionCategory: QuestionCategory.eserKarakter,
    ),
  ];
}
