// TEMPORARILY DISABLED FOR COMPILATION RESET
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../models/player.dart';
// 
// class PlayerInfoPanel extends StatelessWidget {
//   final Player player;
// 
//   const PlayerInfoPanel({
//     super.key,
//     required this.player,
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
//           // Player name
//           Text(
//             player.name,
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.brown.shade900,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           
//           // Stars display
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.amber.shade100,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.amber, width: 2),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.star, color: Colors.amber, size: 24),
//                 const SizedBox(width: 8),
//                 Text(
//                   '${player.stars}',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.brown.shade900,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           
//           // Position
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.brown.shade50,
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.location_on, color: Colors.brown.shade700, size: 16),
//                 const SizedBox(width: 4),
//                 Text(
//                   'Kutucuk: ${player.position}',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.brown.shade900,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
