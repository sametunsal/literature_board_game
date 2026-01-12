import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/game_theme.dart';
import '../models/player.dart';

/// Literature-themed icons for player avatars (same as setup screen)
const List<IconData> literatureIcons = [
  Icons.menu_book,
  Icons.auto_stories,
  Icons.history_edu,
  Icons.edit_note,
  Icons.school,
  Icons.local_library,
  Icons.workspace_premium,
  Icons.bookmark,
  Icons.article,
  Icons.psychology,
  Icons.lightbulb,
  Icons.emoji_events,
];

/// Game log widget with Score Panel and modern glassmorphism effect
/// Displays player scores and recent game events as a floating glass panel
class GameLog extends StatelessWidget {
  final List<String> logs;
  final List<Player> players;
  final int currentPlayerIndex;

  const GameLog({
    super.key,
    required this.logs,
    this.players = const [],
    this.currentPlayerIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Show last 5 messages
    final displayLogs = logs.length > 5 ? logs.sublist(logs.length - 5) : logs;

    return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            // Blur effect for glassmorphism
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 280,
              constraints: const BoxConstraints(maxHeight: 320),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // Semi-transparent white for glass effect
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                // Thin white border for glass edge
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
                // Subtle inner shadow for depth
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SCORE PANEL
                  if (players.isNotEmpty) ...[
                    _buildScoreHeader(),
                    const SizedBox(height: 6),
                    _buildScoreList(),
                    const SizedBox(height: 10),
                    _buildDivider(),
                    const SizedBox(height: 10),
                  ],

                  // GAME LOG HEADER
                  _buildLogHeader(),
                  const SizedBox(height: 6),

                  // DIVIDER
                  _buildDivider(),
                  const SizedBox(height: 6),

                  // LOG ENTRIES (scrollable)
                  if (displayLogs.isNotEmpty)
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: displayLogs
                              .asMap()
                              .entries
                              .map(
                                (entry) => _LogEntry(
                                  text: entry.value,
                                  isLatest: entry.key == displayLogs.length - 1,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    )
                  else
                    Text(
                      "Henüz olay yok...",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildScoreHeader() {
    return Row(
      children: [
        Icon(Icons.leaderboard, size: 14, color: GameTheme.goldAccent),
        const SizedBox(width: 6),
        Text(
          "PUAN DURUMU",
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: GameTheme.goldAccent,
            letterSpacing: 0.5,
            shadows: [
              Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreList() {
    // Sort players by balance (descending)
    final sortedPlayers = List<Player>.from(players)
      ..sort((a, b) => b.balance.compareTo(a.balance));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: sortedPlayers.asMap().entries.map((entry) {
        final player = entry.value;
        final isCurrentTurn = players.indexOf(player) == currentPlayerIndex;

        return _PlayerScoreRow(
          player: player,
          isCurrentTurn: isCurrentTurn,
          rank: entry.key + 1,
        );
      }).toList(),
    );
  }

  Widget _buildLogHeader() {
    return Row(
      children: [
        Icon(
          Icons.history,
          size: 14,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(
          "OYUN GEÇMİŞİ",
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

/// Player score row with icon, name, and balance
class _PlayerScoreRow extends StatelessWidget {
  final Player player;
  final bool isCurrentTurn;
  final int rank;

  const _PlayerScoreRow({
    required this.player,
    this.isCurrentTurn = false,
    this.rank = 0,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = player.iconIndex < literatureIcons.length
        ? literatureIcons[player.iconIndex]
        : Icons.person;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? GameTheme.goldAccent.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isCurrentTurn
            ? Border.all(
                color: GameTheme.goldAccent.withValues(alpha: 0.4),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          // Rank indicator
          SizedBox(
            width: 14,
            child: Text(
              "$rank.",
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: rank == 1
                    ? GameTheme.goldAccent
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),

          // Player icon
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: player.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: player.color.withValues(alpha: 0.4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(iconData, size: 12, color: Colors.white),
          ),

          const SizedBox(width: 8),

          // Player name
          Expanded(
            child: Text(
              player.name,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isCurrentTurn ? FontWeight.w600 : FontWeight.w500,
                color: isCurrentTurn
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.85),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Balance
          Text(
            "₺${player.balance}",
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: rank == 1 ? GameTheme.goldAccent : Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 2,
                ),
              ],
            ),
          ),

          // Current turn indicator
          if (isCurrentTurn)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                Icons.play_arrow,
                size: 12,
                color: GameTheme.goldAccent,
              ),
            ),
        ],
      ),
    );
  }
}

/// Individual log entry with styling
class _LogEntry extends StatelessWidget {
  final String text;
  final bool isLatest;

  const _LogEntry({required this.text, this.isLatest = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bullet point
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: isLatest
                  ? GameTheme.goldAccent
                  : Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),

          // Log text
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isLatest ? FontWeight.w500 : FontWeight.normal,
                color: isLatest
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.7),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
