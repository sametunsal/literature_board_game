import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/game_theme.dart';

/// Pause menu dialog with resume, settings, and exit options
/// Styled to match the premium Literature Board Game theme
class PauseDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onSettings;
  final VoidCallback onExit;

  const PauseDialog({
    super.key,
    required this.onResume,
    required this.onSettings,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: GameTheme.parchmentColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HEADER ICON
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: GameTheme.goldAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pause_circle_filled,
                    size: 40,
                    color: GameTheme.goldAccent,
                  ),
                ),
                const SizedBox(height: 16),

                // TITLE
                Text(
                  "OYUN DURAKLATILDI",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: GameTheme.textDark,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),

                // SUBTITLE
                Text(
                  "Ne yapmak istersiniz?",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: GameTheme.textDark.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 28),

                // DIVIDER
                _buildDivider(),
                const SizedBox(height: 24),

                // RESUME BUTTON
                _MenuButton(
                  label: "OYUNA DÖN",
                  icon: Icons.play_arrow,
                  color: const Color(0xFF388E3C), // Green
                  onPressed: onResume,
                ),
                const SizedBox(height: 12),

                // SETTINGS BUTTON
                _MenuButton(
                  label: "AYARLAR",
                  icon: Icons.settings,
                  color: const Color(0xFF546E7A), // Blue-grey
                  onPressed: onSettings,
                ),
                const SizedBox(height: 12),

                // EXIT BUTTON
                _MenuButton(
                  label: "ÇIKIŞ",
                  icon: Icons.exit_to_app,
                  color: const Color(0xFFD32F2F), // Red
                  onPressed: onExit,
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  GameTheme.goldAccent.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.menu_book,
            size: 16,
            color: GameTheme.goldAccent.withValues(alpha: 0.6),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GameTheme.goldAccent.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Styled menu button with icon, label, and color
class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 4,
          shadowColor: color.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
