class Quote {
  final String id;
  final String quote;
  final String author;
  final String book;

  Quote({
    required this.id,
    required this.quote,
    required this.author,
    required this.book,
  });

  // Converte a frase para salvar no banco de dados local
  Map<String, String> toMap() {
    return {
      'id': id,
      'quote': quote,
      'author': author,
      'book': book,
    };
  }

  // Recupera a frase do banco de dados local
  factory Quote.fromMap(Map<dynamic, dynamic> map) {
    return Quote(
      id: map['id'] ?? '',
      quote: map['quote'] ?? '',
      author: map['author'] ?? '',
      book: map['book'] ?? '',
    );
  }
}