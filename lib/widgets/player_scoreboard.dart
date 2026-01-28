import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/player.dart';
import '../models/game_enums.dart';
import '../core/constants/game_constants.dart';

/// Compact corner scoreboard for displaying player stats
/// Shows: Avatar, Name, Stars, and Mastery count
class PlayerScoreboard extends StatelessWidget {
  final Player player;
  final bool isCurrentPlayer;
  final Alignment alignment;

  const PlayerScoreboard({
    super.key,
    required this.player,
    required this.isCurrentPlayer,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final masteriesCount = _countMasteries();
    final isLeft =
        alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: isCurrentPlayer
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isLeft
            ? [
                _buildAvatar(),
                const SizedBox(width: 10),
                _buildInfo(masteriesCount),
              ]
            : [
                _buildInfo(masteriesCount),
                const SizedBox(width: 10),
                _buildAvatar(),
              ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCurrentPlayer ? Colors.amber.shade50 : Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          GameConstants.getAvatarPath(player.iconIndex),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: Icon(
                Icons.person_rounded,
                color: Colors.grey.shade600,
                size: 22,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfo(int masteriesCount) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Player name
        Text(
          player.name,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 4),
        // Stars row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, color: Colors.amber, size: 14),
            const SizedBox(width: 4),
            Text(
              '${player.stars}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(width: 8),
            // Masteries count
            Icon(
              Icons.emoji_events_rounded,
              color: masteriesCount > 0 ? Colors.orange : Colors.grey.shade400,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              '$masteriesCount/6',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: masteriesCount > 0
                    ? Colors.orange
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Count how many categories the player is Master (level 3) in
  int _countMasteries() {
    int count = 0;
    for (final category in QuestionCategory.values) {
      final level = player.categoryLevels[category.name] ?? 0;
      if (level >= 3) count++;
    }
    return count;
  }
}
