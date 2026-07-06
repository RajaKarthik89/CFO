/// User profile and card information models for the CFO finance app.
///
/// [UserProfile] represents the app user's financial identity — their
/// income pattern, bank, payment cards, and locale. The app uses this to
/// personalise AI-generated advice (e.g. irregular freelance income means
/// no fixed salary-day budgeting).

/// A single payment card or UPI handle linked to the user's account.
class CardInfo {
  final String name;

  /// Card type — `"credit"`, `"debit"`, `"upi"`, etc.
  final String type;

  /// Human-readable reward description, e.g.
  /// `"5% cashback on Amazon & Flipkart, 1% on others"`.
  final String rewardRate;

  /// Credit limit in ₹. Null for non-credit instruments (UPI, debit).
  final double? limit;

  const CardInfo({
    required this.name,
    required this.type,
    required this.rewardRate,
    this.limit,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      name: json['name'] as String,
      type: json['type'] as String,
      rewardRate: json['reward_rate'] as String,
      limit: json['limit'] != null ? (json['limit'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'reward_rate': rewardRate,
      if (limit != null) 'limit': limit,
    };
  }
}

class UserProfile {
  final String name;
  final int age;
  final String occupation;

  /// Average monthly income in ₹ (may be irregular for freelancers).
  final double monthlyIncomeAvg;

  /// Income pattern — `"salaried"`, `"irregular_freelance"`, etc.
  final String incomeType;

  /// Day of month salary is credited. Null for freelance / irregular income.
  final int? salaryDay;

  final String primaryBank;
  final List<CardInfo> cards;
  final String location;

  /// ISO 4217 currency code, e.g. `"INR"`.
  final String currency;

  const UserProfile({
    required this.name,
    required this.age,
    required this.occupation,
    required this.monthlyIncomeAvg,
    required this.incomeType,
    this.salaryDay,
    required this.primaryBank,
    required this.cards,
    required this.location,
    required this.currency,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      age: json['age'] as int,
      occupation: json['occupation'] as String,
      monthlyIncomeAvg: (json['monthly_income_avg'] as num).toDouble(),
      incomeType: json['income_type'] as String,
      salaryDay: json['salary_credit_day'] as int?,
      primaryBank: json['primary_bank'] as String,
      cards: (json['cards'] as List<dynamic>)
          .map((c) => CardInfo.fromJson(c as Map<String, dynamic>))
          .toList(),
      location: json['location'] as String,
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'occupation': occupation,
      'monthly_income_avg': monthlyIncomeAvg,
      'income_type': incomeType,
      'salary_credit_day': salaryDay,
      'primary_bank': primaryBank,
      'cards': cards.map((c) => c.toJson()).toList(),
      'location': location,
      'currency': currency,
    };
  }

  @override
  String toString() => 'UserProfile($name, $occupation, ₹$monthlyIncomeAvg/mo)';
}
