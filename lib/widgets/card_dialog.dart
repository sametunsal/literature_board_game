// TEMPORARILY DISABLED FOR COMPILATION RESET
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../models/card.dart';
// 
// class CardDialog extends StatelessWidget {
//   final Card card;
//   final VoidCallback onDismiss;
// 
//   const CardDialog({
//     super.key,
//     required this.card,
//     required this.onDismiss,
//   });
// 
//   @override
//   Widget build(BuildContext context) {
//     Color backgroundColor;
//     IconData icon;
//     String title;
// 
//     switch (card.type) {
//       case CardType.sans:
//         backgroundColor = Colors.amber.shade100;
//         icon = Icons.star;
//         title = 'ŞANS Kartı';
//         break;
//       case CardType.kader:
//         backgroundColor = Colors.red.shade100;
//         icon = Icons.fortune;
//         title = 'KADER Kartı';
//         break;
//     }
// 
//     return AlertDialog(
//       backgroundColor: backgroundColor,
//       title: Row(
//         children: [
//           Icon(icon, color: Colors.brown.shade900),
//           const SizedBox(width: 8),
//           Text(
//             title,
//             style: GoogleFonts.poppins(
//               fontWeight: FontWeight.bold,
//               color: Colors.brown.shade900,
//             ),
//           ),
//         ],
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Card description
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.brown.shade300),
//               ),
//               child: Text(
//                 card.description,
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.brown.shade900,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             
//             // Effect description
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.brown.shade50,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info_outline, color: Colors.brown.shade700, size: 20),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       _getEffectDescription(card.effect),
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Colors.brown.shade800,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             
//             // Star amount if applicable
//             if (card.starAmount != null) ...[
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.amber.shade200,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(Icons.star, color: Colors.amber, size: 20),
//                     const SizedBox(width: 4),
//                     Text(
//                       '${card.starAmount!} yıldız',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.brown.shade900,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//       actions: [
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton.icon(
//             onPressed: onDismiss,
//             icon: const Icon(Icons.check),
//             label: Text(
//               'Tamam',
//               style: GoogleFonts.poppins(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.brown.shade800,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 12),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// 
//   String _getEffectDescription(CardEffect effect) {
//     switch (effect) {
//       case CardEffect.gainStars:
//         return 'Yıldız kazan';
//       case CardEffect.loseStars:
//         return 'Yıldız kaybet';
//       case CardEffect.skipNextTax:
//         return 'Sonraki vergiyi atla';
//       case CardEffect.freeTurn:
//         return 'Ücretsiz tur';
//       case CardEffect.easyQuestionNext:
//         return 'Sonraki soru kolay';
//       case CardEffect.allPlayersGainStars:
//         return 'Tüm oyuncular yıldız kazanır';
//       case CardEffect.allPlayersLoseStars:
//         return 'Tüm oyuncular yıldız kaybeder';
//       case CardEffect.publisherOwnersLose:
//         return 'Yayınevi sahipleri yıldız kaybeder';
//       case CardEffect.taxWaiver:
//         return 'Tüm oyuncular vergi ödemez';
//       case CardEffect.richPlayerPays:
//         return 'En zengin oyuncu öder';
//       case CardEffect.allPlayersEasyQuestion:
//         return 'Tüm oyuncular kolay soru alır';
//     }
//   }
// }
