/// Difficulty levels for questions and tiles
enum Difficulty { easy, medium, hard }

/// Extension to get display name for difficulty
extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Kolay';
      case Difficulty.medium:
        return 'Orta';
      case Difficulty.hard:
        return 'Zor';
    }
  }
}
