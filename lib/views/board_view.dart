// TEMPORARILY DISABLED FOR COMPILATION RESET
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../providers/game_provider.dart';
// import '../widgets/board_widget.dart';
// import '../widgets/player_info_panel.dart';
// import '../widgets/dice_widget.dart';
// import '../widgets/game_log.dart';
// import '../widgets/question_dialog.dart';
// import '../widgets/card_dialog.dart';
// import '../widgets/copyright_purchase_dialog.dart';
// 
// class BoardView extends ConsumerWidget {
//   const BoardView({super.key});
// 
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final gameState = ref.watch(gameProvider);
//     final currentPlayer = ref.watch(currentPlayerProvider);
//     final isGameOver = ref.watch(isGameOverProvider);
//     final currentQuestion = ref.watch(currentQuestionProvider);
//     final currentCard = ref.watch(currentCardProvider);
// 
//     // Show question dialog if active
//     if (currentQuestion != null && gameState.isQuestionActive) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _showQuestionDialog(context, ref, currentQuestion!);
//       });
//     }
// 
//     // Show card dialog if active
//     if (currentCard != null && gameState.isCardActive) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _showCardDialog(context, currentCard!);
//       });
//     }
// 
//     // Show copyright purchase dialog
//     if (gameState.awaitingCopyrightPurchaseTileId != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _showCopyrightPurchaseDialog(context, ref);
//       });
//     }
// 
//     return Scaffold(
//       backgroundColor: Colors.brown.shade200,
//       appBar: _buildAppBar(context, currentPlayer, isGameOver),
//       body: isGameOver
//           ? _buildGameOverScreen(context, ref)
//           : _buildGameBody(context, ref, gameState, currentPlayer),
//     );
//   }
// 
//   PreferredSizeWidget _buildAppBar(BuildContext context, Player currentPlayer, bool isGameOver) {
//     return AppBar(
//       title: Text(
//         'Edebiyat Oyunu',
//         style: GoogleFonts.poppins(
//           fontWeight: FontWeight.bold,
//           fontSize: 24,
//           color: Colors.white,
//         ),
//       ),
//       backgroundColor: Colors.brown.shade800,
//       foregroundColor: Colors.white,
//       elevation: 4,
//       centerTitle: true,
//       actions: [
//         Padding(
//           padding: const EdgeInsets.only(right: 16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 'Sira: ${currentPlayer.name}',
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               if (isGameOver)
//                 Text(
//                   'Oyun Bitti!',
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: Colors.amber,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// 
//   Widget _buildGameBody(
//     BuildContext context,
//     WidgetRef ref,
//     GameState gameState,
//     Player currentPlayer,
//   ) {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             // Top section: Players info
//             _buildPlayersInfoBar(context, gameState.players, currentPlayer),
//             const SizedBox(height: 8),
//             
//             // Middle section: Board and controls
//             Expanded(
//               child: Row(
//                 children: [
//                   // Left: Game log
//                   Expanded(
//                     flex: 2,
//                     child: GameLogWidget(),
//                   ),
//                   const SizedBox(width: 8),
//                   
//                   // Center: Board
//                   Expanded(
//                     flex: 5,
//                     child: BoardWidget(),
//                   ),
//                   const SizedBox(width: 8),
//                   
//                   // Right: Player info and controls
//                   Expanded(
//                     flex: 2,
//                     child: Column(
//                       children: [
//                         // Current player info
//                         PlayerInfoPanel(player: currentPlayer),
//                         const SizedBox(height: 16),
//                         
//                         // Dice and controls
//                         DiceWidget(
//                           diceRoll: gameState.lastDiceRoll,
//                           canRoll: gameState.canRoll,
//                           onRoll: () {
//                             ref.read(gameProvider.notifier).executeTurn();
//                           },
//                         ),
//                         
//                         // Game message
//                         if (gameState.lastMessage != null)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 16),
//                             child: Container(
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(8),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.2),
//                                     blurRadius: 4,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Text(
//                                 gameState.lastMessage!,
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 12,
//                                   color: Colors.brown.shade900,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// 
//   Widget _buildPlayersInfoBar(BuildContext context, List<Player> players, Player currentPlayer) {
//     return Container(
//       height: 80,
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: players.map((player) {
//           final isCurrentPlayer = player.id == currentPlayer.id;
//           return Expanded(
//             child: Container(
//               margin: EdgeInsets.only(
//                 right: player.id != players.last.id ? 8 : 0,
//               ),
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: isCurrentPlayer ? Colors.brown.shade100 : Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(6),
//                 border: isCurrentPlayer
//                     ? Border.all(color: Colors.brown.shade800, width: 2)
//                     : null,
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     player.name,
//                     style: GoogleFonts.poppins(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.brown.shade900,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.star, color: Colors.amber, size: 16),
//                       const SizedBox(width: 4),
//                       Text(
//                         '${player.stars}',
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.brown.shade900,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// 
//   Widget _buildGameOverScreen(BuildContext context, WidgetRef ref) {
//     final gameState = ref.watch(gameProvider);
//     final winner = gameState.players.firstWhere(
//       (p) => !p.isBankrupt,
//       orElse: () => gameState.players.first,
//     );
// 
//     return Center(
//       child: Container(
//         padding: const EdgeInsets.all(32),
//         margin: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.emoji_events,
//               size: 80,
//               color: Colors.amber,
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'OYUN BITTI!',
//               style: GoogleFonts.poppins(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.brown.shade900,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'KAZANAN:',
//               style: GoogleFonts.poppins(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.brown.shade800,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               winner.name,
//               style: GoogleFonts.poppins(
//                 fontSize: 36,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.amber.shade700,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               '${winner.stars} yildiz',
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 color: Colors.brown.shade700,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// 
//   void _showQuestionDialog(BuildContext context, WidgetRef ref, Question question) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => QuestionDialog(
//         question: question,
//         onAnswer: (isCorrect) {
//           Navigator.of(context).pop();
//           ref.read(gameProvider.notifier).answerQuestion(isCorrect);
//         },
//       ),
//     );
//   }
// 
//   void _showCardDialog(BuildContext context, Card card) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => CardDialog(
//         card: card,
//         onDismiss: () {
//           Navigator.of(context).pop();
//         },
//       ),
//     );
//   }
// 
//   void _showCopyrightPurchaseDialog(BuildContext context, WidgetRef ref) {
//     final gameState = ref.read(gameProvider);
//     final tileId = gameState.awaitingCopyrightPurchaseTileId!;
//     final tile = gameState.tiles.firstWhere((t) => t.id == tileId);
//     final player = gameState.currentPlayer;
// 
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => CopyrightPurchaseDialog(
//         tileName: tile.name,
//         price: tile.purchasePrice ?? 0,
//         playerStars: player.stars,
//         onDecision: (wantsToBuy) {
//           Navigator.of(context).pop();
//           ref.read(gameProvider.notifier).purchaseCopyright(wantsToBuy);
//         },
//       ),
//     );
//   }
// }
