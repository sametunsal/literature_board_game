import '../../models/book_level.dart';
import '../../models/book_ownership.dart';
import '../../models/player.dart';

class WinConditionService {
  const WinConditionService();

  static const int requiredOwnedBooks = 5;
  static const int requiredCiltBooks = 2;
  static const int requiredUstaCategories = 2;

  int ownedBookCount({
    required String playerId,
    required Map<String, BookOwnership> ownerships,
  }) {
    return ownerships.values
        .where((ownership) => ownership.ownerPlayerId == playerId)
        .length;
  }

  int ciltBookCount({
    required String playerId,
    required Map<String, BookOwnership> ownerships,
  }) {
    return ownerships.values
        .where(
          (ownership) =>
              ownership.ownerPlayerId == playerId &&
              ownership.level == BookLevel.cilt,
        )
        .length;
  }

  int ustaCategoryCount(Player player) => player.ustaCategoryCount;

  bool hasWon({
    required Player player,
    required Map<String, BookOwnership> ownerships,
  }) {
    return ownedBookCount(playerId: player.id, ownerships: ownerships) >=
            requiredOwnedBooks &&
        ciltBookCount(playerId: player.id, ownerships: ownerships) >=
            requiredCiltBooks &&
        ustaCategoryCount(player) >= requiredUstaCategories;
  }
}
