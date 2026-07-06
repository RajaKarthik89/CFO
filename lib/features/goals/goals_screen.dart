import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../core/services/mock_data_service.dart';
import '../../widgets/cfo_card.dart';
import '../../widgets/amount_text.dart';
import 'goals_controller.dart';
import 'add_goal_sheet.dart';

// ── Icon key → IconData helper ─────────────────────────────────────────────────
IconData _iconForKey(String? key) {
  switch (key) {
    case 'laptop_mac': return Icons.laptop_mac_rounded;
    case 'flight':     return Icons.flight_takeoff_rounded;
    case 'shield':     return Icons.shield_rounded;
    case 'home':       return Icons.home_rounded;
    case 'car':        return Icons.directions_car_rounded;
    case 'gift':       return Icons.card_giftcard_rounded;
    case 'education':  return Icons.school_rounded;
    default:           return Icons.flag_rounded;
  }
}

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockAsync = ref.watch(mockDataServiceProvider);
    final goals = ref.watch(goalsListProvider);
    final cfo = context.cfoColors;

    return Scaffold(
      backgroundColor: cfo.canvas,
      floatingActionButton: const _HoverFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Text(
          'SAVINGS GOALS',
          style: context.uiHeader.copyWith(letterSpacing: 1.0),
        ),
      ),
      body: mockAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC9A44C)),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error loading goals.',
            style: context.uiLabel.copyWith(color: cfo.warningRust),
          ),
        ),
        data: (_) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flag_rounded,
                      size: 48, color: cfo.mutedSlate.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text('No active goals yet.', style: context.uiLabel),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => showAddGoalSheet(context),
                    icon: const Icon(Icons.add_rounded,
                        size: 16, color: Color(0xFFC9A44C)),
                    label: Text(
                      'Add your first goal',
                      style: context.uiLabel.copyWith(
                        color: const Color(0xFFC9A44C),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CFOCard(
                    onTap: () => context.push('/goals/${goal.id}'),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_iconForKey(goal.icon),
                                color: cfo.brassGold, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                goal.name,
                                style: context.uiHeader.copyWith(fontSize: 16),
                              ),
                            ),
                            Text(
                              '${goal.progressPercentage.toStringAsFixed(0)}%',
                              style: context.numberMedium
                                  .copyWith(color: cfo.brassGold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: goal.progressPercentage / 100.0,
                            backgroundColor: cfo.canvas,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(cfo.brassGold),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('SAVED', style: context.uiLabel),
                                const SizedBox(height: 2),
                                AmountText(
                                  goal.savedAmount,
                                  size: AmountSize.medium,
                                  type: AmountType.credit,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('TARGET', style: context.uiLabel),
                                const SizedBox(height: 2),
                                AmountText(
                                  goal.targetAmount,
                                  size: AmountSize.medium,
                                  type: AmountType.debit,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
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
        onTap: () => showAddGoalSheet(context),
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
                            'Add goal',
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
