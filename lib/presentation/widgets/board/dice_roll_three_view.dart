import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/game_constants.dart';

/// Isometric 3D-like dice animation using Flutter transforms.
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
  late final AnimationController _controller;
  final _rng = math.Random();
  int _d1 = 1;
  int _d2 = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: GameConstants.diceRollMotionDelayMs),
    )..addListener(_tick);
    _controller.forward();
  }

  void _tick() {
    final t = _controller.value;
    setState(() {
      if (t < 0.88) {
        _d1 = _rng.nextInt(6) + 1;
        _d2 = _rng.nextInt(6) + 1;
      } else {
        _d1 = widget.dice1.clamp(1, 6);
        _d2 = widget.dice2.clamp(1, 6);
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_tick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = math.max(widget.width, 1.0);
    final h = math.max(widget.height, 1.0);
    final dieSize = math.min((w * 0.32), h * 0.64).clamp(28.0, 88.0);
    final gap = math.max(10.0, dieSize * 0.26);
    final t = _controller.value;

    final spinA = (1 - t) * math.pi * 3.2;
    final spinB = (1 - t) * math.pi * 2.9;
    final bob = math.sin(t * math.pi * 5) * (1 - t) * 9;

    return SizedBox(
      width: w,
      height: h,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IsometricDie(
              value: _d1,
              size: dieSize,
              rotateY: spinA,
              rotateX: spinA * 0.55,
              bobY: bob,
            ),
            SizedBox(width: gap),
            _IsometricDie(
              value: _d2,
              size: dieSize,
              rotateY: -spinB,
              rotateX: spinB * 0.52,
              bobY: -bob * 0.6,
            ),
          ],
        ),
      ),
    );
  }
}

class _IsometricDie extends StatelessWidget {
  const _IsometricDie({
    required this.value,
    required this.size,
    required this.rotateY,
    required this.rotateX,
    required this.bobY,
  });

  final int value;
  final double size;
  final double rotateY;
  final double rotateX;
  final double bobY;

  @override
  Widget build(BuildContext context) {
    final depth = size * 0.23;
    final radius = Radius.circular(size * 0.12);

    return Transform.translate(
      offset: Offset(0, bobY),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0022)
          ..rotateX(0.65 + rotateX)
          ..rotateZ(-0.42)
          ..rotateY(rotateY),
        child: SizedBox(
          width: size + depth,
          height: size + depth,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: depth * 0.55,
                top: depth * 0.55,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8D0BC),
                    borderRadius: BorderRadius.all(radius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: depth * 0.18,
                top: depth * 0.24,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFCF2), Color(0xFFF0E9D7)],
                    ),
                    borderRadius: BorderRadius.all(radius),
                    border: Border.all(
                      color: const Color(0xFFB5A985),
                      width: 1.25,
                    ),
                  ),
                  child: CustomPaint(painter: _PipsPainter(value)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PipsPainter extends CustomPainter {
  _PipsPainter(this.value);
  final int value;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide * 0.08;
    final pip = Paint()..color = const Color(0xFF2F2819);
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);

    void dot(double x, double y) {
      final c = Offset(x * size.width, y * size.height);
      canvas.drawCircle(c + const Offset(0.35, 0.55), r * 0.9, shadow);
      canvas.drawCircle(c, r, pip);
    }

    const lo = 0.26;
    const mid = 0.50;
    const hi = 0.74;
    switch (value.clamp(1, 6)) {
      case 1:
        dot(mid, mid);
      case 2:
        dot(lo, lo);
        dot(hi, hi);
      case 3:
        dot(lo, lo);
        dot(mid, mid);
        dot(hi, hi);
      case 4:
        dot(lo, lo);
        dot(hi, lo);
        dot(lo, hi);
        dot(hi, hi);
      case 5:
        dot(lo, lo);
        dot(hi, lo);
        dot(mid, mid);
        dot(lo, hi);
        dot(hi, hi);
      default:
        dot(lo, lo);
        dot(hi, lo);
        dot(lo, mid);
        dot(hi, mid);
        dot(lo, hi);
        dot(hi, hi);
    }
  }

  @override
  bool shouldRepaint(covariant _PipsPainter oldDelegate) =>
      oldDelegate.value != value;
}
