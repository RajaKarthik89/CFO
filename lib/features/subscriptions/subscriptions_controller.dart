import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/ai_service.dart';
import '../../models/models.dart';

class SubscriptionsState {
  final List<Subscription> subscriptions;
  final double totalMonthlyCost;
  final double potentialSavings;
  final Map<String, String> subscriptionTips;

  SubscriptionsState({
    required this.subscriptions,
    required this.totalMonthlyCost,
    required this.potentialSavings,
    required this.subscriptionTips,
  });
}

class SubscriptionsNotifier extends AsyncNotifier<SubscriptionsState> {
  List<Subscription>? _customList;

  @override
  Future<SubscriptionsState> build() async {
    final mockData = await ref.watch(mockDataServiceProvider.future);
    final aiService = ref.read(aiServiceProvider);

    final subs = _customList ?? List<Subscription>.from(mockData.getSubscriptions());
    _customList = subs;

    // 1. Calculate costs
    double totalCost = 0.0;
    double wasteCost = 0.0;
    for (final s in subs) {
      totalCost += s.monthlyCost;
      if (s.isWasteful) {
        wasteCost += s.monthlyCost;
      }
    }

    // 2. Fetch advice from AI for each subscription
    final Map<String, String> tips = {};
    for (final s in subs) {
      final contextMap = {
        'name': s.name,
        'cost': '₹${s.monthlyCost.toStringAsFixed(0)}/mo',
        'status': s.status.name,
        'reason': s.notes,
        'annualCost': '₹${s.annualCost.toStringAsFixed(0)}',
      };

      final advice = await aiService.generateSubscriptionAdvice(contextMap);
      tips[s.id] = advice;
    }

    return SubscriptionsState(
      subscriptions: subs,
      totalMonthlyCost: totalCost,
      potentialSavings: wasteCost,
      subscriptionTips: tips,
    );
  }

  Future<void> addSubscription(Subscription sub) async {
    final current = state.value;
    if (current == null) return;

    _customList = [...current.subscriptions, sub];
    
    // Invalidate self to re-run build asynchronously and generate AI advice
    ref.invalidateSelf();
    await future; // Wait for rebuilding to finish
  }
}

final subscriptionsControllerProvider = AsyncNotifierProvider<SubscriptionsNotifier, SubscriptionsState>(() {
  return SubscriptionsNotifier();
});
