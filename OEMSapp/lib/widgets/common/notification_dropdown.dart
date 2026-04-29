import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notification_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationDropdown extends ConsumerStatefulWidget {
  const NotificationDropdown({super.key});

  @override
  ConsumerState<NotificationDropdown> createState() => _NotificationDropdownState();
}

class _NotificationDropdownState extends ConsumerState<NotificationDropdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _bellController;

  @override
  void initState() {
    super.initState();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _bellController.dispose();
    super.dispose();
  }

  void _showNotificationSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Use bottom sheet on mobile, popup on wide screens
    if (screenWidth < 600) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(child: _NotificationList(scrollController: scrollController)),
              ],
            ),
          ),
        ),
      );
    } else {
      showMenu(
        context: context,
        position: const RelativeRect.fromLTRB(100, 60, 10, 0),
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        items: [
          PopupMenuItem(
            enabled: false,
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: 380,
              height: 450,
              child: const _NotificationList(),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final unreadCount = notificationState.unreadCount;

    // Trigger bell animation when new notifications arrive
    if (unreadCount > 0 && !_bellController.isAnimating) {
      _bellController.forward().then((_) => _bellController.reverse());
    }

    return GestureDetector(
      onTap: () => _showNotificationSheet(context),
      child: AnimatedBuilder(
        animation: _bellController,
        builder: (context, child) => Transform.rotate(
          angle: _bellController.value * 0.3 * ((_bellController.value > 0.5) ? -1 : 1),
          child: child,
        ),
        child: Stack(
          children: [
            IconButton(
              icon: Icon(
                unreadCount > 0 ? Icons.notifications_active : Icons.notifications_none,
                size: 24,
              ),
              onPressed: () => _showNotificationSheet(context),
              tooltip: 'Notifications',
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationList extends ConsumerWidget {
  final ScrollController? scrollController;

  const _NotificationList({this.scrollController});

  IconData _getIconData(String type) {
    switch (type) {
      case 'EXPENSE_APPROVED':
      case 'FUND_REQUEST_APPROVED':
      case 'EXPANSION_APPROVED':
        return Icons.check_circle;
      case 'EXPENSE_REJECTED':
      case 'FUND_REQUEST_REJECTED':
      case 'EXPANSION_REJECTED':
        return Icons.cancel;
      case 'FUND_ALLOCATED':
        return Icons.account_balance_wallet;
      case 'FUND_REQUESTED':
      case 'EXPANSION_REQUESTED':
        return Icons.history;
      case 'USER_REGISTERED':
      case 'ACCOUNT_STATUS':
      case 'MANAGER_ASSIGNED':
      case 'USER_ASSIGNED':
        return Icons.person_add;
      case 'REGISTRATION_APPROVED':
      case 'EXPANSION_ALLOCATED':
        return Icons.check_circle;
      case 'REGISTRATION_REJECTED':
        return Icons.cancel;
      case 'FUND_RETURNED':
        return Icons.swap_horiz;
      case 'EXPENSE_PENDING':
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    if (type.contains('APPROVED') || type.contains('ALLOCATED')) return const Color(0xFF10B981);
    if (type.contains('REJECTED')) return const Color(0xFFEF4444);
    if (type.contains('PENDING') || type.contains('REQUESTED')) return const Color(0xFFF59E0B);
    if (type.contains('FUND')) return const Color(0xFF3B82F6);
    if (type.contains('USER') || type.contains('MANAGER') || type.contains('REGISTERED')) return const Color(0xFF8B5CF6);
    return const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);
    final notifications = notificationState.notifications;
    final unreadCount = notificationState.unreadCount;
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unreadCount new',
                        style: GoogleFonts.outfit(fontSize: 11, color: theme.primaryColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
              if (unreadCount > 0)
                TextButton.icon(
                  icon: const Icon(Icons.done_all, size: 16),
                  label: Text('Mark all', style: GoogleFonts.outfit(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => ref.read(notificationProvider.notifier).markAllAsRead(),
                ),
            ],
          ),
        ),
        Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
        // List
        Expanded(
          child: notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      Text('No notifications yet', style: GoogleFonts.inter(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: scrollController,
                  itemCount: notifications.length,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final color = _getIconColor(notif.type);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        color: notif.isRead ? null : color.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: notif.isRead ? null : Border.all(color: color.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_getIconData(notif.type), color: color, size: 18),
                        ),
                        title: Text(
                          notif.title,
                          style: GoogleFonts.outfit(
                            fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(notif.message, style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                            const SizedBox(height: 4),
                            Text(
                              timeago.format(notif.createdAt),
                              style: GoogleFonts.inter(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.35)),
                            ),
                          ],
                        ),
                        trailing: !notif.isRead
                            ? GestureDetector(
                                onTap: () => ref.read(notificationProvider.notifier).markAsRead(notif.id),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

