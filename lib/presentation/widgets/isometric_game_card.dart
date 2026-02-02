import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/game_enums.dart';

class IsometricGameCard extends StatelessWidget {
  final CardType type;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool isMirrored;

  const IsometricGameCard({
    super.key,
    required this.type,
    this.width = 160,
    this.height = 220,
    this.onTap,
    this.isMirrored = false,
  });

  @override
  Widget build(BuildContext context) {
    // Theme setup based on card type
    final isSans = type == CardType.sans;

    // Visual configuration based on type (Pastel/Matte Palette)
    final mainColor = isSans
        ? const Color(0xFF4DB6AC) // Pastel Teal
        : const Color(0xFF3949AB); // Softer Indigo

    final accentColor = isSans
        ? const Color(0xFFFDD835) // Soft Gold
        : const Color(0xFFEEEEEE); // Matte Silver

    final icon = isSans ? Icons.auto_awesome : Icons.explore;
    final label = isSans ? "ŞANS" : "KADER";

    // Isometric Transform Constants
    // Rotate X ~0.6 rad for tilt (~34 deg)
    // Rotate Z: 0.0 (No tilt/inclination as requested)
    final double zRotation = 0.0;

    final Matrix4 isometricTransform = Matrix4.identity()
      ..setEntry(3, 2, 0.0) // No perspective (Orthographic)
      ..rotateX(0.6)
      ..rotateZ(zRotation);

    const double thickness = 16.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Extra padding for the rotation to not clip
        width: width + 40,
        height: height + 40,
        alignment: Alignment.center,
        child: Transform(
          transform: isometricTransform,
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // LAYER 1: Shadow (Bottom)
              Positioned(
                top:
                    thickness +
                    8, // Much tighter to looks like it's on the table
                left: 8,
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),

              // LAYER 2: Thickness (Middle - Side Walls as Stacked Paper)
              // Render from Bottom (thickness) to Top (1) so they overlap correctly.
              // i=thickness is the bottom-most card, drawn first.
              // i=1 is the card just below the face, drawn last (before face).
              for (int i = thickness.toInt(); i >= 1; i--)
                Positioned(
                  top: i.toDouble(),
                  left: 0,
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      // Alternating colors to emphasize individual cards
                      color: i % 2 == 0
                          ? const Color(0xFFFAFAFA)
                          : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.15),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),

              // LAYER 3: Main Face (Top)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        mainColor, // More solid, less shiny
                        mainColor.withOpacity(0.95),
                        mainColor.withOpacity(0.90),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accentColor.withOpacity(0.8),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.15),
                        offset: const Offset(-1, -1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Inner Border Frame
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: accentColor.withOpacity(0.4),
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),

                      // Content: Icon + Text
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Circular Icon Badge
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.2),
                                border: Border.all(
                                  color: accentColor,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: accentColor,
                                size: width * 0.25,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Text
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: width * 0.14,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.6),
                                    offset: const Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Decorative corner icons
                      Positioned(
                        top: 18,
                        left: 18,
                        child: Icon(
                          icon,
                          color: accentColor.withOpacity(0.4),
                          size: 14,
                        ),
                      ),
                      Positioned(
                        bottom: 18,
                        right: 18,
                        child: Transform.rotate(
                          angle: math.pi,
                          child: Icon(
                            icon,
                            color: accentColor.withOpacity(0.4),
                            size: 14,
                          ),
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
  }
}
