import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/finance_calculator.dart';
import '../../core/services/ai_service.dart';
import '../../models/models.dart';

class SimulatorState {
  final bool stopFoodDelivery;
  final bool cancelUnusedSubs;
  final bool reduceShopping;
  final double customSlider;

  final double monthlySavings;
  final double quarterlySavings;
  final double halfYearlySavings;
  final double yearlySavings;

  final Goal? nearestGoal;
  final DateTime originalGoalDate;
  final DateTime newGoalDate;
  final int daysSaved;

  final String aiSummary;
  final bool isLoading;

  SimulatorState({
    required this.stopFoodDelivery,
    required this.cancelUnusedSubs,
    required this.reduceShopping,
    required this.customSlider,
    required this.monthlySavings,
    required this.quarterlySavings,
    required this.halfYearlySavings,
    required this.yearlySavings,
    this.nearestGoal,
    required this.originalGoalDate,
    required this.newGoalDate,
    required this.daysSaved,
    required this.aiSummary,
    required this.isLoading,
  });

  SimulatorState copyWith({
    bool? stopFoodDelivery,
    bool? cancelUnusedSubs,
    bool? reduceShopping,
    double? customSlider,
    double? monthlySavings,
    double? quarterlySavings,
    double? halfYearlySavings,
    double? yearlySavings,
    Goal? nearestGoal,
    DateTime? originalGoalDate,
    DateTime? newGoalDate,
    int? daysSaved,
    String? aiSummary,
    bool? isLoading,
  }) {
    return SimulatorState(
      stopFoodDelivery: stopFoodDelivery ?? this.stopFoodDelivery,
      cancelUnusedSubs: cancelUnusedSubs ?? this.cancelUnusedSubs,
      reduceShopping: reduceShopping ?? this.reduceShopping,
      customSlider: customSlider ?? this.customSlider,
      monthlySavings: monthlySavings ?? this.monthlySavings,
      quarterlySavings: quarterlySavings ?? this.quarterlySavings,
      halfYearlySavings: halfYearlySavings ?? this.halfYearlySavings,
      yearlySavings: yearlySavings ?? this.yearlySavings,
      nearestGoal: nearestGoal ?? this.nearestGoal,
      originalGoalDate: originalGoalDate ?? this.originalGoalDate,
      newGoalDate: newGoalDate ?? this.newGoalDate,
      daysSaved: daysSaved ?? this.daysSaved,
      aiSummary: aiSummary ?? this.aiSummary,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SimulatorNotifier extends AutoDisposeAsyncNotifier<SimulatorState> {
  @override
  Future<SimulatorState> build() async {
    final mockData = await ref.watch(mockDataServiceProvider.future);
    
    final goals = mockData.getGoals();
    Goal? nearestGoal;
    if (goals.isNotEmpty) {
      nearestGoal = goals.where((g) => !g.isCompleted).reduce(
          (curr, next) => curr.progressPercentage > next.progressPercentage ? curr : next);
    }

    final DateTime originalDate = nearestGoal != null
        ? FinanceCalculator.calculateGoalProjection(nearestGoal, nearestGoal.monthlyContributionTarget)
        : DateTime.now();

    return SimulatorState(
      stopFoodDelivery: false,
      cancelUnusedSubs: false,
      reduceShopping: false,
      customSlider: 0.0,
      monthlySavings: 0.0,
      quarterlySavings: 0.0,
      halfYearlySavings: 0.0,
      yearlySavings: 0.0,
      nearestGoal: nearestGoal,
      originalGoalDate: originalDate,
      newGoalDate: originalDate,
      daysSaved: 0,
      aiSummary: 'Select savings toggles above to simulate goal timeline acceleration.',
      isLoading: false,
    );
  }

  Future<void> updateScenarios({
    bool? stopFoodDelivery,
    bool? cancelUnusedSubs,
    bool? reduceShopping,
    double? customSlider,
  }) async {
    state = const AsyncValue.loading();

    final mockData = ref.read(mockDataServiceProvider).requireValue;
    final aiService = ref.read(aiServiceProvider);
    
    // Get current toggle states or use existing
    final current = state.value!;
    final sFood = stopFoodDelivery ?? current.stopFoodDelivery;
    final sSubs = cancelUnusedSubs ?? current.cancelUnusedSubs;
    final sShop = reduceShopping ?? current.reduceShopping;
    final sSlider = customSlider ?? current.customSlider;

    final transactions = mockData.getTransactions();

    // 1. Calculate savings using static calculator
    final scenariosMap = {
      'stop_food_delivery': sFood ? 1.0 : 0.0,
      'cancel_underused_subs': sSubs ? 1.0 : 0.0,
      'reduce_shopping_20': sShop ? 1.0 : 0.0,
      'custom_slider': sSlider,
    };

    final savings = FinanceCalculator.calculateSavingsSimulation(transactions, scenariosMap);
    final monthly = savings['monthly'] ?? 0.0;

    // 2. Recalculate goal date acceleration
    final goal = current.nearestGoal;
    DateTime newDate = current.originalGoalDate;
    int daysSaved = 0;

    if (goal != null) {
      // New contribution rate is original target + simulated monthly savings
      final newContributionRate = goal.monthlyContributionTarget + monthly;
      newDate = FinanceCalculator.calculateGoalProjection(goal, newContributionRate);
      daysSaved = current.originalGoalDate.difference(newDate).inDays;
    }

    // 3. Ask Gemini for explanatory sentence
    String aiSummary = 'Select savings toggles above to simulate goal timeline acceleration.';
    if (monthly > 0) {
      final List<String> enabled = [];
      if (sFood) enabled.add('cooking on weekends');
      if (sSubs) enabled.add('cancelling underused subscriptions');
      if (sShop) enabled.add('cutting shopping spend by 20%');
      if (sSlider > 0) enabled.add('saving ₹${sSlider.toStringAsFixed(0)}/mo');

      final contextMap = {
        'scenarios': enabled.join(', '),
        'monthly': '₹${monthly.toStringAsFixed(0)}',
        'yearly': '₹${(monthly * 12).toStringAsFixed(0)}',
        'goalProgress': goal != null 
            ? 'accelerating your "${goal.name}" goal by $daysSaved days'
            : 'accumulating a larger emergency cushion',
      };

      aiSummary = await aiService.generateSavingsSummary(contextMap);
    }

    state = AsyncValue.data(SimulatorState(
      stopFoodDelivery: sFood,
      cancelUnusedSubs: sSubs,
      reduceShopping: sShop,
      customSlider: sSlider,
      monthlySavings: monthly,
      quarterlySavings: savings['quarterly'] ?? 0.0,
      halfYearlySavings: savings['halfYearly'] ?? 0.0,
      yearlySavings: savings['yearly'] ?? 0.0,
      nearestGoal: goal,
      originalGoalDate: current.originalGoalDate,
      newGoalDate: newDate,
      daysSaved: daysSaved.clamp(0, 9999),
      aiSummary: aiSummary,
      isLoading: false,
    ));
  }
}

final simulatorControllerProvider = AutoDisposeAsyncNotifierProvider<SimulatorNotifier, SimulatorState>(() {
  return SimulatorNotifier();
});
