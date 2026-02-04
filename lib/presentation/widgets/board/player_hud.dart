import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/player.dart';
import '../../widgets/player_scoreboard.dart';

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
    // Single player HUD with constrained width for perimeter layout
    return SizedBox(
      width: 210, // Increased width to fit Avatar + Name + Badge
      child:
          PlayerScoreboard(
                player: player,
                isCurrentPlayer: isCurrentPlayer,
                isNext: isNextPlayer,
                alignment: Alignment.topLeft, // Default internal alignment
              )
              .animate(target: isCurrentPlayer ? 1 : 0)
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
                duration: 300.ms,
                curve: Curves.easeOutBack,
              ),
    );
  }
}
