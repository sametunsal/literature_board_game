/// Publishing progression levels for a book property.
enum BookLevel { none, telif, baski, cilt }

extension BookLevelExtension on BookLevel {
  int get value {
    switch (this) {
      case BookLevel.none:
        return 0;
      case BookLevel.telif:
        return 1;
      case BookLevel.baski:
        return 2;
      case BookLevel.cilt:
        return 3;
    }
  }

  String get displayName {
    switch (this) {
      case BookLevel.none:
        return 'Yok';
      case BookLevel.telif:
        return 'Telif';
      case BookLevel.baski:
        return 'Baski';
      case BookLevel.cilt:
        return 'Cilt';
    }
  }

  bool get isMaxLevel => this == BookLevel.cilt;

  BookLevel get nextLevel {
    switch (this) {
      case BookLevel.none:
        return BookLevel.telif;
      case BookLevel.telif:
        return BookLevel.baski;
      case BookLevel.baski:
        return BookLevel.cilt;
      case BookLevel.cilt:
        return BookLevel.cilt;
    }
  }
}
