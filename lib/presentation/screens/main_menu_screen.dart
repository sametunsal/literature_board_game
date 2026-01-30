import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/motion/motion_constants.dart';
import '../../core/theme/game_theme.dart';
import '../../providers/theme_notifier.dart';
import '../../services/streak_service.dart';
import 'setup_screen.dart';
import 'settings_screen.dart';
import '../widgets/streak_candle_widget.dart';
import '../dialogs/rules_dialog.dart';

/// Main menu screen with EDEBİNA branding - Theme-aware design
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
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _initStreak();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Breathing gradient animation (8 second loop)
    _gradientController = AnimationController(
      duration: MotionDurations.ambientGradient.safe,
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _gradientController,
        curve: MotionCurves.standard,
      ),
    );
  }

  @override
  void dispose() {
    _gradientController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
    final themeState = ref.watch(themeProvider);
    final tokens = themeState.tokens;
    final isDark = themeState.isDarkMode;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          // Use tokens for animated colors
          final animatedColor = Color.lerp(
            tokens.background,
            tokens.surfaceAlt,
            _gradientAnimation.value,
          )!;

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
                      animatedColor.withValues(alpha: 0.9),
                      animatedColor,
                      isDark
                          ? tokens.surfaceAlt
                          : tokens.background.withValues(alpha: 0.95),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),

              // Content
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo
                            _buildLogo(tokens),
                            const SizedBox(height: 24),

                            // Title with enhanced glow
                            _buildTitle(tokens),
                            const SizedBox(height: 8),

                            // Subtitle
                            _buildSubtitle(tokens),
                            const SizedBox(height: 48),

                            // Glassmorphism menu buttons
                            _buildMenuButtons(context, tokens, isDark),
                          ],
                        ),
                      ),
                    );
                  },
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
                            _buildThemeSelector(
                              tokens,
                              isDark,
                              themeState.preset,
                            ),
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
                        .fadeIn(
                          delay: MotionDurations.medium.safe * 2,
                          duration: MotionDurations.medium.safe * 2,
                        )
                        .slideY(
                          begin: -0.3,
                          end: 0,
                          delay: MotionDurations.medium.safe * 2,
                          duration: MotionDurations.medium.safe * 1.5,
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogo(ThemeTokens tokens) {
    return Container(
          width: 95,
          height: 95,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                tokens.accent.withValues(alpha: 0.15),
                tokens.accent.withValues(alpha: 0.05),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: tokens.accent.withValues(alpha: 0.5),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: tokens.accent.withValues(alpha: 0.3),
                blurRadius: 35,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Icon(Icons.menu_book, size: 50, color: tokens.accent),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: MotionDurations.medium.safe * 2)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: MotionDurations.medium.safe * 2,
          curve: MotionCurves.spring,
        )
        .then()
        .shimmer(
          duration: MotionDurations.slow.safe * 6,
          color: tokens.accent.withValues(alpha: 0.2),
        );
  }

  Widget _buildTitle(ThemeTokens tokens) {
    return Text(
          "EDEBİNA",
          style: GoogleFonts.poppins(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: tokens.textPrimary,
            letterSpacing: 8,
          ),
        )
        .animate()
        .fadeIn(
          delay: MotionDurations.fast.safe,
          duration: MotionDurations.medium.safe * 2,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          delay: MotionDurations.fast.safe,
          duration: MotionDurations.medium.safe * 2,
        );
  }

  Widget _buildSubtitle(ThemeTokens tokens) {
    return Text(
      "Türk Edebiyatı Masa Oyunu",
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: tokens.textSecondary,
        letterSpacing: 2.5,
        fontWeight: FontWeight.w300,
      ),
    ).animate().fadeIn(
      delay: MotionDurations.fast.safe * 2,
      duration: MotionDurations.medium.safe * 2,
    );
  }

  Widget _buildThemeSelector(
    ThemeTokens tokens,
    bool isDark,
    ThemePreset currentPreset,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: tokens.surface.withValues(alpha: isDark ? 0.2 : 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tokens.border.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 4),
            child: Text(
              "TEMA",
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: tokens.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
          ),
          // Light theme option
          _buildThemeOption(
            label: "Sıcak Kütüphane",
            icon: Icons.light_mode,
            isSelected: currentPreset == ThemePreset.warmLibraryLight,
            tokens: tokens,
            isDark: isDark,
            onTap: () => ref
                .read(themeProvider.notifier)
                .setPreset(ThemePreset.warmLibraryLight),
          ),
          const SizedBox(height: 6),
          // Dark theme option
          _buildThemeOption(
            label: "Karanlık Akademi",
            icon: Icons.dark_mode,
            isSelected: currentPreset == ThemePreset.darkAcademia,
            tokens: tokens,
            isDark: isDark,
            onTap: () => ref
                .read(themeProvider.notifier)
                .setPreset(ThemePreset.darkAcademia),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required ThemeTokens tokens,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MotionDurations.fast.safe,
        curve: MotionCurves.standard,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? tokens.primary.withValues(alpha: isDark ? 0.3 : 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? tokens.primary
                : tokens.border.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? tokens.primary : tokens.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? tokens.primary : tokens.textSecondary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_circle, size: 14, color: tokens.primary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButtons(
    BuildContext context,
    ThemeTokens tokens,
    bool isDark,
  ) {
    return Column(
      children: [
        // Play button
        _GlassmorphicButton(
              label: "OYNA",
              icon: Icons.play_arrow,
              isPrimary: true,
              tokens: tokens,
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
                    transitionDuration: MotionDurations.medium.safe * 1.5,
                  ),
                );
              },
            )
            .animate()
            .fadeIn(delay: MotionDurations.medium.safe)
            .slideX(
              begin: -0.2,
              end: 0,
              delay: MotionDurations.medium.safe,
              duration: MotionDurations.medium.safe * 2,
            ),

        const SizedBox(height: 16),

        // Rules button
        _GlassmorphicButton(
              label: "KURALLAR",
              icon: Icons.menu_book,
              tokens: tokens,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const RulesDialog(),
                );
              },
            )
            .animate()
            .fadeIn(
              delay: MotionDurations.medium.safe + MotionDurations.fast.safe,
            )
            .slideX(
              begin: -0.2,
              end: 0,
              delay: MotionDurations.medium.safe + MotionDurations.fast.safe,
              duration: MotionDurations.medium.safe * 2,
            ),

        const SizedBox(height: 16),

        // Settings button
        _GlassmorphicButton(
              label: "AYARLAR",
              icon: Icons.settings,
              tokens: tokens,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            )
            .animate()
            .fadeIn(
              delay: MotionDurations.medium.safe + MotionDurations.fast.safe,
            )
            .slideX(
              begin: -0.2,
              end: 0,
              delay: MotionDurations.medium.safe + MotionDurations.fast.safe,
              duration: MotionDurations.medium.safe * 2,
            ),

        const SizedBox(height: 16),

        // About button
        _GlassmorphicButton(
              label: "HAKKINDA",
              icon: Icons.info_outline,
              tokens: tokens,
              onPressed: () => _showEnhancedAboutDialog(context, tokens),
            )
            .animate()
            .fadeIn(
              delay:
                  MotionDurations.medium.safe + MotionDurations.fast.safe * 2,
            )
            .slideX(
              begin: -0.2,
              end: 0,
              delay:
                  MotionDurations.medium.safe + MotionDurations.fast.safe * 2,
              duration: MotionDurations.medium.safe * 2,
            ),
      ],
    );
  }

  void _showEnhancedAboutDialog(BuildContext context, ThemeTokens tokens) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: tokens.dialogBackground.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: tokens.accent.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book, size: 64, color: tokens.accent),
              const SizedBox(height: 16),
              Text(
                "EDEBİNA",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: tokens.textPrimary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Türk Edebiyatı Masa Oyunu",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 50,
                height: 2,
                color: tokens.accent.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 24),
              Text(
                "Bu oyun, Türk Edebiyatı'nın zengin dünyasını eğlenceli bir masa oyunu formatında keşfetmeniz için tasarlandı.\n\n"
                "Keyifli oyunlar!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: tokens.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.accent,
                    foregroundColor: tokens.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    "KAPAT",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "v1.0.0 • © 2026 EDEBİNA",
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: tokens.textSecondary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modern elevated button - clean flat design
class _GlassmorphicButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final ThemeTokens tokens;

  const _GlassmorphicButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.tokens,
    this.isPrimary = false,
  });

  @override
  State<_GlassmorphicButton> createState() => _GlassmorphicButtonState();
}

class _GlassmorphicButtonState extends State<_GlassmorphicButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final scale = _isPressed ? 0.96 : (_isHovered ? 1.02 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: MotionDurations.fast.safe,
          curve: MotionCurves.emphasized,
          child: SizedBox(
            width: 240,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isPrimary
                    ? tokens.primary
                    : Colors.white,
                foregroundColor: widget.isPrimary
                    ? Colors.white
                    : tokens.textPrimary,
                elevation: widget.isPrimary ? 4 : 2,
                shadowColor: widget.isPrimary
                    ? tokens.primary.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: widget.isPrimary
                        ? Colors.transparent
                        : tokens.border,
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    widget.label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
