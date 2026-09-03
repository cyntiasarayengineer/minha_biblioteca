import 'package:flutter/material.dart';
import '../services/ocr_service.dart';

class QuoteFormModal extends StatefulWidget {
  final String? initialQuote;
  final String? initialAuthor;
  final String? initialBook;
  final Function(String quote, String author, String book) onSave;

  const QuoteFormModal({
    super.key,
    this.initialQuote,
    this.initialAuthor,
    this.initialBook,
    required this.onSave,
  });

  @override
  State<QuoteFormModal> createState() => _QuoteFormModalState();
}

class _QuoteFormModalState extends State<QuoteFormModal> {
  late TextEditingController _quoteController;
  late TextEditingController _authorController;
  late TextEditingController _bookController;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _quoteController = TextEditingController(text: widget.initialQuote ?? '');
    _authorController = TextEditingController(text: widget.initialAuthor ?? '');
    _bookController = TextEditingController(text: widget.initialBook ?? '');
  }

  @override
  void dispose() {
    _quoteController.dispose();
    _authorController.dispose();
    _bookController.dispose();
    super.dispose();
  }

  Future<void> _scanTextFromCamera() async {
    setState(() => _isScanning = true);
    try {
      final scannedText = await OcrService.scanTextFromCamera();
      if (scannedText != null && scannedText.isNotEmpty) {
        setState(() {
          if (_quoteController.text.isNotEmpty) {
            _quoteController.text += ' $scannedText';
          } else {
            _quoteController.text = scannedText;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível ler o texto da imagem.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.initialQuote == null ? 'Nova Citação' : 'Editar Citação',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _quoteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Citação *',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _isScanning ? null : _scanTextFromCamera,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 90,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.deepPurple.shade200),
                  ),
                  child: _isScanning
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_rounded, color: Colors.deepPurple),
                            SizedBox(height: 4),
                            Text(
                              'Escanear',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _authorController,
            decoration: const InputDecoration(
              labelText: 'Autor *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bookController,
            decoration: const InputDecoration(
              labelText: 'Livro',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A148C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              if (_quoteController.text.trim().isEmpty ||
                  _authorController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, preencha os campos obrigatórios.'),
                  ),
                );
                return;
              }

              widget.onSave(
                _quoteController.text.trim(),
                _authorController.text.trim(),
                _bookController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: Text(widget.initialQuote == null ? 'Salvar' : 'Atualizar'),
          ),
        ],
      ),
    );
  }
}