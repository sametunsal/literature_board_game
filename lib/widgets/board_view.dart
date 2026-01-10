import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/board_config.dart';
import '../models/board_tile.dart';
import '../models/game_enums.dart'; // GamePhase, CardType
import '../models/player.dart';
import '../providers/game_notifier.dart';
import '../core/theme/game_theme.dart';
import 'dice_roller.dart';
import 'game_tile_widget.dart';
import 'game_log.dart';
import 'floating_score.dart'; // Import added

class BoardView extends ConsumerStatefulWidget {
  const BoardView({super.key});

  @override
  ConsumerState<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends ConsumerState<BoardView> {
  late ConfettiController _confettiController;
  // Local list to manage multiple overlapping floating effects
  final List<Widget> _floatingEffects = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 10),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _addFloatingEffect(String text, Color color) {
    if (!mounted) return;

    // Unique key to identify this specific widget instance
    Key key = UniqueKey();

    setState(() {
      _floatingEffects.add(
        Positioned(
          key: key,
          top: MediaQuery.of(context).size.shortestSide * 0.45,
          left: MediaQuery.of(context).size.shortestSide * 0.4,
          width: 200, // Constrain width
          child: FloatingScore(
            text: text,
            color: color,
            onComplete: () {
              if (mounted) {
                setState(() {
                  _floatingEffects.removeWhere((w) => w.key == key);
                });
              }
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    // Listen for effect triggers
    ref.listen(gameProvider, (previous, next) {
      if (next.floatingEffect != null &&
          next.floatingEffect != previous?.floatingEffect) {
        _addFloatingEffect(
          next.floatingEffect!.text,
          next.floatingEffect!.color,
        );
      }
    });

    // Ekranın kısa kenarını baz alarak tahta boyutunu belirle
    final boardSize = MediaQuery.of(context).size.shortestSide * 0.95;
    final tileSize =
        boardSize / 13; // 13 birimlik grid (9 normal + 2x2 köşeler)

    // Oyun bittiyse konfeti patlat
    if (gameState.phase == GamePhase.gameOver) {
      _confettiController.play();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF37474F),
              Color(0xFF263238),
            ], // Ortası daha açık, kenarlar koyu
            radius: 1.2,
          ),
        ),
        child: Center(
          child: Container(
            width: boardSize,
            height: boardSize,
            decoration: GameTheme.boardDecoration,
            child: Stack(
              children: [
                // 1. ORTA ALAN (Center)
                Center(child: _buildCenterArea(gameState, boardSize, ref)),

                // 2. KUTUCUKLAR (Tiles)
                ...BoardConfig.tiles.map((tile) => _buildTile(tile, tileSize)),

                // 3. OYUNCULAR (Piyonlar) - Animated
                ..._buildGroupedPlayers(
                  gameState.players,
                  tileSize,
                  gameState.currentPlayer.id,
                ),

                // 4. FLOATING EFFECTS (Para uçuşları)
                ..._floatingEffects,

                // 5. KONFETİ (En üst katman)
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: true,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple,
                    ],
                  ),
                ),

                // 6. DIALOGLAR (Overlay) - Animated Pop-in
                if (gameState.showCardDialog && gameState.currentCard != null)
                  _buildOverlay(child: _buildCardDialog(ref, gameState))
                      .animate()
                      .scale(duration: 400.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 300.ms),

                if (gameState.showQuestionDialog &&
                    gameState.currentQuestion != null)
                  _buildOverlay(child: _buildQuestionDialog(ref, gameState))
                      .animate()
                      .scale(duration: 400.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 300.ms),

                if (gameState.showPurchaseDialog &&
                    gameState.currentTile != null)
                  _buildOverlay(child: _buildPurchaseDialog(ref, gameState))
                      .animate()
                      .scale(duration: 400.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 300.ms),

                if (gameState.showUpgradeDialog &&
                    gameState.currentTile != null)
                  _buildOverlay(child: _buildUpgradeDialog(ref, gameState))
                      .animate()
                      .scale(duration: 400.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 300.ms),

                // 7. OYUN GÜNLÜĞÜ (Log)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: GameLog(logs: gameState.logs),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Tile Positioning Logic ---
  Widget _buildTile(BoardTile tile, double size) {
    double top = 0;
    double left = 0;

    if (tile.id == 0) {
      left = 0;
      top = 11 * size;
    } // Sol Alt
    else if (tile.id > 0 && tile.id < 10) {
      // SOL KENAR (Yukarı Çıkıyor)
      left = 0;
      top = (11 - tile.id) * size;
    } else if (tile.id == 10) {
      left = 0;
      top = 0;
    } // SOL ÜST
    else if (tile.id > 10 && tile.id < 20) {
      // ÜST KENAR (Sağa Gidiyor)
      left = (tile.id - 10 + 0.5) * size;
      top = 0;
    } else if (tile.id == 20) {
      left = 11 * size;
      top = 0;
    } // SAĞ ÜST
    else if (tile.id > 20 && tile.id < 30) {
      // SAĞ KENAR (Aşağı İniyor)
      left = 11.5 * size;
      top = (tile.id - 20 + 0.5) * size;
    } else if (tile.id == 30) {
      left = 11 * size;
      top = 11 * size;
    } // SAĞ ALT
    else if (tile.id > 30) {
      // ALT KENAR (Sola Gidiyor)
      left = (11 - (tile.id - 30) + 0.5) * size;
      top = 11.5 * size;
    }

    return Positioned(
      left: left,
      top: top,
      child: GameTileWidget(tile: tile, size: size),
    );
  }

  // --- Player Positioning Logic (Grouped to avoid overlap) ---
  List<Widget> _buildGroupedPlayers(
    List<Player> players,
    double size,
    String currentPlayerId,
  ) {
    // Oyuncuları bulundukları kareye göre grupla
    Map<int, List<Player>> groups = {};
    for (var p in players) {
      if (!groups.containsKey(p.position)) groups[p.position] = [];
      groups[p.position]!.add(p);
    }

    List<Widget> pawnWidgets = [];

    groups.forEach((pos, group) {
      double top = 0, left = 0;
      if (pos == 0) {
        left = 0;
        top = 11 * size;
      } else if (pos < 10) {
        left = 0;
        top = (11 - pos) * size;
      } else if (pos == 10) {
        left = 0;
        top = 0;
      } else if (pos < 20) {
        left = (pos - 10 + 0.5) * size;
        top = 0;
      } else if (pos == 20) {
        left = 11 * size;
        top = 0;
      } else if (pos < 30) {
        left = 11.5 * size;
        top = (pos - 20 + 0.5) * size;
      } else if (pos == 30) {
        left = 11 * size;
        top = 11 * size;
      } else {
        left = (11 - (pos - 30) + 0.5) * size;
        top = 11.5 * size;
      }

      double areaSize = (pos % 10 == 0) ? size * 1.5 : size;

      pawnWidgets.add(
        AnimatedPositioned(
          duration: 600.ms,
          curve: Curves.easeInOutCubic,
          left: left,
          top: top,
          child: Container(
            width: areaSize,
            height: areaSize,
            alignment: Alignment.center,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 2,
              runSpacing: 2,
              children: group
                  .map((p) => _buildPawn(p, size, currentPlayerId))
                  .toList(),
            ),
          ),
        ),
      );
    });

    return pawnWidgets;
  }

  Widget _buildPawn(Player p, double size, String currentPlayerId) {
    Widget pawn = Container(
      width: size * 0.35,
      height: size * 0.35,
      decoration: BoxDecoration(
        color: p.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black54)],
      ),
      child: Icon(
        IconData(0xe000 + p.iconIndex, fontFamily: 'MaterialIcons'),
        size: size * 0.2,
        color: Colors.white,
      ),
    );

    if (p.id == currentPlayerId) {
      return pawn
          .animate(onPlay: (c) => c.repeat())
          .boxShadow(
            begin: const BoxShadow(
              color: Colors.white,
              blurRadius: 0,
              spreadRadius: 0,
            ),
            end: const BoxShadow(
              color: Colors.white,
              blurRadius: 20,
              spreadRadius: 5,
            ),
          )
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.2, 1.2),
            duration: 1000.ms,
            curve: Curves.easeInOut,
          );
    }
    return pawn;
  }

  // --- Center Area ---
  Widget _buildCenterArea(var state, double boardSize, WidgetRef ref) {
    return Container(
      width: boardSize * 0.5,
      height: boardSize * 0.5,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "EDEBİYAT MACERA",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
              color: GameTheme.primaryText,
            ),
          ),
          const Divider(),
          Text(
            state.lastAction,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDeck("ŞANS", Colors.pink[100]!),
              const SizedBox(width: 10),
              _buildDeck("KADER", Colors.teal[100]!),
            ],
          ),
          const SizedBox(height: 10),
          if (!state.isDiceRolled &&
              !state.showCardDialog &&
              !state.showPurchaseDialog &&
              !state.showQuestionDialog)
            const DiceRoller() // Yeni widget kullanımı
          else if (state.isDiceRolled &&
              !state.showCardDialog &&
              !state.showPurchaseDialog &&
              !state.showQuestionDialog)
            // Zar animasyonu DiceRoller içinde yönetildiği için buradaki text'e gerek kalmayabilir
            // ama DiceRoller sadece "isDiceRolled" durumunda da görünüyor.
            // BoardView içindeki logic DiceRoller'ı render etmeli.
            // Yukardaki if/else yapısını DiceRoller'a bıraktık zaten.
            // Tekrar düzenleyelim:
            const DiceRoller(),
        ],
      ),
    );
  }

  Widget _buildDeck(String title, Color color) {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26),
        boxShadow: const [
          BoxShadow(offset: Offset(2, 2), color: Colors.black12),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _buildOverlay({required Widget child}) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildQuestionDialog(WidgetRef ref, GameState state) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        "SORU",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      const SizedBox(height: 10),
      Text(state.currentQuestion!.text, textAlign: TextAlign.center),
      const SizedBox(height: 20),
      ...List.generate(
        state.currentQuestion!.options.length,
        (index) => Padding(
          padding: const EdgeInsets.all(4),
          child: ElevatedButton(
            onPressed: () =>
                ref.read(gameProvider.notifier).answerQuestion(index),
            child: Text(state.currentQuestion!.options[index]),
          ),
        ),
      ),
    ],
  );

  Widget _buildPurchaseDialog(WidgetRef ref, GameState state) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.shopping_cart, size: 50, color: Colors.green),
      const SizedBox(height: 10),
      const Text("TELİF HAKKI", style: TextStyle(fontWeight: FontWeight.bold)),
      Text(state.currentTile!.title, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 10),
      Text("Fiyat: ${state.currentTile!.price} Yıldız"),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => ref.read(gameProvider.notifier).declinePurchase(),
            child: const Text("PAS GEÇ"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => ref.read(gameProvider.notifier).purchaseProperty(),
            child: const Text("SATIN AL"),
          ),
        ],
      ),
    ],
  );

  Widget _buildCardDialog(WidgetRef ref, GameState state) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        state.currentCard!.type == CardType.sans ? Icons.star : Icons.bolt,
        size: 60,
        color: state.currentCard!.type == CardType.sans
            ? Colors.pink
            : Colors.teal,
      ),
      const SizedBox(height: 16),
      Text(
        state.currentCard!.type == CardType.sans ? "ŞANS KARTI" : "KADER KARTI",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      const SizedBox(height: 16),
      Text(
        state.currentCard!.description,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: () => ref.read(gameProvider.notifier).closeCardDialog(),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(120, 45),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        child: const Text("TAMAM"),
      ),
    ],
  );

  Widget _buildUpgradeDialog(WidgetRef ref, GameState state) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.arrow_circle_up, size: 50, color: Colors.orange),
      const SizedBox(height: 10),
      const Text(
        "Mülk Geliştirme",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      Text(state.currentTile!.title),
      const SizedBox(height: 20),
      Text(
        state.currentTile!.upgradeLevel < 3
            ? "Baskı Yapmak İster misiniz?"
            : "Cilt/Seri Yapmak İster misiniz?",
        textAlign: TextAlign.center,
      ),
      Text(
        "Maliyet: ${state.currentTile!.upgradeLevel < 3 ? (state.currentTile!.price! * 0.5).round() : (state.currentTile!.price! * 2).round()} Yıldız",
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () => ref.read(gameProvider.notifier).declineUpgrade(),
            child: const Text("Hayır"),
          ),
          ElevatedButton(
            onPressed: () => ref.read(gameProvider.notifier).upgradeProperty(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text("Evet, Geliştir"),
          ),
        ],
      ),
    ],
  );
}
