import 'package:flutter/material.dart';

class IsometricIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double depth;

  const IsometricIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 50.0,
    this.depth = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    // We use Text widget instead of Icon to apply advanced effects
    // like strokes and accurate shadows.
    final iconString = String.fromCharCode(icon.codePoint);
    final textStyle = TextStyle(
      fontFamily: icon.fontFamily,
      package: icon.fontPackage,
      fontSize: size,
      height: 1.0, // Critical for alignment
    );

    // Calculate darker shade for depth
    final hslColor = HSLColor.fromColor(color);
    final darkerColor = hslColor
        .withLightness((hslColor.lightness - 0.2).clamp(0.0, 1.0))
        .toColor();

    return SizedBox(
      width: size,
      height: size + depth,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. BLUR SHADOW LAYER (Bottom-most)
          Positioned(
            top: depth + 2,
            left: 0,
            right: 0,
            child: Text(
              iconString,
              textAlign: TextAlign.center,
              style: textStyle.copyWith(
                color: Colors.transparent, // Only shadow is visible
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // 2. DEPTH LAYERS (Stacked for 3D effect)
          for (int i = 0; i < depth; i++)
            Positioned(
              top: (depth - i).toDouble(),
              left: 0,
              right: 0,
              child: Text(
                iconString,
                textAlign: TextAlign.center,
                style: textStyle.copyWith(color: darkerColor),
              ),
            ),

          // 3. OUTLINE LAYER (Stroke behind the front face)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Text(
              iconString,
              textAlign: TextAlign.center,
              style: textStyle.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth =
                      2.0 // 1px visual width effectively
                  ..color = Colors.white,
              ),
            ),
          ),

          // 4. FRONT GRADIENT FACE (Top-most)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color, // Base color
                    hslColor
                        .withLightness(
                          (hslColor.lightness - 0.1).clamp(0.0, 1.0),
                        )
                        .toColor(), // Slightly darker
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: Text(
                iconString,
                textAlign: TextAlign.center,
                style: textStyle.copyWith(color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
