import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/game_constants.dart';

/// Gerçek izometrik 3D zar animasyonu - 6 yüzlü küp ile tam 3D dönüş.
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
    with TickerProviderStateMixin {
  late final AnimationController _spinController;
  late final AnimationController _bounceController;
  final _rng = math.Random();

  // Anlık görünen değerler (animasyon sırasında rastgele)
  int _displayVal1 = 1;
  int _displayVal2 = 1;

  // Dönüş açıları
  double _rotX1 = 0, _rotY1 = 0, _rotZ1 = 0;
  double _rotX2 = 0, _rotY2 = 0, _rotZ2 = 0;

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: GameConstants.diceRollMotionDelayMs),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _spinController.addListener(_onSpinTick);
    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _bounceController.forward();
      }
    });

    _bounceController.addListener(() => setState(() {}));

    _spinController.forward();
  }

  void _onSpinTick() {
    final t = _spinController.value;
    final easeT = Curves.easeOutCubic.transform(t);

    setState(() {
      if (t < 0.85) {
        // Hızlı dönüş fazı - rastgele değerler
        _displayVal1 = _rng.nextInt(6) + 1;
        _displayVal2 = _rng.nextInt(6) + 1;

        // Dinamik dönüş (yavaşlayarak)
        final spinSpeed = (1 - easeT) * 12;
        _rotX1 += spinSpeed * 0.08;
        _rotY1 += spinSpeed * 0.12;
        _rotZ1 += spinSpeed * 0.03;

        _rotX2 += spinSpeed * 0.09;
        _rotY2 -= spinSpeed * 0.11;
        _rotZ2 -= spinSpeed * 0.04;
      } else {
        // Yavaşlama fazı - final değerlere yaklaşma
        _displayVal1 = widget.dice1.clamp(1, 6);
        _displayVal2 = widget.dice2.clamp(1, 6);

        // Final pozisyona yumuşak geçiş
        final settleT = ((t - 0.85) / 0.15);
        final targetRot1 = _getTargetRotation(widget.dice1);
        final targetRot2 = _getTargetRotation(widget.dice2);

        _rotX1 = _lerpAngle(_rotX1, targetRot1.x, settleT * 0.3);
        _rotY1 = _lerpAngle(_rotY1, targetRot1.y, settleT * 0.3);
        _rotZ1 = _lerpAngle(_rotZ1, 0, settleT * 0.3);

        _rotX2 = _lerpAngle(_rotX2, targetRot2.x, settleT * 0.3);
        _rotY2 = _lerpAngle(_rotY2, targetRot2.y, settleT * 0.3);
        _rotZ2 = _lerpAngle(_rotZ2, 0, settleT * 0.3);
      }
    });
  }

  /// Değere göre zarın durması gereken açı (üst yüzde o değer görünecek şekilde)
  _RotationAngles _getTargetRotation(int value) {
    // İzometrik görünüm: X=-25°, Y=45° temel açı
    const baseX = -0.45; // ~25 derece
    const baseY = 0.78; // ~45 derece

    switch (value) {
      case 1:
        return _RotationAngles(baseX, baseY); // Üst = 1
      case 2:
        return _RotationAngles(baseX + math.pi / 2, baseY); // Ön = 2
      case 3:
        return _RotationAngles(baseX, baseY - math.pi / 2); // Sağ = 3
      case 4:
        return _RotationAngles(baseX, baseY + math.pi / 2); // Sol = 4
      case 5:
        return _RotationAngles(baseX - math.pi / 2, baseY); // Arka = 5
      case 6:
        return _RotationAngles(baseX + math.pi, baseY); // Alt = 6
      default:
        return _RotationAngles(baseX, baseY);
    }
  }

  double _lerpAngle(double from, double to, double t) {
    return from + (to - from) * t;
  }

  @override
  void dispose() {
    _spinController.removeListener(_onSpinTick);
    _spinController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = math.max(widget.width, 1.0);
    final h = math.max(widget.height, 1.0);
    final dieSize = math.min(w * 0.30, h * 0.58).clamp(32.0, 72.0);
    final gap = dieSize * 0.4;

    // Bounce efekti
    final bounceT = _bounceController.value;
    final bounceScale = 1.0 + math.sin(bounceT * math.pi) * 0.08;
    final bounceY = math.sin(bounceT * math.pi * 2) * (1 - bounceT) * 4;

    return SizedBox(
      width: w,
      height: h,
      child: Center(
        child: Transform.translate(
          offset: Offset(0, bounceY),
          child: Transform.scale(
            scale: bounceScale,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dice3D(
                  size: dieSize,
                  topValue: _displayVal1,
                  rotationX: _rotX1,
                  rotationY: _rotY1,
                  rotationZ: _rotZ1,
                ),
                SizedBox(width: gap),
                _Dice3D(
                  size: dieSize,
                  topValue: _displayVal2,
                  rotationX: _rotX2,
                  rotationY: _rotY2,
                  rotationZ: _rotZ2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RotationAngles {
  final double x;
  final double y;
  const _RotationAngles(this.x, this.y);
}

/// Gerçek 6 yüzlü 3D zar - isometric perspektif
class _Dice3D extends StatelessWidget {
  const _Dice3D({
    required this.size,
    required this.topValue,
    required this.rotationX,
    required this.rotationY,
    required this.rotationZ,
  });

  final double size;
  final int topValue;
  final double rotationX;
  final double rotationY;
  final double rotationZ;

  @override
  Widget build(BuildContext context) {
    final halfSize = size / 2;

    return SizedBox(
      width: size * 1.6,
      height: size * 1.6,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspektif
          ..rotateX(rotationX)
          ..rotateY(rotationY)
          ..rotateZ(rotationZ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ön yüz (Z+)
            _CubeFace(
              value: _getFaceValue(topValue, _Face.front),
              size: size,
              translateZ: halfSize,
              baseColor: const Color(0xFFFFFDF5),
            ),
            // Arka yüz (Z-)
            _CubeFace(
              value: _getFaceValue(topValue, _Face.back),
              size: size,
              translateZ: -halfSize,
              rotateY: math.pi,
              baseColor: const Color(0xFFF8F4E8),
            ),
            // Sağ yüz (X+)
            _CubeFace(
              value: _getFaceValue(topValue, _Face.right),
              size: size,
              translateX: halfSize,
              rotateY: math.pi / 2,
              baseColor: const Color(0xFFF5F1E5),
            ),
            // Sol yüz (X-)
            _CubeFace(
              value: _getFaceValue(topValue, _Face.left),
              size: size,
              translateX: -halfSize,
              rotateY: -math.pi / 2,
              baseColor: const Color(0xFFF0ECE0),
            ),
            // Üst yüz (Y-)
            _CubeFace(
              value: topValue,
              size: size,
              translateY: -halfSize,
              rotateX: -math.pi / 2,
              baseColor: const Color(0xFFFFFEFA),
              isTop: true,
            ),
            // Alt yüz (Y+)
            _CubeFace(
              value: _getFaceValue(topValue, _Face.bottom),
              size: size,
              translateY: halfSize,
              rotateX: math.pi / 2,
              baseColor: const Color(0xFFEAE6DA),
            ),
          ],
        ),
      ),
    );
  }

  /// Üst yüze göre diğer yüzlerin değerlerini hesapla
  /// Standart zar: karşılıklı yüzlerin toplamı = 7
  int _getFaceValue(int topValue, _Face face) {
    // Standart zar düzeni (top=1 iken):
    // front=2, back=5, right=3, left=4, bottom=6
    final faceMap = <int, Map<_Face, int>>{
      1: {
        _Face.front: 2,
        _Face.back: 5,
        _Face.right: 3,
        _Face.left: 4,
        _Face.bottom: 6
      },
      2: {
        _Face.front: 1,
        _Face.back: 6,
        _Face.right: 3,
        _Face.left: 4,
        _Face.bottom: 5
      },
      3: {
        _Face.front: 2,
        _Face.back: 5,
        _Face.right: 6,
        _Face.left: 1,
        _Face.bottom: 4
      },
      4: {
        _Face.front: 2,
        _Face.back: 5,
        _Face.right: 1,
        _Face.left: 6,
        _Face.bottom: 3
      },
      5: {
        _Face.front: 6,
        _Face.back: 1,
        _Face.right: 3,
        _Face.left: 4,
        _Face.bottom: 2
      },
      6: {
        _Face.front: 5,
        _Face.back: 2,
        _Face.right: 3,
        _Face.left: 4,
        _Face.bottom: 1
      },
    };

    return faceMap[topValue]?[face] ?? 1;
  }
}

enum _Face { front, back, right, left, bottom }

/// Küp yüzü - doğru transform sırası ile (rotation -> translation)
class _CubeFace extends StatelessWidget {
  const _CubeFace({
    required this.value,
    required this.size,
    required this.baseColor,
    this.translateX = 0,
    this.translateY = 0,
    this.translateZ = 0,
    this.rotateX = 0,
    this.rotateY = 0,
    this.isTop = false,
  });

  final int value;
  final double size;
  final Color baseColor;
  final double translateX;
  final double translateY;
  final double translateZ;
  final double rotateX;
  final double rotateY;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    // İç içe Transform ile doğru sıra: önce rotation, sonra translation
    Widget face = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor,
            Color.lerp(baseColor, const Color(0xFFD4C9A8), 0.3)!,
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.12),
        border: Border.all(
          color: const Color(0xFFAA9F7F),
          width: 1.0,
        ),
        boxShadow: isTop
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        painter: _DiceFacePainter(value: value.clamp(1, 6)),
      ),
    );

    // Önce rotation uygula
    if (rotateX != 0 || rotateY != 0) {
      face = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateX(rotateX)
          ..rotateY(rotateY),
        child: face,
      );
    }

    // Sonra translation uygula
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.translationValues(translateX, translateY, translateZ),
      child: face,
    );
  }
}

/// Zar yüzü pip painter - klasik nokta düzeni
class _DiceFacePainter extends CustomPainter {
  const _DiceFacePainter({required this.value});
  final int value;

  @override
  void paint(Canvas canvas, Size size) {
    final pipRadius = size.shortestSide * 0.085;
    final pipPaint = Paint()..color = const Color(0xFF1A1408);
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

    void drawPip(double relX, double relY) {
      final center = Offset(relX * size.width, relY * size.height);
      // Gölge
      canvas.drawCircle(center + const Offset(0.5, 0.8), pipRadius * 0.9, shadowPaint);
      // Pip
      canvas.drawCircle(center, pipRadius, pipPaint);
      // Işık yansıması
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.25);
      canvas.drawCircle(
        center - Offset(pipRadius * 0.25, pipRadius * 0.25),
        pipRadius * 0.35,
        highlightPaint,
      );
    }

    const lo = 0.25;
    const mid = 0.50;
    const hi = 0.75;

    switch (value) {
      case 1:
        drawPip(mid, mid);
      case 2:
        drawPip(lo, lo);
        drawPip(hi, hi);
      case 3:
        drawPip(lo, lo);
        drawPip(mid, mid);
        drawPip(hi, hi);
      case 4:
        drawPip(lo, lo);
        drawPip(hi, lo);
        drawPip(lo, hi);
        drawPip(hi, hi);
      case 5:
        drawPip(lo, lo);
        drawPip(hi, lo);
        drawPip(mid, mid);
        drawPip(lo, hi);
        drawPip(hi, hi);
      case 6:
        drawPip(lo, lo);
        drawPip(hi, lo);
        drawPip(lo, mid);
        drawPip(hi, mid);
        drawPip(lo, hi);
        drawPip(hi, hi);
    }
  }

  @override
  bool shouldRepaint(covariant _DiceFacePainter old) => old.value != value;
}
