import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

import 'setup_screen.dart';
import '../dialogs/how_to_play_dialog.dart';
import '../dialogs/settings_dialog.dart';
import '../widgets/common/scholar_button.dart';
import '../widgets/common/ottoman_background.dart';
import '../../core/theme/game_theme.dart';
import '../../core/motion/motion_constants.dart';

/// Main Menu Screen - "The Scholar's Desk Entry"
/// Ottoman Scholar themed with aged paper, gold accents, and library atmosphere
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    // Enforce Portrait Mode for Menu
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Ambient animation controller
    _ambientController = AnimationController(
      duration: MotionDurations.ambientGradient.safe,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: OttomanBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // LOGO & TITLE SECTION
                  _buildLogoSection(),

                  const SizedBox(height: 60),

                  // MENU BUTTONS
                  _buildMenuButtons(),

                  const SizedBox(height: 40),

                  // DECORATIVE ELEMENTS
                  _buildDecorativeElements(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// App Bar with settings button (ornate keyhole style)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8),
          decoration: BoxDecoration(
            color: GameTheme.ottomanBackground,
            shape: BoxShape.circle,
            border: Border.all(
              color: GameTheme.ottomanGold,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: GameTheme.ottomanGoldShadow.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.settings_rounded,
              color: GameTheme.ottomanAccent,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const SettingsDialog(),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Logo section with animated quill decoration
  Widget _buildLogoSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive title sizing
        final titleSize = constraints.maxWidth < 350 ? 42.0 : 60.0;
        final subtitleSize = constraints.maxWidth < 350 ? 18.0 : 24.0;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                // Main Title: EDEBİNA
                Text(
                  'EDEBİNA',
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    color: GameTheme.ottomanAccent,
                    letterSpacing: 4,
                    height: 1.0,
                    shadows: [
                      Shadow(
                        color: GameTheme.ottomanGold.withValues(alpha: 0.4),
                        offset: const Offset(3, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      curve: Curves.easeOutBack,
                      duration: 800.ms,
                    ),

                const SizedBox(height: 8),

                // Drop Cap Decorative Element
                _buildDropCapDecoration(),

                const SizedBox(height: 12),

                // Subtitle: ANA MENÜ
                Text(
                  'ANA MENÜ',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: subtitleSize,
                    fontWeight: FontWeight.w600,
                    color: GameTheme.ottomanAccent.withValues(alpha: 0.7),
                    letterSpacing: 6,
                    height: 1.0,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),

            // Animated Quill Pen Decoration
            Positioned(
              top: constraints.maxWidth < 350 ? -5 : 10,
              right: constraints.maxWidth < 350 ? -20 : -30,
              child: AnimatedBuilder(
                animation: _ambientController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: math.sin(_ambientController.value * 2 * math.pi) *
                        0.1,
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        math.sin(_ambientController.value * 2 * math.pi) * -5,
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        size: constraints.maxWidth < 350 ? 28 : 36,
                        color: GameTheme.ottomanGold.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Drop Cap-style decorative element
  Widget _buildDropCapDecoration() {
    return Container(
      width: 60,
      height: 3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GameTheme.ottomanGold.withValues(alpha: 0.3),
            GameTheme.ottomanGold,
            GameTheme.ottomanGold.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    )
        .animate()
        .shimmer(
          duration: 2000.ms,
          color: GameTheme.ottomanGoldLight,
          angle: 0,
        );
  }

  /// Menu buttons with staggered animation
  Widget _buildMenuButtons() {
    return Column(
      children: [
        // Primary CTA: OYNA
        ScholarButton(
          label: "OYNA",
          icon: Icons.play_arrow_rounded,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SetupScreen(),
              ),
            );
          },
          isFullWidth: true,
        )
            .animate()
            .fadeIn(delay: 600.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0),

        const SizedBox(height: 20),

        // Secondary: NASIL OYNANIR
        ScholarButton(
          label: "NASIL OYNANIR",
          icon: Icons.menu_book_rounded,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const HowToPlayDialog(),
            );
          },
          isPrimary: false,
          isFullWidth: true,
        )
            .animate()
            .fadeIn(delay: 700.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }

  /// Decorative desk elements
  Widget _buildDecorativeElements() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Opacity(
        opacity: 0.4,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInkwellDecoration(),
            _buildScrollDecoration(),
            _buildQuillDecoration(),
          ],
        )
            .animate()
            .fadeIn(delay: 1000.ms, duration: 600.ms),
      ),
    );
  }

  /// Small inkwell decoration
  Widget _buildInkwellDecoration() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: GameTheme.ottomanAccent.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: GameTheme.ottomanAccent.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: GameTheme.ottomanAccent.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  /// Small scroll decoration
  Widget _buildScrollDecoration() {
    return Container(
      width: 40,
      height: 24,
      decoration: BoxDecoration(
        color: GameTheme.ottomanBackgroundAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GameTheme.ottomanSepia.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Container(
          width: 30,
          height: 2,
          decoration: BoxDecoration(
            color: GameTheme.ottomanSepia.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }

  /// Small quill decoration
  Widget _buildQuillDecoration() {
    return Icon(
      Icons.edit,
      size: 28,
      color: GameTheme.ottomanGold.withValues(alpha: 0.5),
    );
  }
}
