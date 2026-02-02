import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/player.dart';
import '../screens/main_menu_screen.dart';

class VictoryScreen extends StatefulWidget {
  final Player winner;
  final VoidCallback? onReturnToMenu;

  const VictoryScreen({super.key, required this.winner, this.onReturnToMenu});

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _particleController;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  // Icons must match SetupScreen to show correct avatar
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
    // Particle System Setup
    _particleController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..addListener(_updateParticles)
          ..repeat();

    // Initial particles
    for (int i = 0; i < 20; i++) {
      _particles.add(_createParticle());
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  _Particle _createParticle() {
    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 20 + 10,
      opacity: _random.nextDouble() * 0.5 + 0.1,
      speed: _random.nextDouble() * 0.002 + 0.001,
      char: String.fromCharCode(_random.nextInt(26) + 65), // Random Letter
    );
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.y += particle.speed;
      if (particle.y > 1.0) {
        particle.y = -0.1;
        particle.x = _random.nextDouble();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. BLURRED BACKGROUND
          Positioned.fill(
            child: Image.asset(
              'assets/images/wooden_table_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF2D2D2D)),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.7)),
            ),
          ),

          // 2. AMBIENT PARTICLES (Floating Gold Letters)
          Positioned.fill(
            child: CustomPaint(painter: ParticlePainter(_particles)),
          ),

          // 3. MAIN CONTENT
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCertificateScroll(),
                  const SizedBox(height: 40),
                  _buildMainMenuButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateScroll() {
    return Container(
          width: 400,
          constraints: const BoxConstraints(minHeight: 500),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF6E3), // Aged Parchment
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // --- ORNAMENTAL BORDER ---
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                bottom: 10,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00695C), // Deep Teal
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFC5A059), // Gold
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // --- CONTENT ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 60,
                  horizontal: 32,
                ),
                child: Column(
                  children: [
                    // TITLE
                    Text(
                      "EDEBİ ZAFER!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2D2D2D),
                        shadows: [
                          const Shadow(
                            color: Color(0xFFC5A059),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 800.ms).scale(),

                    const SizedBox(height: 30),

                    // WINNER AVATAR MEDALLION
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.winner.color.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Laurel Wreath (Simulated with Gold Border for now)
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFC5A059), // Gold
                                width: 6,
                              ),
                            ),
                          ),
                          // Inner Avatar
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color(0xFFFDF6E3),
                            child: CircleAvatar(
                              radius: 54,
                              backgroundColor: widget.winner.color.withOpacity(
                                0.2,
                              ),
                              child: Icon(
                                _availableIcons[widget.winner.iconIndex %
                                    _availableIcons.length],
                                color: widget.winner.color,
                                size: 64,
                              ),
                            ),
                          ),
                          // Shine Effect
                          Positioned(
                            top: 10,
                            right: 30,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 500.ms).scale(curve: Curves.elasticOut),

                    const SizedBox(height: 30),

                    // WINNER NAME
                    Text(
                          widget.winner.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.pinyonScript(
                            // Elegant Script
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00695C),
                          ),
                        )
                        .animate(delay: 800.ms)
                        .slideY(begin: 0.2, end: 0)
                        .fadeIn(),

                    // FLAVOR TEXT
                    Text(
                      "Kütüphanenin Hâkimi",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF5D4037),
                        letterSpacing: 2,
                      ),
                    ).animate(delay: 1000.ms).fadeIn(),

                    const SizedBox(height: 20),
                    const Divider(
                      color: Color(0xFFC5A059),
                      thickness: 1,
                      indent: 40,
                      endIndent: 40,
                    ),
                    const SizedBox(height: 10),

                    // STATS (Optional)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stars, color: widget.winner.color, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Şampiyon",
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- DECORATIVE CORNERS (Simulated) ---
              Positioned(
                top: -5,
                left: -5,
                child: _CornerDecoration(isTop: true, isLeft: true),
              ),
              Positioned(
                top: -5,
                right: -5,
                child: _CornerDecoration(isTop: true, isLeft: false),
              ),
              Positioned(
                bottom: -5,
                left: -5,
                child: _CornerDecoration(isTop: false, isLeft: true),
              ),
              Positioned(
                bottom: -5,
                right: -5,
                child: _CornerDecoration(isTop: false, isLeft: false),
              ),
            ],
          ),
        )
        .animate()
        .slideY(
          begin: -0.5,
          end: 0,
          duration: 1000.ms,
          curve: Curves.easeOutBack,
        )
        .scaleY(
          begin: 0,
          end: 1,
          duration: 1000.ms,
          alignment: Alignment.topCenter,
        )
        .fadeIn(duration: 500.ms);
  }

  Widget _buildMainMenuButton(BuildContext context) {
    return GestureDetector(
          onTap:
              widget.onReturnToMenu ??
              () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const MainMenuScreen(),
                  ),
                  (route) => false,
                );
              },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFC5A059), // Gold
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                const BoxShadow(
                  color: Color(0xFF5D4037), // Dark wood shadow
                  offset: Offset(0, 6),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 10),
                  blurRadius: 10,
                ),
              ],
              border: Border.all(color: const Color(0xFFFDF6E3), width: 2),
            ),
            child: Text(
              "ANA MENÜYE DÖN",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFDF6E3),
                letterSpacing: 1.5,
              ),
            ),
          ),
        )
        .animate(delay: 1500.ms)
        .slideY(begin: 1, end: 0, curve: Curves.easeOut)
        .fadeIn();
  }
}

// ════════════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════════════

class _CornerDecoration extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _CornerDecoration({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle:
          (isTop ? (isLeft ? 0 : 90) : (isLeft ? 270 : 180)) * (math.pi / 180),
      child: const Icon(
        Icons.filter_vintage, // Or any ornate icon
        size: 40,
        color: Color(0xFFC5A059),
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double opacity;
  double speed;
  String char;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.char,
  });
}

class ParticlePainter extends CustomPainter {
  final List<_Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var particle in particles) {
      textPainter.text = TextSpan(
        text: particle.char,
        style: GoogleFonts.cinzelDecorative(
          fontSize: particle.size,
          color: Color(0xFFC5A059).withOpacity(particle.opacity),
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(particle.x * size.width, particle.y * size.height),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
