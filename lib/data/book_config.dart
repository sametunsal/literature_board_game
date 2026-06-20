import '../models/book.dart';
import '../models/game_enums.dart';

class BookConfig {
  BookConfig._();

  static const int expectedBookCount = 15;

  static const List<Book> books = [
    Book(
      id: 'intibah',
      title: 'Intibah',
      author: 'Namik Kemal',
      category: QuestionCategory.turkEdebiyatindaIlkler,
      tilePosition: 1,
      baskiCostAkce: 8,
      ciltCostAkce: 18,
    ),
    Book(
      id: 'araba_sevdasi',
      title: 'Araba Sevdasi',
      author: 'Recaizade Mahmut Ekrem',
      category: QuestionCategory.edebiSanatlar,
      tilePosition: 2,
      baskiCostAkce: 8,
      ciltCostAkce: 18,
    ),
    Book(
      id: 'ask_i_memnu',
      title: 'Ask-i Memnu',
      author: 'Halit Ziya Usakligil',
      category: QuestionCategory.eserKarakter,
      tilePosition: 4,
      baskiCostAkce: 10,
      ciltCostAkce: 22,
    ),
    Book(
      id: 'sinekli_bakkal',
      title: 'Sinekli Bakkal',
      author: 'Halide Edib Adivar',
      category: QuestionCategory.edebiyatAkimlari,
      tilePosition: 5,
      baskiCostAkce: 10,
      ciltCostAkce: 22,
    ),
    Book(
      id: 'calikusu',
      title: 'Calikusu',
      author: 'Resat Nuri Guntekin',
      category: QuestionCategory.benKimim,
      tilePosition: 7,
      baskiCostAkce: 10,
      ciltCostAkce: 22,
    ),
    Book(
      id: 'kuyucakli_yusuf',
      title: 'Kuyucakli Yusuf',
      author: 'Sabahattin Ali',
      category: QuestionCategory.turkEdebiyatindaIlkler,
      tilePosition: 9,
      baskiCostAkce: 12,
      ciltCostAkce: 26,
    ),
    Book(
      id: 'dokuzuncu_hariciye_kogusu',
      title: 'Dokuzuncu Hariciye Kogusu',
      author: 'Peyami Safa',
      category: QuestionCategory.edebiSanatlar,
      tilePosition: 11,
      baskiCostAkce: 12,
      ciltCostAkce: 26,
    ),
    Book(
      id: 'fatih_harbiye',
      title: 'Fatih-Harbiye',
      author: 'Peyami Safa',
      category: QuestionCategory.eserKarakter,
      tilePosition: 12,
      baskiCostAkce: 12,
      ciltCostAkce: 26,
    ),
    Book(
      id: 'tutunamayanlar',
      title: 'Tutunamayanlar',
      author: 'Oguz Atay',
      category: QuestionCategory.edebiyatAkimlari,
      tilePosition: 14,
      baskiCostAkce: 14,
      ciltCostAkce: 30,
    ),
    Book(
      id: 'ince_memed',
      title: 'Ince Memed',
      author: 'Yasar Kemal',
      category: QuestionCategory.benKimim,
      tilePosition: 15,
      baskiCostAkce: 14,
      ciltCostAkce: 30,
    ),
    Book(
      id: 'saatleri_ayarlama_enstitusu',
      title: 'Saatleri Ayarlama Enstitusu',
      author: 'Ahmet Hamdi Tanpinar',
      category: QuestionCategory.turkEdebiyatindaIlkler,
      tilePosition: 18,
      baskiCostAkce: 14,
      ciltCostAkce: 30,
    ),
    Book(
      id: 'huzur',
      title: 'Huzur',
      author: 'Ahmet Hamdi Tanpinar',
      category: QuestionCategory.edebiSanatlar,
      tilePosition: 20,
      baskiCostAkce: 16,
      ciltCostAkce: 34,
    ),
    Book(
      id: 'yaban',
      title: 'Yaban',
      author: 'Yakup Kadri Karaosmanoglu',
      category: QuestionCategory.eserKarakter,
      tilePosition: 21,
      baskiCostAkce: 16,
      ciltCostAkce: 34,
    ),
    Book(
      id: 'kiralik_konak',
      title: 'Kiralik Konak',
      author: 'Yakup Kadri Karaosmanoglu',
      category: QuestionCategory.edebiyatAkimlari,
      tilePosition: 23,
      baskiCostAkce: 16,
      ciltCostAkce: 34,
    ),
    Book(
      id: 'mai_ve_siyah',
      title: 'Mai ve Siyah',
      author: 'Halit Ziya Usakligil',
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
