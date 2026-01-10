import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/board_config.dart';
import '../models/game_enums.dart'; // GamePhase, CardType
import '../models/player.dart';
import '../providers/game_notifier.dart';
import '../core/theme/game_theme.dart';
import 'dice_roller.dart';
import 'game_log.dart';
import 'floating_score.dart'; // Import added
import 'enhanced_tile_widget.dart'; // New import for the new implementation

class BoardView extends ConsumerStatefulWidget {
  const BoardView({super.key});
  @override
  ConsumerState<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends ConsumerState<BoardView> {
  late ConfettiController _confettiController;
  final List<Widget> _floatingEffects = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _addFloatingEffect(String text, Color color) {
    if (!mounted) return;
    Key key = UniqueKey();
    setState(() {
      _floatingEffects.add(
        Positioned(
          key: key,
          top: MediaQuery.of(context).size.shortestSide * 0.45,
          left: MediaQuery.of(context).size.shortestSide * 0.4,
          width: 200,
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
    final state = ref.watch(gameProvider);
    if (state.phase == GamePhase.gameOver) _confettiController.play();

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

    // Responsive Kare Boyutu Hesaplama
    final double screenShortest = MediaQuery.of(context).size.shortestSide;
    final double boardSize = screenShortest * 0.95; // Ekranın %95'i

    // Kenar uzunluğu logic: 2 KÖŞE + 9 NORMAL
    // Köşeler normalin 1.5 katı olsun.
    // 1.5 + 9 + 1.5 = 12 birim.
    final double unitSize = boardSize / 12;
    final double cornerSize = unitSize * 1.5;
    final double normalSize = unitSize;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: GameTheme.tableDecoration,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // --- ANA TAHTA KATMANI (Grid System) ---
              Container(
                width: boardSize,
                height: boardSize,
                decoration: GameTheme.boardDecoration,
                child: Column(
                  children: [
                    // ÜST SATIR (Soldan Sağa: 10 -> 20)
                    SizedBox(
                      height: cornerSize,
                      child: Row(
                        children: [
                          EnhancedTileWidget(
                            tile: BoardConfig.tiles[10],
                            width: cornerSize,
                            height: cornerSize,
                          ),
                          ...List.generate(
                            9,
                            (i) => EnhancedTileWidget(
                              tile: BoardConfig.tiles[11 + i],
                              width: normalSize,
                              height: cornerSize,
                            ),
                          ),
                          EnhancedTileWidget(
                            tile: BoardConfig.tiles[20],
                            width: cornerSize,
                            height: cornerSize,
                          ),
                        ],
                      ),
                    ),

                    // ORTA BÖLÜM (Sol Kenar + Orta Alan + Sağ Kenar)
                    Expanded(
                      child: Row(
                        children: [
                          // SOL KENAR (Yukarıdan Aşağı: 9 -> 1)
                          // SOL KENAR (Yukarıdan Aşağı: 9 -> 1) - DÖNÜK (90 derece)
                          SizedBox(
                            width: cornerSize,
                            child: Column(
                              children: List.generate(
                                9,
                                (i) => RotatedBox(
                                  quarterTurns: 1,
                                  child: EnhancedTileWidget(
                                    tile: BoardConfig.tiles[9 - i],
                                    width: normalSize,
                                    height: cornerSize,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // ORTA ALAN (Center)
                          Expanded(
                            child: Container(
                              decoration: GameTheme.centerAreaDecoration,
                              margin: const EdgeInsets.all(4),
                              child: Stack(
                                children: [
                                  const Center(
                                    child: Opacity(
                                      opacity: 0.1,
                                      child: Icon(
                                        Icons.menu_book,
                                        size: 150,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Center(child: _buildHUD(state)),
                                ],
                              ),
                            ),
                          ),

                          // SAĞ KENAR (Yukarıdan Aşağı: 21 -> 29)
                          // SAĞ KENAR (21 -> 29) - DÖNÜK (270 derece)
                          SizedBox(
                            width: cornerSize,
                            child: Column(
                              children: List.generate(
                                9,
                                (i) => RotatedBox(
                                  quarterTurns: 3,
                                  child: EnhancedTileWidget(
                                    tile: BoardConfig.tiles[21 + i],
                                    width: normalSize,
                                    height: cornerSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ALT SATIR (Soldan Sağa: 0 -> 39..31 -> 30) - Hayır Layout:
                    // 0 Sol Alt, 30 Sağ Alt.
                    // Alt kenar (30 ile 0 arası) : 31..39 (Sağdan sola akar)
                    // Row Children: [0] + [39, 38, ..., 31] + [30]
                    SizedBox(
                      height: cornerSize,
                      child: Row(
                        children: [
                          EnhancedTileWidget(
                            tile: BoardConfig.tiles[0],
                            width: cornerSize,
                            height: cornerSize,
                          ),
                          ...List.generate(
                            9,
                            (i) => EnhancedTileWidget(
                              tile: BoardConfig.tiles[39 - i],
                              width: normalSize,
                              height: cornerSize,
                            ),
                          ),
                          EnhancedTileWidget(
                            tile: BoardConfig.tiles[30],
                            width: cornerSize,
                            height: cornerSize,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- PİYONLAR (Grid Koordinat Hesaplamalı) ---
              ..._buildGroupedPlayers(
                state.players,
                boardSize,
                cornerSize,
                normalSize,
                state.currentPlayer.id,
              ),

              // --- EFEKTLER ---
              ..._floatingEffects,
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(confettiController: _confettiController),
              ),

              // Log (Bottom Right corner area)
              Positioned(
                bottom: cornerSize + 20,
                right: cornerSize + 20,
                child: GameLog(logs: state.logs),
              ),

              // --- DIALOGLAR ---
              if (state.showCardDialog && state.currentCard != null)
                _buildOverlay(child: _buildCardDialog(ref, state)),

              if (state.showQuestionDialog && state.currentQuestion != null)
                _buildOverlay(child: _buildQuestionDialog(ref, state)),

              if (state.showPurchaseDialog && state.currentTile != null)
                _buildOverlay(child: _buildPurchaseDialog(ref, state)),

              if (state.showUpgradeDialog && state.currentTile != null)
                _buildOverlay(child: _buildUpgradeDialog(ref, state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHUD(dynamic state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "EDEBİYAT MACERA",
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const DiceRoller(),
        const SizedBox(height: 10),
        Text(
          state.lastAction,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Koordinat Hesaplayıcı
  Offset _calculateTileOffset(
    int tileId,
    double cornerSize,
    double normalSize,
  ) {
    // 0: Sol Alt
    if (tileId == 0) return Offset(0, cornerSize + 9 * normalSize);

    // 1-9: Sol Kenar (Aşağıdan Yukarı) -> Ama görselde Yukarıdan Aşağı 9..1
    // Tile 1: En alt. Y = cornerSize + 8*normalSize. Wait.
    // 0 H = corner. 1..9 H = 9*normal. 10 H = corner. Total = 2C + 9N.
    // Logic:
    // Left Column Top is at Y = cornerSize.
    // Tile 9 is Y = cornerSize + 0*normal.
    // Tile 1 is Y = cornerSize + 8*normal.
    // Generic: Y = cornerSize + (9 - tileId) * normalSize. X = 0.
    if (tileId > 0 && tileId < 10) {
      return Offset(0, cornerSize + (9 - tileId) * normalSize);
    }

    // 10: Sol Üst
    if (tileId == 10) return Offset(0, 0);

    // 11-19: Üst Kenar (Soldan Sağa)
    // X = cornerSize + (tileId - 11) * normalSize. Y = 0.
    if (tileId > 10 && tileId < 20) {
      return Offset(cornerSize + (tileId - 11) * normalSize, 0);
    }

    // 20: Sağ Üst
    // X = cornerSize + 9*normalSize.
    if (tileId == 20) return Offset(cornerSize + 9 * normalSize, 0);

    // 21-29: Sağ Kenar (Yukarıdan Aşağı)
    // X = cornerSize + 9*normalSize. Y = cornerSize + (tileId - 21) * normalSize.
    if (tileId > 20 && tileId < 30) {
      return Offset(
        cornerSize + 9 * normalSize,
        cornerSize + (tileId - 21) * normalSize,
      );
    }

    // 30: Sağ Alt
    // X = cornerSize + 9*normalSize. Y = cornerSize + 9*normalSize.
    if (tileId == 30)
      return Offset(cornerSize + 9 * normalSize, cornerSize + 9 * normalSize);

    // 31-39: Alt Kenar (Sağdan Sola)
    // X logic: Tile 31 is right-most (next to 30).
    // Tile 39 is left-most (next to 0).
    // X = cornerSize + (39 - tileId) * normalSize. Y = cornerSize + 9*normalSize.
    if (tileId > 30) {
      return Offset(
        cornerSize + (39 - tileId) * normalSize,
        cornerSize + 9 * normalSize,
      );
    }

    return Offset.zero;
  }

  // Center Offset Helper
  Offset _getTileCenter(int tileId, double cornerSize, double normalSize) {
    Offset topLeft = _calculateTileOffset(tileId, cornerSize, normalSize);
    double w = normalSize;
    double h = normalSize;

    if (tileId % 10 == 0) {
      w = cornerSize;
      h = cornerSize;
    } else {
      // Hangi kenarda?
      if (tileId < 10 || (tileId > 20 && tileId < 30)) {
        // Sol ve Sağ kenar dikeydir. Genişlik cornerSize, Yükseklik normalSize mı?
        // Kodda: EnhancedTileWidget(width: cornerSize, height: normalSize)
        w = cornerSize;
        h = normalSize;
      } else {
        // Üst ve Alt kenar yataydır.
        // Kodda: EnhancedTileWidget(width: normalSize, height: cornerSize)
        w = normalSize;
        h = cornerSize;
      }
    }
    return topLeft + Offset(w / 2, h / 2);
  }

  List<Widget> _buildGroupedPlayers(
    List<Player> players,
    double boardSize,
    double cornerSize,
    double normalSize,
    String currentPlayerId,
  ) {
    Map<int, List<Player>> groups = {};
    for (var p in players) {
      if (!groups.containsKey(p.position)) groups[p.position] = [];
      groups[p.position]!.add(p);
    }

    List<Widget> pawnWidgets = [];

    // Player Pawn Size
    double pawnSize = normalSize * 0.4;

    groups.forEach((pos, group) {
      Offset tileCenter = _getTileCenter(pos, cornerSize, normalSize);

      // Center the wrap around the tile center
      // Since AnimatedPositioned works Top-Left, we calculate top/left for the container
      // Container size estimates:
      double wrapSize = (pos % 10 == 0) ? cornerSize * 0.8 : normalSize * 0.8;

      double left = tileCenter.dx - wrapSize / 2;
      double top = tileCenter.dy - wrapSize / 2;

      pawnWidgets.add(
        AnimatedPositioned(
          duration: 600.ms,
          curve: Curves.easeInOutCubic,
          left: left,
          top: top,
          child: Container(
            width: wrapSize,
            height: wrapSize,
            alignment: Alignment.center,
            child: Wrap(
              alignment: WrapAlignment.center,
              children: group
                  .map((p) => _buildPawn(p, pawnSize, currentPlayerId))
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
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black54)],
      ),
      child: Icon(
        IconData(0xe000 + p.iconIndex, fontFamily: 'MaterialIcons'),
        size: size * 0.6,
        color: Colors.white,
      ),
    );

    if (p.id == currentPlayerId) {
      return pawn
          .animate(onPlay: (c) => c.repeat())
          .boxShadow(
            begin: const BoxShadow(color: Colors.white, blurRadius: 0),
            end: const BoxShadow(color: Colors.white, blurRadius: 15),
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
            boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black)],
          ),
          child: child,
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  // --- Dialog Builders (Mevcut koddan taşınanlar) ---
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
      Icon(Icons.shopping_cart, size: 50, color: Colors.green),
      SizedBox(height: 10),
      Text("TELİF HAKKI", style: TextStyle(fontWeight: FontWeight.bold)),
      Text(state.currentTile!.title, style: TextStyle(fontSize: 18)),
      SizedBox(height: 10),
      Text("Fiyat: ${state.currentTile!.price} Yıldız"),
      SizedBox(height: 20),
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
}
