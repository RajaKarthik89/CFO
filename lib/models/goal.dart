/// Savings-goal model for the CFO finance app.
///
/// Each [Goal] tracks a target purchase or fund the user is saving towards.
/// Computed getters [progressPercentage] and [remainingAmount] let the UI
/// render progress bars and labels without extra logic.

class Goal {
  final String id;
  final String name;

  /// Total amount needed to achieve this goal, in ₹.
  final double targetAmount;

  /// Amount saved so far, in ₹.
  final double savedAmount;

  /// Desired completion date.
  final DateTime targetDate;

  /// Date the goal was first created.
  final DateTime createdDate;

  /// Goal category — `"Electronics"`, `"Travel"`, `"Safety Net"`, etc.
  final String category;

  /// Priority level — `"high"`, `"medium"`, `"low"`.
  final String priority;

  /// How much the user plans to contribute each month, in ₹.
  final double monthlyContributionTarget;

  /// Icon identifier used by the UI (maps to Material icon names).
  final String icon;

  const Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
    required this.createdDate,
    required this.category,
    required this.priority,
    required this.monthlyContributionTarget,
    required this.icon,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      savedAmount: (json['saved_amount'] as num).toDouble(),
      targetDate: DateTime.parse(json['target_date'] as String),
      createdDate: DateTime.parse(json['created_date'] as String),
      category: json['category'] as String,
      priority: json['priority'] as String,
      monthlyContributionTarget:
          (json['monthly_contribution_target'] as num).toDouble(),
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'saved_amount': savedAmount,
      'target_date': targetDate.toIso8601String().split('T').first,
      'created_date': createdDate.toIso8601String().split('T').first,
      'category': category,
      'priority': priority,
      'monthly_contribution_target': monthlyContributionTarget,
      'icon': icon,
    };
  }

  // ── Computed properties ──────────────────────────────────────

  /// Percentage of the goal that has been saved (0.0 – 100.0).
  double get progressPercentage {
    if (targetAmount <= 0) return 100.0;
    return (savedAmount / targetAmount * 100).clamp(0.0, 100.0);
  }

  /// How much more the user still needs to save.
  double get remainingAmount => (targetAmount - savedAmount).clamp(0.0, targetAmount);

  /// Whether this goal has been fully funded.
  bool get isCompleted => savedAmount >= targetAmount;

  @override
  String toString() =>
      'Goal($name, ₹$savedAmount/₹$targetAmount, ${progressPercentage.toStringAsFixed(1)}%)';
}
