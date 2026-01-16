import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/game_theme.dart';
import '../core/motion/motion_constants.dart';
import '../providers/theme_notifier.dart';
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
                // V2.5 Dark Academia glassmorphism
                color: GameTheme.tableBackgroundColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                // Copper accent border for V2.5 theme
                border: Border.all(color: GameTheme.copperAccent, width: 1.5),
                // Subtle shadow for depth
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  // SCORE PANEL
                  if (players.isNotEmpty) ...[
                    _buildScoreHeader(),
                    const SizedBox(height: 8),
                    _buildScoreList(),
                    const SizedBox(height: 12),
                    _buildDivider(),
                    const SizedBox(height: 12),
                  ],

                  // GAME LOG HEADER
                  _buildLogHeader(),
                  const SizedBox(height: 8),

                  // DIVIDER
                  _buildDivider(),
                  const SizedBox(height: 8),

                  // LOG ENTRIES (scrollable)
                  if (displayLogs.isNotEmpty)
                    ...displayLogs.asMap().entries.map((entry) {
                      return _LogEntry(
                        text: entry.value,
                        isLatest: entry.key == displayLogs.length - 1,
                      );
                    })
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          "Henüz olay yok...",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: GameTheme.textDark.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
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
          style: GameTheme.hudSectionLabel.copyWith(
            shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
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
          key: ValueKey('score_${player.id}'),
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
          color: GameTheme.textDark.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(
          "OYUN GEÇMİŞİ",
          style: GameTheme.hudSectionLabel.copyWith(
            color: GameTheme.textDark.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
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
            GameTheme.copperAccent.withValues(alpha: 0.0),
            GameTheme.copperAccent.withValues(alpha: 0.4),
            GameTheme.copperAccent.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

/// Player score row with icon, name, and animated balance
class _PlayerScoreRow extends ConsumerStatefulWidget {
  final Player player;
  final bool isCurrentTurn;
  final int rank;

  const _PlayerScoreRow({
    super.key,
    required this.player,
    this.isCurrentTurn = false,
    this.rank = 0,
  });

  @override
  ConsumerState<_PlayerScoreRow> createState() => _PlayerScoreRowState();
}

class _PlayerScoreRowState extends ConsumerState<_PlayerScoreRow>
    with SingleTickerProviderStateMixin {
  int _previousBalance = 0;
  int _displayedBalance = 0;
  bool _isAnimating = false;
  bool _isIncrease = false;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _previousBalance = widget.player.balance;
    _displayedBalance = widget.player.balance;
  }

  @override
  void didUpdateWidget(_PlayerScoreRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect balance change
    if (oldWidget.player.balance != widget.player.balance) {
      _previousBalance = oldWidget.player.balance;
      final newBalance = widget.player.balance;
      _isIncrease = newBalance > _previousBalance;

      // Start animation
      setState(() {
        _isAnimating = true;
        _scale = 1.08;
      });

      // Animate number counting
      _animateNumber(_previousBalance, newBalance);

      // Reset scale after animation
      Future.delayed(MotionDurations.fast, () {
        if (mounted) {
          setState(() => _scale = 1.0);
        }
      });

      // Clear glow after animation
      Future.delayed(MotionDurations.fast * 2, () {
        if (mounted) {
          setState(() => _isAnimating = false);
        }
      });
    }
  }

  void _animateNumber(int from, int to) {
    final diff = (to - from).abs();
    final steps = diff.clamp(1, 10);
    final stepDuration = MotionDurations.fast.inMilliseconds ~/ steps;
    final increment = (to - from) ~/ steps;

    int current = from;
    for (int i = 0; i < steps; i++) {
      Future.delayed(Duration(milliseconds: stepDuration * i), () {
        if (mounted) {
          setState(() {
            current += increment;
            _displayedBalance = current;
          });
        }
      });
    }

    // Ensure final value is exact
    Future.delayed(MotionDurations.fast, () {
      if (mounted) {
        setState(() => _displayedBalance = to);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final isCurrentTurn = widget.isCurrentTurn;
    final rank = widget.rank;
    final themeState = ref.watch(themeProvider);
    final tokens = themeState.tokens;

    final iconData = player.iconIndex < literatureIcons.length
        ? literatureIcons[player.iconIndex]
        : Icons.person;

    // Determine glow color based on increase/decrease
    final glowColor = _isIncrease ? tokens.accent : tokens.danger;

    return AnimatedScale(
      scale: _scale,
      duration: MotionDurations.fast.safe,
      curve: MotionCurves.emphasized,
      child: AnimatedContainer(
        duration: MotionDurations.fast.safe,
        curve: Curves.easeOutCubic,
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
          // Money change glow
          boxShadow: _isAnimating
              ? [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Colors.transparent,
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                  const BoxShadow(
                    color: Colors.transparent,
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
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
                      : GameTheme.textDark.withValues(alpha: 0.5),
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
                style: GameTheme.hudPlayerName.copyWith(
                  fontWeight: isCurrentTurn ? FontWeight.w600 : FontWeight.w500,
                  color: isCurrentTurn
                      ? GameTheme.textDark
                      : GameTheme.textDark.withValues(alpha: 0.85),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Animated Balance
            AnimatedDefaultTextStyle(
              duration: MotionDurations.fast.safe,
              style: GameTheme.hudBalance.copyWith(
                color: _isAnimating
                    ? glowColor
                    : (rank == 1 ? GameTheme.goldAccent : GameTheme.textDark),
                shadows: const [Shadow(color: Colors.black54, blurRadius: 2)],
              ),
              child: Text("₺$_displayedBalance"),
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
                  : GameTheme.textDark.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),

          // Log text
          Expanded(
            child: Text(
              text,
              style: GameTheme.hudLogEntry.copyWith(
                fontWeight: isLatest ? FontWeight.w500 : FontWeight.normal,
                color: isLatest
                    ? GameTheme.textDark
                    : GameTheme.textDark.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
