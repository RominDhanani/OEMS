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
import '../../models/expense_model.dart';
import '../../models/fund_model.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/notification_dropdown.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/premium/premium_table.dart';

import '../expenses/create_expense_screen.dart';
import '../../providers/tab_provider.dart';
import '../expenses/expense_details_screen.dart';
import '../funds/fund_details_screen.dart';

import '../../services/socket_service.dart';
import '../../core/theme/app_theme.dart';

import '../../widgets/premium/animated_stat_card.dart';
import '../../widgets/premium/premium_skeleton.dart';
import '../../widgets/premium/premium_export_button.dart';
import '../../core/utils/report_generator.dart';
import 'dart:async';

class UserDashboard extends ConsumerStatefulWidget {
  const UserDashboard({super.key});

  @override
  ConsumerState<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends ConsumerState<UserDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    final initialTab = ref.read(tabProvider.notifier).getTab('user_dashboard');
    _tabController = TabController(length: 3, vsync: this, initialIndex: initialTab.clamp(0, 2));
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
        setState(() {});
      }
    });
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref
            .read(tabProvider.notifier)
            .setTab('user_dashboard', _tabController.index);
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
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final expenseState = ref.watch(expenseProvider);
    final fundState = ref.watch(fundProvider);
    ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);


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
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor.withOpacity(0.08),
                          theme.scaffoldBackgroundColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
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
                        children: [Icon(Icons.account_balance_wallet_rounded, size: 18), SizedBox(width: 8), Text("RECEIVED FUND")],
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
                _buildHomeTab(expenseState, fundState, settingsNotifier, theme, user),
                _buildMyExpensesTab(expenseState, user),
                _buildMyFundsTab(fundState, user),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab(dynamic expenseState, dynamic fundState, SettingsNotifier settingsNotifier, ThemeData theme, dynamic user) {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel(theme, "Financial Overview"),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: (expenseState.isLoading || fundState.isLoading)
                  ? List.generate(4, (index) => const DashboardCardSkeleton())
                  : [
                      AnimatedStatCard(
                        title: "Allocated",
                        value: settingsNotifier.formatCurrency(
                          fundState.funds
                              .where((f) => ['ALLOCATED', 'RECEIVED', 'COMPLETED'].contains(f.status.toUpperCase()) && f.toUserId == user?.id)
                              .fold(0.0, (sum, f) => sum + f.amount)
                        ),
                        icon: Icons.payments_rounded,
                        color: AppTheme.accentIndigo,
                        delay: const Duration(milliseconds: 100),
                      ),
                      AnimatedStatCard(
                        title: "Expenses",
                        value: settingsNotifier.formatCurrency(
                          expenseState.expenses
                              .where((e) => e.userId == user?.id)
                              .fold(0.0, (sum, e) => sum + e.amount)
                        ),
                        icon: Icons.receipt_long_rounded,
                        color: theme.primaryColor,
                        delay: const Duration(milliseconds: 200),
                      ),
                      AnimatedStatCard(
                        title: "Balance",
                        value: settingsNotifier.formatCurrency(
                          fundState.funds
                              .where((f) => ['ALLOCATED', 'RECEIVED', 'COMPLETED'].contains(f.status.toUpperCase()) && f.toUserId == user?.id)
                              .fold(0.0, (sum, f) => sum + f.amount) -
                          expenseState.expenses
                              .where((e) => e.userId == user?.id && ['RECEIPT_APPROVED', 'FUND_ALLOCATED', 'EXPANSION_ALLOCATED', 'COMPLETED'].contains(e.status.toUpperCase()))
                              .fold(0.0, (sum, e) => sum + e.amount)
                        ),
                        icon: Icons.account_balance_wallet_rounded,
                        color: const Color(0xFF10B981),
                        delay: const Duration(milliseconds: 300),
                      ),
                      AnimatedStatCard(
                        title: "Pending",
                        value: expenseState.expenses
                              .where((e) => e.userId == user?.id && e.status.toUpperCase() == 'PENDING_APPROVAL')
                              .length.toString(),
                        icon: Icons.hourglass_empty_rounded,
                        color: AppTheme.warningOrange,
                        delay: const Duration(milliseconds: 400),
                      ),
                    ],
            ),

          ],
        ),
      ),
    );
  }


  Widget _buildMyExpensesTab(dynamic expenseState, dynamic user) {
    final myExpenses = expenseState.expenses.where((e) => e.userId == user?.id).toList();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: PremiumTable<ExpenseModel>(
        isLoading: expenseState.isLoading,
        data: myExpenses,
        columns: [
          TableColumn<ExpenseModel>(label: "ID", key: "id"),
          TableColumn<ExpenseModel>(label: "Date", key: "expenseDate", builder: (context, item) => Text(DateFormat('dd-MM-yyyy').format(item.expenseDate.toLocal()))),
          TableColumn<ExpenseModel>(label: "Title", key: "title"),
          TableColumn<ExpenseModel>(label: "Amount", key: "amount", isCurrency: true),
          TableColumn<ExpenseModel>(label: "Status", key: "status", isStatus: true),
        ],
        searchFields: const ["id", "title", "amount", "status"],
        onExportPdf: (data) => ReportGenerator.generateDetailedReportPDF(
          title: "My Expenses",
          headers: ["ID", "Date", "Title", "Amount", "Status"],
          data: data.map((e) => [
            e.id.toString(),
            DateFormat('dd-MM-yyyy').format(e.expenseDate.toLocal()),
            e.title,
            ReportGenerator.formatCurrency(e.amount.toDouble()),
            e.status,
          ]).toList(),
          summaries: {
            "Total Approved": ReportGenerator.formatCurrency(data.where((e) => !['REJECTED', 'PENDING', 'PENDING_APPROVAL'].contains(e.status.toUpperCase())).fold(0.0, (sum, e) => sum + e.amount)),
            "Net Total": ReportGenerator.formatCurrency(data.fold(0.0, (sum, e) => sum + e.amount)),
          },
        ),
        onExportExcel: (data) => ReportGenerator.generateExcel(
          title: "My Expenses",
          headers: ["ID", "Date", "Title", "Amount", "Status"],
          data: data.map((e) => [
            e.id.toString(),
            e.expenseDate.toLocal(),
            e.title,
            e.amount.toDouble(),
            e.status,
          ]).toList(),
          summaries: {
            "Total Approved": ReportGenerator.formatCurrency(data.where((e) => !['REJECTED', 'PENDING', 'PENDING_APPROVAL'].contains(e.status.toUpperCase())).fold(0.0, (sum, e) => sum + e.amount)),
            "Net Total": ReportGenerator.formatCurrency(data.fold(0.0, (sum, e) => sum + e.amount)),
          },
        ),
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
      ),
    );
  }

  Widget _buildMyFundsTab(dynamic fundState, dynamic user) {
    // Simplify filtering as backend already handles USER role filtering
    final myFunds = fundState.funds;
    
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: PremiumTable<FundModel>(
        isLoading: fundState.isLoading,
        data: myFunds,
        columns: [
          TableColumn<FundModel>(label: "ID", key: "id"),
          TableColumn<FundModel>(
            label: "Date", 
            key: "createdAt", 
            builder: (context, item) => Text(
              DateFormat('dd-MM-yyyy').format(item.createdAt.toLocal()),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          TableColumn<FundModel>(label: "Manager", key: "fromUserName"),
          TableColumn<FundModel>(
            label: "Description", 
            key: "description",
            builder: (context, item) => Container(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                item.description ?? "-",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          TableColumn<FundModel>(label: "Amount", key: "amount", isCurrency: true),
          TableColumn<FundModel>(label: "Mode", key: "paymentMode"),
          TableColumn<FundModel>(label: "Status", key: "status", isStatus: true),
        ],
        searchFields: const ["id", "fromUserName", "amount", "description", "status", "paymentMode"],
        onExportPdf: (data) => ReportGenerator.generateDetailedReportPDF(
          title: "Received Funds",
          headers: ["ID", "Date", "Manager", "Description", "Amount", "Mode", "Status"],
          data: data.map((f) => [
            f.id.toString(),
            DateFormat('dd-MM-yyyy').format(f.createdAt.toLocal()),
            f.fromUserName,
            f.description ?? '-',
            ReportGenerator.formatCurrency(f.amount.toDouble()),
            f.paymentMode,
            f.status,
          ]).toList(),
          summaries: {
            "Total Allocated": ReportGenerator.formatCurrency(data.where((f) => ['ALLOCATED', 'RECEIVED', 'COMPLETED'].contains(f.status.toUpperCase())).fold(0.0, (sum, f) => sum + f.amount)),
            "Net Total": ReportGenerator.formatCurrency(data.fold(0.0, (sum, f) => sum + f.amount)),
          },
        ),
        onExportExcel: (data) => ReportGenerator.generateExcel(
          title: "Received Funds",
          headers: ["ID", "Date", "Manager", "Description", "Amount", "Mode", "Status"],
          data: data.map((f) => [
            f.id.toString(),
            f.createdAt.toLocal(),
            f.fromUserName,
            f.description ?? '-',
            f.amount.toDouble(),
            f.paymentMode,
            f.status,
          ]).toList(),
          summaries: {
            "Total Allocated": ReportGenerator.formatCurrency(data.where((f) => ['ALLOCATED', 'RECEIVED', 'COMPLETED'].contains(f.status.toUpperCase())).fold(0.0, (sum, f) => sum + f.amount)),
            "Net Total": ReportGenerator.formatCurrency(data.fold(0.0, (sum, f) => sum + f.amount)),
          },
        ),
        customRowActions: (fund) {
          final status = fund.status.toUpperCase();
          return [
            IconButton(
              icon: const Icon(Icons.visibility_rounded, color: Colors.blue, size: 20),
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => FundDetailsScreen(fund: fund))
              ),
              tooltip: "View Details",
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
            if (status == 'ALLOCATED')
              IconButton(
                icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 20),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirm Receipt"),
                      content: const Text("Are you sure you have received this fund?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref.read(fundProvider.notifier).confirmReceipt(fund.id);
                  }
                },
                tooltip: "Confirm Receipt",
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            if (status == 'RECEIVED') ...[
              const SizedBox(width: 4),
              PremiumExportButton(
                type: ExportType.pdf,
                isIconOnly: true,
                tooltip: "Download Statement",
                onPressed: () => ref.read(fundProvider.notifier).downloadFundStatement(fund.id),
              ),
            ],
          ];
        },
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
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

}

