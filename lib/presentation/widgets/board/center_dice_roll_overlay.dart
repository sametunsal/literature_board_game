import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/game_constants.dart';
import '../../../providers/game_notifier.dart';
import 'dice_roll_three_view.dart';

class CenterDiceRollOverlay extends StatefulWidget {
  final GameState state;
  final double minSide;

  const CenterDiceRollOverlay({
    super.key,
    required this.state,
    required this.minSide,
  });

  @override
  State<CenterDiceRollOverlay> createState() => _CenterDiceRollOverlayState();
}

class _CenterDiceRollOverlayState extends State<CenterDiceRollOverlay> {
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    // Wait for dice animation + settle hold before showing result
    Future.delayed(
      Duration(
        milliseconds:
            GameConstants.diceRollMotionDelayMs +
            GameConstants.diceSettleHoldMs,
      ),
      () {
        if (mounted) setState(() => _showResult = true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.state.currentPlayer.name;
    final d1 = widget.state.dice1.clamp(1, 6);
    final d2 = widget.state.dice2.clamp(1, 6);
    final total = d1 + d2;
    final minSide = widget.minSide;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        final pad = 6.0;
        final innerW = math.max(0.0, maxW - pad * 2);
        final innerH = math.max(0.0, maxH - pad * 2);

        if (!_showResult) {
          return Padding(
            padding: EdgeInsets.all(pad),
            child: ClipRect(
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: math.max(innerW, 1),
                    maxHeight: math.max(innerH, 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DiceRollThreeView(
                        width: math.min(innerW * 0.94, 230),
                        height: math.min(innerH * 0.6, 118),
                        dice1: d1,
                        dice2: d2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Sonuç paneli — kompakt
        return Padding(
          padding: EdgeInsets.all(pad),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: math.min(minSide * 0.035, 16),
                  vertical: math.min(minSide * 0.015, 8),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.amber.shade600,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: math.max(9, minSide * 0.025),
                        fontWeight: FontWeight.w600,
                        color: Colors.brown.shade700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '$d1 + $d2 = $total',
                      style: GoogleFonts.poppins(
                        fontSize: math.max(14, minSide * 0.04),
                        fontWeight: FontWeight.w800,
                        color: Colors.brown.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
