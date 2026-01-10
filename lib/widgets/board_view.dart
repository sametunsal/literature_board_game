import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/board_config.dart';
import '../models/board_tile.dart';
import '../models/game_enums.dart';
import '../models/player.dart';
import '../providers/game_notifier.dart';
import '../core/theme/game_theme.dart';
import 'enhanced_tile_widget.dart';
import 'game_log.dart';
import 'dice_roller.dart';
import 'question_dialog.dart';
import 'card_dialog.dart';
import 'copyright_purchase_dialog.dart';

class BoardView extends ConsumerStatefulWidget {
  const BoardView({super.key});
  @override
  ConsumerState<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends ConsumerState<BoardView> {
  late ConfettiController _confettiController;

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    if (state.phase == GamePhase.gameOver) _confettiController.play();

    // 1. GRID HESAPLAMALARI
    final double screenShortest = MediaQuery.of(context).size.shortestSide;
    final double boardSize = screenShortest * 0.98; // Ekranın neredeyse tamamı

    // Sistem: 12 Birim (1.5 Köşe + 9 Normal + 1.5 Köşe)
    final double u = boardSize / 12.0;

    return Scaffold(
      backgroundColor: GameTheme.backgroundTable,
      body: Center(
        child: Container(
          width: boardSize,
          height: boardSize,
          decoration: GameTheme.boardDecoration,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 2. ORTA ALAN (Background)
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.all(u * 1.5), // Kenarlar kadar içeride
                  decoration: GameTheme.centerAreaDecoration,
                  child: Stack(
                    children: [
                      Center(
                        child: Opacity(
                          opacity: 0.15,
                          child: Icon(
                            Icons.auto_stories,
                            size: boardSize * 0.4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Center(child: _buildHUD(state)),
                    ],
                  ),
                ),
              ),

              // 3. KUTUCUKLAR (Tiles)
              ...List.generate(40, (index) {
                final layout = _calculateTileLayout(index, boardSize, u);
                final tile = BoardConfig.getTile(index); // Safe getter

                return Positioned(
                  left: layout.rect.left,
                  top: layout.rect.top,
                  width: layout.rect.width,
                  height: layout.rect.height,
                  child: RotatedBox(
                    quarterTurns: layout.quarterTurns,
                    child: EnhancedTileWidget(
                      tile: tile,
                      // Widget içine her zaman dik boyutları gönderiyoruz, RotatedBox onu çeviriyor
                      width: layout.quarterTurns % 2 == 0
                          ? layout.rect.width
                          : layout.rect.height,
                      height: layout.quarterTurns % 2 == 0
                          ? layout.rect.height
                          : layout.rect.width,
                    ),
                  ),
                );
              }),

              // 4. PİYONLAR
              ..._buildGroupedPlayers(state.players, boardSize, u),

              // 5. EFEKTLER
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                ),
              ),
              Positioned(
                bottom: u * 2,
                right: u * 2,
                child: GameLog(logs: state.logs),
              ),

              // 6. DIALOGLAR
              if (state.showQuestionDialog && state.currentQuestion != null)
                _animateDialog(
                  QuestionDialog(question: state.currentQuestion!),
                ),
              if (state.showPurchaseDialog && state.currentTile != null)
                _animateDialog(
                  CopyrightPurchaseDialog(tile: state.currentTile!),
                ),
              if (state.showCardDialog && state.currentCard != null)
                _animateDialog(CardDialog(card: state.currentCard!)),
            ],
          ),
        ),
      ),
    );
  }

  // --- MATEMATİK MOTORU (Grid Engine) ---

  // Kutunun konumunu ve yönünü hesaplayan tek gerçek kaynak
  _TileLayout _calculateTileLayout(int index, double S, double U) {
    // Boyutlar
    final double corner = 1.5 * U;
    final double normal = 1.0 * U;
    final double depth = 1.5 * U; // Kenar derinliği (köşe ile aynı olmalı)

    // 0: Sol Alt Köşe
    if (index == 0) {
      return _TileLayout(Rect.fromLTWH(0, S - corner, corner, corner), 0);
    }
    // 1-9: Sol Kenar (Aşağıdan Yukarı) -> Yönü: Sağ (1 turn)
    else if (index < 10) {
      // Sol kenar: X=0. Y hesapla.
      // 1. kare en altta (corner'ın üstünde).
      // BottomOffset = corner + (index-1)*normal.
      // Top = S - BottomOffset - normal.
      double top = S - corner - (index - 1 + 1) * normal;
      // Rect: width=depth(1.5), height=normal(1)
      return _TileLayout(Rect.fromLTWH(0, top, depth, normal), 1);
    }
    // 10: Sol Üst Köşe
    else if (index == 10) {
      return _TileLayout(
        Rect.fromLTWH(0, 0, corner, corner),
        1,
      ); // 90 derece dönük de olabilir, köşe olduğu için fark etmez ama simetri için 1 iyi.
    }
    // 11-19: Üst Kenar (Soldan Sağa) -> Yönü: Aşağı (2 turns)
    else if (index < 20) {
      double left = corner + (index - 11) * normal;
      // Rect: width=normal, height=depth
      return _TileLayout(Rect.fromLTWH(left, 0, normal, depth), 2);
    }
    // 20: Sağ Üst Köşe
    else if (index == 20) {
      return _TileLayout(Rect.fromLTWH(S - corner, 0, corner, corner), 2);
    }
    // 21-29: Sağ Kenar (Yukarıdan Aşağı) -> Yönü: Sol (3 turns)
    else if (index < 30) {
      double top = corner + (index - 21) * normal;
      // Rect: Left = S-depth.
      return _TileLayout(Rect.fromLTWH(S - depth, top, depth, normal), 3);
    }
    // 30: Sağ Alt Köşe
    else if (index == 30) {
      return _TileLayout(
        Rect.fromLTWH(S - corner, S - corner, corner, corner),
        3,
      );
    }
    // 31-39: Alt Kenar (Sağdan Sola) -> Yönü: Yukarı (0 turns)
    else {
      // 31 en sağda (köşenin yanında).
      // RightOffset = corner + (index-31)*normal.
      // Left = S - RightOffset - normal.
      double left = S - corner - (index - 31 + 1) * normal;
      return _TileLayout(Rect.fromLTWH(left, S - depth, normal, depth), 0);
    }
  }

  List<Widget> _buildGroupedPlayers(List<Player> players, double S, double U) {
    Map<int, List<Player>> groups = {};
    for (var p in players) groups.putIfAbsent(p.position, () => []).add(p);

    List<Widget> widgets = [];
    groups.forEach((pos, group) {
      final layout = _calculateTileLayout(pos, S, U);
      final center = layout.rect.center;

      // Piyonları kutunun ortasına diziyoruz
      widgets.add(
        AnimatedPositioned(
          duration: 600.ms,
          curve: Curves.easeInOutCubic,
          left:
              center.dx -
              (U / 1.5), // Centerlamak için ofset (Piyon alanı boyutu/2)
          top: center.dy - (U / 1.5),
          child: Container(
            width: U * 1.5, // Piyon alanı biraz geniş olsun (Wrap için)
            height: U * 1.5,
            alignment: Alignment.center,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 2,
              runSpacing: 2,
              children: group.map((p) => _buildPawn(p, U * 0.4)).toList(),
            ),
          ),
        ),
      );
    });
    return widgets;
  }

  Widget _buildPawn(Player p, double size) {
    bool isActive = ref.read(gameProvider).currentPlayer.id == p.id;
    Widget pawn = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black54)],
      ),
      child: Icon(
        IconData(0xe000 + p.iconIndex, fontFamily: 'MaterialIcons'),
        size: size * 0.7,
        color: Colors.white,
      ),
    );
    if (isActive) {
      return pawn
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: Offset(1, 1), end: Offset(1.3, 1.3), duration: 700.ms)
          .boxShadow(
            color: Colors.white,
            begin: BoxShadow(blurRadius: 0),
            end: BoxShadow(blurRadius: 15),
          );
    }
    return pawn;
  }

  Widget _buildHUD(dynamic state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "EDEBIİNA",
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 5)],
          ),
        ),
        SizedBox(height: 15),
        DiceRoller(),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            state.lastAction,
            style: TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _animateDialog(Widget child) => Container(
    color: Colors.black54,
    child: Center(
      child: child
          .animate()
          .scale(duration: 300.ms, curve: Curves.easeOutBack)
          .fadeIn(),
    ),
  );
}

class _TileLayout {
  final Rect rect;
  final int quarterTurns;
  _TileLayout(this.rect, this.quarterTurns);
}
