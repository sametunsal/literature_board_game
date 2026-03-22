import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';

/// İki küp zar — saf Flutter; boyutlar parent içinde tutulur (overflow yok).
class DiceRollThreeView extends StatefulWidget {
  const DiceRollThreeView({
    super.key,
    required this.width,
    required this.height,
    required this.dice1,
    required this.dice2,
  });

  final double width;
  final double height;
  final int dice1;
  final int dice2;

  @override
  State<DiceRollThreeView> createState() => _DiceRollThreeViewState();
}

class _DiceRollThreeViewState extends State<DiceRollThreeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = math.Random();
  int _d1 = 1;
  int _d2 = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: GameConstants.diceRollMotionDelayMs),
    )..addListener(_onTick);
    _controller.forward();
  }

  void _onTick() {
    final t = _controller.value;
    setState(() {
      if (t < 0.88) {
        _d1 = _random.nextInt(6) + 1;
        _d2 = _random.nextInt(6) + 1;
      } else {
        _d1 = widget.dice1.clamp(1, 6);
        _d2 = widget.dice2.clamp(1, 6);
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = math.max(widget.width, 1.0);
    final h = math.max(widget.height, 1.0);
    final gap = math.max(6.0, w * 0.04);
    // Dönüş + gölge için ekstra slot (Monopoly tahta merkezinde sıkışmayı önler)
    const slotPerDie = 1.58;
    var dieSize = math.min(
      (w - gap) / (2 * slotPerDie),
      h * 0.68,
    );
    // Ek güvenlik: hiçbir zaman viewport'un %42'sinden büyük olmasın
    dieSize *= 0.92;
    final spin = _controller.value * math.pi * 5 * (1 - _controller.value);

    return SizedBox(
      width: w,
      height: h,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RotatingDie(
              angle: spin,
              dieSize: dieSize,
              value: _d1,
            ),
            SizedBox(width: gap),
            _RotatingDie(
              angle: -spin * 1.05,
              dieSize: dieSize,
              value: _d2,
            ),
          ],
        ),
      ),
    );
  }
}

class _RotatingDie extends StatelessWidget {
  const _RotatingDie({
    required this.angle,
    required this.dieSize,
    required this.value,
  });

  final double angle;
  final double dieSize;
  final int value;

  @override
  Widget build(BuildContext context) {
    final pad = dieSize * 0.29; // slotPerDie 1.58 ile uyumlu
    return SizedBox(
      width: dieSize + 2 * pad,
      height: dieSize + 2 * pad,
      child: Center(
        child: Transform.rotate(
          angle: angle,
          child: _DiceFace(value: value, size: dieSize),
        ),
      ),
    );
  }
}

class _DiceFace extends StatelessWidget {
  const _DiceFace({required this.value, required this.size});

  final int value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(size * 0.12),
        border: Border.all(color: Colors.black45, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _DicePipsPainter(value.clamp(1, 6)),
      ),
    );
  }
}

class _DicePipsPainter extends CustomPainter {
  _DicePipsPainter(this.value);

  final int value;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide * 0.09;
    final paint = Paint()..color = const Color(0xFF212121);

    void dot(double nx, double ny) {
      canvas.drawCircle(
        Offset(nx * size.width, ny * size.height),
        r,
        paint,
      );
    }

    const lo = 0.24;
    const c = 0.5;
    const hi = 0.76;

    switch (value) {
      case 1:
        dot(c, c);
        break;
      case 2:
        dot(lo, lo);
        dot(hi, hi);
        break;
      case 3:
        dot(lo, lo);
        dot(c, c);
        dot(hi, hi);
        break;
      case 4:
        dot(lo, lo);
        dot(hi, lo);
        dot(lo, hi);
        dot(hi, hi);
        break;
      case 5:
        dot(lo, lo);
        dot(hi, lo);
        dot(c, c);
        dot(lo, hi);
        dot(hi, hi);
        break;
      case 6:
      default:
        dot(lo, lo);
        dot(hi, lo);
        dot(lo, c);
        dot(hi, c);
        dot(lo, hi);
        dot(hi, hi);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _DicePipsPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
