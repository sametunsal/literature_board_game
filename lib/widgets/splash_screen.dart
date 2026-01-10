import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/game_theme.dart';
import 'setup_screen.dart';

/// Premium splash screen with brand presentation and font preloading
/// Displays the game logo with elegant animations before navigating to setup
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  /// Wait for fonts to load and minimum display time, then navigate
  Future<void> _initializeAndNavigate() async {
    // Start both the font loading and minimum timer simultaneously
    await Future.wait([
      // Preload the fonts we use
      GoogleFonts.pendingFonts([
        GoogleFonts.playfairDisplay(),
        GoogleFonts.poppins(),
      ]),
      // Minimum splash display time
      Future.delayed(const Duration(milliseconds: 3000)),
    ]);

    // Navigate to setup screen and remove splash from stack
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SetupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2818), // Darker green variant
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              const Color(0xFF1B4721), // Table green at center
              const Color(0xFF0D2818), // Darker at edges
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO/ICON
              _buildLogo(),
              const SizedBox(height: 32),

              // TITLE
              _buildTitle(),
              const SizedBox(height: 12),

              // SUBTITLE
              _buildSubtitle(),
              const SizedBox(height: 48),

              // LOADING INDICATOR
              _buildLoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  /// Animated book icon logo
  Widget _buildLogo() {
    return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: GameTheme.goldAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: GameTheme.goldAccent.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: GameTheme.goldAccent.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(Icons.menu_book, size: 50, color: GameTheme.goldAccent),
        )
        .animate()
        .fadeIn(duration: 1000.ms)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: 1200.ms,
          curve: Curves.elasticOut,
        );
  }

  /// Main game title with gold styling
  Widget _buildTitle() {
    return Text(
          "EDEBİYAT OYUNU",
          style: GoogleFonts.playfairDisplay(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: GameTheme.goldAccent,
            letterSpacing: 3,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(2, 4),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 800.ms)
        .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 800.ms);
  }

  /// Subtitle text
  Widget _buildSubtitle() {
    return Text(
      "Bilginizi Test Edin",
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.white.withValues(alpha: 0.7),
        letterSpacing: 1,
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 600.ms);
  }

  /// Pulsating loading indicator
  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              GameTheme.goldAccent.withValues(alpha: 0.8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Yükleniyor...",
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 1200.ms, duration: 600.ms);
  }
}
