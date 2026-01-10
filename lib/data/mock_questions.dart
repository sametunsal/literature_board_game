import '../models/game_enums.dart';
import '../models/question.dart';

final List<Question> mockQuestions = [
  // ESER-KARAKTER
  Question(
    text: "Çalıkuşu romanının baş karakteri Feride'nin mesleği nedir?",
    options: ["Hemşire", "Öğretmen", "Doktor", "Avukat"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Bihter ve Behlül hangi romanın karakterleridir?",
    options: ["Yaprak Dökümü", "Aşk-ı Memnu", "Eylül", "Mai ve Siyah"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'İnce Memed' romanının yazarı kimdir?",
    options: ["Orhan Kemal", "Yaşar Kemal", "Kemal Tahir", "Sabahattin Ali"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),

  // İLKLER
  Question(
    text: "Türk Edebiyatındaki ilk psikolojik roman hangisidir?",
    options: ["Eylül", "İntibah", "Araba Sevdası", "Mai ve Siyah"],
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk yerli tiyatro eserimiz hangisidir?",
    options: [
      "Vatan Yahut Silistre",
      "Şair Evlenmesi",
      "Zavallı Çocuk",
      "Akif Bey",
    ],
    correctIndex: 1,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "Batılı anlamda ilk romanımız hangisidir?",
    options: [
      "Taaşşuk-ı Talat ve Fitnat",
      "Mai ve Siyah",
      "İntibah",
      "Araba Sevdası",
    ],
    correctIndex: 1,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),

  // AKIMLAR
  Question(
    text: "Hangisi 'Garip' akımı şairlerinden biridir?",
    options: [
      "Nazım Hikmet",
      "Orhan Veli Kanık",
      "Necip Fazıl",
      "Attila İlhan",
    ],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Servet-i Fünun dönemi hangi edebi akımdan etkilenmiştir?",
    options: ["Romantizm", "Realizm ve Sembolizm", "Klasisizm", "Sürrealizm"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),

  // BEN KİMİM?
  Question(
    text: "'Vatan Şairi' olarak bilinen şairimiz kimdir?",
    options: [
      "Namık Kemal",
      "Ziya Gökalp",
      "Mehmet Akif Ersoy",
      "Tevfik Fikret",
    ],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Sultan-ı Şuara' (Şairler Sultanı) ünvanlı Divan şairi kimdir?",
    options: ["Fuzuli", "Nedim", "Baki", "Nefi"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),

  // EDEBİ SANATLAR
  Question(
    text: "Bir şeyi olduğundan çok fazla veya az gösterme sanatına ne denir?",
    options: ["Teşbih", "Mübalağa", "İntak", "Tezat"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "İnsan dışındaki varlıkları konuşturma sanatına ne denir?",
    options: ["Teşhis", "İntak", "Kinaye", "Tevriye"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
];
