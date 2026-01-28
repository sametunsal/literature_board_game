import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_menu_screen.dart';

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
    try {
      // Preload the fonts we use with a timeout
      // Note: We use a separate variable to avoid inference issues
      final fontFuture =
          GoogleFonts.pendingFonts([
            GoogleFonts.playfairDisplay(),
            GoogleFonts.poppins(),
          ]).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('Font loading timed out - proceeding with fallback');
              return [];
            },
          );

      // Start both the font loading and minimum timer simultaneously
      await Future.wait([
        fontFuture,
        // Minimum splash display time
        Future.delayed(const Duration(milliseconds: 3000)),
      ]);
    } catch (e) {
      debugPrint('Error during splash initialization: $e');
      // If error occurs, wait a bit to ensure 3s minimum then proceed
      await Future.delayed(const Duration(milliseconds: 3000));
    } finally {
      _navigateToMenu();
    }
  }

  void _navigateToMenu() {
    // Navigate to setup screen and remove splash from stack
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainMenuScreen(),
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
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
            color: Colors.amber.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.amber, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(Icons.menu_book, size: 50, color: Colors.amber),
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

  /// Main game title
  Widget _buildTitle() {
    return Text(
          "EDEBİNA",
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 3,
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
        color: Colors.grey.shade600,
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
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Yükleniyor...",
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    ).animate().fadeIn(delay: 1200.ms, duration: 600.ms);
  }
}
