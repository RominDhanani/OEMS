import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/report_generator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/fund_provider.dart';
import '../../providers/toast_provider.dart';
import '../../providers/expansion_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/expense_model.dart';
import '../../models/fund_model.dart';
import '../../models/expansion_model.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/erp_toast.dart';
import '../../widgets/funds/allocation_form.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/premium/premium_table.dart';
import '../../widgets/premium/premium_export_button.dart';
import '../../widgets/status_badge.dart';
import '../funds/request_expansion_screen.dart';
import '../funds/expansion_details_screen.dart';
import '../expenses/expense_details_screen.dart';
import '../funds/fund_details_screen.dart';


class ManagerTeamScreen extends ConsumerStatefulWidget {
  const ManagerTeamScreen({super.key});

  @override
  ConsumerState<ManagerTeamScreen> createState() => _ManagerTeamScreenState();
}

class _ManagerTeamScreenState extends ConsumerState<ManagerTeamScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).fetchAllUsers();
      ref.read(expenseProvider.notifier).fetchExpenses();
      ref.read(fundProvider.notifier).fetchOperationalFunds();
    });
  }

  void _handleReview(int id, String action, {String? reason, bool isFund = false}) async {
    bool success;
    if (isFund) {
      if (action == 'APPROVE') {
        success = await ref.read(fundProvider.notifier).approveFundRequest(id);
      } else {
        success = await ref.read(fundProvider.notifier).rejectFundRequest(id, reason ?? "Rejected by manager");
      }
    } else {
      if (action == 'APPROVE') {
        success = await ref.read(expenseProvider.notifier).approveExpense(id);
      } else {
        success = await ref.read(expenseProvider.notifier).rejectExpense(id, reason ?? "No reason provided");
      }
    }
    
    if (success && mounted) {
      ref.read(toastProvider.notifier).show(
        message: "${isFund ? 'Fund request' : 'Expense'} ${action.toLowerCase()}d successfully",
        type: action == 'APPROVE' ? ToastType.success : ToastType.warning,
      );
    }
  }

  void _handleDeleteExpansion(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text("Delete Distribution"),
          content: const Text("Are you sure you want to permanently delete this distribution? The funds will be returned to your account."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text("DELETE", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Safely handle potential nulls during regex matching
      final expansionState = ref.read(expansionProvider);
      final request = expansionState.expansions.isEmpty ? null : expansionState.expansions.firstWhere((e) => e.id == id);
      if (request != null) {
        final match = RegExp(r'(?:\(ID:\s*|Expense\s*#)(\d+)').firstMatch(request.justification);
        if (match != null) {
          final expenseIdStr = match.group(1);
          if (expenseIdStr != null) {
            final expenseId = int.tryParse(expenseIdStr);
            if (expenseId != null) {
              await ref.read(expenseProvider.notifier).updateExpenseStatus(expenseId, 'RECEIPT_APPROVED');
            }
          }
        }
      }

      final success = await ref.read(expansionProvider.notifier).deleteExpansion(id);
      if (success && mounted) {
        ref.read(toastProvider.notifier).show(
          message: "Expansion request deleted",
          type: ToastType.success,
        );
      }
    }
  }

  void _showRejectDialog(int id, {bool isFund = false}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text("Reject ${isFund ? 'Fund Request' : 'Expense'}"),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(labelText: "Reason for rejection", border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _handleReview(id, 'REJECT', reason: controller.text, isFund: isFund);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text("REJECT", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    final currentUser = ref.watch(authProvider).user;
    ref.watch(settingsProvider);
    final theme = Theme.of(context);
    

    final expansionState = ref.watch(expansionProvider);
    final teamPendingExpenses = expenseState.expenses.where((e) => 
      e.managerId == currentUser!.id && 
      e.userId != currentUser.id &&
      (e.status == 'PENDING_APPROVAL' || e.status == 'RECEIPT_APPROVED' || e.status == 'EXPANSION_REQUESTED') &&
      !expansionState.expansions.any((ef) => 
        ef.justification.contains("(ID: ${e.id})") || 
        ef.justification.contains("Expense #${e.id}")
      )
    ).toList();

    final fundState = ref.watch(fundProvider);
    final teamPendingFunds = fundState.funds.where((f) => 
      f.fromUserId == currentUser!.id && 
      f.toUserId != currentUser.id &&
      (f.status.toUpperCase() == 'PENDING' || f.status.toUpperCase() == 'APPROVED')
    ).toList();

    final managerActiveExpansions = expansionState.expansions.where((e) => 
      e.managerId == currentUser!.id && 
      (e.status.toUpperCase() == 'PENDING' || e.status.toUpperCase() == 'REJECTED')
    ).toList();

    final totalApprovals = teamPendingExpenses.length + teamPendingFunds.length + managerActiveExpansions.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppLoader(
        isLoading: false, 
        child: currentUser == null 
        ? const Center(child: Text("Authentication Required"))
        : DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: theme.colorScheme.secondary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.65),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                indicator: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.8),
                physics: const BouncingScrollPhysics(),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fact_check_rounded, size: 18),
                        const SizedBox(width: 8),
                        const Text("APPROVALS"),
                        if (totalApprovals > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [BoxShadow(color: theme.colorScheme.secondary.withOpacity(0.3), blurRadius: 4)],
                            ),
                            child: Text("$totalApprovals", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.history_rounded, size: 18),
                        SizedBox(width: 8),
                        Text("ALL EXPENSE"),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Approvals Tab
                    totalApprovals == 0
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.done_all_rounded, size: 64, color: theme.primaryColor.withOpacity(0.1)),
                              const SizedBox(height: 16),
                              Text("No pending approvals", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            children: [
                            if (teamPendingFunds.isNotEmpty) ...[
                              _buildApprovalHeader("FUND REQUESTS", teamPendingFunds.length, theme),
                              ...teamPendingFunds.map((f) => _buildFundApprovalCard(f, theme)),
                              const SizedBox(height: 24),
                            ],
                            if (teamPendingExpenses.isNotEmpty) ...[
                              _buildApprovalHeader("EXPENSE APPROVALS", teamPendingExpenses.length, theme),
                              ...teamPendingExpenses.map((exp) => _buildExpenseApprovalCard(exp, theme)),
                              const SizedBox(height: 24),
                            ],
                            if (managerActiveExpansions.isNotEmpty) ...[
                              _buildApprovalHeader("MY EXPANSION REQUESTS", managerActiveExpansions.length, theme),
                              ...managerActiveExpansions.map((ex) => _buildExpansionTrackingCard(ex, theme)),
                            ],
                          ],
                        ),
                    
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: PremiumTable<ExpenseModel>(
                        isLoading: expenseState.isLoading,
                        data: expenseState.expenses.where((e) => e.managerId == currentUser.id && e.userId != currentUser.id).toList(),
                        columns: [
                          TableColumn<ExpenseModel>(label: "ID", key: "id", builder: (context, e) => Text(e.id.toString())),
                          TableColumn<ExpenseModel>(
                            label: "Date", 
                            key: "expenseDate",
                            builder: (context, e) => Text(DateFormat('dd-MM-yyyy').format(e.expenseDate.toLocal()))
                          ),
                          TableColumn<ExpenseModel>(label: "Employee", key: "userName", builder: (context, e) => Text(e.userName)),
                          TableColumn<ExpenseModel>(label: "Category", key: "category", builder: (context, e) => Text(e.category)),
                          TableColumn<ExpenseModel>(label: "Department", key: "department", builder: (context, e) => Text(e.department ?? "-")),
                          TableColumn<ExpenseModel>(label: "Title", key: "title", builder: (context, e) => Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          TableColumn<ExpenseModel>(label: "Amount", key: "amount", builder: (context, e) => Text(ref.read(settingsProvider.notifier).formatCurrency(e.amount.toDouble()))),
                          TableColumn<ExpenseModel>(label: "Approved By", key: "approvedByName", builder: (context, e) => Text(e.approvedByName ?? "-")),
                          TableColumn<ExpenseModel>(label: "Status", key: "status", isStatus: true),
                        ],
                        searchFields: const ["title", "userName", "status", "category"],
                        customRowActions: (item) => [
                          IconButton(
                            icon: Icon(Icons.visibility_rounded, size: 20, color: theme.colorScheme.secondary),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ExpenseDetailsScreen(expense: item)),
                              );
                            },
                            tooltip: "View Details",
                          ),
                          // Request Expansion button for RECEIPT_APPROVED expenses (only if no expansion exists)
                          if (item.status.toUpperCase() == 'RECEIPT_APPROVED' &&
                              !expansionState.expansions.any((ef) =>
                                ef.justification.contains("(ID: ${item.id})") ||
                                ef.justification.contains("Expense #${item.id}")))
                            IconButton(
                              icon: Icon(Icons.add_circle_outline_rounded, size: 20, color: theme.colorScheme.secondary),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RequestExpansionScreen(
                                    preFillExpenseId: item.id.toString(),
                                    preFillAmount: item.amount.toString(),
                                    preFillJustification: "Expansion fund for approved expense: ${item.title} (ID: ${item.id})",
                                  ),
                                ),
                              ),
                              tooltip: "Request Expansion",
                            ),
                          PremiumExportButton(
                            type: ExportType.pdf,
                            isIconOnly: true,
                            tooltip: "Download Invoice",
                            onPressed: () => ReportGenerator.generateExpensePDF(item),
                          ),
                        ],
                        onExportPdf: (data) {
                          ReportGenerator.generateDetailedReportPDF(
                            title: "Team Expenses Report",
                            headers: ["Date", "User", "Category", "Title", "Amount", "Status"],
                            data: data.map((item) => [
                              DateFormat('dd-MM-yyyy').format(item.expenseDate.toLocal()),
                              item.userName,
                              item.category,
                              item.title,
                              ReportGenerator.formatCurrency(item.amount.toDouble()),
                              item.status
                            ]).toList(),
                            summaries: {
                              "Total Approved": ReportGenerator.formatCurrency(data.where((e) => !['REJECTED', 'PENDING', 'PENDING_APPROVAL'].contains(e.status.toUpperCase())).fold(0.0, (sum, e) => sum + e.amount)),
                              "Net Amount": ReportGenerator.formatCurrency(data.fold(0.0, (sum, e) => sum + e.amount)),
                            },
                          );
                        },
                        onExportExcel: (data) {
                          final columns = ["Date", "User", "Category", "Title", "Amount", "Status"];
                          final rows = data.map((item) => [
                            DateFormat('dd-MM-yyyy').format(item.expenseDate.toLocal()),
                            item.userName,
                            item.category,
                            item.title,
                            item.amount.toDouble(),
                            item.status
                          ]).toList();
                          ReportGenerator.generateExcel(title: "Team_Expenses", headers: columns, data: rows);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalHeader(String title, int count, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.7), letterSpacing: 1.5)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: theme.colorScheme.secondary.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Text("$count", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: theme.colorScheme.secondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildFundApprovalCard(dynamic fund, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fund.toUserName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(DateFormat('dd-MM-yyyy').format(fund.createdAt.toLocal()), style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "${fund.amount}",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.secondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(fund.description ?? "No justification provided", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FundDetailsScreen(fund: fund)),
              ),
              icon: Icon(Icons.visibility_rounded, size: 20, color: theme.colorScheme.secondary),
              tooltip: "VIEW DETAILS",
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(height: 16),
            if (fund.status.toUpperCase() == 'PENDING')
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showRejectDialog(fund.id, isFund: true),
                    icon: const Icon(Icons.close_rounded, color: Colors.red, size: 22),
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.all(12),
                    ),
                    tooltip: "REJECT",
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => _handleReview(fund.id, 'APPROVE', isFund: true),
                    icon: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      padding: const EdgeInsets.all(12),
                    ),
                    tooltip: "APPROVE",
                  ),
                ],
              )
            else if (fund.status.toUpperCase() == 'APPROVED')
              IconButton(
                onPressed: () => _showAllocationFlow(fund),
                icon: const Icon(Icons.payments_rounded, color: Colors.white, size: 22),
                style: IconButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.all(12),
                ),
                tooltip: "ALLOCATE FUNDS",
              ),
          ],
        ),
      ),
    );
  }

  void _showAllocationFlow(FundModel fund) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => AllocationForm(
          managers: [], // Not needed for request allocation as target is fixed
          initialData: {
            'to_user_id': fund.toUserId,
            'amount': fund.amount,
            'description': "Fund for request #${fund.id}: ${fund.description}",
            // We pass the request ID to mark it as allocated after creating the operational fund
          },
          onCancel: () => Navigator.pop(context),
          onSubmit: (data, path) async {
            final success = await ref.read(fundProvider.notifier).allocateFund(data, filePath: path);
            if (success) {
              // Now mark the original request as ALLOCATED
              await ref.read(fundProvider.notifier).allocateFundRequest(fund.id);
              if (!context.mounted) return;
              Navigator.pop(context);
              ref.read(toastProvider.notifier).show(message: "Fund allocated successfully", type: ToastType.success);
            }
          },
        ),
      ),
    );
  }

  Widget _buildExpenseApprovalCard(ExpenseModel exp, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exp.userName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text("${exp.category} • ${DateFormat('dd-MM-yyyy').format(exp.expenseDate.toLocal())}", style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "${exp.amount}",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: theme.primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            Text(exp.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // Status and metadata Row
            Row(
              children: [
                StatusBadge(status: exp.status),
                const Spacer(),
                if (exp.approvedByName != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      "Approved by ${exp.approvedByName}",
                      style: TextStyle(
                        fontSize: 10, 
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            
            const Divider(height: 32),
            
            // Primary actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExpenseDetailsScreen(expense: exp)),
                  ),
                  icon: Icon(Icons.visibility_rounded, size: 20, color: theme.colorScheme.secondary),
                  tooltip: "VIEW DETAILS",
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                if (exp.status == 'PENDING_APPROVAL') ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showRejectDialog(exp.id),
                        icon: const Icon(Icons.close_rounded, color: Colors.red, size: 22),
                        style: IconButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.all(12),
                        ),
                        tooltip: "REJECT",
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => _handleReview(exp.id, 'APPROVE'),
                        icon: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.successGreen,
                          padding: const EdgeInsets.all(12),
                        ),
                        tooltip: "APPROVE",
                      ),
                    ],
                  ),
                ] else if (exp.status == 'RECEIPT_APPROVED') ...[
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestExpansionScreen(
                          preFillExpenseId: exp.id.toString(),
                          preFillAmount: exp.amount.toString(),
                          preFillJustification: "Expansion fund for approved expense: ${exp.title} (ID: ${exp.id})",
                        ),
                      ),
                    ),
                    icon: Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 22),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      padding: const EdgeInsets.all(12),
                    ),
                    tooltip: "REQUEST EXPANSION",
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTrackingCard(ExpansionModel expansion, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Expansion Request", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      Text(DateFormat('dd-MM-yyyy').format(expansion.requestedAt.toLocal()), style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    ref.read(settingsProvider.notifier).formatCurrency(expansion.requestedAmount.toDouble()),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.secondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(expansion.justification, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                StatusBadge(status: expansion.status),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true, // aligns right
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (expansion.status.toUpperCase() == 'PENDING' || expansion.status.toUpperCase() == 'REJECTED') ...[
                          IconButton(
                            icon: Icon(Icons.edit_rounded, color: theme.colorScheme.secondary, size: 20),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RequestExpansionScreen(expansion: expansion),
                              ),
                            ),
                            tooltip: "Edit Request",
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 20),
                            onPressed: () => _handleDeleteExpansion(expansion.id),
                            tooltip: "Delete Request",
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                        ],
                        IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ExpansionDetailsScreen(expansion: expansion)),
                          ),
                          icon: const Icon(Icons.visibility_rounded, size: 20, color: Colors.blue),
                          tooltip: "VIEW STATUS",
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

