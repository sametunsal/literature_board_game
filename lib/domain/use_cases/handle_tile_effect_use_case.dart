/// Use case for handling tile effects.
/// Pure Dart - no Flutter dependencies.

import '../../core/constants/game_constants.dart';
import '../entities/board_tile.dart';
import '../entities/player.dart';
import '../entities/game_enums.dart';

class HandleTileEffectUseCase {
  /// Determines the action to take when a player lands on a tile.
  TileAction determineTileAction(BoardTile tile, Player player) {
    switch (tile.type) {
      case TileType.property:
      case TileType.publisher:
      case TileType.writingSchool:
      case TileType.educationFoundation:
        return TileActions.propertyInteraction(tile);

      case TileType.chance:
      case TileType.fate:
        return TileActions.drawCard(tile.type);

      case TileType.libraryWatch:
        return TileActions.libraryPenalty();

      case TileType.autographDay:
        return TileActions.autographDay();

      case TileType.bankruptcyRisk:
        return TileActions.bankruptcyRisk();

      case TileType.incomeTax:
        return TileActions.incomeTax(GameConstants.incomeTax);

      case TileType.writingTax:
        return TileActions.writingTax(GameConstants.writingTax);

      case TileType.start:
        return TileActions.none();
    }
  }

  /// Calculates the bankruptcy risk penalty.
  int calculateBankruptcyPenalty(Player player) {
    return (player.balance * GameConstants.bankruptcyRiskMultiplier).floor();
  }

  /// Checks if a tile is purchasable.
  bool isPurchasable(BoardTile tile) {
    return tile.type == TileType.property ||
        tile.type == TileType.publisher ||
        tile.type == TileType.writingSchool ||
        tile.type == TileType.educationFoundation;
  }

  /// Checks if a tile requires a question before purchase.
  bool requiresQuestion(BoardTile tile) {
    return tile.category != null;
  }

  /// Checks if a tile is a utility.
  bool isUtility(BoardTile tile) {
    return tile.isUtility;
  }

  /// Checks if a tile is upgradeable.
  bool isUpgradeable(BoardTile tile) {
    return !tile.isUtility && tile.upgradeLevel < GameConstants.maxUpgradeLevel;
  }

  /// Gets the tax amount for a tile.
  int getTaxAmount(TileType type) {
    switch (type) {
      case TileType.incomeTax:
        return GameConstants.incomeTax;
      case TileType.writingTax:
        return GameConstants.writingTax;
      default:
        return 0;
    }
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

/// Draw a chance or fate card.
class DrawCardAction extends TileAction {
  final TileType cardType;
  const DrawCardAction(this.cardType);
}

/// Library penalty (jail).
class LibraryPenaltyAction extends TileAction {
  const LibraryPenaltyAction();
}

/// Autograph day (informative).
class AutographDayAction extends TileAction {
  const AutographDayAction();
}

/// Bankruptcy risk.
class BankruptcyRiskAction extends TileAction {
  const BankruptcyRiskAction();
}

/// Income tax.
class IncomeTaxAction extends TileAction {
  final int amount;
  const IncomeTaxAction(this.amount);
}

/// Writing tax.
class WritingTaxAction extends TileAction {
  final int amount;
  const WritingTaxAction(this.amount);
}

/// Factory for creating tile actions.
class TileActions {
  TileActions._();

  static TileAction none() => const NoneAction();
  static TileAction propertyInteraction(BoardTile tile) =>
      PropertyInteractionAction(tile);
  static TileAction drawCard(TileType cardType) => DrawCardAction(cardType);
  static TileAction libraryPenalty() => const LibraryPenaltyAction();
  static TileAction autographDay() => const AutographDayAction();
  static TileAction bankruptcyRisk() => const BankruptcyRiskAction();
  static TileAction incomeTax(int amount) => IncomeTaxAction(amount);
  static TileAction writingTax(int amount) => WritingTaxAction(amount);
}
