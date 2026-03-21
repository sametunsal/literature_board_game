import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../providers/game_notifier.dart';
import 'dice_roll_three_view.dart';

/// Tahta merkezinde (CenterArea), BoardLayout izometrik düzleminde zar atılışı.
/// İki gerçek 3D küp [three_js] ile döner; parent tahta matrisi ayrıca uygulanır.
class CenterDiceRollOverlay extends StatelessWidget {
  final GameState state;
  final double minSide;

  const CenterDiceRollOverlay({
    super.key,
    required this.state,
    required this.minSide,
  });

  @override
  Widget build(BuildContext context) {
    final name = state.currentPlayer.name;
    final d1 = (state.dice1 >= 1 && state.dice1 <= 6) ? state.dice1 : 1;
    final d2 = (state.dice2 >= 1 && state.dice2 <= 6) ? state.dice2 : 1;
    // 3D viewport — biraz daha geniş / yüksek (zarlar daha okunaklı)
    final viewW = math.min(minSide * 0.98, 380.0);
    final viewH = math.min(minSide * 0.52, 210.0);

    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.95,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.12),
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$name atıyor',
                style: GoogleFonts.poppins(
                  fontSize: math.max(11, minSide * 0.038),
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  shadows: [
                    Shadow(
                      color: Colors.white.withValues(alpha: 0.9),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              SizedBox(height: minSide * 0.03),
              DiceRollThreeView(
                width: viewW,
                height: viewH,
                dice1: d1,
                dice2: d2,
              ),
              SizedBox(height: minSide * 0.028),
              Text(
                'Üstteki noktalar sonucu gösterir',
                style: GoogleFonts.poppins(
                  fontSize: math.max(10, minSide * 0.03),
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                  shadows: [
                    Shadow(
                      color: Colors.white.withValues(alpha: 0.85),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
