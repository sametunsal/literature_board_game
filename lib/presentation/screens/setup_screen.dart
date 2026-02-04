import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/common/scholar_button.dart';
import '../widgets/common/ottoman_background.dart';
import '../../models/player.dart';
import '../widgets/board_view.dart';
import '../../providers/game_notifier.dart';
import '../../core/theme/game_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Setup Screen - "The Imperial Registry"
/// Ottoman Scholar themed with parchment cards, wax seals, and signature inputs
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final List<TextEditingController> _nameControllers = [];
  final List<Player> _players = [];
  final int _maxPlayers = 6;

  // Wax seal colors (traditional Ottoman palette)
  final List<Color> _waxSealColors = [
    const Color(0xFFA83F39), // Cinnabar Red
    const Color(0xFF1E5A7D), // Lapis Lazuli Blue
    const Color(0xFF2D5A3D), // Malachite Green
    const Color(0xFFB8860B), // Dark Gold
    const Color(0xFF5C3C7A), // Tyrian Purple
    const Color(0xFFD4AF37), // Polished Gold
    const Color(0xFF8B4513), // Sepia Brown
    const Color(0xFF1A4D42), // Ottoman Teal
  ];

  // Available Icons
  final List<IconData> _availableIcons = [
    Icons.person,
    Icons.face,
    Icons.emoji_people,
    Icons.sentiment_satisfied_alt,
    Icons.catching_pokemon,
    Icons.psychology,
    Icons.school,
    Icons.auto_stories,
    Icons.create,
    Icons.favorite,
    Icons.star,
    Icons.pets,
  ];

  @override
  void initState() {
    super.initState();
    // Enforce Portrait Mode for Setup
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _addPlayer();
    _addPlayer(); // Start with 2 players
  }

  void _addPlayer() {
    if (_players.length >= _maxPlayers) return;

    final index = _players.length;
    final controller = TextEditingController(text: "Oyuncu ${index + 1}");
    _nameControllers.add(controller);

    setState(() {
      _players.add(
        Player(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: controller.text,
          color: _waxSealColors[index % _waxSealColors.length],
          iconIndex: index,
        ),
      );
    });
  }

  void _removePlayer(int index) {
    if (_players.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "En az 2 oyuncu gerekli!",
            style: GoogleFonts.crimsonText(),
          ),
          backgroundColor: GameTheme.ottomanCinnabar,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _players.removeAt(index);
      _nameControllers[index].dispose();
      _nameControllers.removeAt(index);
    });
  }

  void _startGame() {
    // Update player names from controllers
    for (int i = 0; i < _players.length; i++) {
      _players[i] = _players[i].copyWith(name: _nameControllers[i].text);
    }

    // Initialize Game
    ref.read(gameProvider.notifier).initializeGame(_players);

    // Navigate to Game Board
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const BoardView()),
    );
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: OttomanBackground(
        showPattern: true,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Player List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: _players.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == _players.length) {
                      // Add Player Button
                      if (_players.length < _maxPlayers) {
                        return _buildAddPlayerButton()
                            .animate()
                            .fadeIn(delay: (index * 100).ms, duration: 300.ms)
                            .slideX(begin: -0.2, end: 0);
                      }
                      return const SizedBox(height: 20);
                    }

                    return _buildPlayerCard(index)
                        .animate()
                        .fadeIn(delay: (index * 100).ms, duration: 400.ms)
                        .slideX(begin: -0.15, end: 0);
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // Start Game FAB (Bottom Right)
      floatingActionButton: _buildStartFAB(),
    );
  }

  /// App Bar with Ottoman styling
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 16, top: 8),
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
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: GameTheme.ottomanAccent,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        "OYUNCU DEFTERİ",
        style: GoogleFonts.cinzelDecorative(
          fontWeight: FontWeight.w700,
          color: GameTheme.ottomanAccent,
          fontSize: 24,
          letterSpacing: 3,
        ),
      ),
      centerTitle: true,
    );
  }

  /// Header with decorative flourish
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Decorative line
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  GameTheme.ottomanGold.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "İmzanızı deftere ekleyin",
            style: GoogleFonts.crimsonText(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: GameTheme.ottomanTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Player Registry Card
  Widget _buildPlayerCard(int index) {
    final player = _players[index];
    final controller = _nameControllers[index];

    return Container(
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          // PARCHMENT CARD
          Container(
            margin: const EdgeInsets.only(right: 50),
            decoration: BoxDecoration(
              color: GameTheme.ottomanBackgroundAlt.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GameTheme.ottomanBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                // AVATAR MEDALLION
                GestureDetector(
                  onTap: () => _showAvatarSelectionDialog(index),
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: player.color,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: player.color.withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: player.color.withValues(alpha: 0.15),
                      child: Icon(
                        _availableIcons[
                            player.iconIndex % _availableIcons.length],
                        color: player.color,
                        size: 32,
                      ),
                    ),
                  ),
                ),

                // NAME INPUT (Signature Style)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Player Label
                        Text(
                          "OYUNCU ${index + 1}",
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: GameTheme.ottomanTextSecondary,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Signature Line Input
                        TextField(
                          controller: controller,
                          style: GoogleFonts.amiri(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: GameTheme.ottomanText,
                            height: 1.0,
                          ),
                          decoration: InputDecoration(
                            hintText: "İmza atınız...",
                            hintStyle: GoogleFonts.amiri(
                              color: GameTheme.ottomanTextSecondary
                                  .withValues(alpha: 0.5),
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                            ),
                            border: InputBorder.none,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: GameTheme.ottomanSignatureLine,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: GameTheme.ottomanAccent,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 50),
              ],
            ),
          ),

          // WAX SEAL (Color Picker)
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: () => _showColorSelectionDialog(index),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: player.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: player.color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: player.color.withValues(alpha: 0.8),
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.palette,
                  color: Colors.black.withValues(alpha: 0.2),
                  size: 24,
                ),
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.05, 1.05),
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                ),
          ),

          // REMOVE STAMP
          Positioned(
            top: 4,
            right: 60,
            child: GestureDetector(
              onTap: () => _removePlayer(index),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: GameTheme.ottomanCinnabar.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: GameTheme.ottomanCinnabar.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: GameTheme.ottomanCinnabar,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Add Player Button
  Widget _buildAddPlayerButton() {
    return GestureDetector(
      onTap: _addPlayer,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GameTheme.ottomanAccent.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: GameTheme.ottomanAccent.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: GameTheme.ottomanAccent,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  "YENİ OYUNCU EKLE",
                  style: GoogleFonts.crimsonText(
                    color: GameTheme.ottomanAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Start Game FAB
  Widget _buildStartFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 16),
      child: ScholarButton(
        label: "OYUNU BAŞLAT",
        icon: Icons.arrow_forward_rounded,
        onTap: _startGame,
        isSmall: true,
      )
          .animate()
          .fadeIn(delay: 800.ms, duration: 400.ms)
          .slideY(begin: 0.3, end: 0),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MODALS
  // ═══════════════════════════════════════════════════════════════════════════

  void _showAvatarSelectionDialog(int playerIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: GameTheme.ottomanBackground,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: OttomanGlassOverlay(
          opacity: 0.95,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Profil İkonu Seç",
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: GameTheme.ottomanAccent,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: List.generate(_availableIcons.length, (index) {
                    final isSelected =
                        _players[playerIndex].iconIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _players[playerIndex] =
                              _players[playerIndex].copyWith(iconIndex: index);
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _players[playerIndex].color
                                  .withValues(alpha: 0.15)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? _players[playerIndex].color
                                : GameTheme.ottomanBorder,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _availableIcons[index],
                          color: isSelected
                              ? _players[playerIndex].color
                              : GameTheme.ottomanTextSecondary,
                          size: 24,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showColorSelectionDialog(int playerIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: GameTheme.ottomanBackground,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: OttomanGlassOverlay(
          opacity: 0.95,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Mühür Rengi Seç",
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: GameTheme.ottomanAccent,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: _waxSealColors.map((color) {
                    final isSelected =
                        _players[playerIndex].color == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _players[playerIndex] =
                              _players[playerIndex].copyWith(color: color);
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? GameTheme.ottomanAccent
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
