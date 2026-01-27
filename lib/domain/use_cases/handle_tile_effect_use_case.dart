/// Use case for handling tile effects.
/// Pure Dart - no Flutter dependencies.

import '../../core/constants/game_constants.dart';
import '../entities/board_tile.dart';
import '../entities/player.dart';
import '../entities/game_enums.dart';

class HandleTileEffectUseCase {
  TileAction determineTileAction(BoardTile tile, Player player) {
    return switch (tile.type) {
      TileType.property => TileActions.propertyInteraction(tile),
      TileType.chance || TileType.fate => TileActions.drawCard(tile.type),
      TileType.kiraathane => TileActions.openShop(),
      _ => TileActions.none(),
    };
  }

  /// Calculates the bankruptcy risk penalty (Stars).
  int calculateBankruptcyPenalty(Player player) {
    return (player.stars * GameConstants.bankruptcyRiskMultiplier).floor();
  }

  /// Checks if a tile is purchasable (Question interaction).
  bool isPurchasable(BoardTile tile) {
    return tile.type == TileType.property;
  }

  /// Checks if a tile requires a question before purchase.
  bool requiresQuestion(BoardTile tile) {
    return tile.category != null;
  }

  /// Checks if a tile is special (non-question).
  bool isUtility(BoardTile tile) {
    return tile.type != TileType.property;
  }

  /// Checks if a tile is upgradeable (Difficulty level).
  bool isUpgradeable(BoardTile tile) {
    return tile.type == TileType.property && tile.difficulty != Difficulty.hard;
  }

  /// Gets the tax amount for a tile (Not used in current RPG).
  int getTaxAmount(TileType type) {
    return 0;
  }
}

/// Represents the action to take when landing on a tile.
abstract class TileAction {
  const TileAction();
}

/// No action needed.
class NoneAction extends TileAction {
  const NoneAction();
}

/// Property interaction (purchase, rent, or upgrade).
class PropertyInteractionAction extends TileAction {
  final BoardTile tile;
  const PropertyInteractionAction(this.tile);
}

/// Open shop dialog (Kıraathane).
class OpenShopAction extends TileAction {
  const OpenShopAction();
}

/// Factory for creating tile actions.
class TileActions {
  TileActions._();

  static TileAction none() => const NoneAction();
  static TileAction propertyInteraction(BoardTile tile) =>
      PropertyInteractionAction(tile);
  static TileAction drawCard(TileType cardType) => DrawCardAction(cardType);
  static TileAction openShop() => const OpenShopAction();
}

class DrawCardAction extends TileAction {
  final TileType cardType;
  const DrawCardAction(this.cardType);
}
