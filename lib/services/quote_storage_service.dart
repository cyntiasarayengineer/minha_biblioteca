import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/quote_model.dart';

class QuoteStorageService {
  static const String boxName = 'quotes_box';

  Box get _box => Hive.box(boxName);

  ValueNotifier<List<MapEntry<dynamic, Quote>>> get quotesNotifier {
    return ValueNotifier(_getSortedQuotes());
  }

  // Retorna todas as citações ordenadas pelas mais recentes primeiro
  List<MapEntry<dynamic, Quote>> _getSortedQuotes() {
    final keys = _box.keys.toList();
    final list = <MapEntry<dynamic, Quote>>[];

    for (var key in keys) {
      final item = _box.get(key);
      if (item != null) {
        final quote = Quote.fromMap(Map<String, dynamic>.from(item));
        list.add(MapEntry(key, quote));
      }
    }

    // Ordena do mais recente para o mais antigo
    list.sort((a, b) => b.value.createdAt.compareTo(a.value.createdAt));
    return list;
  }

  // Adiciona nova citação
  Future<void> addQuote(Quote quote) async {
    await _box.add(quote.toMap());
  }

  // Atualiza citação existente
  Future<void> updateQuote(dynamic key, Quote quote) async {
    await _box.put(key, quote.toMap());
  }

  // Exclui citação
  Future<void> deleteQuote(dynamic key) async {
    await _box.delete(key);
  }
}