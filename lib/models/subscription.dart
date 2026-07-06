/// Recurring subscription model for the CFO finance app.
///
/// Tracks streaming services, cloud storage, and other recurring charges.
/// The [status] field lets the AI flag subscriptions that are underused
/// or duplicated so it can suggest cancellations.

enum SubscriptionStatus {
  active,
  underused,
  duplicate;

  factory SubscriptionStatus.fromJson(String value) {
    return SubscriptionStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => SubscriptionStatus.active,
    );
  }
}

class Subscription {
  final String id;
  final String name;

  /// Monthly cost in ₹.
  final double monthlyCost;

  /// Annual cost in ₹ (may differ from monthlyCost × 12 for annual plans).
  final double annualCost;

  /// Category — `"Entertainment"`, `"Music"`, `"Cloud Storage"`, etc.
  final String category;

  /// Billing frequency — `"monthly"`, `"quarterly"`, `"annual"`.
  final String billingCycle;

  /// Date when the next charge will occur.
  final DateTime nextBillingDate;

  /// Date the user last interacted with / used this service.
  final DateTime lastUsed;

  /// Self-reported usage — `"daily"`, `"weekly"`, `"low"`, etc.
  final String usageFrequency;

  /// AI-inferred or user-set status flag.
  final SubscriptionStatus status;

  /// Free-text notes, e.g. `"Watched only 2 shows in the last 3 months"`.
  final String notes;

  const Subscription({
    required this.id,
    required this.name,
    required this.monthlyCost,
    required this.annualCost,
    required this.category,
    required this.billingCycle,
    required this.nextBillingDate,
    required this.lastUsed,
    required this.usageFrequency,
    required this.status,
    required this.notes,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      name: json['name'] as String,
      monthlyCost: (json['monthly_cost'] as num).toDouble(),
      annualCost: (json['annual_cost'] as num).toDouble(),
      category: json['category'] as String,
      billingCycle: json['billing_cycle'] as String,
      nextBillingDate: DateTime.parse(json['next_billing_date'] as String),
      lastUsed: DateTime.parse(json['last_used'] as String),
      usageFrequency: json['usage_frequency'] as String,
      status: SubscriptionStatus.fromJson(json['status'] as String),
      notes: (json['notes'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'monthly_cost': monthlyCost,
      'annual_cost': annualCost,
      'category': category,
      'billing_cycle': billingCycle,
      'next_billing_date': nextBillingDate.toIso8601String().split('T').first,
      'last_used': lastUsed.toIso8601String().split('T').first,
      'usage_frequency': usageFrequency,
      'status': status.name,
      'notes': notes,
    };
  }

  /// Whether this subscription is flagged for potential savings.
  bool get isWasteful =>
      status == SubscriptionStatus.underused ||
      status == SubscriptionStatus.duplicate;

  @override
  String toString() => 'Subscription($name, ₹$monthlyCost/mo, ${status.name})';
}
