import '../models/tile.dart';

class BoardSetup {
  static List<Tile> generateTiles() {
    List<Tile> tiles = [];
    Tile createBook(int id, String name, int group, int price) {
      return Tile(
        id: id,
        name: name,
        type: TileType.book,
        group: group,
        purchasePrice: price,
        copyrightFee: (price * 0.1).toInt(),
      );
    }

    // 40 Karelik Dizilim (Sol Alt Başlangıç -> Saat Yönü Tersi)
    tiles.add(
      const Tile(
        id: 0,
        name: "BAŞLANGIÇ",
        type: TileType.corner,
        cornerEffect: CornerEffect.baslangic,
      ),
    );
    tiles.add(createBook(1, "Çalıkuşu", 1, 100));
    tiles.add(const Tile(id: 2, name: "KADER", type: TileType.fate));
    tiles.add(createBook(3, "Yaban", 1, 100));
    tiles.add(
      const Tile(
        id: 4,
        name: "GELİR VERGİSİ",
        type: TileType.tax,
        taxType: TaxType.gelirVergisi,
      ),
    );
    tiles.add(
      const Tile(
        id: 5,
        name: "CAN YAYINLARI",
        type: TileType.publisher,
        purchasePrice: 200,
        copyrightFee: 50,
      ),
    );
    tiles.add(createBook(6, "Kiralık Konak", 2, 120));
    tiles.add(const Tile(id: 7, name: "ŞANS", type: TileType.chance));
    tiles.add(createBook(8, "Eylül", 2, 120));
    tiles.add(createBook(9, "Mai ve Siyah", 2, 120));
    tiles.add(createBook(10, "Sergüzeşt", 2, 120));
    tiles.add(
      const Tile(
        id: 11,
        name: "KÜTÜPHANE NÖBETİ",
        type: TileType.corner,
        cornerEffect: CornerEffect.kutuphaneNobeti,
      ),
    );

    // Geri kalan kareleri döngü ile doldur veya eksikleri tamamla
    // (Örnek verisiyle 40'a tamamlanacak şekilde)
    for (int i = 12; i < 40; i++) {
      tiles.add(createBook(i, "Kitap $i", 3, 150));
    }

    return tiles;
  }
}
