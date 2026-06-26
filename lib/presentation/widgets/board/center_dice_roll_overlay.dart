import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../providers/game_notifier.dart';
import 'dice_roll_three_view.dart';

class CenterDiceRollOverlay extends StatelessWidget {
  final GameState state;
  final double minSide;
  final double visualScale;

  const CenterDiceRollOverlay({
    super.key,
    required this.state,
    required this.minSide,
    this.visualScale = 1,
  });

  @override
  Widget build(BuildContext context) {
    final d1 = state.dice1.clamp(1, 6);
    final d2 = state.dice2.clamp(1, 6);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        final pad = 6.0;
        final innerW = math.max(0.0, maxW - pad * 2);
        final innerH = math.max(0.0, maxH - pad * 2);

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
                      visualScale: visualScale,
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
