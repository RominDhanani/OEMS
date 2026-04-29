import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/document_list.dart';
import '../models/expense_model.dart';
import '../models/fund_model.dart';
import '../providers/settings_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/expansion_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/fund_provider.dart';
import '../providers/toast_provider.dart';
import '../widgets/common/erp_toast.dart';
import '../core/utils/report_generator.dart';
import '../widgets/premium/premium_export_button.dart';
import '../services/socket_service.dart';
import 'dart:ui';
import '../models/expansion_model.dart';

enum InvoiceType { expense, fund, expansion }

class InvoiceModal extends ConsumerStatefulWidget {
  final dynamic data;
  final InvoiceType type;
  final VoidCallback? onDownload;

  const InvoiceModal({
    super.key,
    required this.data,
    required this.type,
    this.onDownload,
  });

  @override
  ConsumerState<InvoiceModal> createState() => _InvoiceModalState();
}

class _InvoiceModalState extends ConsumerState<InvoiceModal> {
  int? _linkedExpenseId;
  List<ExpenseDocument> _linkedDocs = [];
  bool _loadingLinked = false;
  dynamic _fullData;
  bool _isLoading = false;
  StreamSubscription? _socketSub;

  @override
  void initState() {
    super.initState();
    _fetchFullDetails();
    _detectAndFetchLinkedDocs();
    _listenToSocket();
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    super.dispose();
  }

  void _listenToSocket() {
    _socketSub = ref.read(socketServiceProvider).eventStream.listen((event) {
      if (!mounted) return;
      
      bool shouldRefresh = false;
      if (widget.type == InvoiceType.expense && event == 'expenseUpdated') {
        shouldRefresh = true;
      } else if (widget.type == InvoiceType.fund && event == 'fundUpdated') {
        shouldRefresh = true;
      } else if (widget.type == InvoiceType.expansion && event == 'expansionUpdated') {
        shouldRefresh = true;
      }

      if (shouldRefresh) {
        _fetchFullDetails();
        _detectAndFetchLinkedDocs();
      }
    });
  }

  Future<void> _fetchFullDetails() async {
    setState(() => _isLoading = true);
    try {
      if (widget.type == InvoiceType.expense) {
        final fullExpense = await ref.read(expenseProvider.notifier).fetchExpenseById(widget.data.id);
        if (fullExpense != null && mounted) {
          setState(() {
            _fullData = fullExpense;
          });
        }
      } else if (widget.type == InvoiceType.expansion) {
        final fullExpansion = await ref.read(expansionProvider.notifier).fetchExpansionById(widget.data.id);
        if (fullExpansion != null && mounted) {
          setState(() {
            _fullData = fullExpansion;
          });
        }
      } else if (widget.type == InvoiceType.fund) {
        final fullFund = await ref.read(fundProvider.notifier).fetchFundById(widget.data.id);
        if (fullFund != null && mounted) {
          setState(() {
            _fullData = fullFund;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching full details: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _detectAndFetchLinkedDocs() async {
    final description = _getDescription();
    if (description == null) return;

    // React-parity regex: catching "(ID: 32)", "Expense #32", "Allocation for Expense 32", etc.
    final regex = RegExp(r'(?:Allocation for Expense|Expense|ID:?)\s*[#]?\s*(\d+)', caseSensitive: false);
    final match = regex.firstMatch(description);
    
    if (match != null) {
      final idStr = match.group(1);
      if (idStr != null) {
        final id = int.tryParse(idStr);
        if (id != null) {
          setState(() {
            _linkedExpenseId = id;
            _loadingLinked = true;
          });
          
          try {
            final docs = await ref.read(expenseProvider.notifier).fetchExpenseDocuments(id);
            if (mounted) {
              setState(() {
                _linkedDocs = docs;
                _loadingLinked = false;
              });
            }
          } catch (e) {
            if (mounted) setState(() => _loadingLinked = false);
          }
        }
      }
    }
  }

  void _handleDeleteDocument(ExpenseDocument doc) async {
    final activeData = _fullData ?? widget.data;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Attachment"),
        content: Text("Are you sure you want to delete '${doc.originalFilename}'?"),
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
      bool success = false;
      if (widget.type == InvoiceType.expense) {
        success = await ref.read(expenseProvider.notifier).deleteDocument(activeData.id, doc.id);
      } 

      if (success) {
        ref.read(toastProvider.notifier).show(message: "Document deleted", type: ToastType.success);
        _fetchFullDetails(); // Refresh
      } else {
        ref.read(toastProvider.notifier).show(message: "Failed to delete document", type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    
    // Config based on type
    final config = _getConfig();
    final String title = config['title'];
    final Color themeColor = config['color'];
    final IconData icon = config['icon'];
    final String idPrefix = config['idPrefix'];

    // Normalize data
    final String? description = _getDescription();
    final String userLabel = config['userLabel'];
    final String userName = _getUserName();
    final DateTime date = _getDate();
    final double amount = _getAmount();

    final activeData = _fullData ?? widget.data;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent, // Required for BackdropFilter to work
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withOpacity(0.85),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                        ),
                        Text(
                          "#$idPrefix${activeData.id.toString().padLeft(4, '0')}",
                          style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withOpacity(0.65), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: _getStatusColor(activeData.status).withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      activeData.status.replaceAll('_', ' '),
                      style: GoogleFonts.outfit(color: _getStatusColor(activeData.status), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loading Full Details Indicator
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),

                    // Rejection Reason
                    if (activeData.status.toUpperCase() == 'REJECTED') _buildRejectionAlert((activeData as dynamic).rejectionReason),

                    // Primary Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(context, userLabel, userName, icon: Icons.person_outline),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(child: _buildDetailRow(context, "Date", DateFormat('dd-MM-yyyy').format(date))),
                              Expanded(
                                child: _buildDetailRow(
                                  context, 
                                  "Total Amount", 
                                  settingsNotifier.formatCurrency(amount),
                                  isBold: true,
                                  color: theme.primaryColor,
                                  align: CrossAxisAlignment.end
                                )
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Specific Details
                    Text("DETAILS", style: _sectionTitleStyle(theme)),
                    const SizedBox(height: 12),
                    _buildSpecificDetails(context, theme, ref),
                    
                    const SizedBox(height: 20),
                    
                    if (description != null && description.isNotEmpty) ...[
                      Text(widget.type == InvoiceType.expansion ? "JUSTIFICATION" : "DESCRIPTION", style: _sectionTitleStyle(theme)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          description,
                          style: GoogleFonts.inter(fontSize: 13, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Attachments
                    Text("ATTACHMENTS", style: _sectionTitleStyle(theme)),
                    const SizedBox(height: 8),
                    _buildAttachments(),

                    // Linked Expense Vouchers (Smart Linking)
                    if (_linkedExpenseId != null) ...[
                      const SizedBox(height: 20),
                      Text("LINKED EXPENSE VOUCHERS (EXP-#${_linkedExpenseId.toString().padLeft(4, '0')})", style: _sectionTitleStyle(theme).copyWith(color: theme.primaryColor)),
                      const SizedBox(height: 8),
                      if (_loadingLinked)
                        const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(strokeWidth: 2)))
                      else if (_linkedDocs.isEmpty)
                        Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text("No vouchers found for linked expense", style: GoogleFonts.inter(fontStyle: FontStyle.italic, fontSize: 12))))
                      else
                        DocumentList(documents: _linkedDocs),
                    ],
                  ],
                ),
              ),
            ),
            
            // Footer Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color?.withOpacity(0.5), // Match header transparency
                border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),
                  if (widget.onDownload != null || (widget.type == InvoiceType.expense || widget.type == InvoiceType.fund || widget.type == InvoiceType.expansion)) ...[
                    const SizedBox(width: 8),
                    if (widget.type == InvoiceType.fund && activeData.status == 'ALLOCATED' && activeData.toUserId == ref.watch(authProvider).user?.id)
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            await ref.read(fundProvider.notifier).confirmReceipt(activeData.id);
                            if (!context.mounted) return; 
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text('Confirm Receipt', overflow: TextOverflow.ellipsis),
                        ),
                      )
                    else
                      Flexible(
                        child: PremiumExportButton(
                          type: widget.type == InvoiceType.expense ? ExportType.pdf : ExportType.standard,
                          customLabel: widget.type == InvoiceType.expense ? 'Detailed PDF' : 'Download',
                          onPressed: () {
                            if (widget.onDownload != null) {
                              widget.onDownload!();
                            } else {
                              final symbol = ref.read(settingsProvider).currencySymbol;
                              if (widget.type == InvoiceType.expense) {
                                ReportGenerator.generateExpensePDF(activeData, currencySymbol: symbol);
                              } else if (widget.type == InvoiceType.fund) {
                                ReportGenerator.generateFundPDF(activeData, currencySymbol: symbol);
                              } else if (widget.type == InvoiceType.expansion) {
                                ReportGenerator.generateExpansionPDF(activeData, currencySymbol: symbol);
                              }
                            }
                            Navigator.pop(context);
                          },
                        ),
                      ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getConfig() {
    switch (widget.type) {
      case InvoiceType.expense:
        return {
          'title': 'Expense Invoice',
          'idPrefix': 'EXP-',
          'color': const Color(0xFF1E3A8A),
          'icon': Icons.description_outlined,
          'userLabel': 'Submitted By',
        };
      case InvoiceType.fund:
        return {
          'title': 'Fund Transaction',
          'idPrefix': 'TRX-',
          'color': const Color(0xFF065F46),
          'icon': Icons.swap_horiz,
          'userLabel': 'Manager',
        };
      case InvoiceType.expansion:
        return {
          'title': 'Expansion Request',
          'idPrefix': 'REQ-',
          'color': const Color(0xFF92400E),
          'icon': Icons.account_balance_wallet_outlined,
          'userLabel': 'Requested By',
        };
    }
  }

  double _getAmount() {
    final data = _fullData ?? widget.data;
    if (widget.type == InvoiceType.expansion) return (data as dynamic).requestedAmount;
    return (data as dynamic).amount;
  }

  DateTime _getDate() {
    final data = _fullData ?? widget.data;
    if (widget.type == InvoiceType.expense) return (data as ExpenseModel).expenseDate;
    if (widget.type == InvoiceType.fund) return (data as FundModel).createdAt;
    return (data as dynamic).requestedAt;
  }

  String _getUserName() {
    final data = _fullData ?? widget.data;
    String name = "User";
    String? role;
    
    if (widget.type == InvoiceType.expense) {
      final exp = data as ExpenseModel;
      name = exp.userName;
      role = exp.userRole;
    } else if (widget.type == InvoiceType.fund) {
      final fund = data as FundModel;
      name = fund.toUserName.isNotEmpty ? fund.toUserName : fund.fromUserName;
    } else if (widget.type == InvoiceType.expansion) {
      final req = data as dynamic;
      name = req.managerName ?? "Manager";
      role = "MANAGER";
    }
    
    return (role != null && role.isNotEmpty) ? "$name ($role)" : name;
  }

  String? _getDescription() {
    final data = _fullData ?? widget.data;
    if (widget.type == InvoiceType.expansion) return (data as dynamic).justification;
    return (data as dynamic).description;
  }

  Widget _buildRejectionAlert(String? reason) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700, size: 16),
              const SizedBox(width: 8),
              Text(
                "REJECTION REASON",
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            reason ?? "No reason provided",
            style: GoogleFonts.inter(fontSize: 13, color: Colors.red.shade900),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {IconData? icon, bool isBold = false, Color? color, CrossAxisAlignment align = CrossAxisAlignment.start}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.outfit(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.65), fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13, 
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  TextStyle _sectionTitleStyle(ThemeData theme) {
    return GoogleFonts.outfit(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface.withOpacity(0.75),
      letterSpacing: 0.5,
    );
  }

  Widget _buildSpecificDetails(BuildContext context, ThemeData theme, WidgetRef ref) {
    final activeData = _fullData ?? widget.data;
    if (widget.type == InvoiceType.expense) {
      final exp = activeData as ExpenseModel;
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDetailRow(context, "Category", exp.category)),
              Expanded(child: _buildDetailRow(context, "Department", exp.department ?? "-", align: CrossAxisAlignment.end)),
            ],
          ),
        ],
      );
    }
    
    if (widget.type == InvoiceType.fund) {
      final fund = activeData as FundModel;
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDetailRow(context, "Payment Mode", fund.paymentMode)),
              if (fund.paymentMode == 'UPI')
                Expanded(child: _buildDetailRow(context, "Transaction ID", fund.transactionId ?? "-", align: CrossAxisAlignment.end)),
              if (fund.paymentMode == 'CHEQUE')
                Expanded(child: _buildDetailRow(context, "Cheque No", fund.chequeNumber ?? "-", align: CrossAxisAlignment.end)),
            ],
          ),
          if (fund.paymentMode == 'CHEQUE') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDetailRow(context, "Bank Name", fund.bankName ?? "-")),
                Expanded(child: _buildDetailRow(context, "Cheque Date", fund.chequeDate != null ? DateFormat('dd-MM-yyyy').format(fund.chequeDate!) : "-", align: CrossAxisAlignment.end)),
              ],
            ),
          ],
          if (fund.paymentMode == 'UPI' && fund.upiId != null && fund.upiId!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailRow(context, "UPI ID", fund.upiId!),
          ],
        ],
      );
    }

    if (widget.type == InvoiceType.expansion) {
      final req = activeData as dynamic;
      return Row(
        children: [
          Expanded(child: _buildDetailRow(context, "Status", req.status)),
          Expanded(child: _buildDetailRow(context, "Approved Amt", req.approvedAmount != null ? ref.read(settingsProvider.notifier).formatCurrency(req.approvedAmount) : "N/A", align: CrossAxisAlignment.end)),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAttachments() {
    final theme = Theme.of(context);
    final activeData = _fullData ?? widget.data;
    List<ExpenseDocument> docs = [];
    if (widget.type == InvoiceType.expense) {
      docs = (activeData as ExpenseModel).documents ?? [];
    } else if (widget.type == InvoiceType.fund) {
      final fund = activeData as FundModel;
      if (fund.chequeImagePath != null) {
        docs.add(ExpenseDocument(
          id: 0,
          documentPath: fund.chequeImagePath!,
          originalFilename: "Cheque Image",
          fileType: "image/jpeg",
        ));
      }
    } else if (widget.type == InvoiceType.expansion) {
      final expansion = activeData as ExpansionModel;
      docs = expansion.documents ?? [];
      if (expansion.chequeImagePath != null) {
        docs.add(ExpenseDocument(
          id: 0,
          documentPath: expansion.chequeImagePath!,
          originalFilename: "Cheque Image",
          fileType: "image/jpeg",
        ));
      }
    }

    
    final currentUser = ref.watch(authProvider).user;
    final isOwner = (widget.type == InvoiceType.expense && activeData is ExpenseModel && activeData.userId == currentUser?.id) ||
                  (widget.type == InvoiceType.expansion && (activeData as dynamic).managerId == currentUser?.id);

    
    // Only allow deletion if status is editable (matching backend)
    final isEditablePath = ['CREATED', 'PENDING', 'PENDING_APPROVAL', 'RECEIPT_APPROVED', 'REJECTED'].contains(activeData.status.toUpperCase());
    final showDelete = isOwner && isEditablePath;

    if (docs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("No attachments found", style: GoogleFonts.inter(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
        ),
      );
    }
    
    return DocumentList(
      documents: docs,
      onDelete: showDelete ? _handleDeleteDocument : null,
    );
  }

  Color _getStatusColor(String status) {
    status = status.toUpperCase();
    if (status.contains('APPROVED') || status == 'COMPLETED' || status == 'ALLOCATED' || status == 'RECEIVED') return Colors.green;
    if (status.contains('PENDING')) return Colors.orange;
    if (status.contains('REJECTED')) return Colors.red;
    return Colors.grey;
  }
}

