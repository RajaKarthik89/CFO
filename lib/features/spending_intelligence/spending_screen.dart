import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme.dart';
import '../../widgets/cfo_card.dart';
import '../../widgets/amount_text.dart';
import '../../widgets/insight_banner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'spending_controller.dart';

class SpendingScreen extends ConsumerWidget {
  const SpendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(spendingControllerProvider);
    final cfo = context.cfoColors;

    return Scaffold(
      backgroundColor: cfo.canvas,
      appBar: AppBar(
        title: Text(
          'SPENDING INTELLIGENCE',
          style: context.uiHeader.copyWith(letterSpacing: 1.0),
        ),
      ),
      body: stateAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC9A44C)),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error loading spending narrative.',
            style: context.uiLabel.copyWith(color: cfo.warningRust),
          ),
        ),
        data: (state) {
          final sortedCategories = state.categorySpent.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                // ── Total Monthly Spending Card ────────
                CFOCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL SPEND (JUNE)', style: context.uiLabel),
                      const SizedBox(height: 8),
                      AmountText(state.totalSpent, size: AmountSize.hero),
                      const SizedBox(height: 4),
                      Text(
                        'Excludes savings & investment contributions',
                        style: context.uiLabel.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── AI Insight Banner ───────────────────
                InsightBanner(
                  text: state.aiNarrative,
                  accentColor: cfo.brassGold,
                ),

                const SizedBox(height: 28),

                // ── Chart Section ───────────────────────
                Text(
                  'CATEGORY DISTRIBUTION',
                  style: context.uiLabel.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                CFOCard(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 50,
                        sections: _buildChartSections(sortedCategories, cfo),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Breakdown List ──────────────────────
                Text(
                  'MONTH-OVER-MONTH BREAKDOWN',
                  style: context.uiLabel.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedCategories.length,
                  itemBuilder: (context, index) {
                    final entry = sortedCategories[index];
                    final cat = entry.key;
                    final amt = entry.value;

                    // Get MoM change percent
                    double changePercent = 0.0;
                    if (state.momChanges.containsKey(cat)) {
                      changePercent = state.momChanges[cat]!['changePercent'] ?? 0.0;
                    }

                    final isIncrease = changePercent > 0;
                    final isSignificant = changePercent.abs() >= 10.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CFOCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            // Color block matching chart slice
                            Container(
                              width: 6,
                              height: 24,
                              decoration: BoxDecoration(
                                color: index == 0
                                    ? cfo.brassGold
                                    : cfo.mutedSlate.withValues(
                                        alpha: 1.0 - (index * 0.18).clamp(0.2, 0.9)),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cat, style: context.uiHeader.copyWith(fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'June Spend',
                                    style: context.uiLabel.copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                AmountText(amt, size: AmountSize.medium),
                                const SizedBox(height: 2),
                                Text(
                                  '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(0)}% MoM',
                                  style: context.numberSmall.copyWith(
                                    fontSize: 10,
                                    color: isSignificant
                                        ? (isIncrease ? cfo.warningRust : cfo.brassGold)
                                        : cfo.mutedSlate,
                                  ),
                                ),
                              ],
                            ),
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

  List<PieChartSectionData> _buildChartSections(
    List<MapEntry<String, double>> entries,
    CFOColors cfo,
  ) {
    double total = entries.fold(0.0, (sum, e) => sum + e.value);
    if (total == 0) return [];

    return List.generate(entries.length, (index) {
      final entry = entries[index];
      final percentage = (entry.value / total) * 100;

      // Color mapping: primary largest is Gold, others are stepped slate colors
      final Color color;
      if (index == 0) {
        color = cfo.brassGold;
      } else {
        final opacity = 1.0 - (index * 0.18).clamp(0.2, 0.9);
        color = cfo.mutedSlate.withValues(alpha: opacity);
      }

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 20,
        showTitle: percentage > 8,
        titleStyle: GoogleFonts.ibmPlexMono(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: index == 0 ? cfo.canvas : cfo.warmWhite,
        ),
      );
    });
  }
}
