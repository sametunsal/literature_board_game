import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/board_config.dart';
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

    // EKRAN VE TAHTA BOYUTU
    final double screenShortest = MediaQuery.of(context).size.shortestSide;
    final double boardSize = screenShortest * 0.95; // Ekranın %95'i

    // TEMEL BİRİM (Unit)
    // Standart Monopoly: 2 Köşe + 9 Kare = 11 birim gibi düşünülür ama
    // Köşeler karelerden büyüktür.
    // Bizim Formül: 12 Birim = 1.5 (Köşe) + 9 (Kare) + 1.5 (Köşe)
    final double u = boardSize / 12.0;

    final double normalSize = u; // Normal Karenin dar kenarı
    final double cornerSize =
        u * 1.5; // Köşenin kenarı (ve normal karenin uzun kenarı)

    return Scaffold(
      backgroundColor: GameTheme.backgroundTable,
      body: Center(
        child: Container(
          width: boardSize,
          height: boardSize,
          decoration: GameTheme.boardDecoration,
          child: Stack(
            // Stack içinde koordinat sistemi (0,0) Sol Üst'tür.
            children: [
              // 1. ORTA ALAN (Background)
              Positioned(
                top: cornerSize,
                left: cornerSize,
                right: cornerSize,
                bottom: cornerSize,
                child: Container(
                  decoration: GameTheme.centerAreaDecoration,
                  child: Stack(
                    children: [
                      Center(
                        child: Opacity(
                          opacity: 0.1,
                          child: Icon(
                            Icons.menu_book,
                            size: boardSize * 0.3,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Center(child: _buildHUD(state)),
                    ],
                  ),
                ),
              ),

              // 2. KUTUCUKLARIN YERLEŞTİRİLMESİ
              // List.generate yerine manuel döngülerle kenarları çizmek daha kontrollü.

              // --- ALT KENAR (Bottom) ---
              // Index: 0 (Sol Alt) -> 1..9 (Alt Kenar ? Hayır, senaryoya göre değişir)
              // BİZİM YAPIMIZ (Varsayım):
              // 0: Sol Alt Köşe.
              // 1..9: SOL KENAR (Yukarı doğru).
              // 10: Sol Üst Köşe.
              // 11..19: ÜST KENAR (Sağa doğru).
              // 20: Sağ Üst Köşe.
              // 21..29: SAĞ KENAR (Aşağı doğru).
              // 30: Sağ Alt Köşe.
              // 31..39: ALT KENAR (Sola doğru).

              // KÖŞELER
              _buildTileAbsolute(
                0,
                0,
                boardSize - cornerSize,
                cornerSize,
                cornerSize,
                0,
              ), // SOL ALT
              _buildTileAbsolute(
                10,
                0,
                0,
                cornerSize,
                cornerSize,
                1,
              ), // SOL ÜST (90 derece dönük başlık için)
              _buildTileAbsolute(
                20,
                boardSize - cornerSize,
                0,
                cornerSize,
                cornerSize,
                2,
              ), // SAĞ ÜST
              _buildTileAbsolute(
                30,
                boardSize - cornerSize,
                boardSize - cornerSize,
                cornerSize,
                cornerSize,
                3,
              ), // SAĞ ALT
              // SOL KENAR (1..9) -> Yukarı Çıkıyor
              ...List.generate(9, (i) {
                // X: 0
                // Y: Alttan yukarı doğru. İlk eleman (1) 0. köşe'nin üstünde.
                // Y = (BoardHeight - Corner) - (i+1)*Normal
                double top = boardSize - cornerSize - ((i + 1) * normalSize);
                // Genişlik: CornerSize (Çünkü yatay duruyor), Yükseklik: NormalSize
                return _buildTileAbsolute(
                  1 + i,
                  0,
                  top,
                  cornerSize,
                  normalSize,
                  1,
                ); // 1 = 90 Derece
              }),

              // ÜST KENAR (11..19) -> Sağa Gidiyor
              ...List.generate(9, (i) {
                // Y: 0
                // X: Soldan sağa.
                double left = cornerSize + (i * normalSize);
                return _buildTileAbsolute(
                  11 + i,
                  left,
                  0,
                  normalSize,
                  cornerSize,
                  2,
                ); // 2 = 180 Derece
              }),

              // SAĞ KENAR (21..29) -> Aşağı İniyor
              ...List.generate(9, (i) {
                // X: En sağ (Board - Corner)
                double left = boardSize - cornerSize;
                double top = cornerSize + (i * normalSize);
                return _buildTileAbsolute(
                  21 + i,
                  left,
                  top,
                  cornerSize,
                  normalSize,
                  3,
                ); // 3 = 270 Derece
              }),

              // ALT KENAR (31..39) -> Sola Gidiyor
              ...List.generate(9, (i) {
                // Y: En alt (Board - Corner)
                double top = boardSize - cornerSize;
                // X: Sağdan sola.
                double left = boardSize - cornerSize - ((i + 1) * normalSize);
                return _buildTileAbsolute(
                  31 + i,
                  left,
                  top,
                  normalSize,
                  cornerSize,
                  0,
                ); // 0 = 0 Derece
              }),

              // 3. PİYONLAR
              ..._buildPlayers(
                state.players,
                boardSize,
                cornerSize,
                normalSize,
              ),

              // 4. EFEKTLER & DIALOGLAR
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                ),
              ),
              Positioned(
                bottom: cornerSize + 10,
                right: cornerSize + 10,
                child: GameLog(logs: state.logs),
              ),

              if (state.showQuestionDialog && state.currentQuestion != null)
                _dialogOverlay(
                  QuestionDialog(question: state.currentQuestion!),
                ),
              if (state.showPurchaseDialog && state.currentTile != null)
                _dialogOverlay(
                  CopyrightPurchaseDialog(tile: state.currentTile!),
                ),
              if (state.showCardDialog && state.currentCard != null)
                _dialogOverlay(CardDialog(card: state.currentCard!)),
            ],
          ),
        ),
      ),
    );
  }

  // YARDIMCI: Kutucuk Çizici
  Widget _buildTileAbsolute(
    int id,
    double left,
    double top,
    double width,
    double height,
    int rotation,
  ) {
    // Rotation: 0=0, 1=90, 2=180, 3=270
    // RotatedBox, çocuğu çevirir.
    // Eğer dikey bir kutuyu (W:Normal, H:Corner) 90 derece çevirirsek (W:Corner, H:Normal) olur.
    // Positioned'a verdiğimiz width/height, ÇEVRİLMİŞ HALİ olmalıdır.

    // EnhancedTileWidget her zaman "Dikey" (Upright) içerik bekler.
    // Biz onu RotatedBox ile çeviririz.

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: RotatedBox(
        quarterTurns: rotation,
        child: EnhancedTileWidget(
          tile: BoardConfig.getTile(id),
          // Widget'a, onun "kendi iç dünyasındaki" boyutları gönderiyoruz.
          // Eğer 90/270 derece döndüyse, dışarıdaki width aslında içerideki height'tır.
          width: (rotation % 2 == 0) ? width : height,
          height: (rotation % 2 == 0) ? height : width,
        ),
      ),
    );
  }

  // YARDIMCI: Piyon Konumlandırıcı (Grid Merkezine Oturtma)
  List<Widget> _buildPlayers(
    List<Player> players,
    double boardSize,
    double C,
    double N,
  ) {
    Map<int, List<Player>> groups = {};
    for (var p in players) groups.putIfAbsent(p.position, () => []).add(p);

    List<Widget> widgets = [];
    groups.forEach((pos, group) {
      Offset center = _getTileCenter(pos, boardSize, C, N);

      widgets.add(
        AnimatedPositioned(
          duration: 600.ms,
          curve: Curves.easeInOutCubic,
          // Piyon grubunu tam merkeze koymak için: Center - (Size/2)
          left: center.dx - (C / 2),
          top: center.dy - (C / 2),
          child: Container(
            width: C, // Grup alanı köşe kadar geniş olsun
            height: C,
            alignment: Alignment.center,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 2,
              children: group.map((p) => _buildPawn(p, N * 0.4)).toList(),
            ),
          ),
        ),
      );
    });
    return widgets;
  }

  Offset _getTileCenter(int i, double S, double C, double N) {
    // Kutucukların merkez koordinatını döndürür.
    // 0 Sol Alt
    if (i == 0) return Offset(C / 2, S - C / 2);
    // 1-9 Sol Kenar
    if (i < 10) {
      double top = S - C - ((i - 1 + 1) * N);
      // Tile Rect: Left=0, Top=top, W=C, H=N. Center = (C/2, top + N/2)
      return Offset(C / 2, top + N / 2);
    }
    // 10 Sol Üst
    if (i == 10) return Offset(C / 2, C / 2);
    // 11-19 Üst Kenar
    if (i < 20) {
      double left = C + ((i - 11) * N);
      return Offset(left + N / 2, C / 2);
    }
    // 20 Sağ Üst
    if (i == 20) return Offset(S - C / 2, C / 2);
    // 21-29 Sağ Kenar
    if (i < 30) {
      double top = C + ((i - 21) * N);
      return Offset(S - C / 2, top + N / 2);
    }
    // 30 Sağ Alt
    if (i == 30)
      return Offset(S - C / 2, S - C / 2);
    // 31-39 Alt Kenar
    else {
      double left = S - C - ((i - 31 + 1) * N);
      return Offset(left + N / 2, S - C / 2);
    }
  }

  Widget _buildPawn(Player p, double size) {
    bool isActive = ref.read(gameProvider).currentPlayer.id == p.id;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: isActive
            ? [BoxShadow(color: Colors.white, blurRadius: 10)]
            : [BoxShadow(color: Colors.black54, blurRadius: 4)],
      ),
      child: Icon(
        IconData(0xe000 + p.iconIndex, fontFamily: 'MaterialIcons'),
        size: size * 0.7,
        color: Colors.white,
      ),
    );
  }

  Widget _dialogOverlay(Widget child) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: child
            .animate()
            .scale(duration: 300.ms, curve: Curves.easeOutBack)
            .fadeIn(),
      ),
    );
  }

  Widget _buildHUD(dynamic state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "EDEBIİNA",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Georgia',
          ),
        ),
        SizedBox(height: 10),
        DiceRoller(),
        SizedBox(height: 5),
        Text(
          state.lastAction,
          style: TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}
