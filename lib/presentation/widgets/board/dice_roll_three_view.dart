import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as tjs;

import '../../../core/constants/game_constants.dart';

/// `three_js` ile iki küp zar — fırlatma, dönüş, üst yüzeyde gerçek sonuç, sonra sabit bekleme.
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

class _DiceRollThreeViewState extends State<DiceRollThreeView> {
  late final tjs.ThreeJS threeJs;
  tjs.Object3D? _die1;
  tjs.Object3D? _die2;
  double _spin = 0;
  double _elapsedSec = 0;

  late final double _yaw1;
  late final double _yaw2;

  final tjs.Quaternion _q1Start = tjs.Quaternion();
  final tjs.Quaternion _q2Start = tjs.Quaternion();
  final tjs.Quaternion _q1Final = tjs.Quaternion();
  final tjs.Quaternion _q2Final = tjs.Quaternion();
  bool _settleCaptured = false;

  double get _motionSec => GameConstants.diceRollMotionDelayMs / 1000.0;
  double get _totalSec => GameConstants.diceAnimationDelay / 1000.0;

  @override
  void initState() {
    super.initState();
    final r = math.Random();
    _yaw1 = r.nextInt(4) * (math.pi / 2);
    _yaw2 = r.nextInt(4) * (math.pi / 2);

    final w = math.max(widget.width, 1.0);
    final h = math.max(widget.height, 1.0);
    threeJs = tjs.ThreeJS(
      size: Size(w, h),
      settings: tjs.Settings(
        alpha: true,
        clearAlpha: 0.0,
        clearColor: 0x000000,
        antialias: true,
      ),
      onSetupComplete: () {
        if (mounted) setState(() {});
      },
      setup: _setup,
    );
  }

  static double _easeOutCubic(double t) {
    final c = 1.0 - t;
    return 1.0 - c * c * c;
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  /// Model: +Z=1, -Z=6, +Y=5, -Y=2, +X=3, -X=4.
  /// Son yön: seçilen yüzün dış normali **kameraya** (izleyiciye) bakacak şekilde;
  /// dünya +Y “üst” varsayımı bu sahne/kamera ile görseli yanıltıyordu.
  static tjs.Vector3 _outwardNormalForFace(int value) {
    switch (value.clamp(1, 6)) {
      case 1:
        return tjs.Vector3(0, 0, 1);
      case 6:
        return tjs.Vector3(0, 0, -1);
      case 5:
        return tjs.Vector3(0, 1, 0);
      case 2:
        return tjs.Vector3(0, -1, 0);
      case 3:
        return tjs.Vector3(1, 0, 0);
      case 4:
      default:
        return tjs.Vector3(-1, 0, 0);
    }
  }

  static tjs.Quaternion _quaternionFaceTowardCamera(
    int faceValue,
    double yawAroundViewAxis,
    double dieX,
    double dieY,
    double dieZ,
    double cameraX,
    double cameraY,
    double cameraZ,
  ) {
    final dx = cameraX - dieX;
    final dy = cameraY - dieY;
    final dz = cameraZ - dieZ;
    final toward = tjs.Vector3(dx, dy, dz);
    toward.normalize();

    final nLoc = _outwardNormalForFace(faceValue);
    final qAlign = tjs.Quaternion().setFromUnitVectors(nLoc, toward);
    final qSpin =
        tjs.Quaternion().setFromAxisAngle(toward, yawAroundViewAxis);
    return tjs.Quaternion().multiplyQuaternions(qSpin, qAlign);
  }

  /// Batı zar düzeni: +Z=1, -Z=6, +Y=5, -Y=2, +X=3, -X=4 (karşılar toplam 7).
  tjs.Group _buildStandardDie(double size) {
    final half = size / 2;
    final pipR = size * 0.038;
    final pipH = size * 0.028;
    final a = half * 0.36;
    final b = half * 0.46;
    final eps = pipH * 0.5;

    final group = tjs.Group();

    final bodyMat = tjs.MeshPhysicalMaterial.fromMap({
      'color': 0xf4f4f4,
      'roughness': 0.42,
      'metalness': 0.05,
      'clearcoat': 0.12,
      'clearcoatRoughness': 0.48,
      'side': 2,
    });

    final bodyGeo = tjs.BoxGeometry(size, size, size, 3, 3, 3);
    group.add(tjs.Mesh(bodyGeo, bodyMat));

    final pipGeo = tjs.CylinderGeometry(pipR, pipR, pipH, 16, 1);
    final pipMat = tjs.MeshLambertMaterial.fromMap({
      'color': 0x000000,
      'side': 2,
    });

    void pipDisk(double x, double y, double z, int face) {
      final m = tjs.Mesh(pipGeo, pipMat);
      m.position.setValues(x, y, z);
      switch (face) {
        case 0:
          break;
        case 1:
          m.rotation.x = math.pi;
          break;
        case 2:
          m.rotation.x = math.pi / 2;
          break;
        case 3:
          m.rotation.x = -math.pi / 2;
          break;
        case 4:
          m.rotation.z = -math.pi / 2;
          break;
        case 5:
          m.rotation.z = math.pi / 2;
          break;
        default:
          break;
      }
      group.add(m);
    }

    final zOut = half + pipH * 0.5 + eps;

    pipDisk(0, 0, zOut, 2);
    for (final sy in [-1.0, 0.0, 1.0]) {
      pipDisk(-a, sy * b, -zOut, 3);
      pipDisk(a, sy * b, -zOut, 3);
    }

    final yOut = half + pipH * 0.5 + eps;
    pipDisk(0, yOut, 0, 0);
    pipDisk(-a, yOut, -a, 0);
    pipDisk(a, yOut, -a, 0);
    pipDisk(-a, yOut, a, 0);
    pipDisk(a, yOut, a, 0);

    final yIn = -(half + pipH * 0.5 + eps);
    pipDisk(-a, yIn, -a, 1);
    pipDisk(a, yIn, a, 1);

    final xOut = half + pipH * 0.5 + eps;
    pipDisk(xOut, -a, -a, 4);
    pipDisk(xOut, 0, 0, 4);
    pipDisk(xOut, a, a, 4);

    final xIn = -(half + pipH * 0.5 + eps);
    pipDisk(xIn, -a, -a, 5);
    pipDisk(xIn, a, -a, 5);
    pipDisk(xIn, -a, a, 5);
    pipDisk(xIn, a, a, 5);

    final cornerR = half * 0.22;
    final cornerGeo = tjs.SphereGeometry(cornerR, 10, 8);
    final cornerMat = bodyMat.clone();
    for (var i = 0; i < 8; i++) {
      final sx = (i & 1) == 0 ? 1.0 : -1.0;
      final sy = (i & 2) == 0 ? 1.0 : -1.0;
      final sz = (i & 4) == 0 ? 1.0 : -1.0;
      final cx = sx * (half - cornerR * 0.90);
      final cy = sy * (half - cornerR * 0.90);
      final cz = sz * (half - cornerR * 0.90);
      final cm = tjs.Mesh(cornerGeo, cornerMat);
      cm.position.setValues(cx, cy, cz);
      group.add(cm);
    }

    return group;
  }

  Future<void> _setup() async {
    final v1 = widget.dice1.clamp(1, 6);
    final v2 = widget.dice2.clamp(1, 6);

    threeJs.camera = tjs.PerspectiveCamera(
      46,
      threeJs.width / threeJs.height,
      0.1,
      100,
    );
    threeJs.camera.position.setValues(0, 0.38, 5.95);
    threeJs.camera.lookAt(tjs.Vector3(0, 0, 0));

    const x1Rest = -1.42;
    const x2Rest = 1.42;
    final cam = threeJs.camera.position;
    _q1Final.setFrom(
      _quaternionFaceTowardCamera(
        v1,
        _yaw1,
        x1Rest,
        0,
        0,
        cam.x,
        cam.y,
        cam.z,
      ),
    );
    _q2Final.setFrom(
      _quaternionFaceTowardCamera(
        v2,
        _yaw2,
        x2Rest,
        0,
        0,
        cam.x,
        cam.y,
        cam.z,
      ),
    );

    threeJs.scene = tjs.Scene();

    threeJs.scene.add(tjs.AmbientLight(0xffffff, 0.58));

    final dir = tjs.DirectionalLight(0xffffff, 0.82);
    dir.position.setValues(3.2, 6.5, 4.5);
    threeJs.scene.add(dir);

    final fill = tjs.DirectionalLight(0xe0e8ff, 0.35);
    fill.position.setValues(-4, 2, -2);
    threeJs.scene.add(fill);

    const dieSize = 1.22;
    _die1 = _buildStandardDie(dieSize);
    _die2 = _buildStandardDie(dieSize);

    threeJs.scene.add(_die1!);
    threeJs.scene.add(_die2!);

    const flightPortion = 0.36;
    final settleDur = 0.42;

    threeJs.addAnimationEvent((dt) {
      final d1 = _die1;
      final d2 = _die2;
      if (d1 == null || d2 == null) return;

      _elapsedSec += dt;
      final motionSec = _motionSec;

      if (_elapsedSec >= _totalSec) {
        d1.position.setValues(x1Rest, 0, 0);
        d2.position.setValues(x2Rest, 0, 0);
        d1.quaternion.setFrom(_q1Final);
        d2.quaternion.setFrom(_q2Final);
        d1.rotation.setFromQuaternion(d1.quaternion);
        d2.rotation.setFromQuaternion(d2.quaternion);
        return;
      }

      if (_elapsedSec < motionSec) {
        final tm = _elapsedSec / motionSec;

        if (tm < flightPortion) {
          final u = _easeOutCubic(tm / flightPortion);
          const x1s = -3.15;
          const x2s = 3.15;
          const ys = 2.35;
          const zs = -1.05;
          var y1 = _lerp(ys, 0, u);
          var y2 = _lerp(ys * 0.92, 0, u);
          if (tm > flightPortion * 0.55) {
            final w = ((tm - flightPortion * 0.55) / (flightPortion * 0.45))
                .clamp(0.0, 1.0);
            final bump = math.sin(w * math.pi) * 0.14;
            y1 += bump;
            y2 += bump * 0.9;
          }
          d1.position.setValues(_lerp(x1s, x1Rest, u), y1, _lerp(zs, 0, u));
          d2.position.setValues(_lerp(x2s, x2Rest, u), y2, _lerp(zs * 0.88, 0, u));
          final spinBoost = _lerp(2.6, 1.15, u);
          _spin += dt * 5.4 * spinBoost;
          d1.rotation.x = _spin * 1.12;
          d1.rotation.y = _spin * 0.88;
          d1.rotation.z = math.sin(_spin * 0.68) * 0.38;
          d2.rotation.x = -_spin * 0.94;
          d2.rotation.y = _spin * 1.16;
          d2.rotation.z = math.cos(_spin * 0.55) * 0.44;
        } else {
          final settleStartSec = motionSec - settleDur;
          if (_elapsedSec < settleStartSec) {
            d1.position.setValues(x1Rest, 0, 0);
            d2.position.setValues(x2Rest, 0, 0);
            final hop = math.sin(_spin * 1.72);
            d1.position.y = hop * 0.24;
            d2.position.y = -hop * 0.21;
            _spin += dt * 5.1;
            d1.rotation.x = _spin * 1.12;
            d1.rotation.y = _spin * 0.88;
            d1.rotation.z = math.sin(_spin * 0.68) * 0.38;
            d2.rotation.x = -_spin * 0.94;
            d2.rotation.y = _spin * 1.16;
            d2.rotation.z = math.cos(_spin * 0.55) * 0.44;
          } else {
            if (!_settleCaptured) {
              _q1Start.setFrom(d1.quaternion);
              _q2Start.setFrom(d2.quaternion);
              _settleCaptured = true;
            }
            d1.position.setValues(x1Rest, 0, 0);
            d2.position.setValues(x2Rest, 0, 0);
            final denom = math.max(1e-6, motionSec - settleStartSec);
            final u =
                ((_elapsedSec - settleStartSec) / denom).clamp(0.0, 1.0);
            final e = _easeOutCubic(u);
            d1.quaternion.slerpQuaternions(_q1Start, _q1Final, e);
            d2.quaternion.slerpQuaternions(_q2Start, _q2Final, e);
            d1.rotation.setFromQuaternion(d1.quaternion);
            d2.rotation.setFromQuaternion(d2.quaternion);
          }
        }
      } else {
        d1.position.setValues(x1Rest, 0, 0);
        d2.position.setValues(x2Rest, 0, 0);
        d1.quaternion.setFrom(_q1Final);
        d2.quaternion.setFrom(_q2Final);
        d1.rotation.setFromQuaternion(d1.quaternion);
        d2.rotation.setFromQuaternion(d2.quaternion);
      }
    });
  }

  @override
  void dispose() {
    threeJs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = math.max(widget.width, 1.0);
    final h = math.max(widget.height, 1.0);
    return SizedBox(
      width: w,
      height: h,
      child: threeJs.build(),
    );
  }
}
