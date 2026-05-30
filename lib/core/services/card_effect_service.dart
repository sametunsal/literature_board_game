import '../../data/board_config.dart';
import '../../core/constants/game_constants.dart';
import '../../models/game_card.dart';
import '../../models/player.dart';
import 'economy_service.dart';

class LogEntry {
  final String message;
  final String type;
  const LogEntry(this.message, {this.type = 'info'});
}

class CardEffectResult {
  final List<Player> updatedPlayers;
  final List<LogEntry> logs;
  final bool movementOccurred;
  final bool rollAgain;
  final bool showPrinterIssue;
  final bool showFloatingEffect;
  final int? starsDelta;

  const CardEffectResult({
    required this.updatedPlayers,
    this.logs = const [],
    this.movementOccurred = false,
    this.rollAgain = false,
    this.showPrinterIssue = false,
    this.showFloatingEffect = false,
    this.starsDelta,
  });
}

class CardEffectService {
  final EconomyService _economyService;

  const CardEffectService(this._economyService);

  CardEffectResult apply({
    required GameCard card,
    required List<Player> players,
    required int currentPlayerIndex,
    bool isBot = false,
  }) {
    final player = players[currentPlayerIndex];
    final prefix = isBot ? '🤖 Bot: ' : '';

    switch (card.effectType) {
      case CardEffectType.moneyChange:
        return _applyMoneyChange(card, players, currentPlayerIndex, prefix);
      case CardEffectType.move:
        return _applyMove(card, players, currentPlayerIndex, prefix);
      case CardEffectType.moveRelative:
        return _applyMoveRelative(card, players, currentPlayerIndex, prefix);
      case CardEffectType.jail:
        return _applyJail(players, currentPlayerIndex, prefix);
      case CardEffectType.skipTurn:
        return _applySkipTurn(card, players, currentPlayerIndex, prefix);
      case CardEffectType.rollAgain:
        return CardEffectResult(
          updatedPlayers: List.from(players),
          logs: [LogEntry('$prefix🎲 ${player.name} tekrar zar atıyor!', type: 'info')],
          rollAgain: true,
        );
      case CardEffectType.loseStarsPercentage:
        return _applyLoseStarsPercentage(card, players, currentPlayerIndex, prefix);
      case CardEffectType.globalMoney:
        return _applyGlobalMoney(card, players, currentPlayerIndex, prefix);
    }
  }

  CardEffectResult _applyMoneyChange(
    GameCard card,
    List<Player> players,
    int currentPlayerIndex,
    String prefix,
  ) {
    final player = players[currentPlayerIndex];
    final originalStars = player.stars;
    final rawNewStars = player.stars + card.value;
    final newStars = rawNewStars.clamp(0, double.infinity).toInt();
    final List<Player> updated = List.from(players);
    final List<LogEntry> logs = [];

    if (card.value < 0 && rawNewStars < 0) {
      updated[currentPlayerIndex] = player.copyWith(
        stars: newStars,
        turnsToSkip: player.turnsToSkip + 1,
      );
      logs.add(LogEntry(
        "$prefix⚠️ ${player.name} ödeyemedi! Yıldızlar 0'a düştü + 1 tur ceza!",
        type: 'error',
      ));
      return CardEffectResult(
        updatedPlayers: updated,
        logs: logs,
        starsDelta: newStars - originalStars,
      );
    }

    updated[currentPlayerIndex] = player.copyWith(stars: newStars);
    final delta = newStars - originalStars;

    if (card.value > 0) {
      logs.add(LogEntry(
        '$prefix💰 ${player.name} +${card.value} yıldız kazandı!',
        type: 'success',
      ));
    } else {
      final lost = originalStars - newStars;
      logs.add(LogEntry(
        '$prefix💸 ${player.name} $lost yıldız kaybetti!',
        type: 'error',
      ));
    }

    return CardEffectResult(
      updatedPlayers: updated,
      logs: logs,
      starsDelta: delta,
      showFloatingEffect: true,
    );
  }

  CardEffectResult _applyMove(
    GameCard card,
    List<Player> players,
    int currentPlayerIndex,
    String prefix,
  ) {
    final player = players[currentPlayerIndex];
    final int targetPos = card.value % BoardConfig.boardSize;
    final bool passedStart = targetPos < player.position;
    final List<Player> updated = List.from(players);
    final List<LogEntry> logs = [];
    int newStars = player.stars;

    if (passedStart && targetPos != BoardConfig.startPosition) {
      newStars += GameConstants.passingStartBonus;
      logs.add(LogEntry(
        '$prefix🏁 Başlangıçtan geçtin: +${GameConstants.passingStartBonus} Yıldız!',
        type: 'success',
      ));
    }

    updated[currentPlayerIndex] = player.copyWith(
      position: targetPos,
      stars: newStars,
    );
    logs.add(LogEntry('$prefix🏯 ${player.name} $targetPos. kareye taşındı!'));

    return CardEffectResult(
      updatedPlayers: updated,
      logs: logs,
      movementOccurred: true,
      starsDelta: newStars - player.stars,
    );
  }

  CardEffectResult _applyMoveRelative(
    GameCard card,
    List<Player> players,
    int currentPlayerIndex,
    String prefix,
  ) {
    final player = players[currentPlayerIndex];
    final int currentPos = player.position;
    int targetPos = (currentPos + card.value) % BoardConfig.boardSize;
    if (targetPos < 0) targetPos += BoardConfig.boardSize;

    final List<Player> updated = List.from(players);
    final List<LogEntry> logs = [];
    int newStars = player.stars;

    if (card.value > 0 && targetPos < currentPos) {
      newStars += GameConstants.passingStartBonus;
      logs.add(LogEntry(
        '$prefix🏁 Başlangıçtan geçtin: +${GameConstants.passingStartBonus} Yıldız!',
        type: 'success',
      ));
    }

    updated[currentPlayerIndex] = player.copyWith(
      position: targetPos,
      stars: newStars,
    );

    if (card.value > 0) {
      logs.add(LogEntry('$prefix➡️ ${player.name} $targetPos. kareye ilerledi!'));
    } else {
      logs.add(LogEntry('$prefix⬅️ ${player.name} $targetPos. kareye geri gitti!'));
    }

    return CardEffectResult(
      updatedPlayers: updated,
      logs: logs,
      movementOccurred: true,
      starsDelta: newStars - player.stars,
    );
  }

  CardEffectResult _applyJail(
    List<Player> players,
    int currentPlayerIndex,
    String prefix,
  ) {
    final player = players[currentPlayerIndex];
    final List<Player> updated = List.from(players);

    updated[currentPlayerIndex] = player.copyWith(
      position: BoardConfig.shopPosition,
      turnsToSkip: GameConstants.jailTurns,
    );

    return CardEffectResult(
      updatedPlayers: updated,
      logs: [LogEntry(
        '$prefix⛓ ${player.name} kütüphane nöbetine yollandı!',
        type: 'error',
      )],
      movementOccurred: true,
    );
  }

  CardEffectResult _applySkipTurn(
    GameCard card,
    List<Player> players,
    int currentPlayerIndex,
    String prefix,
  ) {
    final player = players[currentPlayerIndex];
    final isPrinterIssue =
        card.description.contains('Mürekkep') ||
        card.description.contains('Yazıcı');

    if (isPrinterIssue) {
      return CardEffectResult(
        updatedPlayers: List.from(players),
        logs: [LogEntry(
          '$prefix▪️ ${player.name} yazıcı sorunuyla karşılaştı!',
          type: 'error',
        )],
        showPrinterIssue: true,
      );
    }

    final List<Player> updated = List.from(players);
    updated[currentPlayerIndex] = player.copyWith(
      turnsToSkip: player.turnsToSkip + card.value,
    );

    return CardEffectResult(
      updatedPlayers: updated,
      logs: [LogEntry(
        '$prefix⏸️ ${player.name} ${card.value} tur ceza aldı!',
        type: 'error',
      )],
    );
  }

  CardEffectResult _applyLoseStarsPercentage(
    GameCard card,
    List<Player> players,
    int currentPlayerIndex,
    String prefix,
  ) {
    final player = players[currentPlayerIndex];
    final percentage = _economyService.applyPercentLossCap(
      requestedPercent: card.value,
    );
    final loss = (player.stars * percentage / 100).round();
    final newStars = _economyService.normalizeTransferFloor(
      currentStars: player.stars,
      delta: -loss,
    );

    final List<Player> updated = List.from(players);
    updated[currentPlayerIndex] = player.copyWith(stars: newStars);

    return CardEffectResult(
      updatedPlayers: updated,
      logs: [LogEntry(
        "$prefix📉 ${player.name} yıldızlarının %%$percentage'ini kaybetti! (-$loss ⭐)",
        type: 'error',
      )],
      starsDelta: newStars - player.stars,
      showFloatingEffect: true,
    );
  }

  CardEffectResult _applyGlobalMoney(
    GameCard card,
    List<Player> players,
    int currentPlayerIndex,
    String prefix,
  ) {
    final player = players[currentPlayerIndex];
    final List<Player> updated = List.from(players);
    int totalTransfer = 0;

    for (int i = 0; i < updated.length; i++) {
      if (i != currentPlayerIndex) {
        if (card.value > 0) {
          int amount = card.value;
          if (updated[i].stars < amount) {
            amount = updated[i].stars > 0 ? updated[i].stars : 0;
          }
          updated[i] = updated[i].copyWith(
            stars: updated[i].stars - amount,
          );
          totalTransfer += amount;
        } else {
          int amount = -card.value;
          updated[i] = updated[i].copyWith(
            stars: updated[i].stars + amount,
          );
          totalTransfer += amount;
        }
      }
    }

    final int finalStars = card.value > 0
        ? player.stars + totalTransfer
        : player.stars - totalTransfer;
    updated[currentPlayerIndex] = updated[currentPlayerIndex].copyWith(
      stars: finalStars,
    );

    final List<LogEntry> logs = [];
    if (card.value > 0) {
      logs.add(LogEntry(
        '$prefix🏆 ${player.name} herkesten toplam $totalTransfer ⭐ aldı!',
        type: 'success',
      ));
    } else {
      logs.add(LogEntry(
        '$prefix💸 ${player.name} herkese toplam $totalTransfer ⭐ ödedi!',
        type: 'error',
      ));
    }

    return CardEffectResult(
      updatedPlayers: updated,
      logs: logs,
      starsDelta: finalStars - player.stars,
    );
  }
}
