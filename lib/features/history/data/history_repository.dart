import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../analysis/data/models/analysis_result.dart';
import '../../../core/utils/media_validators.dart';

class HistoryRepository {
  static const String _storageKey = 'history_records';
  final List<AnalysisResult> _history = [];
  bool _isInitialized = false;

  HistoryRepository() {
    init();
  }

  Future<void> init() async {
    if (_isInitialized) return;
    await loadHistory();
  }

  Future<List<AnalysisResult>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(jsonString) as List<dynamic>;
        _history.clear();
        _history.addAll(
          decodedList.map((item) => AnalysisResult.fromJson(item as Map<String, dynamic>)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Failed to load history from SharedPreferences: $e');
    } finally {
      _isInitialized = true;
    }
    return _history;
  }

  Future<void> saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(_history.map((item) => item.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Failed to save history to SharedPreferences: $e');
    }
  }

  Future<void> addScan(AnalysisResult result) async {
    _history.insert(0, result);
    await saveHistory();
  }

  List<AnalysisResult> getHistory({
    MediaTypeCategory? filterCategory,
    String? searchQuery,
  }) {
    return _history.where((item) {
      if (filterCategory != null && item.mediaType != filterCategory) {
        return false;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return item.fileName.toLowerCase().contains(query) ||
            item.classification.toLowerCase().contains(query) ||
            item.id.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await saveHistory();
  }
}
