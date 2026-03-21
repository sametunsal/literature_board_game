import 'dart:math';

/// Tek kaynak: iki D6 ve toplam. Animasyon ve oyun mantığı aynı değerleri kullanır.
abstract final class DiceRollValues {
  DiceRollValues._();

  static (int d1, int d2, int sum) roll(Random random) {
    final d1 = random.nextInt(6) + 1;
    final d2 = random.nextInt(6) + 1;
    return (d1, d2, d1 + d2);
  }
}
