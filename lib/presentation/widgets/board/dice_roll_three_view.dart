import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/game_constants.dart';

/// Stabil izometrik 3D zar animasyonu - CustomPainter ile çizim.
/// Yüzler kaybolmaz, içi görünmez.
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

  int _displayVal1 = 1;
  int _displayVal2 = 1;
  double _wobble1 = 0;
  double _wobble2 = 0;

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
      if (t < 0.80) {
        // Dönüş fazı - rastgele değerler göster
        // Her 80ms'de bir değer değiştir (daha yavaş)
        if ((_controller.lastElapsedDuration?.inMilliseconds ?? 0) % 80 < 20) {
          _displayVal1 = _rng.nextInt(6) + 1;
          _displayVal2 = _rng.nextInt(6) + 1;
        }
        // Hafif sallanma efekti
        _wobble1 = math.sin(t * math.pi * 8) * (1 - t) * 0.15;
        _wobble2 = math.sin(t * math.pi * 7 + 1) * (1 - t) * 0.12;
      } else {
        // Yerleşme fazı - final değerlere geç
        _displayVal1 = widget.dice1.clamp(1, 6);
        _displayVal2 = widget.dice2.clamp(1, 6);
        // Sallanma azalsın
        final settleT = (t - 0.80) / 0.20;
        _wobble1 = math.sin(t * math.pi * 8) * (1 - settleT) * 0.08;
        _wobble2 = math.sin(t * math.pi * 7 + 1) * (1 - settleT) * 0.06;
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
    final dieSize = math.min(w * 0.20, h * 0.38).clamp(28.0, 52.0);
    final gap = dieSize * 0.5;

    return SizedBox(
      width: w,
      height: h,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IsometricDie(
              value: _displayVal1,
              size: dieSize,
              wobble: _wobble1,
            ),
            SizedBox(width: gap),
            _IsometricDie(
              value: _displayVal2,
              size: dieSize,
              wobble: _wobble2,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tek bir isometric zar - CustomPainter ile çizilir
class _IsometricDie extends StatelessWidget {
  const _IsometricDie({
    required this.value,
    required this.size,
    required this.wobble,
  });

  final int value;
  final double size;
  final double wobble;

  @override
  Widget build(BuildContext context) {
    // Toplam boyut: küp + perspektif için ekstra alan
    final totalSize = size * 1.4;

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: CustomPaint(
        size: Size(totalSize, totalSize),
        painter: _IsometricDiePainter(
          value: value.clamp(1, 6),
          wobble: wobble,
        ),
      ),
    );
  }
}

/// Isometric küp çizen painter - 3 yüz her zaman görünür
class _IsometricDiePainter extends CustomPainter {
  _IsometricDiePainter({
    required this.value,
    required this.wobble,
  });

  final int value;
  final double wobble;

  // Renkler
  static const _topColor = Color(0xFFFFFDF8);
  static const _leftColor = Color(0xFFE8E4D8);
  static const _rightColor = Color(0xFFD4D0C4);
  static const _borderColor = Color(0xFF8B8578);
  static const _pipColor = Color(0xFF1A1408);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final cubeSize = size.width * 0.6;

    // Isometric açılar (30 derece)
    const angle = math.pi / 6; // 30°

    // Küp köşe noktaları hesapla
    final halfW = cubeSize / 2;
    final halfH = cubeSize * 0.5; // Yükseklik
    final depth = cubeSize * 0.35; // Derinlik

    // Wobble efekti - hafif offset
    final wobbleX = wobble * cubeSize * 0.3;
    final wobbleY = wobble * cubeSize * 0.15;

    // Merkez noktası (küpün ön köşesi)
    final frontX = center.dx + wobbleX;
    final frontY = center.dy + halfH * 0.3 + wobbleY;

    // Üst yüz köşeleri
    final topFront = Offset(frontX, frontY - halfH);
    final topLeft = Offset(frontX - halfW * math.cos(angle), frontY - halfH - halfW * math.sin(angle));
    final topRight = Offset(frontX + halfW * math.cos(angle), frontY - halfH - halfW * math.sin(angle));
    final topBack = Offset(frontX, frontY - halfH - halfW * math.sin(angle) * 2);

    // Alt ön köşe
    final bottomFront = Offset(frontX, frontY + depth);

    // Sol ve sağ alt köşeler
    final bottomLeft = Offset(topLeft.dx, topLeft.dy + depth + halfH);
    final bottomRight = Offset(topRight.dx, topRight.dy + depth + halfH);

    // Gölge
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    final shadowPath = Path()
      ..moveTo(bottomFront.dx + 3, bottomFront.dy + 5)
      ..lineTo(bottomLeft.dx + 3, bottomLeft.dy + 5)
      ..lineTo(topLeft.dx + 3, topLeft.dy + depth + 5)
      ..lineTo(topBack.dx + 3, topBack.dy + depth + 5)
      ..lineTo(topRight.dx + 3, topRight.dy + depth + 5)
      ..lineTo(bottomRight.dx + 3, bottomRight.dy + 5)
      ..close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Sol yüz (karanlık)
    final leftPath = Path()
      ..moveTo(topFront.dx, topFront.dy)
      ..lineTo(topLeft.dx, topLeft.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(bottomFront.dx, bottomFront.dy)
      ..close();
    
    canvas.drawPath(leftPath, Paint()..color = _leftColor);
    canvas.drawPath(leftPath, Paint()..color = _borderColor..style = PaintingStyle.stroke..strokeWidth = 1);

    // Sağ yüz (orta)
    final rightPath = Path()
      ..moveTo(topFront.dx, topFront.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomFront.dx, bottomFront.dy)
      ..close();
    
    canvas.drawPath(rightPath, Paint()..color = _rightColor);
    canvas.drawPath(rightPath, Paint()..color = _borderColor..style = PaintingStyle.stroke..strokeWidth = 1);

    // Üst yüz (en aydınlık) - pip'ler burada
    final topPath = Path()
      ..moveTo(topFront.dx, topFront.dy)
      ..lineTo(topLeft.dx, topLeft.dy)
      ..lineTo(topBack.dx, topBack.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..close();
    
    canvas.drawPath(topPath, Paint()..color = _topColor);
    canvas.drawPath(topPath, Paint()..color = _borderColor..style = PaintingStyle.stroke..strokeWidth = 1);

    // Üst yüze pip'leri çiz
    _drawPips(canvas, topFront, topLeft, topRight, topBack, value);
  }

  void _drawPips(Canvas canvas, Offset front, Offset left, Offset right, Offset back, int val) {
    final pipPaint = Paint()..color = _pipColor;
    final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.3);

    // Üst yüzün merkezi ve boyutları
    final centerX = (front.dx + left.dx + right.dx + back.dx) / 4;
    final centerY = (front.dy + left.dy + right.dy + back.dy) / 4;
    
    // Yüz genişliği ve yüksekliği
    final faceW = (right.dx - left.dx) * 0.7;
    final faceH = (front.dy - back.dy) * 0.7;
    
    final pipR = math.min(faceW, faceH) * 0.12;

    void drawPip(double relX, double relY) {
      // Isometric dönüşüm
      final px = centerX + (relX - 0.5) * faceW + (relY - 0.5) * faceW * 0.15;
      final py = centerY + (relY - 0.5) * faceH * 0.5 + (relX - 0.5) * faceH * 0.15;
      
      // Gölge
      canvas.drawCircle(Offset(px + 0.5, py + 0.5), pipR * 0.9, 
        Paint()..color = Colors.black.withValues(alpha: 0.15));
      // Pip
      canvas.drawCircle(Offset(px, py), pipR, pipPaint);
      // Highlight
      canvas.drawCircle(Offset(px - pipR * 0.2, py - pipR * 0.2), pipR * 0.3, highlightPaint);
    }

    const lo = 0.22;
    const mid = 0.50;
    const hi = 0.78;

    switch (val) {
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
  bool shouldRepaint(covariant _IsometricDiePainter old) =>
      old.value != value || old.wobble != wobble;
}
