import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum OptionState {
  idle,
  checking, // Selected/Processing
  correct,
  wrong,
}

class OptionButton extends StatefulWidget {
  final String text;
  final OptionState state;
  final VoidCallback onTap;

  const OptionButton({
    super.key,
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  State<OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<OptionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // 1. Determine Color Scheme based on state
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData? icon;

    switch (widget.state) {
      case OptionState.idle:
        bgColor = Colors.white;
        borderColor = const Color(0xFFE0E0E0); // Light Grey
        textColor = const Color(0xFF2C2C2C); // Dark Ink
        break;
      case OptionState.checking:
        bgColor = const Color(0xFFFFC107); // Amber/Orange
        borderColor = const Color(0xFFFFA000);
        textColor = Colors.black;
        icon = Icons.hourglass_empty_rounded;
        break;
      case OptionState.correct:
        bgColor = const Color(0xFF4CAF50); // Green
        borderColor = const Color(0xFF2E7D32);
        textColor = Colors.white;
        icon = Icons.check_circle_rounded;
        break;
      case OptionState.wrong:
        bgColor = const Color(0xFFF44336); // Red
        borderColor = const Color(0xFFC62828);
        textColor = Colors.white;
        icon = Icons.cancel_rounded;
        break;
    }

    // 2. Determine "Physical" properties (Elevation/Shadow/Offset)
    // If pressed, we reduce shadow and move down to simulate depth.
    final double shadowOffset = _isPressed ? 0 : 4;
    final double translateY = _isPressed ? 4 : 0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, translateY, 0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.4),
              offset: Offset(0, shadowOffset),
              blurRadius: 0, // Solid shadow for "cartoon/embossed" feel
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.text,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 12),
              Icon(icon, color: textColor, size: 24),
            ],
          ],
        ),
      ),
    );
  }
}
