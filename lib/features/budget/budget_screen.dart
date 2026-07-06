import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../widgets/cfo_card.dart';
import '../../widgets/amount_text.dart';
import 'budget_controller.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(budgetControllerProvider);
    final cfo = context.cfoColors;

    return Scaffold(
      backgroundColor: cfo.canvas,
      appBar: AppBar(
        title: Text(
          'AUTOMATIC BUDGETS',
          style: context.uiHeader.copyWith(letterSpacing: 1.0),
        ),
      ),
      body: stateAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC9A44C)),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error loading budget plan.',
            style: context.uiLabel.copyWith(color: cfo.warningRust),
          ),
        ),
        data: (state) {
          final sortedBudgets = state.budgets.values.toList()
            ..sort((a, b) => b.percentage.compareTo(a.percentage));

          final overallPercentage = state.totalBudgetLimit > 0
              ? (state.totalSpent / state.totalBudgetLimit)
              : 0.0;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                // ── Overall Budget Summary Card ───────
                CFOCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OVERALL SPENDING BUDGET (JUNE)', style: context.uiLabel),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          AmountText(state.totalSpent, size: AmountSize.large),
                          const SizedBox(width: 8),
                          Text('of', style: context.uiLabel),
                          const SizedBox(width: 8),
                          AmountText(
                            state.totalBudgetLimit,
                            size: AmountSize.medium,
                            type: AmountType.neutral,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: overallPercentage.clamp(0.0, 1.0),
                          backgroundColor: cfo.canvas,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            overallPercentage > 0.8 ? cfo.warningRust : cfo.brassGold,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Budgets are auto-computed from a 3-month rolling average',
                        style: context.uiLabel.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Categories Header ─────────────────
                Text(
                  'CATEGORY BUDGETS',
                  style: context.uiLabel.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Category List ─────────────────────
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedBudgets.length,
                  itemBuilder: (context, index) {
                    final budgetCat = sortedBudgets[index];
                    final cat = budgetCat.category;
                    final spent = budgetCat.spent;
                    final limit = budgetCat.budget;
                    final percent = budgetCat.percentage;

                    final isOver80 = percent >= 0.8;
                    final tip = state.categoryTips[cat];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CFOCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cat.toUpperCase(),
                                  style: context.uiHeader.copyWith(fontSize: 13),
                                ),
                                Row(
                                  children: [
                                    AmountText(
                                      spent,
                                      size: AmountSize.small,
                                      type: isOver80 ? AmountType.warning : AmountType.debit,
                                    ),
                                    Text(' / ', style: context.numberSmall),
                                    AmountText(
                                      limit,
                                      size: AmountSize.small,
                                      type: AmountType.neutral,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: percent.clamp(0.0, 1.0),
                                backgroundColor: cfo.canvas,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isOver80 ? cfo.warningRust : cfo.brassGold,
                                ),
                                minHeight: 4,
                              ),
                            ),
                            if (isOver80 && tip != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline_rounded,
                                    size: 14,
                                    color: cfo.warningRust,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: context.aiQuoteItalic.copyWith(
                                        fontSize: 13,
                                        color: cfo.mutedSlate,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
