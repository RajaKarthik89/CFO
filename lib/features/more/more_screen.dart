import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';
import '../../widgets/cfo_card.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _items = [
    _MoreItem(
      title: 'Health Score',
      subtitle: 'Your financial fitness score',
      icon: Icons.favorite_border_rounded,
      route: '/health-score',
    ),
    _MoreItem(
      title: 'Goals',
      subtitle: 'Track active savings goals',
      icon: Icons.flag_outlined,
      route: '/goals',
    ),
    _MoreItem(
      title: 'Subscriptions',
      subtitle: 'Manage active subscriptions',
      icon: Icons.repeat_rounded,
      route: '/subscriptions',
    ),
    _MoreItem(
      title: 'Simulator',
      subtitle: 'What-if savings scenarios',
      icon: Icons.science_outlined,
      route: '/simulator',
    ),
    _MoreItem(
      title: 'Search',
      subtitle: 'Search in plain English',
      icon: Icons.search_rounded,
      route: '/search',
    ),
    _MoreItem(
      title: 'Forecast',
      subtitle: 'Income & expense runway',
      icon: Icons.analytics_outlined,
      route: '/forecast',
    ),
    _MoreItem(
      title: 'Wealth & Net Worth',
      subtitle: 'Portfolio & asset tracker',
      icon: Icons.account_balance_wallet_outlined,
      route: '/wealth',
    ),
    _MoreItem(
      title: 'Tax Planning',
      subtitle: 'Section 80C & 80D planner',
      icon: Icons.percent_rounded,
      route: '/tax-planning',
    ),
    _MoreItem(
      title: 'Credit Health',
      subtitle: 'CIBIL score & optimizer',
      icon: Icons.credit_score_rounded,
      route: '/credit-health',
    ),
    _MoreItem(
      title: 'Auto-Savings',
      subtitle: 'Round-ups & micro-saving',
      icon: Icons.savings_outlined,
      route: '/micro-savings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cfo = context.cfoColors;

    return Scaffold(
      backgroundColor: cfo.canvas,
      appBar: AppBar(
        title: Text(
          'MORE FEATURES',
          style: context.uiHeader.copyWith(letterSpacing: 1.0),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                mainAxisExtent: 130,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return CFOCard(
                  onTap: () => context.push(item.route),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: cfo.canvas,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(item.icon, color: cfo.brassGold, size: 20),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.title,
                        style: context.uiHeader.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        style: context.uiLabel.copyWith(fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 48),

            // ── App Info ────────────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    'CFO',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cfo.warmWhite,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your AI Financial Operating System',
                    style: context.uiLabel.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v1.0.0 (Demo Mode)',
                    style: context.uiLabel.copyWith(
                      fontSize: 10,
                      color: cfo.mutedSlate.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreItem {
  const _MoreItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}
