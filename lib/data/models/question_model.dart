/// Data Transfer Object for Question entity.
/// Used for JSON serialization and persistence.
/// Pure Dart - no Flutter dependencies.

enum QuestionCategoryModel {
  benKimim,
  turkEdebiyatindaIlkler,
  edebiyatAkimlari,
  edebiyatSanatlari,
  eserKarakter,
}

enum QuestionDifficultyModel { easy, medium, hard }

class QuestionModel {
  final String id;
  final String question;
  final String answer;
  final List<String> options;
  final QuestionCategoryModel category;
  final QuestionDifficultyModel difficulty;

  QuestionModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.options,
    required this.category,
    required this.difficulty,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String? ?? '',
      question: json['question'] as String,
      answer: json['answer'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      category: QuestionCategoryModel.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => QuestionCategoryModel.benKimim,
      ),
      difficulty: QuestionDifficultyModel.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => QuestionDifficultyModel.medium,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'options': options,
      'category': category.name,
      'difficulty': difficulty.name,
    };
  }

  /// Get correctIndex for backward compatibility
  int get correctIndex => options.indexOf(answer);

  QuestionModel copyWith({
    String? id,
    String? question,
    String? answer,
    List<String>? options,
    QuestionCategoryModel? category,
    QuestionDifficultyModel? difficulty,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      options: options ?? this.options,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionModel &&
        other.id == id &&
        other.question == question &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(id, question, category);

  @override
  String toString() {
    return 'QuestionModel(id: $id, question: $question, answer: $answer, category: $category)';
  }
}
