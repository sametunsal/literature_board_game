import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../models/player.dart';
import '../../models/game_enums.dart';
import '../../core/constants/game_constants.dart';
import 'isometric_icon.dart';

class PlayerScoreboard extends StatelessWidget {
  final Player player;
  final bool isCurrentPlayer;
  final bool isNext;
  final Alignment alignment;

  const PlayerScoreboard({
    super.key,
    required this.player,
    required this.isCurrentPlayer,
    this.isNext = false,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final masteriesCount = _countMasteries();
    final isLeft =
        alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    Color borderColor;
    double borderWidth = 1;
    if (isCurrentPlayer) {
      borderColor = Colors.green.shade400;
      borderWidth = 2.5;
    } else if (isNext) {
      borderColor = Colors.amber.shade400;
      borderWidth = 2;
    } else {
      borderColor = Colors.grey.shade200;
      borderWidth = 1;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCurrentPlayer
              ? [
                  Colors.green.shade100.withValues(alpha: 0.98),
                  Colors.green.shade50.withValues(alpha: 0.95),
                ]
              : isNext
                  ? [
                      Colors.amber.shade100.withValues(alpha: 0.98),
                      Colors.amber.shade50.withValues(alpha: 0.95),
                    ]
                  : [
                      Colors.grey.shade100.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.98),
                    ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: isCurrentPlayer
                ? Colors.green.withValues(alpha: 0.3)
                : isNext
                    ? Colors.amber.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.6),
            blurRadius: 4,
            offset: const Offset(0, -1),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isLeft
            ? [
                _buildAvatar(),
                const SizedBox(width: 6),
                Expanded(child: _buildInfo(masteriesCount)),
              ]
            : [
                Expanded(child: _buildInfo(masteriesCount)),
                const SizedBox(width: 6),
                _buildAvatar(),
              ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCurrentPlayer ? Colors.amber.shade50 : Colors.grey.shade100,
        border: Border.all(
          color: isCurrentPlayer ? Colors.white : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(2, 3),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.7),
            blurRadius: 3,
            offset: const Offset(-1, -1),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Center(
        child: IsometricIcon(
          icon: GameConstants.iconPalette[
              player.iconIndex % GameConstants.iconPalette.length],
          color: player.color,
          size: 18,
          depth: 3,
        ),
      ),
    );
  }

  Widget _buildInfo(int masteriesCount) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name row — AutoSizeText so it shrinks instead of ellipsis
        Row(
          children: [
            Expanded(
              child: AutoSizeText(
                player.name,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
                maxLines: 1,
                minFontSize: 8,
                stepGranularity: 0.5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCurrentPlayer) ...[
              const SizedBox(width: 4),
              _StatusBadge(
                label: 'SIRA',
                colors: [Colors.green.shade400, Colors.green.shade600],
                glowColor: Colors.green,
              ),
            ] else if (isNext) ...[
              const SizedBox(width: 4),
              _StatusBadge(
                label: 'SONRA',
                colors: [Colors.amber.shade400, Colors.amber.shade600],
                glowColor: Colors.amber,
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        // Stats row — compact
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, color: Colors.amber, size: 13),
            const SizedBox(width: 2),
            Text(
              '${player.stars}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.emoji_events_rounded,
              color:
                  masteriesCount > 0 ? Colors.orange : Colors.grey.shade400,
              size: 13,
            ),
            const SizedBox(width: 2),
            Text(
              '$masteriesCount/6',
              style: GoogleFonts.poppins(
                fontSize: 11,
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

  int _countMasteries() {
    int count = 0;
    for (final category in QuestionCategory.values) {
      final level = player.categoryLevels[category.name] ?? 0;
      if (level >= 3) count++;
    }
    return count;
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final List<Color> colors;
  final Color glowColor;

  const _StatusBadge({
    required this.label,
    required this.colors,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 7,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
