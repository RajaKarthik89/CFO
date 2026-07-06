import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../widgets/cfo_card.dart';
import '../../widgets/amount_text.dart';

class MicroSavingsScreen extends StatefulWidget {
  const MicroSavingsScreen({super.key});

  @override
  State<MicroSavingsScreen> createState() => _MicroSavingsScreenState();
}

class _MicroSavingsScreenState extends State<MicroSavingsScreen> {
  bool _roundUpsEnabled = true;
  double _roundUpLimit = 10.0;
  double _savedTotal = 346.0;

  @override
  Widget build(BuildContext context) {
    final cfo = context.cfoColors;

    return Scaffold(
      backgroundColor: cfo.canvas,
      appBar: AppBar(
        title: Text(
          'AUTOMATED MICRO-SAVINGS',
          style: context.uiHeader.copyWith(letterSpacing: 1.0),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // ── Micro Savings Hero Card ──
            CFOCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL MICRO-SAVED', style: context.uiLabel),
                  const SizedBox(height: 8),
                  AmountText(_savedTotal, size: AmountSize.hero),
                  const SizedBox(height: 8),
                  Text(
                    'Automatically rounded up from your UPI transactions and added directly to your "Goa Trip" goal.',
                    style: context.uiLabel.copyWith(fontSize: 11, color: cfo.mutedSlate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Settings Selector ──
            Text(
              'ROUND-UP SETTINGS',
              style: context.uiLabel.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            CFOCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UPI Round-ups', style: context.uiHeader.copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('Save change to nearest increment', style: context.uiLabel.copyWith(fontSize: 10)),
                        ],
                      ),
                      Switch(
                        value: _roundUpsEnabled,
                        onChanged: (val) => setState(() => _roundUpsEnabled = val),
                        activeColor: cfo.brassGold,
                        activeTrackColor: cfo.brassGold.withOpacity(0.2),
                      ),
                    ],
                  ),
                  if (_roundUpsEnabled) ...[
                    const Divider(color: Color(0xFF1B2036), height: 24, thickness: 0.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Round-up Increment', style: context.uiHeader.copyWith(fontSize: 13)),
                        Row(
                          children: [10, 50].map((val) {
                            final isSelected = _roundUpLimit == val;
                            return GestureDetector(
                              onTap: () => setState(() => _roundUpLimit = val.toDouble()),
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFC9A44C).withOpacity(0.15) : cfo.canvas,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFC9A44C) : const Color(0xFF1B2036),
                                    width: isSelected ? 1.0 : 0.5,
                                  ),
                                ),
                                child: Text(
                                  '₹$val',
                                  style: context.uiLabel.copyWith(
                                    fontSize: 11,
                                    color: isSelected ? const Color(0xFFC9A44C) : cfo.mutedSlate,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Recent Round-ups ──
            Text(
              'RECENT MICRO-SAVINGS',
              style: context.uiLabel.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _MicroTransactionRow(
              merchant: 'Swiggy Delivery',
              spent: 244.0,
              saved: 6.0,
              cfo: cfo,
              context: context,
            ),
            const SizedBox(height: 12),
            _MicroTransactionRow(
              merchant: 'Uber Rides',
              spent: 188.0,
              saved: 12.0,
              cfo: cfo,
              context: context,
            ),
            const SizedBox(height: 12),
            _MicroTransactionRow(
              merchant: 'Starbucks Coffee',
              spent: 345.0,
              saved: 5.0,
              cfo: cfo,
              context: context,
            ),
          ],
        ),
      ),
    );
  }
}

class _MicroTransactionRow extends StatelessWidget {
  const _MicroTransactionRow({
    required this.merchant,
    required this.spent,
    required this.saved,
    required this.cfo,
    required this.context,
  });

  final String merchant;
  final double spent;
  final double saved;
  final CFOColors cfo;
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
              Text(merchant, style: context.uiHeader.copyWith(fontSize: 13)),
              const SizedBox(height: 2),
              Text('Spent ₹${spent.toStringAsFixed(0)}', style: context.uiLabel.copyWith(fontSize: 10, color: cfo.mutedSlate)),
            ],
          ),
          Row(
            children: [
              Text(
                'Round-up: ',
                style: context.uiLabel.copyWith(fontSize: 11, color: cfo.mutedSlate),
              ),
              Text(
                '+₹${saved.toStringAsFixed(0)}',
                style: context.numberMedium.copyWith(color: cfo.brassGold, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
