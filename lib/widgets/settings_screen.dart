import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/game_theme.dart';

/// Settings screen with premium Dark Academia theme styling
/// Matches the main menu aesthetic with animated gradient and glassmorphism
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  // Local state for toggles
  bool _soundEnabled = true;
  bool _musicEnabled = true;

  // Animated gradient background
  late AnimationController _gradientController;
  late Animation<Color?> _backgroundColor;

  @override
  void initState() {
    super.initState();

    // Breathing gradient animation (8 second loop) - matches main menu
    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundColor =
        ColorTween(
          begin: const Color(0xFF1B2A1E), // Deep Forest Green
          end: const Color(0xFF2C241B), // Antique Brown
        ).animate(
          CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundColor,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // ANIMATED GRADIENT BACKGROUND
              _buildAnimatedBackground(),

              // MAIN CONTENT
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: _buildContent(),
                  ),
                ),
              ),

              // BACK BUTTON (top-left)
              _buildBackButton(),
            ],
          );
        },
      ),
    );
  }

  /// Animated breathing gradient background
  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            _backgroundColor.value ?? const Color(0xFF1B2A1E),
            const Color(0xFF0F0E0D), // Very dark edge
          ],
        ),
      ),
    );
  }

  /// Back button with glassmorphism
  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child:
          GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: GameTheme.goldAccent.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: GameTheme.goldAccent,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideX(begin: -0.3, end: 0),
    );
  }

  /// Main content area
  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // TITLE
        _buildTitle(),
        const SizedBox(height: 32),

        // SETTINGS CARDS
        _buildSettingsCards(),
        const SizedBox(height: 24),

        // ABOUT SECTION
        _buildAboutCard(),
      ],
    );
  }

  /// Screen title with glow effect
  Widget _buildTitle() {
    return Text(
          "AYARLAR",
          style: GoogleFonts.playfairDisplay(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: GameTheme.goldAccent,
            letterSpacing: 6,
            shadows: [
              Shadow(
                color: GameTheme.goldAccent.withValues(alpha: 0.6),
                blurRadius: 30,
              ),
              Shadow(
                color: GameTheme.goldAccent.withValues(alpha: 0.4),
                blurRadius: 20,
              ),
              Shadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.3, end: 0, duration: 600.ms)
        .then()
        .shimmer(
          duration: 2500.ms,
          color: GameTheme.goldAccent.withValues(alpha: 0.3),
        );
  }

  /// Settings section with glassmorphism cards
  Widget _buildSettingsCards() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        children: [
          // SOUND EFFECTS
          _GlassmorphicSettingCard(
            icon: Icons.volume_up_rounded,
            label: "Ses Efektleri",
            subtitle: "Oyun içi ses efektleri",
            trailing: _buildGoldSwitch(_soundEnabled, (val) {
              setState(() => _soundEnabled = val);
            }),
            delay: 0,
          ),

          const SizedBox(height: 14),

          // BACKGROUND MUSIC
          _GlassmorphicSettingCard(
            icon: Icons.music_note_rounded,
            label: "Arka Plan Müziği",
            subtitle: "Oyun müziği",
            trailing: _buildGoldSwitch(_musicEnabled, (val) {
              setState(() => _musicEnabled = val);
            }),
            delay: 100,
          ),

          const SizedBox(height: 14),

          // LANGUAGE (locked)
          _GlassmorphicSettingCard(
            icon: Icons.language_rounded,
            label: "Dil",
            subtitle: "Uygulama dili",
            trailing: _buildLanguageBadge(),
            delay: 200,
          ),
        ],
      ),
    );
  }

  /// Premium gold toggle switch
  Widget _buildGoldSwitch(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 60,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value
              ? GameTheme.goldAccent
              : Colors.white.withValues(alpha: 0.15),
          border: Border.all(
            color: value
                ? GameTheme.goldAccent
                : Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: GameTheme.goldAccent.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: value
                ? Icon(Icons.check, size: 16, color: GameTheme.goldAccent)
                : null,
          ),
        ),
      ),
    );
  }

  /// Language badge (locked)
  Widget _buildLanguageBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: GameTheme.goldAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: GameTheme.goldAccent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "🇹🇷 Türkçe",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.lock_rounded,
            size: 14,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  /// About section glassmorphism card
  Widget _buildAboutCard() {
    return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: GameTheme.goldAccent.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Section title
                    Text(
                      "HAKKINDA",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: GameTheme.goldAccent.withValues(alpha: 0.8),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // App icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            GameTheme.goldAccent.withValues(alpha: 0.3),
                            GameTheme.goldAccent.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: GameTheme.goldAccent.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 32,
                        color: GameTheme.goldAccent,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // App name
                    Text(
                      "EDEBİNA",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      "Edebiyat Macerası",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Divider
                    Container(
                      width: 60,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            GameTheme.goldAccent.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Version
                    Text(
                      "Versiyon 1.0.0",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Developer
                    Text(
                      "Geliştirici: Samet Ünsal",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms);
  }
}

/// Glassmorphic settings tile widget
class _GlassmorphicSettingCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Widget trailing;
  final int delay;

  const _GlassmorphicSettingCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.trailing,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // ICON
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          GameTheme.goldAccent.withValues(alpha: 0.25),
                          GameTheme.goldAccent.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: GameTheme.goldAccent.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(icon, color: GameTheme.goldAccent, size: 24),
                  ),

                  const SizedBox(width: 16),

                  // LABEL & SUBTITLE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // TRAILING WIDGET
                  trailing,
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 200 + delay),
          duration: 400.ms,
        )
        .slideY(begin: 0.15, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
