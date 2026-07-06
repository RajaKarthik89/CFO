import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../widgets/cfo_card.dart';
import '../../widgets/amount_text.dart';
import 'subscriptions_controller.dart';
import 'add_subscription_sheet.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(subscriptionsControllerProvider);
    final cfo = context.cfoColors;

    return Scaffold(
      backgroundColor: cfo.canvas,
      floatingActionButton: const _HoverFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Text(
          'SUBSCRIPTIONS',
          style: context.uiHeader.copyWith(letterSpacing: 1.0),
        ),
      ),
      body: stateAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC9A44C)),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error loading subscriptions.',
            style: context.uiLabel.copyWith(color: cfo.warningRust),
          ),
        ),
        data: (state) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                // ── Potential Monthly Savings Card ────
                CFOCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('POTENTIAL MONTHLY SAVINGS', style: context.uiLabel),
                      const SizedBox(height: 8),
                      AmountText(
                        state.potentialSavings,
                        size: AmountSize.large,
                        type: state.potentialSavings > 0 ? AmountType.credit : AmountType.neutral,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.potentialSavings > 0
                            ? 'Flagged from underused or overlapping accounts'
                            : 'All active subscriptions are regularly used',
                        style: context.uiLabel.copyWith(
                          fontSize: 10,
                          color: state.potentialSavings > 0 ? cfo.brassGold : cfo.mutedSlate,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Subscriptions List Header ─────────
                Text(
                  'ACTIVE SUBSCRIPTIONS',
                  style: context.uiLabel.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Subscription List ─────────────────
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.subscriptions.length,
                  itemBuilder: (context, index) {
                    final sub = state.subscriptions[index];
                    final tip = state.subscriptionTips[sub.id];
                    final isWaste = sub.isWasteful;

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
                                Row(
                                  children: [
                                    Text(
                                      sub.name.toUpperCase(),
                                      style: context.uiHeader.copyWith(fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    // Status Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isWaste ? cfo.warningRust : cfo.brassGold.withValues(alpha: 0.5),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        sub.status.name.toUpperCase(),
                                        style: context.uiLabel.copyWith(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: isWaste ? cfo.warningRust : cfo.brassGold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                AmountText(
                                  sub.monthlyCost,
                                  size: AmountSize.small,
                                  type: isWaste ? AmountType.neutral : AmountType.debit,
                                ),
                              ],
                            ),
                            if (tip != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 14,
                                    color: isWaste ? cfo.warningRust : cfo.brassGold,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: context.aiQuoteItalic.copyWith(
                                        fontSize: 13,
                                        color: cfo.mutedSlate,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

// ── Hover-expandable FAB ────────────────────────────────────────────────────────

class _HoverFAB extends StatefulWidget {
  const _HoverFAB();

  @override
  State<_HoverFAB> createState() => _HoverFABState();
}

class _HoverFABState extends State<_HoverFAB> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => showAddSubscriptionSheet(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          height: 52,
          padding: EdgeInsets.symmetric(
            horizontal: _hovered ? 24 : 14,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFC9A44C),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC9A44C).withValues(alpha: 0.35),
                blurRadius: _hovered ? 20 : 10,
                spreadRadius: _hovered ? 2 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_rounded,
                size: 26,
                color: Colors.white,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: _hovered
                    ? const SizedBox(width: 8)
                    : const SizedBox.shrink(),
              ),
              ClipRect(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  child: _hovered
                      ? AnimatedOpacity(
                          opacity: _hovered ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Text(
                            'Add subscription',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
