import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';

import '../../screens/dashboard/manager_dashboard.dart';
import '../../screens/dashboard/user_dashboard.dart';
import '../../screens/expenses/expense_list_screen.dart';
import '../../screens/expenses/create_expense_screen.dart';
// import '../../screens/funds/allocate_fund_screen.dart'; // Merged into Dashboard / Workflow
import '../../screens/funds/allocation_usage_screen.dart';
import '../../screens/expenses/expense_details_screen.dart';

import '../../screens/profile/profile_screen.dart';
import '../../screens/reports/reports_screen.dart';
import '../../models/expense_model.dart';
import '../../models/fund_model.dart';
import '../../models/expansion_model.dart';
import '../../screens/funds/fund_details_screen.dart';
import '../../screens/funds/request_expansion_screen.dart';
import '../../screens/funds/expansion_details_screen.dart';
import '../../screens/profile/user_details_screen.dart';
import '../../models/user_model.dart';

import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/reset_password_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../widgets/layout/main_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final path = state.uri.path;
      final publicRoutes = [
        '/login',
        '/register',
        '/verify-otp',
        '/forgot-password',
        '/reset-password'
      ];
      final isPublicRoute = publicRoutes.any((route) => path.startsWith(route));

      if (authState.status == AuthStatus.initial || authState.status == AuthStatus.loading) {
        return null;
      }

      if (authState.status != AuthStatus.authenticated) {
        return isPublicRoute ? null : '/login';
      }

      // If authenticated and trying to access a public route, redirect to dashboard
      if (isPublicRoute) {
        final role = authState.user?.role.toUpperCase();
        if (role == 'MANAGER') return '/manager_dashboard';
        if (role == 'USER') return '/user_dashboard';
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ForgotPasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      ),
      GoRoute(
        path: '/reset-password',
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return CustomTransitionPage(
            child: ResetPasswordScreen(token: token),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const RegisterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      ),
      GoRoute(
        path: '/verify-otp',
        pageBuilder: (context, state) {
          if (state.extra == null || state.extra is! Map<String, dynamic>) {
            return const NoTransitionPage(child: LoginScreen());
          }
          final extra = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            child: OtpVerificationScreen(
              email: extra['email'] as String? ?? '',
              flow: extra['flow'] as String? ?? 'LOGIN',
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [

              GoRoute(path: '/manager_dashboard', builder: (context, state) => const ManagerDashboard()),
              GoRoute(path: '/user_dashboard', builder: (context, state) => const UserDashboard()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/expenses', builder: (context, state) => const ExpenseListScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
            ],
          ),
        ],
      ),
      GoRoute(path: '/create_expense', builder: (context, state) => const CreateExpenseScreen()),
      // GoRoute(path: '/allocate_fund', ...) // Removed as it's now handled via Dashboard or popups
      GoRoute(path: '/allocation-usage', builder: (context, state) => const AllocationUsageScreen()),
      GoRoute(
        path: '/request_expansion',
        builder: (context, state) {
          final queryParams = state.uri.queryParameters;
          ExpansionModel? expansion;
          String? preFillAmount = queryParams['amount'];
          String? preFillExpenseId = queryParams['expenseId'];
          String? preFillJustification = queryParams['justification'];

          if (state.extra != null) {
            if (state.extra is ExpansionModel) {
              expansion = state.extra as ExpansionModel;
            } else if (state.extra is Map<String, dynamic>) {
              final extra = state.extra as Map<String, dynamic>;
              preFillAmount ??= extra['preFillAmount']?.toString();
              preFillExpenseId ??= extra['preFillExpenseId']?.toString();
              preFillJustification ??= extra['preFillJustification']?.toString();
            }
          }

          return RequestExpansionScreen(
            expansion: expansion,
            preFillAmount: preFillAmount,
            preFillExpenseId: preFillExpenseId,
            preFillJustification: preFillJustification,
          );
        },
      ),
      GoRoute(path: '/user_approvals', builder: (context, state) => const ManagerDashboard()), // Redirect to Manager dashboard for task approvals
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(
        path: '/expense_details',
        builder: (context, state) {
          final expense = state.extra as ExpenseModel;
          return ExpenseDetailsScreen(expense: expense);
        },
      ),
      GoRoute(
        path: '/fund_details',
        builder: (context, state) {
          final fund = state.extra as FundModel;
          return FundDetailsScreen(fund: fund);
        },
      ),
      GoRoute(
        path: '/expansion_details',
        builder: (context, state) {
          final expansion = state.extra as ExpansionModel;
          return ExpansionDetailsScreen(expansion: expansion);
        },
      ),
      GoRoute(
        path: '/user_details',
        builder: (context, state) {
          final user = state.extra as UserModel;
          return UserDetailsScreen(user: user);
        },
      ),
    ],
  );

  ref.listen(authProvider, (_, __) => router.refresh());
  return router;
});
