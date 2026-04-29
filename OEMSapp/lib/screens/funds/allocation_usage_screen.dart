import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/fund_provider.dart';
import '../../core/utils/report_generator.dart';
import '../../widgets/premium/premium_export_button.dart';
import '../../core/utils/table_manager.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/table_filter_bar.dart';
import '../../widgets/common/table_pagination_footer.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/premium/premium_card.dart';
import '../../widgets/premium/animated_stat_card.dart';
import '../../widgets/premium/premium_skeleton.dart';

class AllocationUsageScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  final int? managerId;
  const AllocationUsageScreen({super.key, this.isEmbedded = false, this.managerId});

  @override
  ConsumerState<AllocationUsageScreen> createState() =>
      _AllocationUsageScreenState();
}

class _AllocationUsageScreenState extends ConsumerState<AllocationUsageScreen> {
  final _searchController = TextEditingController();
  int _currentPage = 1;
  int _itemsPerPage = 10;
  final Map<int, bool> _expandedManagers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fundProvider.notifier).fetchAllocationUsage();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleManager(int managerId) {
    setState(() {
      _expandedManagers[managerId] = !(_expandedManagers[managerId] ?? false);
    });
  }

  void _showManagerDetails(BuildContext context, dynamic manager) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManagerDetailsModal(manager: manager),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fundState = ref.watch(fundProvider);
    ref.watch(settingsProvider);
    List<dynamic> data = fundState.allocationUsage;

    if (widget.managerId != null) {
      data = data.where((m) => m['manager_id'] == widget.managerId).toList();
    }

    // Table manager for filtering
    final manager = TableManager(
      allData: data,
      searchFields: const ['manager_name'],
    );
    final filteredData = manager.filter(searchTerm: _searchController.text);
    final paginatedData = manager.getPaginatedData(
      filteredData.cast<Map<String, dynamic>>(),
      _currentPage,
      _itemsPerPage,
    );
    final totalPages = manager.getTotalPages(
      filteredData.length,
      _itemsPerPage,
    );

    final content = AppLoader(
      isLoading: false, // Use skeletons instead of full-screen loader
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            _buildPremiumStats(data, fundState.isLoading),
            TableFilterBar(
              searchController: _searchController,
              searchPlaceholder: "Search managers...",
              selectedFilters: const {},
              onFilterChanged: (key, value) {},
              onDateRangeChanged: (range) {},
              onClearFilters: () {
                setState(() {
                  _searchController.clear();
                  _currentPage = 1;
                });
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: fundState.isLoading
                ? _buildSkeletonList()
                : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: paginatedData.length,
                itemBuilder: (context, index) {
                  final managerData = paginatedData[index];
                  final int managerId = managerData['manager_id'] is String 
                      ? int.parse(managerData['manager_id']) 
                      : (managerData['manager_id'] as int? ?? 0);
                  final isExpanded = _expandedManagers[managerId] ?? false;
                  final teamMembers = List<dynamic>.from(managerData['team_usage_breakdown'] ?? []);
                  final theme = Theme.of(context);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PremiumCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => _toggleManager(managerId),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Icon(Icons.person_outline_rounded, color: theme.primaryColor),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              managerData['manager_name'],
                                              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            RichText(
                                              text: TextSpan(
                                                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                                children: [
                                                  const TextSpan(text: "Limit: "),
                                                  TextSpan(
                                                    text: ReportGenerator.formatCurrency(managerData['total_received'].toDouble()),
                                                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                                                  ),
                                                ],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildActionButton(Icons.fullscreen_rounded, Colors.blue, 
                                            () => _showManagerDetails(context, managerData)),
                                          _buildActionButton(Icons.expand_more_rounded, theme.primaryColor, 
                                            () => _toggleManager(managerId), 
                                            isRotate: isExpanded),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "OWN USAGE",
                                              style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                                            ),
                                            Text(
                                              ReportGenerator.formatCurrency(managerData['manager_own_usage']?.toDouble() ?? 0),
                                              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, fontSize: 13),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "REMAINING",
                                              style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                                            ),
                                            Text(
                                              ReportGenerator.formatCurrency(managerData['manager_balance']?.toDouble() ?? 0),
                                              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.green, fontSize: 15),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded) ...[
                            const Divider(height: 1),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface.withOpacity(0.02),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("TEAM BREAKDOWN", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface.withOpacity(0.4), letterSpacing: 1)),
                                      Text("${teamMembers.length} Members", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  if (teamMembers.isEmpty)
                                    const Center(child: Text("No team members assigned", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)))
                                  else
                                    ...teamMembers.map((user) => _buildTeamMemberItem(user, theme)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            TablePaginationFooter(
              currentPage: _currentPage,
              totalPages: totalPages == 0 ? 1 : totalPages,
              totalItems: filteredData.length,
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
      appBar: AppBar(
        title: Text("Fund Utilization Dashboard", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          PremiumExportButton(
            type: ExportType.pdf,
            isIconOnly: true,
            tooltip: "Download PDF Report",
            onPressed: () {
              final notifier = ref.read(settingsProvider.notifier);
              ReportGenerator.generateAllocationUsagePDF(
                data,
                currencySymbol: notifier.getSymbol(),
              );
            },
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildPremiumStats(List<dynamic> data, bool isLoading) {
    if (isLoading) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Row(
          children: List.generate(4, (index) => const DashboardCardSkeleton()),
        ),
      );
    }
    final grandTotalReceived = data.fold<double>(0, (sum, item) => sum + (item['total_received'] ?? 0));
    final grandTotalTeamAllocated = data.fold<double>(0, (sum, item) => sum + (item['total_allocated_to_team'] ?? 0));

    final grandTotalBalance = data.fold<double>(0, (sum, item) {
      final teamUsage = (item['team_usage_breakdown'] as List? ?? []).fold<double>(0, (s, u) => s + (u['used_fund'] ?? 0));
      final teamAllocated = (item['total_allocated_to_team'] ?? 0).toDouble();
      final effectiveDeduction = teamAllocated > teamUsage ? teamAllocated : teamUsage;
      return sum + ((item['total_received'] ?? 0) - (item['manager_own_usage'] ?? 0) - effectiveDeduction);
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          AnimatedStatCard(
            title: "Total Outflow",
            value: ReportGenerator.formatCurrency(grandTotalReceived),
            icon: Icons.payments_rounded,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          AnimatedStatCard(
            title: "Manager Usage",
            value: ReportGenerator.formatCurrency(data.fold<double>(0, (sum, item) => sum + (item['manager_own_usage'] ?? 0))),
            icon: Icons.person_rounded,
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          AnimatedStatCard(
            title: "Org Balance",
            value: ReportGenerator.formatCurrency(grandTotalBalance),
            icon: Icons.account_balance_wallet_rounded,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          AnimatedStatCard(
            title: "Allocated to Teams",
            value: ReportGenerator.formatCurrency(grandTotalTeamAllocated),
            icon: Icons.groups_rounded,
            color: Colors.indigo,
          ),
          const SizedBox(width: 12),
          AnimatedStatCard(
            title: "Team Usage",
            value: ReportGenerator.formatCurrency(data.fold<double>(0, (sum, item) {
              return sum + (item['team_usage_breakdown'] as List? ?? []).fold<double>(0, (s, u) => s + (u['used_fund'] ?? 0));
            })),
            icon: Icons.receipt_long_rounded,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap, {bool isRotate = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(left: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Transform.rotate(
          angle: isRotate ? 3.14159 / 1 : 0,
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  Widget _buildTeamMemberItem(dynamic user, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("Limit: ${ReportGenerator.formatCurrency(user['allocated_fund'].toDouble())}", style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.4))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                ReportGenerator.formatCurrency(user['balance'].toDouble()),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.green),
              ),
              Text(
                "BALANCE",
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface.withOpacity(0.2)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemBuilder: (context, index) => const ExpenseCardSkeleton(),
    );
  }
}

class _ManagerDetailsModal extends ConsumerWidget {
  final dynamic manager;

  const _ManagerDetailsModal({required this.manager});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 32,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.analytics_rounded, color: theme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(manager['manager_name'], style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900)),
                        Text("Comprehensive Allocation Audit", style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                      ],
                    ),
                  ),
                  _buildTopIconButton(Icons.picture_as_pdf_rounded, Colors.orange, () {
                    ReportGenerator.generateManagerReportPDF(manager, currencySymbol: notifier.getSymbol());
                  }),
                ],
              ),
              const SizedBox(height: 32),
              _buildModernInfoRow("Total Received", manager['total_received'].toDouble(), Icons.add_chart_rounded, Colors.blue, theme),
              _buildModernInfoRow("Manager Usage", manager['manager_own_usage'].toDouble(), Icons.person_rounded, Colors.orange, theme),
              _buildModernInfoRow("Team Distribution", manager['total_allocated_to_team'].toDouble(), Icons.groups_rounded, Colors.indigo, theme),
              const Divider(height: 48),
              _buildModernInfoRow("Current Balance", manager['manager_balance'].toDouble(), Icons.account_balance_wallet_rounded, Colors.green, theme, isLarge: true),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopIconButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildModernInfoRow(String label, double value, IconData icon, Color color, ThemeData theme, {bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color.withOpacity(0.6)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.6))),
          const Spacer(),
          Text(
            ReportGenerator.formatCurrency(value),
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900,
              fontSize: isLarge ? 20 : 15,
              color: isLarge ? Colors.green : null,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

