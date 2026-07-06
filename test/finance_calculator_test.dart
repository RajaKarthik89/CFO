import 'package:flutter_test/flutter_test.dart';
import 'package:cfo/models/models.dart';
import 'package:cfo/core/services/finance_calculator.dart';

void main() {
  group('FinanceCalculator Tests', () {
    final t1 = Transaction(
      id: 'TXN1001',
      date: DateTime(2026, 4, 15),
      merchant: 'Upwork',
      category: 'Income',
      amount: 15000.0,
      type: TransactionType.credit,
      paymentMethod: 'Bank Transfer',
      description: '',
      balanceAfter: 15000.0,
    );

    final t2 = Transaction(
      id: 'TXN1002',
      date: DateTime(2026, 4, 20),
      merchant: 'Swiggy',
      category: 'Food & Dining',
      amount: 500.0,
      type: TransactionType.debit,
      paymentMethod: 'UPI - HDFC',
      description: '',
      balanceAfter: 14500.0,
    );

    final t3 = Transaction(
      id: 'TXN1003',
      date: DateTime(2026, 5, 5),
      merchant: 'Swiggy',
      category: 'Food & Dining',
      amount: 1000.0,
      type: TransactionType.debit,
      paymentMethod: 'UPI - HDFC',
      description: '',
      balanceAfter: 13500.0,
    );

    final t4 = Transaction(
      id: 'TXN1004',
      date: DateTime(2026, 6, 10),
      merchant: 'Swiggy',
      category: 'Food & Dining',
      amount: 1500.0,
      type: TransactionType.debit,
      paymentMethod: 'UPI - HDFC',
      description: '',
      balanceAfter: 12000.0,
    );

    final t5 = Transaction(
      id: 'TXN1005',
      date: DateTime(2026, 6, 20),
      merchant: 'Amazon India',
      category: 'Shopping',
      amount: 2000.0,
      type: TransactionType.debit,
      paymentMethod: 'HDFC Millennia',
      description: '',
      balanceAfter: 10000.0,
    );

    final txns = [t1, t2, t3, t4, t5];

    test('calculateBalance returns correct balance after last transaction', () {
      final balance = FinanceCalculator.calculateBalance(txns);
      expect(balance, equals(10000.0));
    });

    test('calculateCategoryBudgets computes correct 3-month rolling average', () {
      // If we are looking for budgets for July 2026 (7),
      // the rolling average months are April, May, June (4, 5, 6).
      // Food & Dining has:
      // April: 500
      // May: 1000
      // June: 1500
      // Total: 3000 -> divided by 3 = 1000 average.
      final budgets = FinanceCalculator.calculateCategoryBudgets(txns, 7, 2026);
      expect(budgets['Food & Dining'], equals(1000.0));
      expect(budgets['Shopping'], equals(2000.0 / 3.0));
    });

    test('calculateMonthOverMonthChange calculates MoM percentages correctly', () {
      // Compare June (6) vs May (5)
      // Food & Dining:
      // June: 1500
      // May: 1000
      // Change: +50%
      final changes = FinanceCalculator.calculateMonthOverMonthChange(txns, 6, 2026);
      expect(changes['Food & Dining']?['current'], equals(1500.0));
      expect(changes['Food & Dining']?['previous'], equals(1000.0));
      expect(changes['Food & Dining']?['changePercent'], equals(50.0));
    });

    test('calculateGoalProjection computes correct projected completion date', () {
      final goal = Goal(
        id: 'goal_1',
        name: 'MacBook Air',
        targetAmount: 110000.0,
        savedAmount: 35000.0,
        targetDate: DateTime(2026, 12, 31),
        createdDate: DateTime(2026, 1, 1),
        category: 'Electronics',
        priority: 'high',
        monthlyContributionTarget: 7500.0,
        icon: 'laptop_mac',
      );

      final date = FinanceCalculator.calculateGoalProjection(goal, 10000.0);
      final remaining = goal.remainingAmount; // 75000.0
      final double months = remaining / 10000.0; // 7.5 months
      final days = (months * 30.437).round(); // ~228 days

      final expectedDate = DateTime.now().add(Duration(days: days));
      expect(date.year, equals(expectedDate.year));
      expect(date.month, equals(expectedDate.month));
      expect(date.day, equals(expectedDate.day));
    });
  });
}
