import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/report_provider.dart';
import '../../models/expense_model.dart';
import '../../models/fund_model.dart';
import '../../models/expansion_model.dart';
import '../../core/utils/report_generator.dart';
import '../../widgets/common/table_filter_bar.dart';
import '../../widgets/common/table_pagination_footer.dart';
import '../../widgets/common/app_loader.dart';
import '../../providers/toast_provider.dart';
import '../../widgets/common/erp_toast.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common/erp_app_bar.dart';
import '../expenses/expense_details_screen.dart';
import '../funds/fund_details_screen.dart';
import '../funds/expansion_details_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/premium/premium_report_card.dart';
import '../../widgets/premium/premium_skeleton.dart';
import '../../core/utils/table_manager.dart';
import '../../widgets/premium/premium_export_button.dart';

enum ReportMode { expenses, category, funds, expansions }

class ReportsScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const ReportsScreen({super.key, this.isEmbedded = false});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ReportMode _currentMode = ReportMode.expenses;
  List<ReportMode> _allowedModes = ReportMode.values;

  // Filter States
  final _searchController = TextEditingController();
  DateTimeRange? _dateRange;
  final Map<String, String> _selectedFilters = {'category': 'All', 'status': 'All', 'scope': 'All', 'department': 'All'};
  
  // Pagination State
  int _currentPage = 1;
  int _itemsPerPage = 10;
  bool _showFooter = true;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(authProvider).user;
    _allowedModes = _getModesForRole(currentUser?.role);
    
    _tabController = TabController(length: _allowedModes.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentMode = _allowedModes[_tabController.index];
          _resetFilters();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  List<ReportMode> _getModesForRole(String? role) {
    if (role == 'USER') {
      return [ReportMode.expenses, ReportMode.category, ReportMode.funds];
    }
    return ReportMode.values;
  }

  void _resetFilters() {
    _searchController.clear();
    _dateRange = null;
    _selectedFilters['category'] = 'All';
    _selectedFilters['status'] = 'All';
    _selectedFilters['scope'] = 'All';
    _selectedFilters['department'] = 'All';
    _currentPage = 1;
    ref.read(reportProvider.notifier).clearReports();
  }

  bool _hasActiveFilters() {
    return _dateRange != null || 
           (_selectedFilters['category'] != 'All') || 
           (_selectedFilters['department'] != 'All');
  }

  Future<void> _fetchData() async {
    final startStr = _dateRange != null ? DateFormat('yyyy-MM-dd').format(_dateRange!.start) : null;
    final endStr = _dateRange != null ? DateFormat('yyyy-MM-dd').format(_dateRange!.end) : null;

    // Requirement: Only show data if specific filters (category or date or department) are chosen
    // for expenses and category reports.
    if ((_currentMode == ReportMode.expenses || _currentMode == ReportMode.category) && !_hasActiveFilters()) {
      ref.read(reportProvider.notifier).clearReports();
      return;
    }

    final notifier = ref.read(reportProvider.notifier);
    
    switch (_currentMode) {
      case ReportMode.expenses:
        await notifier.fetchExpenseReports(
          startDate: startStr,
          endDate: endStr,
          category: _selectedFilters['category'],
          department: _selectedFilters['department'],
          status: _selectedFilters['status'],
          scope: _selectedFilters['scope'],
        );
        break;
      case ReportMode.category:
        await notifier.fetchExpenseReports(
          startDate: startStr,
          endDate: endStr,
          category: _selectedFilters['category'],
          department: _selectedFilters['department'],
          status: _selectedFilters['status'],
          scope: _selectedFilters['scope'],
          type: 'category',
        );
        break;
      case ReportMode.funds:
        await notifier.fetchFundReports(
          startDate: startStr,
          endDate: endStr,
          status: _selectedFilters['status'],
          scope: _selectedFilters['scope'],
        );
        break;
      case ReportMode.expansions:
        await notifier.fetchExpansionReports(
          startDate: startStr,
          endDate: endStr,
          status: _selectedFilters['status'],
        );
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredData() {
    final reportState = ref.watch(reportProvider);
    final data = reportState.data;

    if (_searchController.text.isEmpty) return data;

    final searchTerm = _searchController.text.toLowerCase();
    return data.where((item) {
      final id = (item is ExpenseModel ? item.id : (item is FundModel ? item.id : (item is ExpansionModel ? item.id : ''))).toString().toLowerCase();
      final amount = (item is ExpenseModel ? item.amount : (item is FundModel ? item.amount : (item is ExpansionModel ? item.requestedAmount : (item is Map ? item['total'] : '')))).toString().toLowerCase();
      final status = (item is ExpenseModel ? item.status : (item is FundModel ? item.status : (item is ExpansionModel ? item.status : ''))).toString().toLowerCase();

      if (item is ExpenseModel) {
        return id.contains(searchTerm) ||
               item.title.toLowerCase().contains(searchTerm) || 
               item.userName.toLowerCase().contains(searchTerm) ||
               item.category.toLowerCase().contains(searchTerm) ||
               amount.contains(searchTerm) ||
               status.contains(searchTerm);
      } else if (item is FundModel) {
        return id.contains(searchTerm) ||
               item.fromUserName.toLowerCase().contains(searchTerm) || 
               item.toUserName.toLowerCase().contains(searchTerm) ||
               (item.description?.toLowerCase().contains(searchTerm) ?? false) ||
               amount.contains(searchTerm) ||
               status.contains(searchTerm);
      } else if (item is ExpansionModel) {
        return id.contains(searchTerm) ||
               item.managerName.toLowerCase().contains(searchTerm) || 
               item.justification.toLowerCase().contains(searchTerm) ||
               amount.contains(searchTerm) ||
               status.contains(searchTerm);
      } else if (item is Map) {
        final category = item['category']?.toString().toLowerCase() ?? '';
        return category.contains(searchTerm) || amount.contains(searchTerm);
      }
      return false;
    }).toList();
  }

  Map<String, double> _calculateSummaries(List<dynamic> filteredData) {
    double gross = 0;
    double rejected = 0;
    double net = 0;

    for (var item in filteredData) {
      double amount = 0;
      String status = 'COMPLETED';

      if (item is ExpenseModel) {
        amount = item.amount.toDouble();
        status = item.status;
      } else if (item is FundModel) {
        amount = item.amount.toDouble();
        status = item.status;
      } else if (item is ExpansionModel) {
        amount = item.requestedAmount.toDouble();
        status = item.status;
      } else if (item is Map) {
        amount = (item['total'] as num).toDouble();
        status = 'COMPLETED';
      }

      gross += amount;
      if (status.toUpperCase().contains('REJECTED')) {
        rejected += amount;
      } else {
        net += amount;
      }
    }

    return {'gross': gross, 'rejected': rejected, 'net': net};
  }

  void _handleExportExcel() async {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) {
      ref.read(toastProvider.notifier).show(message: "No data to export", type: ToastType.info);
      return;
    }

    try {
      String title = "${_currentMode.name.toUpperCase()} Report";
      List<String> headers = [];
      List<List<dynamic>> rows = [];

      switch (_currentMode) {
        case ReportMode.expenses:
          headers = ["Date", "Title", "Category", "User", "Amount", "Status"];
          rows = filteredData.map((e) => [DateFormat('dd-MM-yyyy').format(e.expenseDate), e.title, e.category, e.userName, e.amount, e.status]).toList();
          break;
        case ReportMode.funds:
          headers = ["Date", "From", "To", "Mode", "Amount", "Status"];
          rows = filteredData.map((e) => [DateFormat('dd-MM-yyyy').format(e.createdAt), e.fromUserName, e.toUserName, e.paymentMode, e.amount, e.status]).toList();
          break;
        case ReportMode.category:
          headers = ["Category", "Record Count", "Total Amount"];
          rows = filteredData.map((e) => [e['category'], e['count'], e['total']]).toList();
          break;
        case ReportMode.expansions:
          headers = ["Date", "Manager", "Justification", "Amount", "Status"];
          rows = filteredData.map((e) => [DateFormat('dd-MM-yyyy').format(e.requestedAt), e.managerName, e.justification, e.requestedAmount, e.status]).toList();
          break;
      }

      final settings = ref.read(settingsProvider.notifier);
      final summaries = _calculateSummaries(filteredData);
      final Map<String, String> excelSummaries = {
        "GROSS": settings.formatCurrency(summaries['gross']!),
        "REJECTED": settings.formatCurrency(summaries['rejected']!),
        "NET TOTAL": settings.formatCurrency(summaries['net']!),
      };

      await ReportGenerator.generateExcel(
        title: title, 
        headers: headers, 
        data: rows,
        summaries: excelSummaries,
      );
      ref.read(toastProvider.notifier).show(message: "Report exported to Excel", type: ToastType.success);
    } catch (e) {
      ref.read(toastProvider.notifier).show(message: "Export failed: $e", type: ToastType.error);
    }
  }

  void _handleExportPDF() async {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) {
      ref.read(toastProvider.notifier).show(message: "No data to export", type: ToastType.info);
      return;
    }

    try {
      final summaries = _calculateSummaries(filteredData);
      String title = "${_currentMode.name.toUpperCase()} Report";
      List<String> headers = [];
      List<List<String>> rows = [];

      switch (_currentMode) {
        case ReportMode.expenses:
          headers = ["Date", "Title", "Category", "User", "Amount", "Status"];
          rows = filteredData.map<List<String>>((e) => [
            DateFormat('dd-MM-yyyy').format(e.expenseDate),
            e.title,
            e.category,
            e.userName,
            ReportGenerator.formatCurrency(e.amount.toDouble()),
            e.status
          ]).toList();
          break;
        case ReportMode.funds:
          headers = ["Date", "From", "To", "Mode", "Amount", "Status"];
          rows = filteredData.map<List<String>>((e) => [
            DateFormat('dd-MM-yyyy').format(e.createdAt),
            e.fromUserName,
            e.toUserName,
            e.paymentMode,
            ReportGenerator.formatCurrency(e.amount.toDouble()),
            e.status
          ]).toList();
          break;
        case ReportMode.category:
          headers = ["Category", "Count", "Total Amount"];
          rows = filteredData.map<List<String>>((e) => [
            e['category'],
            e['count'].toString(),
            ReportGenerator.formatCurrency((e['total'] as num).toDouble())
          ]).toList();
          break;
        case ReportMode.expansions:
          headers = ["Date", "Manager", "Justification", "Amount", "Status"];
          rows = filteredData.map<List<String>>((e) => [
            DateFormat('dd-MM-yyyy').format(e.requestedAt),
            e.managerName,
            e.justification,
            ReportGenerator.formatCurrency(e.requestedAmount.toDouble()),
            e.status
          ]).toList();
          break;
      }

      await ReportGenerator.generateDetailedReportPDF(
        title: title,
        headers: headers,
        data: rows,
        summaries: {
          "GROSS": ReportGenerator.formatCurrency(summaries['gross']!),
          "REJECTED": ReportGenerator.formatCurrency(summaries['rejected']!),
          "NET TOTAL": ReportGenerator.formatCurrency(summaries['net']!),
        },
      );
      ref.read(toastProvider.notifier).show(message: "Report exported to PDF", type: ToastType.success);
    } catch (e) {
      ref.read(toastProvider.notifier).show(message: "Export failed: $e", type: ToastType.error);
    }
  }

  void _showCategoryDetails(String category) async {
    final settings = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    
    // Fetch detailed expenses for this category from backend
    final startStr = _dateRange != null ? DateFormat('yyyy-MM-dd').format(_dateRange!.start) : null;
    final endStr = _dateRange != null ? DateFormat('yyyy-MM-dd').format(_dateRange!.end) : null;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) => FutureBuilder<List<ExpenseModel>>(
          future: ref.read(reportProvider.notifier).fetchExpensesDirect(
            category: category,
            startDate: startStr,
            endDate: endStr,
            department: _selectedFilters['department'],
            scope: _selectedFilters['scope'],
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            
            final expenses = snapshot.data ?? [];
            
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(category, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text("${expenses.length} Total Records", style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const Divider(height: 32),
                  Expanded(
                    child: expenses.isEmpty
                      ? Center(child: Text("No detailed expenses found.", style: GoogleFonts.inter(color: Colors.grey[400])))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final exp = expenses[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(exp.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                subtitle: Text(DateFormat('dd MMM yyyy').format(exp.expenseDate)),
                                trailing: Text(
                                  settings.formatCurrency(exp.amount),
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ExpenseDetailsScreen(expense: exp)),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportState = ref.watch(reportProvider);
    final filteredData = _getFilteredData();
    final totalItems = filteredData.length;
    final totalPages = (totalItems / _itemsPerPage).ceil();
    final paginatedData = TableManager(allData: [], searchFields: []).getPaginatedData(filteredData, _currentPage, _itemsPerPage);
    final summaries = _calculateSummaries(filteredData);
    final currentUser = ref.watch(authProvider).user;
    final settings = ref.read(settingsProvider.notifier);

    final widgetContent = Column(
      children: [
        if (widget.isEmbedded) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Text("Role-based Reports", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                 Row(
                   children: [
                     PremiumExportButton(
                       type: ExportType.pdf,
                       onPressed: _handleExportPDF,
                     ),
                     const SizedBox(width: 8),
                     PremiumExportButton(
                       type: ExportType.excel,
                       onPressed: _handleExportExcel,
                     ),
                   ],
                 ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            labelColor: theme.colorScheme.secondary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.75),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            indicator: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3), width: 1),
            ),
            dividerColor: Colors.transparent,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
            unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.5),
            physics: const BouncingScrollPhysics(),
            tabs: _allowedModes.map((mode) => _buildTab(mode)).toList(),
          ),
        ],
        TableFilterBar(
          searchController: _searchController,
          searchPlaceholder: "Search ${_currentMode.name}...",
          dateRange: _dateRange,
          onDateRangeChanged: (range) {
             setState(() => _dateRange = range);
             _fetchData();
          },
          dropdownFilters: {
            if (_currentMode == ReportMode.expenses || _currentMode == ReportMode.category) ...{
              'category': AppConstants.expenseCategories,
              'department': AppConstants.departmentTypes,
            },
            if (_currentMode != ReportMode.category)
              'status': _currentMode == ReportMode.expenses 
                ? ['PENDING_APPROVAL', 'RECEIPT_APPROVED', 'FUND_ALLOCATED', 'COMPLETED', 'REJECTED']
                : ['PENDING', 'APPROVED', 'REJECTED', 'ALLOCATED', 'RECEIVED', 'COMPLETED'],
            if (currentUser?.role != 'USER')
              'scope': ['Me', 'Team'],
          },
          selectedFilters: _selectedFilters,
          onFilterChanged: (key, value) {
             setState(() {
               _selectedFilters[key] = value;
               _currentPage = 1;
             });
             _fetchData();
          },
          onClearFilters: () {
             setState(() => _resetFilters());
             _fetchData();
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RefreshIndicator(
            onRefresh: _fetchData,
            child: (_currentMode == ReportMode.expenses || _currentMode == ReportMode.category) && !_hasActiveFilters()
              ? _buildEmptyState("Use filters to generate report", "Choose a category or date range to view data.", theme)
              : reportState.isLoading
                ? _buildSkeletonList()
                : filteredData.isEmpty
                  ? _buildEmptyState("No Records Found", "Try adjusting your filters", theme)
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: paginatedData.length,
                    itemBuilder: (context, index) {
                      final item = paginatedData[index];
                      return _buildReportItem(item, settings);
                    },
                  ),
          ),
        ),
        if (filteredData.isNotEmpty) ...[
          const SizedBox(height: 16),
          Center(
            child: InkWell(
              onTap: () => setState(() => _showFooter = !_showFooter),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.primaryColor.withOpacity(0.35), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showFooter ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                      size: 20,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _showFooter ? "HIDE FOOTER" : "SHOW FOOTER",
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: theme.primaryColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showFooter) ...[
            const SizedBox(height: 8),
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
            _buildSummaryFooter(summaries),
          ],
        ],
      ],
    );

    final content = AppLoader(
      isLoading: false, // Use skeletons instead of full-screen loader
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: widgetContent,
      ),
    );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: content,
      );
    }

    return Scaffold(
      appBar: ERPAppBar(
        showSettingsAndNotifications: false,
        actions: [
          PremiumExportButton(
            type: ExportType.pdf,
            isIconOnly: true,
            onPressed: _handleExportPDF,
          ),
          const SizedBox(width: 8),
          PremiumExportButton(
            type: ExportType.excel,
            isIconOnly: true,
            onPressed: _handleExportExcel,
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          labelColor: theme.colorScheme.secondary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.75),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          indicator: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3), width: 1),
          ),
          dividerColor: Colors.transparent,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
          unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.5),
          physics: const BouncingScrollPhysics(),
          tabs: _allowedModes.map((mode) => _buildTab(mode)).toList(),
        ),
      ),
      body: content,
    );
  }

  Widget _buildTab(ReportMode mode) {
    switch (mode) {
      case ReportMode.expenses:
        return const Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
               Icon(Icons.receipt_long_rounded, size: 18),
               SizedBox(width: 8),
               Text("EXPENSES"),
            ],
          ),
        );
      case ReportMode.category:
        return const Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
               Icon(Icons.pie_chart_rounded, size: 18),
               SizedBox(width: 8),
               Text("CATEGORY"),
            ],
          ),
        );
      case ReportMode.funds:
        return const Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
               Icon(Icons.account_balance_wallet_rounded, size: 18),
               SizedBox(width: 8),
               Text("FUNDS"),
            ],
          ),
        );
      case ReportMode.expansions:
        return const Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
               Icon(Icons.trending_up_rounded, size: 18),
               SizedBox(width: 8),
               Text("EXPANSIONS"),
            ],
          ),
        );
    }
  }

  Widget _buildEmptyState(String title, String subtitle, ThemeData theme) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.analytics_outlined, size: 52, color: theme.primaryColor.withOpacity(0.35)),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryFooter(Map<String, double> summaries) {
    if (_getFilteredData().isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(child: _buildFooterStat("GROSS", summaries['gross']!, theme.primaryColor, Icons.account_balance_wallet_rounded)),
              VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor.withOpacity(0.1), indent: 16, endIndent: 16),
              Expanded(child: _buildFooterStat("REJECTED", summaries['rejected']!, Colors.redAccent, Icons.cancel_presentation_rounded)),
              VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor.withOpacity(0.1), indent: 16, endIndent: 16),
              Expanded(child: _buildFooterStat("NET TOTAL", summaries['net']!, const Color(0xFF10B981), Icons.check_circle_outline_rounded)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterStat(String label, double amount, Color color, IconData icon) {
    final settings = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(
                label, 
                style: GoogleFonts.outfit(
                  fontSize: 10, 
                  fontWeight: FontWeight.w900, 
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  letterSpacing: 0.5,
                )
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              settings.formatCurrency(amount),
              style: GoogleFonts.outfit(
                fontSize: 15, 
                fontWeight: FontWeight.w900, 
                color: color,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(dynamic item, dynamic settings) {
    return PremiumReportCard(
      item: item,
      formattedAmount: settings.formatCurrency(
        item is ExpenseModel 
          ? item.amount.toDouble() 
          : (item is FundModel 
              ? item.amount.toDouble() 
              : (item is ExpansionModel 
                  ? item.requestedAmount.toDouble() 
                  : (item['total'] as num).toDouble()))
      ),
      onTap: () {
        if (item is ExpenseModel) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseDetailsScreen(expense: item)));
        } else if (item is FundModel) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FundDetailsScreen(fund: item)));
        } else if (item is ExpansionModel) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ExpansionDetailsScreen(expansion: item)));
        } else if (item is Map) {
          _showCategoryDetails(item['category']);
        }
      },
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) => const ExpenseCardSkeleton(),
    );
  }
}
