import 'package:flutter/material.dart';

class GameTheme {
  // --- Renk Paleti ---
  static const Color woodDark = Color(0xFF3E2723); // Maun Çerçeve
  static const Color woodLight = Color(0xFF5D4037);
  static const Color feltGreen = Color(
    0xFF2E7D32,
  ); // Klasik Çuha Yeşili (Orta Alan)
  static const Color parchment = Color(0xFFFFF3E0); // Parşömen (Kutucuklar)
  static const Color backgroundTable = Color(0xFF263238); // Koyu Masa Rengi

  static const Color textPrimary = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF455A64);

  // --- Dekorasyonlar ---

  // 1. Oyun Masası (Deri/Ahşap Hissi)
  static BoxDecoration tableDecoration = BoxDecoration(
    gradient: RadialGradient(
      colors: [Color(0xFF455A64), Color(0xFF263238)],
      radius: 1.2,
      center: Alignment.center,
    ),
  );

  // 2. Oyun Tahtası (Fiziksel Karton Hissi)
  static BoxDecoration boardDecoration = BoxDecoration(
    color: parchment,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.6),
        blurRadius: 30,
        spreadRadius: 5,
        offset: Offset(0, 10),
      ), // Masaya düşen gölge
    ],
    border: Border.all(color: woodDark, width: 12), // Kalın Ahşap Çerçeve
  );

  // 3. Kutucuk Stili (Kart Hissi)
  static BoxDecoration tileDecoration(bool isCorner) => BoxDecoration(
    color: Colors.white,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, Color(0xFFF5F5F5)], // Hafif kağıt dokusu
    ),
    border: Border.all(color: Colors.black12, width: 0.5),
    // Köşeler biraz daha belirgin olsun
  );

  // 4. Orta Alan (Çuha Kumaş Hissi)
  static BoxDecoration centerAreaDecoration = BoxDecoration(
    color: feltGreen,
    borderRadius: BorderRadius.circular(4),
    boxShadow: [
      // Flutter'da BoxShadow inset parametresi yoktur.
      // Derinlik hissi için iç kenar gibi davranan bir gradient veya border kullanabiliriz.
      // Şimdilik standart gölge ile devam ediyoruz.
      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2)),
    ],
  );

  // --- Compatibility / Legacy Support (Eski widget'lar kırılmasın diye) ---
  static const Color primaryText = textPrimary;
  static const Color accentRed = Color(0xFFE57373);
  static const Color accentGold = Color(0xFFFFD54F);
  static const Color tileBorder = woodLight;

  static const TextStyle tileTitle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle tilePrice = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
  );
}
