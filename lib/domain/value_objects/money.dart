/// Value object for game currency.
/// Pure Dart - no Flutter dependencies.
library;

class Money {
  final int value;

  const Money(this.value);

  /// Creates a Money object with zero value.
  const Money.zero() : value = 0;

  /// Creates a Money object with the default starting balance.
  const Money.startingBalance() : value = 2500;

  /// Adds another Money object to this one.
  Money add(Money other) {
    return Money(value + other.value);
  }

  /// Subtracts another Money object from this one.
  Money subtract(Money other) {
    return Money(value - other.value);
  }

  /// Multiplies this Money by a factor.
  Money multiply(double factor) {
    return Money((value * factor).round());
  }

  /// Returns true if this Money is negative.
  bool get isNegative => value < 0;

  /// Returns true if this Money is zero.
  bool get isZero => value == 0;

  /// Returns true if this Money is positive.
  bool get isPositive => value > 0;

  /// Returns the absolute value of this Money.
  Money get abs => Money(value.abs());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Money && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '$value';

  /// Returns a formatted string with currency symbol.
  String formatted() => '$value Puan';
}
