import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/question.dart';
import '../exceptions/question_loading_exception.dart';

/// Repository for literature questions loaded from JSON asset
class QuestionRepository {
  static List<Question>? _cachedQuestions;
  static bool _isLoading = false;
  static String? _lastError;
  static bool _hasError = false;

  /// Load questions from JSON asset (call once at app startup)
  /// Returns true if successful, false if fallback was used
  static Future<bool> loadQuestions() async {
    if (_cachedQuestions != null || _isLoading) return !_hasError;

    _isLoading = true;
    _hasError = false;
    _lastError = null;

    try {
      // Load JSON from assets
      final String jsonString = await rootBundle.loadString(
        'assets/data/questions.json',
      );

      if (jsonString.isEmpty) {
        throw QuestionFileException('Questions file is empty');
      }

      final dynamic decoded = json.decode(jsonString);

      if (decoded is! List) {
        throw InvalidQuestionDataException(
          'Expected a list of questions, got ${decoded.runtimeType}',
        );
      }

      final List<dynamic> jsonList = decoded;

      if (jsonList.isEmpty) {
        throw InvalidQuestionDataException('Questions list is empty');
      }

      // Parse questions with individual error handling
      final List<Question> parsedQuestions = [];
      final List<String> parseErrors = [];

      for (int i = 0; i < jsonList.length; i++) {
        try {
          final json = jsonList[i];
          if (json is! Map) {
            parseErrors.add('Question at index $i is not a valid object');
            continue;
          }

          final question = Question(
            id: json['id']?.toString() ?? 'unknown_$i',
            category: _parseCategory(
              json['category']?.toString() ?? 'benKimim',
            ),
            difficulty: _parseDifficulty(
              json['difficulty']?.toString() ?? 'easy',
            ),
            question: json['question']?.toString() ?? 'Soru metni bulunamadı',
            answer: json['answer']?.toString() ?? 'Cevap bulunamadı',
            options: json['options'] != null
                ? List<String>.from(json['options'] as List)
                : null,
            hint: json['hint']?.toString(),
          );
          parsedQuestions.add(question);
        } catch (e) {
          parseErrors.add('Failed to parse question at index $i: $e');
        }
      }

      if (parsedQuestions.isEmpty) {
        throw InvalidQuestionDataException(
          'No valid questions could be parsed. Errors: ${parseErrors.join(", ")}',
        );
      }

      _cachedQuestions = parsedQuestions;

      if (parseErrors.isNotEmpty) {
        debugPrint(
          '⚠️ Loaded ${_cachedQuestions!.length} questions with ${parseErrors.length} parse errors',
        );
        for (final error in parseErrors) {
          debugPrint('  - $error');
        }
      } else {
        debugPrint('✅ Loaded ${_cachedQuestions!.length} questions from JSON');
      }

      return true;
    } on QuestionLoadingException catch (e) {
      _hasError = true;
      _lastError = e.message;
      debugPrint('❌ Question loading error: $e');
      // Fallback to minimal hardcoded list if JSON fails
      _cachedQuestions = _getFallbackQuestions();
      debugPrint('⚠️ Using fallback questions due to error');
      return false;
    } on FormatException catch (e) {
      _hasError = true;
      _lastError = 'Invalid JSON format: ${e.message}';
      debugPrint('❌ JSON format error: $e');
      _cachedQuestions = _getFallbackQuestions();
      debugPrint('⚠️ Using fallback questions due to JSON format error');
      return false;
    } catch (e, stack) {
      _hasError = true;
      _lastError = 'Unexpected error: $e';
      debugPrint('❌ Unexpected error loading questions: $e\n$stack');
      _cachedQuestions = _getFallbackQuestions();
      debugPrint('⚠️ Using fallback questions due to unexpected error');
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Get a random question from specified category
  static Question getRandomQuestion(QuestionCategory category) {
    if (_cachedQuestions == null) {
      debugPrint('⚠️ Questions not loaded yet, using fallback');
      _cachedQuestions = _getFallbackQuestions();
    }

    final questions = _getQuestionsByCategory(category);
    if (questions.isEmpty) {
      debugPrint('⚠️ No questions found for category $category');
      // Return a generic fallback question
      return Question(
        id: 'fallback',
        category: category,
        difficulty: Difficulty.easy,
        question: 'Bu kategori için soru bulunamadı.',
        answer: 'Tekrar Deneyin',
        options: ['Tekrar Deneyin', 'İptal', 'Geri', 'Çıkış'],
      );
    }

    final random = DateTime.now().millisecond % questions.length;
    return questions[random];
  }

  /// Get all questions for a category
  static List<Question> _getQuestionsByCategory(QuestionCategory category) {
    if (_cachedQuestions == null) return [];

    return _cachedQuestions!.where((q) => q.category == category).toList();
  }

  /// Get all questions as a pool
  static List<Question> getAllQuestions() {
    return _cachedQuestions ?? _getFallbackQuestions();
  }

  /// Check if there was an error loading questions
  static bool hasError() => _hasError;

  /// Get the last error message
  static String? getLastError() => _lastError;

  /// Check if questions are currently loading
  static bool isLoading() => _isLoading;

  /// Check if questions have been loaded (either successfully or with fallback)
  static bool isLoaded() => _cachedQuestions != null;

  /// Parse category string to enum
  static QuestionCategory _parseCategory(String category) {
    switch (category) {
      case 'benKimim':
        return QuestionCategory.benKimim;
      case 'turkEdebiyatindaIlkler':
        return QuestionCategory.turkEdebiyatindaIlkler;
      case 'edebiyatAkimlari':
        return QuestionCategory.edebiyatAkimlari;
      case 'edebiyatSanatlari':
        return QuestionCategory.edebiyatSanatlari;
      case 'eserKarakter':
        return QuestionCategory.eserKarakter;
      default:
        debugPrint('⚠️ Unknown category: $category, defaulting to benKimim');
        return QuestionCategory.benKimim;
    }
  }

  /// Parse difficulty string to enum
  static Difficulty _parseDifficulty(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Difficulty.easy;
      case 'medium':
        return Difficulty.medium;
      case 'hard':
        return Difficulty.hard;
      default:
        debugPrint('⚠️ Unknown difficulty: $difficulty, defaulting to easy');
        return Difficulty.easy;
    }
  }

  /// Fallback questions if JSON loading fails
  static List<Question> _getFallbackQuestions() {
    return [
      // Ben Kimim (5 soru)
      Question(
        id: 'fb_001',
        category: QuestionCategory.benKimim,
        difficulty: Difficulty.easy,
        question: 'Hangi yazar Tutunamayanlar romanının yazarıdır?',
        answer: 'Oğuz Atay',
        options: [
          'Oğuz Atay',
          'Yaşar Kemal',
          'Sabahattin Ali',
          'Sait Faik Abasıyanık',
        ],
      ),
      Question(
        id: 'fb_002',
        category: QuestionCategory.benKimim,
        difficulty: Difficulty.easy,
        question: 'İnce Memed romanının yazarı kimdir?',
        answer: 'Yaşar Kemal',
        options: [
          'Yaşar Kemal',
          'Orhan Kemal',
          'Kemal Tahir',
          'Sabahattin Ali',
        ],
      ),
      Question(
        id: 'fb_003',
        category: QuestionCategory.benKimim,
        difficulty: Difficulty.medium,
        question: 'Kürk Mantolu Madonna romanının yazarı kimdir?',
        answer: 'Sabahattin Ali',
        options: [
          'Sabahattin Ali',
          'Ahmet Hamdi Tanpınar',
          'Oğuz Atay',
          'Sait Faik',
        ],
      ),
      Question(
        id: 'fb_004',
        category: QuestionCategory.benKimim,
        difficulty: Difficulty.medium,
        question: 'Saatleri Ayarlama Enstitüsü romanının yazarı kimdir?',
        answer: 'Ahmet Hamdi Tanpınar',
        options: [
          'Ahmet Hamdi Tanpınar',
          'Yaşar Kemal',
          'Orhan Pamuk',
          'Elif Şafak',
        ],
      ),
      Question(
        id: 'fb_005',
        category: QuestionCategory.benKimim,
        difficulty: Difficulty.hard,
        question: 'Kırlangıç Yuvası eserinin yazarı kimdir?',
        answer: 'Sait Faik Abasıyanık',
        options: [
          'Sait Faik Abasıyanık',
          'Yaşar Kemal',
          'Orhan Kemal',
          'Sabahattin Ali',
        ],
      ),

      // Türk Edebiyatında İlkler (5 soru)
      Question(
        id: 'fb_006',
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
      ),
      Question(
        id: 'fb_007',
        category: QuestionCategory.turkEdebiyatindaIlkler,
        difficulty: Difficulty.easy,
        question: 'Türk edebiyatında ilk tiyatro oyunu yazarı kimdir?',
        answer: 'Şinasi',
        options: ['Şinasi', 'Namık Kemal', 'Ziya Paşa', 'Ahmet Mithat Efendi'],
      ),
      Question(
        id: 'fb_008',
        category: QuestionCategory.turkEdebiyatindaIlkler,
        difficulty: Difficulty.medium,
        question: 'İlk Türk kadın romancı kimdir?',
        answer: 'Fatma Aliye',
        options: [
          'Fatma Aliye',
          'Halide Edip Adıvar',
          'Afet İnan',
          'Emine Semiye',
        ],
      ),
      Question(
        id: 'fb_009',
        category: QuestionCategory.turkEdebiyatindaIlkler,
        difficulty: Difficulty.medium,
        question: 'İlk Türkçe gazetenin adı nedir?',
        answer: 'Takvim-i Vekayi',
        options: [
          'Takvim-i Vekayi',
          'Tercüman-ı Ahval',
          'Ceride-i Havadis',
          'Bosphor',
        ],
      ),
      Question(
        id: 'fb_010',
        category: QuestionCategory.turkEdebiyatindaIlkler,
        difficulty: Difficulty.hard,
        question: 'Türk edebiyatında ilk mizah dergisi hangisidir?',
        answer: 'Diyojen',
        options: ['Diyojen', 'Karagöz', 'Hayal', 'Tanzimat'],
      ),

      // Edebiyat Akımları (5 soru)
      Question(
        id: 'fb_011',
        category: QuestionCategory.edebiyatAkimlari,
        difficulty: Difficulty.easy,
        question: 'Servet-i Fünun dergisi hangi edebi akımı temsil eder?',
        answer: 'Servet-i Fünun Edebiyatı',
        options: [
          'Servet-i Fünun Edebiyatı',
          'Milli Edebiyat',
          'Yedi Meşale',
          'Garip Akımı',
        ],
      ),
      Question(
        id: 'fb_012',
        category: QuestionCategory.edebiyatAkimlari,
        difficulty: Difficulty.easy,
        question: 'Garip akımının kurucuları kimlerdir?',
        answer: 'Orhan Veli, Melih Cevdet, Oktay Rifat',
        options: [
          'Orhan Veli, Melih Cevdet, Oktay Rifat',
          'Nazım Hikmet, Orhan Veli, Fazıl Hüsnü',
          'Cahit Sıtkı, Ahmet Hamdi, Orhan Veli',
          'Necip Fazıl, Sezai Karakoç, Cahit Zarifoğlu',
        ],
      ),
      Question(
        id: 'fb_013',
        category: QuestionCategory.edebiyatAkimlari,
        difficulty: Difficulty.medium,
        question: 'Milli Edebiyat akımının öncüsü kimdir?',
        answer: 'Ziya Gökalp',
        options: ['Ziya Gökalp', 'Ömer Seyfettin', 'Ali Canip', 'Yusuf Akçura'],
      ),
      Question(
        id: 'fb_014',
        category: QuestionCategory.edebiyatAkimlari,
        difficulty: Difficulty.medium,
        question: 'Yeni Lisan akımının kurucusu kimdir?',
        answer: 'Ziya Gökalp',
        options: ['Ziya Gökalp', 'Ömer Seyfettin', 'Ali Canip', 'Yusuf Akçura'],
      ),
      Question(
        id: 'fb_015',
        category: QuestionCategory.edebiyatAkimlari,
        difficulty: Difficulty.hard,
        question: 'İkinci Yeni akımının özelliklerinden biri nedir?',
        answer: 'İçten dışa akış',
        options: [
          'İçten dışa akış',
          'Toplumsal gerçekçilik',
          'Sanat sanat içindir',
          'Bireyci yaklaşım',
        ],
      ),

      // Edebiyat Sanatları (5 soru)
      Question(
        id: 'fb_016',
        category: QuestionCategory.edebiyatSanatlari,
        difficulty: Difficulty.easy,
        question: 'Divan edebiyatında beyit kaç dizeden oluşur?',
        answer: '2',
        options: ['2', '3', '4', '5'],
      ),
      Question(
        id: 'fb_017',
        category: QuestionCategory.edebiyatSanatlari,
        difficulty: Difficulty.easy,
        question: 'Aruz sanatı nedir?',
        answer: 'Aralıklı vezin',
        options: [
          'Aralıklı vezin',
          'Kafiye sanatı',
          'İsim sanatı',
          'Anlatım tekniği',
        ],
      ),
      Question(
        id: 'fb_018',
        category: QuestionCategory.edebiyatSanatlari,
        difficulty: Difficulty.medium,
        question: 'İki satırlı dörtlük benzerliklerine verilen ad nedir?',
        answer: 'Kafiye',
        options: ['Kafiye', 'Redif', 'Cağ', 'Aruz'],
      ),
      Question(
        id: 'fb_019',
        category: QuestionCategory.edebiyatSanatlari,
        difficulty: Difficulty.medium,
        question: 'Redif nedir?',
        answer: 'Aynı sesin tekrarlanması',
        options: [
          'Aynı sesin tekrarlanması',
          'Farklı seslerin benzerliği',
          'Kelimelerin anlamı',
          'Ses uyumu',
        ],
      ),
      Question(
        id: 'fb_020',
        category: QuestionCategory.edebiyatSanatlari,
        difficulty: Difficulty.hard,
        question: 'Belagat sanatı neyi inceler?',
        answer: 'Konuşma sanatını',
        options: [
          'Konuşma sanatını',
          'Yazı sanatını',
          'Şiir sanatını',
          'Anlatım sanatını',
        ],
      ),

      // Eser-Karakter (5 soru)
      Question(
        id: 'fb_021',
        category: QuestionCategory.eserKarakter,
        difficulty: Difficulty.easy,
        question: 'İnce Memed romanında ana karakterin sevgilisinin adı nedir?',
        answer: 'Hatçe',
        options: ['Hatçe', 'Meleke', 'Çakırcı Mehmet', 'Işık'],
      ),
      Question(
        id: 'fb_022',
        category: QuestionCategory.eserKarakter,
        difficulty: Difficulty.easy,
        question: 'Kürk Mantolu Madonna romanında Raif\'in mesleği nedir?',
        answer: 'Gümrük memuru',
        options: ['Gümrük memuru', 'Öğretmen', 'Mühendis', 'Doktor'],
      ),
      Question(
        id: 'fb_023',
        category: QuestionCategory.eserKarakter,
        difficulty: Difficulty.medium,
        question: 'Yılanların Öcü romanında köyün adı nedir?',
        answer: 'Saklıtatlar',
        options: ['Saklıtatlar', 'Bozcaalan', 'Yukarı', 'Çukur'],
      ),
      Question(
        id: 'fb_024',
        category: QuestionCategory.eserKarakter,
        difficulty: Difficulty.medium,
        question:
            'Saatleri Ayarlama Enstitüsü romanında Halit\'in kızının adı nedir?',
        answer: 'Nuran',
        options: ['Nuran', 'Zehra', 'Ayşe', 'Fatma'],
      ),
      Question(
        id: 'fb_025',
        category: QuestionCategory.eserKarakter,
        difficulty: Difficulty.hard,
        question: 'Tutunamayanlar romanında Selim\'in mesleği nedir?',
        answer: 'Mühendis',
        options: ['Mühendis', 'Doktor', 'Öğretmen', 'Yazar'],
      ),
    ];
  }
}
