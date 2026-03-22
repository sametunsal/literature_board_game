import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/question.dart';
import '../../models/game_enums.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _entrance;
  late Animation<double> _fade;
  late Animation<double> _scale;
  int? selectedIndex;
  bool hasAnswered = false;

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
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _entrance.forward();
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _handleAnswer(int index, bool isCorrect) {
    if (hasAnswered) return;
    setState(() {
      selectedIndex = index;
      hasAnswered = true;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) widget.onAnswer(isCorrect);
    });
  }

  BoxDecoration _optionDecoration({
    required bool showCorrect,
    required bool showWrong,
  }) {
    if (showCorrect) {
      return BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2E7D32), width: 2),
      );
    }
    if (showWrong) {
      return BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC62828), width: 2),
      );
    }
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
        child: Center(
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
                    child: _CardBody(
                      categoryLabel: categoryLabel,
                      question: widget.question,
                      optCount: optCount,
                      hasAnswered: hasAnswered,
                      selectedIndex: selectedIndex,
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
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.categoryLabel,
    required this.question,
    required this.optCount,
    required this.hasAnswered,
    required this.selectedIndex,
    required this.optionDecoration,
    required this.onTap,
  });

  final String categoryLabel;
  final Question question;
  final int optCount;
  final bool hasAnswered;
  final int? selectedIndex;
  final BoxDecoration Function({
    required bool showCorrect,
    required bool showWrong,
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
    required this.decoration,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool isCorrect;
  final bool isSelected;
  final bool hasAnswered;
  final BoxDecoration Function({
    required bool showCorrect,
    required bool showWrong,
  }) decoration;
  final void Function(int index, bool isCorrect) onTap;

  @override
  Widget build(BuildContext context) {
    final showCorrect = hasAnswered && isCorrect;
    final showWrong = hasAnswered && isSelected && !isCorrect;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasAnswered ? null : () => onTap(index, isCorrect),
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: decoration(
            showCorrect: showCorrect,
            showWrong: showWrong,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: showCorrect
                            ? const Color(0xFF1B5E20)
                            : showWrong
                                ? const Color(0xFFB71C1C)
                                : const Color(0xFF5D4037),
                      ),
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
                      color: showCorrect
                          ? const Color(0xFF1B5E20)
                          : showWrong
                              ? const Color(0xFFB71C1C)
                              : const Color(0xFF3E2723),
                      height: 1.22,
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
