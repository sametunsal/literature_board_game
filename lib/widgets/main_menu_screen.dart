import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/game_theme.dart';
import '../providers/theme_notifier.dart';
import '../services/streak_service.dart';
import 'setup_screen.dart';
import 'settings_screen.dart';
import 'streak_candle_widget.dart';

/// Main menu screen with EDEBİNA branding - Dark Academia Aesthetic
class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  int _streakDays = 0;
  bool _isLoading = true;

  // Animated gradient background
  late AnimationController _gradientController;
  late Animation<Color?> _backgroundColor;

  @override
  void initState() {
    super.initState();
    _initStreak();

    // Breathing gradient animation (8 second loop)
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

  Future<void> _initStreak() async {
    final streakDays = await StreakService.instance.checkAndUpdateStreak();
    if (mounted) {
      setState(() {
        _streakDays = streakDays;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundColor,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Animated gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      _backgroundColor.value!.withValues(alpha: 0.9),
                      _backgroundColor.value!,
                      const Color(0xFF0F0E0D), // Very dark edges
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),

              // Paper noise texture
              Opacity(
                opacity: 0.12,
                child: Image.asset(
                  'assets/images/paper_noise.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  colorBlendMode: BlendMode.multiply,
                  color: Colors.white,
                ),
              ),

              // Content
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      _buildLogo(),
                      const SizedBox(height: 24),

                      // Title with enhanced glow
                      _buildTitle(),
                      const SizedBox(height: 8),

                      // Subtitle
                      _buildSubtitle(),
                      const SizedBox(height: 48),

                      // Glassmorphism menu buttons
                      _buildMenuButtons(context),
                    ],
                  ),
                ),
              ),

              // Top-right: Theme toggle + Streak candle
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child:
                    Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildThemeToggle(),
                            const SizedBox(height: 20),
                            if (!_isLoading)
                              StreakCandleWidget(
                                streakDays: _streakDays,
                                size: 55,
                                isLit: _streakDays > 0,
                              ),
                          ],
                        )
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 600.ms)
                        .slideY(
                          begin: -0.3,
                          end: 0,
                          delay: 800.ms,
                          duration: 500.ms,
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
          width: 95,
          height: 95,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                GameTheme.goldAccent.withValues(alpha: 0.15),
                GameTheme.goldAccent.withValues(alpha: 0.05),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: GameTheme.goldAccent.withValues(alpha: 0.5),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: GameTheme.goldAccent.withValues(alpha: 0.3),
                blurRadius: 35,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Icon(Icons.menu_book, size: 50, color: GameTheme.goldAccent),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 600.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 800.ms,
          curve: Curves.elasticOut,
        )
        .then()
        .shimmer(
          duration: 3000.ms,
          color: GameTheme.goldAccent.withValues(alpha: 0.2),
        );
  }

  Widget _buildTitle() {
    return Text(
          "EDEBİNA",
          style: GoogleFonts.playfairDisplay(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: GameTheme.goldAccent,
            letterSpacing: 12,
            shadows: [
              // Multi-layer glow
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
                offset: const Offset(3, 5),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 700.ms)
        .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 700.ms)
        .then(delay: 500.ms)
        .shimmer(
          duration: 2500.ms,
          color: GameTheme.goldAccent.withValues(alpha: 0.3),
        );
  }

  Widget _buildSubtitle() {
    return Text(
      "Türk Edebiyatı Masa Oyunu",
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: GameTheme.textDark.withValues(alpha: 0.7),
        letterSpacing: 2.5,
        fontWeight: FontWeight.w300,
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms);
  }

  Widget _buildThemeToggle() {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;

    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: GameTheme.goldAccent.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: GameTheme.goldAccent.withValues(alpha: 0.25),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Icon(
          isDark ? Icons.dark_mode : Icons.light_mode,
          size: 28,
          color: GameTheme.goldAccent,
        ),
      ),
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Column(
      children: [
        // Play button
        _GlassmorphicButton(
              label: "OYNA",
              icon: Icons.play_arrow,
              isPrimary: true,
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SetupScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
            )
            .animate()
            .fadeIn(delay: 500.ms)
            .slideX(begin: -0.2, end: 0, delay: 500.ms, duration: 600.ms),

        const SizedBox(height: 16),

        // Settings button
        _GlassmorphicButton(
              label: "AYARLAR",
              icon: Icons.settings,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            )
            .animate()
            .fadeIn(delay: 600.ms)
            .slideX(begin: -0.2, end: 0, delay: 600.ms, duration: 600.ms),

        const SizedBox(height: 16),

        // About button
        _GlassmorphicButton(
              label: "HAKKINDA",
              icon: Icons.info_outline,
              onPressed: () => _showAboutDialog(context),
            )
            .animate()
            .fadeIn(delay: 700.ms)
            .slideX(begin: -0.2, end: 0, delay: 700.ms, duration: 600.ms),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C241B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: GameTheme.goldAccent.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        title: Text(
          "EDEBİNA",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: GameTheme.goldAccent,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Türk Edebiyatı Temalı Masa Oyunu",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: GameTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Versiyon 1.0.0",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: GameTheme.textDark.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "© 2026 EDEBİNA",
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: GameTheme.textDark.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "KAPAT",
              style: GoogleFonts.poppins(
                color: GameTheme.goldAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// True glassmorphic button with BackdropFilter
class _GlassmorphicButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _GlassmorphicButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<_GlassmorphicButton> createState() => _GlassmorphicButtonState();
}

class _GlassmorphicButtonState extends State<_GlassmorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 240,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isPrimary
                  ? GameTheme.goldAccent.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.2),
              width: widget.isPrimary ? 2 : 1.5,
            ),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: GameTheme.goldAccent.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isPrimary
                        ? [
                            GameTheme.goldAccent.withValues(alpha: 0.15),
                            GameTheme.goldAccent.withValues(alpha: 0.08),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      size: 24,
                      color: widget.isPrimary
                          ? GameTheme.goldAccent
                          : GameTheme.textDark,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 2,
                        color: widget.isPrimary
                            ? GameTheme.goldAccent
                            : GameTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
