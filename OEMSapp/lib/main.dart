import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/router_config.dart';
import 'providers/theme_provider.dart';
import 'services/socket_service.dart';
import 'widgets/common/toast_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: OfficeExpenseApp(),
    ),
  );
}

class OfficeExpenseApp extends ConsumerWidget {
  const OfficeExpenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeType = ref.watch(themeProvider);
    // Initialize real-time synchronization
    ref.watch(socketServiceProvider);

    return MaterialApp.router(
      title: 'Office Expense Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(themeType),
      routerConfig: router,
      builder: (context, child) => ToastOverlay(child: child!),
    );
  }
}
