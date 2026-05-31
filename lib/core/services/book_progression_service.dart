import '../../models/book.dart';
import '../../models/book_level.dart';
import '../../models/book_ownership.dart';
import '../../models/difficulty.dart';
import '../../models/player.dart';

enum BookProgressionActionType {
  noAction,
  acquiredTelif,
  upgradedToBaski,
  upgradedToCilt,
  failedUpgrade,
  insufficientAkce,
  alreadyCilt,
  opponentCorrectNoPayment,
  royaltyPaid,
}

class BookProgressionResult {
  final List<Player> updatedPlayers;
  final Map<String, BookOwnership> updatedOwnerships;
  final BookProgressionActionType actionType;
  final int akceDelta;
  final int royaltyPaid;
  final List<String> logs;

  const BookProgressionResult({
    required this.updatedPlayers,
    required this.updatedOwnerships,
    required this.actionType,
    this.akceDelta = 0,
    this.royaltyPaid = 0,
    this.logs = const [],
  });
}

class BookProgressionService {
  const BookProgressionService();

  static const int baskiUpgradeCostAkce = 5;
  static const int ciltUpgradeCostAkce = 10;

  BookProgressionResult apply({
    required Book book,
    required List<Player> players,
    required String currentPlayerId,
    required Map<String, BookOwnership> ownerships,
    required bool isCorrect,
    required Difficulty difficulty,
  }) {
    final currentPlayerIndex = players.indexWhere(
      (player) => player.id == currentPlayerId,
    );
    if (currentPlayerIndex < 0) {
      return BookProgressionResult(
        updatedPlayers: List<Player>.from(players),
        updatedOwnerships: Map<String, BookOwnership>.from(ownerships),
        actionType: BookProgressionActionType.noAction,
        logs: ['Oyuncu bulunamadı.'],
      );
    }

    final ownership = ownerships[book.id];
    if (ownership == null) {
      return _handleUnownedBook(
        book: book,
        players: players,
        currentPlayerIndex: currentPlayerIndex,
        ownerships: ownerships,
        isCorrect: isCorrect,
      );
    }

    if (ownership.ownerPlayerId == currentPlayerId) {
      return _handleOwnBook(
        book: book,
        players: players,
        currentPlayerIndex: currentPlayerIndex,
        ownerships: ownerships,
        ownership: ownership,
        isCorrect: isCorrect,
        difficulty: difficulty,
      );
    }

    return _handleOpponentOwnedBook(
      book: book,
      players: players,
      currentPlayerIndex: currentPlayerIndex,
      ownerships: ownerships,
      ownership: ownership,
      isCorrect: isCorrect,
    );
  }

  BookProgressionResult _handleUnownedBook({
    required Book book,
    required List<Player> players,
    required int currentPlayerIndex,
    required Map<String, BookOwnership> ownerships,
    required bool isCorrect,
  }) {
    final updatedOwnerships = Map<String, BookOwnership>.from(ownerships);
    if (!isCorrect) {
      return BookProgressionResult(
        updatedPlayers: List<Player>.from(players),
        updatedOwnerships: updatedOwnerships,
        actionType: BookProgressionActionType.noAction,
        logs: ['Yanlış cevap: telif alınamadı.'],
      );
    }

    final currentPlayer = players[currentPlayerIndex];
    updatedOwnerships[book.id] = BookOwnership(
      bookId: book.id,
      ownerPlayerId: currentPlayer.id,
      level: BookLevel.telif,
    );

    return BookProgressionResult(
      updatedPlayers: List<Player>.from(players),
      updatedOwnerships: updatedOwnerships,
      actionType: BookProgressionActionType.acquiredTelif,
      logs: ['${book.title} telifi alındı.'],
    );
  }

  BookProgressionResult _handleOwnBook({
    required Book book,
    required List<Player> players,
    required int currentPlayerIndex,
    required Map<String, BookOwnership> ownerships,
    required BookOwnership ownership,
    required bool isCorrect,
    required Difficulty difficulty,
  }) {
    return switch (ownership.level) {
      BookLevel.none => _handleUnownedBook(
        book: book,
        players: players,
        currentPlayerIndex: currentPlayerIndex,
        ownerships: ownerships,
        isCorrect: isCorrect,
      ),
      BookLevel.telif => _attemptUpgrade(
        book: book,
        players: players,
        currentPlayerIndex: currentPlayerIndex,
        ownerships: ownerships,
        ownership: ownership,
        costAkce: baskiUpgradeCostAkce,
        targetLevel: BookLevel.baski,
        canUpgrade: isCorrect,
        successAction: BookProgressionActionType.upgradedToBaski,
        successLog: '${book.title} Baskı seviyesine yükseldi.',
      ),
      BookLevel.baski => _attemptUpgrade(
        book: book,
        players: players,
        currentPlayerIndex: currentPlayerIndex,
        ownerships: ownerships,
        ownership: ownership,
        costAkce: ciltUpgradeCostAkce,
        targetLevel: BookLevel.cilt,
        canUpgrade:
            isCorrect &&
            difficulty == Difficulty.hard &&
            players[currentPlayerIndex]
                    .getMasteryLevel(book.category.name)
                    .value >=
                MasteryLevel.kalfa.value,
        successAction: BookProgressionActionType.upgradedToCilt,
        successLog: '${book.title} Cilt seviyesine yükseldi.',
      ),
      BookLevel.cilt => BookProgressionResult(
        updatedPlayers: List<Player>.from(players),
        updatedOwnerships: Map<String, BookOwnership>.from(ownerships),
        actionType: BookProgressionActionType.alreadyCilt,
        logs: ['${book.title} zaten Cilt seviyesinde.'],
      ),
    };
  }

  BookProgressionResult _attemptUpgrade({
    required Book book,
    required List<Player> players,
    required int currentPlayerIndex,
    required Map<String, BookOwnership> ownerships,
    required BookOwnership ownership,
    required int costAkce,
    required BookLevel targetLevel,
    required bool canUpgrade,
    required BookProgressionActionType successAction,
    required String successLog,
  }) {
    final currentPlayer = players[currentPlayerIndex];
    final updatedOwnerships = Map<String, BookOwnership>.from(ownerships);

    if (currentPlayer.akce < costAkce) {
      return BookProgressionResult(
        updatedPlayers: List<Player>.from(players),
        updatedOwnerships: updatedOwnerships,
        actionType: BookProgressionActionType.insufficientAkce,
        logs: ['Yetersiz Akçe: yükseltme denenmedi.'],
      );
    }

    final updatedPlayers = List<Player>.from(players);
    updatedPlayers[currentPlayerIndex] = currentPlayer.withAkce(
      currentPlayer.akce - costAkce,
    );

    if (!canUpgrade) {
      return BookProgressionResult(
        updatedPlayers: updatedPlayers,
        updatedOwnerships: updatedOwnerships,
        actionType: BookProgressionActionType.failedUpgrade,
        akceDelta: -costAkce,
        logs: ['Yükseltme başarısız oldu.'],
      );
    }

    updatedOwnerships[book.id] = ownership.copyWith(level: targetLevel);
    return BookProgressionResult(
      updatedPlayers: updatedPlayers,
      updatedOwnerships: updatedOwnerships,
      actionType: successAction,
      akceDelta: -costAkce,
      logs: [successLog],
    );
  }

  BookProgressionResult _handleOpponentOwnedBook({
    required Book book,
    required List<Player> players,
    required int currentPlayerIndex,
    required Map<String, BookOwnership> ownerships,
    required BookOwnership ownership,
    required bool isCorrect,
  }) {
    if (isCorrect) {
      return BookProgressionResult(
        updatedPlayers: List<Player>.from(players),
        updatedOwnerships: Map<String, BookOwnership>.from(ownerships),
        actionType: BookProgressionActionType.opponentCorrectNoPayment,
        logs: ['Doğru cevap: telif ödemesi yok.'],
      );
    }

    final ownerIndex = players.indexWhere(
      (player) => player.id == ownership.ownerPlayerId,
    );
    if (ownerIndex < 0) {
      return BookProgressionResult(
        updatedPlayers: List<Player>.from(players),
        updatedOwnerships: Map<String, BookOwnership>.from(ownerships),
        actionType: BookProgressionActionType.noAction,
        logs: ['Kitap sahibi bulunamadı.'],
      );
    }

    final payer = players[currentPlayerIndex];
    final owner = players[ownerIndex];
    final royalty = _royaltyFor(ownership.level);
    final paid = payer.akce < royalty ? payer.akce : royalty;

    final updatedPlayers = List<Player>.from(players);
    updatedPlayers[currentPlayerIndex] = payer.withAkce(payer.akce - paid);
    updatedPlayers[ownerIndex] = owner.withAkce(owner.akce + paid);

    return BookProgressionResult(
      updatedPlayers: updatedPlayers,
      updatedOwnerships: Map<String, BookOwnership>.from(ownerships),
      actionType: BookProgressionActionType.royaltyPaid,
      akceDelta: -paid,
      royaltyPaid: paid,
      logs: ['${book.title} için $paid Akçe telif ödendi.'],
    );
  }

  int _royaltyFor(BookLevel level) {
    return switch (level) {
      BookLevel.none => 0,
      BookLevel.telif => 1,
      BookLevel.baski => 2,
      BookLevel.cilt => 3,
    };
  }
}
