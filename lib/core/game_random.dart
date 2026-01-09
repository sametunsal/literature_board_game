import 'dart:math';

/// Centralized random number generator for game-wide determinism
///
/// This singleton ensures all random operations use the same seeded instance,
/// making the game deterministic and testable.
class GameRandom {
  static final GameRandom instance = GameRandom._();
  late final Random random;

  GameRandom._() {
    random = Random(DateTime.now().millisecondsSinceEpoch);
  }

  /// Seed the random number generator for deterministic behavior
  /// Call this at game start to ensure reproducible results
  static void seed(int seed) {
    instance.random = Random(seed);
  }

  /// Get next random integer in range [0, max)
  static int nextInt(int max) {
    return instance.random.nextInt(max);
  }

  /// Get next random double in range [0.0, 1.0)
  static double nextDouble() {
    return instance.random.nextDouble();
  }

  /// Get next random boolean
  static bool nextBool() {
    return instance.random.nextBool();
  }
}
