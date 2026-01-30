import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/game_theme.dart';
import '../../core/motion/motion_constants.dart';

/// Streak Candle Widget - "Sönmeyen Mum" (Eternal Candle)
/// Represents user's daily play streak with a physical candle appearance
/// Uses CustomPainter for detailed candle and flame rendering
class StreakCandleWidget extends StatefulWidget {
  final int streakDays;
  final double size;
  final bool isLit;

  const StreakCandleWidget({
    super.key,
    this.streakDays = 0,
    this.size = 60,
    this.isLit = false,
  });

  @override
  State<StreakCandleWidget> createState() => _StreakCandleWidgetState();
}

class _StreakCandleWidgetState extends State<StreakCandleWidget>
    with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  // Flame animation controller
  late AnimationController _flameController;
  late Animation<double> _flameAnimation;

  @override
  void initState() {
    super.initState();

    // Subtle breathing animation for candle body
    _breatheController = AnimationController(
      vsync: this,
      duration: MotionDurations.shimmerMedium.safe,
    );

    _breatheAnimation = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: MotionCurves.standard),
    );

    _breatheController.repeat(reverse: true);

    // Flame flicker animation (faster for realistic flame movement)
    _flameController = AnimationController(
      vsync: this,
      duration: MotionDurations.fast.safe,
    );

    _flameAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flameController, curve: MotionCurves.standard),
    );

    _flameController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _flameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breatheAnimation, _flameAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _breatheAnimation.value,
          child: Opacity(
            opacity: 0.9 + (_breatheAnimation.value - 0.97) * 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Flame (rendered above candle)
                if (widget.isLit)
                  CustomPaint(
                    size: Size(widget.size, widget.size * 0.6),
                    painter: _FlamePainter(flickerValue: _flameAnimation.value),
                  ),

                // Candle body
                CustomPaint(
                  size: Size(widget.size, widget.size * 1.5),
                  painter: _CandlePainter(
                    waxColor: _getWaxColor(),
                    wickColor: GameTheme.tableBackgroundColor,
                    isLit: widget.isLit,
                  ),
                ),
                const SizedBox(height: 4),

                // Streak counter
                if (widget.streakDays > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isLit
                          ? GameTheme.goldAccent.withValues(alpha: 0.4)
                          : GameTheme.copperAccent.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: widget.isLit
                          ? [
                              BoxShadow(
                                color: GameTheme.goldAccent.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '${widget.streakDays} gün',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: widget.isLit
                            ? GameTheme.tableBackgroundColor
                            : GameTheme.textDark,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getWaxColor() {
    final baseColor = GameTheme.parchmentColor;
    return Color.fromARGB(
      255,
      ((baseColor.r * 255) * 0.85).toInt().clamp(0, 255),
      ((baseColor.g * 255) * 0.85).toInt().clamp(0, 255),
      ((baseColor.b * 255) * 0.85).toInt().clamp(0, 255),
    );
  }
}

/// CustomPainter for animated flame with flicker effect
class _FlamePainter extends CustomPainter {
  final double flickerValue;

  _FlamePainter({required this.flickerValue});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final flameBottom = size.height;

    // Flicker modifiers for organic movement
    final widthMod = 1.0 + (math.sin(flickerValue * math.pi * 2) * 0.15);
    final heightMod = 1.0 + (math.cos(flickerValue * math.pi * 3) * 0.1);
    final swayX = math.sin(flickerValue * math.pi * 4) * 2;

    final flameWidth = size.width * 0.35 * widthMod;
    final flameHeight = size.height * 0.85 * heightMod;
    final flameTop = flameBottom - flameHeight;

    // ═══════════════════════════════════════════════════════════════
    // GLOW EFFECT (Radial blur around flame)
    // ═══════════════════════════════════════════════════════════════
    final glowPaint = Paint()
      ..color = const Color(0xFFFF6B00).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(
      Offset(centerX + swayX, flameBottom - flameHeight * 0.5),
      flameWidth * 1.8,
      glowPaint,
    );

    // ═══════════════════════════════════════════════════════════════
    // OUTER FLAME (Red/Orange)
    // ═══════════════════════════════════════════════════════════════
    final outerPath = _createFlamePath(
      centerX + swayX,
      flameBottom,
      flameWidth,
      flameHeight,
    );

    final outerPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: const [
              Color(0xFFFF4500), // Red-orange at base
              Color(0xFFFF6B00), // Orange
              Color(0xFFFF8C00), // Dark orange at tip
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromLTWH(
              centerX - flameWidth,
              flameTop,
              flameWidth * 2,
              flameHeight,
            ),
          );

    canvas.drawPath(outerPath, outerPaint);

    // ═══════════════════════════════════════════════════════════════
    // INNER FLAME (Yellow/White core)
    // ═══════════════════════════════════════════════════════════════
    final innerPath = _createFlamePath(
      centerX + swayX * 0.5,
      flameBottom,
      flameWidth * 0.6,
      flameHeight * 0.7,
    );

    final innerPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: const [
              Color(0xFFFFD700), // Gold at base
              Color(0xFFFFFF00), // Yellow
              Color(0xFFFFFFCC), // Light yellow at tip
            ],
            stops: const [0.0, 0.4, 1.0],
          ).createShader(
            Rect.fromLTWH(
              centerX - flameWidth * 0.6,
              flameTop + flameHeight * 0.3,
              flameWidth * 1.2,
              flameHeight * 0.7,
            ),
          );

    canvas.drawPath(innerPath, innerPaint);

    // ═══════════════════════════════════════════════════════════════
    // BLUE BASE (Near wick - hottest part)
    // ═══════════════════════════════════════════════════════════════
    final bluePath = _createFlamePath(
      centerX + swayX * 0.2,
      flameBottom,
      flameWidth * 0.3,
      flameHeight * 0.25,
    );

    final bluePaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: const [
              Color(0xFF1E90FF), // Dodger blue
              Color(0xFF87CEEB), // Sky blue
            ],
          ).createShader(
            Rect.fromLTWH(
              centerX - flameWidth * 0.3,
              flameBottom - flameHeight * 0.25,
              flameWidth * 0.6,
              flameHeight * 0.25,
            ),
          );

    canvas.drawPath(bluePath, bluePaint);
  }

  Path _createFlamePath(
    double centerX,
    double bottom,
    double width,
    double height,
  ) {
    final top = bottom - height;
    final path = Path();

    // Teardrop flame shape using bezier curves
    path.moveTo(centerX, top); // Tip
    path.quadraticBezierTo(
      centerX + width * 1.2,
      top + height * 0.3,
      centerX + width,
      bottom - height * 0.1,
    );
    path.quadraticBezierTo(centerX + width * 0.3, bottom, centerX, bottom);
    path.quadraticBezierTo(
      centerX - width * 0.3,
      bottom,
      centerX - width,
      bottom - height * 0.1,
    );
    path.quadraticBezierTo(
      centerX - width * 1.2,
      top + height * 0.3,
      centerX,
      top,
    );

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _FlamePainter oldDelegate) {
    return oldDelegate.flickerValue != flickerValue;
  }
}

/// CustomPainter for rendering the candle body, wick, and wax pool
class _CandlePainter extends CustomPainter {
  final Color waxColor;
  final Color wickColor;
  final bool isLit;

  _CandlePainter({
    required this.waxColor,
    required this.wickColor,
    this.isLit = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final candleWidth = size.width * 0.5;
    final candleHeight = size.height * 0.7;
    final candleTop = size.height * 0.2;
    final candleBottom = candleTop + candleHeight;

    // ═══════════════════════════════════════════════════════════════
    // WAX POOL (Bottom oval)
    // ═══════════════════════════════════════════════════════════════
    final poolPaint = Paint()
      ..color = waxColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final poolRect = Rect.fromCenter(
      center: Offset(centerX, candleBottom + 5),
      width: candleWidth * 1.4,
      height: size.height * 0.12,
    );
    canvas.drawOval(poolRect, poolPaint);

    // ═══════════════════════════════════════════════════════════════
    // CANDLE BODY (Cylinder with gradient)
    // ═══════════════════════════════════════════════════════════════
    final bodyRect = Rect.fromLTWH(
      centerX - candleWidth / 2,
      candleTop,
      candleWidth,
      candleHeight,
    );

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          _darken(waxColor, 0.15),
          waxColor,
          _lighten(waxColor, 0.1),
          waxColor,
          _darken(waxColor, 0.2),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(bodyRect);

    final bodyRRect = RRect.fromRectAndRadius(
      bodyRect,
      const Radius.circular(4),
    );
    canvas.drawRRect(bodyRRect, bodyPaint);

    // Lit glow on candle body
    if (isLit) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFF6B00).withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawRRect(bodyRRect, glowPaint);
    }

    // Top oval (candle top surface)
    final topOvalRect = Rect.fromCenter(
      center: Offset(centerX, candleTop),
      width: candleWidth,
      height: candleWidth * 0.3,
    );
    final topPaint = Paint()
      ..color = _lighten(waxColor, 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawOval(topOvalRect, topPaint);

    // ═══════════════════════════════════════════════════════════════
    // WICK (Black line on top)
    // ═══════════════════════════════════════════════════════════════
    final wickPaint = Paint()
      ..color = isLit ? Colors.black : wickColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final wickStart = Offset(centerX, candleTop - 2);
    final wickEnd = Offset(centerX, candleTop - size.height * 0.12);
    canvas.drawLine(wickStart, wickEnd, wickPaint);

    // Wick tip (charred/glowing when lit)
    if (isLit) {
      final glowTipPaint = Paint()
        ..color = const Color(0xFFFF4500)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(wickEnd, 3, glowTipPaint);
    }

    final tipPaint = Paint()
      ..color = isLit ? const Color(0xFF330000) : Colors.black87
      ..style = PaintingStyle.fill;
    canvas.drawCircle(wickEnd, 2.5, tipPaint);

    // ═══════════════════════════════════════════════════════════════
    // SUBTLE DETAILS (Wax drips)
    // ═══════════════════════════════════════════════════════════════
    final dripPaint = Paint()
      ..color = waxColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    _drawWaxDrip(
      canvas,
      Offset(centerX - candleWidth * 0.35, candleTop + candleHeight * 0.3),
      candleWidth * 0.15,
      candleHeight * 0.2,
      dripPaint,
    );

    _drawWaxDrip(
      canvas,
      Offset(centerX + candleWidth * 0.3, candleTop + candleHeight * 0.5),
      candleWidth * 0.12,
      candleHeight * 0.15,
      dripPaint,
    );
  }

  void _drawWaxDrip(
    Canvas canvas,
    Offset start,
    double width,
    double height,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(
        start.dx - width / 2,
        start.dy + height * 0.6,
        start.dx,
        start.dy + height,
      )
      ..quadraticBezierTo(
        start.dx + width / 2,
        start.dy + height * 0.6,
        start.dx,
        start.dy,
      );
    canvas.drawPath(path, paint);
  }

  Color _darken(Color color, double amount) {
    return Color.fromARGB(
      255,
      ((color.r * 255) * (1 - amount)).toInt().clamp(0, 255),
      ((color.g * 255) * (1 - amount)).toInt().clamp(0, 255),
      ((color.b * 255) * (1 - amount)).toInt().clamp(0, 255),
    );
  }

  Color _lighten(Color color, double amount) {
    return Color.fromARGB(
      255,
      ((color.r * 255) + (255 - (color.r * 255)) * amount).toInt().clamp(
        0,
        255,
      ),
      ((color.g * 255) + (255 - (color.g * 255)) * amount).toInt().clamp(
        0,
        255,
      ),
      ((color.b * 255) + (255 - (color.b * 255)) * amount).toInt().clamp(
        0,
        255,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _CandlePainter oldDelegate) {
    return oldDelegate.waxColor != waxColor ||
        oldDelegate.wickColor != wickColor ||
        oldDelegate.isLit != isLit;
  }
}
