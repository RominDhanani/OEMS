import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/fund_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/expansion_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/user_model.dart';
import '../../models/fund_model.dart';
import '../../models/expansion_model.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/erp_toast.dart';
import '../../widgets/funds/allocation_form.dart';
import '../../widgets/premium/premium_table.dart';
import '../../widgets/premium/premium_export_button.dart';
import '../../core/utils/report_generator.dart';
import '../funds/fund_details_screen.dart';

import '../funds/expansion_details_screen.dart';
import '../funds/request_expansion_screen.dart';
import 'package:intl/intl.dart';

class ManagerFundManagementScreen extends ConsumerStatefulWidget {
  const ManagerFundManagementScreen({super.key});

  @override
  ConsumerState<ManagerFundManagementScreen> createState() => _ManagerFundManagementScreenState();
}

class _ManagerFundManagementScreenState extends ConsumerState<ManagerFundManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fundProvider.notifier).fetchOperationalFunds();
      ref.read(userProvider.notifier).fetchAllUsers();
    });
  }

  void _handleAllocation(Map<String, dynamic> data, String? filePath) async {
    await ref.read(fundProvider.notifier).allocateFund(data, filePath: filePath);
    if (mounted) {
      ref.read(toastProvider.notifier).show(
        message: "Fund allocated successfully",
        type: ToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fundState = ref.watch(fundProvider);
    final userState = ref.watch(userProvider);
    final expenseState = ref.watch(expenseProvider);
    final currentUser = ref.watch(authProvider).user;
    ref.watch(settingsProvider);
    final theme = Theme.of(context);

    // Funds received from CEO
    final receivedFunds = fundState.funds.where((f) => f.toUserId == currentUser?.id).toList();
    
    // Funds distributed to team
    final distributedFunds = fundState.funds.where((f) => f.fromUserId == currentUser?.id).toList();

    // Filtered users for allocation (only my team members)
    final myTeam = userState.users.where((u) => u.managerId == currentUser?.id).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppLoader(
        isLoading: false, // Use skeletons instead of full-screen loader
        child: DefaultTabController(
          length: 3,
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
                  color: theme.primaryColor.withOpacity(0.1),
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
                      children: const [
                        Icon(Icons.call_received_rounded, size: 18),
                        SizedBox(width: 8),
                        Text("RECEIVED"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.call_made_rounded, size: 18),
                        SizedBox(width: 8),
                        Text("ALLOCATION"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.trending_up_rounded, size: 18),
                        SizedBox(width: 8),
                        Text("EXPANSION"),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Received from CEO
                    PremiumTable<FundModel>(
                      isLoading: fundState.isLoading,
                      data: receivedFunds,
                      columns: [
                        TableColumn<FundModel>(label: "ID", key: "id"),
                        TableColumn<FundModel>(label: "Date", key: "createdAt", builder: (context, item) => Text(DateFormat('dd-MM-yyyy').format(item.createdAt.toLocal()))),
                        TableColumn<FundModel>(label: "Allocated By", key: "fromUserName"),
                        TableColumn<FundModel>(label: "Amount", key: "amount", isCurrency: true),
                        TableColumn<FundModel>(label: "Status", key: "status", isStatus: true),
                      ],
                      searchFields: const ["id", "fromUserName", "amount", "status"],
                      customRowActions: (fund) {
                        return [
                          IconButton(
                            icon: Icon(Icons.visibility_rounded, color: theme.colorScheme.secondary),
                            tooltip: "View Dossier",
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FundDetailsScreen(fund: fund)),
                            ),
                          ),
                          if (fund.status == 'ALLOCATED')
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981)),
                              tooltip: "Confirm Receipt",
                              onPressed: () async {
                                await ref.read(fundProvider.notifier).confirmReceipt(fund.id);
                                if (mounted) {
                                  ref.read(toastProvider.notifier).show(message: "Receipt confirmed", type: ToastType.success);
                                }
                              },
                            ),
                          if (fund.status == 'RECEIVED')
                            PremiumExportButton(
                              type: ExportType.pdf,
                              isIconOnly: true,
                              tooltip: "Download Statement",
                              onPressed: () => ref.read(fundProvider.notifier).downloadFundStatement(fund.id),
                            ),
                          if (fund.status == 'RECEIVED') (() {
                            bool isAllocated = false;
                            final match = RegExp(r'(?:\(ID:\s*|Expense\s*#)(\d+)').firstMatch(fund.description ?? '');
                            if (match != null) {
                              final expenseId = int.tryParse(match.group(1)!);
                              if (expenseId != null) {
                                final matches = expenseState.expenses.where((e) => e.id == expenseId).toList();
                                if (matches.isNotEmpty) {
                                  final expense = matches.first;
                                  if (expense.status == 'FUND_ALLOCATED' || expense.status == 'COMPLETED') {
                                    isAllocated = true;
                                  }
                                }
                              }
                            }
                            if (isAllocated) return const SizedBox.shrink();
                            
                            return IconButton(
                              icon: Icon(Icons.reply_all_rounded, color: theme.colorScheme.secondary),
                              tooltip: "Distribute to Team",
                              onPressed: () {
                                _showDistributionFlow(context, ref, fund, myTeam);
                              },
                            );
                          })(),
                          if (fund.status.toUpperCase() == 'PENDING')
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                              tooltip: "Cancel Request",
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    final theme = Theme.of(context);
                                    return AlertDialog(
                                      title: const Text("Cancel Fund Request"),
                                      content: const Text("Are you sure you want to cancel this allocation request?"),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("NO")),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: theme.colorScheme.error,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text("YES, CANCEL", style: TextStyle(fontWeight: FontWeight.w900)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirmed == true) {
                                  final success = await ref.read(fundProvider.notifier).deleteFund(fund.id);
                                  if (success && mounted) {
                                    ref.read(toastProvider.notifier).show(message: "Request cancelled", type: ToastType.success);
                                  }
                                }
                              },
                            ),
                        ];
                      },
                      onExportPdf: (data) {
                        ReportGenerator.generateDetailedReportPDF(
                          title: "Received Funds History",
                          headers: ["Date", "From", "Amount", "Status"],
                          data: data.map((f) => [
                            DateFormat('dd-MM-yyyy').format(f.createdAt.toLocal()),
                            f.fromUserName,
                            ReportGenerator.formatCurrency(f.amount.toDouble()),
                            f.status
                          ]).toList(),
                          summaries: {
                            "Total Allocated": ReportGenerator.formatCurrency(data.where((f) => ['ALLOCATED', 'RECEIVED', 'COMPLETED'].contains(f.status.toUpperCase())).fold(0.0, (sum, f) => sum + f.amount)),
                            "Net Amount": ReportGenerator.formatCurrency(data.fold(0.0, (sum, f) => sum + f.amount)),
                          },
                        );
                      },
                      onExportExcel: (data) {
                        final columns = ["Date", "From", "Amount", "Status"];
                        final rows = data.map((f) => [
                          DateFormat('dd-MM-yyyy').format(f.createdAt.toLocal()),
                          f.fromUserName,
                          f.amount.toDouble(),
                          f.status
                        ]).toList();
                        ReportGenerator.generateExcel(title: "Received_Funds_History", headers: columns, data: rows);
                      },
                    ),
                    
                    // Distributed to Team
                    PremiumTable<FundModel>(
                      isLoading: fundState.isLoading,
                      data: distributedFunds,
                      columns: [
                        TableColumn<FundModel>(label: "ID", key: "id"),
                        TableColumn<FundModel>(label: "Date", key: "createdAt", builder: (context, item) => Text(DateFormat('dd-MM-yyyy').format(item.createdAt.toLocal()))),
                        TableColumn<FundModel>(label: "To", key: "toUserName"),
                        TableColumn<FundModel>(label: "Mode", key: "paymentMode"),
                        TableColumn<FundModel>(label: "Reference/Description", key: "description", builder: (context, item) => Text(item.description ?? "-", maxLines: 1, overflow: TextOverflow.ellipsis)),
                        TableColumn<FundModel>(label: "Amount", key: "amount", isCurrency: true),
                        TableColumn<FundModel>(label: "Status", key: "status", isStatus: true),
                      ],
                      searchFields: const ["id", "toUserName", "amount", "status", "paymentMode", "description"],
                      onExportPdf: (data) {
                        ReportGenerator.generateDetailedReportPDF(
                          title: "Distributed Funds History",
                          headers: ["Date", "To", "Mode", "Reference", "Amount", "Status"],
                          data: data.map((f) => [
                            DateFormat('dd-MM-yyyy').format(f.createdAt.toLocal()),
                            f.toUserName,
                            f.paymentMode,
                            f.description ?? "-",
                            ReportGenerator.formatCurrency(f.amount.toDouble()),
                            f.status
                          ]).toList(),
                          summaries: {
                            "Total Distributed": ReportGenerator.formatCurrency(data.where((f) => !['REJECTED', 'PENDING'].contains(f.status.toUpperCase())).fold(0.0, (sum, f) => sum + f.amount)),
                            "Net Amount": ReportGenerator.formatCurrency(data.fold(0.0, (sum, f) => sum + f.amount)),
                          },
                        );
                      },
                      onExportExcel: (data) {
                        final columns = ["Date", "To", "Mode", "Reference", "Amount", "Status"];
                        final rows = data.map((f) => [
                          DateFormat('dd-MM-yyyy').format(f.createdAt.toLocal()),
                          f.toUserName,
                          f.paymentMode,
                          f.description ?? "-",
                          f.amount.toDouble(),
                          f.status
                        ]).toList();
                        ReportGenerator.generateExcel(title: "Distributed_Funds_History", headers: columns, data: rows);
                      },
                      customRowActions: (fund) {
                        return [
                          IconButton(
                            icon: const Icon(Icons.visibility_rounded, color: Colors.blue),
                            tooltip: "View Dossier",
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FundDetailsScreen(fund: fund)),
                            ),
                          ),
                          if (fund.status.toUpperCase() == 'ALLOCATED' || fund.status.toUpperCase() == 'PENDING' || fund.status.toUpperCase() == 'APPROVED') ...[
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, color: Color(0xFFF59E0B)),
                              tooltip: "Edit Allocation",
                              onPressed: () => _handleEditDistribution(fund, myTeam),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                              tooltip: "Delete Allocation",
                              onPressed: () => _handleDeleteDistribution(fund.id),
                            ),
                          ],
                          PremiumExportButton(
                            type: ExportType.pdf,
                            isIconOnly: true,
                            tooltip: "Download Statement",
                            onPressed: () => ref.read(fundProvider.notifier).downloadFundStatement(fund.id),
                          ),
                        ];
                      },
                    ),

                    // Expansion History
                    _buildExpansionHistoryTab(currentUser, theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionHistoryTab(dynamic currentUser, ThemeData theme) {
    final expansionState = ref.watch(expansionProvider);
    final myExpansions = expansionState.expansions
        .where((e) => e.managerId == currentUser?.id)
        .toList();

    return PremiumTable<ExpansionModel>(
      isLoading: expansionState.isLoading,
      data: myExpansions,
      columns: [
        TableColumn<ExpansionModel>(label: "ID", key: "id"),
        TableColumn<ExpansionModel>(
          label: "Date",
          key: "requestedAt",
          builder: (context, item) => Text(DateFormat('dd-MM-yyyy').format(item.requestedAt.toLocal())),
        ),
        TableColumn<ExpansionModel>(label: "Requested", key: "requestedAmount", isCurrency: true),
        TableColumn<ExpansionModel>(
          label: "Approved",
          key: "approvedAmount",
          builder: (context, item) => Text(
            item.approvedAmount != null && item.approvedAmount! > 0
                ? ref.read(settingsProvider.notifier).formatCurrency(item.approvedAmount!.toDouble())
                : '-',
          ),
        ),
        TableColumn<ExpansionModel>(
          label: "Justification",
          key: "justification",
          builder: (context, item) => Text(
            item.justification,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableColumn<ExpansionModel>(label: "Status", key: "status", isStatus: true),
      ],
      searchFields: const ["id", "requestedAmount", "justification", "status"],
      customRowActions: (expansion) {
        final canModify = expansion.status.toUpperCase() == 'PENDING' || expansion.status.toUpperCase() == 'REJECTED';
        return [
          IconButton(
            icon: Icon(Icons.visibility_rounded, color: theme.colorScheme.secondary),
            tooltip: "View Details",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ExpansionDetailsScreen(expansion: expansion)),
            ),
          ),
          PremiumExportButton(
            type: ExportType.pdf,
            isIconOnly: true,
            tooltip: "Download Statement",
            onPressed: () => ref.read(expansionProvider.notifier).downloadExpansionStatement(expansion.id),
          ),
          if (canModify) ...[
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Color(0xFFF59E0B)),
              tooltip: "Edit Request",
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RequestExpansionScreen(expansion: expansion)),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
              tooltip: "Delete Request",
              onPressed: () => _handleDeleteExpansion(expansion.id),
            ),
          ],
        ];
      },
      onExportPdf: (List<ExpansionModel> data) {
        ReportGenerator.generateDetailedReportPDF(
          title: "Expansion History",
          headers: ["Date", "Requested Amount", "Approved Amount", "Justification", "Status"],
          data: data.map((e) => [
            DateFormat('dd-MM-yyyy').format(e.requestedAt.toLocal()),
            ReportGenerator.formatCurrency(e.requestedAmount.toDouble()),
            e.approvedAmount != null && e.approvedAmount! > 0 ? ReportGenerator.formatCurrency(e.approvedAmount!.toDouble()) : '-',
            e.justification,
            e.status,
          ]).toList(),
          summaries: {
            "Total Approved": ReportGenerator.formatCurrency(data.where((e) => e.status.toUpperCase() == 'APPROVED').fold(0.0, (sum, e) => sum + (e.approvedAmount ?? 0))),
            "Total Requested": ReportGenerator.formatCurrency(data.fold(0.0, (sum, e) => sum + e.requestedAmount)),
          },
        );
      },
      onExportExcel: (List<ExpansionModel> data) {
        final headers = ["Date", "Requested Amount", "Approved Amount", "Justification", "Status"];
        final rows = data.map((e) => [
          DateFormat('dd-MM-yyyy').format(e.requestedAt.toLocal()),
          e.requestedAmount.toDouble(),
          e.approvedAmount?.toDouble() ?? '-',
          e.justification,
          e.status,
        ]).toList();
        ReportGenerator.generateExcel(title: "Expansion_History", headers: headers, data: rows);
      },
    );
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
      final success = await ref.read(expansionProvider.notifier).deleteExpansion(id);
      if (success && mounted) {
        ref.read(toastProvider.notifier).show(
          message: "Expansion request deleted",
          type: ToastType.warning,
        );
      }
    }
  }

  void _showDistributionFlow(BuildContext context, WidgetRef ref, dynamic fund, List<dynamic> team) {
    // Extract Expense ID from description if it exists
    final match = RegExp(r'(?:\(ID:\s*|Expense\s*#)(\d+)').firstMatch(fund.description ?? '');
    final expenseIdStr = match?.group(1);
    
    int? targetUserId;
    if (expenseIdStr != null) {
      final expenseId = int.tryParse(expenseIdStr);
      if (expenseId != null) {
        final expenseState = ref.read(expenseProvider);
        final matches = expenseState.expenses.where((e) => e.id == expenseId).toList();
        if (matches.isNotEmpty) {
          targetUserId = matches.first.userId;
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => AllocationForm(
          managers: team.cast<UserModel>(),
          initialData: {
            'to_user_id': targetUserId,
            'amount': fund.amount,
            'description': fund.description ?? "Distribution from received fund ID: ${fund.id}",
            'expense_id': expenseIdStr,
            'payment_mode': fund.paymentMode ?? 'CASH',
            'cheque_number': fund.chequeNumber ?? '',
            'bank_name': fund.bankName ?? '',
            'cheque_date': fund.chequeDate?.toIso8601String().split('T')[0] ?? '',
            'account_holder_name': fund.accountHolderName ?? '',
            'cheque_image_path': fund.chequeImagePath,
            'upi_id': fund.upiId ?? '',
            'transaction_id': fund.transactionId ?? '',
          },
          onCancel: () => Navigator.pop(context),
          onSubmit: (data, path) {
            _handleAllocation(data, path);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _handleEditDistribution(FundModel fund, List<UserModel> team) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => AllocationForm(
          managers: team,
          initialData: {
            'to_user_id': fund.toUserId,
            'amount': fund.amount,
            'description': fund.description,
            'payment_mode': fund.paymentMode,
            'cheque_number': fund.chequeNumber ?? '',
            'bank_name': fund.bankName ?? '',
            'cheque_date': fund.chequeDate?.toIso8601String().split('T')[0] ?? '',
            'account_holder_name': fund.accountHolderName ?? '',
            'cheque_image_path': fund.chequeImagePath,
            'upi_id': fund.upiId ?? '',
            'transaction_id': fund.transactionId ?? '',
          },
          onCancel: () => Navigator.pop(context),
          onSubmit: (data, path) async {
            final success = await ref.read(fundProvider.notifier).updateFund(fund.id, data);
            if (success) {
              if (!context.mounted) return;
              Navigator.pop(context);
              ref.read(toastProvider.notifier).show(message: "Allocation updated", type: ToastType.success);
            }
          },
        ),
      ),
    );
  }

  void _handleDeleteDistribution(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Allocation"),
        content: const Text("Are you sure you want to delete this allocation? This record will be permanently removed."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("DELETE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(fundProvider.notifier).deleteFund(id);
      if (success && mounted) {
        ref.read(toastProvider.notifier).show(message: "Allocation deleted", type: ToastType.warning);
      }
    }
  }
}

