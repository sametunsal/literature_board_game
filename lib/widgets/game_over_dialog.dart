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
import '../core/motion/motion_constants.dart';
import '../utils/sound_manager.dart';
import '../presentation/widgets/common/game_button.dart';
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
      duration: MotionDurations.confetti * 10, // 20 seconds
    );
    _confettiController.play();

    // Money counter animation
    _counterController = AnimationController(
      duration: MotionDurations.confetti,
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
            curve: MotionCurves.standard,
          ),
        );

    _counterAnimation.addListener(() {
      setState(() {
        _displayedMoney = _counterAnimation.value.toInt();
      });
    });

    // Start counter after a short delay
    Future.delayed(MotionDurations.slow, () {
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

    // Theme-aware tokens
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tokens = GameTheme.getTokens(isDarkMode);

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
                      // Theme-aware gradient background
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode
                            ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                            : [tokens.surface, tokens.surfaceAlt],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDarkMode ? tokens.accent : tokens.border,
                        width: isDarkMode ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: tokens.accent.withValues(
                            alpha: isDarkMode ? 0.3 : 0.15,
                          ),
                          blurRadius: 40,
                          spreadRadius: isDarkMode ? 10 : 5,
                        ),
                        BoxShadow(
                          color: tokens.shadow.withValues(
                            alpha: isDarkMode ? 0.8 : 0.2,
                          ),
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
                          _buildTrophy(tokens, isDarkMode)
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.08, 1.08),
                                duration: MotionDurations.slow * 2,
                              )
                              .then()
                              .shimmer(
                                duration: MotionDurations.confetti,
                                color: tokens.accent.withValues(alpha: 0.3),
                              ),

                          const SizedBox(height: 24),

                          // "VICTORY!" title
                          Text(
                                "🏆 ZAFER! 🏆",
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: tokens.accent,
                                  letterSpacing: 3,
                                  shadows: [
                                    Shadow(
                                      color: tokens.accent.withValues(
                                        alpha: isDarkMode ? 0.5 : 0.3,
                                      ),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                              )
                              .animate()
                              .fadeIn(
                                delay: MotionDurations.fast,
                                duration: MotionDurations.slow,
                              )
                              .slideY(
                                begin: -0.3,
                                end: 0,
                                duration: MotionDurations.slow,
                                curve: MotionCurves.standard,
                              ),

                          const SizedBox(height: 20),

                          // Winner card
                          if (winner != null)
                            _buildWinnerCard(
                              winner,
                              notifier,
                              tokens,
                              isDarkMode,
                            ),

                          const SizedBox(height: 28),

                          // Stats section
                          _buildStats(
                            winner,
                            rankedPlayers,
                            notifier,
                            tokens,
                            isDarkMode,
                          ),

                          const SizedBox(height: 28),

                          // Menu button
                          _buildMenuButton(context, tokens, isDarkMode),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: MotionDurations.dialog.safe)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    duration: MotionDurations.slow.safe,
                    curve: MotionCurves.emphasized,
                  ),
        ),
      ],
    );
  }

  Widget _buildTrophy(ThemeTokens tokens, bool isDarkMode) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [tokens.accent, tokens.accent.withValues(alpha: 0.6)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: tokens.accent.withValues(alpha: isDarkMode ? 0.6 : 0.4),
            blurRadius: 30,
            spreadRadius: isDarkMode ? 10 : 5,
          ),
        ],
      ),
      child: Icon(
        Icons.emoji_events,
        size: 60,
        color: isDarkMode ? Colors.white : tokens.textOnAccent,
      ),
    );
  }

  Widget _buildWinnerCard(
    Player winner,
    GameNotifier notifier,
    ThemeTokens tokens,
    bool isDarkMode,
  ) {
    final winnerIcon = winner.iconIndex < literatureIcons.length
        ? literatureIcons[winner.iconIndex]
        : Icons.person;

    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                winner.color.withValues(alpha: isDarkMode ? 0.25 : 0.15),
                winner.color.withValues(alpha: isDarkMode ? 0.15 : 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDarkMode
                  ? tokens.accent
                  : winner.color.withValues(alpha: 0.5),
              width: isDarkMode ? 2.5 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: winner.color.withValues(alpha: isDarkMode ? 0.3 : 0.15),
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
                      border: Border.all(
                        color: isDarkMode ? tokens.accent : winner.color,
                        width: 3,
                      ),
                    ),
                    child: Icon(winnerIcon, size: 36, color: Colors.white),
                  )
                  .animate(delay: MotionDurations.medium)
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: MotionDurations.dialog,
                    curve: MotionCurves.spring,
                  )
                  .fadeIn(),

              const SizedBox(height: 12),

              // Winner name
              Text(
                    winner.name.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : tokens.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  )
                  .animate(delay: MotionDurations.dialog)
                  .fadeIn(duration: MotionDurations.medium)
                  .slideX(begin: -0.2, end: 0, curve: MotionCurves.standard),

              const SizedBox(height: 16),

              // Animated money counter
              Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: tokens.accent,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "₺$_displayedMoney",
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: tokens.accent,
                          shadows: [
                            Shadow(
                              color: tokens.accent.withValues(
                                alpha: isDarkMode ? 0.5 : 0.3,
                              ),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                  .animate(delay: MotionDurations.slow)
                  .fadeIn(duration: MotionDurations.medium)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    curve: MotionCurves.standard,
                  ),
            ],
          ),
        )
        .animate(delay: MotionDurations.medium)
        .fadeIn(duration: MotionDurations.dialog)
        .slideY(begin: 0.2, end: 0, curve: MotionCurves.standard);
  }

  Widget _buildStats(
    Player? winner,
    List<Player> rankedPlayers,
    GameNotifier notifier,
    ThemeTokens tokens,
    bool isDarkMode,
  ) {
    if (winner == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Staggered stat items
        _buildStatItem(
          Icons.account_balance_wallet,
          "Nakit",
          "₺${winner.balance}",
          delay: MotionDurations.dice,
          tokens: tokens,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildStatItem(
          Icons.business,
          "Mülkler",
          "${winner.ownedTiles.length} Adet",
          delay: MotionDurations.dice + MotionDurations.fast,
          tokens: tokens,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildStatItem(
          Icons.leaderboard,
          "Sıralama",
          rankedPlayers.length > 1
              ? "1 / ${rankedPlayers.length}"
              : "Tek Oyuncu",
          delay: MotionDurations.dice + MotionDurations.medium,
          tokens: tokens,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value, {
    required Duration delay,
    required ThemeTokens tokens,
    required bool isDarkMode,
  }) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.08)
                : tokens.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.15)
                  : tokens.border,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: tokens.accent, size: 24),
              const SizedBox(width: 14),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: isDarkMode ? Colors.white70 : tokens.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : tokens.textPrimary,
                ),
              ),
            ],
          ),
        )
        .animate(delay: delay)
        .fadeIn(duration: MotionDurations.medium)
        .slideX(begin: 0.3, end: 0, curve: MotionCurves.standard);
  }

  Widget _buildMenuButton(
    BuildContext context,
    ThemeTokens tokens,
    bool isDarkMode,
  ) {
    return GameButton(
          label: "ANA MENÜYE DÖN",
          icon: Icons.home,
          variant: GameButtonVariant.primary,
          isFullWidth: true,
          customColor: tokens.accent,
          customTextColor: tokens.textOnAccent,
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
        )
        .animate(delay: MotionDurations.confetti * 0.75)
        .fadeIn(duration: MotionDurations.dialog)
        .slideY(begin: 0.2, end: 0, curve: MotionCurves.standard);
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
