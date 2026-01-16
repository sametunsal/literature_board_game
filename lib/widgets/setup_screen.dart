import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/motion/motion_constants.dart';
import '../models/player.dart';
import '../providers/game_notifier.dart';
import '../core/theme/game_theme.dart';
import '../utils/sound_manager.dart';
import 'board_view.dart';
import 'main_menu_screen.dart';

/// Premium styled setup screen with Literature theme
/// Matches the visual polish of the main game board
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  int playerCount = 4;
  final List<TextEditingController> _controllers = [];

  /// Available colors for player selection
  static const List<Color> _colorPalette = [
    Color(0xFFD32F2F), // Red
    Color(0xFF1976D2), // Blue
    Color(0xFF388E3C), // Green
    Color(0xFFE64A19), // Orange
    Color(0xFF7B1FA2), // Purple
    Color(0xFF00796B), // Teal
    Color(0xFFE91E63), // Pink
    Color(0xFF795548), // Brown
    Color(0xFF512DA8), // Deep Purple
    Color(0xFF0097A7), // Cyan
  ];

  /// Selected color index for each player
  final List<int> _selectedColors = [];

  /// Selected icon index for each player (now references avatar images)
  final List<int> _selectedIcons = [];

  /// Custom avatar image paths (20 avatars)
  static final List<String> _avatarPaths = List.generate(
    20,
    (index) =>
        'assets/images/avatar_${(index + 1).toString().padLeft(2, '0')}.png',
  );

  @override
  void initState() {
    super.initState();
    // Allow all orientations on setup screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _updateControllers();
  }

  void _updateControllers() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _selectedIcons.clear();
    _selectedColors.clear();
    for (int i = 0; i < playerCount; i++) {
      _controllers.add(TextEditingController(text: "Oyuncu ${i + 1}"));
      _selectedIcons.add(i % _avatarPaths.length);
      _selectedColors.add(i % _colorPalette.length);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme-aware tokens
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tokens = GameTheme.getTokens(isDarkMode);

    return Scaffold(
      // Modern themed - Layered Background
      body: Stack(
        fit: StackFit.expand,
        children: [
          // LAYER 1: Base Background Color
          Container(decoration: GameTheme.tableDecorationFor(isDarkMode)),

          // LAYER 2: Paper Noise Texture - Tactile Effect
          Opacity(
            opacity: isDarkMode ? 0.12 : 0.06,
            child: Image.asset(
              'assets/images/paper_noise.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              colorBlendMode: BlendMode.multiply,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),

          // LAYER 3: Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildMainCard(tokens, isDarkMode),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Main styled card container - theme-aware
  Widget _buildMainCard(ThemeTokens tokens, bool isDarkMode) {
    return Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tokens.border.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: tokens.shadow.withValues(alpha: isDarkMode ? 0.4 : 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: tokens.accent.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              _buildHeader(tokens, isDarkMode),
              const SizedBox(height: 24),

              // PLAYER COUNT SELECTOR
              _buildPlayerCountSelector(tokens, isDarkMode),
              const SizedBox(height: 20),

              // DIVIDER
              _buildDivider(tokens),
              const SizedBox(height: 20),

              // PLAYER LIST
              _buildPlayerList(tokens, isDarkMode),
              const SizedBox(height: 24),

              // START BUTTON
              _buildStartButton(tokens, isDarkMode),
              const SizedBox(height: 12),

              // EXIT BUTTON
              _buildExitButton(tokens),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: MotionDurations.medium.safe * 2)
        .slideY(
          begin: 0.2,
          end: 0,
          duration: MotionDurations.medium.safe * 2,
          curve: MotionCurves.standard,
        );
  }

  /// Header with decorative title - theme-aware
  Widget _buildHeader(ThemeTokens tokens, bool isDarkMode) {
    return Column(
      children: [
        // Decorative icon with glow
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tokens.accent.withValues(alpha: 0.15),
            boxShadow: [
              BoxShadow(
                color: tokens.accent.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(Icons.menu_book, size: 42, color: tokens.accent),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          "OYUN KURULUMU",
          style: GoogleFonts.cinzel(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: tokens.textPrimary,
            letterSpacing: 3,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          "Oyuncuları belirleyin",
          style: GoogleFonts.poppins(fontSize: 14, color: tokens.textSecondary),
        ),
      ],
    );
  }

  /// Elegant player count dropdown - theme-aware
  Widget _buildPlayerCountSelector(ThemeTokens tokens, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tokens.border.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: playerCount,
          icon: Icon(Icons.arrow_drop_down, color: tokens.primary),
          dropdownColor: tokens.surface,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: tokens.textPrimary,
          ),
          items: [2, 3, 4, 5, 6]
              .map((e) => DropdownMenuItem(value: e, child: Text("$e Oyuncu")))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                playerCount = val;
                _updateControllers();
              });
            }
          },
        ),
      ),
    );
  }

  /// Decorative divider - theme-aware
  Widget _buildDivider(ThemeTokens tokens) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  tokens.border.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.accent.withValues(alpha: 0.2),
            ),
            child: Icon(Icons.star, size: 14, color: tokens.accent),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  tokens.border.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Player list with responsive grid layout (2-4 columns based on orientation)
  Widget _buildPlayerList(ThemeTokens tokens, bool isDarkMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine column count based on available width
        final isLandscape = constraints.maxWidth > constraints.maxHeight;
        final crossAxisCount = isLandscape
            ? (constraints.maxWidth > 600 ? 4 : 3)
            : 2;
        final aspectRatio = isLandscape ? 0.9 : 0.82;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: aspectRatio,
          ),
          itemCount: playerCount,
          itemBuilder: (context, index) =>
              _buildPlayerCard(index, tokens, isDarkMode),
        );
      },
    );
  }

  /// Individual player card - vertical layout for grid
  Widget _buildPlayerCard(int index, ThemeTokens tokens, bool isDarkMode) {
    final playerColor = _colorPalette[_selectedColors[index]];

    return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: tokens.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: playerColor.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: playerColor.withValues(alpha: isDarkMode ? 0.15 : 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // AVATAR (centered) - Custom Image
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tokens.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: playerColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: playerColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Image.asset(
                      _avatarPaths[_selectedIcons[index]],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image fails
                        return Icon(Icons.person, color: playerColor, size: 24);
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              // NAME INPUT (full width, compact)
              TextField(
                controller: _controllers[index],
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: tokens.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: "Oyuncu ${index + 1}",
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 11,
                    color: tokens.textSecondary,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 5,
                  ),
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: tokens.accent, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              // ICON SELECTOR
              _buildSelectorLabel("Simge", tokens),
              const SizedBox(height: 2),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      _avatarPaths.length,
                      (iconIndex) => _buildIconOption(
                        index,
                        iconIndex,
                        tokens,
                        isDarkMode,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 3),

              // COLOR SELECTOR
              _buildSelectorLabel("Renk", tokens),
              const SizedBox(height: 2),
              SizedBox(
                height: 22,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      _colorPalette.length,
                      (colorIndex) =>
                          _buildColorOption(index, colorIndex, tokens),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (50 * index).ms, duration: MotionDurations.fast.safe)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          delay: (50 * index).ms,
          duration: MotionDurations.fast.safe,
        );
  }

  /// Build selector label (compact)
  Widget _buildSelectorLabel(String label, ThemeTokens tokens) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: tokens.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Build individual avatar option for horizontal selector - theme-aware
  Widget _buildIconOption(
    int playerIndex,
    int iconIndex,
    ThemeTokens tokens,
    bool isDarkMode,
  ) {
    final isSelected = _selectedIcons[playerIndex] == iconIndex;

    return GestureDetector(
      onTap: () => setState(() => _selectedIcons[playerIndex] = iconIndex),
      child: AnimatedContainer(
        duration: MotionDurations.fast.safe,
        curve: MotionCurves.standard,
        margin: const EdgeInsets.only(right: 6),
        width: isSelected ? 38 : 32,
        height: isSelected ? 38 : 32,
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? tokens.accent
                : tokens.border.withValues(alpha: 0.3),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: tokens.accent.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Image.asset(
              _avatarPaths[iconIndex],
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person,
                  size: 16,
                  color: tokens.textSecondary,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Build individual color option for horizontal selector (compact)
  Widget _buildColorOption(
    int playerIndex,
    int colorIndex,
    ThemeTokens tokens,
  ) {
    final isSelected = _selectedColors[playerIndex] == colorIndex;
    final color = _colorPalette[colorIndex];

    return GestureDetector(
      onTap: () => setState(() => _selectedColors[playerIndex] = colorIndex),
      child: AnimatedContainer(
        duration: MotionDurations.fast.safe,
        curve: MotionCurves.standard,
        margin: const EdgeInsets.only(right: 5),
        width: isSelected ? 26 : 22,
        height: isSelected ? 26 : 22,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isSelected ? 0.5 : 0.25),
              blurRadius: isSelected ? 6 : 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 12)
            : null,
      ),
    );
  }

  /// Premium styled start button - theme-aware
  Widget _buildStartButton(ThemeTokens tokens, bool isDarkMode) {
    return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [tokens.primary, tokens.accent],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: tokens.accent.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _startGame,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow,
                      size: 28,
                      color: tokens.textOnAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "OYUNA BAŞLA",
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: tokens.textOnAccent,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          delay: 2000.ms,
          duration: 1500.ms,
          color: Colors.white.withValues(alpha: 0.2),
        );
  }

  /// Exit button to return to main menu - theme-aware
  Widget _buildExitButton(ThemeTokens tokens) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          debugPrint("Exit button pressed");
          SoundManager.instance.playClick();
          // Navigate back to main menu
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainMenuScreen()),
            (route) => false,
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.textSecondary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: tokens.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.exit_to_app, size: 22, color: tokens.textSecondary),
            const SizedBox(width: 8),
            Text(
              "ÇIKIŞ",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Initialize the game with configured players and navigate to board
  void _startGame() {
    SoundManager.instance.playClick();
    // Validate minimum players
    if (playerCount < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'En az 2 oyuncu gerekli!',
            style: GameTheme.bodyFont.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    // Create player list
    List<Player> players = [];
    for (int i = 0; i < playerCount; i++) {
      players.add(
        Player(
          id: '${DateTime.now().millisecondsSinceEpoch}$i',
          name: _controllers[i].text.trim().isEmpty
              ? "Oyuncu ${i + 1}"
              : _controllers[i].text.trim(),
          color: _colorPalette[_selectedColors[i]],
          iconIndex: _selectedIcons[i],
        ),
      );
    }

    // Initialize game state
    ref.read(gameProvider.notifier).initializeGame(players);

    // Navigate to BoardView
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const BoardView()),
    );
  }
}
