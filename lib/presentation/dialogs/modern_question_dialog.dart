import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/quiz/option_button.dart';
import '../../models/question.dart';
import '../../models/game_enums.dart';
import '../../core/managers/audio_manager.dart';

/// "The Royal Bookmark" Question Dialog
/// A vertical, elegant card that resembles a high-quality bookmark.
class ModernQuestionDialog extends StatefulWidget {
  final Question question;
  final Function(bool isCorrect) onAnswer;
  final VoidCallback? onTimeExpired;

  const ModernQuestionDialog({
    super.key,
    required this.question,
    required this.onAnswer,
    this.onTimeExpired,
  });

  @override
  State<ModernQuestionDialog> createState() => _ModernQuestionDialogState();
}

class _ModernQuestionDialogState extends State<ModernQuestionDialog>
    with TickerProviderStateMixin {
  int? _selectedIndex;
  bool _isLocked = false;
  bool _isChecking = false;
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;
  final GlobalKey<_ShakeWidgetState> _shakeKey = GlobalKey();

  // Timer duration in seconds
  static const int _kQuestionDuration = 20;

  @override
  void initState() {
    super.initState();

    // Initialize Timer Animation (Golden Line)
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _kQuestionDuration),
    );

    _timerAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _timerController, curve: Curves.linear));

    _timerController.forward();

    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isLocked) {
        _handleTimeExpired();
      }
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  void _handleTimeExpired() {
    if (_isLocked) return;
    setState(() {
      _isLocked = true;
    });
    if (widget.onTimeExpired != null) {
      widget.onTimeExpired!();
    } else {
      widget.onAnswer(false);
    }
  }

  void _handleOptionTap(int index) {
    if (_isLocked) return;

    setState(() {
      _selectedIndex = index;
      _isLocked = true;
      _isChecking = true; // Start suspense
    });

    _timerController.stop();

    // SUSPENSE PHASE (1 second)
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      final isCorrect = index == widget.question.correctIndex;

      // REVEAL RESULT + PLAY SFX SIMULTANEOUSLY
      setState(() {
        _isChecking = false; // Reveal result (Green/Red)
      });

      // Play SFX exactly when color changes
      AudioManager.instance.playSfx(isCorrect ? 'audio/correct.wav' : 'audio/wrong.wav');

      if (!isCorrect) {
        // Trigger Shake Animation
        _shakeKey.currentState?.shake();
      }

      // CLOSE PHASE (1.5 seconds after reveal)
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          widget.onAnswer(isCorrect);
        }
      });
    });
  }

  Color _getCategoryColor(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.benKimim:
        return const Color(0xFF7B1FA2); // Purple
      case QuestionCategory.turkEdebiyatindaIlkler:
        return const Color(0xFF1976D2); // Blue
      case QuestionCategory.edebiyatAkimlari:
        return const Color(0xFFD32F2F); // Red
      case QuestionCategory.edebiSanatlar:
        return const Color(0xFF388E3C); // Green
      case QuestionCategory.eserKarakter:
        return const Color(0xFFFF8C00); // Orange
      case QuestionCategory.tesvik:
        return const Color(0xFF9C27B0); // Magenta
      case QuestionCategory.bonusBilgiler:
        return const Color(0xFFE91E63); // Pink
    }
  }

  String _getCategoryTitle(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.benKimim:
        return "BEN KİMİM?";
      case QuestionCategory.turkEdebiyatindaIlkler:
        return "İLKLER";
      case QuestionCategory.edebiyatAkimlari:
        return "EDEBİ AKIMLAR";
      case QuestionCategory.edebiSanatlar:
        return "EDEBİ SANATLAR";
      case QuestionCategory.eserKarakter:
        return "ESER & KARAKTER";
      case QuestionCategory.tesvik:
        return "TEŞVİK";
      case QuestionCategory.bonusBilgiler:
        return "BONUS BİLGİ";
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(widget.question.category);
    final categoryTitle = _getCategoryTitle(widget.question.category);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ShakeWidget(
          key: _shakeKey,
          child:
              Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    constraints: const BoxConstraints(maxWidth: 400),
                    // Aspect ratio management via flexible container instead of fixed aspect ratio widget
                    // to prevent overflow on smaller screens
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF9F6), // Cream / Off-White
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. HEADER (Category Indicator)
                          ClipPath(
                            clipper: ZigZagClipper(),
                            child: Container(
                              height: 80,
                              color: categoryColor,
                              alignment: Alignment.center,
                              child: Text(
                                categoryTitle,
                                style: GoogleFonts.alegreyaSansSc(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),

                          // 2. QUESTION BODY
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 100),
                              child: Center(
                                child: Text(
                                  widget.question.text,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.crimsonText(
                                    fontSize: 22,
                                    color: const Color(0xFF2C2C2C), // Dark Ink
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 3. OPTIONS LIST
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child: Column(
                              children: List.generate(
                                widget.question.options.length,
                                (index) {
                                  return _buildOptionButton(index);
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 4. TIMER (Golden Ink Line)
                          AnimatedBuilder(
                            animation: _timerAnimation,
                            builder: (context, child) {
                              // Color transition: Gold -> Orange -> Red
                              Color timerColor;
                              if (_timerAnimation.value > 0.6) {
                                timerColor = const Color(0xFFFFD700); // Gold
                              } else if (_timerAnimation.value > 0.3) {
                                timerColor = Colors.orange;
                              } else {
                                timerColor = Colors.red;
                              }

                              return Container(
                                height: 4,
                                width: double.infinity,
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: _timerAnimation.value,
                                  child: Container(color: timerColor),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .slideY(
                    begin: 0.5,
                    end: 0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: const Duration(milliseconds: 400)),
        ),
      ),
    );
  }

  Widget _buildOptionButton(int index) {
    final isSelected = _selectedIndex == index;
    final isCorrect = index == widget.question.correctIndex;

    OptionState state = OptionState.idle;

    if (_isLocked) {
      if (_isChecking) {
        // Suspense phase
        if (isSelected) {
          state = OptionState.checking;
        } else {
          state = OptionState.idle; // Disable others visually or keep idle
        }
      } else {
        // Result phase
        if (isSelected) {
          state = isCorrect ? OptionState.correct : OptionState.wrong;
        } else if (isCorrect) {
          // Reveal correct answer if we were wrong
          // User requested "If Wrong: Option turns Red".
          // Standard UX: Also show Green on the correct one.
          // OptionButton handles styles.
          state = OptionState.correct;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OptionButton(
        text: widget.question.options[index],
        state: state,
        onTap: () => _handleOptionTap(index),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HELPER WIDGETS
// ---------------------------------------------------------------------------

/// ZigZag / Scalloped Clipper for the header
class ZigZagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 10);

    double x = 0;
    double increment = 10;

    // Create zigzag teeth
    while (x < size.width) {
      path.lineTo(x + increment / 2, size.height);
      path.lineTo(x + increment, size.height - 10);
      x += increment;
    }

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Shake Widget Wrapper
class ShakeWidget extends StatefulWidget {
  final Widget child;

  const ShakeWidget({super.key, required this.child});

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Sine wave for shaking
    _offsetAnimation = Tween<double>(
      begin: 0.0,
      end: 20.0,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      }
    });
  }

  void shake() {
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
      animation: _offsetAnimation,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            math.sin(_controller.value * math.pi * 6) * 10,
            0,
          ), // Horizontal shake
          child: child,
        );
      },
    );
  }
}
