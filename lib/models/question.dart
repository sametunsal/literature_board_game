enum QuestionCategory {
  benKimim,
  turkEdebiyatindaIlkler,
  edebiyatAkillari,
  edebiyatSanatlari,
  eserKarakter,
}

enum Difficulty { easy, medium, hard }

class Question {
  final String id;
  final QuestionCategory category;
  final Difficulty difficulty;
  final String question;
  final String answer;
  final List<String>? options; // Optional multiple choice options
  final String? hint; // Optional hint for the question

  const Question({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.question,
    required this.answer,
    this.options,
    this.hint,
  });

  // Calculate star reward based on difficulty
  int get starReward {
    switch (difficulty) {
      case Difficulty.easy:
        return 10;
      case Difficulty.medium:
        return 15;
      case Difficulty.hard:
        return 20;
    }
  }

  // Check if question is multiple choice
  bool get isMultipleChoice => options != null && options!.isNotEmpty;

  // Check if answer is correct
  bool isAnswerCorrect(String userAnswer) {
    return userAnswer.trim().toLowerCase() == answer.trim().toLowerCase();
  }

  // Check if multiple choice option is correct
  bool isOptionCorrect(int selectedIndex) {
    if (!isMultipleChoice ||
        selectedIndex < 0 ||
        selectedIndex >= options!.length) {
      return false;
    }
    return options![selectedIndex].trim().toLowerCase() ==
        answer.trim().toLowerCase();
  }
}
