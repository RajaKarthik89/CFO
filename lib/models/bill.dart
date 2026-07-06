/// Upcoming bill / payment-due model for the CFO finance app.
///
/// Bills represent known future outflows — rent, utilities, credit card
/// payments. The computed [isUrgent] flag helps the AI prioritise bills
/// that are due within 3 days in the daily briefing.

enum BillStatus {
  pending,
  paid,
  overdue;

  factory BillStatus.fromJson(String value) {
    return BillStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => BillStatus.pending,
    );
  }
}

class Bill {
  final String id;
  final String name;
  final String merchant;

  /// Amount due in ₹.
  final double amount;

  /// Date the payment is due.
  final DateTime dueDate;

  /// Category — `"Bills & Utilities"`, `"Rent"`, `"Credit Card"`, etc.
  final String category;

  final BillStatus status;

  /// Whether this bill recurs on a regular cycle.
  final bool isRecurring;

  /// Recurrence frequency — `"monthly"`, `"quarterly"`, etc.
  final String frequency;

  /// Whether auto-pay is enabled for this bill.
  final bool autoPay;

  const Bill({
    required this.id,
    required this.name,
    required this.merchant,
    required this.amount,
    required this.dueDate,
    required this.category,
    required this.status,
    required this.isRecurring,
    required this.frequency,
    required this.autoPay,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String,
      name: json['name'] as String,
      merchant: json['merchant'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['due_date'] as String),
      category: json['category'] as String,
      status: BillStatus.fromJson(json['status'] as String),
      isRecurring: json['is_recurring'] as bool,
      frequency: json['frequency'] as String,
      autoPay: json['auto_pay'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'merchant': merchant,
      'amount': amount,
      'due_date': dueDate.toIso8601String().split('T').first,
      'category': category,
      'status': status.name,
      'is_recurring': isRecurring,
      'frequency': frequency,
      'auto_pay': autoPay,
    };
  }

  // ── Computed properties ──────────────────────────────────────

  /// Days remaining until the due date (negative if overdue).
  int get daysUntilDue {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final dueMidnight = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueMidnight.difference(todayMidnight).inDays;
  }

  /// Bills due within 3 calendar days are considered urgent.
  bool get isUrgent => daysUntilDue >= 0 && daysUntilDue <= 3;

  /// Whether the due date has already passed.
  bool get isOverdue => daysUntilDue < 0 && status != BillStatus.paid;

  @override
  String toString() =>
      'Bill($name, ₹$amount, due ${dueDate.toIso8601String().split('T').first}, ${status.name})';
}
