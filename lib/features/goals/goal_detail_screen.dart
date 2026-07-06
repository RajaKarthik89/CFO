import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../widgets/cfo_card.dart';
import '../../widgets/amount_text.dart';
import '../../widgets/insight_banner.dart';
import 'goals_controller.dart';

class GoalDetailScreen extends ConsumerStatefulWidget {
  const GoalDetailScreen({super.key, required this.goalId});
  final String goalId;

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onSimulate() {
    final text = _amountController.text.trim();
    if (text.isEmpty) {
      ref.read(goalDetailControllerProvider(widget.goalId).notifier).simulatePurchase(0);
      return;
    }
    final double? amt = double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (amt != null) {
      ref.read(goalDetailControllerProvider(widget.goalId).notifier).simulatePurchase(amt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(goalDetailControllerProvider(widget.goalId));
    final cfo = context.cfoColors;

    return Scaffold(
      backgroundColor: cfo.canvas,
      appBar: AppBar(
        title: Text(
          'GOAL DECISION MATRIX',
          style: context.uiHeader.copyWith(letterSpacing: 1.0),
        ),
      ),
      body: stateAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC9A44C)),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error loading goal details.',
            style: context.uiLabel.copyWith(color: cfo.warningRust),
          ),
        ),
        data: (state) {
          final goal = state.goal;
          final dateStr = DateFormat('MMMM d, YYYY').format(goal.targetDate);
          final projDateStr = DateFormat('MMMM d, YYYY').format(state.projectedDate);

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                // ── Goal Identity ─────────────────────
                CFOCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.name, style: context.uiHeader.copyWith(fontSize: 18)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TARGET DATE', style: context.uiLabel),
                          Text(dateStr, style: context.uiHeader.copyWith(fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('MONTHLY COMMITMENT', style: context.uiLabel),
                          AmountText(goal.monthlyContributionTarget, size: AmountSize.small),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: goal.progressPercentage / 100.0,
                          backgroundColor: cfo.canvas,
                          valueColor: AlwaysStoppedAnimation<Color>(cfo.brassGold),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AmountText(goal.savedAmount, size: AmountSize.small, type: AmountType.credit),
                          Text(
                            '${goal.progressPercentage.toStringAsFixed(0)}% saved',
                            style: context.uiLabel.copyWith(fontSize: 11),
                          ),
                          AmountText(goal.targetAmount, size: AmountSize.small, type: AmountType.neutral),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Decision Simulator Section ────────
                Text(
                  'DECISION SIMULATOR',
                  style: context.uiLabel.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                CFOCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Simulate a purchase impact:',
                        style: context.uiHeader.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Deducts amount from current savings to project delay',
                        style: context.uiLabel.copyWith(fontSize: 11),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              style: context.numberMedium,
                              cursorColor: cfo.brassGold,
                              decoration: InputDecoration(
                                hintText: 'Enter purchase amount (e.g. ₹15,000)',
                                prefixText: '₹ ',
                                prefixStyle: context.numberMedium.copyWith(color: cfo.mutedSlate),
                              ),
                              onChanged: (_) => _onSimulate(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── AI Explanation ─────────────────────
                InsightBanner(
                  text: state.aiImpactExplanation,
                  isItalic: state.simulatedPurchaseAmount > 0,
                  accentColor: state.simulatedPurchaseAmount > 0 ? cfo.warningRust : cfo.brassGold,
                  icon: state.simulatedPurchaseAmount > 0 
                      ? Icons.warning_amber_rounded 
                      : Icons.auto_awesome_rounded,
                ),

                const SizedBox(height: 24),

                // ── Simulated Metrics Breakdown ────────
                if (state.simulatedPurchaseAmount > 0)
                  CFOCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('NEW PROJECTED DATE', style: context.uiLabel),
                            Text(
                              projDateStr,
                              style: context.numberMedium.copyWith(
                                color: state.daysDelayed > 0 ? cfo.warningRust : cfo.warmWhite,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('PROJECTED DELAY', style: context.uiLabel),
                            Text(
                              '${state.daysDelayed} days',
                              style: context.numberMedium.copyWith(color: cfo.warningRust),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('ADJUSTED TARGET SAVINGS', style: context.uiLabel),
                            AmountText(
                              state.newMonthlyRequired,
                              size: AmountSize.medium,
                              type: AmountType.warning,
                              prefix: '',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Required monthly to meet original target date',
                            style: context.uiLabel.copyWith(fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
