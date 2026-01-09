import 'game_enums.dart';

class BoardTile {
  final int id;
  final String title;
  final TileType type;
  final int? price;
  final int? baseRent; // Temel Kira
  final QuestionCategory? category;
  final bool isUtility; // Yayınevi/Vakıf mı? (Zar * 15 kuralı için)
  final int upgradeLevel; // 0:Yok, 1-3:Baskı, 4:Cilt

  const BoardTile({
    required this.id,
    required this.title,
    required this.type,
    this.price,
    this.baseRent,
    this.category,
    this.isUtility = false,
    this.upgradeLevel = 0,
  });

  BoardTile copyWith({int? upgradeLevel}) {
    return BoardTile(
      id: id,
      title: title,
      type: type,
      price: price,
      baseRent: baseRent,
      category: category,
      isUtility: isUtility,
      upgradeLevel: upgradeLevel ?? this.upgradeLevel,
    );
  }
}
