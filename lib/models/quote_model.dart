class Quote {
  final String id;
  final String quote;
  final String author;
  final String book;
  final DateTime createdAt;

  Quote({
    required this.id,
    required this.quote,
    required this.author,
    required this.book,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quote': quote,
      'author': author,
      'book': book,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Quote.fromMap(Map<dynamic, dynamic> map) {
    return Quote(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      quote: map['quote'] ?? '',
      author: map['author'] ?? 'Autor Desconhecido',
      book: map['book'] ?? 'Sem título',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(), // Se for uma frase antiga sem data, atribui a data atual!
    );
  }
}