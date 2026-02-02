import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for animations and loading
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

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

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    const bgGradientStart = Color(0xFFF9F7F2); // Warm Cream
    const bgGradientEnd = Color(0xFFF0EBE0); // Slightly darker beige
    const textColor = Color(0xFF00695C); // Deep Teal
    const accentColor = Color(0xFFD4AF37); // Metallic Gold

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgGradientStart, bgGradientEnd],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Logo Section
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Main Text
                  Text(
                        'EDEBİNA',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: 8,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 1000.ms, curve: Curves.easeOut)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.0, 1.0),
                        duration: 1200.ms,
                        curve: Curves.elasticOut,
                      ),

                  // Animated Quill Icon
                  Positioned(
                    right: -40,
                    bottom: 0,
                    child:
                        const Icon(
                              Icons.edit_outlined,
                              size: 40,
                              color: accentColor,
                            )
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 600.ms)
                            .move(
                              begin: const Offset(-20, -10),
                              end: const Offset(0, 0),
                              duration: 800.ms,
                              curve: Curves.easeOutQuart,
                            ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Subtitle / Tagline
              Text(
                    'Edebiyatın Derinliklerine Yolculuk',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: textColor.withOpacity(0.7),
                      letterSpacing: 2,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 800.ms)
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 800.ms,
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 60),

              // 2. Loading Indicator (Minimalist Gold Line)
              SizedBox(
                width: 120,
                child: Column(
                  children: [
                    const LinearProgressIndicator(
                      backgroundColor: Color(0xFFE0E0E0),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      minHeight: 2,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Yükleniyor...',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: textColor.withOpacity(0.5),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 1500.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
