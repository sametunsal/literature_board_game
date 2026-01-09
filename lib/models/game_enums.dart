enum TileType {
  start,
  property, // Kitap (Satın alınabilir)
  publisher, // Yayınevi
  chance, // Şans Kartı
  fate, // Kader Kartı
  libraryWatch, // Kütüphane Nöbeti (Ceza)
  autographDay, // İmza Günü (Güvenli)
  bankruptcyRisk, // İflas Riski (Ceza)
  writingSchool, // Yazarlık Okulu
  educationFoundation, // Eğitim Vakfı
  incomeTax, // Gelir Vergisi
  writingTax, // Yazarlık Vergisi
}

enum QuestionCategory {
  benKimim,
  turkEdebiyatindaIlkler,
  edebiyatAkimlari,
  edebiSanatlar,
  eserKarakter,
  cumhuriyetDonemi, // Yeni
  divanEdebiyati, // Yeni
  halkEdebiyati, // Yeni
  genelKultur, // Yeni
}

enum CardType { sans, kader }

enum GamePhase { setup, rollingForOrder, playing, gameOver }
