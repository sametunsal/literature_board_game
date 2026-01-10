import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/game_theme.dart';

/// Settings screen with premium Literature theme styling
/// Provides options for sound, music, and language preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local state for toggles (not persisted yet)
  bool _soundEnabled = true;
  bool _musicEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: GameTheme.tableDecoration,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildMainCard(),
            ),
          ),
        ),
      ),
    );
  }

  /// Main parchment-styled card container
  Widget _buildMainCard() {
    return Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GameTheme.parchmentColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 50,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER with back button
              _buildHeader(),
              const SizedBox(height: 24),

              // SETTINGS OPTIONS
              _buildSettingsSection(),
              const SizedBox(height: 24),

              // DIVIDER
              _buildDivider(),
              const SizedBox(height: 20),

              // ABOUT SECTION
              _buildAboutSection(),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.15, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  /// Header with back button and title
  Widget _buildHeader() {
    return Row(
      children: [
        // BACK BUTTON
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: GameTheme.goldAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GameTheme.goldAccent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back,
              color: GameTheme.goldAccent,
              size: 22,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // TITLE
        Expanded(
          child: Text(
            "AYARLAR",
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: GameTheme.textDark,
              letterSpacing: 1.5,
            ),
          ),
        ),

        // SETTINGS ICON
        Icon(Icons.settings, color: GameTheme.goldAccent, size: 32),
      ],
    );
  }

  /// Settings options section
  Widget _buildSettingsSection() {
    return Column(
      children: [
        // SOUND EFFECTS
        _SettingsTile(
          icon: Icons.volume_up,
          label: "Ses Efektleri",
          subtitle: "Oyun içi ses efektleri",
          trailing: _buildSwitch(_soundEnabled, (val) {
            setState(() => _soundEnabled = val);
          }),
        ),

        const SizedBox(height: 12),

        // BACKGROUND MUSIC
        _SettingsTile(
          icon: Icons.music_note,
          label: "Arka Plan Müziği",
          subtitle: "Oyun müziği",
          trailing: _buildSwitch(_musicEnabled, (val) {
            setState(() => _musicEnabled = val);
          }),
        ),

        const SizedBox(height: 12),

        // LANGUAGE
        _SettingsTile(
          icon: Icons.language,
          label: "Dil",
          subtitle: "Uygulama dili",
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: GameTheme.goldAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "🇹🇷 Türkçe",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: GameTheme.textDark,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.lock,
                  size: 14,
                  color: GameTheme.textDark.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Styled switch widget
  Widget _buildSwitch(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value
              ? GameTheme.goldAccent
              : GameTheme.textDark.withValues(alpha: 0.2),
          boxShadow: [
            BoxShadow(
              color: value
                  ? GameTheme.goldAccent.withValues(alpha: 0.3)
                  : Colors.transparent,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Decorative divider
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
                  GameTheme.goldAccent.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.info_outline,
            size: 18,
            color: GameTheme.goldAccent.withValues(alpha: 0.7),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GameTheme.goldAccent.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// About section with version info
  Widget _buildAboutSection() {
    return Column(
      children: [
        Text(
          "HAKKINDA",
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: GameTheme.textDark.withValues(alpha: 0.7),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),

        // App info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // App icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: GameTheme.goldAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu_book,
                  size: 32,
                  color: GameTheme.goldAccent,
                ),
              ),
              const SizedBox(height: 12),

              // App name
              Text(
                "Edebiyat Oyunu",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: GameTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),

              // Version
              Text(
                "Versiyon 1.0.0",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: GameTheme.textDark.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),

              // Developer
              Text(
                "Geliştirici: Samet Ünsal",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: GameTheme.textDark.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual settings tile widget
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: GameTheme.goldAccent.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // ICON
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: GameTheme.goldAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: GameTheme.goldAccent, size: 22),
          ),

          const SizedBox(width: 14),

          // LABEL & SUBTITLE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: GameTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: GameTheme.textDark.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // TRAILING WIDGET
          trailing,
        ],
      ),
    );
  }
}
