import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../providers/toast_provider.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/erp_toast.dart';
import '../../widgets/common/table_filter_bar.dart';
import '../../widgets/common/table_pagination_footer.dart';
import '../../core/utils/table_manager.dart';
import 'package:intl/intl.dart';
import '../../core/utils/report_generator.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/premium/premium_skeleton.dart';
import '../../widgets/premium/premium_export_button.dart';
import '../../widgets/status_badge.dart';
import '../profile/user_details_screen.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  final String? initialStatus;
  final String? roleFilter;
  const UserManagementScreen({
    super.key, 
    this.isEmbedded = false,
    this.initialStatus,
    this.roleFilter,
  });

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final _searchController = TextEditingController();
  late String _selectedStatus;
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus ?? 'All';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    await ref.read(userProvider.notifier).fetchAllUsers();
    await ref.read(userProvider.notifier).fetchManagers();
  }

  List<dynamic> _getFilteredData() {
    final users = ref.watch(userProvider).users;
    final manager = TableManager(
      allData: users,
      searchFields: ['id', 'fullName', 'email', 'role', 'mobileNumber'],
      dateField: 'createdAt',
    );

    final filters = <String, String>{};
    if (_selectedStatus != 'All') {
      filters['status'] = _selectedStatus;
    }
    if (widget.roleFilter != null) {
      filters['role'] = widget.roleFilter!;
    }

    return manager.filter(
      searchTerm: _searchController.text,
      fieldFilters: filters,
    );
  }

  void _handleAssignManager(int userId) async {
    final managers = ref.read(userProvider).managers;
    final selectedUser = ref.read(userProvider).users.firstWhere((u) => u.id == userId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Assign Manager"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: managers.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: const Text("None / Unassign"),
                  onTap: () async {
                    Navigator.pop(context);
                    final success = await ref.read(userProvider.notifier).assignManager(userId, null);
                    if (success) {
                      ref.read(toastProvider.notifier).show(message: "Manager unassigned", type: ToastType.success);
                    }
                  },
                );
              }
              final manager = managers[index - 1];
              return ListTile(
                title: Text(manager.fullName),
                subtitle: Text(manager.email),
                trailing: selectedUser.managerId == manager.id ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () async {
                  Navigator.pop(context);
                  final success = await ref.read(userProvider.notifier).assignManager(userId, manager.id);
                  if (success) {
                    ref.read(toastProvider.notifier).show(message: "Manager assigned successfully", type: ToastType.success);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _currentPage = 1;
    });
  }

  void _handleUpdateStatus(int userId, String currentStatus, String fullName) async {
    final isDeactivating = currentStatus.toUpperCase() == 'APPROVED';
    final action = isDeactivating ? 'DEACTIVATE' : 'ACTIVATE';
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${isDeactivating ? 'Deactivate' : 'Activate'} User"),
        content: Text("Are you sure you want to ${isDeactivating ? 'deactivate' : 'activate'} $fullName?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: isDeactivating ? Colors.red : Colors.green),
            child: Text(isDeactivating ? "Deactivate" : "Activate", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(userProvider.notifier).approveUser(userId, action);
      if (success) {
        ref.read(toastProvider.notifier).show(
          message: "User ${isDeactivating ? 'deactivated' : 'activated'} successfully",
          type: ToastType.success
        );
      }
    }
  }

  void _handleDownloadUserPDF(dynamic user) async {
    try {
      // Convert UserModel to Map for the ReportGenerator
      final userMap = {
        'id': user.id,
        'full_name': user.fullName,
        'email': user.email,
        'role': user.role,
        'mobile_number': user.mobileNumber,
        'manager_name': user.managerName,
        'status': user.status,
        'created_at': user.createdAt.toIso8601String(),
      };
      await ReportGenerator.generateUserPDF(userMap);
      ref.read(toastProvider.notifier).show(message: "PDF Report generated", type: ToastType.success);
    } catch (e) {
      ref.read(toastProvider.notifier).show(message: "Failed to generate PDF: $e", type: ToastType.error);
    }
  }

  void _handleExport() async {
    final data = _getFilteredData();
    if (data.isEmpty) {
      ref.read(toastProvider.notifier).show(message: "No data to export", type: ToastType.info);
      return;
    }

    try {
      final rows = data.map((u) => [
        DateFormat('dd-MM-yyyy').format(u.createdAt.toLocal()),
        u.fullName,
        u.email,
        u.mobileNumber ?? '-',
        u.role,
        u.managerName ?? 'None',
        u.status
      ]).toList();

      final headers = ["Date Joined", "Full Name", "Email", "Mobile", "Role", "Manager", "Status"];
      await ReportGenerator.generateExcel(title: "User_Management_Report", headers: headers, data: rows);
      ref.read(toastProvider.notifier).show(message: "Exported to Excel", type: ToastType.success);
    } catch (e) {
      ref.read(toastProvider.notifier).show(message: "Export failed: $e", type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredData = _getFilteredData();
    final totalItems = filteredData.length;
    final totalPages = (totalItems / _itemsPerPage).ceil();
    final paginatedData = TableManager(allData: [], searchFields: []).getPaginatedData(filteredData, _currentPage, _itemsPerPage);
    final isLoading = ref.watch(userProvider).isLoading;

    final content = AppLoader(
      isLoading: false, // Use skeletons instead of full-screen loader
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            TableFilterBar(
              searchController: _searchController,
              searchPlaceholder: "Search users...",
              onDateRangeChanged: (range) {},
              onFilterChanged: (key, value) {
                if (key == 'status') {
                  setState(() {
                    _selectedStatus = value;
                    _currentPage = 1;
                  });
                }
              },
              dropdownFilters: const {
                'status': ['All', 'PENDING', 'APPROVED', 'REJECTED', 'DEACTIVATED'],
              },
              selectedFilters: {'status': _selectedStatus},
              onClearFilters: () {
                setState(() {
                  _searchController.clear();
                  _selectedStatus = 'All';
                  _currentPage = 1;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Users: $totalItems", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.push('/register'),
                        icon: const Icon(Icons.person_add_rounded, size: 18),
                        label: const Text("Add User"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PremiumExportButton(
                        type: ExportType.excel,
                        onPressed: _handleExport,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchData,
                child: isLoading
                  ? _buildSkeletonList()
                  : filteredData.isEmpty
                    ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_search_rounded, size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.isNotEmpty 
                                    ? "No users matching '${_searchController.text}'"
                                    : "No users matching the current filters.",
                                  style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _resetFilters,
                                  child: const Text("Clear Filters"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                          itemCount: paginatedData.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemBuilder: (context, index) {
                            final user = paginatedData[index];
                            final theme = Theme.of(context);
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlassCard(
                                padding: EdgeInsets.zero,
                                opacity: theme.brightness == Brightness.dark ? 0.1 : 0.05,
                                  child: ListTile(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => UserDetailsScreen(user: user)),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  title: Text(
                                    user.fullName, 
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.2)
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        "${user.email} • ${user.role}",
                                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "Mobile: ${user.mobileNumber ?? '-'} • Joined: ${DateFormat('dd-MM-yyyy').format(user.createdAt.toLocal())}",
                                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          StatusBadge(status: user.status),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: (user.managerName != null ? Colors.green : Colors.orange).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: (user.managerName != null ? Colors.green : Colors.orange).withOpacity(0.2)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  user.managerName != null ? Icons.link_rounded : Icons.link_off_rounded,
                                                  size: 10,
                                                    color: user.managerName != null ? Colors.green : Colors.orange,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  user.managerName != null ? "ASSIGNED" : "UNASSIGNED", 
                                                  style: TextStyle(
                                                    fontSize: 10, 
                                                    fontWeight: FontWeight.w900, 
                                                    color: user.managerName != null ? Colors.green : Colors.orange,
                                                    letterSpacing: 0.5,
                                                  )
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert_rounded),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    onSelected: (value) {
                                      if (value == 'status') {
                                        _handleUpdateStatus(user.id, user.status, user.fullName);
                                      } else if (value == 'manager') {
                                        _handleAssignManager(user.id);
                                      } else if (value == 'report') {
                                        _handleDownloadUserPDF(user);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'status',
                                        child: Row(
                                          children: [
                                            Icon(
                                              user.status.toUpperCase() == 'APPROVED' ? Icons.block_rounded : Icons.check_circle_rounded,
                                              size: 18,
                                              color: user.status.toUpperCase() == 'APPROVED' ? Colors.red : Colors.green,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(user.status.toUpperCase() == 'APPROVED' ? "Deactivate User" : "Activate User"),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'manager',
                                        child: Row(
                                          children: [
                                            Icon(Icons.assignment_ind_rounded, size: 18),
                                            SizedBox(width: 8),
                                            Text("Assign Manager"),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'report',
                                        child: Row(
                                          children: [
                                            Icon(Icons.picture_as_pdf_rounded, size: 18, color: Colors.indigo),
                                            SizedBox(width: 8),
                                            Text("Download Report"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
            TablePaginationFooter(
              currentPage: _currentPage,
              totalPages: totalPages == 0 ? 1 : totalPages,
              totalItems: totalItems,
              itemsPerPage: _itemsPerPage,
              onPageChanged: (page) => setState(() => _currentPage = page),
              onItemsPerPageChanged: (size) => setState(() {
                _itemsPerPage = size;
                _currentPage = 1;
              }),
            ),
          ],
        ),
      ),
    );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: content,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("User Management")),
      body: content,
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) => const ExpenseCardSkeleton(),
    );
  }
}

