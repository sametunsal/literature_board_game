import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
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
    final dieSize = math.min(w * 0.22, h * 0.40).clamp(35.0, 65.0);
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
    final clampedFinalValue = finalValue.clamp(1, 6);

    // Hedef rotasyon - final değerin olduğu yüzü kameraya (ön yüze) getir.
    // Sabit tablo yerine aynı 3D matematikle hesaplıyoruz.
    final targetRotation = _findRotationForVisibleFace(clampedFinalValue);
    final baseRng = math.Random(seed * 7919 + clampedFinalValue * 101);
    final startX = (baseRng.nextDouble() * 2 - 1) * math.pi;
    final startY = (baseRng.nextDouble() * 2 - 1) * math.pi;
    final dirX = baseRng.nextBool() ? 1.0 : -1.0;
    final dirY = baseRng.nextBool() ? 1.0 : -1.0;
    final turnsX = 2 + baseRng.nextInt(2); // 2-3 tam tur
    final turnsY = 2 + baseRng.nextInt(2); // 2-3 tam tur

    // Son açı: hedef + tam tur(lar). Böylece zar baştan sona doğal şekilde akıp
    // tam hedef yüzde bitiyor, finalde ani "snap" olmuyor.
    final endX = targetRotation.$1 + dirX * 2 * math.pi * turnsX;
    final endY = targetRotation.$2 + dirY * 2 * math.pi * turnsY;
    final t = Curves.easeOutQuart.transform(progress.clamp(0.0, 1.0));
    final currentRotationX = startX + (endX - startX) * t;
    final currentRotationY = startY + (endY - startY) * t;

    // Hafif sallanma (yerleştikten sonra)
    final settleCurve = ((progress - 0.8) / 0.2).clamp(0.0, 1.0);
    final wobble = progress > 0.8
        ? math.sin((progress - 0.8) / 0.2 * math.pi * 3) * 0.02 * (1 - settleCurve)
        : 0.0;

    return SizedBox(
      width: size * 1.3,
      height: size * 1.3,
      child: CustomPaint(
        size: Size(size * 1.3, size * 1.3),
        isComplex: true,
        willChange: true,
        painter: _RealisticDiePainter(
          value: clampedFinalValue,
          rotationX: currentRotationX + wobble,
          rotationY: currentRotationY,
          cubeSize: size,
          debugExpectedValue: clampedFinalValue,
          showDebugOverlay: progress >= 0.74 && _kShowDiceDebugOverlay,
        ),
      ),
    );
  }

  (double, double) _findRotationForVisibleFace(int visibleValue) {
    const faceValues = [5, 2, 6, 1, 4, 3]; // 0=arka,1=ön,2=alt,3=üst,4=sol,5=sağ
    const quarterTurns = [
      0.0,
      math.pi / 2,
      -math.pi / 2,
      math.pi,
    ];

    // Küp yüz merkezleri (birim küp).
    const faceCenters = <List<double>>[
      [0.0, 0.0, -1.0], // arka
      [0.0, 0.0, 1.0], // ön
      [0.0, -1.0, 0.0], // alt
      [0.0, 1.0, 0.0], // üst
      [-1.0, 0.0, 0.0], // sol
      [1.0, 0.0, 0.0], // sağ
    ];

    for (final rx in quarterTurns) {
      for (final ry in quarterTurns) {
        var bestFace = 0;
        var bestZ = -double.infinity;
        for (var i = 0; i < faceCenters.length; i++) {
          final v = _rotate3D(faceCenters[i], rx, ry);
          if (v[2] > bestZ) {
            bestZ = v[2];
            bestFace = i;
          }
        }
        if (faceValues[bestFace] == visibleValue) {
          return (rx, ry);
        }
      }
    }

    // Fallback: hiçbir aday eşleşmezse nötr dön.
    return (0.0, 0.0);
  }

  List<double> _rotate3D(List<double> v, double rx, double ry) {
    final cosY = math.cos(ry);
    final sinY = math.sin(ry);
    final x1 = v[0] * cosY - v[2] * sinY;
    final z1 = v[0] * sinY + v[2] * cosY;

    final cosX = math.cos(rx);
    final sinX = math.sin(rx);
    final y2 = v[1] * cosX - z1 * sinX;
    final z2 = v[1] * sinX + z1 * cosX;

    return [x1, y2, z2];
  }

}

const bool _kShowDiceDebugOverlay = false;

/// Gerçekçi 3D zar çizen painter
class _RealisticDiePainter extends CustomPainter {
  _RealisticDiePainter({
    required this.value,
    required this.rotationX,
    required this.rotationY,
    required this.cubeSize,
    required this.debugExpectedValue,
    required this.showDebugOverlay,
  });

  final int value;
  final double rotationX;
  final double rotationY;
  final double cubeSize;
  final int debugExpectedValue;
  final bool showDebugOverlay;

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

    // Yüzler (vertex indeksleri, saat yönü/saat yönü tersi sırası tutarlı olmalı)
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
    // Projeksiyonla uyumlu görünüm yönü (+Z)
    const cameraDir = [0.0, 0.0, 1.0];
    const cullingEpsilon = 1e-4;
    for (int i = 0; i < faces.length; i++) {
      final f = faces[i];
      final rawNormal = _calculateNormal(rotated[f[0]], rotated[f[1]], rotated[f[2]]);
      final faceCenter = _calculateFaceCenter(rotated, f);
      var normal = rawNormal;

      // Normal içeri bakıyorsa ters çevirerek winding farklarından etkilenmeyi azalt.
      final outwardDot = normal[0] * faceCenter[0] + normal[1] * faceCenter[1] + normal[2] * faceCenter[2];
      if (outwardDot < 0) {
        normal = [-normal[0], -normal[1], -normal[2]];
      }

      final dotProduct =
          normal[0] * cameraDir[0] + normal[1] * cameraDir[1] + normal[2] * cameraDir[2];

      // Yüz kameraya bakıyor mu? (sınır açılarda titreşim için epsilon)
      if (dotProduct > cullingEpsilon) {
        final zValues = [
          rotated[f[0]][2],
          rotated[f[1]][2],
          rotated[f[2]][2],
          rotated[f[3]][2],
        ];
        final depth = zValues.reduce((a, b) => a + b) / 4.0;
        final minDepth = zValues.reduce(math.min);
        final maxDepth = zValues.reduce(math.max);
        final faceValue = _getFaceValue(i);
        // Parlaklık = kameraya dönüklük
        final brightness = dotProduct.clamp(0.0, 1.0);
        faceData.add(_FaceData(
          indices: f,
          faceIndex: i,
          depth: depth,
          minDepth: minDepth,
          maxDepth: maxDepth,
          brightness: brightness,
          faceValue: faceValue,
        ));
      }
    }

    // Derinliğe göre sırala (arkadan öne), eşitlikte deterministik tie-break.
    faceData.sort((a, b) {
      final depthCompare = a.depth.compareTo(b.depth);
      if (depthCompare != 0) return depthCompare;
      final minCompare = a.minDepth.compareTo(b.minDepth);
      if (minCompare != 0) return minCompare;
      final maxCompare = a.maxDepth.compareTo(b.maxDepth);
      if (maxCompare != 0) return maxCompare;
      return a.faceIndex.compareTo(b.faceIndex);
    });

    // Gölge çiz
    _drawShadow(canvas, projected, center, half);

    // Yüzleri çiz
    for (final face in faceData) {
      _drawFace(canvas, projected, face);
    }

    if (showDebugOverlay && faceData.isNotEmpty) {
      // En öndeki (kameraya en yakın) yüzü görünen yüz kabul et.
      final visibleFace = faceData.last;
      _drawDebugOverlay(canvas, size, debugExpectedValue, visibleFace.faceValue);
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
    if (len < 1e-8) {
      return [0.0, 0.0, 0.0];
    }
    return [nx / len, ny / len, nz / len];
  }

  List<double> _calculateFaceCenter(List<List<double>> vertices, List<int> indices) {
    final cx = (vertices[indices[0]][0] +
            vertices[indices[1]][0] +
            vertices[indices[2]][0] +
            vertices[indices[3]][0]) /
        4.0;
    final cy = (vertices[indices[0]][1] +
            vertices[indices[1]][1] +
            vertices[indices[2]][1] +
            vertices[indices[3]][1]) /
        4.0;
    final cz = (vertices[indices[0]][2] +
            vertices[indices[1]][2] +
            vertices[indices[2]][2] +
            vertices[indices[3]][2]) /
        4.0;
    return [cx, cy, cz];
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
    final p0 = projected[face.indices[0]];
    final p1 = projected[face.indices[1]];
    final p2 = projected[face.indices[2]];
    final p3 = projected[face.indices[3]];
    final edgeA = (p1 - p0).distance;
    final edgeB = (p3 - p0).distance;
    final shortestEdge = math.min(edgeA, edgeB);
    final maxAllowed = shortestEdge * 0.24;
    // Degenerate (çok ince/çizgiye yakın) yüzlerde rounded path üretme,
    // aksi durumda bezier köşeler titreşim ve argüman hatası üretebiliyor.
    final isDegenerateFace = shortestEdge < 2.0 || maxAllowed <= 0.0;
    final desiredRadius = cubeSize * 0.15;
    final cornerRadius = isDegenerateFace
        ? 0.0
        : math.min(math.max(desiredRadius, 0.2), maxAllowed);

    // Yüzler ayrı ayrı rasterize edildiği için animasyon sırasında birleşim
    // çizgilerinde mikroskobik boşluklar oluşabiliyor. Özellikle köşelerde
    // daha agresif genişletme ile komşu yüzlerle üst üste bindiriyoruz.
    final expansionPx = math.max(0.8, cubeSize * 0.018);
    final expandedPath = _buildCornerExpandedPath(
      p0: p0,
      p1: p1,
      p2: p2,
      p3: p3,
      expansionPx: expansionPx,
      cornerExpansion: expansionPx * 1.5, // Köşelerde ekstra genişletme
      cornerRadius: cornerRadius,
    );

    // Kenarlık için hafif genişletilmiş path
    final borderPath = _buildCornerExpandedPath(
      p0: p0,
      p1: p1,
      p2: p2,
      p3: p3,
      expansionPx: expansionPx * 0.4,
      cornerExpansion: expansionPx * 0.8,
      cornerRadius: cornerRadius,
    );

    // Yüz rengi (parlaklığa göre)
    final baseColor = face.brightness > 0.7
        ? _faceLight
        : face.brightness > 0.4
            ? _faceMid
            : _faceDark;

    // Yüzü doldur - expanded path kullan
    canvas.drawPath(
      expandedPath,
      Paint()
        ..color = baseColor
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high,
    );

    // Kenarlık - expanded path kullan
    canvas.drawPath(borderPath, Paint()
      ..color = _border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..isAntiAlias = true);

    // Köşe boşluklarını dolduracak ekstra "seam" katmanı
    // Kenarlıktan SONRA çiziyoruz ki border boşluklarını da kapatsın
    _drawCornerSeams(canvas, [p0, p1, p2, p3], expansionPx, baseColor);

    // Pip'leri culling'den geçmiş görünür yüzlerde çiz.
    if (face.brightness > 0.2) {
      _drawPips(canvas, projected, face);
    }
  }

  Path _buildRoundedQuadPath(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    double radius,
  ) {
    final aIn = _pointTowards(p0, p3, radius);
    final aOut = _pointTowards(p0, p1, radius);
    final bIn = _pointTowards(p1, p0, radius);
    final bOut = _pointTowards(p1, p2, radius);
    final cIn = _pointTowards(p2, p1, radius);
    final cOut = _pointTowards(p2, p3, radius);
    final dIn = _pointTowards(p3, p2, radius);
    final dOut = _pointTowards(p3, p0, radius);

    return Path()
      ..moveTo(aOut.dx, aOut.dy)
      ..lineTo(bIn.dx, bIn.dy)
      ..quadraticBezierTo(p1.dx, p1.dy, bOut.dx, bOut.dy)
      ..lineTo(cIn.dx, cIn.dy)
      ..quadraticBezierTo(p2.dx, p2.dy, cOut.dx, cOut.dy)
      ..lineTo(dIn.dx, dIn.dy)
      ..quadraticBezierTo(p3.dx, p3.dy, dOut.dx, dOut.dy)
      ..lineTo(aIn.dx, aIn.dy)
      ..quadraticBezierTo(p0.dx, p0.dy, aOut.dx, aOut.dy)
      ..close();
  }

  Offset _expandFromCenter(Offset point, Offset center, double amount) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1e-6) return point;
    final nx = dx / len;
    final ny = dy / len;
    return Offset(point.dx + nx * amount, point.dy + ny * amount);
  }

  Offset _pointTowards(Offset from, Offset to, double distance) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1e-6) return from;
    final t = (distance / len).clamp(0.0, 1.0);
    return Offset(from.dx + dx * t, from.dy + dy * t);
  }

  /// Her köşeyi ayrı ayrı genişleten path - köşe boşlukları için
  Path _buildCornerExpandedPath({
    required Offset p0,
    required Offset p1,
    required Offset p2,
    required Offset p3,
    required double expansionPx,
    required double cornerExpansion,
    required double cornerRadius,
  }) {
    final center = Offset(
      (p0.dx + p1.dx + p2.dx + p3.dx) / 4,
      (p0.dy + p1.dy + p2.dy + p3.dy) / 4,
    );

    // Köşe noktalarını daha agresif genişlet
    final ep0 = _expandFromCenter(p0, center, cornerExpansion);
    final ep1 = _expandFromCenter(p1, center, cornerExpansion);
    final ep2 = _expandFromCenter(p2, center, cornerExpansion);
    final ep3 = _expandFromCenter(p3, center, cornerExpansion);

    if (cornerRadius <= 0.0) {
      return Path()
        ..moveTo(ep0.dx, ep0.dy)
        ..lineTo(ep1.dx, ep1.dy)
        ..lineTo(ep2.dx, ep2.dy)
        ..lineTo(ep3.dx, ep3.dy)
        ..close();
    }

    // Rounded path with expanded corners
    final aIn = _pointTowards(ep0, ep3, cornerRadius);
    final aOut = _pointTowards(ep0, ep1, cornerRadius);
    final bIn = _pointTowards(ep1, ep0, cornerRadius);
    final bOut = _pointTowards(ep1, ep2, cornerRadius);
    final cIn = _pointTowards(ep2, ep1, cornerRadius);
    final cOut = _pointTowards(ep2, ep3, cornerRadius);
    final dIn = _pointTowards(ep3, ep2, cornerRadius);
    final dOut = _pointTowards(ep3, ep0, cornerRadius);

    return Path()
      ..moveTo(aOut.dx, aOut.dy)
      ..lineTo(bIn.dx, bIn.dy)
      ..quadraticBezierTo(ep1.dx, ep1.dy, bOut.dx, bOut.dy)
      ..lineTo(cIn.dx, cIn.dy)
      ..quadraticBezierTo(ep2.dx, ep2.dy, cOut.dx, cOut.dy)
      ..lineTo(dIn.dx, dIn.dy)
      ..quadraticBezierTo(ep3.dx, ep3.dy, dOut.dx, dOut.dy)
      ..lineTo(aIn.dx, aIn.dy)
      ..quadraticBezierTo(ep0.dx, ep0.dy, aOut.dx, aOut.dy)
      ..close();
  }

  /// Köşe boşluklarını dolduracak "seam" - ince ve uyumlu
  /// Kenarlıktan SONRA çağrılır, ancak çok subtle olmalı
  void _drawCornerSeams(Canvas canvas, List<Offset> corners, double expansionPx, Color faceColor) {
    // Çok daha küçük - sadece boşluğu doldursun, görünmesin
    final seamRadius = expansionPx * 0.5;

    // Yüz rengiyle tam uyumlu paint
    final seamPaint = Paint()
      ..color = faceColor
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    for (final corner in corners) {
      // Tek küçük daire - sadece boşluğu kapatsın
      canvas.drawCircle(corner, seamRadius, seamPaint);
    }
  }

  void _drawDebugOverlay(
    Canvas canvas,
    Size size,
    int expectedValue,
    int visibleValue,
  ) {
    final isMatch = expectedValue == visibleValue;
    final bgPaint = Paint()
      ..color = (isMatch ? Colors.green : Colors.red).withValues(alpha: 0.80);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(6, 6, size.width - 12, 20),
      const Radius.circular(6),
    );
    canvas.drawRRect(rect, bgPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'exp:$expectedValue vis:$visibleValue',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 16);

    textPainter.paint(canvas, const Offset(10, 9));
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
        break;
      case 2:
        drawPip(lo, lo);
        drawPip(hi, hi);
        break;
      case 3:
        drawPip(lo, lo);
        drawPip(mid, mid);
        drawPip(hi, hi);
        break;
      case 4:
        drawPip(lo, lo);
        drawPip(hi, lo);
        drawPip(lo, hi);
        drawPip(hi, hi);
        break;
      case 5:
        drawPip(lo, lo);
        drawPip(hi, lo);
        drawPip(mid, mid);
        drawPip(lo, hi);
        drawPip(hi, hi);
        break;
      case 6:
        drawPip(lo, lo);
        drawPip(hi, lo);
        drawPip(lo, mid);
        drawPip(hi, mid);
        drawPip(lo, hi);
        drawPip(hi, hi);
        break;
    }
  }

  // Küpün sabit yüz yerleşimi:
  // faceIndex: 0=arka, 1=ön, 2=alt, 3=üst, 4=sol, 5=sağ
  // değerler:   5      2     6     1     4     3
  int _getFaceValue(int faceIndex) {
    const faceValues = [5, 2, 6, 1, 4, 3];
    if (faceIndex < 0 || faceIndex >= faceValues.length) return 1;
    return faceValues[faceIndex];
  }

  @override
  bool shouldRepaint(covariant _RealisticDiePainter old) =>
      old.value != value || 
      old.rotationX != rotationX || 
      old.rotationY != rotationY ||
      old.cubeSize != cubeSize;
}

class _FaceData {
  final List<int> indices;
  final int faceIndex;
  final double depth;
  final double minDepth;
  final double maxDepth;
  final double brightness;
  final int faceValue;

  _FaceData({
    required this.indices,
    required this.faceIndex,
    required this.depth,
    required this.minDepth,
    required this.maxDepth,
    required this.brightness,
    required this.faceValue,
  });
}
