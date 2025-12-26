// TEMPORARILY DISABLED FOR COMPILATION RESET
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../models/dice_roll.dart';
// 
// class DiceWidget extends StatelessWidget {
//   final DiceRoll? diceRoll;
//   final bool canRoll;
//   final VoidCallback onRoll;
// 
//   const DiceWidget({
//     super.key,
//     this.diceRoll,
//     required this.canRoll,
//     required this.onRoll,
//   });
// 
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Dice display
//           if (diceRoll != null) ...[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _buildDie(diceRoll!.die1),
//                 const SizedBox(width: 16),
//                 _buildDie(diceRoll!.die2),
//               ],
//             ),
//             const SizedBox(height: 12),
//             
//             // Total
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.brown.shade100,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Toplam: ',
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       color: Colors.brown.shade700,
//                     ),
//                   ),
//                   Text(
//                     '${diceRoll!.total}',
//                     style: GoogleFonts.poppins(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.brown.shade900,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ] else ...[
//             // Placeholder when no roll
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 Icons.help_outline,
//                 size: 32,
//                 color: Colors.grey.shade400,
//               ),
//             ),
//           ],
//           
//           const SizedBox(height: 16),
//           
//           // Roll button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: canRoll ? onRoll : null,
//               icon: const Icon(Icons.casino),
//               label: Text(
//                 'Zar At',
//                 style: GoogleFonts.poppins(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: canRoll ? Colors.brown.shade800 : Colors.grey.shade300,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// 
//   Widget _buildDie(int value) {
//     return Container(
//       width: 60,
//       height: 60,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: Colors.brown.shade400,
//           width: 2,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 2,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Center(
//         child: Text(
//           '$value',
//           style: GoogleFonts.poppins(
//             fontSize: 32,
//             fontWeight: FontWeight.bold,
//             color: Colors.brown.shade900,
//           ),
//         ),
//       ),
//     );
//   }
// }
