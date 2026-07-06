import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../widgets/cfo_card.dart';
import '../../widgets/insight_banner.dart';
import 'health_score_controller.dart';

class HealthScoreScreen extends ConsumerWidget {
  const HealthScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(healthScoreControllerProvider);
    final cfo = context.cfoColors;

    return Scaffold(
      backgroundColor: cfo.canvas,
      appBar: AppBar(
        title: Text(
          'FINANCIAL HEALTH',
          style: context.uiHeader.copyWith(letterSpacing: 1.0),
        ),
      ),
      body: stateAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC9A44C)),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error loading health assessment.',
            style: context.uiLabel.copyWith(color: cfo.warningRust),
          ),
        ),
        data: (state) {
          final score = state.healthScore.overallScore;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                // ── Large Circular Score ───────────────
                Center(
                  child: Container(
                    width: 160,
                    height: 160,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background track
                        CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 4,
                          color: cfo.cardSurface,
                        ),
                        // Animated progress
                        CircularProgressIndicator(
                          value: score / 100.0,
                          strokeWidth: 4,
                          color: score >= 70 ? cfo.brassGold : cfo.warningRust,
                        ),
                        // Numeric score
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$score',
                              style: context.numberLarge.copyWith(fontSize: 48),
                            ),
                            Text(
                              'HEALTH SCORE',
                              style: context.uiLabel.copyWith(
                                fontSize: 9,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── AI Explanation ─────────────────────
                InsightBanner(
                  text: state.aiReasoning,
                  accentColor: score >= 70 ? cfo.brassGold : cfo.warningRust,
                ),

                const SizedBox(height: 32),

                // ── Factor Breakdown List ──────────────
                Text(
                  'HEALTH FACTORS BREAKDOWN',
                  style: context.uiLabel.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.healthScore.factors.length,
                  itemBuilder: (context, index) {
                    final factor = state.healthScore.factors[index];
                    final factorScore = factor.score;
                    final isLow = factorScore < 60;

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
                                  factor.name.toUpperCase(),
                                  style: context.uiHeader.copyWith(fontSize: 13),
                                ),
                                Text(
                                  '$factorScore / 100',
                                  style: context.numberMedium.copyWith(
                                    fontSize: 14,
                                    color: isLow ? cfo.warningRust : cfo.brassGold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: factorScore / 100.0,
                                backgroundColor: cfo.canvas,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isLow ? cfo.warningRust : cfo.brassGold,
                                ),
                                minHeight: 4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              factor.description,
                              style: context.uiLabel.copyWith(
                                fontSize: 12,
                                color: cfo.warmWhite.withValues(alpha: 0.8),
                                height: 1.4,
                              ),
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
}
