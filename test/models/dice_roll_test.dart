import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/models/dice_roll.dart';

void main() {
  group('DiceRoll Model Tests', () {
    late DiceRoll diceRoll;

    setUp(() {
      diceRoll = const DiceRoll(die1: 3, die2: 4);
    });

    group('DiceRoll Creation', () {
      test('should create a dice roll with valid values', () {
        expect(diceRoll.die1, 3);
        expect(diceRoll.die2, 4);
      });

      test('should create a dice roll with minimum values', () {
        const minRoll = DiceRoll(die1: 1, die2: 1);
        expect(minRoll.die1, 1);
        expect(minRoll.die2, 1);
      });

      test('should create a dice roll with maximum values', () {
        const maxRoll = DiceRoll(die1: 6, die2: 6);
        expect(maxRoll.die1, 6);
        expect(maxRoll.die2, 6);
      });

      test('should create a dice roll with same values (double)', () {
        const doubleRoll = DiceRoll(die1: 5, die2: 5);
        expect(doubleRoll.die1, 5);
        expect(doubleRoll.die2, 5);
      });
    });

    group('Computed Properties', () {
      test('total should return sum of both dice', () {
        expect(diceRoll.total, 7);
      });

      test('total should return 2 for minimum roll', () {
        const minRoll = DiceRoll(die1: 1, die2: 1);
        expect(minRoll.total, 2);
      });

      test('total should return 12 for maximum roll', () {
        const maxRoll = DiceRoll(die1: 6, die2: 6);
        expect(maxRoll.total, 12);
      });

      test('isDouble should return false for different values', () {
        expect(diceRoll.isDouble, isFalse);
      });

      test('isDouble should return true for same values', () {
        const doubleRoll = DiceRoll(die1: 3, die2: 3);
        expect(doubleRoll.isDouble, isTrue);
      });

      test('isDouble should return true for all doubles', () {
        for (int i = 1; i <= 6; i++) {
          final doubleRoll = DiceRoll(die1: i, die2: i);
          expect(doubleRoll.isDouble, isTrue);
        }
      });

      test('isValid should return true for valid dice values (1-6)', () {
        expect(diceRoll.isValid, isTrue);
      });

      test('isValid should return true for all valid combinations', () {
        for (int d1 = 1; d1 <= 6; d1++) {
          for (int d2 = 1; d2 <= 6; d2++) {
            final roll = DiceRoll(die1: d1, die2: d2);
            expect(roll.isValid, isTrue);
          }
        }
      });
    });

    group('Value Validation', () {
      test('should accept value 1', () {
        const roll = DiceRoll(die1: 1, die2: 1);
        expect(roll.isValid, isTrue);
      });

      test('should accept value 6', () {
        const roll = DiceRoll(die1: 6, die2: 6);
        expect(roll.isValid, isTrue);
      });

      test('should accept all values from 1 to 6', () {
        for (int i = 1; i <= 6; i++) {
          final roll = DiceRoll(die1: i, die2: i);
          expect(roll.isValid, isTrue);
        }
      });

      test('should handle edge case of value 1', () {
        const roll = DiceRoll(die1: 1, die2: 6);
        expect(roll.isValid, isTrue);
        expect(roll.total, 7);
      });

      test('should handle edge case of value 6', () {
        const roll = DiceRoll(die1: 6, die2: 1);
        expect(roll.isValid, isTrue);
        expect(roll.total, 7);
      });
    });

    group('isThirdDouble Method', () {
      test('should return false when not a double', () {
        expect(diceRoll.isThirdDouble(0), isFalse);
        expect(diceRoll.isThirdDouble(1), isFalse);
        expect(diceRoll.isThirdDouble(2), isFalse);
      });

      test('should return false when double count is less than 2', () {
        const doubleRoll = DiceRoll(die1: 3, die2: 3);
        expect(doubleRoll.isThirdDouble(0), isFalse);
        expect(doubleRoll.isThirdDouble(1), isFalse);
      });

      test('should return true when double count is 2 and roll is double', () {
        const doubleRoll = DiceRoll(die1: 4, die2: 4);
        expect(doubleRoll.isThirdDouble(2), isTrue);
      });

      test('should return false when double count is greater than 2', () {
        const doubleRoll = DiceRoll(die1: 5, die2: 5);
        expect(doubleRoll.isThirdDouble(3), isFalse);
        expect(doubleRoll.isThirdDouble(4), isFalse);
      });
    });

    group('random() Factory Method', () {
      test('should create a dice roll with valid values', () {
        final randomRoll = DiceRoll.random();
        expect(randomRoll.die1, greaterThanOrEqualTo(1));
        expect(randomRoll.die1, lessThanOrEqualTo(6));
        expect(randomRoll.die2, greaterThanOrEqualTo(1));
        expect(randomRoll.die2, lessThanOrEqualTo(6));
      });

      test('should create valid dice rolls on multiple calls', () {
        for (int i = 0; i < 100; i++) {
          final randomRoll = DiceRoll.random();
          expect(randomRoll.isValid, isTrue);
        }
      });

      test('should produce different rolls over time', () {
        final rolls = <DiceRoll>[];
        for (int i = 0; i < 50; i++) {
          rolls.add(DiceRoll.random());
        }
        // With 50 random rolls, it's extremely unlikely all are the same
        final uniqueRolls = rolls.toSet();
        expect(uniqueRolls.length, greaterThan(1));
      });
    });

    group('specific() Factory Method', () {
      test('should create a dice roll with specified values', () {
        final specificRoll = DiceRoll.specific(2, 5);
        expect(specificRoll.die1, 2);
        expect(specificRoll.die2, 5);
      });

      test('should create a double using specific()', () {
        final doubleRoll = DiceRoll.specific(6, 6);
        expect(doubleRoll.die1, 6);
        expect(doubleRoll.die2, 6);
        expect(doubleRoll.isDouble, isTrue);
      });

      test('should create minimum roll using specific()', () {
        final minRoll = DiceRoll.specific(1, 1);
        expect(minRoll.die1, 1);
        expect(minRoll.die2, 1);
        expect(minRoll.total, 2);
      });

      test('should create maximum roll using specific()', () {
        final maxRoll = DiceRoll.specific(6, 6);
        expect(maxRoll.die1, 6);
        expect(maxRoll.die2, 6);
        expect(maxRoll.total, 12);
      });
    });

    group('copyWith Method', () {
      test('should create a copy with updated die1', () {
        final updatedRoll = diceRoll.copyWith(die1: 5);
        expect(updatedRoll.die1, 5);
        expect(updatedRoll.die2, 4);
      });

      test('should create a copy with updated die2', () {
        final updatedRoll = diceRoll.copyWith(die2: 2);
        expect(updatedRoll.die1, 3);
        expect(updatedRoll.die2, 2);
      });

      test('should create a copy with both dice updated', () {
        final updatedRoll = diceRoll.copyWith(die1: 1, die2: 6);
        expect(updatedRoll.die1, 1);
        expect(updatedRoll.die2, 6);
      });

      test(
        'should create a copy with same values when no parameters provided',
        () {
          final copiedRoll = diceRoll.copyWith();
          expect(copiedRoll.die1, diceRoll.die1);
          expect(copiedRoll.die2, diceRoll.die2);
        },
      );

      test('should not modify original roll when copying', () {
        final originalDie1 = diceRoll.die1;
        final originalDie2 = diceRoll.die2;

        diceRoll.copyWith(die1: 6, die2: 6);

        expect(diceRoll.die1, originalDie1);
        expect(diceRoll.die2, originalDie2);
      });

      test('should create a double using copyWith', () {
        final doubleRoll = diceRoll.copyWith(die1: 4, die2: 4);
        expect(doubleRoll.isDouble, isTrue);
      });
    });

    group('toString Method', () {
      test('should return correct string representation for normal roll', () {
        expect(diceRoll.toString(), 'DiceRoll(3, 4) - Total: 7');
      });

      test('should return correct string representation for double', () {
        const doubleRoll = DiceRoll(die1: 5, die2: 5);
        expect(doubleRoll.toString(), 'DiceRoll(5, 5) - Total: 10 (DOUBLE!)');
      });

      test('should return correct string for minimum roll', () {
        const minRoll = DiceRoll(die1: 1, die2: 1);
        expect(minRoll.toString(), 'DiceRoll(1, 1) - Total: 2 (DOUBLE!)');
      });

      test('should return correct string for maximum roll', () {
        const maxRoll = DiceRoll(die1: 6, die2: 6);
        expect(maxRoll.toString(), 'DiceRoll(6, 6) - Total: 12 (DOUBLE!)');
      });
    });

    group('Equality Operator', () {
      test('should be equal to itself', () {
        expect(diceRoll == diceRoll, isTrue);
      });

      test('should be equal to another roll with same values', () {
        const otherRoll = DiceRoll(die1: 3, die2: 4);
        expect(diceRoll == otherRoll, isTrue);
      });

      test('should not be equal to roll with different die1', () {
        const otherRoll = DiceRoll(die1: 2, die2: 4);
        expect(diceRoll == otherRoll, isFalse);
      });

      test('should not be equal to roll with different die2', () {
        const otherRoll = DiceRoll(die1: 3, die2: 5);
        expect(diceRoll == otherRoll, isFalse);
      });

      test('should not be equal to roll with both dice different', () {
        const otherRoll = DiceRoll(die1: 1, die2: 6);
        expect(diceRoll == otherRoll, isFalse);
      });

      test('should not be equal to different type', () {
        expect(diceRoll, isNot('DiceRoll(3, 4)'));
      });
    });

    group('hashCode', () {
      test('should have same hashCode for equal rolls', () {
        const roll1 = DiceRoll(die1: 3, die2: 4);
        const roll2 = DiceRoll(die1: 3, die2: 4);
        expect(roll1.hashCode, roll2.hashCode);
      });

      test('should have consistent hashCode', () {
        final hashCode1 = diceRoll.hashCode;
        final hashCode2 = diceRoll.hashCode;
        expect(hashCode1, hashCode2);
      });

      test(
        'note: hashCode may collide for different values due to XOR implementation',
        () {
          // The current implementation uses XOR which can produce same hash for different values
          // e.g., (3,4) and (4,3) may have same hash
          const roll1 = DiceRoll(die1: 3, die2: 4);
          const roll2 = DiceRoll(die1: 4, die2: 3);
          // This is a known limitation of the current hashCode implementation
          // Equality is still checked via == operator
          expect(roll1 == roll2, isFalse);
        },
      );
    });

    group('Edge Cases', () {
      test('should handle all possible dice combinations', () {
        final allCombinations = <DiceRoll>[];
        for (int d1 = 1; d1 <= 6; d1++) {
          for (int d2 = 1; d2 <= 6; d2++) {
            final roll = DiceRoll(die1: d1, die2: d2);
            allCombinations.add(roll);
            expect(roll.isValid, isTrue);
            expect(roll.total, greaterThanOrEqualTo(2));
            expect(roll.total, lessThanOrEqualTo(12));
          }
        }
        expect(allCombinations.length, 36);
      });

      test('should have exactly 6 possible doubles', () {
        final doubles = <DiceRoll>[];
        for (int i = 1; i <= 6; i++) {
          final roll = DiceRoll(die1: i, die2: i);
          if (roll.isDouble) {
            doubles.add(roll);
          }
        }
        expect(doubles.length, 6);
      });

      test('should have correct total distribution', () {
        final totals = <int, int>{};
        for (int d1 = 1; d1 <= 6; d1++) {
          for (int d2 = 1; d2 <= 6; d2++) {
            final roll = DiceRoll(die1: d1, die2: d2);
            totals[roll.total] = (totals[roll.total] ?? 0) + 1;
          }
        }
        // Total 2: 1 way (1+1)
        expect(totals[2], 1);
        // Total 7: 6 ways (1+6, 2+5, 3+4, 4+3, 5+2, 6+1)
        expect(totals[7], 6);
        // Total 12: 1 way (6+6)
        expect(totals[12], 1);
      });
    });
  });
}
