import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/expense_model.dart';
import '../../widgets/status_badge.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/toast_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/fund_provider.dart';
import '../../widgets/funds/allocation_form.dart';
import '../../providers/expansion_provider.dart';
import '../funds/request_expansion_screen.dart';
import '../../core/utils/path_utils.dart';
import '../../core/utils/report_generator.dart';
import '../../widgets/premium/modern_action_card.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/common/erp_toast.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/premium/workflow_stepper.dart';
import '../../widgets/premium/audit_timeline.dart';
import '../../screens/expenses/create_expense_screen.dart';

class ExpenseDetailsScreen extends ConsumerWidget {
  final ExpenseModel expense;

  const ExpenseDetailsScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;
    ref.watch(settingsProvider);
    final settings = ref.read(settingsProvider.notifier);
    final isOwner = user?.id == expense.userId;
    final isPending = expense.status == 'PENDING_APPROVAL';

    // React parity: check if an expansion request already exists for this expense
    final expansions = ref.watch(expansionProvider).expansions;
    final hasExpansion = expansions.any((e) {
      final match = RegExp(r'(?:\(ID:\s*|Expense\s*#)(\d+)').firstMatch(e.justification);
      return match != null && match.group(1) == expense.id.toString();
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Expense Dossier", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => ReportGenerator.generateExpensePDF(expense),
            tooltip: "Download PDF",
          ),
          if (isOwner && ['PENDING', 'PENDING_APPROVAL', 'REJECTED'].contains(expense.status.toUpperCase()))
            PopupMenuButton<String>(
              onSelected: (val) async {
                if (val == 'edit') {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CreateExpenseScreen(expense: expense),
                  );
                } else if (val == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete Expense"),
                      content: const Text("Are you sure you want to permanently delete this expense dossier?"),
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
                    final success = await ref.read(expenseProvider.notifier).deleteExpense(expense.id);
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ref.read(toastProvider.notifier).show(message: "Expense deleted", type: ToastType.success);
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_rounded), title: Text("Edit Dossier"))),
                const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline_rounded, color: Colors.red), title: Text("Delete Dossier", style: TextStyle(color: Colors.red)))),
              ],
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            // Premium Invoice Header
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(color: theme.colorScheme.onSurface.withOpacity(0.03), blurRadius: 30, offset: const Offset(0, 15)),
                ],
              ),
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
                            Text(
                              "EXPENSE VOUCHER",
                              style: GoogleFonts.outfit(
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                color: theme.brightness == Brightness.dark ? theme.colorScheme.secondary : theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "#TX-${expense.id.toString().padLeft(6, '0')}",
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: expense.status),
                    ],
                  ),
                  const Divider(height: 32),
                  
                  // Grid Info
                  _buildInvoiceGrid(context, settings),
                  
                  const Divider(height: 32),
                  
                  Text(
                    "DESCRIPTION",
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    expense.description ?? "No specific details provided for this expense document.",
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Visual Workflow
            WorkflowStepper(
              currentStatus: expense.status,
              isRejected: expense.status.toUpperCase() == 'REJECTED',
            ),
            
            const SizedBox(height: 24),
            
            // Rejection Section if exists
            if (expense.status.toUpperCase() == 'REJECTED' && expense.rejectionReason != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withAlpha(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text("REJECTION REASON", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(expense.rejectionReason!, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Timeline Section
            _buildSectionTitle(context, "ACTIVITY TIMELINE"),
            const SizedBox(height: 16),
            AuditTimeline(
              items: [
                AuditTimelineItem(
                  title: "Voucher Submitted",
                  subtitle: "Original expense document uploaded and sent for review.",
                  timestamp: expense.createdAt,
                  icon: Icons.upload_file_rounded,
                ),
                if (expense.status.toUpperCase() != 'PENDING_APPROVAL')
                  AuditTimelineItem(
                    title: expense.status.toUpperCase() == 'REJECTED' ? "Review Rejected" : "Review Approved",
                    subtitle: "Processed by ${expense.approvedByName ?? 'Supervisor'} (${expense.approvedByRole ?? 'Manager'})",
                    timestamp: expense.createdAt.add(const Duration(hours: 2)), // Mocked delay for visualization
                    icon: expense.status == 'REJECTED' ? Icons.cancel_outlined : Icons.verified_user_rounded,
                    color: expense.status == 'REJECTED' ? Colors.red : Colors.green,
                  ),
                if (['FUND_ALLOCATED', 'COMPLETED', 'FUND_CONFIRMED'].contains(expense.status))
                  AuditTimelineItem(
                    title: "Funds Allocated",
                    subtitle: "Operational funds have been assigned to this expense.",
                    timestamp: expense.createdAt.add(const Duration(hours: 4)),
                    icon: Icons.payments_rounded,
                    color: Colors.blue,
                  ),
                if (['COMPLETED', 'FUND_CONFIRMED'].contains(expense.status))
                  AuditTimelineItem(
                    title: "Process Completed",
                    subtitle: "Receipt confirmed and transaction finalized.",
                    timestamp: expense.createdAt.add(const Duration(hours: 5)),
                    icon: Icons.task_alt_rounded,
                    color: Colors.purple,
                    isLast: true,
                  )
                else
                  AuditTimelineItem(
                    title: "Next Step",
                    subtitle: _getNextStepLabel(expense.status),
                    timestamp: DateTime.now(),
                    icon: Icons.hourglass_empty_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    isLast: true,
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Attachments Section
            _buildSectionTitle(context, "SUPPORTING DOCUMENTS"),
            const SizedBox(height: 12),
            if (expense.documents != null && expense.documents!.isNotEmpty)
              ...expense.documents!.map((doc) => _buildDocumentTile(context, doc, ref, isOwner && isPending)),
            
            const SizedBox(height: 24),
            
            // Workflow Action Buttons for CEO/Manager
            _buildWorkflowActions(context, ref, expense, user, hasExpansion),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _getNextStepLabel(String status) {
    switch (status) {
      case 'PENDING_APPROVAL':
        return "Awaiting manager review and initial approval.";
      case 'APPROVED':
      case 'RECEIPT_APPROVED':
        return "Waiting for operational funds to be allocated.";
      case 'FUND_ALLOCATED':
        return "Please confirm receipt of funds once received.";
      default:
        return "Awaiting next administrative action.";
    }
  }

  Widget _buildInvoiceGrid(BuildContext context, SettingsNotifier settings) {
    return Column(
      children: [
        Row(
          children: [
            _buildGridItem(context, "DATE", DateFormat('dd-MM-yyyy').format(expense.expenseDate.toLocal())),
            _buildGridItem(context, "CATEGORY", expense.category),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildGridItem(context, "SUBMITTED BY", expense.userName),
            _buildGridItem(context, "DEPARTMENT", expense.department ?? "N/A"),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildGridItem(context, "TOTAL AMOUNT", settings.formatCurrency(expense.amount), isHighlight: true),
            _buildGridItem(context, "APPROVED BY", expense.approvedByName ?? "Pending Review"),
          ],
        ),
      ],
    );
  }

  Widget _buildGridItem(BuildContext context, String label, String value, {bool isHighlight = false}) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface.withOpacity(0.95), letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              fontSize: isHighlight ? 16 : 13,
              color: isHighlight ? (theme.brightness == Brightness.dark ? theme.colorScheme.secondary : theme.primaryColor) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.bold, 
          fontSize: 12, 
          color: theme.brightness == Brightness.dark ? theme.colorScheme.secondary : theme.primaryColor, 
          letterSpacing: 1.1
        ),
      ),
    );
  }

  Widget _buildDocumentTile(BuildContext context, ExpenseDocument doc, WidgetRef ref, bool canDelete) {
    final theme = Theme.of(context);
    final isPdf = doc.fileType == 'application/pdf' || doc.documentPath.endsWith('.pdf');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isPdf ? Colors.red : Colors.blue).withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(isPdf ? Icons.picture_as_pdf : Icons.image, color: isPdf ? Colors.red : Colors.blue, size: 24),
        ),
        title: Text(doc.originalFilename, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(isPdf ? "PDF Document" : "Image Attachment", style: const TextStyle(fontSize: 11)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canDelete)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                onPressed: () => _handleDelete(context, doc, ref),
                visualDensity: VisualDensity.compact,
              ),
            IconButton(
              icon: const Icon(Icons.share_outlined, size: 20, color: Colors.blue),
              onPressed: () {
                // Fix: Use PathUtils.normalizeImageUrl instead of manual construction
                final url = PathUtils.normalizeImageUrl(doc.documentPath);
                ReportGenerator.downloadAndShareFile(url, doc.originalFilename);
              },
              visualDensity: VisualDensity.compact,
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
        onTap: () => _showDocument(context, doc),
      ),
    );
  }


  Future<void> _handleDelete(BuildContext context, ExpenseDocument doc, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Attachment"),
        content: const Text("This action will permanently delete this supporting document. Continue?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("DELETE", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ref.read(expenseProvider.notifier).deleteDocument(expense.id, doc.id);
      if (success) {
        ref.read(toastProvider.notifier).show(message: "Document removed", type: ToastType.success);
        if (context.mounted) Navigator.pop(context);
      }
    }
  }

  void _showDocument(BuildContext context, ExpenseDocument doc) {
    final url = PathUtils.normalizeImageUrl(doc.documentPath);
    final isPdf = doc.fileType == 'application/pdf' || doc.documentPath.endsWith('.pdf');

    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text(doc.originalFilename),
            actions: [IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))],
          ),
          body: isPdf 
              ? SfPdfViewer.network(url)
              : Center(child: InteractiveViewer(child: Image.network(url))),
        ),
      ),
    );
  }

  Widget _buildWorkflowActions(BuildContext context, WidgetRef ref, ExpenseModel expense, dynamic user, bool hasExpansion) {
    if (user == null) return const SizedBox.shrink();

    final isManager = user.role == 'MANAGER';
    final isTargetManager = expense.managerId == user.id;
    final isOwner = user.id == expense.userId;
    final normalizedStatus = expense.status.toUpperCase();

    // Approvals: Manager approves their team
    final canApprove = (isManager && isTargetManager && (normalizedStatus == 'PENDING_APPROVAL' || normalizedStatus == 'PENDING'));

    // Allocation: Manager can allocate funds for APPROVED expenses
    final canAllocate = isManager && normalizedStatus == 'APPROVED';

    // Expansion Action: For managers viewing approved team expenses (hide for own)
    final canRequestExpansion = !isOwner && !hasExpansion && isManager && (normalizedStatus == 'RECEIPT_APPROVED' || normalizedStatus == 'COMPLETED');

    if (!canApprove && !canAllocate && !canRequestExpansion) return const SizedBox.shrink();

    final actions = <Widget>[];

    // Approval actions
    if (canApprove) {
      actions.add(
        ModernActionCard(
          title: "Reject",
          subtitle: "Decline and request revision",
          icon: Icons.cancel_rounded,
          color: Colors.red,
          onTap: () => _showRejectDialog(context, ref, expense),
        ),
      );
      actions.add(
        ModernActionCard(
          title: "Approve",
          subtitle: "Verify and authorize voucher",
          icon: Icons.check_circle_rounded,
          color: AppTheme.successGreen,
          onTap: () async {
            final success = await ref.read(expenseProvider.notifier).approveExpense(expense.id);
            if (success) {
              ref.read(toastProvider.notifier).show(message: "Expense approved successfully", type: ToastType.success);
              if (context.mounted) Navigator.pop(context);
            }
          },
        ),
      );
    }

    // Allocation actions
    if (canAllocate) {
      actions.add(
        ModernActionCard(
          title: "Allocate Funds",
          subtitle: "Settle this approved expense",
          icon: Icons.payments_rounded,
          color: AppTheme.accentIndigo,
          onTap: () => _showAllocationFlow(context, ref, expense),
        ),
      );
    }

    // Expansion Action
    if (canRequestExpansion) {
      actions.add(
        ModernActionCard(
          title: "Request Expansion",
          subtitle: "Request additional capital",
          icon: Icons.rocket_launch_rounded,
          color: Colors.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestExpansionScreen(
                preFillExpenseId: expense.id.toString(),
                preFillAmount: expense.amount.toString(),
              ),
            ),
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "PENDING ACTION",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...actions,
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, ExpenseModel expense) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Expense Dossier"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(labelText: "Rejection Reason", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final success = await ref.read(expenseProvider.notifier).rejectExpense(expense.id, controller.text);
                if (success) {
                  ref.read(toastProvider.notifier).show(message: "Expense rejected", type: ToastType.warning);
                  if (context.mounted) {
                    Navigator.pop(context); // Pop dialog
                    Navigator.pop(context); // Pop details screen
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("CONFIRM REJECT"),
          ),
        ],
      ),
    );
  }

  void _showAllocationFlow(BuildContext context, WidgetRef ref, ExpenseModel expense) {
    final userState = ref.read(userProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => AllocationForm(
          managers: userState.managers,
          initialData: {
            'to_user_id': expense.userId,
            'amount': expense.amount,
            'description': "Fund for expense: ${expense.title}",
            'expense_id': expense.id,
          },
          onCancel: () => Navigator.pop(context),
          onSubmit: (data, path) async {
            final success = await ref.read(fundProvider.notifier).allocateFund(data, filePath: path);
            if (success) {
              if (!context.mounted) return;
              Navigator.pop(context); // Pop form
              Navigator.pop(context); // Pop details screen
              ref.read(toastProvider.notifier).show(message: "Fund allocated successfully", type: ToastType.success);
            }
          },
        ),
      ),
    );
  }
}

