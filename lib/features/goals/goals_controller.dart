import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/finance_calculator.dart';
import '../../core/services/ai_service.dart';
import '../../models/models.dart';

// A simple StateNotifier backed by an explicit list — no dependency on async FutureProvider.
class GoalsNotifier extends StateNotifier<List<Goal>> {
  GoalsNotifier(List<Goal> initial) : super(initial);

  void addGoal(Goal goal) {
    state = [...state, goal];
  }
}

// Top-level mutable goals list, seeded from mock data once it resolves.
// The UI layer watches mockDataServiceProvider for loading/error states,
// so this provider only runs after mock data is available.
final goalsListProvider =
    StateNotifierProvider<GoalsNotifier, List<Goal>>((ref) {
  // Watch the FutureProvider — this will re-run when mock data resolves.
  final mockDataAsync = ref.watch(mockDataServiceProvider);
  final goals = mockDataAsync.maybeWhen(
    data: (svc) => svc.getGoals(),
    orElse: () => <Goal>[],
  );
  return GoalsNotifier(goals);
});

class GoalDetailState {
  final Goal goal;
  final double simulatedPurchaseAmount;
  final DateTime projectedDate;
  final int daysDelayed;
  final double newMonthlyRequired;
  final String aiImpactExplanation;
  final bool isLoading;

  GoalDetailState({
    required this.goal,
    required this.simulatedPurchaseAmount,
    required this.projectedDate,
    required this.daysDelayed,
    required this.newMonthlyRequired,
    required this.aiImpactExplanation,
    required this.isLoading,
  });

  GoalDetailState copyWith({
    Goal? goal,
    double? simulatedPurchaseAmount,
    DateTime? projectedDate,
    int? daysDelayed,
    double? newMonthlyRequired,
    String? aiImpactExplanation,
    bool? isLoading,
  }) {
    return GoalDetailState(
      goal: goal ?? this.goal,
      simulatedPurchaseAmount: simulatedPurchaseAmount ?? this.simulatedPurchaseAmount,
      projectedDate: projectedDate ?? this.projectedDate,
      daysDelayed: daysDelayed ?? this.daysDelayed,
      newMonthlyRequired: newMonthlyRequired ?? this.newMonthlyRequired,
      aiImpactExplanation: aiImpactExplanation ?? this.aiImpactExplanation,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class GoalDetailNotifier extends StateNotifier<AsyncValue<GoalDetailState>> {
  GoalDetailNotifier(this._mockData, this._aiService, this._goalId)
      : super(const AsyncValue.loading()) {
    _init();
  }

  final MockDataService _mockData;
  final AIService _aiService;
  final String _goalId;

  void _init() {
    try {
      final goal = _mockData.getGoals().firstWhere((g) => g.id == _goalId);
      final defaultDate = FinanceCalculator.calculateGoalProjection(goal, goal.monthlyContributionTarget);
      
      state = AsyncValue.data(GoalDetailState(
        goal: goal,
        simulatedPurchaseAmount: 0.0,
        projectedDate: defaultDate,
        daysDelayed: 0,
        newMonthlyRequired: goal.monthlyContributionTarget,
        aiImpactExplanation: 'Type a purchase amount above to simulate the impact on your "${goal.name}" timeline.',
        isLoading: false,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> simulatePurchase(double amount) async {
    if (amount < 0 || state.value == null) return;
    
    final current = state.value!;
    state = AsyncValue.data(current.copyWith(isLoading: true));

    final goal = current.goal;

    if (amount == 0) {
      final defaultDate = FinanceCalculator.calculateGoalProjection(goal, goal.monthlyContributionTarget);
      state = AsyncValue.data(GoalDetailState(
        goal: goal,
        simulatedPurchaseAmount: 0.0,
        projectedDate: defaultDate,
        daysDelayed: 0,
        newMonthlyRequired: goal.monthlyContributionTarget,
        aiImpactExplanation: 'Type a purchase amount above to simulate the impact on your "${goal.name}" timeline.',
        isLoading: false,
      ));
      return;
    }

    try {
      // 1. Calculate impact locally in Dart
      final impact = FinanceCalculator.calculateGoalImpact(goal, amount);
      final newDate = impact['newProjectedDate'] as DateTime;
      final delay = impact['daysDelayed'] as int;
      final newMonthly = impact['newMonthlyRequired'] as double;

      // 2. Query Gemini for natural language explanation
      final contextMap = {
        'goalName': goal.name,
        'purchaseAmount': '₹${amount.toStringAsFixed(0)}',
        'daysDelayed': '$delay',
        'newMonthlyRequired': '₹${newMonthly.toStringAsFixed(0)}',
      };

      final explanation = await _aiService.generateGoalImpactExplanation(contextMap);

      state = AsyncValue.data(GoalDetailState(
        goal: goal,
        simulatedPurchaseAmount: amount,
        projectedDate: newDate,
        daysDelayed: delay,
        newMonthlyRequired: newMonthly,
        aiImpactExplanation: explanation,
        isLoading: false,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final goalDetailControllerProvider = StateNotifierProvider.family.autoDispose<
    GoalDetailNotifier, AsyncValue<GoalDetailState>, String>((ref, goalId) {
  final mockData = ref.read(mockDataServiceProvider).requireValue;
  final aiService = ref.read(aiServiceProvider);
  return GoalDetailNotifier(mockData, aiService, goalId);
});

// (goalsListProvider is defined at the top of this file as a StateNotifierProvider)
