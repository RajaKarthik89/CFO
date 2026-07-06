import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/ai_service.dart';
import '../../models/models.dart';

class SearchState {
  final List<Transaction> results;
  final String activeQuery;
  final Map<String, dynamic> activeFilters;
  final bool isLoading;

  SearchState({
    required this.results,
    required this.activeQuery,
    required this.activeFilters,
    required this.isLoading,
  });

  SearchState copyWith({
    List<Transaction>? results,
    String? activeQuery,
    Map<String, dynamic>? activeFilters,
    bool? isLoading,
  }) {
    return SearchState(
      results: results ?? this.results,
      activeQuery: activeQuery ?? this.activeQuery,
      activeFilters: activeFilters ?? this.activeFilters,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._mockData, this._aiService)
      : super(SearchState(
          results: [],
          activeQuery: '',
          activeFilters: {},
          isLoading: false,
        ));

  final MockDataService _mockData;
  final AIService _aiService;

  Future<void> executeSearch(String query) async {
    if (query.trim().isEmpty) {
      state = SearchState(results: [], activeQuery: '', activeFilters: {}, isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, activeQuery: query);

    try {
      // 1. Ask Gemini to extract query filters
      final filters = await _aiService.parseSearchIntent(query);

      // 2. Fetch filtered transactions locally based on parsed parameters
      final category = filters['category'] as String?;
      final minAmount = filters['minAmount'] != null ? (filters['minAmount'] as num).toDouble() : null;
      final maxAmount = filters['maxAmount'] != null ? (filters['maxAmount'] as num).toDouble() : null;
      final merchant = filters['merchant'] as String?;

      DateTime? startDate;
      if (filters['startDate'] != null) {
        startDate = DateTime.tryParse(filters['startDate'] as String);
      }
      DateTime? endDate;
      if (filters['endDate'] != null) {
        endDate = DateTime.tryParse(filters['endDate'] as String);
      }

      final results = _mockData.getTransactions(
        category: category,
        minAmount: minAmount,
        maxAmount: maxAmount,
        searchQuery: merchant,
        startDate: startDate,
        endDate: endDate,
      );

      state = SearchState(
        results: results,
        activeQuery: query,
        activeFilters: filters,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, results: []);
    }
  }
}

final searchControllerProvider = StateNotifierProvider.autoDispose<SearchNotifier, SearchState>((ref) {
  final mockData = ref.read(mockDataServiceProvider).requireValue;
  final aiService = ref.read(aiServiceProvider);
  return SearchNotifier(mockData, aiService);
});
