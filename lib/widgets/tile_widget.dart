// TEMPORARILY DISABLED FOR COMPILATION RESET
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import '../models/tile.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class TileWidget extends StatelessWidget {
//   final Tile tile;
//   final double size;
//   final VoidCallback? onTap;
//
//   const TileWidget({
//     super.key,
//     required this.tile,
//     required this.size,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     Color backgroundColor;
//     IconData? icon;
//     String? subtitle;
//
//     switch (tile.type) {
//       case TileType.corner:
//         backgroundColor = _getCornerBackgroundColor(tile.cornerEffect);
//         icon = _getCornerIcon(tile.cornerEffect);
//         break;
//
//       case TileType.book:
//         backgroundColor = Colors.blue.shade100;
//         icon = FontAwesomeIcons.book;
//         subtitle = '${tile.copyrightFee}/${tile.purchasePrice}';
//         break;
//
//       case TileType.publisher:
//         backgroundColor = Colors.green.shade100;
//         icon = FontAwesomeIcons.building;
//         subtitle = '${tile.copyrightFee}/${tile.purchasePrice}';
//         break;
//
//       case TileType.chance:
//         backgroundColor = Colors.amber.shade300;
//         icon = FontAwesomeIcons.question;
//         break;
//
//       case TileType.fate:
//         backgroundColor = Colors.red.shade300;
//         icon = FontAwesomeIcons.fortAwesome;
//         break;
//
//       case TileType.tax:
//         backgroundColor = Colors.orange.shade200;
//         icon = FontAwesomeIcons.moneyBill;
//         subtitle = '%${tile.taxRate}';
//         break;
//
//       case TileType.special:
//         backgroundColor = Colors.purple.shade200;
//         icon = FontAwesomeIcons.star;
//         break;
//     }
//
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           border: Border.all(color: Colors.brown.shade400, width: 1),
//           borderRadius: BorderRadius.circular(4),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 2,
//               offset: const Offset(0, 1),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(size * 0.05),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Icon
//               if (icon != null) ...[
//                 Icon(
//                   icon,
//                   size: size * 0.25,
//                   color: Colors.brown.shade900,
//                 ),
//                 SizedBox(height: size * 0.03),
//               ],
//
//               // Tile name
//               Flexible(
//                 child: Text(
//                   tile.name,
//                   style: GoogleFonts.poppins(
//                     fontSize: size * 0.09,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.brown.shade900,
//                     height: 1.1,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//
//               // Group number for book tiles
//               if (tile.isBook && tile.group != null) ...[
//                 SizedBox(height: size * 0.02),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: size * 0.03,
//                     vertical: size * 0.01,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.brown.shade700,
//                     borderRadius: BorderRadius.circular(size * 0.02),
//                   ),
//                   child: Text(
//                     'Grup ${tile.group}',
//                     style: GoogleFonts.poppins(
//                       fontSize: size * 0.06,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//
//               // Fee/Price for book/publisher tiles
//               if (subtitle != null) ...[
//                 SizedBox(height: size * 0.02),
//                 Text(
//                   subtitle!,
//                   style: GoogleFonts.poppins(
//                     fontSize: size * 0.065,
//                     color: Colors.brown.shade800,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Color _getCornerBackgroundColor(CornerEffect? effect) {
//     switch (effect) {
//       case CornerEffect.baslangic:
//         return Colors.green.shade200;
//       case CornerEffect.kutuphaneNobeti:
//         return Colors.orange.shade200;
//       case CornerEffect.imzaGunu:
//         return Colors.purple.shade200;
//       case CornerEffect.iflasRiski:
//         return Colors.red.shade200;
//       default:
//         return Colors.grey.shade200;
//     }
//   }
//
//   IconData? _getCornerIcon(CornerEffect? effect) {
//     switch (effect) {
//       case CornerEffect.baslangic:
//         return FontAwesomeIcons.flag;
//       case CornerEffect.kutuphaneNobeti:
//         return FontAwesomeIcons.book;
//       case CornerEffect.imzaGunu:
//         return FontAwesomeIcons.pen;
//       case CornerEffect.iflasRiski:
//         return FontAwesomeIcons.skull;
//       default:
//         return null;
//     }
//   }
// }
