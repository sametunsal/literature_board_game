import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/game_constants.dart';

/// Gerçekçi 3D zar animasyonu - büyük, kare orantılı, görünür dönüş.
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: GameConstants.diceRollMotionDelayMs),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = math.max(widget.width, 1.0);
    final h = math.max(widget.height, 1.0);
    
    // Daha büyük zarlar - ekranın önemli bir kısmını kaplasın
    final dieSize = math.min(w * 0.28, h * 0.50).clamp(45.0, 80.0);
    final gap = dieSize * 0.4;

    return SizedBox(
      width: w,
      height: h,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            
            // Zıplama efekti - zarlar havadan düşer gibi
            final bounceY = _calculateBounce(t) * dieSize * 0.3;
            
            return Transform.translate(
              offset: Offset(0, bounceY),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AnimatedDie(
                    finalValue: widget.dice1,
                    size: dieSize,
                    progress: t,
                    seed: 1,
                  ),
                  SizedBox(width: gap),
                  _AnimatedDie(
                    finalValue: widget.dice2,
                    size: dieSize,
                    progress: t,
                    seed: 2,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Gerçekçi zıplama - hızlı düşüş, birkaç küçük zıplama
  double _calculateBounce(double t) {
    if (t < 0.3) {
      // İlk düşüş
      return -math.sin(t / 0.3 * math.pi / 2);
    } else if (t < 0.5) {
      // İlk zıplama
      final localT = (t - 0.3) / 0.2;
      return -0.4 * math.sin(localT * math.pi);
    } else if (t < 0.65) {
      // İkinci zıplama (daha küçük)
      final localT = (t - 0.5) / 0.15;
      return -0.15 * math.sin(localT * math.pi);
    } else if (t < 0.75) {
      // Son zıplama (çok küçük)
      final localT = (t - 0.65) / 0.1;
      return -0.05 * math.sin(localT * math.pi);
    }
    return 0;
  }
}

/// Tek bir animasyonlu zar
class _AnimatedDie extends StatelessWidget {
  const _AnimatedDie({
    required this.finalValue,
    required this.size,
    required this.progress,
    required this.seed,
  });

  final int finalValue;
  final double size;
  final double progress;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final rng = math.Random(seed * 1000 + (progress * 50).floor());
    
    // Görüntülenecek değer
    final displayValue = progress < 0.75 
        ? rng.nextInt(6) + 1 
        : finalValue.clamp(1, 6);

    // Dönüş açıları - gerçekçi 3D rotasyon
    // Başlangıçta hızlı dönüş, sonra yavaşlama
    final spinFactor = progress < 0.75 
        ? math.pow(1 - progress / 0.75, 2) // Yavaşlayan dönüş
        : 0.0;
    
    // Toplam dönüş miktarı (birkaç tam tur)
    final totalSpinX = spinFactor * math.pi * 4 * (seed == 1 ? 1 : 1.2);
    final totalSpinY = spinFactor * math.pi * 3 * (seed == 1 ? 1.1 : 0.9);
    
    // Hafif sallanma (yerleştikten sonra)
    final wobble = progress > 0.75 
        ? math.sin((progress - 0.75) / 0.25 * math.pi * 3) * 0.03 * (1 - progress)
        : 0.0;

    return SizedBox(
      width: size * 1.3,
      height: size * 1.3,
      child: CustomPaint(
        size: Size(size * 1.3, size * 1.3),
        painter: _RealisticDiePainter(
          value: displayValue,
          rotationX: totalSpinX + wobble,
          rotationY: totalSpinY,
          cubeSize: size,
        ),
      ),
    );
  }
}

/// Gerçekçi 3D zar çizen painter
class _RealisticDiePainter extends CustomPainter {
  _RealisticDiePainter({
    required this.value,
    required this.rotationX,
    required this.rotationY,
    required this.cubeSize,
  });

  final int value;
  final double rotationX;
  final double rotationY;
  final double cubeSize;

  // Zar renkleri - fildişi/krem tonu
  static const _faceLight = Color(0xFFFFFDF5);
  static const _faceMid = Color(0xFFF5F0E0);
  static const _faceDark = Color(0xFFE8E0D0);
  static const _border = Color(0xFF9A9080);
  static const _pip = Color(0xFF1A1408);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final half = cubeSize / 2;

    // 3D küp köşeleri (birim küp -1 ile 1 arası)
    final vertices = <List<double>>[
      [-1, -1, -1], [1, -1, -1], [1, 1, -1], [-1, 1, -1], // Arka yüz
      [-1, -1, 1], [1, -1, 1], [1, 1, 1], [-1, 1, 1],     // Ön yüz
    ];

    // Rotasyon uygula
    final rotated = vertices.map((v) => _rotate3D(v, rotationX, rotationY)).toList();

    // 2D'ye projeksiyon (isometric-like)
    final projected = rotated.map((v) {
      final scale = 1.0 + v[2] * 0.15; // Hafif perspektif
      return Offset(
        center.dx + v[0] * half * scale,
        center.dy + v[1] * half * scale * 0.85, // Y eksenini biraz sıkıştır
      );
    }).toList();

    // Yüzler (vertex indeksleri)
    final faces = [
      [0, 1, 2, 3], // Arka (Z-)
      [4, 5, 6, 7], // Ön (Z+)
      [0, 1, 5, 4], // Alt (Y-)
      [2, 3, 7, 6], // Üst (Y+)
      [0, 3, 7, 4], // Sol (X-)
      [1, 2, 6, 5], // Sağ (X+)
    ];

    // Her yüzün normal vektörü ve derinliği
    final faceData = <_FaceData>[];
    for (int i = 0; i < faces.length; i++) {
      final f = faces[i];
      final normal = _calculateNormal(rotated[f[0]], rotated[f[1]], rotated[f[2]]);
      
      // Yüz kameraya bakıyor mu? (Z komponenti pozitif)
      if (normal[2] > 0) {
        final depth = (rotated[f[0]][2] + rotated[f[1]][2] + rotated[f[2]][2] + rotated[f[3]][2]) / 4;
        final faceValue = _getFaceValue(value, i);
        faceData.add(_FaceData(
          indices: f,
          depth: depth,
          brightness: normal[2],
          faceValue: faceValue,
        ));
      }
    }

    // Derinliğe göre sırala (arkadan öne)
    faceData.sort((a, b) => a.depth.compareTo(b.depth));

    // Gölge çiz
    _drawShadow(canvas, projected, center, half);

    // Yüzleri çiz
    for (final face in faceData) {
      _drawFace(canvas, projected, face);
    }
  }

  List<double> _rotate3D(List<double> v, double rx, double ry) {
    // Y ekseni etrafında döndür
    final cosY = math.cos(ry);
    final sinY = math.sin(ry);
    final x1 = v[0] * cosY - v[2] * sinY;
    final z1 = v[0] * sinY + v[2] * cosY;

    // X ekseni etrafında döndür
    final cosX = math.cos(rx);
    final sinX = math.sin(rx);
    final y2 = v[1] * cosX - z1 * sinX;
    final z2 = v[1] * sinX + z1 * cosX;

    return [x1, y2, z2];
  }

  List<double> _calculateNormal(List<double> v0, List<double> v1, List<double> v2) {
    // İki kenar vektörü
    final e1 = [v1[0] - v0[0], v1[1] - v0[1], v1[2] - v0[2]];
    final e2 = [v2[0] - v0[0], v2[1] - v0[1], v2[2] - v0[2]];
    
    // Çapraz çarpım
    final nx = e1[1] * e2[2] - e1[2] * e2[1];
    final ny = e1[2] * e2[0] - e1[0] * e2[2];
    final nz = e1[0] * e2[1] - e1[1] * e2[0];
    
    // Normalize
    final len = math.sqrt(nx * nx + ny * ny + nz * nz);
    return [nx / len, ny / len, nz / len];
  }

  void _drawShadow(Canvas canvas, List<Offset> projected, Offset center, double half) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    
    // Basit oval gölge
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + 4, center.dy + half * 0.7),
        width: cubeSize * 0.9,
        height: cubeSize * 0.3,
      ),
      shadowPaint,
    );
  }

  void _drawFace(Canvas canvas, List<Offset> projected, _FaceData face) {
    final path = Path();
    path.moveTo(projected[face.indices[0]].dx, projected[face.indices[0]].dy);
    for (int i = 1; i < 4; i++) {
      path.lineTo(projected[face.indices[i]].dx, projected[face.indices[i]].dy);
    }
    path.close();

    // Yüz rengi (parlaklığa göre)
    final baseColor = face.brightness > 0.7 
        ? _faceLight 
        : face.brightness > 0.4 
            ? _faceMid 
            : _faceDark;
    
    // Yüzü doldur
    canvas.drawPath(path, Paint()..color = baseColor);
    
    // Kenarlık
    canvas.drawPath(path, Paint()
      ..color = _border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2);

    // Pip'leri çiz (sadece en parlak yüze)
    if (face.brightness > 0.5) {
      _drawPips(canvas, projected, face);
    }
  }

  void _drawPips(Canvas canvas, List<Offset> projected, _FaceData face) {
    final p0 = projected[face.indices[0]];
    final p1 = projected[face.indices[1]];
    final p2 = projected[face.indices[2]];
    final p3 = projected[face.indices[3]];

    // Yüz merkezi ve eksenleri
    final centerX = (p0.dx + p1.dx + p2.dx + p3.dx) / 4;
    final centerY = (p0.dy + p1.dy + p2.dy + p3.dy) / 4;
    
    // Yüz boyutu
    final faceW = (p1 - p0).distance;
    final faceH = (p3 - p0).distance;
    final pipR = math.min(faceW, faceH) * 0.10;

    // Yüz yönleri
    final dirX = Offset((p1.dx - p0.dx) / faceW, (p1.dy - p0.dy) / faceW);
    final dirY = Offset((p3.dx - p0.dx) / faceH, (p3.dy - p0.dy) / faceH);

    void drawPip(double relX, double relY) {
      final px = centerX + (relX - 0.5) * faceW * 0.6 * dirX.dx + (relY - 0.5) * faceH * 0.6 * dirY.dx;
      final py = centerY + (relX - 0.5) * faceW * 0.6 * dirX.dy + (relY - 0.5) * faceH * 0.6 * dirY.dy;
      
      // Pip gölgesi
      canvas.drawCircle(
        Offset(px + 0.5, py + 0.5),
        pipR * 0.9,
        Paint()..color = Colors.black.withValues(alpha: 0.2),
      );
      // Pip
      canvas.drawCircle(Offset(px, py), pipR, Paint()..color = _pip);
      // Highlight
      canvas.drawCircle(
        Offset(px - pipR * 0.25, py - pipR * 0.25),
        pipR * 0.3,
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      );
    }

    const lo = 0.20;
    const mid = 0.50;
    const hi = 0.80;

    switch (face.faceValue) {
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

  // Üst değere göre her yüzün değerini belirle
  int _getFaceValue(int topValue, int faceIndex) {
    // Standart zar: karşılıklı yüzler 7
    // faceIndex: 0=arka, 1=ön, 2=alt, 3=üst, 4=sol, 5=sağ
    final mapping = {
      1: [5, 2, 3, 1, 4, 6], // top=1
      2: [4, 3, 1, 2, 6, 5], // top=2
      3: [1, 6, 2, 5, 3, 4], // top=3
      4: [6, 1, 5, 2, 4, 3], // top=4
      5: [3, 4, 6, 5, 1, 2], // top=5
      6: [2, 5, 4, 6, 3, 1], // top=6
    };
    return mapping[topValue]?[faceIndex] ?? 1;
  }

  @override
  bool shouldRepaint(covariant _RealisticDiePainter old) =>
      old.value != value || 
      old.rotationX != rotationX || 
      old.rotationY != rotationY;
}

class _FaceData {
  final List<int> indices;
  final double depth;
  final double brightness;
  final int faceValue;

  _FaceData({
    required this.indices,
    required this.depth,
    required this.brightness,
    required this.faceValue,
  });
}
