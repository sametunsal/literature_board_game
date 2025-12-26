// TEMPORARILY DISABLED FOR COMPILATION RESET
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../providers/game_provider.dart';
// 
// class GameLogWidget extends ConsumerWidget {
//   const GameLogWidget({super.key});
// 
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final logMessages = ref.watch(logMessagesProvider);
// 
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
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.only(bottom: 12),
//             decoration: const BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(color: Colors.brown, width: 2),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.history, color: Colors.brown.shade800, size: 20),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Oyun Geçmişi',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.brown.shade900,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           
//           // Log messages
//           Expanded(
//             child: logMessages.isEmpty
//                 ? Center(
//                     child: Text(
//                       'Henüz işlem yok',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   )
//                 : ListView.builder(
//                     reverse: true,
//                     itemCount: logMessages.length,
//                     itemBuilder: (context, index) {
//                       final message = logMessages[index];
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 8),
//                         child: Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.brown.shade50,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: Text(
//                             message,
//                             style: GoogleFonts.poppins(
//                               fontSize: 12,
//                               color: Colors.brown.shade900,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
