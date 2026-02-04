import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/motion/motion_constants.dart';
import '../../core/managers/audio_manager.dart';
import '../../core/theme/game_theme.dart';

/// Settings screen - "The Library Cabinet"
/// Ottoman Scholar themed with wood tones, glassmorphism, and lantern toggles
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
    _soundEnabled = AudioManager.instance.isSoundEnabled;
    _musicEnabled = AudioManager.instance.isMusicEnabled;

    // Breathing gradient animation (8 second loop)
    _gradientController = AnimationController(
      duration: MotionDurations.ambientGradient.safe,
      vsync: this,
    )..repeat(reverse: true);

    _backgroundColor = ColorTween(
      begin: const Color(0xFFE8DED0), // Wood tone light
      end: const Color(0xFFDDD0C0), // Wood tone dark
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
              // ANIMATED WOOD TONE BACKGROUND
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

  /// Animated breathing wood tone background
  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            _backgroundColor.value ?? const Color(0xFFE8DED0),
            const Color(0xFFD0C5B5), // Darker wood tone edge
          ],
        ),
      ),
    );
  }

  /// Back button with ornate keyhole style
  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: GameTheme.ottomanBackground,
            shape: BoxShape.circle,
            border: Border.all(
              color: GameTheme.ottomanGold,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: GameTheme.ottomanGoldShadow.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back,
            color: GameTheme.ottomanAccent,
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

  /// Screen title with Ottoman styling
  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: GameTheme.ottomanGold.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "AYARLAR",
        style: GoogleFonts.cinzelDecorative(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: GameTheme.ottomanAccent,
          letterSpacing: 6,
        ),
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
          _OttomanSettingCard(
            icon: Icons.volume_up_rounded,
            label: "Ses Efektleri",
            subtitle: "Oyun içi ses efektleri",
            trailing: _buildLanternToggle(_soundEnabled, (val) {
              setState(() => _soundEnabled = val);
              AudioManager.instance.toggleSound(val);
            }),
            delay: 0,
          ),

          const SizedBox(height: 14),

          // BACKGROUND MUSIC
          _OttomanSettingCard(
            icon: Icons.music_note_rounded,
            label: "Arka Plan Müziği",
            subtitle: "Oyun müziği",
            trailing: _buildLanternToggle(_musicEnabled, (val) {
              setState(() => _musicEnabled = val);
              AudioManager.instance.toggleMusic(val);
            }),
            delay: 100,
          ),

          const SizedBox(height: 14),

          // LANGUAGE (locked)
          _OttomanSettingCard(
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

  /// Ottoman lantern-style toggle switch
  Widget _buildLanternToggle(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: MotionDurations.fast.safe,
        width: 64,
        height: 36,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value
              ? GameTheme.ottomanAccent
              : GameTheme.ottomanSepia.withValues(alpha: 0.3),
          border: Border.all(
            color: value
                ? GameTheme.ottomanAccent
                : GameTheme.ottomanSepia.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: GameTheme.ottomanAccent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: AnimatedAlign(
          duration: MotionDurations.fast.safe,
          curve: MotionCurves.emphasized,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: value
                    ? [
                        GameTheme.ottomanGold,
                        GameTheme.ottomanGoldLight,
                      ]
                    : [
                        GameTheme.ottomanBackgroundAlt,
                        GameTheme.ottomanBackground,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
                if (value)
                  BoxShadow(
                    color: GameTheme.ottomanGold.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: value
                ? Icon(
                    Icons.nights_stay,
                    size: 16,
                    color: Colors.white,
                  )
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
        color: GameTheme.ottomanGold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: GameTheme.ottomanGold.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "🇹🇷 Türkçe",
            style: GoogleFonts.crimsonText(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: GameTheme.ottomanGoldShadow,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.lock_rounded,
            size: 14,
            color: GameTheme.ottomanGold,
          ),
        ],
      ),
    );
  }

  /// About section with Ottoman card styling
  Widget _buildAboutCard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: GameTheme.ottomanBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: GameTheme.ottomanGold.withValues(alpha: 0.3),
            width: 1,
          ),
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
            // Section title with decorative line
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 1,
                  color: GameTheme.ottomanGold.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 12),
                Text(
                  "HAKKINDA",
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: GameTheme.ottomanAccent,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 30,
                  height: 1,
                  color: GameTheme.ottomanGold.withValues(alpha: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // App icon with gold frame
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: GameTheme.ottomanGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: GameTheme.ottomanGold,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 32,
                color: GameTheme.ottomanGold,
              ),
            ),
            const SizedBox(height: 14),

            // App name
            Text(
              "EDEBİNA",
              style: GoogleFonts.cinzelDecorative(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: GameTheme.ottomanAccent,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 4),

            // Subtitle
            Text(
              "Edebiyat Macerası",
              style: GoogleFonts.crimsonText(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: GameTheme.ottomanTextSecondary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),

            // Divider
            Container(
              width: 60,
              height: 1,
              color: GameTheme.ottomanBorder,
            ),
            const SizedBox(height: 12),

            // Version
            Text(
              "Versiyon 1.0.0",
              style: GoogleFonts.crimsonText(
                fontSize: 12,
                color: GameTheme.ottomanTextSecondary,
              ),
            ),
            const SizedBox(height: 4),

            // Developer
            Text(
              "Geliştirici: Samet Ünsal",
              style: GoogleFonts.crimsonText(
                fontSize: 11,
                color: GameTheme.ottomanTextSecondary.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
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

/// Ottoman-themed settings tile widget
class _OttomanSettingCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Widget trailing;
  final int delay;

  const _OttomanSettingCard({
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
        color: GameTheme.ottomanBackground.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: GameTheme.ottomanBorder.withValues(alpha: 0.5),
          width: 1,
        ),
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
          // ICON - Ottoman styled container
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: GameTheme.ottomanAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: GameTheme.ottomanAccent.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: GameTheme.ottomanAccent, size: 24),
          ),

          const SizedBox(width: 16),

          // LABEL & SUBTITLE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.crimsonText(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: GameTheme.ottomanText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.crimsonText(
                    fontSize: 12,
                    color: GameTheme.ottomanTextSecondary,
                    fontStyle: FontStyle.italic,
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
