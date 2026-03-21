import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/question.dart';
import '../../models/game_enums.dart';

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
  int? selectedIndex;
  bool hasAnswered = false;

  @override
  void initState() {
    super.initState();

    // Initialize Flip Animation
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _flipAnimation = Tween<double>(begin: -math.pi / 2, end: 0.0).animate(
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

  void _handleAnswer(int index, bool isCorrect) {
    if (hasAnswered) return;

    setState(() {
      selectedIndex = index;
      hasAnswered = true;
    });

    // Delay the callback to show feedback
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        widget.onAnswer(isCorrect);
      }
    });
  }

  /// Uzun sorularda genişliği kullanır; yüksekliğe sığana kadar punto düşürür (uniform FittedBox yerine).
  double _fitQuestionFontSize(String text, double maxW, double maxH) {
    for (var fs = 27.0; fs >= 14.0; fs -= 0.5) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: GoogleFonts.crimsonText(
            fontSize: fs,
            height: 1.38,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C2C2C),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout(maxWidth: maxW);
      if (tp.height <= maxH) return fs;
    }
    return 14;
  }

  double _fitOptionFontSize(String text, double maxW, Color textColor) {
    const maxH = 110.0;
    for (var fs = 26.0; fs >= 13.5; fs -= 0.5) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: GoogleFonts.crimsonText(
            fontSize: fs,
            height: 1.28,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 6,
      );
      tp.layout(maxWidth: maxW);
      if (tp.height <= maxH && !tp.didExceedMaxLines) return fs;
    }
    return 13.5;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = math.min(screenSize.width * 0.92, 460.0);
    final cardHeight = math.min(screenSize.height * 0.73, 560.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_flipAnimation.value),
              child: child,
            );
          },
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              color: const Color(0xFFFDFBF7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF8B4513),
                width: 4,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x30000000),
                  blurRadius: 30,
                  offset: Offset(0, 15),
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Color(0x15000000),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFD2691E),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF9F6EE),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFF8B4513),
                              width: 3,
                            ),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.question.category.displayName.toUpperCase(),
                            style: GoogleFonts.crimsonText(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF8B4513),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: LayoutBuilder(
                            builder: (context, c) {
                              final maxW = c.maxWidth;
                              final maxH = c.maxHeight;
                              final fs = _fitQuestionFontSize(
                                widget.question.text,
                                maxW,
                                maxH,
                              );
                              return Center(
                                child: Text(
                                  widget.question.text,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.crimsonText(
                                    fontSize: fs,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2C2C2C),
                                    height: 1.38,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: const Color(0xFF8B4513).withOpacity(0.3),
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                      ),
                      
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                          child: LayoutBuilder(
                            builder: (context, optionsConstraints) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: List.generate(
                                  widget.question.options.length,
                                  (index) {
                                    final isCorrect = index == widget.question.correctIndex;
                                    final isSelected = selectedIndex == index;
                                    final showCorrect = hasAnswered && isCorrect;
                                    final showWrong = hasAnswered && isSelected && !isCorrect;

                                    Color backgroundColor;
                                    Color borderColor;
                                    Color textColor;
                                    BoxDecoration decoration;

                                    if (showCorrect) {
                                      backgroundColor = const Color(0xFFE8F5E9);
                                      borderColor = const Color(0xFF2E7D32);
                                      textColor = const Color(0xFF1B5E20);
                                      decoration = BoxDecoration(
                                        color: backgroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: borderColor,
                                          width: 3,
                                        ),
                                      );
                                    } else if (showWrong) {
                                      backgroundColor = const Color(0xFFFFEBEE);
                                      borderColor = const Color(0xFFC62828);
                                      textColor = const Color(0xFFB71C1C);
                                      decoration = BoxDecoration(
                                        color: backgroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: borderColor,
                                          width: 3,
                                        ),
                                      );
                                    } else {
                                      backgroundColor = const Color(0xFFFFFBF0);
                                      borderColor = const Color(0xFF8B7355);
                                      textColor = const Color(0xFF3E2723);
                                      decoration = BoxDecoration(
                                        color: backgroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: borderColor,
                                          width: 2,
                                          style: BorderStyle.solid,
                                        ),
                                      );
                                    }

                                    return Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          decoration: decoration,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: hasAnswered 
                                                ? null 
                                                : () => _handleAnswer(index, isCorrect),
                                              borderRadius: BorderRadius.circular(8),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 8,
                                                ),
                                                child: LayoutBuilder(
                                                  builder: (context, oc) {
                                                    final fs = _fitOptionFontSize(
                                                      widget.question.options[index],
                                                      oc.maxWidth,
                                                      textColor,
                                                    );
                                                    return Text(
                                                      widget.question.options[index],
                                                      textAlign: TextAlign.center,
                                                      maxLines: 6,
                                                      style: GoogleFonts.crimsonText(
                                                        fontSize: fs,
                                                        fontWeight: FontWeight.w600,
                                                        color: textColor,
                                                        height: 1.28,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
