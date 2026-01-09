import 'package:flutter/material.dart';

class GameTheme {
  // Renk Paleti (Edebiyat / Kütüphane Estetiği)
  static const Color backgroundTable = Color(0xFF263238); // Koyu Maun Masa
  static const Color boardBackground = Color(0xFFF0E6D2); // Parşömen Kağıdı
  static const Color primaryText = Color(0xFF4E342E); // Mürekkep Rengi

  static const Color accentGold = Color(0xFFFFD54F); // Vurgu (Yıldızlar)
  static const Color accentRed = Color(0xFFE57373); // Ceza
  static const Color accentGreen = Color(0xFF81C784); // Onay/Para

  static const Color tileBorder = Color(0xFF5D4037); // Kutu Çerçevesi

  // Text Styles
  static const TextStyle tileTitle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.bold,
    color: primaryText,
    letterSpacing: -0.2,
  );

  static const TextStyle tilePrice = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
  );

  // Decorations
  static BoxDecoration boardDecoration = BoxDecoration(
    color: boardBackground,
    borderRadius: BorderRadius.circular(4),
    border: Border.all(color: Color(0xFF3E2723), width: 8), // Deri Cilt Çerçeve
    boxShadow: [
      BoxShadow(
        color: Colors.black87,
        blurRadius: 20,
        spreadRadius: 5,
        offset: Offset(0, 10),
      ),
    ],
  );
}
