/// Data Transfer Object for Question entity.
/// Used for JSON serialization and persistence.
/// Pure Dart - no Flutter dependencies.

enum QuestionCategoryModel {
  benKimim,
  turkEdebiyatindaIlkler,
  edebiyatAkimlari,
  edebiSanatlar,
  eserKarakter,
}

class QuestionModel {
  final String text;
  final List<String> options;
  final int correctIndex;
  final QuestionCategoryModel category;

  QuestionModel({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.category,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      text: json['text'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctIndex: json['correctIndex'] as int,
      category: QuestionCategoryModel.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => QuestionCategoryModel.benKimim,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'options': options,
      'correctIndex': correctIndex,
      'category': category.name,
    };
  }

  QuestionModel copyWith({
    String? text,
    List<String>? options,
    int? correctIndex,
    QuestionCategoryModel? category,
  }) {
    return QuestionModel(
      text: text ?? this.text,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionModel &&
        other.text == text &&
        other.correctIndex == correctIndex &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(text, correctIndex, category);

  @override
  String toString() {
    return 'QuestionModel(text: $text, options: $options, correctIndex: $correctIndex, category: $category)';
  }
}
