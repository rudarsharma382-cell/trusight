import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../analysis/data/models/analysis_result.dart';
import '../../data/history_repository.dart';
import '../../../../core/utils/media_validators.dart';

class HistoryState {
  final List<AnalysisResult> items;
  final MediaTypeCategory? selectedCategory;
  final String searchQuery;

  const HistoryState({
    this.items = const [],
    this.selectedCategory,
    this.searchQuery = '',
  });

  HistoryState copyWith({
    List<AnalysisResult>? items,
    MediaTypeCategory? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
  }) {
    return HistoryState(
      items: items ?? this.items,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryRepository _repository;

  HistoryNotifier({HistoryRepository? repository})
    : _repository = repository ?? HistoryRepository(),
      super(const HistoryState()) {
    _refresh();
  }

  void _refresh() {
    final filtered = _repository.getHistory(
      filterCategory: state.selectedCategory,
      searchQuery: state.searchQuery,
    );
    state = state.copyWith(items: filtered);
  }

  void addScan(AnalysisResult result) {
    _repository.addScan(result);
    _refresh();
  }

  void setFilterCategory(MediaTypeCategory? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
    );
    _refresh();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _refresh();
  }

  void clearHistory() {
    _repository.clearHistory();
    _refresh();
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((
  ref,
) {
  final repo = ref.watch(historyRepositoryProvider);
  return HistoryNotifier(repository: repo);
});
