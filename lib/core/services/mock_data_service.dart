import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';

class MockDataService {
  late UserProfile _profile;
  late List<Transaction> _transactions;
  late List<Goal> _goals;
  late List<Subscription> _subscriptions;
  late List<Bill> _bills;
  late Map<String, dynamic> _metadata;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final profileStr = await rootBundle.loadString('assets/mock_data/user_profile.json');
      _profile = UserProfile.fromJson(jsonDecode(profileStr) as Map<String, dynamic>);

      final txnsStr = await rootBundle.loadString('assets/mock_data/transactions.json');
      final txnsJson = jsonDecode(txnsStr) as List<dynamic>;
      _transactions = txnsJson.map((t) => Transaction.fromJson(t as Map<String, dynamic>)).toList();

      final goalsStr = await rootBundle.loadString('assets/mock_data/goals.json');
      final goalsJson = jsonDecode(goalsStr) as List<dynamic>;
      _goals = goalsJson.map((g) => Goal.fromJson(g as Map<String, dynamic>)).toList();

      final subsStr = await rootBundle.loadString('assets/mock_data/subscriptions.json');
      final subsJson = jsonDecode(subsStr) as List<dynamic>;
      _subscriptions = subsJson.map((s) => Subscription.fromJson(s as Map<String, dynamic>)).toList();

      final billsStr = await rootBundle.loadString('assets/mock_data/bills.json');
      final billsJson = jsonDecode(billsStr) as List<dynamic>;
      _bills = billsJson.map((b) => Bill.fromJson(b as Map<String, dynamic>)).toList();

      final metaStr = await rootBundle.loadString('assets/mock_data/metadata.json');
      _metadata = jsonDecode(metaStr) as Map<String, dynamic>;

      _initialized = true;
    } catch (e) {
      print('Error initializing MockDataService: $e');
      rethrow;
    }
  }

  UserProfile getUserProfile() {
    _checkInit();
    return _profile;
  }

  List<Transaction> getTransactions({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
  }) {
    _checkInit();
    Iterable<Transaction> query = _transactions;

    if (category != null && category.toLowerCase() != 'all') {
      query = query.where((t) => t.category.toLowerCase() == category.toLowerCase());
    }
    if (startDate != null) {
      query = query.where((t) => t.date.isAfter(startDate) || t.date.isAtSameMomentAs(startDate));
    }
    if (endDate != null) {
      query = query.where((t) => t.date.isBefore(endDate) || t.date.isAtSameMomentAs(endDate));
    }
    if (minAmount != null) {
      query = query.where((t) => t.amount >= minAmount);
    }
    if (maxAmount != null) {
      query = query.where((t) => t.amount <= maxAmount);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      query = query.where((t) =>
          t.merchant.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q));
    }

    return query.toList();
  }

  List<Goal> getGoals() {
    _checkInit();
    return _goals;
  }

  List<Subscription> getSubscriptions() {
    _checkInit();
    return _subscriptions;
  }

  List<Bill> getBills() {
    _checkInit();
    return _bills;
  }

  double getBalance() {
    _checkInit();
    if (_transactions.isEmpty) return 0.0;
    return _transactions.last.balanceAfter;
  }

  Map<String, double> getSpendingByCategory({int? month, int? year}) {
    _checkInit();
    final Map<String, double> spending = {};
    
    final filtered = _transactions.where((t) {
      if (t.type != TransactionType.debit) return false;
      if (t.category == 'Savings' || t.category == 'Investments') return false; // Exclude savings
      if (month != null && t.date.month != month) return false;
      if (year != null && t.date.year != year) return false;
      return true;
    });

    for (final t in filtered) {
      spending[t.category] = (spending[t.category] ?? 0.0) + t.amount;
    }

    return spending;
  }

  double getMonthlySpending({int? month, int? year}) {
    _checkInit();
    return _transactions.where((t) {
      if (t.type != TransactionType.debit) return false;
      if (t.category == 'Savings' || t.category == 'Investments') return false;
      if (month != null && t.date.month != month) return false;
      if (year != null && t.date.year != year) return false;
      return true;
    }).fold(0.0, (sum, t) => sum + t.amount);
  }

  double getMonthlyIncome({int? month, int? year}) {
    _checkInit();
    return _transactions.where((t) {
      if (t.category != 'Income') return false;
      if (month != null && t.date.month != month) return false;
      if (year != null && t.date.year != year) return false;
      return true;
    }).fold(0.0, (sum, t) => sum + t.amount);
  }

  List<Transaction> getRecentTransactions(int count) {
    _checkInit();
    if (_transactions.isEmpty) return [];
    // Sort transactions descending by date
    final sorted = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(count).toList();
  }

  Map<String, dynamic> getMetadata() {
    _checkInit();
    return _metadata;
  }

  void _checkInit() {
    if (!_initialized) {
      throw StateError('MockDataService has not been initialized. Call initialize() first.');
    }
  }
}

// ── Providers ─────────────────────────────────────────────────

final mockDataServiceProvider = FutureProvider<MockDataService>((ref) async {
  final service = MockDataService();
  await service.initialize();
  return service;
});
