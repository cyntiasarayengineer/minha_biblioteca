class Quote {
  final String id;
  final String quote;
  final String author;
  final String book;
  final String? page;
  final String? tag;
  final DateTime createdAt;

  Quote({
    required this.id,
    required this.quote,
    required this.author,
    required this.book,
    this.page,
    this.tag,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quote': quote,
      'author': author,
      'book': book,
      'page': page,
      'tag': tag,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Quote.fromMap(Map<String, dynamic> map) {
    return Quote(
      id: map['id'] ?? '',
      quote: map['quote'] ?? '',
      author: map['author'] ?? '',
      book: map['book'] ?? '',
      page: map['page'],
      tag: map['tag'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}