import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/literary_quote_model.dart';

/// Repository for loading and managing literary quotes
class QuoteRepository {
  List<LiteraryQuoteModel>? _cachedQuotes;

  /// Load all quotes from JSON asset
  Future<List<LiteraryQuoteModel>> getAllQuotes() async {
    if (_cachedQuotes != null) return _cachedQuotes!;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/literary_quotes.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedQuotes = jsonList
          .map((json) => LiteraryQuoteModel.fromJson(json))
          .toList();
      return _cachedQuotes!;
    } catch (e) {
      print('Error loading quotes: $e');
      return [];
    }
  }

  /// Get quotes by period
  Future<List<LiteraryQuoteModel>> getQuotesByPeriod(String period) async {
    final allQuotes = await getAllQuotes();
    return allQuotes.where((q) => q.period == period).toList();
  }

  /// Get quotes affordable with given stars
  Future<List<LiteraryQuoteModel>> getAffordableQuotes(int stars) async {
    final allQuotes = await getAllQuotes();
    return allQuotes.where((q) => q.starCost <= stars).toList();
  }

  /// Get quote by ID
  Future<LiteraryQuoteModel?> getQuoteById(String id) async {
    final allQuotes = await getAllQuotes();
    try {
      return allQuotes.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all unique periods
  Future<List<String>> getAllPeriods() async {
    final allQuotes = await getAllQuotes();
    return allQuotes.map((q) => q.period).toSet().toList();
  }

  /// Clear cache (for testing or refresh)
  void clearCache() {
    _cachedQuotes = null;
  }
}
