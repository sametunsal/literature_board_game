import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tahmini satır sayısı — soru metni seçiminde uzun (çok satırlı) soruları azaltmak için.
class QuestionLineEstimator {
  QuestionLineEstimator._();

  /// [maxWidth] içinde, [fontSize] ve [height] ile kaç satıra düştüğünü tahmin eder.
  static int estimateLines(
    String text,
    double maxWidth, {
    double fontSize = 18,
    double height = 1.38,
  }) {
    if (text.isEmpty) return 0;
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.crimsonText(
          fontSize: fontSize,
          height: height,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: maxWidth);
    return tp.computeLineMetrics().length;
  }
}
