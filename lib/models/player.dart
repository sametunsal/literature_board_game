class Player {
  final String id;
  final String name;
  final String color;
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

  // Check if player owns a tile
  bool ownsTile(int tileId) {
    return ownedTiles.contains(tileId);
  }

  // Create a copy with updated values
  Player copyWith({
    String? id,
    String? name,
    String? color,
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
