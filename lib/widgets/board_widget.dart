// TEMPORARILY DISABLED FOR COMPILATION RESET
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../providers/game_provider.dart';
// import 'tile_widget.dart';
// 
// class BoardWidget extends ConsumerWidget {
//   const BoardWidget({super.key});
// 
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final gameState = ref.watch(gameProvider);
//     final players = gameState.players;
//     final currentPlayerIndex = gameState.currentPlayerIndex;
// 
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.brown.shade100,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.brown.shade400, width: 2),
//       ),
//       child: Stack(
//         children: [
//           // Board tiles (counter-clockwise)
//           ..._buildBoardTiles(gameState.tiles),
//           
//           // Center area
//           _buildCenterArea(),
//           
//           // Player pawns
//           ..._buildPlayerPawns(players, currentPlayerIndex),
//         ],
//       ),
//     );
//   }
// 
//   List<Widget> _buildBoardTiles(List<Tile> tiles) {
//     final tilesWidgets = <Widget>[];
//     final boardSize = 300.0;
//     final tileSize = 40.0;
//     final cornerTileSize = tileSize * 1.5;
// 
//     // Build counter-clockwise board (40 tiles)
//     // Top row (left to right): tiles 11-1
//     for (int i = 11; i >= 1; i--) {
//       final tile = tiles.firstWhere((t) => t.id == i);
//       final isCorner = i % 10 == 1;
//       final currentTileSize = isCorner ? cornerTileSize : tileSize;
//       
//       tilesWidgets.add(
//         Positioned(
//           left: (11 - i) * tileSize + (isCorner ? (tileSize - cornerTileSize) / 2 : 0),
//           top: 0,
//           child: TileWidget(
//             tile: tile,
//             size: currentTileSize,
//           ),
//         ),
//       );
//     }
// 
//     // Right column (top to bottom): tiles 1-10
//     for (int i = 1; i <= 10; i++) {
//       final tile = tiles.firstWhere((t) => t.id == i);
//       final isCorner = i % 10 == 1;
//       final currentTileSize = isCorner ? cornerTileSize : tileSize;
//       
//       tilesWidgets.add(
//         Positioned(
//           top: (i - 1) * tileSize + (isCorner ? (tileSize - cornerTileSize) / 2 : 0),
//           right: 0,
//           child: TileWidget(
//             tile: tile,
//             size: currentTileSize,
//           ),
//         ),
//       );
//     }
// 
//     // Bottom row (right to left): tiles 11-20
//     for (int i = 11; i <= 20; i++) {
//       final tile = tiles.firstWhere((t) => t.id == i);
//       final isCorner = i % 10 == 1;
//       final currentTileSize = isCorner ? cornerTileSize : tileSize;
//       
//       tilesWidgets.add(
//         Positioned(
//           right: (20 - i) * tileSize + (isCorner ? (tileSize - cornerTileSize) / 2 : 0),
//           bottom: 0,
//           child: TileWidget(
//             tile: tile,
//             size: currentTileSize,
//           ),
//         ),
//       );
//     }
// 
//     // Left column (bottom to top): tiles 21-40
//     for (int i = 21; i <= 40; i++) {
//       final tile = tiles.firstWhere((t) => t.id == i);
//       final isCorner = i % 10 == 1;
//       final currentTileSize = isCorner ? cornerTileSize : tileSize;
//       
//       tilesWidgets.add(
//         Positioned(
//           bottom: (40 - i) * tileSize + (isCorner ? (tileSize - cornerTileSize) / 2 : 0),
//           left: 0,
//           child: TileWidget(
//             tile: tile,
//             size: currentTileSize,
//           ),
//         ),
//       );
//     }
// 
//     return tilesWidgets;
//   }
// 
//   Widget _buildCenterArea() {
//     return Center(
//       child: Container(
//         width: 150,
//         height: 150,
//         decoration: BoxDecoration(
//           color: Colors.brown.shade800,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.menu_book,
//               size: 48,
//               color: Colors.amber,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'EDebiyat',
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             Text(
//               'Oyunu',
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// 
//   List<Widget> _buildPlayerPawns(List<Player> players, int currentPlayerIndex) {
//     final pawns = <Widget>[];
//     final boardSize = 300.0;
//     final tileSize = 40.0;
//     final cornerTileSize = tileSize * 1.5;
// 
//     for (int i = 0; i < players.length; i++) {
//       final player = players[i];
//       final position = player.position;
//       final isCorner = position % 10 == 1;
//       final currentTileSize = isCorner ? cornerTileSize : tileSize;
//       
//       // Calculate position based on tile number (counter-clockwise)
//       double x, y;
//       Offset offset;
//       
//       if (position >= 1 && position <= 10) {
//         // Right column
//         x = boardSize - tileSize;
//         y = (position - 1) * tileSize + (isCorner ? (tileSize - cornerTileSize) / 2 : 0);
//       } else if (position >= 11 && position <= 20) {
//         // Bottom row
//         x = boardSize - (position - 10) * tileSize - (isCorner ? (tileSize - cornerTileSize) / 2 : 0);
//         y = boardSize - tileSize;
//       } else if (position >= 21 && position <= 30) {
//         // Left column
//         x = 0;
//         y = boardSize - (position - 20) * tileSize - (isCorner ? (tileSize - cornerTileSize) / 2 : 0);
//       } else {
//         // Top row (position 31-40)
//         x = (position - 30) * tileSize + (isCorner ? (tileSize - cornerTileSize) / 2 : 0);
//         y = 0;
//       }
//       
//       // Add offset for multiple players on same tile
//       offset = Offset((i % 2) * 10.0, (i ~/ 2) * 10.0);
//       
//       pawns.add(
//         Positioned(
//           left: x + offset.dx,
//           top: y + offset.dy,
//           child: Container(
//             width: 30,
//             height: 30,
//             decoration: BoxDecoration(
//               color: Color(int.parse(player.color)),
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white, width: 2),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black26,
//                   blurRadius: 2,
//                 ),
//               ],
//             ),
//             child: Center(
//               child: Text(
//                 player.name[0],
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     }
// 
//     return pawns;
//   }
// }
