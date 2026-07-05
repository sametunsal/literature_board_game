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

  /// Card width on tablets/desktops.
  static const double _wideWidth = 158;

  /// Card width on phone-sized screens: corner cards must leave the
  /// landscape board visible and stay clear of the device frame.
  static const double _compactWidth = 134;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).shortestSide < 500;

    // Single player HUD with constrained width for perimeter layout
    return SizedBox(
      width: isCompact ? _compactWidth : _wideWidth,
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
