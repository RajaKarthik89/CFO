import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/finance_calculator.dart';
import '../../core/services/ai_service.dart';
import '../../models/models.dart';

class HealthScoreState {
  final HealthScore healthScore;
  final String aiReasoning;

  HealthScoreState({
    required this.healthScore,
    required this.aiReasoning,
  });
}

class HealthScoreNotifier extends AutoDisposeAsyncNotifier<HealthScoreState> {
  @override
  Future<HealthScoreState> build() async {
    final mockData = await ref.watch(mockDataServiceProvider.future);
    final aiService = ref.read(aiServiceProvider);

    final transactions = mockData.getTransactions();
    final goals = mockData.getGoals();
    final subs = mockData.getSubscriptions();

    // 1. Calculate health score via business logic
    final healthScore = FinanceCalculator.calculateHealthScore(transactions, goals, subs);

    // 2. Identify weak and strong factors to pass to AI
    HealthFactor? weakFactor;
    HealthFactor? strongFactor;

    for (final f in healthScore.factors) {
      if (weakFactor == null || f.score < weakFactor.score) {
        weakFactor = f;
      }
      if (strongFactor == null || f.score > strongFactor.score) {
        strongFactor = f;
      }
    }

    final contextMap = {
      'score': '${healthScore.overallScore}',
      'weakFactor': weakFactor?.name ?? 'Subscription Efficiency',
      'weakReason': weakFactor?.description ?? 'Wasteful underused accounts',
      'strongFactor': strongFactor?.name ?? 'Savings Rate',
      'strongReason': strongFactor?.description ?? 'Good rate of savings',
    };

    // 3. Query AI for reasoning narrative
    final aiReasoning = await aiService.generateHealthScoreReasoning(contextMap);

    return HealthScoreState(
      healthScore: healthScore,
      aiReasoning: aiReasoning,
    );
  }
}

final healthScoreControllerProvider = AutoDisposeAsyncNotifierProvider<HealthScoreNotifier, HealthScoreState>(() {
  return HealthScoreNotifier();
});
