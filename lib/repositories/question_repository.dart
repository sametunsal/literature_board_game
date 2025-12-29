import '../models/question.dart';

/// Repository for literature questions with dummy data
class QuestionRepository {
  /// Get a random question from specified category
  static Question getRandomQuestion(QuestionCategory category) {
    final questions = _getQuestionsByCategory(category);
    final random = DateTime.now().millisecond % questions.length;
    return questions[random];
  }

  /// Get all questions for a category
  static List<Question> _getQuestionsByCategory(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.benKimim:
        return _benKimimQuestions;
      case QuestionCategory.turkEdebiyatindaIlkler:
        return _ilklerQuestions;
      case QuestionCategory.edebiyatAkillari:
        return _akimlarQuestions;
      case QuestionCategory.edebiyatSanatlari:
        return _sanatlarQuestions;
      case QuestionCategory.eserKarakter:
        return _eserKarakterQuestions;
    }
  }

  // ========================================
  // BEN KİMİM? (Who Am I?) Questions
  // ========================================
  static final List<Question> _benKimimQuestions = [
    Question(
      id: 'bk001',
      category: QuestionCategory.benKimim,
      difficulty: Difficulty.easy,
      question: 'Hangi yazar Tutunamayanlar romanının yazarıdır?',
      answer: 'Oğuz Atay',
    ),
    Question(
      id: 'bk002',
      category: QuestionCategory.benKimim,
      difficulty: Difficulty.easy,
      question: 'İnce Memed romanının yazarı kimdir?',
      answer: 'Yaşar Kemal',
    ),
    Question(
      id: 'bk003',
      category: QuestionCategory.benKimim,
      difficulty: Difficulty.easy,
      question: 'Kürk Mantolu Madonna kitabının yazarı kimdir?',
      answer: 'Sabahattin Ali',
    ),
    Question(
      id: 'bk004',
      category: QuestionCategory.benKimim,
      difficulty: Difficulty.medium,
      question: 'Saatleri Ayarlama Enstitüsü romanının yazarı kimdir?',
      answer: 'Ahmet Hamdi Tanpınar',
    ),
    Question(
      id: 'bk005',
      category: QuestionCategory.benKimim,
      difficulty: Difficulty.medium,
      question: 'Kırlangıç Yuvası romanının yazarı kimdir?',
      answer: 'Sait Faik Abasıyanık',
    ),
    Question(
      id: 'bk006',
      category: QuestionCategory.benKimim,
      difficulty: Difficulty.hard,
      question: 'Yer Demir Gök Bakır romanının yazarı kimdir?',
      answer: 'Yaşar Kemal',
    ),
    Question(
      id: 'bk007',
      category: QuestionCategory.benKimim,
      difficulty: Difficulty.hard,
      question: 'Tersane İstanbulda romanının yazarı kimdir?',
      answer: 'Selim İleri',
    ),
  ];

  // ========================================
  // İLKLER (Firsts) Questions
  // ========================================
  static final List<Question> _ilklerQuestions = [
    Question(
      id: 'il001',
      category: QuestionCategory.turkEdebiyatindaIlkler,
      difficulty: Difficulty.easy,
      question: 'Türkiyede ilk roman hangisidir?',
      answer: 'İntibah',
    ),
    Question(
      id: 'il002',
      category: QuestionCategory.turkEdebiyatindaIlkler,
      difficulty: Difficulty.easy,
      question: 'Türk edebiyatında ilk tiyatro oyunu kimin eseridir?',
      answer: 'Şair Evlenmesi - Şinasi',
    ),
    Question(
      id: 'il003',
      category: QuestionCategory.turkEdebiyatindaIlkler,
      difficulty: Difficulty.medium,
      question: 'Türk edebiyatında ilk mizah dergisi hangisidir?',
      answer: 'Diyojen',
    ),
    Question(
      id: 'il004',
      category: QuestionCategory.turkEdebiyatindaIlkler,
      difficulty: Difficulty.medium,
      question: 'Türk edebiyatında ilk roman kimin eseridir?',
      answer: 'Taaşşuk-ı Talat - Şemsettin Sami',
    ),
    Question(
      id: 'il005',
      category: QuestionCategory.turkEdebiyatindaIlkler,
      difficulty: Difficulty.hard,
      question: 'Türk edebiyatında ilk şiir kitabını kim yazmıştır?',
      answer: 'Divan - Fuzuli',
    ),
  ];

  // ========================================
  // AKIMLAR (Movements) Questions
  // ========================================
  static final List<Question> _akimlarQuestions = [
    Question(
      id: 'ak001',
      category: QuestionCategory.edebiyatAkillari,
      difficulty: Difficulty.easy,
      question: 'Servet-i Fünun dergi hangi edebi akımı temsil eder?',
      answer: 'Servet-i Fünun Edebiyatı',
    ),
    Question(
      id: 'ak002',
      category: QuestionCategory.edebiyatAkillari,
      difficulty: Difficulty.easy,
      question: 'Yeni Lisan akımının öncüsü kimdir?',
      answer: 'Ziya Gökalp',
    ),
    Question(
      id: 'ak003',
      category: QuestionCategory.edebiyatAkillari,
      difficulty: Difficulty.medium,
      question: 'Edebiyat-ı Cedide akımı hangi dönemi kapsar?',
      answer: 'Divan edebiyatı',
    ),
    Question(
      id: 'ak004',
      category: QuestionCategory.edebiyatAkillari,
      difficulty: Difficulty.medium,
      question: 'Milli Edebiyat akımının temsilcilerinden biri hangisidir?',
      answer: 'Namık Kemal',
    ),
    Question(
      id: 'ak005',
      category: QuestionCategory.edebiyatAkillari,
      difficulty: Difficulty.hard,
      question: 'Garip akımının kurucuları kimlerdir?',
      answer: 'Orhan Veli ve Melih Cevdet Anday',
    ),
  ];

  // ========================================
  // SANATLAR (Arts) Questions
  // ========================================
  static final List<Question> _sanatlarQuestions = [
    Question(
      id: 'sa001',
      category: QuestionCategory.edebiyatSanatlari,
      difficulty: Difficulty.easy,
      question: 'Şiir ve Sanat dergisinin kurucusu kimdir?',
      answer: 'Ahmet Haşim',
    ),
    Question(
      id: 'sa002',
      category: QuestionCategory.edebiyatSanatlari,
      difficulty: Difficulty.easy,
      question: 'Türk sanat müziğinin kurucusu kimdir?',
      answer: 'Dede Efendi',
    ),
    Question(
      id: 'sa003',
      category: QuestionCategory.edebiyatSanatlari,
      difficulty: Difficulty.medium,
      question: 'Yedi Meşale Cemiyeti hangi sanat dalıyla ilgilenirdi?',
      answer: 'Tiyatro',
    ),
    Question(
      id: 'sa004',
      category: QuestionCategory.edebiyatSanatlari,
      difficulty: Difficulty.medium,
      question: 'Darülbedayi nedir?',
      answer: 'İlk sanat okulu',
    ),
    Question(
      id: 'sa005',
      category: QuestionCategory.edebiyatSanatlari,
      difficulty: Difficulty.hard,
      question: 'Yeni Edebiyat akımının sanat anlayışı nasıldır?',
      answer: 'Sanat sanat içindir',
    ),
  ];

  // ========================================
  // ESER-KARAKTER (Works/Characters) Questions
  // ========================================
  static final List<Question> _eserKarakterQuestions = [
    Question(
      id: 'ek001',
      category: QuestionCategory.eserKarakter,
      difficulty: Difficulty.easy,
      question: 'İnce Memed romanında ana karakterin sevgilisinin adı nedir?',
      answer: 'Hatçe',
    ),
    Question(
      id: 'ek002',
      category: QuestionCategory.eserKarakter,
      difficulty: Difficulty.easy,
      question: 'Tutunamayanlar romanında Selimin mesleği nedir?',
      answer: 'Mühendis',
    ),
    Question(
      id: 'ek003',
      category: QuestionCategory.eserKarakter,
      difficulty: Difficulty.medium,
      question: 'Kürk Mantolu Madonna romanında Raifin mesleği nedir?',
      answer: 'Gümrük memuru',
    ),
    Question(
      id: 'ek004',
      category: QuestionCategory.eserKarakter,
      difficulty: Difficulty.medium,
      question: 'Yılanların Öcü romanında köyün adı nedir?',
      answer: 'Saklıtatlar',
    ),
    Question(
      id: 'ek005',
      category: QuestionCategory.eserKarakter,
      difficulty: Difficulty.hard,
      question:
          'Saatleri Ayarlama Enstitüsü romanında Halitin kızının adı nedir?',
      answer: 'Nuran',
    ),
    Question(
      id: 'ek006',
      category: QuestionCategory.eserKarakter,
      difficulty: Difficulty.hard,
      question: 'Suç ve Ceza romanında Raskolnikovun mesleği nedir?',
      answer: 'Öğrenci',
    ),
  ];

  /// Get all questions as a pool
  static List<Question> getAllQuestions() {
    return [
      ..._benKimimQuestions,
      ..._ilklerQuestions,
      ..._akimlarQuestions,
      ..._sanatlarQuestions,
      ..._eserKarakterQuestions,
    ];
  }
}
