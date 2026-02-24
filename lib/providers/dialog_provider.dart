import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../models/game_card.dart';

/// Represents the global visibility state of UI dialogs
/// separated from GameState to prevent full 3D board rebuilds on UI overlays.
class DialogState {
  final Question? currentQuestion;
  final GameCard? currentCard;

  final bool showQuestionDialog;
  final bool showCardDialog;
  final bool showLibraryPenaltyDialog;
  final bool showImzaGunuDialog;
  final bool showTurnSkippedDialog;
  final bool showShopDialog;
  final bool showTurnOrderDialog;

  const DialogState({
    this.currentQuestion,
    this.currentCard,
    this.showQuestionDialog = false,
    this.showCardDialog = false,
    this.showLibraryPenaltyDialog = false,
    this.showImzaGunuDialog = false,
    this.showTurnSkippedDialog = false,
    this.showShopDialog = false,
    this.showTurnOrderDialog = false,
  });

  DialogState copyWith({
    Question? currentQuestion,
    GameCard? currentCard,
    bool? showQuestionDialog,
    bool? showCardDialog,
    bool? showLibraryPenaltyDialog,
    bool? showImzaGunuDialog,
    bool? showTurnSkippedDialog,
    bool? showShopDialog,
    bool? showTurnOrderDialog,
    bool clearQuestion = false,
    bool clearCard = false,
  }) {
    return DialogState(
      currentQuestion: clearQuestion
          ? null
          : (currentQuestion ?? this.currentQuestion),
      currentCard: clearCard ? null : (currentCard ?? this.currentCard),
      showQuestionDialog: showQuestionDialog ?? this.showQuestionDialog,
      showCardDialog: showCardDialog ?? this.showCardDialog,
      showLibraryPenaltyDialog:
          showLibraryPenaltyDialog ?? this.showLibraryPenaltyDialog,
      showImzaGunuDialog: showImzaGunuDialog ?? this.showImzaGunuDialog,
      showTurnSkippedDialog:
          showTurnSkippedDialog ?? this.showTurnSkippedDialog,
      showShopDialog: showShopDialog ?? this.showShopDialog,
      showTurnOrderDialog: showTurnOrderDialog ?? this.showTurnOrderDialog,
    );
  }

  /// Clears all dialog visibility flags, leaving content intact (usually overwritten by `clearAll()`)
  DialogState clearVisibility() {
    return copyWith(
      showQuestionDialog: false,
      showCardDialog: false,
      showLibraryPenaltyDialog: false,
      showImzaGunuDialog: false,
      showTurnSkippedDialog: false,
      showShopDialog: false,
      showTurnOrderDialog: false,
    );
  }

  /// Helper flag to know if ANY overlay is active
  bool get isAnyDialogOpen =>
      showQuestionDialog ||
      showCardDialog ||
      showLibraryPenaltyDialog ||
      showImzaGunuDialog ||
      showTurnSkippedDialog ||
      showShopDialog ||
      showTurnOrderDialog;
}

class DialogNotifier extends StateNotifier<DialogState> {
  DialogNotifier() : super(const DialogState());

  // --- Show Methods ---

  void showQuestion(Question question) {
    state = state.clearVisibility().copyWith(
      showQuestionDialog: true,
      currentQuestion: question,
    );
  }

  void showCard(GameCard card) {
    state = state.clearVisibility().copyWith(
      showCardDialog: true,
      currentCard: card,
    );
  }

  void showLibraryPenalty() {
    state = state.clearVisibility().copyWith(showLibraryPenaltyDialog: true);
  }

  void showImzaGunu() {
    state = state.clearVisibility().copyWith(showImzaGunuDialog: true);
  }

  void showTurnSkipped() {
    state = state.clearVisibility().copyWith(showTurnSkippedDialog: true);
  }

  void showShop() {
    state = state.clearVisibility().copyWith(showShopDialog: true);
  }

  void showTurnOrder() {
    state = state.clearVisibility().copyWith(showTurnOrderDialog: true);
  }

  // --- Hide Methods ---

  void hideQuestion() {
    state = state.copyWith(showQuestionDialog: false, clearQuestion: true);
  }

  void hideCard() {
    state = state.copyWith(showCardDialog: false, clearCard: true);
  }

  void hideLibraryPenalty() {
    state = state.copyWith(showLibraryPenaltyDialog: false);
  }

  void hideImzaGunu() {
    state = state.copyWith(showImzaGunuDialog: false);
  }

  void hideTurnSkipped() {
    state = state.copyWith(showTurnSkippedDialog: false);
  }

  void hideShop() {
    state = state.copyWith(showShopDialog: false);
  }

  void hideTurnOrder() {
    state = state.copyWith(showTurnOrderDialog: false);
  }

  /// Clears all dialogs and resets their mapped content securely
  void clearAll() {
    state = const DialogState();
  }
}

/// Global provider for DialogState
final dialogProvider = StateNotifierProvider<DialogNotifier, DialogState>((
  ref,
) {
  return DialogNotifier();
});
