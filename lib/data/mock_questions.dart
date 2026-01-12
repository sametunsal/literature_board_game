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
];
