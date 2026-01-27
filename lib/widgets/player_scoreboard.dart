import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/player.dart';
import '../models/game_enums.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/game_theme.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: alignment == Alignment.bottomRight
              ? const Radius.circular(16)
              : Radius.zero,
          topRight: alignment == Alignment.bottomLeft
              ? const Radius.circular(16)
              : Radius.zero,
          bottomLeft: alignment == Alignment.topRight
              ? const Radius.circular(16)
              : Radius.zero,
          bottomRight: alignment == Alignment.topLeft
              ? const Radius.circular(16)
              : Radius.zero,
        ),
        border: Border.all(
          color: isCurrentPlayer
              ? GameTheme.goldAccent
              : Colors.white.withValues(alpha: 0.2),
          width: isCurrentPlayer ? 2 : 1,
        ),
        boxShadow: isCurrentPlayer
            ? [
                BoxShadow(
                  color: GameTheme.goldAccent.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isLeft
            ? [
                _buildAvatar(),
                const SizedBox(width: 8),
                _buildInfo(masteriesCount),
              ]
            : [
                _buildInfo(masteriesCount),
                const SizedBox(width: 8),
                _buildAvatar(),
              ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isCurrentPlayer ? GameTheme.goldAccent : Colors.white54,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
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
              color: GameTheme.goldAccent.withValues(alpha: 0.3),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
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
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isCurrentPlayer ? GameTheme.goldAccent : Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        // Stars row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 14),
            const SizedBox(width: 3),
            Text(
              '${player.stars}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            // Masteries count
            Icon(
              Icons.emoji_events,
              color: masteriesCount > 0 ? Colors.orangeAccent : Colors.white38,
              size: 14,
            ),
            const SizedBox(width: 3),
            Text(
              '$masteriesCount/6',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: masteriesCount > 0
                    ? Colors.orangeAccent
                    : Colors.white54,
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
