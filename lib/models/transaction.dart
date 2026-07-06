/// Transaction model for the CFO finance app.
///
/// Represents a single financial transaction — either a credit (income)
/// or debit (expense). The [balanceAfter] field stores the running account
/// balance after this transaction was processed, which the app uses to
/// derive the current balance without re-computing from scratch.

enum TransactionType {
  credit,
  debit;

  /// Parses a JSON string like `"credit"` / `"debit"` into the enum.
  factory TransactionType.fromJson(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => TransactionType.debit,
    );
  }
}

class Transaction {
  final String id;
  final DateTime date;
  final String merchant;
  final String category;
  final double amount;
  final TransactionType type;
  final String paymentMethod;
  final String description;
  final double balanceAfter;

  const Transaction({
    required this.id,
    required this.date,
    required this.merchant,
    required this.category,
    required this.amount,
    required this.type,
    required this.paymentMethod,
    required this.description,
    required this.balanceAfter,
  });

  /// Creates a [Transaction] from a decoded JSON map.
  ///
  /// Expects snake_case keys matching the mock data JSON schema:
  /// `id`, `date`, `merchant`, `category`, `amount`, `type`,
  /// `payment_method`, `description`, `balance_after`.
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      merchant: json['merchant'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.fromJson(json['type'] as String),
      paymentMethod: json['payment_method'] as String,
      description: (json['description'] as String?) ?? '',
      balanceAfter: (json['balance_after'] as num).toDouble(),
    );
  }

  /// Converts this transaction back to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'merchant': merchant,
      'category': category,
      'amount': amount,
      'type': type.name,
      'payment_method': paymentMethod,
      'description': description,
      'balance_after': balanceAfter,
    };
  }

  /// Whether this transaction is an income / incoming credit.
  bool get isCredit => type == TransactionType.credit;

  /// Whether this transaction is a spend / outgoing debit.
  bool get isDebit => type == TransactionType.debit;

  @override
  String toString() =>
      'Transaction($id, ${type.name} ₹$amount at $merchant on $date)';
}
