/// Model representing a literary quote that can be collected in the game
class Quote {
  /// Unique identifier for the quote
  final String id;

  /// The quote text
  final String text;

  /// Author of the quote
  final String author;

  /// Literary era/period (Dönem) - e.g., "Divan Edebiyatı", "Tanzimat", "Servet-i Fünun"
  final String era;

  /// Price in stars to purchase the quote
  final int price;

  /// Category the quote belongs to
  final String category;

  const Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.era,
    required this.price,
    required this.category,
  });

  /// Creates a copy of this quote with optional new values
  Quote copyWith({
    String? id,
    String? text,
    String? author,
    String? era,
    int? price,
    String? category,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      era: era ?? this.era,
      price: price ?? this.price,
      category: category ?? this.category,
    );
  }

  /// Creates a Quote from JSON
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      text: json['text'] as String,
      author: json['author'] as String,
      era: json['era'] as String,
      price: json['price'] as int,
      category: json['category'] as String,
    );
  }

  /// Converts this Quote to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'era': era,
      'price': price,
      'category': category,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quote && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Quote(id: $id, text: $text, author: $author, era: $era, price: $price, category: $category)';
  }
}
