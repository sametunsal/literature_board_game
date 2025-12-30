import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../models/turn_result.dart';
import '../models/player.dart';
import '../models/player_type.dart';
import '../models/turn_phase.dart';
import '../utils/turn_summary_generator.dart';

class TurnSummaryOverlay extends ConsumerStatefulWidget {
  const TurnSummaryOverlay({super.key});

  @override
  ConsumerState<TurnSummaryOverlay> createState() => _TurnSummaryOverlayState();
}

class _TurnSummaryOverlayState extends ConsumerState<TurnSummaryOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) {
        ref.read(gameProvider.notifier).startNextTurn();
      }
    });
  }

  // Güvenli Renk Dönüştürücü (ÇÖKMEYİ ENGELLER)
  Color _safeParseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.blue;
    try {
      final cleanHex = hexString.replaceFirst('#', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('0xFF$cleanHex'));
      } else if (cleanHex.length == 8) {
        return Color(int.parse('0x$cleanHex'));
      }
      return Colors.blue;
    } catch (e) {
      debugPrint("Renk hatası: $e");
      return Colors.red; // Hata durumunda kırmızı dön
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tüm build işlemini try-catch içine alıyoruz (SİYAH EKRAN KORUMASI)
    try {
      final turnPhase = ref.watch(turnPhaseProvider);
      final turnResult = ref.watch(lastTurnResultProvider);
      final gameState = ref.watch(gameProvider);

      // Sadece tur bittiyse göster
      if (turnPhase != TurnPhase.turnEnded) {
        if (_controller.value > 0) _controller.reset();
        return const SizedBox.shrink();
      }

      // Animasyonu başlat
      if (_controller.value == 0) {
        _controller.forward();
        // Bot kontrolü
        if (turnResult.playerIndex >= 0 &&
            turnResult.playerIndex < gameState.players.length) {
          if (gameState.players[turnResult.playerIndex].type ==
              PlayerType.bot) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted &&
                  ref.read(turnPhaseProvider) == TurnPhase.turnEnded) {
                _handleContinue();
              }
            });
          }
        }
      }

      // Veri kontrolü
      if (turnResult.playerIndex < 0 ||
          turnResult.playerIndex >= gameState.players.length) {
        return const SizedBox.shrink();
      }

      final player = gameState.players[turnResult.playerIndex];
      final summaryText = TurnSummaryGenerator.generateTurnSummary(
        turnResult,
        playerName: player.name,
      );

      final playerColor = _safeParseColor(player.color);

      return Stack(
        children: [
          // Arka Plan
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(color: Colors.black54),
            ),
          ),
          // Kart
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: playerColor,
                        child: Text(
                          player.name.isNotEmpty
                              ? player.name[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "TUR BİTTİ",
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        player.name,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 30),
                      Text(
                        summaryText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: playerColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("DEVAM ET"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } catch (e, stack) {
      // OLAĞANÜSTÜ DURUM: Eğer widget çizerken hata olursa Siyah Ekran yerine bunu göster
      debugPrint("Overlay Hatası: $e \n $stack");
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Görüntüleme Hatası",
                style: TextStyle(color: Colors.red),
              ),
              ElevatedButton(
                onPressed: _handleContinue,
                child: const Text("Yine de Devam Et"),
              ),
            ],
          ),
        ),
      );
    }
  }
}
