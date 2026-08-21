import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/quote_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final WidgetsToImageController _imageController = WidgetsToImageController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Janela para Criar ou Editar uma Citação
  void _showQuoteFormModal(BuildContext context, {Quote? quoteToEdit, dynamic quoteKey}) {
    final quoteController = TextEditingController(text: quoteToEdit?.quote ?? '');
    final authorController = TextEditingController(text: quoteToEdit?.author ?? '');
    final bookController = TextEditingController(text: quoteToEdit?.book ?? '');

    final isEditing = quoteToEdit != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Editar Citação' : 'Nova Citação',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quoteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Frase / Citação',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(
                  labelText: 'Autor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bookController,
                decoration: const InputDecoration(
                  labelText: 'Livro (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (quoteController.text.trim().isEmpty) return;

                  final box = Hive.box('quotes_box');

                  if (isEditing && quoteKey != null) {
                    // Atualiza a citação existente
                    final updatedQuote = Quote(
                      id: quoteToEdit.id,
                      quote: quoteController.text.trim(),
                      author: authorController.text.trim().isEmpty
                          ? 'Autor Desconhecido'
                          : authorController.text.trim(),
                      book: bookController.text.trim().isEmpty
                          ? 'Sem título'
                          : bookController.text.trim(),
                    );
                    await box.put(quoteKey, updatedQuote.toMap());
                  } else {
                    // Cria uma nova citação
                    final newQuote = Quote(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      quote: quoteController.text.trim(),
                      author: authorController.text.trim().isEmpty
                          ? 'Autor Desconhecido'
                          : authorController.text.trim(),
                      book: bookController.text.trim().isEmpty
                          ? 'Sem título'
                          : bookController.text.trim(),
                    );
                    await box.add(newQuote.toMap());
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(isEditing ? 'Salvar Alterações' : 'Salvar Citação'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Diálogo para Confirmar Exclusão
  void _confirmDelete(BuildContext context, dynamic key) {
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
              final box = Hive.box('quotes_box');
              await box.delete(key);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  // Modal para Pré-visualização do Card do Instagram
  void _showSharePreview(BuildContext context, Quote quote) {
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
                        const Icon(
                          Icons.format_quote,
                          color: Colors.amber,
                          size: 40,
                        ),
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
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box('quotes_box').listenable(),
                builder: (context, Box box, _) {
                  if (box.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma citação cadastrada ainda.'),
                    );
                  }

                  final keys = box.keys.toList();
                  final filteredKeys = keys.where((key) {
                    final item = box.get(key);
                    final quote = Quote.fromMap(Map<String, dynamic>.from(item));
                    return quote.quote.toLowerCase().contains(_searchQuery) ||
                        quote.author.toLowerCase().contains(_searchQuery) ||
                        quote.book.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredKeys.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma citação encontrada.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 90),
                    itemCount: filteredKeys.length,
                    itemBuilder: (context, index) {
                      final key = filteredKeys[index];
                      final item = box.get(key);
                      final quote = Quote.fromMap(Map<String, dynamic>.from(item));

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '"${quote.quote}"',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${quote.author} — ${quote.book}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                        onPressed: () {
                                          _showQuoteFormModal(
                                            context,
                                            quoteToEdit: quote,
                                            quoteKey: key,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                        onPressed: () {
                                          _confirmDelete(context, key);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.share, size: 20, color: Colors.deepPurple),
                                        onPressed: () {
                                          _showSharePreview(context, quote);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () => _showQuoteFormModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}