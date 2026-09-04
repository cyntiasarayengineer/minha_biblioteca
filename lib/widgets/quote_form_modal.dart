import 'package:flutter/material.dart';
import '../services/ocr_service.dart';

class QuoteFormModal extends StatefulWidget {
  final String? initialQuote;
  final String? initialAuthor;
  final String? initialBook;
  final String? initialPage;
  final String? initialTag;
  final Function(String quote, String author, String book, String? page, String? tag) onSave;

  const QuoteFormModal({
    super.key,
    this.initialQuote,
    this.initialAuthor,
    this.initialBook,
    this.initialPage,
    this.initialTag,
    required this.onSave,
  });

  @override
  State<QuoteFormModal> createState() => _QuoteFormModalState();
}

class _QuoteFormModalState extends State<QuoteFormModal> {
  late TextEditingController _quoteController;
  late TextEditingController _authorController;
  late TextEditingController _bookController;
  late TextEditingController _pageController;
  late TextEditingController _tagController;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _quoteController = TextEditingController(text: widget.initialQuote ?? '');
    _authorController = TextEditingController(text: widget.initialAuthor ?? '');
    _bookController = TextEditingController(text: widget.initialBook ?? '');
    _pageController = TextEditingController(text: widget.initialPage ?? '');
    _tagController = TextEditingController(text: widget.initialTag ?? '');
  }

  @override
  void dispose() {
    _quoteController.dispose();
    _authorController.dispose();
    _bookController.dispose();
    _pageController.dispose();
    _tagController.dispose();
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
          const SnackBar(content: Text('Não foi possível ler o texto da imagem.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A148C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: Color(0xFF4A148C), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.initialQuote == null ? 'Nova citação' : 'Editar citação',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Guarde um trecho que vale revisitar.',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Autor e Livro lado a lado
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Autor', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _authorController,
                          decoration: _inputDecoration('Ex.: Clarice Lispector'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Livro', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _bookController,
                          decoration: _inputDecoration('Ex.: A Hora da Estrela'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Citação com Botão Escanear
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Citação', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  InkWell(
                    onTap: _isScanning ? null : _scanTextFromCamera,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          _isScanning
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4A148C)),
                                )
                              : const Icon(Icons.camera_alt_outlined, size: 15, color: Color(0xFF4A148C)),
                          const SizedBox(width: 4),
                          const Text(
                            'Escanear página',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4A148C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _quoteController,
                maxLines: 4,
                decoration: _inputDecoration('Escreva o trecho aqui ou escaneie a página...'),
              ),
              const SizedBox(height: 16),

              // Etiquetas e Página lado a lado
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Etiquetas', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _tagController,
                          decoration: _inputDecoration('Ex.: Romance, Ficção'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Página', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _pageController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Ex.: 42'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A148C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_quoteController.text.trim().isEmpty ||
                        _authorController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, preencha os campos obrigatórios.')),
                      );
                      return;
                    }

                    widget.onSave(
                      _quoteController.text.trim(),
                      _authorController.text.trim(),
                      _bookController.text.trim(),
                      _pageController.text.trim().isEmpty ? null : _pageController.text.trim(),
                      _tagController.text.trim().isEmpty ? null : _tagController.text.trim(),
                    );
                    Navigator.pop(context);
                  },
                  child: Text(
                    widget.initialQuote == null ? 'Salvar citação' : 'Atualizar citação',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}