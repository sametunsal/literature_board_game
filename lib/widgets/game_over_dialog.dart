import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../models/player.dart';
import '../providers/game_notifier.dart';
import '../core/theme/game_theme.dart';
import '../utils/sound_manager.dart';
import 'main_menu_screen.dart';
import 'game_log.dart' show literatureIcons;

/// Premium Game Over dialog with victory animations
class GameOverDialog extends ConsumerStatefulWidget {
  const GameOverDialog({super.key});

  @override
  ConsumerState<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends ConsumerState<GameOverDialog>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _counterController;
  late Animation<double> _counterAnimation;

  int _displayedMoney = 0;

  @override
  void initState() {
    super.initState();

    // Continuous confetti
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 20),
    );
    _confettiController.play();

    // Money counter animation
    _counterController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    final state = ref.read(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    final rankedPlayers = List<Player>.from(state.players);
    rankedPlayers.sort(
      (a, b) => notifier
          .calculateNetWorth(b)
          .compareTo(notifier.calculateNetWorth(a)),
    );

    final winnerNetWorth = rankedPlayers.isNotEmpty
        ? notifier.calculateNetWorth(rankedPlayers.first)
        : 0;

    _counterAnimation = Tween<double>(begin: 0, end: winnerNetWorth.toDouble())
        .animate(
          CurvedAnimation(
            parent: _counterController,
            curve: Curves.easeOutCubic,
          ),
        );

    _counterAnimation.addListener(() {
      setState(() {
        _displayedMoney = _counterAnimation.value.toInt();
      });
    });

    // Start counter after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _counterController.forward();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return Stack(
      children: [
        // Continuous confetti background
        ...List.generate(3, (i) {
          return Align(
            alignment: [
              Alignment.topLeft,
              Alignment.topCenter,
              Alignment.topRight,
            ][i],
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.directional,
              blastDirection: math.pi / 2, // Down
              emissionFrequency: 0.03,
              numberOfParticles: 15,
              gravity: 0.15,
              colors: const [
                Color(0xFFFFD700), // Gold
                Color(0xFF1E88E5), // Blue
                Color(0xFFEC407A), // Pink
                Color(0xFF43A047), // Green
                Color(0xFFFF9800), // Orange
                Color(0xFF9C27B0), // Purple
                Colors.white,
              ],
              createParticlePath: _drawStar,
            ),
          );
        }),

        // Main dialog
        Center(
          child:
              Container(
                    width: 420,
                    constraints: const BoxConstraints(maxHeight: 600),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      // Premium dark background
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1A1A2E),
                          const Color(0xFF16213E),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: GameTheme.goldAccent, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: GameTheme.goldAccent.withValues(alpha: 0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          blurRadius: 50,
                          offset: const Offset(0, 25),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Trophy icon with pulsating glow
                          _buildTrophy()
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.08, 1.08),
                                duration: 1200.ms,
                              )
                              .then()
                              .shimmer(
                                duration: 2000.ms,
                                color: GameTheme.goldAccent.withValues(
                                  alpha: 0.3,
                                ),
                              ),

                          const SizedBox(height: 24),

                          // "VICTORY!" title
                          Text(
                                "🏆 ZAFER! 🏆",
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: GameTheme.goldAccent,
                                  letterSpacing: 3,
                                  shadows: [
                                    Shadow(
                                      color: GameTheme.goldAccent.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 600.ms)
                              .slideY(begin: -0.3, end: 0, duration: 600.ms),

                          const SizedBox(height: 20),

                          // Winner card
                          if (winner != null)
                            _buildWinnerCard(winner, notifier),

                          const SizedBox(height: 28),

                          // Stats section
                          _buildStats(winner, rankedPlayers, notifier),

                          const SizedBox(height: 28),

                          // Menu button
                          _buildMenuButton(context),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    duration: 700.ms,
                    curve: Curves.easeOutBack,
                  ),
        ),
      ],
    );
  }

  Widget _buildTrophy() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            GameTheme.goldAccent,
            GameTheme.goldAccent.withValues(alpha: 0.6),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: GameTheme.goldAccent.withValues(alpha: 0.6),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: const Icon(Icons.emoji_events, size: 60, color: Colors.white),
    );
  }

  Widget _buildWinnerCard(Player winner, GameNotifier notifier) {
    final winnerIcon = winner.iconIndex < literatureIcons.length
        ? literatureIcons[winner.iconIndex]
        : Icons.person;

    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                winner.color.withValues(alpha: 0.25),
                winner.color.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: GameTheme.goldAccent, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: winner.color.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Winner avatar
              Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(winner.color, Colors.white, 0.3)!,
                          winner.color,
                          Color.lerp(winner.color, Colors.black, 0.2)!,
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: GameTheme.goldAccent, width: 3),
                    ),
                    child: Icon(winnerIcon, size: 36, color: Colors.white),
                  )
                  .animate(delay: 300.ms)
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(),

              const SizedBox(height: 12),

              // Winner name
              Text(
                    winner.name.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  )
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.2, end: 0),

              const SizedBox(height: 16),

              // Animated money counter
              Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: GameTheme.goldAccent,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "₺$_displayedMoney",
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: GameTheme.goldAccent,
                          shadows: [
                            Shadow(
                              color: GameTheme.goldAccent.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                  .animate(delay: 700.ms)
                  .fadeIn(duration: 300.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    curve: Curves.easeOut,
                  ),
            ],
          ),
        )
        .animate(delay: 400.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildStats(
    Player? winner,
    List<Player> rankedPlayers,
    GameNotifier notifier,
  ) {
    if (winner == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Staggered stat items
        _buildStatItem(
          Icons.account_balance_wallet,
          "Nakit",
          "₺${winner.balance}",
          delay: 900,
        ),
        const SizedBox(height: 12),
        _buildStatItem(
          Icons.business,
          "Mülkler",
          "${winner.ownedTiles.length} Adet",
          delay: 1100,
        ),
        const SizedBox(height: 12),
        _buildStatItem(
          Icons.leaderboard,
          "Sıralama",
          rankedPlayers.length > 1
              ? "1 / ${rankedPlayers.length}"
              : "Tek Oyuncu",
          delay: 1300,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value, {
    required int delay,
  }) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Icon(icon, color: GameTheme.goldAccent, size: 24),
              const SizedBox(width: 14),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        )
        .animate(delay: delay.ms)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.3, end: 0, curve: Curves.easeOut);
  }

  Widget _buildMenuButton(BuildContext context) {
    return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              SoundManager.instance.playClick();
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ]);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.home, size: 24),
            label: Text(
              "ANA MENÜYE DÖN",
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: GameTheme.goldAccent,
              foregroundColor: const Color(0xFF1A1A2E),
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 8,
              shadowColor: GameTheme.goldAccent.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        )
        .animate(delay: 1500.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  /// Custom star-shaped particle path for confetti
  Path _drawStar(Size size) {
    final path = Path();
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double outerRadius = size.width / 2;
    final double innerRadius = size.width / 4;
    const int points = 5;
    const double rotation = -math.pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final double radius = i.isEven ? outerRadius : innerRadius;
      final double angle = rotation + (i * math.pi / points);
      final double x = centerX + radius * math.cos(angle);
      final double y = centerY + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }
}
