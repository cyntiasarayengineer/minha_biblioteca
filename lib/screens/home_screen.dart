import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/quote_model.dart';
import '../services/quote_storage_service.dart';
import '../widgets/quote_card.dart';
import '../widgets/quote_form_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final WidgetsToImageController _imageController = WidgetsToImageController();
  final QuoteStorageService _storageService = QuoteStorageService();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFormModal({Quote? quoteToEdit, dynamic quoteKey}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return QuoteFormModal(
          quoteToEdit: quoteToEdit,
          onSave: (quoteText, author, book) async {
            if (quoteToEdit != null && quoteKey != null) {
              final updated = Quote(
                id: quoteToEdit.id,
                quote: quoteText,
                author: author,
                book: book,
                createdAt: quoteToEdit.createdAt,
              );
              await _storageService.updateQuote(quoteKey, updated);
            } else {
              final newQuote = Quote(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                quote: quoteText,
                author: author,
                book: book,
              );
              await _storageService.addQuote(newQuote);
            }
          },
        );
      },
    );
  }

  void _confirmDelete(dynamic key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Citação'),
        content: const Text('Tem certeza que deseja apagar esta citação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              await _storageService.deleteQuote(key);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showSharePreview(Quote quote) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16),
          title: const Text('Preview para Instagram', textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WidgetsToImage(
                  controller: _imageController,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2630),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.format_quote, color: Colors.amber, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          '"${quote.quote}"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '— ${quote.author}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (quote.book.isNotEmpty && quote.book != 'Sem título')
                          Text(
                            quote.book,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final bytes = await _imageController.capture();
                if (bytes != null) {
                  final tempDir = await getTemporaryDirectory();
                  final file = await File('${tempDir.path}/citacao_instagram.png').create();
                  await file.writeAsBytes(bytes);

                  await Share.shareXFiles(
                    [XFile(file.path)],
                    text: 'Citação do livro: ${quote.book}',
                  );
                }
              },
              icon: const Icon(Icons.share),
              label: const Text('Compartilhar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Biblioteca'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por frase, autor ou livro...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box(QuoteStorageService.boxName).listenable(),
                builder: (context, Box box, _) {
                  if (box.isEmpty) {
                    return const Center(child: Text('Nenhuma citação cadastrada ainda.'));
                  }

                  final allQuotes = <MapEntry<dynamic, Quote>>[];
                  for (var key in box.keys) {
                    final item = box.get(key);
                    if (item != null) {
                      final quote = Quote.fromMap(Map<String, dynamic>.from(item));
                      allQuotes.add(MapEntry(key, quote));
                    }
                  }

                  // Ordena por data (mais recentes primeiro)
                  allQuotes.sort((a, b) => b.value.createdAt.compareTo(a.value.createdAt));

                  // Aplica o filtro de busca
                  final filtered = allQuotes.where((entry) {
                    final q = entry.value;
                    return q.quote.toLowerCase().contains(_searchQuery) ||
                        q.author.toLowerCase().contains(_searchQuery) ||
                        q.book.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('Nenhuma citação encontrada.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 90),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final entry = filtered[index];
                      final key = entry.key;
                      final quote = entry.value;

                      return QuoteCard(
                        quote: quote,
                        onEdit: () => _openFormModal(quoteToEdit: quote, quoteKey: key),
                        onDelete: () => _confirmDelete(key),
                        onShare: () => _showSharePreview(quote),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () => _openFormModal(),
        child: const Icon(Icons.add),
      ),
    );
  }
}