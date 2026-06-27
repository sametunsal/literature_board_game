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
    expect(byId['tutunamayanlar']!.author, 'Oğuz Atay');
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
    expect(byId['saatleri_ayarlama_enstitusu']!.boardLabel, 'Saatler Enst.');
    expect(byId['ask_i_memnu']!.boardLabel, isNull);
  });
}
