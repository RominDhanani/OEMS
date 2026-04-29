import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';
import 'auth_provider.dart';

class SystemNotification {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  SystemNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory SystemNotification.fromJson(Map<String, dynamic> json) {
    return SystemNotification(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class NotificationState {
  final List<SystemNotification> notifications;
  final int unreadCount;
  final bool isLoading;
  // Keep legacy counters for dashboard stats without breaking existing UI
  final int pendingApprovals;

  final int newFunds;

  NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.pendingApprovals = 0,

    this.newFunds = 0,
  });

  int get total => unreadCount;

  NotificationState copyWith({
    List<SystemNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
    int? pendingApprovals,

    int? newFunds,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,

      newFunds: newFunds ?? this.newFunds,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final ApiService _apiService;
  final Ref _ref;
  Timer? _timer;

  NotificationNotifier(this._apiService, this._ref) : super(NotificationState()) {
    _startPolling();
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _pollAllData());
    _pollAllData(); // Initial fetch
  }

  Future<void> _pollAllData() async {
    await Future.wait([
      fetchNotifications(),
      fetchLegacyStats(),
    ]);
  }

  Future<void> fetchNotifications() async {
    final user = _ref.read(authProvider).user;
    if (user == null) return;

    try {
      final response = await _apiService.get(ApiConstants.notifications);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['notifications'] ?? [];
        final notificationsList = data.map((n) => SystemNotification.fromJson(n)).toList();
        final unread = notificationsList.where((n) => !n.isRead).length;

        state = state.copyWith(
          notifications: notificationsList,
          unreadCount: unread,
        );
      }
    } catch (e) {
      // Silently fail for polling
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      final response = await _apiService.put('${ApiConstants.notifications}/$id/read');
      if (response.statusCode == 200) {
        final updatedNotifications = state.notifications.map((n) {
          if (n.id == id) {
            return SystemNotification(
              id: n.id,
              userId: n.userId,
              type: n.type,
              title: n.title,
              message: n.message,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: (state.unreadCount > 0) ? state.unreadCount - 1 : 0,
        );
      }
    } catch (e) {
      // Handle error natively
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _apiService.put('${ApiConstants.notifications}/read-all');
      if (response.statusCode == 200) {
        final updatedNotifications = state.notifications.map((n) {
          return SystemNotification(
            id: n.id,
            userId: n.userId,
            type: n.type,
            title: n.title,
            message: n.message,
            isRead: true,
            createdAt: n.createdAt,
          );
        }).toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        );
      }
    } catch (e) {
      // Handle error natively
    }
  }

  Future<void> fetchLegacyStats() async {
    final user = _ref.read(authProvider).user;
    if (user == null) return;

    try {
      int approvals = 0;
      int funds = 0;

      if (user.role == 'MANAGER') {
        final expensesRes = await _apiService.get(ApiConstants.expenses);
        if (expensesRes.data != null && expensesRes.data['expenses'] != null) {
            approvals = (expensesRes.data['expenses'] as List)
                .where((e) => e['status'] == 'PENDING_APPROVAL' && e['user_role'] == 'USER' && e['manager_id'] == user.id)
                .length;
        }
      }

      final fundsRes = await _apiService.get(ApiConstants.operationalFunds);
      if (fundsRes.data != null && fundsRes.data['funds'] != null) {
          funds = (fundsRes.data['funds'] as List)
              .where((f) => f['to_user_id'] == user.id && f['status'] == 'ALLOCATED')
              .length;
      }

      state = state.copyWith(
        pendingApprovals: approvals,

        newFunds: funds,
      );
    } catch (e) {
      // Silently fail for polling
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return NotificationNotifier(apiService, ref);
});
