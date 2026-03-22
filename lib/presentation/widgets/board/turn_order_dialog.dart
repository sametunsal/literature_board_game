import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/game_constants.dart';
import '../../../models/player.dart';

class TurnOrderDialog extends StatelessWidget {
  final List<Player> players;
  final Map<String, int> orderRolls;
  final VoidCallback onClose;

  const TurnOrderDialog({
    super.key,
    required this.players,
    required this.orderRolls,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;
    final screenW = mq.size.width;
    final isLandscape = screenW > screenH;

    final maxH = isLandscape ? screenH * 0.92 : screenH * 0.86;
    final maxW = isLandscape ? math.min(screenW * 0.30, 280.0) : math.min(screenW * 0.72, 320.0);

    return SafeArea(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
          constraints: BoxConstraints(maxHeight: maxH, maxWidth: maxW),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade600, Colors.indigo.shade400],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events_rounded, color: Colors.amber.shade100, size: 26),
                    const SizedBox(height: 6),
                    Text(
                      'Sıra Belirlendi!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'En yüksek zar atan başlar',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // Player list
              Flexible(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(players.length, (index) {
                        final player = players[index];
                        final roll = orderRolls[player.id] ?? 0;
                        final isFirst = index == 0;
                        return _PlayerRow(
                          player: player,
                          rank: index + 1,
                          roll: roll,
                          isFirst: isFirst,
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // Button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      'BAŞLA',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final Player player;
  final int rank;
  final int roll;
  final bool isFirst;

  const _PlayerRow({
    required this.player,
    required this.rank,
    required this.roll,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isFirst ? Colors.amber.shade50 : Colors.grey.shade50;
    final borderColor =
        isFirst ? Colors.amber.shade400 : Colors.grey.shade200;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isFirst ? 2 : 1),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              gradient: isFirst
                  ? LinearGradient(
                      colors: [Colors.amber.shade400, Colors.amber.shade600])
                  : LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade400]),
              shape: BoxShape.circle,
              boxShadow: [
                if (isFirst)
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Center(
              child: Text(
                '$rank',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isFirst ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                GameConstants.getAvatarPath(player.iconIndex),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.person_rounded,
                      color: Colors.grey.shade500, size: 20);
                },
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Name
          Expanded(
            child: Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Dice result
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isFirst ? Colors.amber.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.casino_rounded,
                    size: 14,
                    color: isFirst
                        ? Colors.amber.shade700
                        : Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '$roll',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isFirst
                        ? Colors.amber.shade800
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
