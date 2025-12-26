// TEMPORARILY DISABLED FOR COMPILATION RESET
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../models/question.dart';
// 
// class QuestionDialog extends StatelessWidget {
//   final Question question;
//   final Function(bool isCorrect) onAnswer;
// 
//   const QuestionDialog({
//     super.key,
//     required this.question,
//     required this.onAnswer,
//   });
// 
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text(
//         'Soru',
//         style: GoogleFonts.poppins(
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Category badge
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.brown.shade100,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 _getCategoryName(question.category),
//                 style: GoogleFonts.poppins(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.brown.shade900,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             
//             // Difficulty
//             Row(
//               children: [
//                 Icon(Icons.star, color: Colors.amber, size: 16),
//                 const SizedBox(width: 4),
//                 Text(
//                   _getDifficultyName(question.difficulty),
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             
//             // Question text
//             Text(
//               question.question,
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 8),
//             
//             // Hint
//             if (question.hint != null) ...[
//               Text(
//                 'İpucu: ${question.hint}',
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   color: Colors.grey.shade600,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ] else
//               const SizedBox(height: 16),
//             
//             // Answer input
//             TextField(
//               decoration: InputDecoration(
//                 hintText: 'Cevabınızı girin...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         // Correct answer
//         Expanded(
//           child: ElevatedButton.icon(
//             onPressed: () => onAnswer(true),
//             icon: const Icon(Icons.check),
//             label: const Text('Doğru'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green.shade600,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         // Wrong answer
//         Expanded(
//           child: ElevatedButton.icon(
//             onPressed: () => onAnswer(false),
//             icon: const Icon(Icons.close),
//             label: const Text('Yanlış'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red.shade600,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// 
//   String _getCategoryName(QuestionCategory category) {
//     switch (category) {
//       case QuestionCategory.benKimim:
//         return 'Ben Kimim?';
//       case QuestionCategory.sorudanCevaba:
//         return 'Sorudan Cevaba';
//       case QuestionCategory.ciz Bulgur:
//         return 'Çiz Bulgur';
//       case QuestionCategory.anket:
//         return 'Anket';
//     }
//   }
// 
//   String _getDifficultyName(Difficulty difficulty) {
//     switch (difficulty) {
//       case Difficulty.easy:
//         return 'Kolay';
//       case Difficulty.medium:
//         return 'Orta';
//       case Difficulty.hard:
//         return 'Zor';
//     }
//   }
// }
