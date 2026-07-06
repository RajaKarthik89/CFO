import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';
import '../../widgets/cfo_card.dart';

class CreditHealthScreen extends StatelessWidget {
  const CreditHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cfo = context.cfoColors;

    return Scaffold(
      backgroundColor: cfo.canvas,
      appBar: AppBar(
        title: Text(
          'CREDIT HEALTH',
          style: context.uiHeader.copyWith(letterSpacing: 1.0),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // ── Score Dial Card ──
            CFOCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('CIBIL CREDIT SCORE', style: context.uiLabel),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: 785 / 900,
                          strokeWidth: 8,
                          backgroundColor: const Color(0xFF1B2036).withOpacity(0.3),
                          color: cfo.brassGold,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '785',
                            style: GoogleFonts.fraunces(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: cfo.warmWhite,
                            ),
                          ),
                          Text(
                            'EXCELLENT',
                            style: context.uiLabel.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: cfo.brassGold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Updated on Jul 1, 2026. Next update in 24 days.',
                    style: context.uiLabel.copyWith(fontSize: 10, color: cfo.mutedSlate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Utilization Optimizer Card ──
            Text(
              'CREDIT UTILIZATION OPTIMIZER',
              style: context.uiLabel.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            CFOCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: cfo.warningRust, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Utilization Alert (28%)',
                        style: context.uiHeader.copyWith(fontSize: 13, color: cfo.warningRust),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your HDFC Millennia card utilization is at 28% of the limit (₹2,50,000). Crossing 30% can negatively impact your credit profile.',
                    style: context.uiLabel.copyWith(fontSize: 11, color: cfo.mutedSlate),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cfo.canvas,
                        side: BorderSide(color: cfo.brassGold, width: 0.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Pay ₹15,000 Early to Optimize',
                        style: context.uiHeader.copyWith(
                          fontSize: 12,
                          color: cfo.brassGold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Score Factors ──
            Text(
              'CREDIT SCORE INFLUENCERS',
              style: context.uiLabel.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _FactorRow(
              title: 'On-Time Payments',
              status: '100%',
              impact: 'High',
              color: cfo.brassGold,
              context: context,
            ),
            const SizedBox(height: 12),
            _FactorRow(
              title: 'Credit Age',
              status: '4.2 Years',
              impact: 'Medium',
              color: cfo.brassGold,
              context: context,
            ),
            const SizedBox(height: 12),
            _FactorRow(
              title: 'Credit Inquiries',
              status: '0 in last 3 mo',
              impact: 'Low',
              color: cfo.brassGold,
              context: context,
            ),
          ],
        ),
      ),
    );
  }
}

class _FactorRow extends StatelessWidget {
  const _FactorRow({
    required this.title,
    required this.status,
    required this.impact,
    required this.color,
    required this.context,
  });

  final String title;
  final String status;
  final String impact;
  final Color color;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return CFOCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.uiHeader.copyWith(fontSize: 13)),
              const SizedBox(height: 2),
              Text('Impact: $impact', style: context.uiLabel.copyWith(fontSize: 10)),
            ],
          ),
          Text(
            status,
            style: context.numberMedium.copyWith(color: color, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
