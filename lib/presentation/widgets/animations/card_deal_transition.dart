import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Card deal animation widget that creates a dramatic "flying card from deck" effect
/// with scale, rotation, and fade-in animations.
class CardDealTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const CardDealTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800), // Slower, more dramatic
    this.curve = Curves.easeOutBack,
  });

  @override
  State<CardDealTransition> createState() => _CardDealTransitionState();
}

class _CardDealTransitionState extends State<CardDealTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Scale from 0 (invisible) to full size - very dramatic zoom effect
    _scaleAnimation = Tween<double>(
      begin: 0.0, // Start from nothing
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Full 360° rotation (1 full spin) to simulate card being "thrown" and flipping
    // 2 * pi = 360 degrees
    _rotationAnimation = Tween<double>(
      begin: 2 * math.pi, // Start at 360° (one full rotation)
      end: 0.0, // End at 0° (upright position)
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Fade in from transparent to visible
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.5,
          curve: Curves.easeIn,
        ), // Fade in first half
      ),
    );

    _controller.forward();
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
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
