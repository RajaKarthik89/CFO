/// Financial health score model for the CFO finance app.
///
/// [HealthScore] is a composite metric (0–100) computed by
/// [FinanceCalculator.calculateHealthScore]. Each [HealthFactor] is a
/// weighted component with its own score and human-readable description.
/// The AI service consumes these to generate natural-language explanations.

/// Status thresholds for a single health factor.
enum HealthStatus {
  good,
  warning,
  danger;

  /// Derives the status from a numeric score (0–100).
  factory HealthStatus.fromScore(int score) {
    if (score >= 70) return HealthStatus.good;
    if (score >= 40) return HealthStatus.warning;
    return HealthStatus.danger;
  }

  factory HealthStatus.fromJson(String value) {
    return HealthStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => HealthStatus.warning,
    );
  }
}

/// A single factor that contributes to the overall [HealthScore].
class HealthFactor {
  final String name;

  /// Individual score for this factor (0–100).
  final int score;

  /// How much this factor contributes to the overall score (0.0–1.0).
  /// All factor weights should sum to 1.0.
  final double weight;

  /// Human-readable explanation of why this score is what it is.
  final String description;

  /// Derived status based on the score thresholds.
  final HealthStatus status;

  const HealthFactor({
    required this.name,
    required this.score,
    required this.weight,
    required this.description,
    required this.status,
  });

  factory HealthFactor.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as int;
    return HealthFactor(
      name: json['name'] as String,
      score: score,
      weight: (json['weight'] as num).toDouble(),
      description: json['description'] as String,
      status: json['status'] != null
          ? HealthStatus.fromJson(json['status'] as String)
          : HealthStatus.fromScore(score),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
      'weight': weight,
      'description': description,
      'status': status.name,
    };
  }

  /// The weighted contribution of this factor to the overall score.
  double get weightedScore => score * weight;

  @override
  String toString() => 'HealthFactor($name: $score/100, ${status.name})';
}

/// Composite financial health score for the user.
class HealthScore {
  /// Overall score (0–100), computed as the weighted sum of all factors.
  final int overallScore;

  /// Individual scoring factors with their weights and descriptions.
  final List<HealthFactor> factors;

  const HealthScore({
    required this.overallScore,
    required this.factors,
  });

  factory HealthScore.fromJson(Map<String, dynamic> json) {
    return HealthScore(
      overallScore: json['overall_score'] as int,
      factors: (json['factors'] as List<dynamic>)
          .map((f) => HealthFactor.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_score': overallScore,
      'factors': factors.map((f) => f.toJson()).toList(),
    };
  }

  /// Overall health status derived from the composite score.
  HealthStatus get status => HealthStatus.fromScore(overallScore);

  /// Returns the [HealthFactor] with the given [name], or `null`.
  HealthFactor? factorByName(String name) {
    try {
      return factors.firstWhere((f) => f.name == name);
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() =>
      'HealthScore($overallScore/100, ${factors.length} factors)';
}
