import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/navigation_utils.dart';
import 'dart:ui';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import 'notification_dropdown.dart';

class ERPAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;
  final bool showSettingsAndNotifications;

  const ERPAppBar({
    super.key,
    this.bottom,
    this.actions,
    this.showSettingsAndNotifications = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final state = GoRouterState.of(context);
    final currentPath = state.uri.toString();
    final theme = Theme.of(context);

    final breadcrumbs = NavigationUtils.getBreadcrumbs(user?.role ?? "", currentPath);

    return AppBar(
      backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
      flexibleSpace: Stack(
        children: [
          // Glass blur effect
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
          // Home-style background gradient for depth
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.08),
                  theme.scaffoldBackgroundColor.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.work,
              color: theme.colorScheme.secondary,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          if (breadcrumbs.isEmpty)
            Text(
              "OFFICE EXPENSE MANAGEMENT",
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
                letterSpacing: 1.0,
              ),
            ),
          if (breadcrumbs.isNotEmpty) ...[
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < breadcrumbs.length; i++) ...[
                      Text(
                        breadcrumbs[i],
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: i == breadcrumbs.length - 1 ? FontWeight.w900 : FontWeight.w700,
                          color: i == breadcrumbs.length - 1 
                            ? theme.colorScheme.onSurface 
                            : theme.colorScheme.onSurface.withOpacity(0.65),
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (i < breadcrumbs.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.chevron_right,
                            size: 12,
                            color: theme.dividerColor,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        ...?actions,
        if (showSettingsAndNotifications) ...[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
          _buildNotificationBadge(ref),
        ],
      ],
      bottom: bottom,
    );
  }

  Widget _buildNotificationBadge(WidgetRef ref) {
    final state = ref.watch(notificationProvider);

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 4),
      child: Badge(
        label: Text(state.total.toString()),
        isLabelVisible: state.total > 0,
        child: const NotificationDropdown(),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}

