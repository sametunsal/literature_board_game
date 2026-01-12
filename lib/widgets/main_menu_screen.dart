import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/game_theme.dart';
import 'setup_screen.dart';
import 'settings_screen.dart';

/// Main menu screen with EDEBİNA branding
/// Provides navigation to Play, Settings, and About
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF1B4721), // Table green at center
              Color(0xFF0D2818), // Darker at edges
            ],
          ),
        ),
        child: SafeArea(
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
          style: GoogleFonts.playfairDisplay(
            fontSize: 52,
            fontWeight: FontWeight.bold,
            color: GameTheme.goldAccent,
            letterSpacing: 8,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
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
        color: Colors.white.withValues(alpha: 0.6),
        letterSpacing: 2,
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms);
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Column(
      children: [
        // OYNA (Play) Button
        _MenuButton(
              label: "OYNA",
              icon: Icons.play_arrow,
              color: GameTheme.goldAccent,
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
              color: Colors.white70,
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
              color: Colors.white70,
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
