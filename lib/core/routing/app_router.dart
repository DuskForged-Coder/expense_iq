import 'package:expense_iq/features/analytics/presentation/analytics_screen.dart';
import 'package:expense_iq/features/auth/presentation/auth_screen.dart';
import 'package:expense_iq/features/budgets/presentation/budgets_screen.dart';
import 'package:expense_iq/features/dashboard/presentation/home_shell.dart';
import 'package:expense_iq/features/reports/presentation/reports_screen.dart';
import 'package:expense_iq/features/savings/presentation/savings_screen.dart';
import 'package:expense_iq/features/scanner/presentation/scanner_screen.dart';
import 'package:expense_iq/features/settings/presentation/settings_screen.dart';
import 'package:expense_iq/features/transactions/presentation/transactions_screen.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter() => GoRouter(
      initialLocation: '/auth',
      routes: <RouteBase>[
        GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              HomeShell(navigationShell: navigationShell),
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/dashboard',
                  builder: (context, state) => const DashboardScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/transactions',
                  builder: (context, state) => const TransactionsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/analytics',
                  builder: (context, state) => const AnalyticsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/settings',
                  builder: (context, state) => const SettingsScreen(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'budgets',
                      builder: (context, state) => const BudgetsScreen(),
                    ),
                    GoRoute(
                      path: 'savings',
                      builder: (context, state) => const SavingsScreen(),
                    ),
                    GoRoute(
                      path: 'scanner',
                      builder: (context, state) => const ScannerScreen(),
                    ),
                    GoRoute(
                      path: 'reports',
                      builder: (context, state) => const ReportsScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
