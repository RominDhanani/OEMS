import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('dd-MM-yyyy').format(date);
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'EXPENSE_APPROVED':
      case 'FUND_REQUEST_APPROVED':
      case 'EXPANSION_APPROVED':
        return Icons.check_circle_outline;
      case 'EXPENSE_REJECTED':
      case 'FUND_REQUEST_REJECTED':
      case 'EXPANSION_REJECTED':
        return Icons.cancel_outlined;
      case 'EXPENSE_PENDING':
        return Icons.hourglass_empty;
      case 'FUND_ALLOCATED':
        return Icons.account_balance_wallet_outlined;
      case 'USER_REGISTERED':
        return Icons.person_add_outlined;
      case 'MANAGER_ASSIGNED':
      case 'USER_ASSIGNED':
        return Icons.supervisor_account_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color _getColor(String type) {
    if (type.contains('APPROVED')) return Colors.green;
    if (type.contains('REJECTED')) return Colors.red;
    if (type.contains('PENDING')) return Colors.orange;
    if (type.contains('ALLOCATED')) return Colors.blue;
    return Colors.indigo;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);
    final user = ref.watch(authProvider).user;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: Text(
                    "Notifications",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor.withOpacity(0.1),
                          theme.colorScheme.secondary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (state.unreadCount > 0)
                    IconButton(
                      onPressed: () => ref.read(notificationProvider.notifier).markAllAsRead(),
                      icon: const Icon(Icons.done_all_rounded),
                      tooltip: "Mark all read",
                      color: theme.primaryColor,
                    ),
                ],
              ),
            ];
          },
          body: RefreshIndicator(
            onRefresh: () => ref.read(notificationProvider.notifier).fetchNotifications(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.pendingApprovals > 0 || state.newFunds > 0) ...[
                  Text("PRIORITY ACTIONS", style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.grey)),
                  const SizedBox(height: 16),
                  if (state.pendingApprovals > 0)
                    _buildSummaryCard(
                      context,
                      Icons.receipt_long_rounded,
                      "Expense Review",
                      "${state.pendingApprovals} expense(s) to approve",
                      Colors.orange,
                      () => _navigateToApprovals(context, user?.role),
                    ),
                  if (state.newFunds > 0)
                    _buildSummaryCard(
                      context,
                      Icons.account_balance_wallet_rounded,
                      "New Funds",
                      "You have ${state.newFunds} unconfirmed allocation(s)",
                      Colors.green,
                      () => _navigateToFunds(context),
                    ),
                  const SizedBox(height: 24),
                ],

                Text("RECENT UPDATES", style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.grey)),
                const SizedBox(height: 16),
                if (state.notifications.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 80),
                      child: Column(
                        children: [
                          Icon(Icons.notifications_none_rounded, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.1)),
                          const SizedBox(height: 16),
                          const Text("No notifications yet", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                else
                  ...state.notifications.take(20).map((notif) => _buildNotificationItem(ref, notif)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(WidgetRef ref, SystemNotification notif) {
    final color = _getColor(notif.type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notif.isRead ? null : color.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: notif.isRead ? Colors.grey.withOpacity(0.05) : color.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: notif.isRead ? null : () => ref.read(notificationProvider.notifier).markAsRead(notif.id),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(_getIcon(notif.type), color: color, size: 24),
        ),
        title: Row(
          children: [
            Expanded(child: Text(notif.title, style: TextStyle(fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w900, fontSize: 14))),
            Text(_formatTime(notif.createdAt), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(notif.message, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ),
        trailing: notif.isRead 
          ? null 
          : Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
      ),
    );
  }

  void _navigateToApprovals(BuildContext context, String? role) {
    if (role == 'MANAGER') {
      context.push('/dashboard');
    }
  }

  void _navigateToFunds(BuildContext context) {
    context.push('/dashboard');
  }

  Widget _buildSummaryCard(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: color, size: 20),
        onTap: onTap,
      ),
    );
  }
}

