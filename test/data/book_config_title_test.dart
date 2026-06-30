import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/data/book_config.dart';

void main() {
  test('BookConfig uses canonical Turkish titles and authors', () {
    final byId = {for (final book in BookConfig.books) book.id: book};

    expect(byId['intibah']!.title, 'İntibah');
    expect(byId['intibah']!.author, 'Namık Kemal');
    expect(byId['araba_sevdasi']!.title, 'Araba Sevdası');
    expect(byId['ask_i_memnu']!.title, 'Aşk-ı Memnu');
    expect(byId['ask_i_memnu']!.author, 'Halit Ziya Uşaklıgil');
    expect(byId['sinekli_bakkal']!.author, 'Halide Edib Adıvar');
    expect(byId['calikusu']!.title, 'Çalıkuşu');
    expect(byId['calikusu']!.author, 'Reşat Nuri Güntekin');
    expect(byId['kuyucakli_yusuf']!.title, 'Kuyucaklı Yusuf');
    expect(
      byId['dokuzuncu_hariciye_kogusu']!.title,
      'Dokuzuncu Hariciye Koğuşu',
    );
    expect(byId['tehlikeli_oyunlar']!.title, 'Tehlikeli Oyunlar');
    expect(byId['tehlikeli_oyunlar']!.author, 'Oğuz Atay');
    expect(byId['ince_memed']!.title, 'İnce Memed');
    expect(byId['ince_memed']!.author, 'Yaşar Kemal');
    expect(
      byId['saatleri_ayarlama_enstitusu']!.title,
      'Saatleri Ayarlama Enstitüsü',
    );
    expect(byId['saatleri_ayarlama_enstitusu']!.author, 'Ahmet Hamdi Tanpınar');
    expect(byId['huzur']!.author, 'Ahmet Hamdi Tanpınar');
    expect(byId['yaban']!.author, 'Yakup Kadri Karaosmanoğlu');
    expect(byId['kiralik_konak']!.title, 'Kiralık Konak');
    expect(byId['kiralik_konak']!.author, 'Yakup Kadri Karaosmanoğlu');
    expect(byId['mai_ve_siyah']!.author, 'Halit Ziya Uşaklıgil');
  });

  test('BookConfig keeps short board labels only where useful', () {
    final byId = {for (final book in BookConfig.books) book.id: book};

    expect(byId['dokuzuncu_hariciye_kogusu']!.boardLabel, '9. Koğuş');
    expect(
      byId['saatleri_ayarlama_enstitusu']!.boardLabel,
      'Saatleri\nAyarlama\nEnstitüsü',
    );
    expect(byId['araba_sevdasi']!.boardLabel, 'Araba\nSevdas\u0131');
    expect(byId['ask_i_memnu']!.boardLabel, 'A\u015Fk-\u0131\nMemnu');
    expect(byId['sinekli_bakkal']!.boardLabel, 'Sinekli\nBakkal');
    expect(byId['kuyucakli_yusuf']!.boardLabel, 'Kuyucakl\u0131\nYusuf');
    expect(byId['fatih_harbiye']!.boardLabel, 'Fatih\nHarbiye');
    expect(byId['tehlikeli_oyunlar']!.boardLabel, 'Tehlikeli\nOyunlar');
    expect(byId['kiralik_konak']!.boardLabel, 'Kiral\u0131k\nKonak');
    expect(byId['mai_ve_siyah']!.boardLabel, 'Mai ve\nSiyah');
  });

  test('Books without cramped titles keep a null board label', () {
    final byId = {for (final book in BookConfig.books) book.id: book};

    for (final id in ['intibah', 'calikusu', 'ince_memed', 'huzur', 'yaban']) {
      expect(byId[id]!.boardLabel, isNull, reason: 'boardLabel for $id');
    }
  });

  test('Board labels use real words, never abbreviations or ellipsis', () {
    // Reject a letter followed by a lone trailing period (fake abbreviation
    // like "Araba S."), but allow numeric ordinals ("9. Koğuş"). Labels break
    // on whole words ("Tehlikeli\nOyunlar"), never mid-word with a hyphen.
    final abbreviation = RegExp(r'[A-Za-z]\.(\s|$)');
    for (final book in BookConfig.books) {
      final label = book.boardLabel;
      if (label == null) continue;
      expect(
        abbreviation.hasMatch(label),
        isFalse,
        reason: '${book.id} board label "$label" looks abbreviated',
      );
      expect(label, isNot(contains('…')), reason: book.id);
      expect(label, isNot(contains('...')), reason: book.id);
    }
  });

  test('Canonical titles never contain manual line breaks', () {
    for (final book in BookConfig.books) {
      expect(book.title, isNot(contains('\n')), reason: book.id);
      expect(book.title, isNot(contains('\u00AD')), reason: book.id);
    }
    // Board labels may differ from canonical titles.
    final saatleri = BookConfig.getById('saatleri_ayarlama_enstitusu')!;
    expect(saatleri.boardLabel, isNot(saatleri.title));
  });

  test('Board label changes do not alter gameplay fields', () {
    final byId = {for (final book in BookConfig.books) book.id: book};

    expect(byId['tehlikeli_oyunlar']!.tilePosition, 14);
    expect(byId['tehlikeli_oyunlar']!.baskiCostAkce, 14);
    expect(byId['tehlikeli_oyunlar']!.ciltCostAkce, 30);
    expect(byId['tehlikeli_oyunlar']!.id, 'tehlikeli_oyunlar');
    expect(byId['tehlikeli_oyunlar']!.title, 'Tehlikeli Oyunlar');
    expect(byId['saatleri_ayarlama_enstitusu']!.tilePosition, 18);
    expect(byId['saatleri_ayarlama_enstitusu']!.baskiCostAkce, 14);
    expect(byId['saatleri_ayarlama_enstitusu']!.ciltCostAkce, 30);
    expect(byId['ask_i_memnu']!.tilePosition, 4);
    expect(byId['ask_i_memnu']!.baskiCostAkce, 10);
    expect(byId['ask_i_memnu']!.ciltCostAkce, 22);
    expect(BookConfig.books.length, 15);
  });
}
