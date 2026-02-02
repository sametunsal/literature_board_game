import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/player.dart';
import '../widgets/board_view.dart';
import '../../providers/game_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final List<TextEditingController> _nameControllers = [];
  final List<Player> _players = [];
  final int _maxPlayers = 4;

  // Available pawn colors
  final List<Color> _playerColors = [
    const Color(0xFFD32F2F), // Red
    const Color(0xFF1976D2), // Blue
    const Color(0xFF388E3C), // Green
    const Color(0xFFFBC02D), // Yellow
    const Color(0xFF8E24AA), // Purple
    const Color(0xFFF4511E), // Deep Orange
    const Color(0xFF00ACC1), // Cyan
    const Color(0xFF5D4037), // Brown
  ];

  // Available Icons
  final List<IconData> _availableIcons = [
    Icons.person,
    Icons.face,
    Icons.emoji_people,
    Icons.sentiment_satisfied_alt,
    Icons.catching_pokemon, // Fun icon for "catching" knowledge
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
          color: _playerColors[index % _playerColors.length],
          iconIndex: index,
        ),
      );
    });
  }

  void _removePlayer(int index) {
    if (_players.length <= 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("En az 2 oyuncu gerekli!")));
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

  // ═══════════════════════════════════════════════════════════════════════════
  // MODALS
  // ═══════════════════════════════════════════════════════════════════════════

  void _showAvatarSelectionDialog(int playerIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFF9F7F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Profil İkonu Seç",
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00695C),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: List.generate(_availableIcons.length, (index) {
                  final isSelected = _players[playerIndex].iconIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        // Update player logic to store icon index properly if needed
                        // Currently we store index, but icon retrieval uses Modulo
                        // Let's just update the stored index directly
                        _players[playerIndex] = _players[playerIndex].copyWith(
                          iconIndex: index,
                        );
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _players[playerIndex].color.withOpacity(0.1)
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? _players[playerIndex].color
                              : Colors.grey.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _availableIcons[index],
                        color: isSelected
                            ? _players[playerIndex].color
                            : Colors.grey,
                        size: 28,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorSelectionDialog(int playerIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFF9F7F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Renk Seç",
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00695C),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: _playerColors.map((color) {
                  final isSelected =
                      _players[playerIndex].color.value == color.value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _players[playerIndex] = _players[playerIndex].copyWith(
                          color: color,
                        );
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
                              ? Colors.black.withOpacity(0.5)
                              : Colors.transparent,
                          width: isSelected ? 3 : 0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 28,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF9F7F2); // Warm Cream

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF00695C),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "OYUNCU KAYDI",
          style: GoogleFonts.cormorantGaramond(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00695C),
            fontSize: 28,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Pattern Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/wooden_table_bg.png', // Reusing texture if available, or just keeping clean
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: _players.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index == _players.length) {
                        // Add Player Button (Dashed)
                        if (_players.length < _maxPlayers) {
                          return _buildAddPlayerButton();
                        }
                        return const SizedBox(height: 80); // Bottom padding
                      }

                      return _buildPlayerCard(index);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Start Game FAB (Bottom Right)
          Positioned(right: 24, bottom: 24, child: _buildStartButton()),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(int index) {
    final player = _players[index];
    final controller = _nameControllers[index];

    return Container(
      height: 140, // Provided enough height for the elements
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          // 1. THE PARCHMENT CARD (The Container)
          Container(
            margin: const EdgeInsets.only(
              right: 24,
            ), // Space for Wax Seal overhang
            decoration: BoxDecoration(
              color: const Color(0xFFFDF6E3), // Aged Parchment
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                // Deep soft shadow for floating effect
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 8),
                  blurRadius: 16,
                ),
                // Subtle inner light/border to simulate paper thickness
                BoxShadow(
                  color: const Color(0xFFE6D6BC).withOpacity(0.5),
                  offset: const Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                // 2. AVATAR MEDALLION (High Ergonomics)
                GestureDetector(
                  onTap: () => _showAvatarSelectionDialog(index),
                  child: Container(
                    width: 100, // Large touch target area
                    height: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: const Offset(2, 4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // The "Frame"
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFDF6E3),
                            border: Border.all(
                              color: player.color, // Player Color Frame
                              width: 3,
                            ),
                          ),
                        ),
                        // The Avatar
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: player.color.withOpacity(0.1),
                          child: Icon(
                            _availableIcons[player.iconIndex %
                                _availableIcons.length],
                            color: player.color,
                            size: 36,
                          ),
                        ),
                        // Decorative Outer Ring (Simulating carved wood/metal)
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: player.color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. TYPOGRAPHY (The Ink)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Antique Label
                        Text(
                          "OYUNCU ${index + 1}",
                          style: GoogleFonts.cinzelDecorative(
                            // Or Playfair Display SC
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5D4037), // Dark Sepia
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Handwritten-style Input
                        TextField(
                          controller: controller,
                          style: GoogleFonts.crimsonText(
                            // Or Libre Baskerville
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF212121), // Darkest Ink
                            height: 1.0,
                          ),
                          decoration: InputDecoration(
                            hintText: "İsim Giriniz...",
                            hintStyle: GoogleFonts.crimsonText(
                              color: const Color(0xFFBCAAA4), // Faded Ink
                              fontSize: 24,
                              fontStyle: FontStyle.italic,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Spacer to keep text from going under the wax seal
                const SizedBox(width: 60),
              ],
            ),
          ),

          // 4. WAX SEAL (Color Picker) - Massive & Hanging off edge
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: () => _showColorSelectionDialog(index),
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: player.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    // Deep stamped shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 6),
                      blurRadius: 8,
                    ),
                    // Internal highlight (simulating wax sheen)
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      offset: const Offset(-2, -2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                  // Rough border simulation (optional, or kept clean for "modern" wax)
                  border: Border.all(
                    color: player.color.withOpacity(0.8), // Slightly darker rim
                    width: 4,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Inner "Stamped" Ring
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                    ),
                    // Debossed Icon
                    Icon(
                      Icons.palette,
                      color: Colors.black.withOpacity(0.2), // Engraved look
                      size: 32,
                    ),
                    // Highlight on Icon
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Icon(
                        Icons.palette,
                        color: Colors.white.withOpacity(0.15),
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. CANCELLATION STAMP (Remove Button)
          Positioned(
            top: 4,
            right: 60, // Left of the wax seal
            child: IconButton(
              onPressed: () => _removePlayer(index),
              icon: Transform.rotate(
                angle: -0.2, // Tilted like a stamp
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFA1887F),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Color(0xFFA1887F),
                  ),
                ),
              ),
              tooltip: "Oyuncuyu Kaldır",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPlayerButton() {
    return GestureDetector(
      onTap: _addPlayer,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00695C).withOpacity(0.3),
            width: 2,
            style: BorderStyle
                .none, // Flutter doesn't support dashed easily via BorderStyle alone
          ),
        ),
        // Use CustomPaint for dashed border if strictly needed,
        // simplified here to light opacity with icon
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF00695C).withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF00695C).withOpacity(0.2)),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_circle_outline, color: Color(0xFF00695C)),
                const SizedBox(width: 8),
                Text(
                  "Yeni Oyuncu Ekle",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF00695C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    // 3D Isometric FAB Look
    return GestureDetector(
      onTap: _startGame,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37), // Gold
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.4),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "OYUNU BAŞLAT",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
