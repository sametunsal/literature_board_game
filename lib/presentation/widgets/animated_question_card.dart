import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/question.dart';
import '../../models/game_enums.dart';
import '../../core/constants/game_constants.dart';
import 'flying_star.dart';

/// Dikey soru kartı — ekrana **sığdırılır** (FittedBox), kaydırma yok.
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
  late AnimationController _entrance;
  late Animation<double> _fade;
  late Animation<double> _scale;
  
  // WWTBAM style animation controllers
  late AnimationController _selectionPulse;
  late Animation<double> _pulseAnimation;
  
  int? selectedIndex;
  bool hasAnswered = false;
  bool isRevealing = false; // True after selection pulse, before showing result
  bool showStarEffect = false; // Show flying star effect for correct answer

  /// Tasarım referans boyutu (portre); FittedBox ekrana ölçekler.
  static const double _designW = 320;
  static const double _designH = 580;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic),
    );
    
    // Selection pulse animation (orange/yellow blink)
    _selectionPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _selectionPulse, curve: Curves.easeInOut),
    );
    
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _entrance.forward();
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _selectionPulse.dispose();
    super.dispose();
  }

  void _handleAnswer(int index, bool isCorrect) {
    if (hasAnswered) return;
    
    setState(() {
      selectedIndex = index;
      hasAnswered = true;
    });
    
    // Start selection pulse animation (orange blink)
    _selectionPulse.repeat(reverse: true);
    
    // After 900ms, stop pulsing and reveal result
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _selectionPulse.stop();
      setState(() {
        isRevealing = true;
        // Show star effect for correct answers
        if (isCorrect) {
          showStarEffect = true;
        }
      });
      
      // After revealing + star animation, callback
      final callbackDelay = isCorrect ? 1600 : 800;
      Future.delayed(Duration(milliseconds: callbackDelay), () {
        if (mounted) widget.onAnswer(isCorrect);
      });
    });
  }
  
  int _getStarReward() {
    switch (widget.question.difficulty) {
      case 'easy':
        return GameConstants.rewardEasy;
      case 'medium':
        return GameConstants.rewardMedium;
      case 'hard':
        return GameConstants.rewardHard;
      default:
        return GameConstants.rewardMedium;
    }
  }

  BoxDecoration _optionDecoration({
    required bool showCorrect,
    required bool showWrong,
    required bool showSelected,
    required double pulseValue,
  }) {
    // WWTBAM Phase 1: Selected (orange/yellow pulsing)
    if (showSelected && !showCorrect && !showWrong) {
      final orangeAlpha = 0.3 + (pulseValue * 0.4);
      return BoxDecoration(
        color: Color.lerp(
          const Color(0xFFFFF8E1),
          const Color(0xFFFFE0B2),
          pulseValue,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color.lerp(
            const Color(0xFFFF9800),
            const Color(0xFFF57C00),
            pulseValue,
          )!,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: orangeAlpha),
            blurRadius: 8 + (pulseValue * 4),
            spreadRadius: pulseValue * 2,
          ),
        ],
      );
    }
    
    // WWTBAM Phase 2: Correct (green)
    if (showCorrect) {
      return BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2E7D32), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      );
    }
    
    // WWTBAM Phase 2: Wrong (red)
    if (showWrong) {
      return BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC62828), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      );
    }
    
    // Default state
    return BoxDecoration(
      color: const Color(0xFFFFFBF5),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: const Color(0xFF8D6E63).withValues(alpha: 0.5),
        width: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final safe = mq.padding;
    final availW = size.width - safe.horizontal - 12;
    final availH = size.height - safe.vertical - 12;

    final categoryLabel = widget.question.category.displayName.toUpperCase();
    final optCount = widget.question.options.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Question card
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: math.max(0, availW),
                      maxHeight: math.max(0, availH),
                    ),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: _designW,
                        height: _designH,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, _) => _CardBody(
                            categoryLabel: categoryLabel,
                            question: widget.question,
                            optCount: optCount,
                            hasAnswered: hasAnswered,
                            isRevealing: isRevealing,
                            selectedIndex: selectedIndex,
                            pulseValue: _pulseAnimation.value,
                            optionDecoration: _optionDecoration,
                            onTap: _handleAnswer,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Flying star effect overlay for correct answers
            if (showStarEffect)
              FlyingStar(
                starCount: _getStarReward(),
                onComplete: () {
                  if (mounted) {
                    setState(() {
                      showStarEffect = false;
                    });
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.categoryLabel,
    required this.question,
    required this.optCount,
    required this.hasAnswered,
    required this.isRevealing,
    required this.selectedIndex,
    required this.pulseValue,
    required this.optionDecoration,
    required this.onTap,
  });

  final String categoryLabel;
  final Question question;
  final int optCount;
  final bool hasAnswered;
  final bool isRevealing;
  final int? selectedIndex;
  final double pulseValue;
  final BoxDecoration Function({
    required bool showCorrect,
    required bool showWrong,
    required bool showSelected,
    required double pulseValue,
  }) optionDecoration;
  final void Function(int index, bool isCorrect) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF5D4037), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF5D4037),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: AutoSizeText(
              categoryLabel,
              textAlign: TextAlign.center,
              maxLines: 2,
              minFontSize: 9,
              maxFontSize: 15,
              stepGranularity: 0.5,
              wrapWords: true,
              style: GoogleFonts.merriweather(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFFECB3),
                height: 1.15,
              ),
            ),
          ),
          Expanded(
            flex: 38,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD7CCC8)),
                ),
                child: Center(
                  child: AutoSizeText(
                    question.text,
                    textAlign: TextAlign.center,
                    maxLines: 12,
                    minFontSize: 11,
                    maxFontSize: 20,
                    stepGranularity: 0.5,
                    wrapWords: true,
                    style: GoogleFonts.merriweather(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF212121),
                      height: 1.38,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: const Color(0xFFBCAAA4)),
          ),
          Expanded(
            flex: 62,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Column(
                children: [
                  for (var index = 0; index < optCount; index++) ...[
                    if (index > 0) const SizedBox(height: 6),
                    Expanded(
                      child: _OptionTile(
                        index: index,
                        label: question.options[index],
                        isCorrect: index == question.correctIndex,
                        isSelected: selectedIndex == index,
                        hasAnswered: hasAnswered,
                        isRevealing: isRevealing,
                        pulseValue: pulseValue,
                        decoration: optionDecoration,
                        onTap: onTap,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.index,
    required this.label,
    required this.isCorrect,
    required this.isSelected,
    required this.hasAnswered,
    required this.isRevealing,
    required this.pulseValue,
    required this.decoration,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool isCorrect;
  final bool isSelected;
  final bool hasAnswered;
  final bool isRevealing;
  final double pulseValue;
  final BoxDecoration Function({
    required bool showCorrect,
    required bool showWrong,
    required bool showSelected,
    required double pulseValue,
  }) decoration;
  final void Function(int index, bool isCorrect) onTap;

  @override
  Widget build(BuildContext context) {
    // WWTBAM style: only show correct/wrong AFTER reveal phase
    final showCorrect = isRevealing && isCorrect;
    final showWrong = isRevealing && isSelected && !isCorrect;
    // Show selection pulse during wait phase (before reveal)
    final showSelected = hasAnswered && isSelected && !isRevealing;

    // Text color based on state
    Color textColor;
    if (showCorrect) {
      textColor = const Color(0xFF1B5E20);
    } else if (showWrong) {
      textColor = const Color(0xFFB71C1C);
    } else if (showSelected) {
      textColor = const Color(0xFFE65100); // Orange during selection
    } else {
      textColor = const Color(0xFF3E2723);
    }

    return AnimatedScale(
      scale: showSelected ? (1.0 + pulseValue * 0.02) : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasAnswered ? null : () => onTap(index, isCorrect),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            decoration: decoration(
              showCorrect: showCorrect,
              showWrong: showWrong,
              showSelected: showSelected,
              pulseValue: pulseValue,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: showCorrect
                              ? const Color(0xFF1B5E20)
                              : showWrong
                                  ? const Color(0xFFB71C1C)
                                  : showSelected
                                      ? const Color(0xFFE65100)
                                      : const Color(0xFF5D4037),
                        ),
                        child: Text(String.fromCharCode(65 + index)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: AutoSizeText(
                      label,
                      textAlign: TextAlign.left,
                      maxLines: 3,
                      minFontSize: 11,
                      maxFontSize: 18,
                      stepGranularity: 0.5,
                      wrapWords: true,
                      style: GoogleFonts.merriweather(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        height: 1.22,
                      ),
                    ),
                  ),
                  // Show result icon after reveal
                  if (showCorrect || showWrong)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        showCorrect ? Icons.check_circle : Icons.cancel,
                        color: showCorrect
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
