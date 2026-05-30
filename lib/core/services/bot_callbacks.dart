import '../../models/game_enums.dart';
import 'card_effect_service.dart';
import 'question_flow_service.dart';

enum BotDialogType {
  library,
  signingDay,
  shop,
}

class BotDialogSnapshot {
  final bool showQuestionDialog;
  final bool showCardDialog;
  final bool showLibraryPenaltyDialog;
  final bool showImzaGunuDialog;
  final bool showPrinterIssueDialog;
  final bool showTurnSkippedDialog;
  final bool showShopDialog;
  final bool showTurnOrderDialog;

  const BotDialogSnapshot({
    this.showQuestionDialog = false,
    this.showCardDialog = false,
    this.showLibraryPenaltyDialog = false,
    this.showImzaGunuDialog = false,
    this.showPrinterIssueDialog = false,
    this.showTurnSkippedDialog = false,
    this.showShopDialog = false,
    this.showTurnOrderDialog = false,
  });

  bool get isAnyDialogOpen =>
      showQuestionDialog ||
      showCardDialog ||
      showLibraryPenaltyDialog ||
      showImzaGunuDialog ||
      showPrinterIssueDialog ||
      showTurnSkippedDialog ||
      showShopDialog ||
      showTurnOrderDialog;
}

class BotCallbacks {
  final void Function() rollDice;
  final void Function() endTurn;
  final void Function(String message, {String type}) addLog;
  final void Function(AnswerResult result) applyAnswerResult;
  final void Function(CardEffectResult result) applyCardEffectResult;
  final void Function() checkWinCondition;
  final void Function() closeCardDialog;
  final void Function() closeLibraryPenaltyDialog;
  final void Function() closeImzaGunuDialog;
  final void Function() closePrinterIssueDialog;
  final void Function() closeShopDialog;
  final void Function() closeTurnOrderDialog;
  final void Function() closeTurnSkippedDialog;
  final void Function(bool isCorrect) answerQuestion;
  final BotDialogSnapshot Function() readDialogState;
  final bool Function() readIsDiceRolling;
  final bool Function() readIsProcessing;
  final void Function(bool value) setProcessing;
  final GamePhase Function() readGamePhase;

  const BotCallbacks({
    required this.rollDice,
    required this.endTurn,
    required this.addLog,
    required this.applyAnswerResult,
    required this.applyCardEffectResult,
    required this.checkWinCondition,
    required this.closeCardDialog,
    required this.closeLibraryPenaltyDialog,
    required this.closeImzaGunuDialog,
    required this.closePrinterIssueDialog,
    required this.closeShopDialog,
    required this.closeTurnOrderDialog,
    required this.closeTurnSkippedDialog,
    required this.answerQuestion,
    required this.readDialogState,
    required this.readIsDiceRolling,
    required this.readIsProcessing,
    required this.setProcessing,
    required this.readGamePhase,
  });
}
