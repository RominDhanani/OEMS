import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/common/table_filter_bar.dart';
import '../../widgets/common/table_pagination_footer.dart';
import '../../widgets/premium/premium_skeleton.dart';
import '../../widgets/common/app_loader.dart';
import '../../core/utils/table_manager.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/design_utils.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  final _searchController = TextEditingController();
  DateTimeRange? _dateRange;
  Map<String, String> _selectedFilters = {'category': 'All', 'status': 'All'};
  
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expenseProvider.notifier).fetchExpenses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseState = ref.watch(expenseProvider);
    ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    
    final manager = TableManager(
      allData: expenseState.expenses,
      searchFields: const ['id', 'title', 'category', 'amount', 'description'],
      dateField: 'expenseDate',
    );

    final filteredExpenses = manager.filter(
      searchTerm: _searchController.text,
      dateRange: _dateRange,
      fieldFilters: _selectedFilters,
    );

    final totalItems = filteredExpenses.length;
    final totalPages = manager.getTotalPages(totalItems, _itemsPerPage);
    final paginatedExpenses = manager.getPaginatedData(filteredExpenses, _currentPage, _itemsPerPage);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: theme.scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: Text(
                    "Transaction History",
                    style: GoogleFonts.outfit(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primaryColor.withOpacity(0.1), theme.colorScheme.secondary.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: AppLoader(
            isLoading: false, // Use skeleton instead of full screen loader
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Column(
                children: [
                  TableFilterBar(
                    searchController: _searchController,
                    searchPlaceholder: "Search activities...",
                    dateRange: _dateRange,
                    onDateRangeChanged: (range) => setState(() { _dateRange = range; _currentPage = 1; }),
                    dropdownFilters: const {
                      'category': AppConstants.expenseCategories,
                      'status': ['PENDING_APPROVAL', 'COMPLETED', 'REJECTED'],
                    },
                    selectedFilters: _selectedFilters,
                    onFilterChanged: (key, value) => setState(() { _selectedFilters[key] = value; _currentPage = 1; }),
                    onClearFilters: () => setState(() {
                      _searchController.clear();
                      _dateRange = null;
                      _selectedFilters = {'category': 'All', 'status': 'All'};
                      _currentPage = 1;
                    }),
                  ),
                  Expanded(
                    child: expenseState.isLoading 
                        ? ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: 8,
                            itemBuilder: (context, index) => const ExpenseCardSkeleton(),
                          )
                        : paginatedExpenses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_toggle_off_rounded, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.1)),
                                const SizedBox(height: 16),
                                Text("No activity found", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            itemCount: paginatedExpenses.length + 1, // +1 for the footer
                            itemBuilder: (context, index) {
                              if (index == paginatedExpenses.length) {
                                // Return the pagination footer as the last item
                                return Padding(
                                  padding: const EdgeInsets.only(top: 16, bottom: 20),
                                  child: TablePaginationFooter(
                                    currentPage: _currentPage,
                                    totalPages: totalPages == 0 ? 1 : totalPages,
                                    totalItems: totalItems,
                                    itemsPerPage: _itemsPerPage,
                                    onPageChanged: (page) => setState(() => _currentPage = page),
                                    onItemsPerPageChanged: (size) => setState(() { _itemsPerPage = size; _currentPage = 1; }),
                                  ),
                                );
                              }

                              final expense = paginatedExpenses[index];
                              final categoryInfo = DesignUtils.getCategoryInfo(expense.category);
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: theme.cardTheme.color,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.shadowColor.withOpacity(0.04),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                  border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => context.push('/expense_details', extra: expense),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            // Category Icon
                                            Container(
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: categoryInfo.color.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Icon(
                                                categoryInfo.icon,
                                                color: categoryInfo.color,
                                                size: 28,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Title & Details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    expense.title,
                                                    style: GoogleFonts.outfit(
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 16,
                                                      letterSpacing: -0.2,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "${expense.category} • ${DateFormat('dd-MM-yyyy').format(expense.expenseDate.toLocal())}",
                                                    style: TextStyle(
                                                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Amount & Status
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  settingsNotifier.formatCurrency(expense.amount),
                                                  style: GoogleFonts.outfit(
                                                    fontWeight: FontWeight.w900,
                                                    color: theme.colorScheme.primary,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                StatusBadge(status: expense.status, fontSize: 10),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/create_expense'),
          elevation: 8,
          highlightElevation: 0,
          backgroundColor: theme.primaryColor,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          label: Text(
            "Add Expense",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.8, fontSize: 13),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
    );
  }
}

