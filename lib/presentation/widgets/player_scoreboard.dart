import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/player.dart';
import '../../models/game_enums.dart';
import '../../core/constants/game_constants.dart';
import 'isometric_icon.dart';

/// Compact corner scoreboard for displaying player stats
/// Shows: Avatar, Name, Stars, and Mastery count
/// Includes visual indicators for current and next player
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

    // Determine border color based on player status
    Color borderColor;
    double borderWidth = 1;
    if (isCurrentPlayer) {
      borderColor = Colors.green.shade400;
      borderWidth = 3;
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        // Gradient background for subtle depth
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: borderWidth),
        // ═══════════════════════════════════════════════════════════════
        // FAUX 3D CARD EFFECT - Elevated scoreboard
        // ═══════════════════════════════════════════════════════════════
        boxShadow: [
          // Primary deep shadow - strong elevation
          BoxShadow(
            color: isCurrentPlayer
                ? Colors.green.withValues(alpha: 0.35)
                : isNext
                ? Colors.amber.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
          // Secondary shadow - depth layer
          BoxShadow(
            color: isCurrentPlayer
                ? Colors.green.withValues(alpha: 0.15)
                : isNext
                ? Colors.amber.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          // Top highlight - light source effect
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.7),
            blurRadius: 6,
            offset: const Offset(0, -2),
            spreadRadius: -1,
          ),
          // Inner glow for active player
          if (isCurrentPlayer)
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.1),
              blurRadius: 12,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isLeft
            ? [
                _buildAvatar(),
                const SizedBox(width: 10),
                Expanded(child: _buildInfo(masteriesCount)),
              ]
            : [
                Expanded(child: _buildInfo(masteriesCount)),
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
        border: Border.all(
          color: isCurrentPlayer ? Colors.white : Colors.grey.shade300,
          width: 2,
        ),
        // ═══════════════════════════════════════════════════════════════
        // FAUX 3D ELEVATION - Neumorphic inspired depth
        // ═══════════════════════════════════════════════════════════════
        boxShadow: [
          // Primary drop shadow - elevation
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(3, 4),
            spreadRadius: -2,
          ),
          // Secondary soft shadow - ambient
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
          // Top highlight - light source from above-left
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 4,
            offset: const Offset(-2, -2),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle inner gradient for 3D curvature effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  radius: 0.8,
                  colors: [
                    Colors.white.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          Center(
            child: IsometricIcon(
              icon:
                  GameConstants.iconPalette[player.iconIndex %
                      GameConstants.iconPalette.length],
              color: player.color, // Use player color for the icon
              size: 24,
              depth: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(int masteriesCount) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Player name with turn indicator badge
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                player.name,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 6),
            // Turn indicator badge with 3D effect
            if (isCurrentPlayer)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  // ═══════════════════════════════════════════════════════════════
                  // 3D BADGE EFFECT
                  // ═══════════════════════════════════════════════════════════════
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Text(
                  'SIRA SENDE',
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              )
            else if (isNext)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.amber.shade400, Colors.amber.shade600],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Text(
                  'SIRADAKİ',
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // Stars row with 3D icon effects
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Star icon with 3D effect
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(Icons.star_rounded, color: Colors.amber, size: 15),
            ),
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
            // Trophy icon with 3D effect
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: masteriesCount > 0
                        ? Colors.orange.withValues(alpha: 0.5)
                        : Colors.grey.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: masteriesCount > 0
                    ? Colors.orange
                    : Colors.grey.shade400,
                size: 15,
              ),
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
