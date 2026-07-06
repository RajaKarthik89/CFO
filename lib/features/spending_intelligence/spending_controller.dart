import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/finance_calculator.dart';
import '../../core/services/ai_service.dart';
import '../../models/models.dart';

class SpendingState {
  final double totalSpent;
  final Map<String, double> categorySpent;
  final Map<String, Map<String, double>> momChanges;
  final String topCategory;
  final double topCategoryAmount;
  final double topCategoryChangePercent;
  final int foodOrdersCount;
  final double foodOrdersTotal;
  final String aiNarrative;

  SpendingState({
    required this.totalSpent,
    required this.categorySpent,
    required this.momChanges,
    required this.topCategory,
    required this.topCategoryAmount,
    required this.topCategoryChangePercent,
    required this.foodOrdersCount,
    required this.foodOrdersTotal,
    required this.aiNarrative,
  });
}

class SpendingNotifier extends AutoDisposeAsyncNotifier<SpendingState> {
  @override
  Future<SpendingState> build() async {
    final mockData = await ref.watch(mockDataServiceProvider.future);
    final aiService = ref.read(aiServiceProvider);

    // June 2026 is the latest completed month in the generated mock data
    const activeMonth = 6;
    const activeYear = 2026;

    final transactions = mockData.getTransactions();
    
    // 1. Calculate total spending
    final totalSpent = mockData.getMonthlySpending(month: activeMonth, year: activeYear);

    // 2. Spending by category
    final categorySpent = mockData.getSpendingByCategory(month: activeMonth, year: activeYear);

    // 3. Month over Month changes
    final momChanges = FinanceCalculator.calculateMonthOverMonthChange(transactions, activeMonth, activeYear);

    // 4. Find top category
    String topCat = 'Shopping';
    double topAmt = 0.0;
    double topChange = 0.0;
    
    categorySpent.forEach((cat, amt) {
      if (amt > topAmt) {
        topAmt = amt;
        topCat = cat;
      }
    });

    if (momChanges.containsKey(topCat)) {
      topChange = momChanges[topCat]!['changePercent'] ?? 0.0;
    }

    // 5. Zomato & Swiggy delivery count
    final foodTx = mockData.getTransactions(startDate: DateTime(2026, 6, 1), endDate: DateTime(2026, 6, 30))
        .where((t) => (t.merchant == 'Swiggy' || t.merchant == 'Zomato') && t.type == TransactionType.debit)
        .toList();
    final foodCount = foodTx.length;
    final foodTotal = foodTx.fold(0.0, (sum, t) => sum + t.amount);

    // 6. Generate AI Narrative
    final contextMap = {
      'highestCategory': topCat,
      'highestAmount': '₹${topAmt.toStringAsFixed(0)}',
      'momChange': '${topChange >= 0 ? '+' : ''}${topChange.toStringAsFixed(0)}%',
      'swiggyCount': '$foodCount',
      'swiggyTotal': '₹${foodTotal.toStringAsFixed(0)}',
    };

    final aiNarrative = await aiService.generateSpendingNarrative(contextMap);

    return SpendingState(
      totalSpent: totalSpent,
      categorySpent: categorySpent,
      momChanges: momChanges,
      topCategory: topCat,
      topCategoryAmount: topAmt,
      topCategoryChangePercent: topChange,
      foodOrdersCount: foodCount,
      foodOrdersTotal: foodTotal,
      aiNarrative: aiNarrative,
    );
  }
}

final spendingControllerProvider = AutoDisposeAsyncNotifierProvider<SpendingNotifier, SpendingState>(() {
  return SpendingNotifier();
});
