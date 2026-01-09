import 'game_enums.dart';

class BoardTile {
  final int id;
  final String title;
  final TileType type;
  final int? price; // Satın alma bedeli (Varsa)
  final int? baseRent; // Temel kira bedeli
  final QuestionCategory? questionCategory; // Eğer soru soracaksa kategorisi
  final int upgradeLevel; // 0: Temel, 1-3: Baskı, 4: Cilt
  final bool isUtilities; // Yayınevi/Vakıf mı?

  const BoardTile({
    required this.id,
    required this.title,
    required this.type,
    this.price,
    this.baseRent,
    this.questionCategory,
    this.upgradeLevel = 0,
    this.isUtilities = false,
  });

  // Kira Hesaplama Yardımcısı (İlerde mantık dosyasına taşınabilir ama modelde durması pratik)
  int get currentRent {
    if (baseRent == null) return 0;
    if (isUtilities) return baseRent!; // Utility için farklı mantık olabilir

    // Basit mantık: Her seviye kirayı %50 artırır (Örnek)
    // Gerçek Monopoly mantığında listelenen değerler vardır, burada formüle ediyoruz.
    double multiplier = 1.0 + (upgradeLevel * 0.5);
    return (baseRent! * multiplier).round();
  }
}
