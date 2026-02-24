import 'dart:io';

void main() {
  final file = File('lib/providers/game_notifier.dart');
  var content = file.readAsStringSync();

  // Replace Dialog Show Methods
  content = content.replaceAll(RegExp(r'state\s*=\s*state\.copyWith\([^()]*showTurnSkippedDialog:\s*true[^()]*\);'), 'ref.read(dialogProvider.notifier).showTurnSkipped();');
  content = content.replaceAll(RegExp(r'state\s*=\s*state\.copyWith\([^()]*showTurnOrderDialog:\s*true[^()]*\);'), 'ref.read(dialogProvider.notifier).showTurnOrder();');
  content = content.replaceAll(RegExp(r'state\s*=\s*state\.copyWith\([^()]*showLibraryPenaltyDialog:\s*true[^()]*\);'), 'ref.read(dialogProvider.notifier).showLibraryPenalty();');
  content = content.replaceAll(RegExp(r'state\s*=\s*state\.copyWith\([^()]*showImzaGunuDialog:\s*true[^()]*\);'), 'ref.read(dialogProvider.notifier).showImzaGunu();');
  content = content.replaceAll(RegExp(r'state\s*=\s*state\.copyWith\([^()]*showShopDialog:\s*true[^()]*\);'), 'ref.read(dialogProvider.notifier).showShop();');
  content = content.replaceAll(RegExp(r'state\s*=\s*state\.copyWith\([^()]*showQuestionDialog:\s*true,\s*currentQuestion:\s*([^,)]+)[^()]*\);'), 'ref.read(dialogProvider.notifier).showQuestion();');
  content = content.replaceAll(RegExp(r'state\s*=\s*state\.copyWith\([^()]*showCardDialog:\s*true,\s*currentCard:\s*([^,)]+)[^()]*\);'), 'ref.read(dialogProvider.notifier).showCard();');

  // Replace Dialog Hide Methods
  content = content.replaceAll(RegExp(r'state\s*=\s*state\.copyWith\([^()]*showCardDialog:\s*false,\s*currentCard:\s*null[^()]*\);'), 'ref.read(dialogProvider.notifier).hideCard();');
  content = content.replaceAll(RegExp(r'state\s*=\s*state\.copyWith\([^()]*showQuestionDialog:\s*false,\s*currentQuestion:\s*null[^()]*\);'), 'ref.read(dialogProvider.notifier).hideQuestion();');
  content = content.replaceAll(RegExp(r'state\s*=\s*state\.copyWith\([^()]*showTurnSkippedDialog:\s*false[^()]*\);'), 'ref.read(dialogProvider.notifier).hideTurnSkipped();');
  content = content.replaceAll(RegExp(r'state\s*=\s*state\.copyWith\([^()]*showTurnOrderDialog:\s*false[^()]*\);'), 'ref.read(dialogProvider.notifier).hideTurnOrder();');
  content = content.replaceAll(RegExp(r'state\s*=\s*state\.copyWith\([^()]*showLibraryPenaltyDialog:\s*false[^()]*\);'), 'ref.read(dialogProvider.notifier).hideLibraryPenalty();');
  content = content.replaceAll(RegExp(r'state\s*=\s*state\.copyWith\([^()]*showImzaGunuDialog:\s*false[^()]*\);'), 'ref.read(dialogProvider.notifier).hideImzaGunu();');
  content = content.replaceAll(RegExp(r'state\s*=\s*state\.copyWith\([^()]*showShopDialog:\s*false[^()]*\);'), 'ref.read(dialogProvider.notifier).hideShop();');
  content = content.replaceAll(RegExp(r'state\s*=\s*state\.copyWith\([^()]*showCardDialog:\s*false[^()]*\);'), 'ref.read(dialogProvider.notifier).hideCard();');
  content = content.replaceAll(RegExp(r'state\s*=\s*state\.copyWith\([^()]*showQuestionDialog:\s*false[^()]*\);'), 'ref.read(dialogProvider.notifier).hideQuestion();');
  
  // Clean up multiline copyWiths that contained these
  content = content.replaceAll(RegExp(r'showTurnSkippedDialog:\s*(true|false),?'), '');
  content = content.replaceAll(RegExp(r'showTurnOrderDialog:\s*(true|false),?'), '');
  content = content.replaceAll(RegExp(r'showLibraryPenaltyDialog:\s*(true|false),?'), '');
  content = content.replaceAll(RegExp(r'showImzaGunuDialog:\s*(true|false),?'), '');
  content = content.replaceAll(RegExp(r'showShopDialog:\s*(true|false),?'), '');
  content = content.replaceAll(RegExp(r'showQuestionDialog:\s*(true|false),?'), '');
  content = content.replaceAll(RegExp(r'currentQuestion:\s*([^,;]+),?'), '');
  content = content.replaceAll(RegExp(r'showCardDialog:\s*(true|false),?'), '');
  content = content.replaceAll(RegExp(r'currentCard:\s*([^,;]+),?'), '');

  // Then replace the individual accesses like state.showX -> ref.read(dialogProvider).showX
  content = content.replaceAll('state.showQuestionDialog', 'ref.read(dialogProvider).showQuestionDialog');
  content = content.replaceAll('state.showCardDialog', 'ref.read(dialogProvider).showCardDialog');
  content = content.replaceAll('state.showLibraryPenaltyDialog', 'ref.read(dialogProvider).showLibraryPenaltyDialog');
  content = content.replaceAll('state.showImzaGunuDialog', 'ref.read(dialogProvider).showImzaGunuDialog');
  content = content.replaceAll('state.showShopDialog', 'ref.read(dialogProvider).showShopDialog');
  content = content.replaceAll('state.showTurnOrderDialog', 'ref.read(dialogProvider).showTurnOrderDialog');
  content = content.replaceAll('state.showTurnSkippedDialog', 'ref.read(dialogProvider).showTurnSkippedDialog');
  
  // state.currentQuestion -> ref.read(dialogProvider).currentQuestion
  content = content.replaceAll('state.currentQuestion', 'ref.read(dialogProvider).currentQuestion');
  content = content.replaceAll('state.currentCard', 'ref.read(dialogProvider).currentCard');

  file.writeAsStringSync(content);
}
