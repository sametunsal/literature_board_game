import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player.dart';
import '../providers/game_notifier.dart';
import '../core/theme/game_theme.dart';
import '../utils/sound_manager.dart';
import 'main_menu_screen.dart';

/// Game Over dialog showing winner and final standings
class GameOverDialog extends ConsumerWidget {
  const GameOverDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    // Sort players by net worth (descending)
    final rankedPlayers = List<Player>.from(state.players);
    rankedPlayers.sort(
      (a, b) => notifier
          .calculateNetWorth(b)
          .compareTo(notifier.calculateNetWorth(a)),
    );

    final winner = rankedPlayers.isNotEmpty ? rankedPlayers.first : null;

    return Center(
          child: Container(
            width: 360,
            constraints: const BoxConstraints(maxHeight: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: GameTheme.parchmentColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: GameTheme.goldAccent, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TROPHY ICON
                Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            GameTheme.goldAccent,
                            GameTheme.goldAccent.withValues(alpha: 0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: GameTheme.goldAccent.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        size: 48,
                        color: Colors.white,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 1000.ms,
                    ),

                const SizedBox(height: 20),

                // WINNER TITLE
                Text(
                  "OYUN BİTTİ!",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: GameTheme.textDark,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 8),

                // WINNER NAME
                if (winner != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: winner.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: winner.color, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: GameTheme.goldAccent, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          "KAZANAN: ${winner.name}",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: GameTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // DIVIDER
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: GameTheme.goldAccent.withValues(alpha: 0.4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "SKOR TABLOSU",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: GameTheme.textDark.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: GameTheme.goldAccent.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // PLAYER RANKINGS
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: rankedPlayers.length,
                    itemBuilder: (context, index) {
                      final player = rankedPlayers[index];
                      final netWorth = notifier.calculateNetWorth(player);
                      final isWinner = index == 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isWinner
                              ? GameTheme.goldAccent.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: isWinner
                              ? Border.all(
                                  color: GameTheme.goldAccent,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            // RANK
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _getRankColor(index),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  "${index + 1}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // PLAYER COLOR DOT
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: player.color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // NAME
                            Expanded(
                              child: Text(
                                player.name,
                                style: GoogleFonts.poppins(
                                  fontSize: isWinner ? 16 : 14,
                                  fontWeight: isWinner
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: GameTheme.textDark,
                                ),
                              ),
                            ),

                            // NET WORTH
                            Text(
                              "₺$netWorth",
                              style: GoogleFonts.poppins(
                                fontSize: isWinner ? 16 : 14,
                                fontWeight: FontWeight.bold,
                                color: isWinner
                                    ? GameTheme.goldAccent
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // MENU BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      SoundManager.instance.playClick();
                      // Reset orientation
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                      ]);
                      // Navigate to main menu
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const MainMenuScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home, size: 22),
                    label: Text(
                      "ANA MENÜYE DÖN",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameTheme.goldAccent,
                      foregroundColor: GameTheme.textDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.elasticOut,
        );
  }

  Color _getRankColor(int index) {
    return switch (index) {
      0 => const Color(0xFFFFD700), // Gold
      1 => const Color(0xFFC0C0C0), // Silver
      2 => const Color(0xFFCD7F32), // Bronze
      _ => Colors.grey.shade500,
    };
  }
}
