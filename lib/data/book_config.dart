import '../models/book.dart';
import '../models/game_enums.dart';

class BookConfig {
  BookConfig._();

  static const int expectedBookCount = 15;

  static const List<Book> books = [
    Book(
      id: 'intibah',
      title: 'İntibah',
      author: 'Namık Kemal',
      category: QuestionCategory.turkEdebiyatindaIlkler,
      tilePosition: 1,
      baskiCostAkce: 8,
      ciltCostAkce: 18,
    ),
    Book(
      id: 'araba_sevdasi',
      title: 'Araba Sevdası',
      boardLabel: 'Araba\nSevdası',
      author: 'Recaizade Mahmut Ekrem',
      category: QuestionCategory.edebiSanatlar,
      tilePosition: 2,
      baskiCostAkce: 8,
      ciltCostAkce: 18,
    ),
    Book(
      id: 'ask_i_memnu',
      title: 'Aşk-ı Memnu',
      boardLabel: 'Aşk-ı\nMemnu',
      author: 'Halit Ziya Uşaklıgil',
      category: QuestionCategory.eserKarakter,
      tilePosition: 4,
      baskiCostAkce: 10,
      ciltCostAkce: 22,
    ),
    Book(
      id: 'sinekli_bakkal',
      title: 'Sinekli Bakkal',
      boardLabel: 'Sinekli\nBakkal',
      author: 'Halide Edib Adıvar',
      category: QuestionCategory.edebiyatAkimlari,
      tilePosition: 5,
      baskiCostAkce: 10,
      ciltCostAkce: 22,
    ),
    Book(
      id: 'calikusu',
      title: 'Çalıkuşu',
      author: 'Reşat Nuri Güntekin',
      category: QuestionCategory.benKimim,
      tilePosition: 7,
      baskiCostAkce: 10,
      ciltCostAkce: 22,
    ),
    Book(
      id: 'kuyucakli_yusuf',
      title: 'Kuyucaklı Yusuf',
      boardLabel: 'Kuyucaklı\nYusuf',
      author: 'Sabahattin Ali',
      category: QuestionCategory.turkEdebiyatindaIlkler,
      tilePosition: 9,
      baskiCostAkce: 12,
      ciltCostAkce: 26,
    ),
    Book(
      id: 'dokuzuncu_hariciye_kogusu',
      title: 'Dokuzuncu Hariciye Koğuşu',
      boardLabel: '9. Koğuş',
      author: 'Peyami Safa',
      category: QuestionCategory.edebiSanatlar,
      tilePosition: 11,
      baskiCostAkce: 12,
      ciltCostAkce: 26,
    ),
    Book(
      id: 'fatih_harbiye',
      title: 'Fatih-Harbiye',
      boardLabel: 'Fatih-\nHarbiye',
      author: 'Peyami Safa',
      category: QuestionCategory.eserKarakter,
      tilePosition: 12,
      baskiCostAkce: 12,
      ciltCostAkce: 26,
    ),
    Book(
      id: 'tutunamayanlar',
      title: 'Tutunamayanlar',
      boardLabel: 'Tutuna-\nmayanlar',
      author: 'Oğuz Atay',
      category: QuestionCategory.edebiyatAkimlari,
      tilePosition: 14,
      baskiCostAkce: 14,
      ciltCostAkce: 30,
    ),
    Book(
      id: 'ince_memed',
      title: 'İnce Memed',
      author: 'Yaşar Kemal',
      category: QuestionCategory.benKimim,
      tilePosition: 15,
      baskiCostAkce: 14,
      ciltCostAkce: 30,
    ),
    Book(
      id: 'saatleri_ayarlama_enstitusu',
      title: 'Saatleri Ayarlama Enstitüsü',
      boardLabel: 'Saatleri\nAyarlama\nEnstitüsü',
      author: 'Ahmet Hamdi Tanpınar',
      category: QuestionCategory.turkEdebiyatindaIlkler,
      tilePosition: 18,
      baskiCostAkce: 14,
      ciltCostAkce: 30,
    ),
    Book(
      id: 'huzur',
      title: 'Huzur',
      author: 'Ahmet Hamdi Tanpınar',
      category: QuestionCategory.edebiSanatlar,
      tilePosition: 20,
      baskiCostAkce: 16,
      ciltCostAkce: 34,
    ),
    Book(
      id: 'yaban',
      title: 'Yaban',
      author: 'Yakup Kadri Karaosmanoğlu',
      category: QuestionCategory.eserKarakter,
      tilePosition: 21,
      baskiCostAkce: 16,
      ciltCostAkce: 34,
    ),
    Book(
      id: 'kiralik_konak',
      title: 'Kiralık Konak',
      boardLabel: 'Kiralık\nKonak',
      author: 'Yakup Kadri Karaosmanoğlu',
      category: QuestionCategory.edebiyatAkimlari,
      tilePosition: 23,
      baskiCostAkce: 16,
      ciltCostAkce: 34,
    ),
    Book(
      id: 'mai_ve_siyah',
      title: 'Mai ve Siyah',
      boardLabel: 'Mai ve\nSiyah',
      author: 'Halit Ziya Uşaklıgil',
      category: QuestionCategory.benKimim,
      tilePosition: 24,
      baskiCostAkce: 16,
      ciltCostAkce: 34,
    ),
  ];

  static Book? getById(String id) {
    for (final book in books) {
      if (book.id == id) return book;
    }
    return null;
  }

  static Book? getByTilePosition(int tilePosition) {
    for (final book in books) {
      if (book.tilePosition == tilePosition) return book;
    }
    return null;
  }
}
