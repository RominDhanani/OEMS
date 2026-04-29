import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../widgets/common/erp_toast.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/premium/premium_skeleton.dart';

class ActiveSessionsScreen extends ConsumerStatefulWidget {
  const ActiveSessionsScreen({super.key});

  @override
  ConsumerState<ActiveSessionsScreen> createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends ConsumerState<ActiveSessionsScreen> {
  bool _isLoading = true;
  List<dynamic> _sessions = [];
  String? _currentToken;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final sessions = await authService.getSessions();
      final token = await authService.getCurrentToken();
      
      setState(() {
        _sessions = sessions;
        _currentToken = token;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load sessions. Please try again.";
        _isLoading = false;
      });
    }
  }

  Future<void> _revokeSession(int sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Session?'),
        content: const Text('The user will be immediately logged out on that device. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('REVOKE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final success = await authService.revokeSession(sessionId);
      
      if (success) {
        ref.read(toastProvider.notifier).show(
          message: 'Session revoked successfully',
          type: ToastType.success,
        );
        _fetchSessions(); // Refresh list
      }
    } catch (e) {
      ref.read(toastProvider.notifier).show(
        message: 'Failed to revoke session',
        type: ToastType.error,
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _revokeAllOtherSessions() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke All Others?'),
        content: const Text('You will be logged out of all other devices except this one. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('REVOKE ALL', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final success = await authService.revokeAllOtherSessions();
      
      if (success) {
        ref.read(toastProvider.notifier).show(
          message: 'All other sessions revoked successfully',
          type: ToastType.success,
        );
        _fetchSessions(); // Refresh list
      }
    } catch (e) {
      ref.read(toastProvider.notifier).show(
        message: 'Failed to revoke other sessions',
        type: ToastType.error,
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Active Sessions'),
        elevation: 0,
        actions: [
          if (_sessions.length > 1)
            TextButton.icon(
              onPressed: _revokeAllOtherSessions,
              icon: const Icon(Icons.phonelink_erase_rounded, color: Colors.red, size: 18),
              label: const Text('REVOKE ALL', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
        ],
      ),
      body: AppLoader(
        isLoading: false, // Use skeletons instead of full-screen loader
        child: _isLoading
            ? _buildSkeletonList()
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _fetchSessions, child: const Text("RETRY")),
                  ],
                ),
              )
            : _sessions.isEmpty
                ? const Center(child: Text('No active sessions found.'))
                : RefreshIndicator(
                    onRefresh: _fetchSessions,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _sessions.length,
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        final isCurrentSession = session['token'] == _currentToken;
                        final lastActive = DateTime.parse(session['last_active']);
                        final theme = Theme.of(context);
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GlassCard(
                            padding: EdgeInsets.zero,
                            opacity: isCurrentSession 
                              ? (theme.brightness == Brightness.dark ? 0.2 : 0.1) 
                              : (theme.brightness == Brightness.dark ? 0.1 : 0.05),
                            border: isCurrentSession 
                              ? Border.all(color: theme.primaryColor.withOpacity(0.5), width: 1.5) 
                              : null,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isCurrentSession 
                                      ? theme.primaryColor.withOpacity(0.2) 
                                      : theme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isCurrentSession ? Icons.phonelink_ring_rounded : Icons.devices_other_rounded,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        session['device_info'] ?? 'Unknown Device',
                                        style: const TextStyle(fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                    if (isCurrentSession)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.primaryColor.withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Text(
                                          "CURRENT",
                                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(Icons.history_rounded, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.65)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Last Active: ${timeago.format(lastActive)}',
                                            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.7), fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_rounded, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.65)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'IP: ${session['ip_address'] ?? "N/A"}',
                                            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.7), fontStyle: FontStyle.italic),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: !isCurrentSession
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                                        onPressed: () => _revokeSession(session['id']),
                                        tooltip: 'Revoke Access',
                                      ),
                                    )
                                  : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) => const ExpenseCardSkeleton(),
    );
  }
}

