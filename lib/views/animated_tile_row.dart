import 'package:flutter/material.dart';
import '../models/tile.dart';

class AnimatedTileRow extends StatelessWidget {
  final List<Tile> tiles;
  final int currentPlayerPosition;

  const AnimatedTileRow({
    super.key,
    required this.tiles,
    required this.currentPlayerPosition,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tiles.map((tile) {
          bool isCurrent = tile.id == currentPlayerPosition;
          return Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrent ? Colors.yellow : Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text(tile.name), Text('ID: ${tile.id}')],
            ),
          );
        }).toList(),
      ),
    );
  }
}
