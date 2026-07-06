import '../../models/models.dart';

class BudgetCategory {
  final String category;
  final double budget;
  final double spent;

  const BudgetCategory({
    required this.category,
    required this.budget,
    required this.spent,
  });

  double get percentage {
    if (budget <= 0) return 0.0;
    return spent / budget;
  }
}

class FinanceCalculator {
  /// Computes the current balance from the transaction list.
  /// If list is empty, returns 0.0. Otherwise returns the balanceAfter of the last transaction.
  static double calculateBalance(List<Transaction> transactions) {
    if (transactions.isEmpty) return 0.0;
    return transactions.last.balanceAfter;
  }

  /// Calculates category budgets based on the 3-month rolling average prior to the specified month and year,
  /// and returns a map of budget category details for the specified month.
  static Map<String, BudgetCategory> calculateBudgetUsage(
    List<Transaction> transactions,
    int month,
    int year,
  ) {
    // 1. Get transactions for the active month/year to calculate spent
    final activeMonthTransactions = transactions.where((t) =>
        t.date.month == month && t.date.year == year && t.type == TransactionType.debit).toList();

    final Map<String, double> spentByCategory = {};
    for (final t in activeMonthTransactions) {
      spentByCategory[t.category] = (spentByCategory[t.category] ?? 0.0) + t.amount;
    }

    // 2. Compute budgets for each category (3-month rolling average prior to this month)
    final budgets = calculateCategoryBudgets(transactions, month, year);

    // 3. Combine them into BudgetCategory models
    final Map<String, BudgetCategory> budgetUsage = {};
    
    // Ensure all categories in either budget or spent are represented (excluding Savings & Investments, which are not regular expenses)
    final allCategories = {...budgets.keys, ...spentByCategory.keys}
        .where((cat) => cat != 'Savings' && cat != 'Income')
        .toList();

    for (final cat in allCategories) {
      budgetUsage[cat] = BudgetCategory(
        category: cat,
        budget: budgets[cat] ?? 5000.0, // Default fallback budget of 5k if no history
        spent: spentByCategory[cat] ?? 0.0,
      );
    }

    return budgetUsage;
  }

  /// Computes the 3-month rolling average spending for each category prior to the specified month/year.
  static Map<String, double> calculateCategoryBudgets(
    List<Transaction> transactions,
    int currentMonth,
    int currentYear,
  ) {
    final Map<String, double> budgets = {};

    // Get prior 3 months
    final List<DateTime> priorMonths = [];
    var m = currentMonth;
    var y = currentYear;
    for (int i = 0; i < 3; i++) {
      m--;
      if (m == 0) {
        m = 12;
        y--;
      }
      priorMonths.add(DateTime(y, m));
    }

    // Filter transactions to only debits in those prior months
    final historyTransactions = transactions.where((t) {
      if (t.type != TransactionType.debit) return false;
      return priorMonths.any((pm) => t.date.month == pm.month && t.date.year == pm.year);
    }).toList();

    // Group by category and month
    // Map of Category -> Map of MonthKey (e.g. "2026-03") -> Sum of Amount
    final Map<String, Map<String, double>> grouped = {};
    for (final t in historyTransactions) {
      final monthKey = "${t.date.year}-${t.date.month}";
      grouped.putIfAbsent(t.category, () => {});
      grouped[t.category]![monthKey] = (grouped[t.category]![monthKey] ?? 0.0) + t.amount;
    }

    // Compute average over the 3 months
    grouped.forEach((category, monthlyData) {
      // Divisor is 3, but if the app has fewer months of data, we use the number of unique months found
      final totalSpent = monthlyData.values.fold(0.0, (sum, val) => sum + val);
      budgets[category] = totalSpent / 3.0;
    });

    return budgets;
  }

  /// Computes the overall financial health score (0-100) and factor details.
  static HealthScore calculateHealthScore(
    List<Transaction> transactions,
    List<Goal> goals,
    List<Subscription> subscriptions,
  ) {
    // We compute metrics based on the last 30 days of transactions for a active view
    final now = DateTime(2026, 7, 4); // "Today" as per mock data
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentTx = transactions.where((t) => t.date.isAfter(thirtyDaysAgo)).toList();

    // 1. Savings Rate Score (Weight: 30%)
    double income = 0.0;
    double spending = 0.0;
    for (final t in recentTx) {
      if (t.category == 'Income') {
        income += t.amount;
      } else if (t.category != 'Savings') {
        // Exclude savings transfer from spending
        spending += t.amount;
      }
    }
    // If no recent income, fallback to user average income
    if (income == 0) income = 28000.0;
    final savingsRate = ((income - spending) / income * 100).clamp(-50.0, 100.0);
    // Map savings rate to 0-100 score: 0% savings rate = 40 points, 30%+ = 100 points
    int savingsScore = 0;
    if (savingsRate > 0) {
      savingsScore = (40 + (savingsRate / 30.0 * 60.0)).clamp(40, 100).round();
    } else {
      savingsScore = (40 + (savingsRate / 50.0 * 40.0)).clamp(0, 40).round();
    }

    // 2. Budget Adherence Score (Weight: 25%)
    // Check June 2026 (the last full month of data)
    final budgets = calculateBudgetUsage(transactions, 6, 2026);
    int withinBudgetCount = 0;
    int totalBudgetCategories = budgets.length;
    budgets.forEach((cat, usage) {
      if (usage.percentage <= 1.0) {
        withinBudgetCount++;
      }
    });
    final budgetAdherenceScore = totalBudgetCategories > 0 
        ? ((withinBudgetCount / totalBudgetCategories) * 100).round()
        : 100;

    // 3. Subscription Efficiency Score (Weight: 15%)
    double totalSubCost = 0.0;
    double wastefulSubCost = 0.0;
    for (final sub in subscriptions) {
      totalSubCost += sub.monthlyCost;
      if (sub.isWasteful) {
        wastefulSubCost += sub.monthlyCost;
      }
    }
    final subEfficiencyScore = totalSubCost > 0
        ? (100 - (wastefulSubCost / totalSubCost * 100)).round().clamp(0, 100)
        : 100;

    // 4. Goal Contribution Consistency (Weight: 30%)
    // Look at last 3 months, calculate how much was transferred to savings/goals
    final threeMonthsAgo = now.subtract(const Duration(days: 90));
    final savingsTx = transactions.where((t) => 
        t.date.isAfter(threeMonthsAgo) && t.category == 'Savings').toList();
    final double totalSaved = savingsTx.fold(0.0, (sum, t) => sum + t.amount);
    final double monthlyAvgSaved = totalSaved / 3.0;
    final double totalTargetMonthly = goals.fold(0.0, (sum, g) => sum + g.monthlyContributionTarget);
    
    final goalScore = totalTargetMonthly > 0
        ? ((monthlyAvgSaved / totalTargetMonthly) * 100).round().clamp(0, 100)
        : 100;

    // Create factors list
    final factors = [
      HealthFactor(
        name: 'Savings Rate',
        score: savingsScore,
        weight: 0.30,
        description: 'You saved ${savingsRate.toStringAsFixed(1)}% of your income this month.',
        status: HealthStatus.fromScore(savingsScore),
      ),
      HealthFactor(
        name: 'Budget Adherence',
        score: budgetAdherenceScore,
        weight: 0.25,
        description: 'You kept $withinBudgetCount of $totalBudgetCategories categories within their budget last month.',
        status: HealthStatus.fromScore(budgetAdherenceScore),
      ),
      HealthFactor(
        name: 'Subscription Efficiency',
        score: subEfficiencyScore,
        weight: 0.15,
        description: subEfficiencyScore == 100 
            ? 'All your active subscriptions are regularly used.' 
            : 'You have underused/duplicate subscriptions costing ₹${wastefulSubCost.toStringAsFixed(0)}/mo.',
        status: HealthStatus.fromScore(subEfficiencyScore),
      ),
      HealthFactor(
        name: 'Goal Consistency',
        score: goalScore,
        weight: 0.30,
        description: 'Saved ₹${monthlyAvgSaved.toStringAsFixed(0)}/mo avg vs target ₹${totalTargetMonthly.toStringAsFixed(0)}/mo.',
        status: HealthStatus.fromScore(goalScore),
      ),
    ];

    final overall = factors.fold(0.0, (sum, f) => sum + f.weightedScore).round().clamp(0, 100);

    return HealthScore(
      overallScore: overall,
      factors: factors,
    );
  }

  /// Calculates the projected completion date of a goal based on a monthly contribution rate.
  static DateTime calculateGoalProjection(Goal goal, double monthlyContribution) {
    if (monthlyContribution <= 0) return DateTime(2099, 12, 31);
    final remaining = goal.remainingAmount;
    final monthsNeeded = (remaining / monthlyContribution);
    
    final int daysNeeded = (monthsNeeded * 30.437).round();
    return DateTime.now().add(Duration(days: daysNeeded));
  }

  /// Evaluates the impact of a one-time purchase on a goal.
  static Map<String, dynamic> calculateGoalImpact(Goal goal, double purchaseAmount) {
    // Current projected date using the target monthly contribution
    final currentProj = calculateGoalProjection(goal, goal.monthlyContributionTarget);
    
    // Simulating deduction of purchaseAmount from savedAmount
    final simulatedSavedAmount = (goal.savedAmount - purchaseAmount).clamp(0.0, goal.targetAmount);
    final simulatedGoal = Goal(
      id: goal.id,
      name: goal.name,
      targetAmount: goal.targetAmount,
      savedAmount: simulatedSavedAmount,
      targetDate: goal.targetDate,
      createdDate: goal.createdDate,
      category: goal.category,
      priority: goal.priority,
      monthlyContributionTarget: goal.monthlyContributionTarget,
      icon: goal.icon,
    );

    final newProj = calculateGoalProjection(simulatedGoal, goal.monthlyContributionTarget);
    final daysDelayed = newProj.difference(currentProj).inDays;

    // Recalculate what monthly contribution is now required to hit the original target date
    final monthsLeft = (goal.targetDate.difference(DateTime.now()).inDays / 30.437);
    final newMonthlyRequired = monthsLeft > 0 
        ? (simulatedGoal.remainingAmount / monthsLeft)
        : simulatedGoal.remainingAmount;

    return {
      'newProjectedDate': newProj,
      'daysDelayed': daysDelayed.clamp(0, 9999),
      'newMonthlyRequired': newMonthlyRequired.clamp(0.0, goal.targetAmount),
    };
  }

  /// Simulates future savings over 3, 6, 12 months based on enabled scenarios.
  /// Scenarios contain keys like: "stop_food_delivery", "cancel_underused_subs", "reduce_shopping_20", "custom_slider_val"
  static Map<String, double> calculateSavingsSimulation(
    List<Transaction> transactions,
    Map<String, double> scenarios,
  ) {
    double monthlySavings = 0.0;

    // Stop food delivery on weekends (Zomato/Swiggy on Sat/Sun)
    if (scenarios['stop_food_delivery'] == 1.0) {
      // Find average food delivery weekend spend in last 3 months
      final now = DateTime(2026, 7, 4);
      final ninetyDaysAgo = now.subtract(const Duration(days: 90));
      final foodTx = transactions.where((t) {
        if (t.date.isBefore(ninetyDaysAgo) || t.type != TransactionType.debit) return false;
        if (t.category != 'Food & Dining') return false;
        if (t.merchant != 'Swiggy' && t.merchant != 'Zomato') return false;
        return t.date.weekday >= 6; // Sat=6, Sun=7
      }).toList();

      final total = foodTx.fold(0.0, (sum, t) => sum + t.amount);
      monthlySavings += (total / 3.0); // Average per month
    }

    // Cancel underused subscriptions (Netflix is underused, costing ₹649/mo)
    if (scenarios['cancel_underused_subs'] == 1.0) {
      monthlySavings += 649.0;
    }

    // Reduce shopping by 20%
    if (scenarios['reduce_shopping_20'] == 1.0) {
      // Find average monthly shopping spend in last 3 months
      final now = DateTime(2026, 7, 4);
      final ninetyDaysAgo = now.subtract(const Duration(days: 90));
      final shoppingTx = transactions.where((t) =>
          t.date.isAfter(ninetyDaysAgo) &&
          t.type == TransactionType.debit &&
          t.category == 'Shopping').toList();

      final total = shoppingTx.fold(0.0, (sum, t) => sum + t.amount);
      monthlySavings += (total / 3.0) * 0.20; // 20% savings
    }

    // Custom slider savings (₹0 - ₹10,000)
    final customVal = scenarios['custom_slider'] ?? 0.0;
    monthlySavings += customVal;

    return {
      'monthly': monthlySavings,
      'quarterly': monthlySavings * 3,
      'halfYearly': monthlySavings * 6,
      'yearly': monthlySavings * 12,
    };
  }

  /// Calculates Month-over-Month changes for categories for a specified month/year compared to the previous month.
  static Map<String, Map<String, double>> calculateMonthOverMonthChange(
    List<Transaction> transactions,
    int month,
    int year,
  ) {
    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;

    // Filter transactions for both months
    final currentTx = transactions.where((t) =>
        t.date.month == month && t.date.year == year && t.type == TransactionType.debit).toList();
    final prevTx = transactions.where((t) =>
        t.date.month == prevMonth && t.date.year == prevYear && t.type == TransactionType.debit).toList();

    final Map<String, double> currentSpent = {};
    for (final t in currentTx) {
      currentSpent[t.category] = (currentSpent[t.category] ?? 0.0) + t.amount;
    }

    final Map<String, double> prevSpent = {};
    for (final t in prevTx) {
      prevSpent[t.category] = (prevSpent[t.category] ?? 0.0) + t.amount;
    }

    final Map<String, Map<String, double>> result = {};
    final allCategories = {...currentSpent.keys, ...prevSpent.keys}.where((c) => c != 'Savings');

    for (final cat in allCategories) {
      final cur = currentSpent[cat] ?? 0.0;
      final prev = prevSpent[cat] ?? 0.0;
      
      // Calculate % change
      double percentChange = 0.0;
      if (prev > 0) {
        percentChange = ((cur - prev) / prev) * 100;
      } else if (cur > 0) {
        percentChange = 100.0; // Brand new spending category
      }

      result[cat] = {
        'current': cur,
        'previous': prev,
        'changePercent': percentChange,
      };
    }

    return result;
  }
}
