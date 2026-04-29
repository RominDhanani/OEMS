import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/fund_provider.dart';
import '../../providers/expansion_provider.dart';
import '../../providers/report_provider.dart';
import '../../models/expense_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/tab_provider.dart';
import '../../core/utils/report_generator.dart';

import '../../providers/settings_provider.dart';
import '../expenses/create_expense_screen.dart';
import '../expenses/expense_details_screen.dart';

import '../../widgets/common/notification_dropdown.dart';


import 'manager_team_screen.dart';
import 'manager_fund_management_screen.dart';
import '../../widgets/premium/premium_export_button.dart';
import '../../services/socket_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/premium/animated_stat_card.dart';
import '../../widgets/premium/premium_table.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/premium/premium_skeleton.dart';
import 'dart:async';

class ManagerDashboard extends ConsumerStatefulWidget {
  const ManagerDashboard({super.key});

  @override
  ConsumerState<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends ConsumerState<ManagerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    final initialTab = ref
        .read(tabProvider.notifier)
        .getTab('manager_dashboard');
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: (initialTab >= 4) ? 0 : initialTab,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
        setState(() {});
      }
      if (!_tabController.indexIsChanging) {
        ref
            .read(tabProvider.notifier)
            .setTab('manager_dashboard', _tabController.index);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      
      // Initialize socket and listen for updates
      final socketService = ref.read(socketServiceProvider);
      socketService.connect();
      _socketSubscription = socketService.eventStream.listen((event) {
        if (mounted) {
          _loadData();
        }
      });
    });
  }

  void _loadData() {
    ref.read(expenseProvider.notifier).fetchExpenses();
    ref.read(fundProvider.notifier).fetchOperationalFunds();
    ref.read(expansionProvider.notifier).fetchExpansions();
    ref.read(reportProvider.notifier).fetchDashboardStats();
    ref.read(userProvider.notifier).fetchAllUsers();
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportState = ref.watch(reportProvider);
    final user = ref.watch(authProvider).user;
    final expenseState = ref.watch(expenseProvider);
    final fundState = ref.watch(fundProvider);
    final expansionState = ref.watch(expansionProvider);
    ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 100.0,
                floating: false,
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.string(
                        '<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg"><path d="M320 336c0 8.84-7.16 16-16 16h-96c-8.84 0-16-7.16-16-16v-48H0v144c0 25.6 22.4 48 48 48h416c25.6 0 48-22.4 48-48V288H320v48zm144-208h-80V80c0-25.6-22.4-48-48-48H176c-25.6 0-48 22.4-48 48v48H48c-25.6 0-48 22.4-48 48v80h512v-80c0-25.6-22.4-48-48-48zm-144 0H192V96h128v32z" fill="white"></path></svg>',
                        width: 16,
                        height: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "OFFICE EXPENSE",
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              fontSize: 13,
                              color: theme.colorScheme.onSurface,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "MANAGEMENT",
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              fontSize: 8,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.primaryColor.withOpacity(0.12),
                              theme.colorScheme.secondary.withOpacity(0.03),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -30,
                        right: -30,
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: theme.primaryColor.withOpacity(0.08),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: -20,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.colorScheme.secondary.withOpacity(0.05),
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  physics: const BouncingScrollPhysics(),
                  indicator: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: -8, vertical: 6),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    fontSize: 11,
                  ),
                  unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    fontSize: 11,
                  ),
                  tabs: const [
                    Tab(
                      height: 46,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [Icon(Icons.dashboard_rounded, size: 18), SizedBox(width: 8), Text("HOME")],
                      ),
                    ),
                    Tab(
                      height: 46,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [Icon(Icons.receipt_long_rounded, size: 18), SizedBox(width: 8), Text("EXPENSES")],
                      ),
                    ),
                    Tab(
                      height: 46,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [Icon(Icons.people_alt_rounded, size: 18), SizedBox(width: 8), Text("TEAM")],
                      ),
                    ),
                    Tab(
                      height: 46,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [Icon(Icons.rocket_launch_rounded, size: 18), SizedBox(width: 8), Text("FUND")],
                      ),
                    ),
                  ],
                ),
                actions: [
                  const NotificationDropdown(),
                  IconButton(
                    icon: Icon(Icons.settings_outlined, color: theme.colorScheme.onSurface),
                    onPressed: () => context.push('/settings'),
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ];
          },
          body: AppLoader(
            isLoading: false, // Use skeletons instead of full-screen loader
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHomeTab(expenseState, fundState, expansionState, settingsNotifier, theme, user, reportState),
                _buildMyExpensesTab(expenseState, user, theme),
                const ManagerTeamScreen(),
                const ManagerFundManagementScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildHomeTab(dynamic expenseState, dynamic fundState, dynamic expansionState, dynamic settingsNotifier, ThemeData theme, dynamic user, dynamic reportState) {
    final myExpensesTotal = expenseState.expenses
        .where((e) => e.userId == user?.id && e.status.toUpperCase() != 'REJECTED')
        .fold(0.0, (sum, e) => sum + e.amount);
    final totalReceived = fundState.funds
        .where((f) => f.toUserId == user?.id && ['RECEIVED', 'COMPLETED'].contains(f.status.toUpperCase()))
        .fold(0.0, (sum, f) => sum + f.amount);
    final distributedTotal = fundState.funds
        .where((f) => f.fromUserId == user?.id && ['ALLOCATED', 'RECEIVED', 'COMPLETED'].contains(f.status.toUpperCase()))
        .fold(0.0, (sum, f) => sum + f.amount);

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildSectionLabel(theme, "Wallet Pulse"),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: (expenseState.isLoading || fundState.isLoading || expansionState.isLoading)
                  ? List.generate(5, (index) => const DashboardCardSkeleton())
                  : [
                      AnimatedStatCard(
                        title: "Total Received",
                        value: settingsNotifier.formatCurrency(totalReceived),
                        icon: Icons.payments_rounded,
                        color: AppTheme.accentIndigo,
                        delay: const Duration(milliseconds: 100),
                      ),
                      AnimatedStatCard(
                        title: "My Expenses",
                        value: settingsNotifier.formatCurrency(myExpensesTotal),
                        icon: Icons.receipt_long_rounded,
                        color: Colors.orange,
                        delay: const Duration(milliseconds: 200),
                      ),
                      AnimatedStatCard(
                        title: "Allocated to Team",
                        value: settingsNotifier.formatCurrency(distributedTotal),
                        icon: Icons.outbond_rounded,
                        color: theme.primaryColor,
                        delay: const Duration(milliseconds: 300),
                      ),
                      AnimatedStatCard(
                        title: "Outstanding Balance",
                        value: settingsNotifier.formatCurrency(totalReceived - distributedTotal - myExpensesTotal),
                        icon: Icons.account_balance_wallet_rounded,
                        color: AppTheme.successGreen,
                        delay: const Duration(milliseconds: 400),
                      ),
                      AnimatedStatCard(
                        title: "Pending Approvals",
                        value: reportState.dashboardStats?.pendingApprovals?.toString() ?? "0",
                        icon: Icons.assignment_turned_in_rounded,
                        color: AppTheme.warningOrange,
                        delay: const Duration(milliseconds: 300),
                      ),
                    ],
            ),
            const SizedBox(height: 24),

          ],
        ),
      ),
    );
  }

  Widget _buildMyExpensesTab(dynamic expenseState, dynamic user, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: PremiumTable<ExpenseModel>(
          isLoading: expenseState.isLoading,
          data: expenseState.expenses.where((e) => e.userId == user?.id).toList(),
          columns: [
            TableColumn<ExpenseModel>(label: "ID", key: "id"),
            TableColumn<ExpenseModel>(
              label: "Date",
              key: "expenseDate",
              builder: (context, item) => Text(DateFormat('dd-MM-yyyy').format(item.expenseDate.toLocal())),
            ),
            TableColumn<ExpenseModel>(label: "Reference", key: "title"),
            TableColumn<ExpenseModel>(label: "Category", key: "category"),
            TableColumn<ExpenseModel>(label: "Department", key: "department"),
            TableColumn<ExpenseModel>(label: "Amount", key: "amount", isCurrency: true),
            TableColumn<ExpenseModel>(label: "Status", key: "status", isStatus: true),
            TableColumn<ExpenseModel>(label: "Approved By", key: "approvedBy", builder: (context, item) => Text(item.approvedByName ?? "-")),
          ],
          searchFields: const ["id", "title", "category", "amount", "status"],
          customRowActions: (expense) {
            final isPending = ['PENDING', 'PENDING_APPROVAL', 'REJECTED'].contains(expense.status.toUpperCase());
            return [
              IconButton(
                icon: const Icon(Icons.visibility_rounded, color: Colors.blue),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseDetailsScreen(expense: expense))),
                tooltip: "View Details",
              ),
              if (isPending) ...[
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.orange),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CreateExpenseScreen(expense: expense),
                  ),
                  tooltip: "Edit",
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Expense"),
                        content: const Text("Are you sure you want to permanently delete this expense?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text("Delete", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(expenseProvider.notifier).deleteExpense(expense.id);
                    }
                  },
                  tooltip: "Delete",
                ),
              ],
              PremiumExportButton(
                type: ExportType.pdf,
                isIconOnly: true,
                tooltip: "Download Invoice",
                onPressed: () => ReportGenerator.generateExpensePDF(expense),
              ),
            ];
          },
          onExportPdf: (List<ExpenseModel> data) {
            ReportGenerator.generateDetailedReportPDF(
              title: "All Expenses Report",
              headers: ["ID", "Date", "Reference", "Category", "Amount", "Status", "Approved By"],
              data: data.map((e) => [
                e.id.toString(),
                DateFormat('dd-MM-yyyy').format(e.expenseDate.toLocal()),
                e.title,
                e.category,
                ReportGenerator.formatCurrency(e.amount.toDouble()),
                e.status,
                e.approvedByName ?? "-",
              ]).toList(),
              summaries: {
                "Total Approved": ReportGenerator.formatCurrency(data.where((e) => !['REJECTED', 'PENDING', 'PENDING_APPROVAL'].contains(e.status.toUpperCase())).fold(0.0, (sum, e) => sum + e.amount)),
                "Net Amount": ReportGenerator.formatCurrency(data.fold(0.0, (sum, e) => sum + e.amount)),
              },
            );
          },
          onExportExcel: (List<ExpenseModel> data) {
            final headers = ["ID", "Date", "Reference", "Category", "Amount", "Status", "Approved By"];
            final rows = data.map((e) => [
              e.id.toString(),
              DateFormat('dd-MM-yyyy').format(e.expenseDate.toLocal()),
              e.title,
              e.category,
              e.amount.toDouble(),
              e.status,
              e.approvedByName ?? "-"
            ]).toList();
            ReportGenerator.generateExcel(title: "All_Expenses_Report", headers: headers, data: rows);
          },
        ),
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface.withOpacity(0.75),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

