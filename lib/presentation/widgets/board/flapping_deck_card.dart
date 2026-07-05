import 'package:flutter/material.dart';

import '../../../core/motion/motion_constants.dart';

/// Subtle idle "flap" for the centre deck cards: a gentle hinge-like tilt
/// around the Y axis with light perspective so the decks feel alive without
/// pulling focus from the dice or the roll button.
///
/// Reusable for both Şans and Kader decks; [phase] offsets the starting point
/// of the cycle so multiple decks don't flap in sync. Respects reduced motion
/// (the card stays flat) and is test-safe: the controller is disposed with the
/// state and the motion is fully time-driven, so fixed-duration pumps render
/// deterministic frames.
class FlappingDeckCard extends StatefulWidget {
  const FlappingDeckCard({super.key, required this.child, this.phase = 0.0});

  final Widget child;

  /// Initial position in the flap cycle (0..1).
  final double phase;

  static const Duration flapDuration = Duration(milliseconds: 2000);

  /// Peak tilt in radians — deliberately tiny so the motion reads as a
  /// breathing card, not a spinning one.
  static const double maxTiltRadians = 0.035;

  static const double perspective = 0.0015;

  @override
  State<FlappingDeckCard> createState() => _FlappingDeckCardState();
}

class _FlappingDeckCardState extends State<FlappingDeckCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _tilt;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: FlappingDeckCard.flapDuration,
      // 0.5 maps to zero tilt, so under reduced motion the card lies flat.
      value: reduceMotion ? 0.5 : widget.phase.clamp(0.0, 1.0),
    );
    _tilt = Tween<double>(
      begin: -FlappingDeckCard.maxTiltRadians,
      end: FlappingDeckCard.maxTiltRadians,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (!reduceMotion) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _tilt,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            // Keep the tap target identical to the untransformed card.
            transformHitTests: false,
            transform: Matrix4.identity()
              ..setEntry(3, 2, FlappingDeckCard.perspective)
              ..rotateY(_tilt.value),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
