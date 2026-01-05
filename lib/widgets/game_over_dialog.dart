import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import 'dart:math' as math;

/// Game Over dialog showing winner and leaderboard
/// Displays when game ends (only one non-bankrupt player remains)
class GameOverDialog extends ConsumerStatefulWidget {
  const GameOverDialog({super.key});

  @override
  ConsumerState<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends ConsumerState<GameOverDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Safe color parser to prevent crashes
  Color _parseHexColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.blue;
    try {
      final colorString = hexColor.replaceFirst('#', '0xFF');
      return Color(int.parse(colorString));
    } catch (e) {
      debugPrint('Error parsing color: $hexColor');
      return Colors.blue;
    }
  }

  /// Find the winner (non-bankrupt player with highest stars)
  Player _findWinner(List<Player> players) {
    // First, try to find non-bankrupt players
    final activePlayers = players.where((p) => !p.isBankrupt).toList();
    
    if (activePlayers.isEmpty) {
      // All bankrupt, return the one with most stars
      return players.reduce((a, b) => a.stars > b.stars ? a : b);
    }
    
    if (activePlayers.length == 1) {
      return activePlayers.first;
    }
    
    // Multiple active players, return the one with most stars
    return activePlayers.reduce((a, b) => a.stars > b.stars ? a : b);
  }

  /// Get sorted leaderboard
  List<Player> _getLeaderboard(List<Player> players) {
    final sorted = List<Player>.from(players);
    sorted.sort((a, b) {
      // Non-bankrupt players first
      if (a.isBankrupt != b.isBankrupt) {
        return a.isBankrupt ? 1 : -1;
      }
      // Then by stars (descending)
      return b.stars.compareTo(a.stars);
    });
    return sorted;
  }

  void _handleRestart() {
    // For now, we'll use Navigator to go back or restart
    // In a real app, you might want to reset the game state
    Navigator.of(context).pop();
    
    // TODO: Implement proper game restart logic
    // This could be ref.read(gameProvider.notifier).resetGame();
    // For now, we'll just close the dialog
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final players = gameState.players;
    
    if (players.isEmpty) {
      return const SizedBox.shrink();
    }

    final winner = _findWinner(players);
    final leaderboard = _getLeaderboard(players);
    final winnerColor = _parseHexColor(winner.color);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            children: [
              // Animated confetti particles
              ...List.generate(20, (index) {
                final random = math.Random(index);
                return AnimatedBuilder(
                  animation: _confettiAnimation,
                  builder: (context, child) {
                    final progress = _confettiAnimation.value;
                    final startX = random.nextDouble() * 400;
                    final endY = random.nextDouble() * 600 + 200;
                    final rotation = progress * math.pi * 4;
                    
                    return Positioned(
                      left: startX,
                      top: -50 + (endY * progress),
                      child: Transform.rotate(
                        angle: rotation,
                        child: Opacity(
                          opacity: 1.0 - (progress * 0.5),
                          child: Icon(
                            Icons.star,
                            size: 16 + (random.nextDouble() * 8),
                            color: [
                              Colors.amber,
                              Colors.orange,
                              Colors.yellow,
                              Colors.red,
                              Colors.pink,
                            ][index % 5],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
              
              // Main dialog content
              Container(
                width: 400,
                constraints: const BoxConstraints(maxHeight: 600),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.amber.shade50,
                      Colors.orange.shade50,
                      Colors.yellow.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.amber.shade400,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trophy header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade300,
                            Colors.amber.shade400,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'OYUN BİTTİ!',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Winner section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Text(
                            'KAZANAN',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade700,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: winnerColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: winnerColor,
                                width: 3,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Winner avatar
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: winnerColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: winnerColor.withValues(alpha: 0.5),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      winner.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Winner info
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      winner.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 20,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${winner.stars} Yıldız',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Leaderboard
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SKOR TABLOSU',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade700,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: leaderboard.length,
                              itemBuilder: (context, index) {
                                final player = leaderboard[index];
                                final playerColor = _parseHexColor(player.color);
                                final isWinner = player.id == winner.id;
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isWinner
                                        ? Colors.amber.shade100
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isWinner
                                          ? Colors.amber.shade400
                                          : Colors.grey.shade300,
                                      width: isWinner ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Rank
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: index == 0
                                              ? Colors.amber
                                              : index == 1
                                                  ? Colors.grey.shade400
                                                  : index == 2
                                                      ? Colors.brown.shade300
                                                      : Colors.grey.shade300,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Avatar
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: playerColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            player.name[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Name
                                      Expanded(
                                        child: Text(
                                          player.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: isWinner
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: Colors.brown.shade900,
                                          ),
                                        ),
                                      ),
                                      // Stars
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${player.stars}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Bankrupt indicator
                                      if (player.isBankrupt)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8),
                                          child: Icon(
                                            Icons.trending_down,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Restart button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _handleRestart,
                          icon: const Icon(Icons.refresh, size: 24),
                          label: Text(
                            'YENİDEN BAŞLAT',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
