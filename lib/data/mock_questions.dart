import '../models/game_enums.dart';

class Question {
  final String text;
  final List<String> options;
  final int correctIndex;
  final QuestionCategory category;

  const Question({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.category,
  });
}

const List<Question> mockQuestions = [
  // Eser-Karakter
  Question(
    text: "Çalıkuşu romanının baş karakteri kimdir?",
    options: ["Feride", "Bihter", "Hürrem", "Kösem"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Sinekli Bakkal'ın Rabia'sı hangi müzik aletiyle ilgilenir?",
    options: ["Ud", "Ney", "Keman", "Piyano"],
    correctIndex:
        1, // Neyzen Tevfik etkisi, ama kitapta ses/hafız da var. Aslında Rabia hafız ve mevlithandır. Ama şıklarda aldatmaca olsun.
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Mai ve Siyah'ın Ahmet Cemil'i ne iş yapar?",
    options: ["Doktor", "Şair/Gazeteci", "Mühendis", "Asker"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Aşk-ı Memnu'daki Behlül'ün yasak aşkı kimdir?",
    options: ["Nihal", "Bihter", "Firdevs", "Peyker"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Huzur romanının baş karakteri Mümtaz'ın sevgilisi kimdir?",
    options: ["Nuran", "Suat", "Handan", "Ferhunde"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),

  // Türk Edebiyatında İlkler
  Question(
    text: "İlk yerli tiyatro eserimiz hangisidir?",
    options: ["Vatan Yahut Silistre", "Şair Evlenmesi", "İntibah", "Cezmi"],
    correctIndex: 1,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk yerli romanımız hangisidir?",
    options: ["Taaşşuk-ı Talat ve Fitnat", "Mai ve Siyah", "İntibah", "Cezmi"],
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk edebi romanımız kabul edilen eser hangisidir?",
    options: ["İntibah", "Araba Sevdası", "Eylül", "Karabibik"],
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "Sahnelenen ilk tiyatro eserimiz hangisidir?",
    options: [
      "Şair Evlenmesi",
      "Vatan Yahut Silistre",
      "Zavallı Çocuk",
      "Akif Bey",
    ],
    correctIndex: 1,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),

  // Edebiyat Akımları
  Question(
    text: "Hangisi 'Beş Hececiler'den biri değildir?",
    options: ["Orhan Veli", "Faruk Nafiz", "Yusuf Ziya", "Enis Behiç"],
    correctIndex: 0,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Garip Akımı (I. Yeni) kurucularından biri kimdir?",
    options: [
      "Cemal Süreya",
      "Melih Cevdet Anday",
      "Nazım Hikmet",
      "Atilla İlhan",
    ],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Servet-i Fünun dönemi hangi akımın etkisindedir?",
    options: ["Realizm / Parnasizm", "Romantizm", "Klasisizm", "Sürrealizm"],
    correctIndex: 0,
    category: QuestionCategory.edebiyatAkimlari,
  ),

  // Ben Kimim? (Yazar Tahmini)
  Question(
    text: "'İstanbul Şairi' olarak bilinen yazarımız kimdir?",
    options: [
      "Yahya Kemal Beyatlı",
      "Orhan Veli",
      "Ahmet Hamdi Tanpınar",
      "Necip Fazıl",
    ],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Vatan Şairi' olarak anılan isim kimdir?",
    options: [
      "Mehmet Akif Ersoy",
      "Namık Kemal",
      "Ziya Gökalp",
      "Tevfik Fikret",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "Nobel Edebiyat Ödülü'nü alan ilk Türk yazar kimdir?",
    options: ["Yaşar Kemal", "Orhan Pamuk", "Aziz Nesin", "Elif Şafak"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),

  // Divan Edebiyatı
  Question(
    text: "Divan edebiyatında 'Hiciv' (eleştiri) ustası kimdir?",
    options: ["Fuzuli", "Baki", "Nefi", "Nedim"],
    correctIndex: 2,
    category: QuestionCategory.divanEdebiyati,
  ),
  Question(
    text: "'Su Kasidesi' kime aittir?",
    options: ["Fuzuli", "Baki", "Nedim", "Şeyhi"],
    correctIndex: 0,
    category: QuestionCategory.divanEdebiyati,
  ),

  // Cumhuriyet Dönemi
  Question(
    text: "'Saatleri Ayarlama Enstitüsü' kime aittir?",
    options: ["Ahmet Hamdi Tanpınar", "Oğuz Atay", "Peyami Safa", "Sait Faik"],
    correctIndex: 0,
    category: QuestionCategory.cumhuriyetDonemi,
  ),
  Question(
    text: "'İnce Memed' serisinin yazarı kimdir?",
    options: ["Kemal Tahir", "Orhan Kemal", "Yaşar Kemal", "Sabahattin Ali"],
    correctIndex: 2,
    category: QuestionCategory.cumhuriyetDonemi,
  ),

  // Genel Kültür / Karışık
  Question(
    text: "İstiklal Marşı'nın yazarı kimdir?",
    options: ["Mehmet Akif Ersoy", "Ziya Gökalp", "Namık Kemal", "Faruk Nafiz"],
    correctIndex: 0,
    category: QuestionCategory.genelKultur,
  ),
  Question(
    text: "Hangisi Yakup Kadri Karaosmanoğlu'nun eseridir?",
    options: ["Yaban", "Sinekli Bakkal", "Fatih-Harbiye", "Aylak Adam"],
    correctIndex: 0,
    category: QuestionCategory.cumhuriyetDonemi,
  ),
];
