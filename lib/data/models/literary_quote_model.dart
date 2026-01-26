/// Data model for literary quotes used in the shop
/// Pure Dart - no Flutter dependencies.

class LiteraryQuoteModel {
  final String id;
  final String text;
  final String author;
  final String period;
  final int starCost;

  const LiteraryQuoteModel({
    required this.id,
    required this.text,
    required this.author,
    required this.period,
    required this.starCost,
  });

  factory LiteraryQuoteModel.fromJson(Map<String, dynamic> json) {
    return LiteraryQuoteModel(
      id: json['id'] as String,
      text: json['text'] as String,
      author: json['author'] as String,
      period: json['period'] as String,
      starCost: json['starCost'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'period': period,
      'starCost': starCost,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiteraryQuoteModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LiteraryQuoteModel(id: $id, author: $author, starCost: $starCost)';
  }
}
