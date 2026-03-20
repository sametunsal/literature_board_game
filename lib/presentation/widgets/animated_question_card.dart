import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/question.dart';

/// 3D Card Flip Animation Widget
/// Creates a realistic card flip effect using Matrix4 rotation
class AnimatedQuestionCard extends StatefulWidget {
  final Question question;
  final Function(bool) onAnswer;
  final VoidCallback? onTimeExpired;

  const AnimatedQuestionCard({
    super.key,
    required this.question,
    required this.onAnswer,
    this.onTimeExpired,
  });

  @override
  State<AnimatedQuestionCard> createState() => _AnimatedQuestionCardState();
}

class _AnimatedQuestionCardState extends State<AnimatedQuestionCard>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize Flip Animation
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    // Start flip animation after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _flipController.forward();
      }
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _handleAnswer(bool isCorrect) {
    // Play flip sound
    if (isCorrect) {
      // Flip back to show result
      _flipController.reverse(from: math.pi);
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        widget.onAnswer(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = math.min(screenSize.width * 0.90, 400.0);
    final cardHeight = math.min(screenSize.height * 0.70, 500.0);

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(_flipAnimation.value), // 3D flip animation
          child: child,
        );
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F6), // Cream / Off-White
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x42000000), // Black with 26% opacity
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Question text
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      widget.question.text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.crimsonText(
                        fontSize: 24,
                        color: const Color(0xFF2C2C2C), // Dark Ink
                        height: 1.3,
                      ),
                    ),
                  ),
                ),

                // Options buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                      widget.question.options.length,
                      (index) => ElevatedButton(
                        onPressed: () => _handleAnswer(
                          index == widget.question.correctIndex,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2C2C2C),
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.question.options[index],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
