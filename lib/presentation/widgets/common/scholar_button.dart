import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/game_theme.dart';
import '../../../core/motion/motion_constants.dart';

/// Ottoman Scholar-themed button with leather texture and gold leaf border
/// Features bounce animation on press and responsive layout
class ScholarButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isSecondary;
  final bool isSmall;
  final bool isFullWidth;
  final Color? customColor;
  final Color? customTextColor;

  const ScholarButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.isPrimary = true,
    this.isSecondary = false,
    this.isSmall = false,
    this.isFullWidth = false,
    this.customColor,
    this.customTextColor,
  });

  @override
  State<ScholarButton> createState() => _ScholarButtonState();
}

class _ScholarButtonState extends State<ScholarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MotionDurations.fast.safe,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MotionCurves.emphasized,
    ));

    // Shimmer animation for gold leaf effect
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = widget.customColor ??
        (widget.isSecondary ? GameTheme.ottomanSepia : GameTheme.ottomanGold);

    final Color textColor = widget.customTextColor ?? Colors.white;

    final double height = widget.isSmall ? 48.0 : 64.0;
    final double fontSize = widget.isSmall ? 16.0 : 20.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = widget.isFullWidth
            ? constraints.maxWidth
            : (widget.isSmall ? 200.0 : 280.0);

        return GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = _scaleAnimation.value;

              return Transform.scale(
                scale: scale,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: 120,
                    maxWidth: maxWidth,
                  ),
                  height: height,
                  decoration: BoxDecoration(
                    // Leather texture gradient
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        buttonColor.withValues(alpha: 0.95),
                        buttonColor.withValues(alpha: 0.85),
                        buttonColor.withValues(alpha: 0.9),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    // Gold leaf border
                    border: Border.all(
                      color: GameTheme.ottomanGoldLight,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    // Pressed state shadow
                    boxShadow: _isPressed
                        ? [
                            BoxShadow(
                              color: buttonColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: GameTheme.ottomanGoldShadow
                                  .withValues(alpha: 0.4),
                              blurRadius: 16,
                              spreadRadius: 0,
                              offset: const Offset(0, 8),
                            ),
                            // Subtle gold glow
                            BoxShadow(
                              color: GameTheme.ottomanGoldLight
                                  .withValues(alpha: 0.15),
                              blurRadius: 8,
                              spreadRadius: -2,
                              offset: Offset.zero,
                            ),
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.5),
                    child: Stack(
                      children: [
                        // Shimmer effect overlay
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.3,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(-1.0 + _shimmerAnimation.value * 2, -0.5),
                                  end: Alignment(1.0 - _shimmerAnimation.value * 2, 0.5),
                                  colors: const [
                                    Colors.transparent,
                                    Colors.white,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Button content
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(
                                    widget.icon,
                                    color: textColor,
                                    size: widget.isSmall ? 20 : 24,
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Flexible(
                                  child: Text(
                                    widget.label,
                                    style: GoogleFonts.crimsonText(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                      letterSpacing: 1.5,
                                      height: 1.0,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Small variant of ScholarButton for compact spaces
class ScholarButtonSmall extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? color;

  const ScholarButtonSmall({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ScholarButton(
      label: label,
      icon: icon,
      onTap: onTap,
      isSmall: true,
      customColor: color,
    );
  }
}
