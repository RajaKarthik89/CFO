import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';
import '../../widgets/cfo_card.dart';
import '../../widgets/amount_text.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  int _selectedDays = 30;

  @override
  Widget build(BuildContext context) {
    final cfo = context.cfoColors;

    return Scaffold(
      backgroundColor: cfo.canvas,
      appBar: AppBar(
        title: Text(
          'PREDICTIVE FORECAST',
          style: context.uiHeader.copyWith(letterSpacing: 1.0),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // ── Cash Flow Runway Card ──
            CFOCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CASH FLOW RUNWAY', style: context.uiLabel),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '11.2',
                        style: GoogleFonts.fraunces(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: cfo.brassGold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MONTHS',
                        style: context.uiHeader.copyWith(
                          fontSize: 14,
                          color: cfo.brassGold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based on average monthly expenses (₹64,200) and current liquid cash reserves (₹7,20,000).',
                    style: context.uiLabel.copyWith(fontSize: 11, color: cfo.mutedSlate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Forecast Timeline Toggle & Visual ──
            Text(
              'FORECASTED CASH TIMELINE',
              style: context.uiLabel.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            CFOCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Days Toggle
                  Row(
                    children: [30, 60, 90].map((days) {
                      final isSelected = _selectedDays == days;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDays = days),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFC9A44C).withOpacity(0.15) : cfo.canvas,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFC9A44C) : const Color(0xFF1B2036),
                                width: isSelected ? 1.0 : 0.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$days Days',
                                style: context.uiLabel.copyWith(
                                  fontSize: 12,
                                  color: isSelected ? const Color(0xFFC9A44C) : cfo.mutedSlate,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Visual bar chart representations
                  _RunwayBar(
                    label: 'Projected Income',
                    amount: _selectedDays == 30 ? 120000 : _selectedDays == 60 ? 240000 : 360000,
                    color: cfo.brassGold,
                    maxAmount: 360000,
                  ),
                  const SizedBox(height: 16),
                  _RunwayBar(
                    label: 'Projected Expenses',
                    amount: _selectedDays == 30 ? 64200 : _selectedDays == 60 ? 128400 : 192600,
                    color: cfo.warningRust,
                    maxAmount: 360000,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Smart Alerts Panel ──
            Text(
              'AI SMART ALERTS',
              style: context.uiLabel.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _SmartAlertCard(
              title: 'Food Budget Breached Risk',
              message: 'Based on your current spending trends, you are likely to breach your food budget by next Thursday.',
              isUrgent: true,
              cfo: cfo,
              context: context,
            ),
            const SizedBox(height: 12),
            _SmartAlertCard(
              title: 'Subscription Overlap',
              message: 'We noticed a duplicate streaming expense. Cancelling one can save you ₹1,788 annually.',
              isUrgent: false,
              cfo: cfo,
              context: context,
            ),
          ],
        ),
      ),
    );
  }
}

class _RunwayBar extends StatelessWidget {
  const _RunwayBar({
    required this.label,
    required this.amount,
    required this.color,
    required this.maxAmount,
  });

  final String label;
  final double amount;
  final Color color;
  final double maxAmount;

  @override
  Widget build(BuildContext context) {
    final pct = (amount / maxAmount).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: context.uiLabel.copyWith(fontSize: 11)),
            AmountText(amount, size: AmountSize.small, type: AmountType.neutral),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1B2036).withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              height: 8,
              width: MediaQuery.of(context).size.width * 0.7 * pct,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SmartAlertCard extends StatelessWidget {
  const _SmartAlertCard({
    required this.title,
    required this.message,
    required this.isUrgent,
    required this.cfo,
    required this.context,
  });

  final String title;
  final String message;
  final bool isUrgent;
  final CFOColors cfo;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return CFOCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isUrgent ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            color: isUrgent ? cfo.warningRust : cfo.brassGold,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.uiHeader.copyWith(
                    fontSize: 13,
                    color: isUrgent ? cfo.warningRust : cfo.warmWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: context.uiLabel.copyWith(fontSize: 11, color: cfo.mutedSlate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
