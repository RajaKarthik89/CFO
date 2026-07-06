import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../widgets/cfo_card.dart';

class TaxPlanningScreen extends StatelessWidget {
  const TaxPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cfo = context.cfoColors;

    return Scaffold(
      backgroundColor: cfo.canvas,
      appBar: AppBar(
        title: Text(
          'TAX PLANNING (FY 2026-27)',
          style: context.uiHeader.copyWith(letterSpacing: 1.0),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // ── Section 80C Progress ──
            CFOCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SECTION 80C LIMIT', style: context.uiHeader.copyWith(fontSize: 14)),
                      Text('₹1,20,000 / ₹1,50,000', style: context.numberMedium.copyWith(color: cfo.brassGold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: 120000 / 150000,
                      minHeight: 6,
                      backgroundColor: cfo.canvas,
                      valueColor: AlwaysStoppedAnimation<Color>(cfo.brassGold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹30,000 remaining to maximize your Section 80C deductions.',
                    style: context.uiLabel.copyWith(fontSize: 11, color: cfo.mutedSlate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Section 80D Progress ──
            CFOCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SECTION 80D LIMIT', style: context.uiHeader.copyWith(fontSize: 14)),
                      Text('₹20,000 / ₹25,000', style: context.numberMedium.copyWith(color: cfo.brassGold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: 20000 / 25000,
                      minHeight: 6,
                      backgroundColor: cfo.canvas,
                      valueColor: AlwaysStoppedAnimation<Color>(cfo.brassGold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹5,000 remaining to maximize health insurance deductions.',
                    style: context.uiLabel.copyWith(fontSize: 11, color: cfo.mutedSlate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── AI Optimization Recommendations ──
            Text(
              'TAX OPTIMIZATION ADVICE',
              style: context.uiLabel.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            CFOCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome_rounded, color: cfo.brassGold, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invest ₹30,000 in ELSS Funds', style: context.uiHeader.copyWith(fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          'By investing the remaining ₹30,000 of your 80C limit into ELSS mutual funds, you will save an additional ₹9,000 in taxes under the 30% tax bracket.',
                          style: context.uiLabel.copyWith(fontSize: 11, color: cfo.mutedSlate),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Automated Tax Document Aggregator ──
            Text(
              'TAX DOCUMENT FOLDERS',
              style: context.uiLabel.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _DocFolderRow(
              title: 'ELSS & Mutual Fund Receipts',
              count: 4,
              cfo: cfo,
              context: context,
            ),
            const SizedBox(height: 12),
            _DocFolderRow(
              title: 'Health Insurance Premium (80D)',
              count: 1,
              cfo: cfo,
              context: context,
            ),
            const SizedBox(height: 12),
            _DocFolderRow(
              title: 'Rent Receipts & HRA docs',
              count: 6,
              cfo: cfo,
              context: context,
            ),
            const SizedBox(height: 12),
            _DocFolderRow(
              title: 'EPF / PF Passbook Copies',
              count: 2,
              cfo: cfo,
              context: context,
            ),
          ],
        ),
      ),
    );
  }
}

class _DocFolderRow extends StatelessWidget {
  const _DocFolderRow({
    required this.title,
    required this.count,
    required this.cfo,
    required this.context,
  });

  final String title;
  final int count;
  final CFOColors cfo;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return CFOCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.folder_open_rounded, color: cfo.brassGold, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.uiHeader.copyWith(fontSize: 13)),
                const SizedBox(height: 2),
                Text('$count documents categorized', style: context.uiLabel.copyWith(fontSize: 10, color: cfo.mutedSlate)),
              ],
            ),
          ),
          Icon(Icons.cloud_upload_rounded, color: cfo.mutedSlate, size: 20),
        ],
      ),
    );
  }
}
