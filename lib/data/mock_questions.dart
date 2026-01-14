import '../models/game_enums.dart';
import '../models/question.dart';

/// Expanded question database with 15+ questions per category
final List<Question> mockQuestions = [
  // ═══════════════════════════════════════════════════════════════════════════
  // ESER-KARAKTER (Eser ve Karakter İlişkileri) - 20 Questions
  // ═══════════════════════════════════════════════════════════════════════════
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
  Question(
    text: "Huzur romanının başkahramanı Mümtaz'ın aşık olduğu kadın kimdir?",
    options: ["Nuran", "Suad", "Leyla", "Bihter"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Kuyucaklı Yusuf romanının yazarı kimdir?",
    options: [
      "Reşat Nuri Güntekin",
      "Sabahattin Ali",
      "Peyami Safa",
      "Orhan Kemal",
    ],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Yaprak Dökümü romanında ailenin reisi olan babanın adı nedir?",
    options: ["Ali Rıza Bey", "Şevket Bey", "Halit Bey", "Kemal Bey"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Tutunamayanlar' romanının yazarı kimdir?",
    options: [
      "Yusuf Atılgan",
      "Oğuz Atay",
      "Orhan Pamuk",
      "Ahmet Hamdi Tanpınar",
    ],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text:
        "Sinekli Bakkal romanının baş karakteri Rabia Hanım'ın kocası kimdir?",
    options: ["Selim Paşa", "Tevfik Efendi", "Hilmi Efendi", "Peregrini"],
    correctIndex: 3,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Aylak Adam' romanının yazarı kimdir?",
    options: ["Yusuf Atılgan", "Oğuz Atay", "Bilge Karasu", "Ferit Edgü"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Kiralık Konak romanında Seniha'nın aşık olduğu kişi kimdir?",
    options: ["Hakkı Celis", "Faik Bey", "Servet Bey", "Naim Efendi"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Mai ve Siyah' romanının baş karakteri kimdir?",
    options: ["Ahmet Cemil", "Bihruz Bey", "Ali Bey", "Raci"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Araba Sevdası romanının baş karakteri kimdir?",
    options: ["Ahmet Cemil", "Bihruz Bey", "Felâtun Bey", "Rakım Efendi"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Dokuzuncu Hariciye Koğuşu' romanının yazarı kimdir?",
    options: ["Reşat Nuri", "Peyami Safa", "Yakup Kadri", "Halide Edip"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Eylül romanının baş karakterleri kimlerdir?",
    options: [
      "Suat ve Necip",
      "Bihter ve Behlül",
      "Feride ve Kamran",
      "Nuran ve Mümtaz",
    ],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Küçük Ağa' romanının yazarı kimdir?",
    options: ["Kemal Tahir", "Tarık Buğra", "Orhan Kemal", "Yaşar Kemal"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Yaban romanının baş karakteri Ahmet Celal'in mesleği nedir?",
    options: ["Asker", "Öğretmen", "Doktor", "Mühendis"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Fatih-Harbiye' romanının yazarı kimdir?",
    options: ["Reşat Nuri", "Peyami Safa", "Yakup Kadri", "Halide Edip"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Sergüzeşt romanının baş karakteri olan cariye kimdir?",
    options: ["Dilber", "Dilşad", "Asaf", "Celal"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Bir Düğün Gecesi' romanının yazarı kimdir?",
    options: ["Adalet Ağaoğlu", "Leyla Erbil", "Sevgi Soysal", "Pınar Kür"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "İntibah romanının baş karakteri kimdir?",
    options: ["Ali Bey", "Bihruz Bey", "Ahmet Cemil", "Suat"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // TÜRK EDEBİYATINDA İLKLER - 20 Questions
  // ═══════════════════════════════════════════════════════════════════════════
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
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk köy romanı hangisidir?",
    options: [
      "Küçük Ağa",
      "Yaban",
      "Bereketli Topraklar Üzerinde",
      "Karadağlar",
    ],
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "Türk edebiyatında ilk makale kimin tarafından yazılmıştır?",
    options: ["Namık Kemal", "Şinasi", "Ziya Paşa", "Ahmet Mithat"],
    correctIndex: 1,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk resmi gazete hangisidir?",
    options: [
      "Tercüman-ı Ahval",
      "Takvim-i Vekayi",
      "Ceride-i Havadis",
      "Hürriyet",
    ],
    correctIndex: 1,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "Edebiyat-ı Cedide'nin ilk öykü yazarı kimdir?",
    options: ["Halit Ziya", "Mehmet Rauf", "Hüseyin Cahit", "Tevfik Fikret"],
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk realist roman hangisidir?",
    options: ["Araba Sevdası", "Mai ve Siyah", "Aşk-ı Memnu", "Eylül"],
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk çeviri roman hangisidir?",
    options: ["Telemak", "Robinson Crusoe", "Monte Cristo", "Sefiller"],
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk özel gazete hangisidir?",
    options: [
      "Takvim-i Vekayi",
      "Tercüman-ı Ahval",
      "Ceride-i Havadis",
      "Hürriyet",
    ],
    correctIndex: 1,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk tarihi roman hangisidir?",
    options: ["Cezmi", "Yeniçeriler", "Devlet Ana", "Üç İstanbul"],
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk serbest müstezat örneği kimin eseridir?",
    options: ["Tevfik Fikret", "Cenap Şahabettin", "Halit Ziya", "Mehmet Rauf"],
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk otobiyografik roman hangisidir?",
    options: [
      "Sergüzeşt",
      "Ateşten Gömlek",
      "Mor Salkımlı Ev",
      "Dokuzuncu Hariciye Koğuşu",
    ],
    correctIndex: 3,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk pastoral şiir örneği hangisidir?",
    options: ["Sahra", "Makber", "Cenge Giderken", "Kara Sevda"],
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk edebi bildiri hangisidir?",
    options: [
      "Genç Kalemler",
      "Fecr-i Ati Beyannamesi",
      "Garip Önsözü",
      "Yedi Meşaleciler",
    ],
    correctIndex: 1,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk kadın romancımız kimdir?",
    options: ["Halide Edip", "Fatma Aliye", "Emine Semiye", "Suat Derviş"],
    correctIndex: 1,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk naturalist roman hangisidir?",
    options: ["Zehra", "Mürebbiye", "Hayal İçinde", "Mai ve Siyah"],
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk hikaye kitabı hangisidir?",
    options: [
      "Letaif-i Rivayat",
      "Küçük Şeyler",
      "Müntehebat-ı Terâcim",
      "Haristan",
    ],
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk tezli roman hangisidir?",
    options: ["Zehra", "İntibah", "Yeryüzünde Bir Melek", "Akif Bey"],
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "İlk mensur şiir örneklerini veren yazar kimdir?",
    options: [
      "Halit Ziya",
      "Recaizade Ekrem",
      "Abdülhak Hamit",
      "Tevfik Fikret",
    ],
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // EDEBİYAT AKIMLARI - 20 Questions
  // ═══════════════════════════════════════════════════════════════════════════
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
  Question(
    text: "Tanzimat edebiyatı hangi akımdan etkilenmiştir?",
    options: ["Klasisizm", "Romantizm", "Natüralizm", "Sembolizm"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "İkinci Yeni akımının temsilcilerinden biri değildir?",
    options: ["Cemal Süreya", "Edip Cansever", "Orhan Veli", "İlhan Berk"],
    correctIndex: 2,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Fecr-i Ati topluluğu hangi yılda kurulmuştur?",
    options: ["1896", "1909", "1911", "1923"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Milli Edebiyat akımının kurucusu kabul edilen yazar kimdir?",
    options: [
      "Ziya Gökalp",
      "Ömer Seyfettin",
      "Mehmet Emin Yurdakul",
      "Halide Edip",
    ],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Beş Hececiler hangi dönemde ortaya çıkmıştır?",
    options: ["Tanzimat", "Servet-i Fünun", "Milli Edebiyat", "Cumhuriyet"],
    correctIndex: 2,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Yedi Meşaleciler hangi döneme tepki olarak ortaya çıkmıştır?",
    options: ["Tanzimat", "Milli Edebiyat", "Servet-i Fünun", "Fecr-i Ati"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Garip akımının manifestosunu kim yazmıştır?",
    options: ["Orhan Veli", "Oktay Rifat", "Melih Cevdet", "Cahit Sıtkı"],
    correctIndex: 0,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Toplumcu gerçekçi şiirin öncüsü kimdir?",
    options: ["Nazım Hikmet", "Orhan Veli", "Necip Fazıl", "Yahya Kemal"],
    correctIndex: 0,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Servet-i Fünun dergisinin yayın yönetmeni kimdir?",
    options: ["Halit Ziya", "Tevfik Fikret", "Cenap Şahabettin", "Mehmet Rauf"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Genç Kalemler akımı hangi şehirde doğmuştur?",
    options: ["İstanbul", "Selanik", "Ankara", "İzmir"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Hisarcılar hareketi hangi yıllarda etkinlik göstermiştir?",
    options: ["1930-1940", "1950-1960", "1970-1980", "1980-1990"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Maviciler grubu nasıl bir şiir anlayışını benimsemiştir?",
    options: ["Saf şiir", "Toplumcu şiir", "Mistik şiir", "Deneysel şiir"],
    correctIndex: 0,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Beş Hececilerin ortak özelliği aşağıdakilerden hangisidir?",
    options: ["Aruz ölçüsü", "Hece ölçüsü", "Serbest ölçü", "Kafiyesiz şiir"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Tanzimat I. dönem sanatçıları hangi anlayışı benimsemiştir?",
    options: [
      "Sanat sanat içindir",
      "Sanat toplum içindir",
      "Saf sanat",
      "Bireysel sanat",
    ],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Servet-i Fünun hangi yıl dağılmıştır?",
    options: ["1896", "1901", "1908", "1911"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Dergâh dergisi hangi akımın yayın organıdır?",
    options: [
      "Milli Edebiyat",
      "Fecr-i Ati",
      "Yedi Meşaleciler",
      "Beş Hececiler",
    ],
    correctIndex: 0,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "İkinci Yeni kaç yılında ortaya çıkmıştır?",
    options: ["1941", "1950", "1956", "1960"],
    correctIndex: 2,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Garip akımı şiirde neye karşı çıkmıştır?",
    options: ["Hece ölçüsü", "Kafiye ve ölçü", "Serbest şiir", "Toplumculuk"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // BEN KİMİM? (Yazarları Tanıma) - 20 Questions
  // ═══════════════════════════════════════════════════════════════════════════
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
  Question(
    text: "'Türk'ün Ateşle İmtihanı' adlı eserin yazarı kimdir?",
    options: ["Yakup Kadri", "Halide Edip Adıvar", "Reşat Nuri", "Falih Rıfkı"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "İstiklal Marşı'nın şairi kimdir?",
    options: ["Namık Kemal", "Mehmet Akif Ersoy", "Yahya Kemal", "Ziya Gökalp"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Üç İstanbul' romanının yazarı kimdir?",
    options: [
      "Reşat Nuri",
      "Mithat Cemal Kuntay",
      "Peyami Safa",
      "Yakup Kadri",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Şiir ve İnşa' makalesini yazan Tanzimat yazarı kimdir?",
    options: ["Namık Kemal", "Şinasi", "Ziya Paşa", "Ahmet Mithat"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "Nobel Edebiyat Ödülü alan Türk yazar kimdir?",
    options: [
      "Yaşar Kemal",
      "Orhan Pamuk",
      "Nazım Hikmet",
      "Ahmet Hamdi Tanpınar",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Safahat' adlı eserin şairi kimdir?",
    options: [
      "Yahya Kemal",
      "Mehmet Akif Ersoy",
      "Tevfik Fikret",
      "Ziya Gökalp",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Sis' şiirinin yazarı kimdir?",
    options: [
      "Yahya Kemal",
      "Tevfik Fikret",
      "Mehmet Akif",
      "Cenap Şahabettin",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Yazık Oldu Süleyman Efendi'ye' şiirini yazan şair kimdir?",
    options: ["Orhan Veli", "Oktay Rifat", "Melih Cevdet", "Cahit Sıtkı"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Kendi Gök Kubbemiz' adlı eserin şairi kimdir?",
    options: ["Tevfik Fikret", "Yahya Kemal", "Necip Fazıl", "Orhan Veli"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Memleketimden İnsan Manzaraları' kimin eseridir?",
    options: ["Orhan Veli", "Nazım Hikmet", "Attila İlhan", "Can Yücel"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Çile' şiirinin şairi kimdir?",
    options: [
      "Necip Fazıl Kısakürek",
      "Yahya Kemal",
      "Mehmet Akif",
      "Ziya Gökalp",
    ],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Şeyh Galip' hangi dönemin şairidir?",
    options: ["Tanzimat", "Divan", "Cumhuriyet", "Milli Edebiyat"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Beyaz Lale' romanının yazarı kimdir?",
    options: ["Hüseyin Rahmi", "Ahmet Midhat", "Halit Ziya", "Mehmet Rauf"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Tarih-i Kadim' şiiri kime aittir?",
    options: ["Namık Kemal", "Ziya Paşa", "Şinasi", "Abdülhak Hamit"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Sürgün' romanının yazarı kimdir?",
    options: ["Refik Halit Karay", "Yakup Kadri", "Halide Edip", "Reşat Nuri"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Bir Adam Yaratmak' adlı oyunun yazarı kimdir?",
    options: ["Necip Fazıl", "Orhan Asena", "Güngör Dilmen", "Haldun Taner"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Otuz Beş Yaş' şiirini yazan şair kimdir?",
    options: [
      "Orhan Veli",
      "Necip Fazıl",
      "Cahit Sıtkı Tarancı",
      "Fazıl Hüsnü",
    ],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Leyla ile Mecnun' mesnevisinin yazarı kimdir?",
    options: ["Baki", "Fuzuli", "Nedim", "Nefi"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // EDEBİ SANATLAR - 20 Questions
  // ═══════════════════════════════════════════════════════════════════════════
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
  Question(
    text: "Birbirine zıt kavramları bir arada kullanma sanatı hangisidir?",
    options: ["Teşbih", "Tezat", "Tenasüp", "Leff ü Neşr"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text:
        "Bir sözü benzetme amacı olmadan başka bir anlama kullanmaya ne denir?",
    options: ["İstiare", "Mecaz-ı Mürsel", "Teşbih", "Kinaye"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text:
        "Bir sözcüğün hem gerçek hem de mecaz anlamını düşündürme sanatı hangisidir?",
    options: ["Tevriye", "Kinaye", "İham", "Tecahül-i Arif"],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Bilinen bir şeyi bilmezlikten gelme sanatına ne denir?",
    options: ["İstifham", "Tecahül-i Arif", "Nida", "Rücu"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Anlamca birbiriyle ilgili sözcükleri bir arada kullanmaya ne denir?",
    options: ["Tezat", "Tenasüp", "Leff ü Neşr", "Mübalağa"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "İnsan dışındaki varlıklara insani özellikler vermeye ne denir?",
    options: ["İntak", "Teşhis", "Kinaye", "İstiare"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Bir şeyi başka bir şeye benzeterek anlatmaya ne denir?",
    options: ["Teşbih", "İstiare", "Mecaz", "Kinaye"],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Coşku ve heyecanı ifade etmek için seslenme sanatına ne denir?",
    options: ["İstifham", "Nida", "Rücu", "Tekrir"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text:
        "Soru sormak amacıyla değil, anlam güçlendirmek için soru sormaya ne denir?",
    options: ["Nida", "İstifham", "Tecahül-i Arif", "İrsal-i Mesel"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Bir sözü gerçek anlamının dışında kullanmaya ne denir?",
    options: ["Mecaz", "Kinaye", "Tevriye", "İham"],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Atasözü veya deyim kullanma sanatına ne denir?",
    options: ["Tekrir", "İrsal-i Mesel", "Telmih", "İktibas"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Tarihi bir olaya veya kişiye gönderme yapma sanatına ne denir?",
    options: ["İrsal-i Mesel", "Telmih", "İktibas", "Tenasüp"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Ayet veya hadis alıntısı yapma sanatına ne denir?",
    options: ["Telmih", "İktibas", "İrsal-i Mesel", "Tecahül-i Arif"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Söylenen sözden geri dönme sanatına ne denir?",
    options: ["Tekrir", "Rücu", "Nida", "İstifham"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Bir sözcüğü veya söz grubunu tekrarlama sanatına ne denir?",
    options: ["Cinas", "Tekrir", "Seci", "Aliterasyon"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Yazılışları aynı, anlamları farklı sözcükleri kullanmaya ne denir?",
    options: ["Cinas", "Tevriye", "İham", "Kinaye"],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Benzetmenin temel öğesi olmadan yapılan benzetmeye ne denir?",
    options: [
      "Teşbih-i Beliğ",
      "Açık İstiare",
      "Kapalı İstiare",
      "Mecaz-ı Mürsel",
    ],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Ünsüz harflerin tekrarıyla oluşan ses sanatına ne denir?",
    options: ["Aliterasyon", "Asonans", "Seci", "Cinas"],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // YENİ SORULAR - Divan, Tanzimat, Servet-i Fünun, Cumhuriyet, Dünya Edebiyatı
  // ═══════════════════════════════════════════════════════════════════════════

  // DIVAN EDEBİYATI - 10 Soru
  Question(
    text: "Divan edebiyatında 'gazel'in ilk beytine ne denir?",
    options: ["Matla", "Makta", "Beytü'l-gazel", "Taç beyit"],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Divan edebiyatında 'kaside'nin kaç bölümü vardır?",
    options: ["3", "5", "6", "7"],
    correctIndex: 2,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Türk edebiyatında ilk divan sahibi şair kimdir?",
    options: ["Fuzuli", "Hoca Dehhani", "Ahmedi", "Nesimi"],
    correctIndex: 1,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "Divan edebiyatında 'şarkı' nazım biçimini ilk kullanan şair kimdir?",
    options: ["Nedim", "Baki", "Fuzuli", "Nabi"],
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "'Hüsn ü Aşk' mesnevisinin yazarı kimdir?",
    options: ["Fuzuli", "Baki", "Şeyh Galip", "Nedim"],
    correctIndex: 2,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Divan edebiyatında 'rubai' kaç dizelik bir nazım biçimidir?",
    options: ["2", "3", "4", "5"],
    correctIndex: 2,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "'Lale Devri' şairi olarak bilinen şair kimdir?",
    options: ["Fuzuli", "Nedim", "Baki", "Nef'i"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "Hiciv (taşlama) ustası olarak bilinen Divan şairi kimdir?",
    options: ["Nedim", "Nef'i", "Baki", "Fuzuli"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Su Kasidesi' hangi şairin eseridir?",
    options: ["Baki", "Nedim", "Fuzuli", "Nabi"],
    correctIndex: 2,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Mesnevi nazım biçiminin kafiye düzeni nedir?",
    options: ["aa bb cc dd", "aa ba ca da", "ab ab ab", "aaaa bbbb"],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),

  // TANZİMAT DÖNEMİ - 10 Soru
  Question(
    text:
        "Tanzimat edebiyatının başlangıç tarihi olarak kabul edilen yıl hangisidir?",
    options: ["1839", "1856", "1860", "1876"],
    correctIndex: 2,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "'Şair Evlenmesi' adlı oyunun türü nedir?",
    options: ["Trajedi", "Dram", "Komedi", "Vodvil"],
    correctIndex: 2,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text:
        "Tanzimat döneminde 'sanat toplum içindir' görüşünü savunan yazar kimdir?",
    options: [
      "Recaizade Mahmut Ekrem",
      "Namık Kemal",
      "Abdülhak Hamit",
      "Halit Ziya",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Celaleddin Harzemşah' trajedisinin yazarı kimdir?",
    options: ["Namık Kemal", "Şinasi", "Abdülhak Hamit", "Ziya Paşa"],
    correctIndex: 2,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Tanzimat döneminin ilk çeviri şiir kitabı hangisidir?",
    options: [
      "Tercüme-i Manzume",
      "Müntehabat-ı Eş'ar",
      "Şiir ve İnşa",
      "Harabat",
    ],
    correctIndex: 0,
    category: QuestionCategory.turkEdebiyatindaIlkler,
  ),
  Question(
    text: "'Zavallı Çocuk' piyesinin yazarı kimdir?",
    options: ["Şinasi", "Namık Kemal", "Recaizade Ekrem", "Abdülhak Hamit"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Harabat' antolojisinin derleyicisi kimdir?",
    options: ["Namık Kemal", "Ziya Paşa", "Şinasi", "Ahmet Mithat"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Felatun Bey ile Rakım Efendi' romanının yazarı kimdir?",
    options: [
      "Şemsettin Sami",
      "Ahmet Mithat Efendi",
      "Namık Kemal",
      "Recaizade Ekrem",
    ],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Talim-i Edebiyat' adlı eser hangi türdedir?",
    options: ["Roman", "Eleştiri", "Poetika", "Tiyatro"],
    correctIndex: 2,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Müntahabat-ı Terâcim' hangi yazara aittir?",
    options: ["Namık Kemal", "Şinasi", "Ziya Paşa", "Ahmet Mithat"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),

  // SERVET-İ FÜNUN DÖNEMİ - 10 Soru
  Question(
    text: "Servet-i Fünun dergisi hangi yıl yayınlanmaya başlamıştır?",
    options: ["1891", "1896", "1901", "1908"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "'Kırık Hayatlar' romanının yazarı kimdir?",
    options: [
      "Mehmet Rauf",
      "Halit Ziya Uşaklıgil",
      "Tevfik Fikret",
      "Cenap Şahabettin",
    ],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Ferda' şiirini yazan şair kimdir?",
    options: [
      "Cenap Şahabettin",
      "Tevfik Fikret",
      "Süleyman Nazif",
      "Hüseyin Cahit",
    ],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Elhan-ı Şita' (Kış Ezgileri) şiirinin şairi kimdir?",
    options: [
      "Tevfik Fikret",
      "Cenap Şahabettin",
      "Yahya Kemal",
      "Mehmet Akif",
    ],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Haluk'un Defteri' adlı eserin yazarı kimdir?",
    options: ["Cenap Şahabettin", "Tevfik Fikret", "Halit Ziya", "Mehmet Rauf"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Servet-i Fünun sanatçılarının benimsediği ilke hangisidir?",
    options: [
      "Sanat toplum içindir",
      "Sanat sanat içindir",
      "Sanat halk içindir",
      "Sanat millet içindir",
    ],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "'Siyah İnciler' adlı öykü kitabının yazarı kimdir?",
    options: [
      "Halit Ziya",
      "Mehmet Rauf",
      "Hüseyin Cahit Yalçın",
      "Tevfik Fikret",
    ],
    correctIndex: 2,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'September' şiiri hangi Servet-i Fünun şairine aittir?",
    options: [
      "Tevfik Fikret",
      "Cenap Şahabettin",
      "Süleyman Nazif",
      "Faik Ali Ozansoy",
    ],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Nemide' romanının yazarı kimdir?",
    options: ["Halit Ziya", "Mehmet Rauf", "Hüseyin Cahit", "Ahmet Hikmet"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Servet-i Fünun topluluğu hangi olayla dağılmıştır?",
    options: [
      "Meşrutiyet ilanı",
      "Hüseyin Cahit'in sürgüne gönderilmesi",
      "Edebiyat-ı Cedide tartışması",
      "Kasideler olayı",
    ],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),

  // CUMHURİYET DÖNEMİ - 10 Soru
  Question(
    text: "'Sakarya Türküsü' şiirinin şairi kimdir?",
    options: ["Yahya Kemal", "Orhan Veli", "Necip Fazıl", "Nazım Hikmet"],
    correctIndex: 2,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Sözde Kızlar' romanının yazarı kimdir?",
    options: ["Reşat Nuri", "Peyami Safa", "Yakup Kadri", "Halide Edip"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Benim Adım Kırmızı' romanının yazarı kimdir?",
    options: [
      "Yaşar Kemal",
      "Orhan Pamuk",
      "Ahmet Hamdi Tanpınar",
      "Oğuz Atay",
    ],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'İstanbul'un Fethi' destanını yazan şair kimdir?",
    options: [
      "Mehmet Akif",
      "Yahya Kemal",
      "Necip Fazıl",
      "Fazıl Hüsnü Dağlarca",
    ],
    correctIndex: 3,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Anayurt Oteli' romanının yazarı kimdir?",
    options: ["Oğuz Atay", "Yusuf Atılgan", "Bilge Karasu", "Ferit Edgü"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Bereketli Topraklar Üzerinde' romanının yazarı kimdir?",
    options: ["Yaşar Kemal", "Orhan Kemal", "Kemal Tahir", "Fakir Baykurt"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Don Kişot'un Kuralları' kimin eseridir?",
    options: [
      "Nurullah Ataç",
      "Suut Kemal Yetkin",
      "Cemil Meriç",
      "Ahmet Hamdi Tanpınar",
    ],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Maviciler topluluğunun kurucusu kimdir?",
    options: ["Attila İlhan", "Cemal Süreya", "Edip Cansever", "İlhan Berk"],
    correctIndex: 0,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "'Kar' romanının yazarı kimdir?",
    options: ["Orhan Pamuk", "Yaşar Kemal", "Oğuz Atay", "Elif Şafak"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Şehrin Öteki Yüzü' romanının yazarı kimdir?",
    options: ["Orhan Pamuk", "Oğuz Atay", "Ahmet Ümit", "Zülfü Livaneli"],
    correctIndex: 2,
    category: QuestionCategory.eserKarakter,
  ),

  // DÜNYA EDEBİYATI - 10 Soru
  Question(
    text: "'Savaş ve Barış' romanının yazarı kimdir?",
    options: ["Dostoyevski", "Tolstoy", "Gogol", "Çehov"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Suç ve Ceza' romanının baş karakteri kimdir?",
    options: ["Raskolnikov", "Karamazov", "Oblomov", "Anna Karenina"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Don Kişot' romanının yazarı kimdir?",
    options: ["Shakespeare", "Cervantes", "Dante", "Boccaccio"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Madame Bovary' romanının yazarı kimdir?",
    options: ["Balzac", "Flaubert", "Stendhal", "Zola"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'1984' romanının yazarı kimdir?",
    options: ["Aldous Huxley", "George Orwell", "Ray Bradbury", "Isaac Asimov"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Hamlet' trajedisinin yazarı kimdir?",
    options: ["Molière", "Shakespeare", "Goethe", "Schiller"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Metamorfoz' (Dönüşüm) adlı eserin yazarı kimdir?",
    options: ["Camus", "Sartre", "Kafka", "Beckett"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Yüzyıllık Yalnızlık' romanının yazarı kimdir?",
    options: ["Borges", "García Márquez", "Vargas Llosa", "Cortázar"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Yabancı' romanının yazarı kimdir?",
    options: ["Sartre", "Camus", "Kafka", "Beckett"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Faust' trajedisinin yazarı kimdir?",
    options: ["Schiller", "Lessing", "Goethe", "Heine"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // EDEBİ SANATLAR - İleri Seviye (25 Soru)
  // ═══════════════════════════════════════════════════════════════════════════
  Question(
    text: "'Gözlerin inci gibi' ifadesindeki edebi sanat nedir?",
    options: ["İstiare", "Teşbih", "Mecaz-ı Mürsel", "Kinaye"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Açık istiare nedir?",
    options: [
      "Benzetme öğelerinden yalnız benzeyenin bulunduğu istiare",
      "Benzetme öğelerinden yalnız kendisine benzetilenin bulunduğu istiare",
      "Tüm benzetme öğelerinin bulunduğu istiare",
      "Hiçbir benzetme öğesinin bulunmadığı istiare",
    ],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Kapalı istiare nedir?",
    options: [
      "Benzetme öğelerinden yalnız benzeyenin bulunduğu istiare",
      "Benzetme öğelerinden yalnız kendisine benzetilenin bulunduğu istiare",
      "Tüm benzetme öğelerinin bulunduğu istiare",
      "Hiçbir benzetme öğesinin bulunmadığı istiare",
    ],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text:
        "'Ey mavi göklerin beyaz ve kızıl süsü' dizesindeki edebi sanat nedir?",
    options: ["Teşhis", "Nida", "Tenasüp", "Tezat"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "'Bir eli yağda bir eli balda' deyimindeki edebi sanat nedir?",
    options: ["Teşbih", "Kinaye", "Mecaz", "İstiare"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text:
        "'Bahar geldi, kuşlar cıvıldamaya başladı, çiçekler açtı' cümlesindeki edebi sanat nedir?",
    options: ["Tezat", "Tenasüp", "Tekrir", "Seci"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text:
        "'Ağlarım, ağlarım, ağladıkça yanar yüreğim' ifadesindeki edebi sanat nedir?",
    options: ["Tenasüp", "Tekrir", "Nida", "Seci"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "'El elden üstündür, arşa kadar' atasözündeki edebi sanat nedir?",
    options: ["Kinaye", "Telmih", "İrsal-i Mesel", "Tecahül-i Arif"],
    correctIndex: 2,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "'Kan kusar kanlı bıçak' ifadesindeki sözcük tekrarı hangi sanattır?",
    options: ["Tekrir", "Cinas", "Seci", "Aliterasyon"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Teşbih-i Beliğ'de hangi öğeler bulunmaz?",
    options: [
      "Benzeyen ve benzetilen",
      "Benzetme yönü ve edatı",
      "Tüm öğeler bulunur",
      "Sadece benzetme edatı bulunmaz",
    ],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text:
        "'Dağ dağ o güzellik, vadi vadi o güzellik' ifadesindeki sanat nedir?",
    options: ["Istıçare", "Tekrîr", "Seci", "Cinas"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Asonans hangi harflerin tekrarıyla oluşur?",
    options: [
      "Ünsüz harfler",
      "Ünlü harfler",
      "Tüm harfler",
      "Noktalama işaretleri",
    ],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "'Sen de mi Brütüs?' ifadesindeki edebi sanat nedir?",
    options: ["İrsal-i Mesel", "Telmih", "İktibas", "Tecahül-i Arif"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text:
        "'Gökyüzü ağlıyor, bulutlar gözlerinden yaşlar döküyor' ifadesindeki sanat nedir?",
    options: ["Teşhis", "İntak", "Tşbih", "Mecaz"],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Hüsn-i ta'lil (güzel nedene bağlama) sanatına örnek:",
    options: [
      "Güller senin için açtı",
      "Gül gibi güzelsin",
      "Güller konuştu",
      "Gülün dikeni var",
    ],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text:
        "'Gece-gündüz, siyah-beyaz, iyi-kötü' gibi karşıt kavramların kullanımı hangi sanattır?",
    options: ["Tenasüp", "Tezat", "İham", "Tevriye"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "İham sanatı nedir?",
    options: [
      "İki anlamlı sözle her iki anlamı da kastetme",
      "Bir şeyi abartarak anlatma",
      "Soru sorarak vurgu yapma",
      "Tarihi olaya gönderme yapma",
    ],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text:
        "'Sensiz kalsam ellerin ağında, diller ağlar dilim ağlar' ifadesinde hangi sanat var?",
    options: ["Cinas", "Tevriye", "İham", "Kinaye"],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Leff ü neşr sanatı nedir?",
    options: [
      "İki sözcüğü sırayla açıklama",
      "Karşıt kavramları kullanma",
      "Abartılı ifade etme",
      "Atasözü kullanma",
    ],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "'Akşam oldu, hüzün oldu' ifadesindeki söz sanatı nedir?",
    options: ["Seci", "Tekrir", "Cinas", "Aliterasyon"],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Teşbih-i temsili (yaygın benzetme) ne demektir?",
    options: [
      "Birden fazla yönden benzetme yapma",
      "Tek bir yönden benzetme yapma",
      "Edat kullanmadan benzetme",
      "İnsana benzetme",
    ],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text:
        "'Nice sultanlar nice şahlar gördü bu köhne dünya' ifadesindeki sanat nedir?",
    options: ["Telmih", "İrsal-i Mesel", "Tekrir", "Tenasüp"],
    correctIndex: 2,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Teşhis ile İntak arasındaki fark nedir?",
    options: [
      "Teşhis duygu verme, intak konuşturma",
      "İntak duygu verme, teşhis konuşturma",
      "İkisi de aynıdır",
      "Teşhis abartı, intak benzetmedir",
    ],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "'Bir of çeksem dağlar inler' ifadesindeki sanat nedir?",
    options: ["Teşhis", "Mübalağa", "Teşbih", "Kinaye"],
    correctIndex: 1,
    category: QuestionCategory.edebiSanatlar,
  ),
  Question(
    text: "Tedric (derece derece anlatma) sanatına örnek hangisidir?",
    options: [
      "İlkbahar, yaz, sonbahar, kış",
      "Gül ve bülbül",
      "Kalem ve kağıt",
      "Anne ve baba",
    ],
    correctIndex: 0,
    category: QuestionCategory.edebiSanatlar,
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // ROMAN KARAKTERLERİ - Detaylı (25 Soru)
  // ═══════════════════════════════════════════════════════════════════════════
  Question(
    text: "Yaban romanında Ahmet Celal kolunu nerede kaybetmiştir?",
    options: ["Çanakkale", "Sakarya", "Kurtuluş Savaşı", "Balkan Savaşı"],
    correctIndex: 2,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Huzur romanında Mümtaz hangi şehirde yaşamaktadır?",
    options: ["Ankara", "İstanbul", "İzmir", "Bursa"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Ateşten Gömlek romanında Ayşe hangi cephede savaşmıştır?",
    options: ["Sakarya", "İnönü", "İzmir", "Çanakkale"],
    correctIndex: 2,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Çalıkuşu romanında Feride'nin ilk görev yeri neresidir?",
    options: ["Zeyniler", "Kuşadası", "İstanbul", "Ankara"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Aşk-ı Memnu romanında Bihter hangi karakterle yasak aşk yaşamıştır?",
    options: ["Adnan Bey", "Behlül", "Nihâl", "Firdevs Hanım"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Kiralık Konak romanında Naim Efendi'nin torunu kimdir?",
    options: ["Seniha", "Faik Bey", "Sekine", "Hakkı Celis"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Mai ve Siyah romanında Ahmet Cemil'in hayalindeki meslek nedir?",
    options: ["Ressam", "Şair", "Doktor", "Öğretmen"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Sinekli Bakkal romanında Rabia Hanım'ın kocasının milliyeti nedir?",
    options: ["Türk", "Arap", "İtalyan", "Fransız"],
    correctIndex: 2,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Yaprak Dökümü romanında Ali Rıza Bey'in mesleği nedir?",
    options: ["Memur", "Tüccar", "Öğretmen", "Doktor"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text:
        "Tutunamayanlar romanında Turgut Özben'in arkadaşı Selim Işık nasıl ölmüştür?",
    options: ["Kaza", "İntihar", "Hastalık", "Cinayet"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "İnce Memed romanında Memed'in sevgilisinin adı nedir?",
    options: ["Hatçe", "Ayşe", "Fatma", "Zeynep"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Kuyucaklı Yusuf romanında Yusuf'un sevdiği kadın kimdir?",
    options: ["Muazzez", "Şahinde", "Kabahatsız", "Kübra"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text:
        "Fatih-Harbiye romanında Neriman hangi iki semt arasında bocalamaktadır?",
    options: [
      "Kadıköy-Beşiktaş",
      "Fatih-Harbiye",
      "Beyoğlu-Üsküdar",
      "Taksim-Sultanahmet",
    ],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Dokuzuncu Hariciye Koğuşu romanında anlatıcının hastalığı nedir?",
    options: ["Verem", "Kemik veremi", "Zatürre", "Grip"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Aylak Adam romanında C.'nin mesleği nedir?",
    options: ["Ressam", "Mimar", "Yazar", "İşsiz (Aylak)"],
    correctIndex: 3,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Anayurt Oteli romanında Zebercet hangi otelde çalışmaktadır?",
    options: ["Pera Palas", "Anayurt Oteli", "Park Otel", "Grand Hotel"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Huzur romanında Nuran'ın eski kocasının adı nedir?",
    options: ["Suat", "Fahir", "İhsan", "Nurettin"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Eylül romanında Suat ile Necip arasındaki ilişki nedir?",
    options: ["Karı-koca", "Kardeş", "Kayınbirader-baldız", "Anne-oğul"],
    correctIndex: 2,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Araba Sevdası romanında Bihruz Bey'in tutulduğu kadın kimdir?",
    options: ["Periveş", "Süheyla", "Nigâr", "Dilber"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "İntibah romanında Ali Bey'i baştan çıkaran kadın kimdir?",
    options: ["Mehpeyker", "Dilaşup", "Fatma", "Ayşe"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Sergüzeşt romanında Dilber hangi statüdedir?",
    options: ["Hür kadın", "Cariye", "Hanımefendi", "Prenses"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Küçük Ağa romanının geçtiği dönem hangisidir?",
    options: ["Tanzimat", "Meşrutiyet", "Kurtuluş Savaşı", "Cumhuriyet"],
    correctIndex: 2,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text:
        "Bereketli Topraklar Üzerinde romanında Yusuf nereden İstanbul'a göç etmiştir?",
    options: ["Çukurova", "Karadeniz", "Ege", "Doğu Anadolu"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Bir Düğün Gecesi romanında Aysel'in mesleği nedir?",
    options: ["Öğretmen", "Doktor", "Akademisyen", "Avukat"],
    correctIndex: 2,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Saatleri Ayarlama Enstitüsü romanının baş karakteri kimdir?",
    options: ["Hayri İrdal", "Nuri Bey", "Ahmet Bey", "Seyit"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // ÜNLÜ DİZELER VE ALINTILAR - "Bu Dizeyi Kim Yazdı?" (50 Soru)
  // ═══════════════════════════════════════════════════════════════════════════

  // ŞİİR DİZELERİ - 30 Soru
  Question(
    text: "'Kaldırımlar, kaldırımlar, çilekeş kaldırımlar' dizesi kime aittir?",
    options: [
      "Orhan Veli",
      "Necip Fazıl Kısakürek",
      "Nazım Hikmet",
      "Attila İlhan",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Ben sana mecburum bilemezsin' dizesi hangi şaire aittir?",
    options: ["Cemal Süreya", "Attila İlhan", "Edip Cansever", "İlhan Berk"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'İstanbul'u dinliyorum gözlerim kapalı' dizesi kime aittir?",
    options: [
      "Yahya Kemal",
      "Orhan Veli Kanık",
      "Necip Fazıl",
      "Behçet Necatigil",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Yaşamak şakaya gelmez' dizesi hangi şairin eseridir?",
    options: ["Orhan Veli", "Nazım Hikmet", "Can Yücel", "Cemal Süreya"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Sessiz gemi' şiiri hangi şaire aittir?",
    options: [
      "Tevfik Fikret",
      "Yahya Kemal Beyatlı",
      "Mehmet Akif",
      "Cenap Şahabettin",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Gel bu anı yaşayalım, birbirimize yaslanarak' dizesi kime aittir?",
    options: ["Cemal Süreya", "Özdemir Asaf", "Edip Cansever", "Turgut Uyar"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Lavinia sana ne kadar baksam az' dizesi hangi şaire aittir?",
    options: [
      "Orhan Veli",
      "Nazım Hikmet",
      "Attila İlhan",
      "Melih Cevdet Anday",
    ],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Ağır hasta' şiirinin yazarı kimdir?",
    options: [
      "Behçet Necatigil",
      "Necip Fazıl",
      "Yahya Kemal",
      "Fazıl Hüsnü Dağlarca",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Akıncılar' şiiri hangi şaire aittir?",
    options: ["Yahya Kemal", "Mehmet Akif", "Ziya Gökalp", "Arif Nihat Asya"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Güzel şeyler düşünelim diye' dizesi kime aittir?",
    options: ["Orhan Veli", "Cemal Süreya", "Oktay Rifat", "Melih Cevdet"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text:
        "'Ben bir ceviz ağacıyım Gülhane Parkı'nda' dizesi hangi şaire aittir?",
    options: ["Orhan Veli", "Nazım Hikmet", "Cemal Süreya", "Can Yücel"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Endülüs'te Raks' şiiri kime aittir?",
    options: [
      "Yahya Kemal",
      "Tevfik Fikret",
      "Ahmet Haşim",
      "Cenap Şahabettin",
    ],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Merdiven' şiiri hangi şaire aittir?",
    options: ["Yahya Kemal", "Ahmet Haşim", "Tevfik Fikret", "Mehmet Akif"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Saatler' şiiri kime aittir?",
    options: [
      "Necip Fazıl",
      "Ahmet Muhip Dıranas",
      "Cahit Sıtkı",
      "Ahmet Hamdi Tanpınar",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Deniz Küstü' şiiri hangi şaire aittir?",
    options: ["Orhan Veli", "Salah Birsel", "Oktay Rifat", "Melih Cevdet"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Çocukluğum' şiirinin yazarı kimdir?",
    options: ["Yahya Kemal", "Orhan Veli", "Nazım Hikmet", "Behçet Necatigil"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Serenad' şiiri kime aittir?",
    options: ["Necip Fazıl", "Orhan Veli", "Cemal Süreya", "Attila İlhan"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Karacaoğlan' şiiri hangi şaire aittir?",
    options: [
      "Fazıl Hüsnü Dağlarca",
      "Bedri Rahmi Eyüboğlu",
      "Cahit Külebi",
      "Arif Nihat Asya",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'O sapkın öpüşlerden kalan kırık burunlu kadın' dizesi kime aittir?",
    options: ["Orhan Veli", "Cemal Süreya", "Attila İlhan", "İlhan Berk"],
    correctIndex: 3,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Bir bayrak rüzgar bekliyor' dizesi hangi şaire aittir?",
    options: ["Arif Nihat Asya", "Yahya Kemal", "Mehmet Akif", "Necip Fazıl"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Piraye'ye Mektuplar' kimin eseridir?",
    options: ["Nazım Hikmet", "Attila İlhan", "Ahmed Arif", "Can Yücel"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Güzelleme' şiiri hangi şaire aittir?",
    options: ["Cemal Süreya", "Edip Cansever", "Turgut Uyar", "Ece Ayhan"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Ölüm var ya ölüm, işte o bile' dizesi kime aittir?",
    options: ["Nazım Hikmet", "Ahmed Arif", "Can Yücel", "Cemal Süreya"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Hasretinden prangalar eskittim' dizesi hangi şaire aittir?",
    options: ["Nazım Hikmet", "Ahmed Arif", "Attila İlhan", "Cemal Süreya"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Ben yoruldum hayat çekilip gitsen' dizesi kime aittir?",
    options: ["Orhan Veli", "Can Yücel", "Cemal Süreya", "Necip Fazıl"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text:
        "'Bir garip öldü galiba, yüreğimde bir sızı var' dizesi hangi şaire aittir?",
    options: ["Orhan Veli", "Âşık Veysel", "Neşet Ertaş", "Abdurrahim Karakoç"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Ayın On Dördü' şiiri kime aittir?",
    options: ["Necip Fazıl", "Yahya Kemal", "Mehmet Akif", "Ahmet Haşim"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Kitabe-i Seng-i Mezar' şiiri hangi şaire aittir?",
    options: ["Orhan Veli", "Yahya Kemal", "Ahmet Haşim", "Tevfik Fikret"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'O Benim Milletim' şiiri kime aittir?",
    options: ["Yahya Kemal", "Arif Nihat Asya", "Necip Fazıl", "Mehmet Akif"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Süleymaniye'de Bayram Sabahı' şiiri hangi şaire aittir?",
    options: ["Yahya Kemal", "Mehmet Akif", "Necip Fazıl", "Arif Nihat Asya"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),

  // ROMAN ALINTILARI - 20 Soru
  Question(
    text: "'Ekmek aslanın ağzında' sözü hangi romanda geçer?",
    options: [
      "Bereketli Topraklar Üzerinde",
      "Yaban",
      "İnce Memed",
      "Kuyucaklı Yusuf",
    ],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Aşk insanı ahmaklığa götürür' sözü hangi romanın temasıdır?",
    options: ["Aşk-ı Memnu", "Çalıkuşu", "Eylül", "Huzur"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Bu memleket bizim' sloganı hangi döneme aittir?",
    options: ["Tanzimat", "Cumhuriyet", "Meşrutiyet", "Milli Edebiyat"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text:
        "'Tutunamayanlar' romanındaki 'tutunamamak' kavramı neyi temsil eder?",
    options: [
      "Topluma uyum sağlayamama",
      "Ekonomik sıkıntı",
      "Aşk acısı",
      "Sağlık problemi",
    ],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Suç ve Ceza'daki ünlü 'üstinsan' teorisi hangi karaktere aittir?",
    options: ["Sonya", "Raskolnikov", "Porfiry", "Dunya"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Saatleri Ayarlama Enstitüsü'nde eleştirilen kavram nedir?",
    options: ["Bürokrasi", "Aşk", "Savaş", "Eğitim"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Yaban'da köylü-aydın çatışması hangi bağlamda ele alınır?",
    options: [
      "Kurtuluş Savaşı dönemi",
      "Osmanlı dönemi",
      "Cumhuriyet sonrası",
      "Balkan Savaşları",
    ],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Mai ve Siyah'ta 'mai' neyi simgeler?",
    options: ["Hayal", "Gerçek", "Aşk", "Ölüm"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Mai ve Siyah'ta 'siyah' neyi simgeler?",
    options: ["Hayal", "Gerçeklik", "Aşk", "Umut"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text:
        "'Sinekli Bakkal' romanında Doğu-Batı çatışması hangi karakterler üzerinden işlenir?",
    options: [
      "Rabia-Peregrini",
      "Selim-Rabia",
      "Tevfik-Rabia",
      "Kız Tevfik-Peregrini",
    ],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Fatih-Harbiye' romanında Neriman'ın bocaladığı kavram nedir?",
    options: ["Doğu-Batı kimliği", "Aşk-kariyer", "Din-bilim", "Köy-şehir"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Huzur' romanının geçtiği tarih hangi olaya denk gelir?",
    options: [
      "İkinci Dünya Savaşı başlangıcı",
      "Birinci Dünya Savaşı",
      "Balkan Savaşları",
      "Kurtuluş Savaşı",
    ],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Yaprak Dökümü'nde aile çöküşü neyin sembolüdür?",
    options: [
      "Osmanlı'nın çöküşü",
      "Ekonomik kriz",
      "Savaş yılları",
      "Göç dalgası",
    ],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Kiralık Konak' romanında konak neyi temsil eder?",
    options: [
      "Osmanlı değerlerini",
      "Batılılaşmayı",
      "Gençlik ideallerini",
      "Köy yaşamını",
    ],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Ben böyle aşkın züğürdüyüm' sözü hangi şaire aittir?",
    options: ["Bedri Rahmi", "Orhan Veli", "Nazım Hikmet", "Can Yücel"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Benim gibi deli bir ozan gelmedi' dizesi kime aittir?",
    options: ["Can Yücel", "Nazım Hikmet", "Orhan Veli", "Ahmed Arif"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Köroğlu' destanı hangi edebiyat dönemine aittir?",
    options: ["Halk Edebiyatı", "Divan Edebiyatı", "Tanzimat", "Cumhuriyet"],
    correctIndex: 0,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "'Dede Korkut Hikayeleri' hangi edebiyat dönemine aittir?",
    options: ["İslamiyet Öncesi", "İslami Dönem", "Tanzimat", "Cumhuriyet"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "'Kerem ile Aslı' hikayesi hangi türdedir?",
    options: ["Halk hikayesi", "Mesnevi", "Destan", "Masal"],
    correctIndex: 0,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "'Ferhat ile Şirin' hangi kültürden alınma bir hikayedir?",
    options: ["İran", "Arap", "Hint", "Çin"],
    correctIndex: 0,
    category: QuestionCategory.edebiyatAkimlari,
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // DÜNYA EDEBİYATI VE MİTOLOJİ - AYT/KPSS (50 Soru)
  // ═══════════════════════════════════════════════════════════════════════════

  // ANTİK DÖNEM - 10 Soru
  Question(
    text: "'İlyada' ve 'Odysseia' destanlarının yazarı kimdir?",
    options: ["Sophokles", "Homeros", "Euripides", "Aristoteles"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Kral Oidipus' trajedisinin yazarı kimdir?",
    options: ["Euripides", "Aiskhylos", "Sophokles", "Aristophanes"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Aeneis' destanının yazarı kimdir?",
    options: ["Homeros", "Ovidius", "Vergilius", "Horatius"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "Yunan mitolojisinde savaş tanrısı kimdir?",
    options: ["Zeus", "Poseidon", "Ares", "Hades"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "Yunan mitolojisinde güzellik ve aşk tanrıçası kimdir?",
    options: ["Hera", "Athena", "Artemis", "Afrodit"],
    correctIndex: 3,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "Truva Savaşı'nın başlamasına neden olan mitolojik olay nedir?",
    options: [
      "Paris'in Helena'yı kaçırması",
      "Akhilleus'un öfkesi",
      "Tahta at hilesi",
      "Zeus'un gazabı",
    ],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Metamorphoses' (Dönüşümler) adlı eserin yazarı kimdir?",
    options: ["Vergilius", "Ovidius", "Homeros", "Seneca"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "Odysseus'un yolculuğu kaç yıl sürmüştür?",
    options: ["5 yıl", "10 yıl", "15 yıl", "20 yıl"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Prometheus Zincire Vurulmuş' trajedisinin yazarı kimdir?",
    options: ["Sophokles", "Euripides", "Aiskhylos", "Aristophanes"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "Yunan mitolojisinde denizler tanrısı kimdir?",
    options: ["Zeus", "Poseidon", "Hades", "Apollon"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),

  // RÖNESANS DÖNEMİ - 8 Soru
  Question(
    text: "'Don Kişot' romanının yazarı Cervantes hangi ülkedendir?",
    options: ["İtalya", "Fransa", "İspanya", "Portekiz"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Hamlet' trajedisinde 'Olmak ya da olmamak' sözü kime aittir?",
    options: ["Claudius", "Hamlet", "Horatio", "Laertes"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Romeo ve Juliet' trajedisinin yazarı kimdir?",
    options: ["Molière", "Shakespeare", "Cervantes", "Dante"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'İlahi Komedya' (Divina Commedia) adlı eserin yazarı kimdir?",
    options: ["Petrarca", "Boccaccio", "Dante", "Machiavelli"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Decameron' adlı eserin yazarı kimdir?",
    options: ["Dante", "Boccaccio", "Petrarca", "Cervantes"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Macbeth' trajedisinin temel konusu nedir?",
    options: ["Aşk", "İktidar hırsı", "Yolculuk", "Dostluk"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Shakespeare hangi ülkenin yazarıdır?",
    options: ["Fransa", "İtalya", "İngiltere", "Almanya"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text:
        "'Othello' trajedisinde kıskançlık teması hangi karakter üzerinden işlenir?",
    options: ["Iago", "Othello", "Desdemona", "Cassio"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),

  // AYDINLANMA DÖNEMİ - 6 Soru
  Question(
    text: "'Candide' adlı eserin yazarı kimdir?",
    options: ["Rousseau", "Voltaire", "Diderot", "Montesquieu"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Toplum Sözleşmesi' adlı eserin yazarı kimdir?",
    options: ["Voltaire", "Rousseau", "Montesquieu", "Locke"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'İtiraflar' (Confessions) adlı otobiyografik eserin yazarı kimdir?",
    options: ["Voltaire", "Diderot", "Rousseau", "D'Alembert"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Robinson Crusoe' romanının yazarı kimdir?",
    options: [
      "Jonathan Swift",
      "Daniel Defoe",
      "Henry Fielding",
      "Samuel Richardson",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Gulliver'in Gezileri' adlı eserin yazarı kimdir?",
    options: [
      "Daniel Defoe",
      "Jonathan Swift",
      "Henry Fielding",
      "Laurence Sterne",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Ansiklopedi' projesinin editörü kimdir?",
    options: ["Voltaire", "Rousseau", "Diderot", "Montesquieu"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),

  // ROMANTİZM DÖNEMİ - 8 Soru
  Question(
    text: "'Sefiller' (Les Misérables) romanının yazarı kimdir?",
    options: ["Balzac", "Victor Hugo", "Flaubert", "Stendhal"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Notre-Dame'ın Kamburu' romanının yazarı kimdir?",
    options: ["Alexandre Dumas", "Victor Hugo", "Chateaubriand", "Lamartine"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Ivanhoe' romanının yazarı kimdir?",
    options: ["Charles Dickens", "Walter Scott", "Jane Austen", "Emily Brontë"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Frankenstein' romanının yazarı kimdir?",
    options: [
      "Mary Shelley",
      "Jane Austen",
      "Emily Brontë",
      "Charlotte Brontë",
    ],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Genç Werther'in Acıları' romanının yazarı kimdir?",
    options: ["Schiller", "Goethe", "Heine", "Hölderlin"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Uğultulu Tepeler' (Wuthering Heights) romanının yazarı kimdir?",
    options: ["Charlotte Brontë", "Emily Brontë", "Anne Brontë", "Jane Austen"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Monte Cristo Kontu' romanının yazarı kimdir?",
    options: ["Victor Hugo", "Alexandre Dumas", "Balzac", "Stendhal"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Jane Eyre' romanının yazarı kimdir?",
    options: [
      "Emily Brontë",
      "Charlotte Brontë",
      "Jane Austen",
      "George Eliot",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),

  // REALİZM DÖNEMİ - 10 Soru
  Question(
    text: "'Goriot Baba' romanının yazarı kimdir?",
    options: ["Flaubert", "Balzac", "Stendhal", "Zola"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'İnsanlık Komedyası' (La Comédie Humaine) hangi yazarın eseridir?",
    options: ["Victor Hugo", "Balzac", "Flaubert", "Stendhal"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Oliver Twist' romanının yazarı kimdir?",
    options: [
      "William Thackeray",
      "Charles Dickens",
      "Thomas Hardy",
      "George Eliot",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'İki Şehrin Hikayesi' romanının yazarı kimdir?",
    options: ["Charles Dickens", "Victor Hugo", "Balzac", "Hardy"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Anna Karenina' romanının yazarı kimdir?",
    options: ["Dostoyevski", "Tolstoy", "Turgenyev", "Çehov"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Karamazov Kardeşler' romanının yazarı kimdir?",
    options: ["Tolstoy", "Dostoyevski", "Gogol", "Turgenyev"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Ölü Canlar' romanının yazarı kimdir?",
    options: ["Dostoyevski", "Tolstoy", "Gogol", "Puşkin"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Parma Manastırı' romanının yazarı kimdir?",
    options: ["Balzac", "Flaubert", "Stendhal", "Zola"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Kızıl ve Kara' romanının yazarı kimdir?",
    options: ["Balzac", "Stendhal", "Flaubert", "Hugo"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Budala' romanının yazarı kimdir?",
    options: ["Tolstoy", "Gogol", "Dostoyevski", "Çehov"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),

  // NATÜRALİZM VE 20. YÜZYIL - 8 Soru
  Question(
    text: "'Germinal' romanının yazarı kimdir?",
    options: ["Flaubert", "Zola", "Maupassant", "Balzac"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Nana' romanının yazarı kimdir?",
    options: ["Maupassant", "Flaubert", "Zola", "Daudet"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Dönüşüm' (Die Verwandlung) adlı eserin yazarı kimdir?",
    options: ["Camus", "Sartre", "Kafka", "Beckett"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Dava' romanının yazarı kimdir?",
    options: ["Kafka", "Camus", "Sartre", "Beckett"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Veba' romanının yazarı kimdir?",
    options: ["Sartre", "Camus", "Malraux", "Gide"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Bulantı' (La Nausée) romanının yazarı kimdir?",
    options: ["Camus", "Sartre", "Gide", "Malraux"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Godot'yu Beklerken' oyununun yazarı kimdir?",
    options: ["Ionesco", "Beckett", "Sartre", "Genet"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Yaşlı Adam ve Deniz' romanının yazarı kimdir?",
    options: ["Steinbeck", "Hemingway", "Fitzgerald", "Faulkner"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),

  // ═══════════════════════════════════════════════════════════════════════════
  // ŞAİR VE ESER ÖZELLİKLERİ - AYT/KPSS (50 Soru)
  // ═══════════════════════════════════════════════════════════════════════════

  // ÜNLÜ LAKAPLAR VE SIFATLAR - 15 Soru
  Question(
    text: "'Fakirlerin Şairi' olarak bilinen şairimiz kimdir?",
    options: ["Necip Fazıl", "Orhan Veli", "Mehmet Akif Ersoy", "Yahya Kemal"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Milli Şair' unvanlı yazarımız kimdir?",
    options: [
      "Ziya Gökalp",
      "Mehmet Emin Yurdakul",
      "Namık Kemal",
      "Ömer Seyfettin",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Türkçenin Nakkaşı' olarak anılan şair kimdir?",
    options: ["Yahya Kemal", "Ahmet Haşim", "Necip Fazıl", "Tevfik Fikret"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Mistik Şair' olarak da bilinen şairimiz kimdir?",
    options: [
      "Yahya Kemal",
      "Necip Fazıl Kısakürek",
      "Fazıl Hüsnü Dağlarca",
      "Arif Nihat Asya",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Bayrak Şairi' olarak bilinen şairimiz kimdir?",
    options: ["Mehmet Akif", "Arif Nihat Asya", "Yahya Kemal", "Necip Fazıl"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Devrin Şairi' (Poet Laureate) olarak Osmanlı'da hangi şair anılır?",
    options: ["Nedim", "Baki", "Fuzuli", "Nef'i"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Şiir Dairesi'nin kurucusu olarak bilinen şair kimdir?",
    options: ["Yahya Kemal", "Ahmet Haşim", "Tevfik Fikret", "Orhan Veli"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Türk Edebiyatının Balzac'ı' olarak nitelendirilen yazar kimdir?",
    options: [
      "Halit Ziya",
      "Reşat Nuri",
      "Hüseyin Rahmi Gürpınar",
      "Ahmet Mithat",
    ],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Usta' (Üstad) lakabıyla anılan yazar kimdir?",
    options: [
      "Necip Fazıl",
      "Nazım Hikmet",
      "Ahmet Hamdi Tanpınar",
      "Yahya Kemal",
    ],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Gariplerin Şairi' olarak bilinen şair kimdir?",
    options: ["Bedri Rahmi", "Orhan Veli", "Nazım Hikmet", "Can Yücel"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Roman Kapısı'nı açan yazarımız kimdir?",
    options: ["Şemseddin Sami", "Ahmet Mithat", "Namık Kemal", "Halit Ziya"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Üç Tarz-ı Siyaset' makalesinin yazarı kimdir?",
    options: ["Namık Kemal", "Ziya Gökalp", "Yusuf Akçura", "Ömer Seyfettin"],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Türkçülüğün Babası' olarak anılan düşünür kimdir?",
    options: ["Mehmet Emin", "Ziya Gökalp", "Ömer Seyfettin", "Yusuf Akçura"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text:
        "'Hikayeciliğin Öncüsü' olarak kabul edilen Milli Edebiyat yazarı kimdir?",
    options: ["Halide Edip", "Ömer Seyfettin", "Refik Halit", "Yakup Kadri"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Sosyal Gerçekçiliğin Öncüsü' olarak bilinen Türk şair kimdir?",
    options: ["Nazım Hikmet", "Orhan Veli", "Fazıl Hüsnü", "Attila İlhan"],
    correctIndex: 0,
    category: QuestionCategory.benKimim,
  ),

  // ESER TÜRLERİ VE AKIMLAR - 20 Soru
  Question(
    text: "'Safahat' hangi türde bir eserdir?",
    options: ["Roman", "Manzum hikaye", "Tiyatro", "Deneme"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Çalıkuşu' hangi edebiyat dönemine aittir?",
    options: ["Servet-i Fünun", "Milli Edebiyat", "Tanzimat", "Fecr-i Ati"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "'Aşk-ı Memnu' hangi akımın etkisiyle yazılmıştır?",
    options: ["Romantizm", "Realizm ve Natüralizm", "Klasisizm", "Sembolizm"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "'Ateşten Gömlek' hangi dönemin romanıdır?",
    options: ["Tanzimat", "Milli Edebiyat", "Servet-i Fünun", "Cumhuriyet"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "'Sinekli Bakkal' hangi dönemde yazılmıştır?",
    options: [
      "Cumhuriyet Dönemi",
      "Milli Edebiyat",
      "Servet-i Fünun",
      "Tanzimat",
    ],
    correctIndex: 0,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "'Huzur' romanı hangi türdedir?",
    options: ["Macera", "Psikolojik roman", "Tarihi roman", "Köy romanı"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Yaban' hangi tür roman örneğidir?",
    options: [
      "Aşk romanı",
      "Köy romanı/Tezli roman",
      "Macera romanı",
      "Polisiye",
    ],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Dokuzuncu Hariciye Koğuşu' hangi türdedir?",
    options: [
      "Tarihi roman",
      "Otobiyografik roman",
      "Macera romanı",
      "Aşk romanı",
    ],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Tutunamayanlar' hangi edebi akıma yakındır?",
    options: ["Realizm", "Postmodernizm", "Romantizm", "Natüralizm"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "'Yaprak Dökümü' hangi edebi dönemde yazılmıştır?",
    options: ["Tanzimat", "Servet-i Fünun", "Milli Edebiyat", "Cumhuriyet"],
    correctIndex: 2,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "'Kiralık Konak' romanı hangi türdedir?",
    options: ["Romantik", "Sosyal/Muhit romanı", "Macera", "Polisiye"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Mai ve Siyah' hangi dönemin eseridir?",
    options: ["Tanzimat", "Servet-i Fünun", "Milli Edebiyat", "Cumhuriyet"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "'Garip' hareketi hangi şiir anlayışına karşı çıkmıştır?",
    options: [
      "Hece veznine",
      "Ölçü ve kafiyeye",
      "Toplumcu şiire",
      "Serbest şiire",
    ],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "'İkinci Yeni' şiiri hangi özelliğiyle bilinir?",
    options: [
      "Sade dil",
      "Kapalı anlatım ve imge yoğunluğu",
      "Toplumcu içerik",
      "Hece ölçüsü",
    ],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Aruz veznini en iyi kullanan Cumhuriyet dönemi şairi kimdir?",
    options: ["Orhan Veli", "Yahya Kemal", "Nazım Hikmet", "Necip Fazıl"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Saf şiir' anlayışını savunan şair kimdir?",
    options: ["Orhan Veli", "Ahmet Haşim", "Nazım Hikmet", "Arif Nihat Asya"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "Recaizade Mahmut Ekrem hangi alanda etkili olmuştur?",
    options: [
      "Roman yazarlığı",
      "Şiir ve edebiyat kuramcılığı",
      "Tiyatro yazarlığı",
      "Gazetecilik",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Talim-i Edebiyat' kimin eseridir?",
    options: ["Namık Kemal", "Recaizade Ekrem", "Ziya Gökalp", "Halit Ziya"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "Muallim Naci hangi şiir anlayışını savunmuştur?",
    options: [
      "Yenileşme hareketini",
      "Eski şiir geleneğini",
      "Garip hareketini",
      "Serbest vezni",
    ],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Sanat sanat içindir' görüşü hangi dönemde yaygınlaşmıştır?",
    options: ["Tanzimat", "Servet-i Fünun", "Milli Edebiyat", "Cumhuriyet"],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),

  // ÖZEL BİLGİLER VE DETAYLAR - 15 Soru
  Question(
    text: "Hangi yazar hem roman hem de şiirde başarılı olmuştur?",
    options: [
      "Halit Ziya",
      "Mehmet Rauf",
      "Tevfik Fikret",
      "Ahmet Hamdi Tanpınar",
    ],
    correctIndex: 3,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Rübab-ı Şikeste' kimin şiir kitabıdır?",
    options: ["Cenap Şahabettin", "Tevfik Fikret", "Mehmet Rauf", "Halit Ziya"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Makber' şiiri kime yazılmıştır?",
    options: ["Eşine", "Kızına", "Annesine", "Oğluna"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Şiir ve İnşa' makalesi hangi tartışmayı başlatmıştır?",
    options: [
      "Dil tartışması",
      "Aruz-hece tartışması",
      "Roman-hikaye tartışması",
      "Şiir-nesir tartışması",
    ],
    correctIndex: 0,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Ahmet Hamdi Tanpınar'ın 'Beş Şehir' adlı eseri hangi türdedir?",
    options: ["Roman", "Deneme", "Hikaye", "Anı"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Edebiyat-ı Cedide' kavramı ne anlama gelir?",
    options: [
      "Eski edebiyat",
      "Yeni edebiyat",
      "Halk edebiyatı",
      "Divan edebiyatı",
    ],
    correctIndex: 1,
    category: QuestionCategory.edebiyatAkimlari,
  ),
  Question(
    text: "Ömer Seyfettin hangi türde eser vermemiştir?",
    options: ["Hikaye", "Roman", "Makale", "Şiir"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text:
        "Yakup Kadri Karaosmanoğlu hangi romanıyla köy edebiyatına katkı sağlamıştır?",
    options: ["Kiralık Konak", "Yaban", "Ankara", "Nur Baba"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Vatan Yahut Silistre' hangi türde bir eserdir?",
    options: ["Roman", "Hikaye", "Tiyatro", "Şiir"],
    correctIndex: 2,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Halit Ziya Uşaklıgil'in en önemli romanı hangisidir?",
    options: ["Kırık Hayatlar", "Aşk-ı Memnu", "Mai ve Siyah", "Nemide"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "Peyami Safa'nın 'Fatih-Harbiye' romanının konusu nedir?",
    options: [
      "Köy şehir çatışması",
      "Doğu Batı çatışması",
      "Kuşak çatışması",
      "Sınıf çatışması",
    ],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Yeşil Gece' romanının yazarı kimdir?",
    options: [
      "Halide Edip",
      "Yakup Kadri",
      "Reşat Nuri Güntekin",
      "Peyami Safa",
    ],
    correctIndex: 2,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "'Küçük Şeyler' adlı hikaye kitabının yazarı kimdir?",
    options: ["Halit Ziya", "Sami Paşazade", "Ömer Seyfettin", "Refik Halit"],
    correctIndex: 1,
    category: QuestionCategory.benKimim,
  ),
  Question(
    text: "Halide Edip Adıvar hangi romanıyla Kurtuluş Savaşı'nı anlatmıştır?",
    options: ["Sinekli Bakkal", "Ateşten Gömlek", "Tatarcık", "Vurun Kahpeye"],
    correctIndex: 1,
    category: QuestionCategory.eserKarakter,
  ),
  Question(
    text: "'Ok ve Işık' kimin şiir kitabıdır?",
    options: ["Yahya Kemal", "Mehmet Akif", "Necip Fazıl", "Ahmet Haşim"],
    correctIndex: 0,
    category: QuestionCategory.eserKarakter,
  ),
];
