import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/game_theme.dart';
import '../core/motion/motion_constants.dart';

/// Reward Particles Widget - Celebratory explosion effect for correct answers
/// Uses physics-based animation with gravity and fade out
class RewardParticlesWidget extends StatefulWidget {
  final VoidCallback? onComplete;
  final int particleCount;

  const RewardParticlesWidget({
    super.key,
    this.onComplete,
    this.particleCount = 25,
  });

  @override
  State<RewardParticlesWidget> createState() => _RewardParticlesWidgetState();
}

class _RewardParticlesWidgetState extends State<RewardParticlesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: MotionDurations.confetti.safe,
    );

    _particles = List.generate(widget.particleCount, (_) => _createParticle());

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  _Particle _createParticle() {
    // Random angle for explosion direction
    final angle = _random.nextDouble() * 2 * math.pi;
    // Random velocity (speed)
    final velocity = 150 + _random.nextDouble() * 200;
    // Random size
    final size = 4 + _random.nextDouble() * 8;
    // Random color between copper and gold
    final color = Color.lerp(
      GameTheme.copperAccent,
      GameTheme.goldAccent,
      _random.nextDouble(),
    )!;
    // Random rotation speed
    final rotationSpeed = (_random.nextDouble() - 0.5) * 4;
    // Random shape (circle or square)
    final isCircle = _random.nextBool();

    return _Particle(
      velocityX: math.cos(angle) * velocity,
      velocityY: math.sin(angle) * velocity,
      size: size,
      color: color,
      rotationSpeed: rotationSpeed,
      isCircle: isCircle,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

/// Individual particle data
class _Particle {
  final double velocityX;
  final double velocityY;
  final double size;
  final Color color;
  final double rotationSpeed;
  final bool isCircle;

  _Particle({
    required this.velocityX,
    required this.velocityY,
    required this.size,
    required this.color,
    required this.rotationSpeed,
    required this.isCircle,
  });
}

/// CustomPainter for rendering particles with physics
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  static const double gravity = 400; // Gravity acceleration

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Time in seconds (for physics calculations)
    final t = progress * 1.5;

    for (final particle in particles) {
      // Calculate position with physics
      // x = x0 + vx * t
      final x = centerX + particle.velocityX * t;
      // y = y0 + vy * t + 0.5 * g * t^2 (gravity pulls down)
      final y = centerY + particle.velocityY * t + 0.5 * gravity * t * t;

      // Fade out based on progress
      final opacity = (1 - progress).clamp(0.0, 1.0);

      // Scale down slightly as particles age
      final scale = 1.0 - (progress * 0.3);

      // Skip if off screen
      if (x < -50 || x > size.width + 50 || y < -50 || y > size.height + 50) {
        continue;
      }

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      // Add glow effect
      final glowPaint = Paint()
        ..color = particle.color.withValues(alpha: opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      final adjustedSize = particle.size * scale;
      final rotation = particle.rotationSpeed * progress * math.pi * 2;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      if (particle.isCircle) {
        // Draw glow
        canvas.drawCircle(Offset.zero, adjustedSize * 1.5, glowPaint);
        // Draw particle
        canvas.drawCircle(Offset.zero, adjustedSize, paint);
      } else {
        // Draw square
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: adjustedSize * 2,
          height: adjustedSize * 2,
        );
        // Draw glow
        canvas.drawRect(rect.inflate(2), glowPaint);
        // Draw particle
        canvas.drawRect(rect, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Overlay widget to show particles on top of everything
class RewardParticlesOverlay extends StatelessWidget {
  final VoidCallback? onComplete;

  const RewardParticlesOverlay({super.key, this.onComplete});

  /// Show the particle effect as an overlay
  static void show(BuildContext context, {VoidCallback? onComplete}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: RewardParticlesWidget(
            onComplete: () {
              entry.remove();
              onComplete?.call();
            },
          ),
        ),
      ),
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return RewardParticlesWidget(onComplete: onComplete);
  }
}
