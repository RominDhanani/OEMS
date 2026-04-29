import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/expansion_model.dart';
import '../../models/expense_model.dart';
import '../../providers/auth_provider.dart';
// import '../../providers/expansion_provider.dart';
// import '../../providers/fund_provider.dart';
// import '../../providers/user_provider.dart';
import '../../providers/toast_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/premium/audit_timeline.dart';
import '../../widgets/premium/glass_card.dart';
// import '../../widgets/funds/allocation_form.dart';
// import '../../widgets/premium/modern_action_card.dart';
import '../../widgets/common/erp_toast.dart';
// import '../../core/theme/app_theme.dart';
import '../expenses/expense_details_screen.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/document_list.dart';

class ExpansionDetailsScreen extends ConsumerWidget {
  final ExpansionModel expansion;

  const ExpansionDetailsScreen({super.key, required this.expansion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;
    ref.watch(settingsProvider);
    final settings = ref.read(settingsProvider.notifier);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Expansion Dossier", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          children: [
            // Status & ID Header
            _buildHeader(context),
            const SizedBox(height: 24),
            
            // Main Info Card
            _buildMainInfoCard(context, settings),
            const SizedBox(height: 24),
            
            // Justification Card
            _buildJustificationCard(context),
            const SizedBox(height: 24),

            // Supporting Documents
            if (expansion.documents != null && expansion.documents!.isNotEmpty) ...[
              _buildDocumentsSection(context),
              const SizedBox(height: 24),
            ],

            // Linked Data Discovery
            _buildLinkedArtifacts(context, ref),
            const SizedBox(height: 24),

            // Timeline Section
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  "ACTIVITY TIMELINE",
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            AuditTimeline(
              items: [
                AuditTimelineItem(
                  title: "Expansion Requested",
                  subtitle: "Detailed justification submitted for manager expansion.",
                  timestamp: expansion.requestedAt,
                  icon: Icons.rocket_launch_rounded,
                ),
                if (expansion.status.toUpperCase() != 'PENDING')
                  AuditTimelineItem(
                    title: expansion.status.toUpperCase() == 'REJECTED' ? "Review Rejected" : "Review Approved",
                    subtitle: "Processed by Strategic Review",
                    timestamp: expansion.approvedAt ?? expansion.requestedAt.add(const Duration(hours: 1)),
                    icon: expansion.status.toUpperCase() == 'REJECTED' ? Icons.cancel_outlined : Icons.verified_user_rounded,
                    color: expansion.status.toUpperCase() == 'REJECTED' ? Colors.red : Colors.green,
                  ),
                if (expansion.status == 'ALLOCATED')
                  AuditTimelineItem(
                    title: "Funds Allocated",
                    subtitle: "Operational funds assigned to this expansion.",
                    timestamp: expansion.approvedAt?.add(const Duration(minutes: 30)) ?? DateTime.now(),
                    icon: Icons.payments_rounded,
                    color: Colors.blue,
                    isLast: true,
                  )
                else
                  AuditTimelineItem(
                    title: "Status: ${expansion.status}",
                    subtitle: _getNextStepLabel(expansion.status),
                    timestamp: DateTime.now(),
                    icon: Icons.hourglass_bottom_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    isLast: true,
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Workflow Actions
            _buildWorkflowActions(context, ref, expansion, user),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _getNextStepLabel(String status) {
    switch (status) {
      case 'PENDING':
        return "Awaiting administrative review and strategic approval.";
      case 'APPROVED':
        return "Waiting for fund allocation process.";
      case 'REJECTED':
        return "Expansion request has been denied.";
      default:
        return "Awaiting administrative finalization.";
    }
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "EXPANSION ID",
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.5,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "#EXP-${expansion.id.toString().padLeft(6, '0')}",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        StatusBadge(status: expansion.status),
      ],
    );
  }

  Widget _buildMainInfoCard(BuildContext context, SettingsNotifier settings) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(context, "REQUESTED AMOUNT", settings.formatCurrency(expansion.requestedAmount), isLarge: true, highlight: true),
              _buildInfoItem(context, "DATE", DateFormat('dd-MM-yyyy').format(expansion.requestedAt), isLarge: false),
            ],
          ),
          if (expansion.approvedAmount != null) ...[
            const Divider(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(context, "APPROVED AMOUNT", settings.formatCurrency(expansion.approvedAmount!), isLarge: true, highlight: true, color: const Color(0xFF10B981)),
                _buildInfoItem(context, "APPROVAL DATE", expansion.approvedAt != null ? DateFormat('dd-MM-yyyy').format(expansion.approvedAt!) : "Pending", isLarge: false),
              ],
            ),
          ],
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(context, "MANAGER", expansion.managerName),
              _buildInfoItem(context, "TARGET", "Operational Capacity"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJustificationCard(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "STRATEGIC JUSTIFICATION",
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            expansion.justification,
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
          if (expansion.rejectionReason != null) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
            const Text("REJECTION NOTE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
            const SizedBox(height: 4),
            Text(expansion.rejectionReason!, style: theme.textTheme.bodySmall?.copyWith(color: Colors.redAccent)),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    final theme = Theme.of(context);
    List<ExpenseDocument> allDocs = List.from(expansion.documents ?? []);
    
    if (expansion.chequeImagePath != null) {
      allDocs.add(ExpenseDocument(
        id: 0,
        documentPath: expansion.chequeImagePath!,
        originalFilename: "Allocation Cheque Image",
        fileType: "image/jpeg",
      ));
    }

    if (allDocs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "SUPPORTING DOCUMENTS",
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: DocumentList(documents: allDocs),
        ),
      ],
    );
  }


  Widget _buildInfoItem(BuildContext context, String label, String value, {bool isLarge = false, bool highlight = false, Color? color}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: isLarge ? 20 : 14,
            fontWeight: highlight || isLarge ? FontWeight.w900 : FontWeight.w700,
            color: color ?? (highlight ? theme.colorScheme.secondary : null),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkflowActions(BuildContext context, WidgetRef ref, ExpansionModel expansion, dynamic user) {
    return const SizedBox.shrink();
  }

  Widget _buildLinkedArtifacts(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final match = RegExp(r'(?:\(ID:\s*|Expense\s*#)(\d+)').firstMatch(expansion.justification);
    
    if (match == null) return const SizedBox.shrink();
    
    final expenseId = match.group(1);
    
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "LINKED ARTIFACTS",
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final expenses = ref.read(expenseProvider).expenses;
                final expense = expenses.where((e) => e.id.toString() == expenseId).firstOrNull;
                
                if (expense != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExpenseDetailsScreen(expense: expense)),
                  );
                } else {
                  ref.read(toastProvider.notifier).show(
                    message: "Linked expense #$expenseId not found in local cache.",
                    type: ToastType.info,
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: theme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Source Expense #$expenseId", style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("View the original dossier for this expansion.", style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
