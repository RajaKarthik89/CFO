import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../widgets/cfo_card.dart';
import '../../widgets/amount_text.dart';
import '../../widgets/insight_banner.dart';
import 'simulator_controller.dart';

class SimulatorScreen extends ConsumerWidget {
  const SimulatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(simulatorControllerProvider);
    final cfo = context.cfoColors;

    return Scaffold(
      backgroundColor: cfo.canvas,
      appBar: AppBar(
        title: Text(
          'SAVINGS SIMULATOR',
          style: context.uiHeader.copyWith(letterSpacing: 1.0),
        ),
      ),
      body: stateAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC9A44C)),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error loading simulator.',
            style: context.uiLabel.copyWith(color: cfo.warningRust),
          ),
        ),
        data: (state) {
          final notifier = ref.read(simulatorControllerProvider.notifier);
          final newDateStr = DateFormat('MMM d, yyyy').format(state.newGoalDate);

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                // ── Savings Toggles ───────────────────
                Text(
                  'ADJUST SPENDING HABITS',
                  style: context.uiLabel.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                CFOCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Toggle 1
                      SwitchListTile(
                        title: Text('Stop Swiggy/Zomato on weekends', style: context.uiHeader.copyWith(fontSize: 14)),
                        subtitle: Text('Cook at home instead', style: context.uiLabel.copyWith(fontSize: 11)),
                        value: state.stopFoodDelivery,
                        activeThumbColor: cfo.brassGold,
                        inactiveTrackColor: cfo.canvas,
                        onChanged: (val) => notifier.updateScenarios(stopFoodDelivery: val),
                      ),
                      const Divider(indent: 16, endIndent: 16),
                      // Toggle 2
                      SwitchListTile(
                        title: Text('Cancel underused Netflix subscription', style: context.uiHeader.copyWith(fontSize: 14)),
                        subtitle: Text('Saves ₹649/month', style: context.uiLabel.copyWith(fontSize: 11)),
                        value: state.cancelUnusedSubs,
                        activeThumbColor: cfo.brassGold,
                        inactiveTrackColor: cfo.canvas,
                        onChanged: (val) => notifier.updateScenarios(cancelUnusedSubs: val),
                      ),
                      const Divider(indent: 16, endIndent: 16),
                      // Toggle 3
                      SwitchListTile(
                        title: Text('Reduce optional shopping by 20%', style: context.uiHeader.copyWith(fontSize: 14)),
                        subtitle: Text('Saves average ₹1,200/month', style: context.uiLabel.copyWith(fontSize: 11)),
                        value: state.reduceShopping,
                        activeThumbColor: cfo.brassGold,
                        inactiveTrackColor: cfo.canvas,
                        onChanged: (val) => notifier.updateScenarios(reduceShopping: val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Custom slider ─────────────────────
                CFOCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ADDITIONAL MONTHLY SAVINGS', style: context.uiLabel),
                          AmountText(state.customSlider, size: AmountSize.small, type: AmountType.credit),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: state.customSlider,
                        min: 0.0,
                        max: 10000.0,
                        divisions: 20,
                        activeColor: cfo.brassGold,
                        inactiveColor: cfo.canvas,
                        onChanged: (val) => notifier.updateScenarios(customSlider: val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── AI Summary explanation ─────────────
                InsightBanner(
                  text: state.aiSummary,
                  isItalic: state.monthlySavings > 0,
                  accentColor: state.monthlySavings > 0 ? cfo.brassGold : cfo.mutedSlate,
                ),

                const SizedBox(height: 28),

                // ── Projected Impact metrics ───────────
                if (state.monthlySavings > 0) ...[
                  Text(
                    'GOAL ACCELERATION IMPACT',
                    style: context.uiLabel.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  CFOCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('MONTHLY ADDITIONS', style: context.uiLabel),
                            AmountText(state.monthlySavings, size: AmountSize.medium, type: AmountType.credit),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('TARGET ACQUISITION DATE', style: context.uiLabel),
                            Text(
                              newDateStr,
                              style: context.numberMedium.copyWith(color: cfo.brassGold),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('DAYS ACCELERATED', style: context.uiLabel),
                            Text(
                              '${state.daysSaved} days sooner',
                              style: context.numberMedium.copyWith(color: cfo.brassGold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Chart Trajectory ──────────────────
                  Text(
                    'SAVINGS TRAJECTORY PROJECTION',
                    style: context.uiLabel.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  CFOCard(
                    padding: const EdgeInsets.fromLTRB(12, 28, 28, 12),
                    child: SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0) return Text('Now', style: context.uiLabel.copyWith(fontSize: 9));
                                  if (value == 3) return Text('3m', style: context.uiLabel.copyWith(fontSize: 9));
                                  if (value == 6) return Text('6m', style: context.uiLabel.copyWith(fontSize: 9));
                                  if (value == 12) return Text('12m', style: context.uiLabel.copyWith(fontSize: 9));
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            // Baseline (Trajectory 1)
                            LineChartBarData(
                              spots: [
                                const FlSpot(0, 0),
                                const FlSpot(3, 0),
                                const FlSpot(6, 0),
                                const FlSpot(12, 0),
                              ],
                              color: cfo.mutedSlate.withValues(alpha: 0.3),
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                            // Simulated trajectory (Trajectory 2)
                            LineChartBarData(
                              spots: [
                                const FlSpot(0, 0),
                                FlSpot(3, state.quarterlySavings),
                                FlSpot(6, state.halfYearlySavings),
                                FlSpot(12, state.yearlySavings),
                              ],
                              color: cfo.brassGold,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
