import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../widgets/cfo_card.dart';
import '../../widgets/amount_text.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(dashboardControllerProvider);
    final cfo = context.cfoColors;
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: cfo.canvas,
      appBar: AppBar(
        title: Text(
          'CFO',
          style: context.uiHeader.copyWith(letterSpacing: 1.5, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              mode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: cfo.brassGold,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC9A44C)),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error loading financial profile.',
            style: context.uiLabel.copyWith(color: cfo.warningRust),
          ),
        ),
        data: (state) {
          // Trigger briefing card entrance animation

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                // ── "Waking Ledger" Briefing (Top Section) ──────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Flat two-tone block for modern restraint (Dawn theme)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Warm Top Deck
                                Container(
                                  width: double.infinity,
                                  color: cfo.wakingLedgerTop, // Muted warmer navy
                                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DAILY BRIEFING',
                                        style: context.uiLabel.copyWith(
                                          color: cfo.brassGold,
                                          letterSpacing: 1.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Good morning, Karthik.',
                                        style: context.aiBriefing.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Base Navy Bottom Deck (solid transition block)
                                Container(
                                  width: double.infinity,
                                  color: cfo.cardSurface, // solid card background color
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                  child: Text(
                                    state.dailyBriefing,
                                    style: context.aiBriefing.copyWith(
                                      fontSize: 16,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Linked Accounts Header ──────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'LINKED ACCOUNTS',
                    style: context.uiLabel.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Horizontal List of Linked Accounts
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // Account 1: Bank Savings
                      CFOCard(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(right: 12),
                        borderRadius: 10,
                        backgroundColor: cfo.cardSurface,
                        child: SizedBox(
                          width: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.account_balance_rounded, size: 14, color: cfo.brassGold),
                                  const SizedBox(width: 6),
                                  Text(
                                    'HDFC SAVINGS',
                                    style: context.uiLabel.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: cfo.brassGold.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      'PRIMARY',
                                      style: context.uiLabel.copyWith(fontSize: 7, color: cfo.brassGold, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              AmountText(
                                state.balance,
                                size: AmountSize.medium,
                                type: AmountType.credit,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'A/C •••• 9821',
                                style: context.uiLabel.copyWith(fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Account 2: Credit Card
                      CFOCard(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(right: 12),
                        borderRadius: 10,
                        backgroundColor: cfo.cardSurface,
                        child: SizedBox(
                          width: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.credit_card_rounded, size: 14, color: cfo.brassGold),
                                  const SizedBox(width: 6),
                                  Text(
                                    'HDFC MILLENNIA',
                                    style: context.uiLabel.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              AmountText(
                                4520.0, // Spent / Outstanding
                                size: AmountSize.medium,
                                type: AmountType.debit,
                                prefix: 'DUE: ',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'LIMIT: ₹75,000',
                                style: context.uiLabel.copyWith(fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Account 3: UPI Account
                      CFOCard(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 10,
                        backgroundColor: cfo.cardSurface,
                        child: SizedBox(
                          width: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.phonelink_ring_rounded, size: 14, color: cfo.brassGold),
                                  const SizedBox(width: 6),
                                  Text(
                                    'UPI - HDFC LINK',
                                    style: context.uiLabel.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.check_circle_rounded, size: 12, color: cfo.brassGold),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'karthik@okhdfcbank',
                                style: context.numberSmall.copyWith(fontSize: 13, color: cfo.warmWhite),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'DAILY LIMIT: ₹1,00,000',
                                style: context.uiLabel.copyWith(fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Summary Cards Header ────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'METRICS & INSIGHTS',
                    style: context.uiLabel.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 155,
                    ),
                    children: [
                      // Balance Card
                      CFOCard(
                        onTap: () => context.go('/spending'),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BALANCE', style: context.uiLabel),
                            const SizedBox(height: 8),
                            AmountText(
                              state.balance,
                              size: AmountSize.large,
                              type: AmountType.debit,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'HDFC Primary Account',
                              style: context.uiLabel.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),

                      // Budget Card
                      CFOCard(
                        onTap: () => context.go('/budget'),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BUDGET USED', style: context.uiLabel),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${(state.budgetSpentTotal / state.budgetLimitTotal * 100).toStringAsFixed(0)}%',
                                  style: context.numberLarge,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'used',
                                  style: context.uiLabel.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '₹${state.budgetSpentTotal.toStringAsFixed(0)} / ₹${state.budgetLimitTotal.toStringAsFixed(0)}',
                              style: context.uiLabel.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),

                      // Goal Card
                      CFOCard(
                        onTap: () => context.go('/goals'),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NEAREST GOAL', style: context.uiLabel),
                            const SizedBox(height: 8),
                            if (state.nearestGoal != null) ...[
                              Text(
                                state.nearestGoal!.name,
                                style: context.uiHeader.copyWith(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: LinearProgressIndicator(
                                        value: state.nearestGoal!.progressPercentage / 100.0,
                                        backgroundColor: cfo.canvas,
                                        valueColor: AlwaysStoppedAnimation<Color>(cfo.brassGold),
                                        minHeight: 4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${state.nearestGoal!.progressPercentage.toStringAsFixed(0)}%',
                                    style: context.numberSmall.copyWith(
                                      color: cfo.brassGold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ] else
                              Text('No active goals', style: context.uiHeader),
                            const SizedBox(height: 12),
                            Text(
                              'Goal Progress',
                              style: context.uiLabel.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),

                      // Upcoming Bill Card
                      CFOCard(
                        onTap: () => context.push('/more'),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('UPCOMING BILL', style: context.uiLabel),
                            const SizedBox(height: 8),
                            if (state.urgentBill != null) ...[
                              Text(
                                state.urgentBill!.name,
                                style: context.uiHeader.copyWith(
                                  fontSize: 14,
                                  color: state.urgentBill!.isUrgent ? cfo.warningRust : cfo.warmWhite,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              AmountText(
                                state.urgentBill!.amount,
                                size: AmountSize.medium,
                                type: state.urgentBill!.isUrgent ? AmountType.warning : AmountType.neutral,
                              ),
                            ] else
                              Text('No bills due', style: context.uiHeader),
                            const SizedBox(height: 12),
                            Text(
                              state.urgentBill != null
                                  ? 'Due in ${state.urgentBill!.daysUntilDue} days'
                                  : 'All caught up',
                              style: context.uiLabel.copyWith(
                                fontSize: 10,
                                color: state.urgentBill?.isUrgent == true ? cfo.warningRust : cfo.mutedSlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
