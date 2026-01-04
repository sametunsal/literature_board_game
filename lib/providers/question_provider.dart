import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../repositories/question_repository.dart';

// Question loading provider
final questionLoadingProvider = FutureProvider<void>((ref) async {
  await QuestionRepository.loadQuestions();
  print('✅ Questions loaded from JSON asset');
});

// Question pool provider
List<Question> generateQuestions() {
  return [
    // Ben Kimim? Questions
    Question(
      id: 'q1',
      category: QuestionCategory.benKimim,
      difficulty: Difficulty.easy,
      question:
          'Türk edebiyatında "Çağlayan" takma adıyla bilinen şair kimdir?',
      answer: 'Orhan Veli',
      options: [
        'Orhan Veli',
        'Nazım Hikmet',
        'Can Yücel',
        'Melih Cevdet Anday',
      ],
      hint: 'Garip akımının kurucusudur',
    ),
    Question(
      id: 'q2',
      category: QuestionCategory.benKimim,
      difficulty: Difficulty.medium,
      question: '"Uçurtma Avcısı" romanının yazarı kimdir?',
      answer: 'Ahmet Hamdi Tanpınar',
      options: [
        'Ahmet Hamdi Tanpınar',
        'Yaşar Kemal',
        'Ömer Seyfettin',
        'Sait Faik Abasıyanık',
      ],
      hint: 'Aynı zamanda "Saatleri Ayarlama Enstitüsü"nün yazarıdır',
    ),
    Question(
      id: 'q3',
      category: QuestionCategory.benKimim,
      difficulty: Difficulty.hard,
      question: '"Saatleri Ayarlama Enstitüsü" romanını kim yazmıştır?',
      answer: 'Ahmet Hamdi Tanpınar',
      options: [
        'Ahmet Hamdi Tanpınar',
        'Orhan Pamuk',
        'Yaşar Kemal',
        'Elif Şafak',
      ],
      hint: 'Türk edebiyatında modernist romanın öncülerindendir',
    ),

    // Türk Edebiyatında İlkler Questions
    Question(
      id: 'q4',
      category: QuestionCategory.turkEdebiyatindaIlkler,
      difficulty: Difficulty.easy,
      question: 'Türk edebiyatında ilk roman hangisidir?',
      answer: 'İntibah',
      options: [
        'İntibah',
        'Araba Sevdası',
        'Taaşşuk-ı Talat ve Fitnat',
        'İnce Memed',
      ],
      hint: 'Namık Kemal eseridir',
    ),
    Question(
      id: 'q5',
      category: QuestionCategory.turkEdebiyatindaIlkler,
      difficulty: Difficulty.medium,
      question: 'Türk edebiyatında ilk tiyatro oyunu yazarı kimdir?',
      answer: 'Şinasi',
      options: ['Şinasi', 'Namık Kemal', 'Ziya Paşa', 'Ahmet Mithat Efendi'],
      hint: 'Şair Şinasi aynı zamanda tiyatro yazarıdır',
    ),
    Question(
      id: 'q6',
      category: QuestionCategory.turkEdebiyatindaIlkler,
      difficulty: Difficulty.hard,
      question: 'İlk Türkçe gazetenin adı nedir?',
      answer: 'Takvim-i Vekayi',
      options: [
        'Takvim-i Vekayi',
        'Tercüman-ı Ahval',
        'Ceride-i Havadis',
        'Bosphor',
      ],
      hint: 'Osmanlı döneminde çıkarılmıştır',
    ),

    // Edebiyat Akilları Questions
    Question(
      id: 'q7',
      category: QuestionCategory.edebiyatAkimlari,
      difficulty: Difficulty.easy,
      question: 'Nazım Hikmet Ran hangi sanat akımıyla ilişkilendirilir?',
      answer: 'Gerçekçilik',
      options: ['Gerçekçilik', 'Romantizm', 'Sembolizm', 'Yedinci Meşverci'],
      hint: 'Toplumcu şiir akımıdır',
    ),
    Question(
      id: 'q8',
      category: QuestionCategory.edebiyatAkimlari,
      difficulty: Difficulty.medium,
      question: 'Yaşar Kemal\'in "İnce Memed" romanında ana tema nedir?',
      answer: 'Ağa sisteminin eleştirisi',
      options: [
        'Ağa sisteminin eleştirisi',
        'Şehir hayatı',
        'Aşk hikayeleri',
        'Tarihsel olaylar',
      ],
      hint: 'Çukurova bölgesinde geçer',
    ),
    Question(
      id: 'q9',
      category: QuestionCategory.edebiyatAkimlari,
      difficulty: Difficulty.hard,
      question: 'Orhan Pamuk hangi ödülü 2006 yılında kazanmıştır?',
      answer: 'Nobel Edebiyat Ödülü',
      options: [
        'Nobel Edebiyat Ödülü',
        'Pulitzer',
        'Man Booker',
        'Goethe Ödülü',
      ],
      hint: 'Türkiye\'den ilk alan kişidir',
    ),

    // Edebiyat Sanatları Questions
    Question(
      id: 'q10',
      category: QuestionCategory.edebiyatSanatlari,
      difficulty: Difficulty.easy,
      question: 'İki satırlı dörtlük benzerliklerine verilen ad nedir?',
      answer: 'Kafiye',
      options: ['Kafiye', 'Redif', 'Cağ', 'Aruz'],
      hint: 'Ses uyumudur',
    ),
    Question(
      id: 'q11',
      category: QuestionCategory.edebiyatSanatlari,
      difficulty: Difficulty.medium,
      question: 'Divan edebiyatında beyit kaç dizeden oluşur?',
      answer: '2',
      options: ['2', '3', '4', '5'],
      hint: 'Mesnevi ve Divan şiirinin temel birimidir',
    ),
    Question(
      id: 'q12',
      category: QuestionCategory.edebiyatSanatlari,
      difficulty: Difficulty.hard,
      question: 'Şiirde kelime oyunu ve tezat sanatına verilen genel ad nedir?',
      answer: 'Belagat',
      options: ['Belagat', 'Bedi', 'Ravz', 'Sade'],
      hint: 'Dil sanatlarının tümüdür',
    ),

    // Eser/Karakter Questions
    Question(
      id: 'q13',
      category: QuestionCategory.eserKarakter,
      difficulty: Difficulty.easy,
      question: '"Siyah İnci" romanının ana karakteri kimdir?',
      answer: 'Karaibrahim',
      options: ['Karaibrahim', 'Memed', 'Şeker Pasha', 'Celal'],
      hint: 'Ahmet Hamdi Tanpınar romanıdır',
    ),
    Question(
      id: 'q14',
      category: QuestionCategory.eserKarakter,
      difficulty: Difficulty.medium,
      question: '"Yer Demir Gök Bakır" romanının yazarı kimdir?',
      answer: 'Yaşar Kemal',
      options: ['Yaşar Kemal', 'Orhan Kemal', 'Kemal Tahir', 'Fakir Baykurt'],
      hint: 'Anadolu insanını anlatan bir yazardır',
    ),
    Question(
      id: 'q15',
      category: QuestionCategory.eserKarakter,
      difficulty: Difficulty.hard,
      question: '"Suç ve Ceza" romanının yazarı kimdir?',
      answer: 'Dostoyevski',
      options: ['Dostoyevski', 'Tolstoy', 'Çehov', 'Gorki'],
      hint: 'Rus yazardır',
    ),

    // More questions for variety
    Question(
      id: 'q16',
      category: QuestionCategory.benKimim,
      difficulty: Difficulty.easy,
      question: '"Kırlangıç Yuvası" romanının yazarı kimdir?',
      answer: 'Sait Faik Abasıyanık',
      options: [
        'Sait Faik Abasıyanık',
        'Yaşar Kemal',
        'Orhan Kemal',
        'Sabahattin Ali',
      ],
      hint: 'Hikaye ustasıdır',
    ),
    Question(
      id: 'q17',
      category: QuestionCategory.turkEdebiyatindaIlkler,
      difficulty: Difficulty.easy,
      question: 'İlk Türk kadın romancı kimdir?',
      answer: 'Halide Edip Adıvar',
      options: [
        'Halide Edip Adıvar',
        'Afet İnan',
        'Emine Semiye',
        'Fatma Aliye',
      ],
      hint: 'Kurtuluş Savaşı romanlarıyla bilinir',
    ),
    Question(
      id: 'q18',
      category: QuestionCategory.edebiyatAkimlari,
      difficulty: Difficulty.easy,
      question: '"Tutunamayanlar" romanının yazarı kimdir?',
      answer: 'Oğuz Atay',
      options: ['Oğuz Atay', 'Bilge Karasu', 'Orhan Pamuk', 'Latife Tekin'],
      hint: 'Postmodernist roman öncüsüdür',
    ),
    Question(
      id: 'q19',
      category: QuestionCategory.edebiyatSanatlari,
      difficulty: Difficulty.medium,
      question: 'Anlatımda olayların gerçekleşme sırasına ne denir?',
      answer: 'Kronoloji',
      options: ['Kronoloji', 'Gerileme', 'Hızlanma', 'Paragraf'],
      hint: 'Zaman akışıdır',
    ),
    Question(
      id: 'q20',
      category: QuestionCategory.eserKarakter,
      difficulty: Difficulty.medium,
      question: '"Sefiller" romanının yazarı kimdir?',
      answer: 'Victor Hugo',
      options: ['Victor Hugo', 'Dostoyevski', 'Balzac', 'Flaubert'],
      hint: 'Fransız yazardır',
    ),
  ];
}
