import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

import 'setup_screen.dart';
import 'settings_screen.dart';
import '../dialogs/how_to_play_dialog.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    const bgColor = Color(0xFFF9F7F2);
    const accentColor = Color(0xFF00695C); // Deep Teal
    const goldColor = Color(0xFFD4AF37); // Metallic Gold

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Rich Background Pattern (Literature Theme)
          Positioned.fill(
            child: CustomPaint(
              painter: LiteraturePatternPainter(
                color: accentColor.withOpacity(0.03),
              ),
            ),
          ),

          // Vignette effect for focus
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [Colors.transparent, bgColor.withOpacity(0.8)],
                ),
              ),
            ),
          ),

          // 2. Menu Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO SECTION
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      children: [
                        Text(
                              'EDEBİNA',
                              style: GoogleFonts.cinzelDecorative(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: accentColor,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                    color: goldColor.withOpacity(0.3),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 800.ms)
                            .scale(curve: Curves.easeOutBack, duration: 800.ms),

                        Text(
                              'ANA MENÜ',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: accentColor.withOpacity(0.7),
                                letterSpacing: 6,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 600.ms)
                            .slideY(begin: 0.5, end: 0),
                      ],
                    ),

                    // Animated Quill Decor
                    Positioned(
                      top: 10,
                      right: -30,
                      child:
                          Icon(
                                Icons.edit_outlined,
                                size: 36,
                                color: goldColor.withOpacity(0.8),
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .rotate(
                                begin: 0,
                                end: 0.1,
                                duration: 2.seconds,
                                curve: Curves.easeInOut,
                              )
                              .moveY(
                                begin: 0,
                                end: -5,
                                duration: 2.seconds,
                                curve: Curves.easeInOut,
                              ),
                    ),
                  ],
                ),

                const SizedBox(height: 80),

                // Isometric Menu Buttons
                _IsometricMenuButton(
                      label: "OYNA",
                      color: const Color(0xFF4DB6AC), // Sage Green
                      sideColor: const Color(0xFF00897B),
                      icon: Icons.play_arrow_rounded,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SetupScreen(),
                          ),
                        );
                      },
                    )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                _IsometricMenuButton(
                      label: "NASIL OYNANIR",
                      color: const Color(0xFF64B5F6), // Pastel Blue
                      sideColor: const Color(0xFF1E88E5),
                      icon: Icons.menu_book_rounded,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const HowToPlayDialog(),
                        );
                      },
                    )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                _IsometricMenuButton(
                      label: "AYARLAR",
                      color: const Color(0xFFB0BEC5), // Pastel Grey
                      sideColor: const Color(0xFF78909C),
                      icon: Icons.settings_rounded,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

class _IsometricMenuButton extends StatefulWidget {
  final String label;
  final Color color;
  final Color sideColor;
  final IconData icon;
  final VoidCallback onTap;

  const _IsometricMenuButton({
    required this.label,
    required this.color,
    required this.sideColor,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_IsometricMenuButton> createState() => _IsometricMenuButtonState();
}

class _IsometricMenuButtonState extends State<_IsometricMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pressAnimation; // Controls Y translation and shadow

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Quick press
      reverseDuration: const Duration(milliseconds: 150), // Bouncy release
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _pressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _controller.reverse();
    // Small delay to let animation start reversing before action
    Future.delayed(const Duration(milliseconds: 100), widget.onTap);
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    const double width = 280;
    const double height = 64;
    const double maxDepth = 8;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final pressValue = _pressAnimation.value;
          final currentDepth =
              maxDepth *
              (1 - pressValue * 0.5); // Depth doesn't disappear fully
          final topOffset = maxDepth - currentDepth; // Moves down visualy

          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: width,
              height: height + maxDepth,
              child: Stack(
                children: [
                  // Layer 1: Shadow
                  // Shadow shrinks and becomes sharper as button is pressed
                  Positioned(
                    bottom: 2 + (pressValue * 2), // Moves up slightly
                    left: 4 + (pressValue * 2),
                    right: 4 + (pressValue * 2),
                    height: height,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(
                          0.2 - (pressValue * 0.05),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.1 - (pressValue * 0.05),
                            ),
                            blurRadius: 8 - (pressValue * 4),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Layer 2: 3D Side (Bottom Block)
                  Positioned(
                    top: topOffset + currentDepth,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: widget.sideColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  // Layer 3: Top Face
                  Positioned(
                    top: topOffset,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [widget.color, widget.color.withOpacity(0.9)],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(widget.icon, color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            widget.label,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PAINTERS
// ═════════════════════════════════════════════════════════════════════════════

class LiteraturePatternPainter extends CustomPainter {
  final Color color;

  LiteraturePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw subtle horizontal lines resembling notebook paper or book text
    const double lineHeight = 20;
    for (double y = 0; y < size.height; y += lineHeight) {
      if (y % 60 == 0) {
        // Break lines occassionally for paragraph look via path
        // Simplified: just drawing dashed lines manually would be performant enough
        // but let's do simple lines for now with varying opacity
        paint.color = color.withOpacity((math.sin(y) + 1) / 2 * 0.05 + 0.02);
        canvas.drawLine(Offset(20, y), Offset(size.width - 20, y), paint);
      }
    }

    // Draw visual flourish curves (abstract letters)
    final random = math.Random(42); // fixed seed
    for (int i = 0; i < 10; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double radius = 20 + random.nextDouble() * 50;

      paint.style = PaintingStyle.stroke;
      paint.color = color.withOpacity(0.04);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
