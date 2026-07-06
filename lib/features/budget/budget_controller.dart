import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/finance_calculator.dart';
import '../../core/services/ai_service.dart';

class BudgetState {
  final Map<String, BudgetCategory> budgets;
  final double totalBudgetLimit;
  final double totalSpent;
  final Map<String, String> categoryTips;

  BudgetState({
    required this.budgets,
    required this.totalBudgetLimit,
    required this.totalSpent,
    required this.categoryTips,
  });
}

class BudgetNotifier extends AutoDisposeAsyncNotifier<BudgetState> {
  @override
  Future<BudgetState> build() async {
    final mockData = await ref.watch(mockDataServiceProvider.future);
    final aiService = ref.read(aiServiceProvider);

    const activeMonth = 6;
    const activeYear = 2026;

    final transactions = mockData.getTransactions();

    // 1. Calculate budget usage
    final budgets = FinanceCalculator.calculateBudgetUsage(transactions, activeMonth, activeYear);

    double totalLimit = 0.0;
    double totalSpent = 0.0;
    budgets.forEach((cat, usage) {
      totalLimit += usage.budget;
      totalSpent += usage.spent;
    });

    // 2. Identify categories over 80% and request AI tips
    final Map<String, String> tips = {};
    for (final entry in budgets.entries) {
      final cat = entry.key;
      final usage = entry.value;

      if (usage.percentage >= 0.8) {
        final contextMap = {
          'spent': '₹${usage.spent.toStringAsFixed(0)}',
          'budget': '₹${usage.budget.toStringAsFixed(0)}',
          'percent': '${(usage.percentage * 100).toStringAsFixed(0)}%',
        };

        // Call Gemini for a custom tip, with a static fallback
        final tip = await aiService.generateBudgetTips(cat, contextMap);
        tips[cat] = tip;
      }
    }

    return BudgetState(
      budgets: budgets,
      totalBudgetLimit: totalLimit,
      totalSpent: totalSpent,
      categoryTips: tips,
    );
  }
}

final budgetControllerProvider = AutoDisposeAsyncNotifierProvider<BudgetNotifier, BudgetState>(() {
  return BudgetNotifier();
});
