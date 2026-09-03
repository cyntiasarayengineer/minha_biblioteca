import 'package:flutter/material.dart';
import '../models/quote_model.dart';

class QuoteFormModal extends StatefulWidget {
  final Quote? quoteToEdit;
  final Function(String quote, String author, String book) onSave;

  const QuoteFormModal({
    super.key,
    this.quoteToEdit,
    required this.onSave,
  });

  @override
  State<QuoteFormModal> createState() => _QuoteFormModalState();
}

class _QuoteFormModalState extends State<QuoteFormModal> {
  late TextEditingController _quoteController;
  late TextEditingController _authorController;
  late TextEditingController _bookController;

  @override
  void initState() {
    super.initState();
    _quoteController = TextEditingController(text: widget.quoteToEdit?.quote ?? '');
    _authorController = TextEditingController(text: widget.quoteToEdit?.author ?? '');
    _bookController = TextEditingController(text: widget.quoteToEdit?.book ?? '');
  }

  @override
  void dispose() {
    _quoteController.dispose();
    _authorController.dispose();
    _bookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.quoteToEdit != null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
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
                controller: _quoteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Frase / Citação',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Autor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bookController,
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
                onPressed: () {
                  if (_quoteController.text.trim().isEmpty) return;
                  widget.onSave(
                    _quoteController.text.trim(),
                    _authorController.text.trim().isEmpty ? 'Autor Desconhecido' : _authorController.text.trim(),
                    _bookController.text.trim().isEmpty ? 'Sem título' : _bookController.text.trim(),
                  );
                  Navigator.pop(context);
                },
                child: Text(isEditing ? 'Salvar Alterações' : 'Salvar Citação'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}