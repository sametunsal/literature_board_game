import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/motion/motion_constants.dart';
import '../../core/managers/sound_manager.dart';

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
    _soundEnabled = SoundManager.instance.isSoundEnabled;
    _musicEnabled = SoundManager.instance.isMusicEnabled;

    // Breathing gradient animation (8 second loop)
    _gradientController = AnimationController(
      duration: MotionDurations.ambientGradient.safe,
      vsync: this,
    )..repeat(reverse: true);

    _backgroundColor =
        ColorTween(
          begin: const Color(0xFFF5F5F5), // Light grey
          end: const Color(0xFFE8E8E8), // Slightly darker grey
        ).animate(
          CurvedAnimation(
            parent: _gradientController,
            curve: MotionCurves.standard,
          ),
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
            _backgroundColor.value ?? const Color(0xFFF5F5F5),
            const Color(0xFFE0E0E0), // Light grey edge
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
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                    size: 24,
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
          style: GoogleFonts.poppins(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 6,
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.3, end: 0, duration: 600.ms);
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
              SoundManager.instance.setSoundEnabled(val);
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
              SoundManager.instance.setMusicEnabled(val);
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
        duration: MotionDurations.fast.safe,
        width: 60,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value ? Colors.blue : Colors.grey.shade300,
          border: Border.all(
            color: value ? Colors.blue : Colors.grey.shade400,
            width: 1.5,
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: AnimatedAlign(
          duration: MotionDurations.fast.safe,
          curve: MotionCurves.emphasized,
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
                ? Icon(Icons.check, size: 16, color: Colors.blue)
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
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
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
              color: Colors.amber.shade700,
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.lock_rounded, size: 14, color: Colors.amber.shade400),
        ],
      ),
    );
  }

  /// About section glassmorphism card
  Widget _buildAboutCard() {
    return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Section title
                Text(
                  "HAKKINDA",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),

                // App icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber, width: 2),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 32,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 14),

                // App name
                Text(
                  "EDEBİNA",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),

                // Subtitle
                Text(
                  "Edebiyat Macerası",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),

                // Divider
                Container(width: 60, height: 1, color: Colors.grey.shade300),
                const SizedBox(height: 12),

                // Version
                Text(
                  "Versiyon 1.0.0",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),

                // Developer
                Text(
                  "Geliştirici: Samet Ünsal",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms);
  }
}

/// Clean settings tile widget
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
    return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.blue, size: 24),
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
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // TRAILING WIDGET
              trailing,
            ],
          ),
        )
        .animate()
        .fadeIn(
          delay: MotionDurations.fast.safe + Duration(milliseconds: delay),
          duration: MotionDurations.medium.safe,
        )
        .slideY(
          begin: 0.15,
          end: 0,
          duration: MotionDurations.medium.safe,
          curve: MotionCurves.standard,
        );
  }
}
