import 'package:flutter/material.dart';
import '../../../models/player.dart';
import '../../widgets/player_scoreboard.dart';
import 'board_visual_constants.dart';

class PlayerHud extends StatelessWidget {
  final Player player;
  final bool isCurrentPlayer;
  final bool isNextPlayer;

  const PlayerHud({
    super.key,
    required this.player,
    this.isCurrentPlayer = false,
    this.isNextPlayer = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).shortestSide < 500;

    // Every player HUD uses the same fixed panel size for a screen class.
    // Turn emphasis (gradient, border, glow, badge) is paint-only inside
    // PlayerScoreboard and must not resize the panel.
    return SizedBox(
      width: isCompact ? kPlayerHudCompactWidth : kPlayerHudWideWidth,
      height: kPlayerHudHeight,
      child: PlayerScoreboard(
        player: player,
        isCurrentPlayer: isCurrentPlayer,
        isNext: isNextPlayer,
        alignment: Alignment.topLeft, // Default internal alignment
      ),
    );
  }
}
