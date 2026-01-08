import '../models/player.dart';
import '../models/card.dart';
import '../models/turn_phase.dart';
import '../models/tile.dart';
import '../constants/game_constants.dart';
import 'game_state_manager.dart';
import 'game_rules_engine.dart';

/// Kart efektlerinin mantığını ve uygulamasını yönetir
class CardEffectHandler {
  final GameStateManager stateManager;
  final GameRulesEngine rulesEngine;

  CardEffectHandler({required this.stateManager, required this.rulesEngine});

  /// Ana giriş noktası: Kart efektini uygula
  void applyCardEffect(Card card, Player currentPlayer) {
    bool isPersonal = false;
    bool isGlobal = false;
    String logMessage = '';

    try {
      switch (card.effect) {
        // --- KİŞİSEL EFEKTLER ---
        case CardEffect.gainStars:
          _applyGainStars(currentPlayer, card.starAmount ?? 0);
          isPersonal = true;
          logMessage =
              '${currentPlayer.name}: +${card.starAmount ?? 0} yıldız kazandı';
          break;

        case CardEffect.loseStars:
          _applyLoseStars(currentPlayer, card.starAmount ?? 0);
          isPersonal = true;
          logMessage =
              '${currentPlayer.name}: -${card.starAmount ?? 0} yıldız kaybetti';
          break;

        case CardEffect.skipNextTax:
          _applySkipNextTax(currentPlayer);
          isPersonal = true;
          logMessage =
              '${currentPlayer.name}: Bir sonraki vergi ödemesi atlanacak';
          break;

        case CardEffect.freeTurn:
          _applyFreeTurn(currentPlayer);
          isPersonal = true;
          logMessage = '${currentPlayer.name}: Ücretsiz tur hakkı kazandı';
          break;

        case CardEffect.easyQuestionNext:
          _applyEasyQuestionNext(currentPlayer);
          isPersonal = true;
          logMessage = '${currentPlayer.name}: Bir sonraki soru kolay olacak';
          break;

        // --- GLOBAL EFEKTLER ---
        case CardEffect.allPlayersGainStars:
          _applyAllPlayersGainStars(card.starAmount ?? 0);
          isGlobal = true;
          logMessage = 'Tüm oyuncular: +${card.starAmount ?? 0} yıldız kazandı';
          break;

        case CardEffect.allPlayersLoseStars:
          _applyAllPlayersLoseStars(card.starAmount ?? 0);
          isGlobal = true;
          logMessage =
              'Tüm oyuncular: -${card.starAmount ?? 0} yıldız kaybetti';
          break;

        case CardEffect.taxWaiver:
          _applyTaxWaiver();
          isGlobal = true;
          logMessage = 'Tüm oyuncular: Bir sonraki vergi ödemesi atlanacak';
          break;

        case CardEffect.allPlayersEasyQuestion:
          _applyAllPlayersEasyQuestion();
          isGlobal = true;
          logMessage = 'Tüm oyuncular: Bir sonraki soru kolay olacak';
          break;

        // --- HEDEF ODAKLI EFEKTLER ---
        case CardEffect.publisherOwnersLose:
          final count = _applyPublisherOwnersLose(card.starAmount ?? 0);
          isGlobal = true;
          logMessage =
              'Yayınevi sahipleri ($count oyuncu): -${card.starAmount ?? 0} yıldız kaybetti';
          break;

        case CardEffect.richPlayerPays:
          final name = _applyRichPlayerPays(card.starAmount ?? 0);
          isGlobal = true;
          logMessage =
              '$name (en zengin): -${card.starAmount ?? 0} yıldız ödedi';
          break;
      }

      // Log ekle
      stateManager.addLogMessage(logMessage);

      // İflas Kontrolleri
      if (isPersonal) {
        _checkBankruptcyForPlayer(stateManager.state.currentPlayer!);
      } else if (isGlobal) {
        _checkAllPlayersBankruptcy();
      }
    } catch (e) {
      stateManager.addLogMessage("Kart hatası: $e");
    } finally {
      // Kartı temizle ve fazı güncelle (Atomik işlem)
      stateManager.setCurrentCard(null, null);
      stateManager.setTurnPhase(TurnPhase.cardApplied);
    }
  }

  // --- YARDIMCI METODLAR ---

  void _applyGainStars(Player player, int amount) {
    stateManager.updatePlayer(player.copyWith(stars: player.stars + amount));
  }

  void _applyLoseStars(Player player, int amount) {
    final newStars = (player.stars - amount).clamp(0, player.stars);
    // İflas kontrolü logic içinde yapılmalı ama şimdilik state güncellemesi:
    stateManager.updatePlayer(player.copyWith(stars: newStars));
  }

  void _applySkipNextTax(Player player) {
    stateManager.updatePlayer(player.copyWith(skipNextTax: true));
  }

  void _applyFreeTurn(Player player) {
    stateManager.updatePlayer(player.copyWith(skippedTurn: false));
  }

  void _applyEasyQuestionNext(Player player) {
    stateManager.updatePlayer(player.copyWith(easyQuestionNext: true));
  }

  void _applyAllPlayersGainStars(int amount) {
    // State'teki oyuncu listesi üzerinde işlem yap
    for (var p in stateManager.state.players) {
      stateManager.updatePlayer(p.copyWith(stars: p.stars + amount));
    }
  }

  void _applyAllPlayersLoseStars(int amount) {
    for (var p in stateManager.state.players) {
      final newStars = (p.stars - amount).clamp(0, 9999);
      stateManager.updatePlayer(p.copyWith(stars: newStars));
    }
  }

  void _applyTaxWaiver() {
    for (var p in stateManager.state.players) {
      stateManager.updatePlayer(p.copyWith(skipNextTax: true));
    }
  }

  void _applyAllPlayersEasyQuestion() {
    for (var p in stateManager.state.players) {
      stateManager.updatePlayer(p.copyWith(easyQuestionNext: true));
    }
  }

  int _applyPublisherOwnersLose(int amount) {
    int count = 0;
    // Tile verisine ihtiyacımız var, state'den okuyoruz
    final tiles = stateManager.state.tiles;

    for (var p in stateManager.state.players) {
      bool hasPublisher = tiles.any(
        (t) => t.owner == p.id && t.type == TileType.publisher,
      );
      if (hasPublisher) {
        final newStars = (p.stars - amount).clamp(0, 9999);
        stateManager.updatePlayer(p.copyWith(stars: newStars));
        count++;
      }
    }
    return count;
  }

  String _applyRichPlayerPays(int amount) {
    if (stateManager.state.players.isEmpty) return '';

    // En zengini bul
    final richest = stateManager.state.players.reduce(
      (curr, next) => curr.stars > next.stars ? curr : next,
    );

    final newStars = (richest.stars - amount).clamp(0, richest.stars);
    stateManager.updatePlayer(richest.copyWith(stars: newStars));

    return richest.name;
  }

  // --- İFLAS KONTROLLERİ (Local) ---

  void _checkBankruptcyForPlayer(Player p) {
    if (rulesEngine.isBankrupt(p, GameConstants.bankruptcyThreshold)) {
      stateManager.updatePlayer(p.copyWith(isBankrupt: true));
      stateManager.addLogMessage('${p.name} İFLAS OLDU!');
    }
  }

  void _checkAllPlayersBankruptcy() {
    for (var p in stateManager.state.players) {
      if (!p.isBankrupt &&
          rulesEngine.isBankrupt(p, GameConstants.bankruptcyThreshold)) {
        stateManager.updatePlayer(p.copyWith(isBankrupt: true));
        stateManager.addLogMessage('${p.name} İFLAS OLDU!');
      }
    }
  }
}
