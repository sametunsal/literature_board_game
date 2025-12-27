import 'player_type.dart';

class Player {
  final String id;
  final String name;
  final String color;
  final PlayerType type;
  int stars;
  int position;
  final List<int> ownedTiles;
  bool isInLibraryWatch;
  int libraryWatchTurnsRemaining;
  int doubleDiceCount;
  bool isBankrupt;
  bool skippedTurn;
  bool skipNextTax;
  bool easyQuestionNext;
  int? lastRoll;

  Player({
    required this.id,
    required this.name,
    required this.color,
    this.type = PlayerType.human,
    this.stars = 150,
    this.position = 1,
    this.ownedTiles = const [],
    this.isInLibraryWatch = false,
    this.libraryWatchTurnsRemaining = 0,
    this.doubleDiceCount = 0,
    this.isBankrupt = false,
    this.skippedTurn = false,
    this.skipNextTax = false,
    this.easyQuestionNext = false,
    this.lastRoll,
  });

  // Check if player can take a turn
  bool get canPlay => !isBankrupt && !isInLibraryWatch && !skippedTurn;

  // Check if player is in a penalty state
  bool get inPenalty => isInLibraryWatch || skippedTurn;

  // Calculate total copyright value owned
  int get totalCopyrightValue {
    // This would be calculated from tiles owned
    // Placeholder for implementation
    return 0;
  }

  // Apply library watch penalty
  void enterLibraryWatch() {
    isInLibraryWatch = true;
    libraryWatchTurnsRemaining = 2;
    position = 11; // Teleport to KÜTÜPHANE NÖBETİ
    doubleDiceCount = 0; // Reset double dice count
  }

  // Decrement library watch turns
  void decrementLibraryWatchTurns() {
    if (isInLibraryWatch) {
      libraryWatchTurnsRemaining--;
      if (libraryWatchTurnsRemaining <= 0) {
        isInLibraryWatch = false;
        libraryWatchTurnsRemaining = 0;
      }
    }
  }

  // Increment double dice count
  void incrementDoubleCount() {
    doubleDiceCount++;
    if (doubleDiceCount >= 3) {
      enterLibraryWatch();
    }
  }

  // Reset double dice count
  void resetDoubleCount() {
    doubleDiceCount = 0;
  }

  // Add stars
  void addStars(int amount) {
    stars += amount;
  }

  // Remove stars
  void removeStars(int amount) {
    stars -= amount;
    if (stars <= 0) {
      stars = 0;
      isBankrupt = true;
    }
  }

  // Lose percentage of stars
  void losePercentageOfStars(int percentage) {
    int loss = (stars * percentage) ~/ 100;
    removeStars(loss);
  }

  // Add owned tile
  void addOwnedTile(int tileId) {
    if (!ownedTiles.contains(tileId)) {
      ownedTiles.add(tileId);
    }
  }

  // Check if player owns a tile
  bool ownsTile(int tileId) {
    return ownedTiles.contains(tileId);
  }

  // Mark turn as skipped
  void markTurnSkipped() {
    skippedTurn = true;
  }

  // Reset skipped turn flag
  void resetSkippedTurn() {
    skippedTurn = false;
  }

  // Mark as bankrupt
  void declareBankrupt() {
    isBankrupt = true;
    stars = 0;
  }

  // Create a copy with updated values
  Player copyWith({
    String? id,
    String? name,
    String? color,
    PlayerType? type,
    int? stars,
    int? position,
    List<int>? ownedTiles,
    bool? isInLibraryWatch,
    int? libraryWatchTurnsRemaining,
    int? doubleDiceCount,
    bool? isBankrupt,
    bool? skippedTurn,
    bool? skipNextTax,
    bool? easyQuestionNext,
    int? lastRoll,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      type: type ?? this.type,
      stars: stars ?? this.stars,
      position: position ?? this.position,
      ownedTiles: ownedTiles ?? List.from(this.ownedTiles),
      isInLibraryWatch: isInLibraryWatch ?? this.isInLibraryWatch,
      libraryWatchTurnsRemaining:
          libraryWatchTurnsRemaining ?? this.libraryWatchTurnsRemaining,
      doubleDiceCount: doubleDiceCount ?? this.doubleDiceCount,
      isBankrupt: isBankrupt ?? this.isBankrupt,
      skippedTurn: skippedTurn ?? this.skippedTurn,
      skipNextTax: skipNextTax ?? this.skipNextTax,
      easyQuestionNext: easyQuestionNext ?? this.easyQuestionNext,
      lastRoll: lastRoll ?? this.lastRoll,
    );
  }
}
