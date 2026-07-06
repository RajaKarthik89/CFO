import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/onboarding/onboarding_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/spending_intelligence/spending_screen.dart';
import '../features/budget/budget_screen.dart';
import '../features/more/more_screen.dart';
import '../features/health_score/health_score_screen.dart';
import '../features/goals/goals_screen.dart';
import '../features/goals/goal_detail_screen.dart';
import '../features/subscriptions/subscriptions_screen.dart';
import '../features/savings_simulator/simulator_screen.dart';
import '../features/search/search_screen.dart';
import '../features/more/forecast_screen.dart';
import '../features/more/wealth_screen.dart';
import '../features/more/tax_planning_screen.dart';
import '../features/more/credit_health_screen.dart';
import '../features/more/micro_savings_screen.dart';
import 'theme.dart';

// ─────────────────────────────────────────────
// SHELL / BOTTOM NAVIGATION
// ─────────────────────────────────────────────

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Five-tab navigation layout wrapping shell routes.
class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    _Tab(icon: Icons.dashboard_outlined, path: '/dashboard'),
    _Tab(icon: Icons.chat_bubble_outline_rounded, path: '/chat'),
    _Tab(icon: Icons.receipt_long_outlined, path: '/spending'),
    _Tab(icon: Icons.pie_chart_outline_rounded, path: '/budget'),
    _Tab(icon: Icons.grid_view_outlined, path: '/more'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final cfo = context.cfoColors;
    final idx = _currentIndex(context);

    return Scaffold(
      backgroundColor: cfo.canvas,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: cfo.mutedSlate.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: idx,
          onDestinationSelected: (i) => context.go(_tabs[i].path),
          destinations: _tabs
              .map((t) => NavigationDestination(
                    icon: Icon(t.icon),
                    selectedIcon: Icon(t.icon),
                    label: '', // Always hide label text as per design spec
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab({required this.icon, required this.path});
  final IconData icon;
  final String path;
}

// ─────────────────────────────────────────────
// ROUTER
// ─────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
    routes: [
      // ── Onboarding (outside shell) ──────────
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Main shell with bottom nav ──────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/chat',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChatScreen(),
            ),
          ),
          GoRoute(
            path: '/spending',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SpendingScreen(),
            ),
          ),
          GoRoute(
            path: '/budget',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BudgetScreen(),
            ),
          ),
          GoRoute(
            path: '/more',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MoreScreen(),
            ),
          ),
        ],
      ),

      // ── Detail routes (outside shell) ───────
      GoRoute(
        path: '/health-score',
        builder: (context, state) => const HealthScoreScreen(),
      ),
      GoRoute(
        path: '/goals',
        builder: (context, state) => const GoalsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => GoalDetailScreen(
              goalId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/subscriptions',
        builder: (context, state) => const SubscriptionsScreen(),
      ),
      GoRoute(
        path: '/simulator',
        builder: (context, state) => const SimulatorScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/forecast',
        builder: (context, state) => const ForecastScreen(),
      ),
      GoRoute(
        path: '/wealth',
        builder: (context, state) => const WealthScreen(),
      ),
      GoRoute(
        path: '/tax-planning',
        builder: (context, state) => const TaxPlanningScreen(),
      ),
      GoRoute(
        path: '/credit-health',
        builder: (context, state) => const CreditHealthScreen(),
      ),
      GoRoute(
        path: '/micro-savings',
        builder: (context, state) => const MicroSavingsScreen(),
      ),
    ],

    // Redirect root to onboarding
    redirect: (context, state) {
      if (state.uri.path == '/') return '/onboarding';
      return null;
    },
  );
});
