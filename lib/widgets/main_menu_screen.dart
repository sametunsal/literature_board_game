import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/game_theme.dart';
import '../providers/theme_notifier.dart';
import '../services/streak_service.dart';
import 'setup_screen.dart';
import 'settings_screen.dart';
import 'streak_candle_widget.dart';

/// Main menu screen with EDEBİNA branding - V2.6 with Theme Toggle
/// Provides navigation to Play, Settings, and About
class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
  int _streakDays = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initStreak();
  }

  Future<void> _initStreak() async {
    final streakDays = await StreakService.instance.checkAndUpdateStreak();
    if (mounted) {
      setState(() {
        _streakDays = streakDays;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ═══════════════════════════════════════════════════════════════
          // LAYER 1 (Bottom): Library Room Background Image
          // ═══════════════════════════════════════════════════════════════
          Image.asset(
            'assets/images/library_room.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // ═══════════════════════════════════════════════════════════════
          // LAYER 2 (Middle): Dark Color Overlay for Contrast
          // ═══════════════════════════════════════════════════════════════
          Container(
            color: GameTheme.tableBackgroundColor.withValues(alpha: 0.85),
          ),

          // ═══════════════════════════════════════════════════════════════
          // LAYER 3 (Top): Paper Noise Texture - Tactile Rebellion Effect
          // ═══════════════════════════════════════════════════════════════
          Opacity(
            opacity: 0.15,
            child: Image.asset(
              'assets/images/paper_noise.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              colorBlendMode: BlendMode.multiply,
              color: Colors.white,
            ),
          ),

          // ═══════════════════════════════════════════════════════════════
          // CONTENT LAYER: Menu UI
          // ═══════════════════════════════════════════════════════════════
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO
                  _buildLogo(),
                  const SizedBox(height: 24),

                  // TITLE
                  _buildTitle(),
                  const SizedBox(height: 8),

                  // SUBTITLE
                  _buildSubtitle(),
                  const SizedBox(height: 48),

                  // MENU BUTTONS
                  _buildMenuButtons(context),
                ],
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════════════
          // TOP-RIGHT: Theme Toggle + Streak Candle
          // ═══════════════════════════════════════════════════════════════
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child:
                Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // THEME TOGGLE BUTTON
                        _buildThemeToggle(),
                        const SizedBox(height: 12),
                        // STREAK CANDLE
                        if (!_isLoading)
                          StreakCandleWidget(
                            streakDays: _streakDays,
                            size: 50,
                            isLit: _streakDays > 0,
                          ),
                      ],
                    )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 600.ms)
                    .slideY(
                      begin: -0.3,
                      end: 0,
                      delay: 800.ms,
                      duration: 500.ms,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: GameTheme.goldAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: GameTheme.goldAccent.withValues(alpha: 0.4),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: GameTheme.goldAccent.withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(Icons.menu_book, size: 45, color: GameTheme.goldAccent),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 800.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildTitle() {
    return Text(
          "EDEBİNA",
          style: GoogleFonts.cinzel(
            fontSize: 52,
            fontWeight: FontWeight.bold,
            color: GameTheme.textDark, // Antique Lace - premium readability
            letterSpacing: 10,
            shadows: [
              // Glow effect for depth
              Shadow(
                color: GameTheme.goldAccent.withValues(alpha: 0.3),
                blurRadius: 20,
              ),
              Shadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 12,
                offset: const Offset(2, 4),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 600.ms);
  }

  Widget _buildSubtitle() {
    return Text(
      "Türk Edebiyatı Masa Oyunu",
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: GameTheme.textDark.withValues(alpha: 0.6),
        letterSpacing: 2,
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms);
  }

  /// Build theme toggle button (Sun/Moon icons)
  Widget _buildThemeToggle() {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;

    return GestureDetector(
      onTap: () {
        ref.read(themeProvider.notifier).toggleTheme();
      },
      child:
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? GameTheme.goldAccent.withValues(alpha: 0.4)
                    : GameTheme.copperAccent.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? GameTheme.goldAccent.withValues(alpha: 0.2)
                      : GameTheme.copperAccent.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              size: 26,
              color: isDark ? GameTheme.goldAccent : GameTheme.copperAccent,
            ),
          ).animate().scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
            duration: 200.ms,
          ),
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Column(
      children: [
        // OYNA (Play) Button - Burnished Copper CTA
        _MenuButton(
              label: "OYNA",
              icon: Icons.play_arrow,
              color: GameTheme.copperAccent, // Burnished Copper for primary CTA
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SetupScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
            )
            .animate()
            .fadeIn(delay: 500.ms)
            .slideX(begin: -0.2, end: 0, delay: 500.ms),

        const SizedBox(height: 16),

        // AYARLAR (Settings) Button
        _MenuButton(
              label: "AYARLAR",
              icon: Icons.settings,
              color: GameTheme.textDark.withValues(alpha: 0.8),
              isSecondary: true,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            )
            .animate()
            .fadeIn(delay: 600.ms)
            .slideX(begin: -0.2, end: 0, delay: 600.ms),

        const SizedBox(height: 16),

        // HAKKINDA (About) Button
        _MenuButton(
              label: "HAKKINDA",
              icon: Icons.info_outline,
              color: GameTheme.textDark.withValues(alpha: 0.8),
              isSecondary: true,
              onPressed: () => _showAboutDialog(context),
            )
            .animate()
            .fadeIn(delay: 700.ms)
            .slideX(begin: -0.2, end: 0, delay: 700.ms),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameTheme.parchmentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "EDEBİNA",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: GameTheme.goldAccent,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Türk Edebiyatı Temalı Masa Oyunu",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: GameTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Versiyon 1.0.0",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: GameTheme.textDark.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "© 2026 EDEBİNA",
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: GameTheme.textDark.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("KAPAT", style: TextStyle(color: GameTheme.goldAccent)),
          ),
        ],
      ),
    );
  }
}

/// Styled menu button widget
class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isSecondary;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary
              ? Colors.white.withValues(alpha: 0.1)
              : color,
          foregroundColor: isSecondary ? color : GameTheme.textDark,
          elevation: isSecondary ? 0 : 6,
          shadowColor: isSecondary ? Colors.transparent : Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSecondary
                ? BorderSide(color: color.withValues(alpha: 0.4), width: 1)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
