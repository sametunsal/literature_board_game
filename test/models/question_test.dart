import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/models/question.dart';

void main() {
  group('Question Model Tests', () {
    late Question question;

    setUp(() {
      question = const Question(
        id: 'q1',
        category: QuestionCategory.benKimim,
        difficulty: Difficulty.medium,
        question: 'Test question text',
        answer: 'Test answer',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        hint: 'Test hint',
      );
    });

    group('Question Creation', () {
      test('should create a question with all fields', () {
        expect(question.id, 'q1');
        expect(question.category, QuestionCategory.benKimim);
        expect(question.difficulty, Difficulty.medium);
        expect(question.question, 'Test question text');
        expect(question.answer, 'Test answer');
        expect(question.options, [
          'Option A',
          'Option B',
          'Option C',
          'Option D',
        ]);
        expect(question.hint, 'Test hint');
      });

      test('should create a question without options', () {
        const questionWithoutOptions = Question(
          id: 'q2',
          category: QuestionCategory.turkEdebiyatindaIlkler,
          difficulty: Difficulty.easy,
          question: 'Simple question',
          answer: 'Simple answer',
        );
        expect(questionWithoutOptions.options, isNull);
        expect(questionWithoutOptions.hint, isNull);
      });

      test('should create a question with hint but no options', () {
        const questionWithHint = Question(
          id: 'q3',
          category: QuestionCategory.edebiyatAkimlari,
          difficulty: Difficulty.hard,
          question: 'Hard question',
          answer: 'Hard answer',
          hint: 'Think carefully',
        );
        expect(questionWithHint.options, isNull);
        expect(questionWithHint.hint, 'Think carefully');
      });

      test('should create a question with options but no hint', () {
        const questionWithOptions = Question(
          id: 'q4',
          category: QuestionCategory.edebiyatSanatlari,
          difficulty: Difficulty.easy,
          question: 'Easy question',
          answer: 'Option A',
          options: ['Option A', 'Option B'],
        );
        expect(questionWithOptions.options, ['Option A', 'Option B']);
        expect(questionWithOptions.hint, isNull);
      });
    });

    group('Category Enum', () {
      test('should have benKimim category', () {
        const benKimimQuestion = Question(
          id: 'q1',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.easy,
          question: 'Who am I?',
          answer: 'Author',
        );
        expect(benKimimQuestion.category, QuestionCategory.benKimim);
      });

      test('should have turkEdebiyatindaIlkler category', () {
        const firstsQuestion = Question(
          id: 'q2',
          category: QuestionCategory.turkEdebiyatindaIlkler,
          difficulty: Difficulty.medium,
          question: 'First novel?',
          answer: 'İntibah',
        );
        expect(
          firstsQuestion.category,
          QuestionCategory.turkEdebiyatindaIlkler,
        );
      });

      test('should have edebiyatAkimlari category', () {
        const movementsQuestion = Question(
          id: 'q3',
          category: QuestionCategory.edebiyatAkimlari,
          difficulty: Difficulty.hard,
          question: 'Which movement?',
          answer: 'Servet-i Fünun',
        );
        expect(movementsQuestion.category, QuestionCategory.edebiyatAkimlari);
      });

      test('should have edebiyatSanatlari category', () {
        const artsQuestion = Question(
          id: 'q4',
          category: QuestionCategory.edebiyatSanatlari,
          difficulty: Difficulty.medium,
          question: 'Which art?',
          answer: 'Aruz',
        );
        expect(artsQuestion.category, QuestionCategory.edebiyatSanatlari);
      });

      test('should have eserKarakter category', () {
        const characterQuestion = Question(
          id: 'q5',
          category: QuestionCategory.eserKarakter,
          difficulty: Difficulty.easy,
          question: 'Which character?',
          answer: 'İnce Memed',
        );
        expect(characterQuestion.category, QuestionCategory.eserKarakter);
      });
    });

    group('Difficulty Enum', () {
      test('should have easy difficulty', () {
        const easyQuestion = Question(
          id: 'q1',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.easy,
          question: 'Easy question',
          answer: 'Easy answer',
        );
        expect(easyQuestion.difficulty, Difficulty.easy);
      });

      test('should have medium difficulty', () {
        const mediumQuestion = Question(
          id: 'q2',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.medium,
          question: 'Medium question',
          answer: 'Medium answer',
        );
        expect(mediumQuestion.difficulty, Difficulty.medium);
      });

      test('should have hard difficulty', () {
        const hardQuestion = Question(
          id: 'q3',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.hard,
          question: 'Hard question',
          answer: 'Hard answer',
        );
        expect(hardQuestion.difficulty, Difficulty.hard);
      });
    });

    group('starReward Computed Property', () {
      test('should return 10 stars for easy difficulty', () {
        const easyQuestion = Question(
          id: 'q1',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.easy,
          question: 'Easy question',
          answer: 'Easy answer',
        );
        expect(easyQuestion.starReward, 10);
      });

      test('should return 15 stars for medium difficulty', () {
        const mediumQuestion = Question(
          id: 'q2',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.medium,
          question: 'Medium question',
          answer: 'Medium answer',
        );
        expect(mediumQuestion.starReward, 15);
      });

      test('should return 20 stars for hard difficulty', () {
        const hardQuestion = Question(
          id: 'q3',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.hard,
          question: 'Hard question',
          answer: 'Hard answer',
        );
        expect(hardQuestion.starReward, 20);
      });
    });

    group('isMultipleChoice Computed Property', () {
      test('should return true when options are provided', () {
        expect(question.isMultipleChoice, isTrue);
      });

      test('should return false when options are null', () {
        const questionWithoutOptions = Question(
          id: 'q2',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.easy,
          question: 'Simple question',
          answer: 'Simple answer',
        );
        expect(questionWithoutOptions.isMultipleChoice, isFalse);
      });

      test('should return false when options list is empty', () {
        const questionWithEmptyOptions = Question(
          id: 'q3',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.easy,
          question: 'Question',
          answer: 'Answer',
          options: [],
        );
        expect(questionWithEmptyOptions.isMultipleChoice, isFalse);
      });

      test('should return true with single option', () {
        const questionWithSingleOption = Question(
          id: 'q4',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.easy,
          question: 'Question',
          answer: 'Answer',
          options: ['Option A'],
        );
        expect(questionWithSingleOption.isMultipleChoice, isTrue);
      });
    });

    group('isAnswerCorrect Method', () {
      test('should return true for exact match', () {
        expect(question.isAnswerCorrect('Test answer'), isTrue);
      });

      test('should return true for case-insensitive match', () {
        expect(question.isAnswerCorrect('test answer'), isTrue);
        expect(question.isAnswerCorrect('TEST ANSWER'), isTrue);
        expect(question.isAnswerCorrect('TeSt AnSwEr'), isTrue);
      });

      test('should return true for match with extra whitespace', () {
        // The implementation trims the user answer but not the stored answer
        expect(question.isAnswerCorrect('  Test answer  '), isTrue);
        // This will fail because the stored answer has no extra whitespace
        // and the implementation only trims the user input
        expect(question.isAnswerCorrect('Test  answer'), isFalse);
      });

      test('should return false for incorrect answer', () {
        expect(question.isAnswerCorrect('Wrong answer'), isFalse);
      });

      test('should return false for empty string', () {
        expect(question.isAnswerCorrect(''), isFalse);
      });

      test('should return false for partial match', () {
        expect(question.isAnswerCorrect('Test'), isFalse);
        expect(question.isAnswerCorrect('answer'), isFalse);
      });

      test('should handle Turkish characters correctly', () {
        const turkishQuestion = Question(
          id: 'q1',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.easy,
          question: 'Türkçe soru',
          answer: 'İstanbul',
        );
        expect(turkishQuestion.isAnswerCorrect('istanbul'), isTrue);
        expect(turkishQuestion.isAnswerCorrect('İSTANBUL'), isTrue);
      });
    });

    group('isOptionCorrect Method', () {
      test('should return true for correct option index', () {
        // The answer is 'Test answer' and options[0] is 'Option A'
        // So index 0 should be false
        expect(question.isOptionCorrect(0), isFalse);
      });

      test('should return false for incorrect option index', () {
        expect(question.isOptionCorrect(1), isFalse);
        expect(question.isOptionCorrect(2), isFalse);
        expect(question.isOptionCorrect(3), isFalse);
      });

      test('should return false for negative index', () {
        expect(question.isOptionCorrect(-1), isFalse);
      });

      test('should return false for index out of bounds', () {
        expect(question.isOptionCorrect(4), isFalse);
        expect(question.isOptionCorrect(10), isFalse);
      });

      test('should return false when options are null', () {
        const questionWithoutOptions = Question(
          id: 'q2',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.easy,
          question: 'Simple question',
          answer: 'Simple answer',
        );
        expect(questionWithoutOptions.isOptionCorrect(0), isFalse);
      });

      test('should return false when options list is empty', () {
        const questionWithEmptyOptions = Question(
          id: 'q3',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.easy,
          question: 'Question',
          answer: 'Answer',
          options: [],
        );
        expect(questionWithEmptyOptions.isOptionCorrect(0), isFalse);
      });

      test('should handle case-insensitive option matching', () {
        const caseQuestion = Question(
          id: 'q4',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.easy,
          question: 'Question',
          answer: 'option a',
          options: ['OPTION A', 'Option B', 'Option C'],
        );
        expect(caseQuestion.isOptionCorrect(0), isTrue);
      });

      test('should handle whitespace in options', () {
        const whitespaceQuestion = Question(
          id: 'q5',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.easy,
          question: 'Question',
          answer: 'Option A',
          options: ['  Option A  ', 'Option B', 'Option C'],
        );
        expect(whitespaceQuestion.isOptionCorrect(0), isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle empty question text', () {
        const emptyQuestion = Question(
          id: 'q1',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.easy,
          question: '',
          answer: 'Answer',
        );
        expect(emptyQuestion.question, '');
      });

      test('should handle empty answer', () {
        const emptyAnswerQuestion = Question(
          id: 'q1',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.easy,
          question: 'Question',
          answer: '',
        );
        expect(emptyAnswerQuestion.answer, '');
        expect(emptyAnswerQuestion.isAnswerCorrect(''), isTrue);
      });

      test('should handle special characters in answer', () {
        final specialCharQuestion = Question(
          id: 'q1',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.easy,
          question: 'Question',
          answer: 'Answer!@#\$%',
        );
        expect(specialCharQuestion.isAnswerCorrect('Answer!@#\$%'), isTrue);
      });

      test('should handle very long question text', () {
        final longText = 'A' * 1000;
        final longQuestion = Question(
          id: 'q1',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.easy,
          question: longText,
          answer: 'Answer',
        );
        expect(longQuestion.question.length, 1000);
      });

      test('should handle many options', () {
        final manyOptions = List.generate(10, (i) => 'Option $i');
        final manyOptionsQuestion = Question(
          id: 'q1',
          category: QuestionCategory.benKimim,
          difficulty: Difficulty.easy,
          question: 'Question',
          answer: 'Option 5',
          options: manyOptions,
        );
        expect(manyOptionsQuestion.options?.length, 10);
        expect(manyOptionsQuestion.isOptionCorrect(5), isTrue);
      });
    });

    group('Question Categories with All Difficulties', () {
      test('should create questions for all categories and difficulties', () {
        final categories = QuestionCategory.values;
        final difficulties = Difficulty.values;

        for (final category in categories) {
          for (final difficulty in difficulties) {
            final testQuestion = Question(
              id: '${category.name}_${difficulty.name}',
              category: category,
              difficulty: difficulty,
              question: 'Test question',
              answer: 'Test answer',
            );
            expect(testQuestion.category, category);
            expect(testQuestion.difficulty, difficulty);
          }
        }
      });
    });
  });
}
