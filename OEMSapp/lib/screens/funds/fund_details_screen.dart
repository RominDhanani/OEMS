import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/fund_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/premium/premium_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/premium/audit_timeline.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fund_provider.dart';
import '../../providers/toast_provider.dart';
import '../../widgets/common/erp_toast.dart';
import '../../widgets/premium/glass_card.dart';
import '../expenses/expense_details_screen.dart';
import '../../core/utils/path_utils.dart';
import '../../core/utils/report_generator.dart';

class FundDetailsScreen extends ConsumerWidget {
  final FundModel fund;

  const FundDetailsScreen({super.key, required this.fund});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    ref.watch(settingsProvider);
    final settings = ref.read(settingsProvider.notifier);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Transaction Dossier", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          children: [
            // Status & ID Header
            _buildHeader(context),
            const SizedBox(height: 24),
            
            // Primary Transaction Card
            _buildMainInfoCard(context, settings),
            const SizedBox(height: 24),
            
            // Payment Mode Specific Details
            if (fund.paymentMode != 'CASH') ...[
              _buildPaymentDetailsCard(context),
              const SizedBox(height: 24),
            ],
            
            // Description Section
            _buildDescriptionCard(context),
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
                  title: "Transaction Initiated",
                  subtitle: "Fund allocation started via ${fund.paymentMode}.",
                  timestamp: fund.createdAt,
                  icon: Icons.send_rounded,
                ),
                if (fund.status != 'ALLOCATED' && fund.status != 'REJECTED')
                  AuditTimelineItem(
                    title: "Funds Processed",
                    subtitle: "Transaction verified and funds dispatched.",
                    timestamp: fund.createdAt.add(const Duration(minutes: 30)),
                    icon: Icons.account_balance_wallet_rounded,
                    color: Colors.green,
                  ),
                if (fund.status == 'RECEIVED' || fund.status == 'COMPLETED')
                  AuditTimelineItem(
                    title: "Receipt Confirmed",
                    subtitle: "Beneficiary confirmed possession of funds.",
                    timestamp: fund.receivedAt ?? fund.createdAt.add(const Duration(hours: 1)),
                    icon: Icons.check_circle_outline_rounded,
                    color: Colors.purple,
                    isLast: true,
                  )
                else
                  AuditTimelineItem(
                    title: "Current Status",
                    subtitle: fund.status == 'ALLOCATED' 
                        ? "Awaiting confirmation from ${fund.toUserName}." 
                        : "Transaction is in state: ${fund.status}",
                    timestamp: DateTime.now(),
                    icon: Icons.hourglass_bottom_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    isLast: true,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Supporting Documents Section
            _buildSupportingDocuments(context),
            const SizedBox(height: 24),
            
            // Confirm Receipt Action for Recipient
            _buildWorkflowActions(context, ref, fund),

            const SizedBox(height: 24),

            // Linked Voucher Section (If applicable)
            _buildLinkedVoucherSection(context, ref),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
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
              "TRANSACTION ID",
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.5,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "#TRX-${fund.id.toString().padLeft(6, '0')}",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        StatusBadge(status: fund.status),
      ],
    );
  }

  Widget _buildMainInfoCard(BuildContext context, SettingsNotifier settings) {
    return PremiumCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(context, "AMOUNT", settings.formatCurrency(fund.amount), isLarge: true, highlight: true),
              _buildInfoItem(context, "DATE", DateFormat('dd-MM-yyyy').format(fund.createdAt.toLocal()), isLarge: false),
            ],
          ),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(context, "FROM", fund.fromUserName),
              _buildInfoItem(context, "TO", fund.toUserName),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(context, "PAYMENT MODE", fund.paymentMode),
              _buildInfoItem(context, "TYPE", fund.expansionId != null ? "Expansion Fund" : "Standard Fund"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard(BuildContext context) {
    final theme = Theme.of(context);
    return PremiumCard(
      color: theme.primaryColor.withOpacity(0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                fund.paymentMode == 'CHEQUE' ? Icons.account_balance_rounded : Icons.payments_outlined,
                size: 20,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                "${fund.paymentMode} DETAILS",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (fund.paymentMode == 'CHEQUE') ...[
            _buildDetailRow(context, "Cheque Number", fund.chequeNumber ?? "N/A"),
            _buildDetailRow(context, "Bank Name", fund.bankName ?? "N/A"),
            _buildDetailRow(context, "Cheque Date", fund.chequeDate != null ? DateFormat('dd-MM-yyyy').format(fund.chequeDate!.toLocal()) : "N/A"),
            _buildDetailRow(context, "A/C Holder", fund.accountHolderName ?? "N/A"),
          ] else if (fund.paymentMode == 'UPI' || fund.paymentMode == 'BANK_TRANSFER') ...[
            _buildDetailRow(context, "Transaction ID", fund.transactionId ?? "N/A"),
            _buildDetailRow(context, "VPA / UPI ID", fund.upiId ?? "N/A"),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
    final theme = Theme.of(context);
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "DESCRIPTION",
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            fund.description ?? "No additional remarks provided for this transaction.",
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
          if (fund.rejectionReason != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            const Text(
              "REJECTION NOTE",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              fund.rejectionReason!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinkedVoucherSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Attempt to extract linked expense ID from description like "Allocation for Expense #32"
    final desc = fund.description ?? "";
    final match = RegExp(r'(?:Expense|ID:?)\s*[#]?\s*(\d+)').firstMatch(desc);
    final expenseId = match?.group(1);

    if (expenseId == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "LINKED VOUCHER",
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        FutureBuilder(
          future: ref.read(expenseProvider.notifier).fetchExpenseById(int.parse(expenseId)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ));
            }
            
            final expense = snapshot.data;
            if (expense == null) return const SizedBox.shrink();

            return PremiumCard(
              padding: EdgeInsets.zero,
              color: theme.primaryColor.withOpacity(0.02),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: Colors.blue),
                ),
                title: Text(
                  expense.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  "EXP-${expense.id.toString().padLeft(4, '0')} • ${expense.category}",
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExpenseDetailsScreen(expense: expense)),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSupportingDocuments(BuildContext context) {
    if (fund.chequeImagePath == null || fund.chequeImagePath!.isEmpty) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final url = PathUtils.normalizeImageUrl(fund.chequeImagePath);
    
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
        PremiumCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_balance_rounded, color: Colors.orange),
            ),
            title: const Text("Cheque Image Scan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text("File: ${fund.chequeImagePath!.split('/').last.split('\\').last}", style: const TextStyle(fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20, color: Colors.blue),
                  onPressed: () => ReportGenerator.downloadAndShareFile(url, "Cheque_Scan.jpg"),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => _showFullDocument(context, url, "Cheque Image Scan"),
          ),
        ),
      ],
    );
  }

  void _showFullDocument(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))],
          ),
          body: Center(child: InteractiveViewer(child: Image.network(url))),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, {bool isLarge = false, bool highlight = false}) {
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
            color: highlight ? theme.colorScheme.secondary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.75), fontSize: 13, fontWeight: FontWeight.w900)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildWorkflowActions(BuildContext context, WidgetRef ref, FundModel fund) {
    final user = ref.read(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    final isRecipient = fund.toUserId == user.id;
    final canConfirm = isRecipient && fund.status.toUpperCase() == 'ALLOCATED';

    if (!canConfirm) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PENDING ACTION", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5, color: const Color(0xFFF59E0B))),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Confirm Receipt"),
                    content: Text("Have you received the funds for Transaction #TRX-${fund.id.toString().padLeft(6, '0')}?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("CONFIRM"),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true) {
                  final success = await ref.read(fundProvider.notifier).confirmReceipt(fund.id);
                  if (success) {
                    ref.read(toastProvider.notifier).show(message: "Receipt confirmed successfully", type: ToastType.success);
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text("CONFIRM RECEIPT OF FUNDS"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

