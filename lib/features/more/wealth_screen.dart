import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../widgets/cfo_card.dart';
import '../../widgets/amount_text.dart';

class WealthScreen extends StatefulWidget {
  const WealthScreen({super.key});

  @override
  State<WealthScreen> createState() => _WealthScreenState();
}

class _WealthScreenState extends State<WealthScreen> {
  // Mock asset and liability totals
  final double _savings = 720000;
  final double _mutualFunds = 1250000;
  final double _stocks = 450000;
  final double _providentFund = 320000;
  final double _gold = 180000;
  final double _crypto = 60000;

  final double _creditCardDue = 18450;
  final double _personalLoan = 450000;

  double get _totalAssets => _savings + _mutualFunds + _stocks + _providentFund + _gold + _crypto;
  double get _totalLiabilities => _creditCardDue + _personalLoan;
  double get _netWorth => _totalAssets - _totalLiabilities;

  void _showLinkAssetDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cfo = ctx.cfoColors;
        return Container(
          decoration: BoxDecoration(
            color: cfo.cardSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: const Color(0xFF1B2036), width: 0.5),
          ),
          padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: cfo.mutedSlate.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'LINK PORTFOLIO ASSET',
                style: ctx.uiHeader.copyWith(letterSpacing: 1.2, fontSize: 15),
              ),
              const SizedBox(height: 20),
              _LinkOptionTile(
                title: 'Mutual Funds / Stocks (via CAS)',
                icon: Icons.trending_up_rounded,
                subtitle: 'Auto-sync holding statement from CDSL/NSDL',
                cfo: cfo,
                context: ctx,
              ),
              const SizedBox(height: 12),
              _LinkOptionTile(
                title: 'Provident Fund (EPFO)',
                icon: Icons.account_balance_wallet_rounded,
                subtitle: 'Link using UAN & SMS OTP validation',
                cfo: cfo,
                context: ctx,
              ),
              const SizedBox(height: 12),
              _LinkOptionTile(
                title: 'Gold Reserves',
                icon: Icons.workspace_premium_rounded,
                subtitle: 'Manually add sovereign gold bonds or jewelry',
                cfo: cfo,
                context: ctx,
              ),
              const SizedBox(height: 12),
              _LinkOptionTile(
                title: 'Crypto Wallets & Exchanges',
                icon: Icons.currency_bitcoin_rounded,
                subtitle: 'Sync MetaMask, WazirX, or CoinDCX API',
                cfo: cfo,
                context: ctx,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfo = context.cfoColors;

    return Scaffold(
      backgroundColor: cfo.canvas,
      appBar: AppBar(
        title: Text(
          'WEALTH & NET WORTH',
          style: context.uiHeader.copyWith(letterSpacing: 1.0),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // ── Net Worth Live Ticker ──
            CFOCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ESTIMATED NET WORTH', style: context.uiLabel),
                  const SizedBox(height: 8),
                  AmountText(_netWorth, size: AmountSize.hero),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CompactWealthLabel(
                        label: 'Total Assets',
                        amount: _totalAssets,
                        color: cfo.brassGold,
                        context: context,
                      ),
                      _CompactWealthLabel(
                        label: 'Total Liabilities',
                        amount: _totalLiabilities,
                        color: cfo.warningRust,
                        context: context,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Portfolio Breakdown (Assets) ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PORTFOLIO ASSETS',
                  style: context.uiLabel.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: _showLinkAssetDialog,
                  child: Text(
                    '+ Link Asset',
                    style: context.uiLabel.copyWith(
                      color: cfo.brassGold,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _WealthBreakdownItem(
              title: 'Mutual Funds',
              amount: _mutualFunds,
              icon: Icons.pie_chart_rounded,
              cfo: cfo,
              context: context,
            ),
            const SizedBox(height: 12),
            _WealthBreakdownItem(
              title: 'Savings Account Balance',
              amount: _savings,
              icon: Icons.account_balance_rounded,
              cfo: cfo,
              context: context,
            ),
            const SizedBox(height: 12),
            _WealthBreakdownItem(
              title: 'Stocks Portfolio',
              amount: _stocks,
              icon: Icons.show_chart_rounded,
              cfo: cfo,
              context: context,
            ),
            const SizedBox(height: 12),
            _WealthBreakdownItem(
              title: 'Provident Funds (EPF/PPF)',
              amount: _providentFund,
              icon: Icons.security_rounded,
              cfo: cfo,
              context: context,
            ),
            const SizedBox(height: 12),
            _WealthBreakdownItem(
              title: 'Gold Assets',
              amount: _gold,
              icon: Icons.monetization_on_rounded,
              cfo: cfo,
              context: context,
            ),
            const SizedBox(height: 12),
            _WealthBreakdownItem(
              title: 'Crypto Holdings',
              amount: _crypto,
              icon: Icons.currency_exchange_rounded,
              cfo: cfo,
              context: context,
            ),
            const SizedBox(height: 24),

            // ── Liabilities Breakdown ──
            Text(
              'LIABILITIES & LOANS',
              style: context.uiLabel.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _WealthBreakdownItem(
              title: 'Personal Loan',
              amount: _personalLoan,
              icon: Icons.credit_score_rounded,
              cfo: cfo,
              context: context,
              isLiability: true,
            ),
            const SizedBox(height: 12),
            _WealthBreakdownItem(
              title: 'Credit Card Outstanding',
              amount: _creditCardDue,
              icon: Icons.credit_card_rounded,
              cfo: cfo,
              context: context,
              isLiability: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactWealthLabel extends StatelessWidget {
  const _CompactWealthLabel({
    required this.label,
    required this.amount,
    required this.color,
    required this.context,
  });

  final String label;
  final double amount;
  final Color color;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: context.uiLabel.copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            AmountText(amount, size: AmountSize.small, type: AmountType.neutral),
          ],
        ),
      ],
    );
  }
}

class _WealthBreakdownItem extends StatelessWidget {
  const _WealthBreakdownItem({
    required this.title,
    required this.amount,
    required this.icon,
    required this.cfo,
    required this.context,
    this.isLiability = false,
  });

  final String title;
  final double amount;
  final IconData icon;
  final CFOColors cfo;
  final BuildContext context;
  final bool isLiability;

  @override
  Widget build(BuildContext ctx) {
    return CFOCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cfo.canvas,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: isLiability ? cfo.warningRust : cfo.brassGold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: context.uiHeader.copyWith(fontSize: 13),
            ),
          ),
          AmountText(
            amount,
            size: AmountSize.small,
            type: isLiability ? AmountType.neutral : AmountType.neutral,
          ),
        ],
      ),
    );
  }
}

class _LinkOptionTile extends StatelessWidget {
  const _LinkOptionTile({
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.cfo,
    required this.context,
  });

  final String title;
  final IconData icon;
  final String subtitle;
  final CFOColors cfo;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cfo.canvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1B2036), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: cfo.brassGold, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.uiHeader.copyWith(fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: context.uiLabel.copyWith(fontSize: 10, color: cfo.mutedSlate)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: cfo.mutedSlate, size: 20),
        ],
      ),
    );
  }
}
