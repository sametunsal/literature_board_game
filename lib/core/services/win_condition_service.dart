import '../../models/book_level.dart';
import '../../models/book_ownership.dart';

class WinConditionService {
  const WinConditionService();

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
}
