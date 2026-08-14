import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'quote_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Box _quotesBox = Hive.box('quotes_box');
  String _searchQuery = '';

  // Controller para converter o Widget em imagem
  final WidgetsToImageController _imageController = WidgetsToImageController();

  // Função para adicionar uma nova citação
  void _showAddQuoteDialog() {
    final quoteController = TextEditingController();
    final authorController = TextEditingController();
    final bookController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nova Citação',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: quoteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Frase / Passagem',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(
                labelText: 'Autor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bookController,
              decoration: const InputDecoration(
                labelText: 'Livro',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                if (quoteController.text.isNotEmpty) {
                  final newQuote = Quote(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    quote: quoteController.text,
                    author: authorController.text.isEmpty ? 'Desconhecido' : authorController.text,
                    book: bookController.text.isEmpty ? 'Sem título' : bookController.text,
                  );
                  _quotesBox.add(newQuote.toMap());
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Salvar Frase'),
            ),
          ],
        ),
      ),
    );
  }

  // Função para exportar e compartilhar no Instagram
  Future<void> _shareQuoteCard(Quote quote) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preview para Instagram'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Widget visual estilizado
            WidgetsToImage(
              controller: _imageController,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.format_quote, color: Colors.amber, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      '"${quote.quote}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '— ${quote.author}',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      quote.book,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('Compartilhar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
            onPressed: () async {
              final bytes = await _imageController.capture();
              if (bytes != null) {
                final tempDir = await getTemporaryDirectory();
                final file = await File('${tempDir.path}/citacao.png').create();
                await file.writeAsBytes(bytes);
                
                await Share.shareXFiles(
                  [XFile(file.path)],
                  text: 'Citação do livro: ${quote.book}',
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Biblioteca', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Campo de Busca
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por frase, autor ou livro...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Lista de Frases em tempo real
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _quotesBox.listenable(),
              builder: (context, Box box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text('Nenhuma citação cadastrada ainda.'));
                }

                final quotes = box.values
                    .map((item) => Quote.fromMap(Map<dynamic, dynamic>.from(item)))
                    .where((quote) {
                  return quote.quote.toLowerCase().contains(_searchQuery) ||
                      quote.author.toLowerCase().contains(_searchQuery) ||
                      quote.book.toLowerCase().contains(_searchQuery);
                }).toList();

                if (quotes.isEmpty) {
                  return const Center(child: Text('Nenhuma citação encontrada na busca.'));
                }

                return ListView.builder(
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    final quote = quotes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(
                          '"${quote.quote}"',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text('${quote.author} — ${quote.book}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.share, color: Colors.deepPurple),
                          onPressed: () => _shareQuoteCard(quote),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddQuoteDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}