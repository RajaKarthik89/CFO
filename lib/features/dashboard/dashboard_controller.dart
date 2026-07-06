import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/finance_calculator.dart';
import '../../core/services/ai_service.dart';
import '../../models/models.dart';

class DashboardState {
  final UserProfile profile;
  final double balance;
  final Map<String, BudgetCategory> budgets;
  final double budgetSpentTotal;
  final double budgetLimitTotal;
  final Goal? nearestGoal;
  final Bill? urgentBill;
  final String bestCard;
  final String dailyBriefing;

  DashboardState({
    required this.profile,
    required this.balance,
    required this.budgets,
    required this.budgetSpentTotal,
    required this.budgetLimitTotal,
    this.nearestGoal,
    this.urgentBill,
    required this.bestCard,
    required this.dailyBriefing,
  });
}

class DashboardNotifier extends AutoDisposeAsyncNotifier<DashboardState> {
  @override
  Future<DashboardState> build() async {
    final mockData = await ref.watch(mockDataServiceProvider.future);
    final aiService = ref.read(aiServiceProvider);

    // 1. Fetch profile and transactions
    final profile = mockData.getUserProfile();
    final transactions = mockData.getTransactions();

    // 2. Compute balance
    final balance = FinanceCalculator.calculateBalance(transactions);

    // 3. Compute budgets (for active month, July 2026 as per mock dataset date range)
    final budgets = FinanceCalculator.calculateBudgetUsage(transactions, 6, 2026); // Use June (last full month) for baseline budget representation
    double totalSpent = 0.0;
    double totalBudget = 0.0;
    budgets.forEach((cat, usage) {
      totalSpent += usage.spent;
      totalBudget += usage.budget;
    });

    // 4. Find nearest goal
    final goals = mockData.getGoals();
    Goal? nearestGoal;
    if (goals.isNotEmpty) {
      // Find goal with highest progress percentage that is not yet completed
      nearestGoal = goals
          .where((g) => !g.isCompleted)
          .reduce((curr, next) => curr.progressPercentage > next.progressPercentage ? curr : next);
    }

    // 5. Find urgent bill
    final bills = mockData.getBills();
    Bill? urgentBill;
    if (bills.isNotEmpty) {
      // Find bill due earliest (lowest daysUntilDue)
      urgentBill = bills
          .where((b) => b.status == BillStatus.pending)
          .reduce((curr, next) => curr.daysUntilDue < next.daysUntilDue ? curr : next);
    }

    // 6. Best card to use
    // Simple logic: credit card has 5% back on Amazon/Flipkart
    final bestCard = profile.cards.firstWhere((c) => c.type == 'credit', orElse: () => profile.cards.first).name;

    // 7. Request AI Daily Briefing
    final contextMap = {
      'name': profile.name,
      'balance': '₹${balance.toStringAsFixed(0)}',
      'budgetUsedPercent': '${totalBudget > 0 ? (totalSpent / totalBudget * 100).toStringAsFixed(0) : '0'}%',
      'nearestGoalName': nearestGoal?.name ?? 'Emergency Fund',
      'nearestGoalProgress': '${nearestGoal?.progressPercentage.toStringAsFixed(0) ?? '0'}%',
      'urgentBillName': urgentBill?.name ?? 'Electricity Bill',
      'urgentBillAmount': '₹${urgentBill?.amount.toStringAsFixed(0) ?? '0'}',
      'urgentBillDays': '${urgentBill?.daysUntilDue ?? 3}',
      'bestCard': bestCard,
    };

    final dailyBriefing = await aiService.generateDailyBriefing(contextMap);

    return DashboardState(
      profile: profile,
      balance: balance,
      budgets: budgets,
      budgetSpentTotal: totalSpent,
      budgetLimitTotal: totalBudget,
      nearestGoal: nearestGoal,
      urgentBill: urgentBill,
      bestCard: bestCard,
      dailyBriefing: dailyBriefing,
    );
  }
}

final dashboardControllerProvider = AutoDisposeAsyncNotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});
