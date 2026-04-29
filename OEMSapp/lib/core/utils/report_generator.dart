import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ReportGenerator {
  static const PdfColor primaryBlue = PdfColor.fromInt(0xFF1E3A8A); // Match BRAND_COLOR
  static const PdfColor emeraldGreen = PdfColor.fromInt(0xFF059669); // Match Fund Color
  static const PdfColor amberOrange = PdfColor.fromInt(0xFFD97706); // Match Expansion Color
  static const PdfColor accentColor = PdfColor.fromInt(0xFFEAB308); // Gold/Amber
  static const PdfColor textDark = PdfColor.fromInt(0xFF1F2937); // Gray 800
  static const PdfColor textMuted = PdfColor.fromInt(0xFF6B7280); // Gray 500
  static const PdfColor bgLight = PdfColor.fromInt(0xFFF9FAFB); // Gray 50

  static String _pdfCurrencySymbol = 'Rs.';
  static String _pdfLocale = 'en_IN';
  static double _pdfConversionRate = 1.0;

  static void updatePdfConfig({required String symbol, required String locale, double rate = 1.0}) {
    _pdfCurrencySymbol = symbol == '₹' ? 'Rs.' : symbol;
    _pdfLocale = locale;
    _pdfConversionRate = rate;
  }

  static String formatCurrency(double amount, {String? symbol}) {
    String effectiveSymbol = symbol != null ? (symbol == '₹' ? 'Rs.' : symbol) : _pdfCurrencySymbol;
    double effectiveRate = symbol != null ? 1.0 : _pdfConversionRate;
    
    return NumberFormat.currency(
      symbol: "$effectiveSymbol ", 
      locale: _pdfLocale, 
      decimalDigits: 2
    ).format(amount * effectiveRate);
  }

  static pw.Widget _buildBriefcaseLogo() {
    return pw.Container(
      width: 40,
      height: 40,
      child: pw.Stack(
        alignment: pw.Alignment.center,
        children: [
          // Outer Blue Circle for Premium Feel
          pw.Container(
            width: 40,
            height: 40,
            decoration: pw.BoxDecoration(
              color: primaryBlue,
              shape: pw.BoxShape.circle,
            ),
          ),
          // Inner Briefcase Icon
          pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              // Handle
              pw.Container(
                width: 10,
                height: 5,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.white, width: 1.5),
                  borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(3),
                    topRight: pw.Radius.circular(3),
                  ),
                ),
              ),
              // Body
              pw.Container(
                width: 20,
                height: 14,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
                child: pw.Center(
                  child: pw.Container(
                    width: 20,
                    height: 1.5,
                    color: primaryBlue, // Latch line
                  ),
                ),
              ),
            ],
          ),
          // Accent Dot
          pw.Positioned(
            right: 8,
            bottom: 8,
            child: pw.Container(
              width: 6,
              height: 6,
              decoration: const pw.BoxDecoration(
                color: accentColor,
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStatusBadge(String status) {
    PdfColor bgColor = PdfColors.grey500;
    String text = status.toUpperCase();

    if (['APPROVED', 'COMPLETED', 'RECEIVED', 'ALLOCATED', 'ACTIVE', 'ASSIGNED'].contains(text)) {
      bgColor = const PdfColor.fromInt(0xFF16A34A); // Green 600
    } else if (['REJECTED', 'DEACTIVATED'].contains(text)) {
      bgColor = const PdfColor.fromInt(0xFFDC2626); // Red 600
    } else if (['PENDING', 'PENDING_APPROVAL', 'CREATED'].contains(text)) {
      bgColor = const PdfColor.fromInt(0xFFD97706); // Amber 600
    }

    return pw.Container(
      width: 65,
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(2),
      ),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 6,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildHeader(String title, String docId, String date, {String? status}) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                _buildBriefcaseLogo(),
                pw.SizedBox(width: 10),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      "OFFICE EXPENSE",
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    pw.Text(
                      "MANAGEMENT",
                      style: pw.TextStyle(
                        fontSize: 6.5,
                        letterSpacing: 2,
                        fontWeight: pw.FontWeight.bold,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  title.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: textDark,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text("ID: $docId", style: const pw.TextStyle(fontSize: 8, color: textMuted)),
                pw.Text("Date: $date", style: const pw.TextStyle(fontSize: 8, color: textMuted)),
                if (status != null) ...[
                  pw.SizedBox(height: 5),
                  _buildStatusBadge(status),
                ],
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          height: 1.5,
          color: primaryBlue,
        ),
        pw.SizedBox(height: 15),
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text("$label: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Text(value.replaceAll('₹', 'Rs. '), style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(List<String> headers, List<List<String>> data) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data.map((row) => row.map((cell) => cell.replaceAll('₹', 'Rs. ')).toList()).toList(),
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: primaryBlue),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
      },
      cellStyle: const pw.TextStyle(fontSize: 10),
      oddRowDecoration: const pw.BoxDecoration(color: bgLight),
    );
  }

  static pw.Widget _buildTotals(Map<String, String> summaries) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      padding: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          ...summaries.entries.map((e) {
            final isNet = e.key.toUpperCase().contains('NET');
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    "${e.key}: ",
                    style: pw.TextStyle(
                      fontSize: isNet ? 14 : 10, 
                      fontWeight: isNet ? pw.FontWeight.bold : pw.FontWeight.normal,
                      color: isNet ? primaryBlue : textDark,
                    ),
                  ),
                  pw.Text(
                    e.value.replaceAll('₹', 'Rs. '),
                    style: pw.TextStyle(
                      fontSize: isNet ? 14 : 10, 
                      fontWeight: pw.FontWeight.bold,
                      color: isNet ? primaryBlue : textDark,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        children: [
          pw.Divider(color: PdfColor.fromInt(0xFFE2E8F0)), // Light Grayish Blue
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 5),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Generated by Office Expense Management System",
                  style: const pw.TextStyle(color: textMuted, fontSize: 8),
                ),
                pw.Text(
                  "Page ${context.pageNumber} of ${context.pagesCount}",
                  style: const pw.TextStyle(color: textMuted, fontSize: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> saveAndShare(String fileName, List<int> bytes, {String mimeType = 'application/pdf'}) async {
    if (kIsWeb) {
      // Use XFile.fromData for Web to bypass path_provider entirely
      await Share.shareXFiles([
        XFile.fromData(
          Uint8List.fromList(bytes),
          name: fileName,
          mimeType: mimeType,
        )
      ]);
    } else {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path, mimeType: mimeType)]);
    }
  }

  static Future<void> downloadAndShareFile(String url, String fileName) async {
    try {
      final HttpClient httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      final bytes = await response.fold<List<int>>([], (p, e) => p..addAll(e));
      
      await saveAndShare(fileName, bytes, mimeType: 'application/octet-stream');
    } catch (e) {
      throw Exception("Failed to download or share file: $e");
    }
  }

  static Future<void> generateExpensePDF(dynamic expense, {String? currencySymbol}) async {
    final pdf = pw.Document();
    final docId = "EXP-${expense.id.toString().padLeft(4, '0')}";
    final date = expense.expenseDate != null ? DateFormat('dd-MM-yyyy').format(expense.expenseDate) : "N/A";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader("Expense Voucher", docId, date, status: expense.status),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInvoiceInfo("Category", expense.category),
                      _buildInvoiceInfo("Department", expense.department ?? '-'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _buildInvoiceInfo("Submitted By", expense.userName),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Text("Description:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              pw.SizedBox(height: 10),
              pw.Text((expense.description ?? "No description provided").replaceAll('₹', 'Rs. '), style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 30),
              _buildTotal("Total Amount", formatCurrency(expense.amount.toDouble(), symbol: currencySymbol)),
              pw.Spacer(),
              _buildFooter(context),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await saveAndShare("$docId.pdf", bytes);
  }

  static Future<void> generateFundPDF(dynamic fund, {String? currencySymbol}) async {
    final pdf = pw.Document();
    final docId = "TRX-${fund.id.toString().padLeft(4, '0')}";
    final date = fund.createdAt != null ? DateFormat('dd-MM-yyyy').format(fund.createdAt) : "N/A";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader("Fund Statement", docId, date, status: fund.status),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInvoiceInfo("Mode", fund.paymentMode ?? 'CASH'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _buildInvoiceInfo("Type", fund.toUserId != null ? 'Allocation' : 'Return'),
                      _buildInvoiceInfo("From", fund.fromUserName ?? fund.managerUserName ?? fund.fromUserId.toString()),
                      _buildInvoiceInfo("To", fund.toUserName ?? fund.toUserId?.toString() ?? '-'),
                    ],
                  ),
                ],
              ),
              if (fund.paymentMode == 'CHEQUE') ...[
                pw.SizedBox(height: 10),
                pw.Text("Cheque Details:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                _buildInvoiceInfo("Bank", fund.bankName ?? '-'),
                _buildInvoiceInfo("No", fund.chequeNumber ?? '-'),
                _buildInvoiceInfo("Date", fund.chequeDate != null ? DateFormat('dd-MM-yyyy').format(fund.chequeDate) : '-'),
              ],
              if (fund.paymentMode == 'UPI') ...[
                pw.SizedBox(height: 10),
                pw.Text("UPI Details:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                _buildInvoiceInfo("ID", fund.upiId ?? '-'),
                _buildInvoiceInfo("Txn ID", fund.transactionId ?? '-'),
              ],
              pw.SizedBox(height: 30),
              if (fund.description != null && fund.description!.isNotEmpty) ...[
                pw.Text("Description:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.SizedBox(height: 10),
                pw.Text(fund.description!.replaceAll('₹', 'Rs. '), style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 30),
              ],
              _buildTotal("Total Amount", formatCurrency(fund.amount.toDouble(), symbol: currencySymbol)),
              pw.Spacer(),
              _buildFooter(context),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await saveAndShare("$docId.pdf", bytes);
  }

  static Future<void> generateExpansionPDF(dynamic expansion, {String? currencySymbol}) async {
    final pdf = pw.Document();
    final docId = "REQ-${expansion.id.toString().padLeft(4, '0')}";
    final date = expansion.requestedAt != null ? DateFormat('dd-MM-yyyy').format(expansion.requestedAt) : "N/A";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader("Expansion Use", docId, date, status: expansion.status),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInvoiceInfo("Purpose", "Allocation Expansion"),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _buildInvoiceInfo("Requested By", expansion.managerName ?? '-'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              if (expansion.justification != null && expansion.justification!.isNotEmpty) ...[
                pw.Text("Justification:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.SizedBox(height: 10),
                pw.Text(expansion.justification!.replaceAll('₹', 'Rs. '), style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 30),
              ],
              _buildTotal("Requested Amount", formatCurrency(expansion.requestedAmount.toDouble(), symbol: currencySymbol)),
              if (expansion.approvedAmount != null) ...[
                _buildTotal("Approved Amount", formatCurrency(expansion.approvedAmount!.toDouble(), symbol: currencySymbol)),
              ],
              pw.Spacer(),
              _buildFooter(context),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await saveAndShare("$docId.pdf", bytes);
  }

  static Future<void> generateAllocationUsagePDF(List<dynamic> data, {String currencySymbol = '₹'}) async {
    final pdf = pw.Document();
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader("Allocation Usage Report", "RPT-ALLOC", date),
        footer: (context) => _buildFooter(context),
        build: (context) {
          return [
            pw.Text("Executive Summary", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: ['Manager', 'Total Received', 'Own Usage', 'Team Usage', 'Balance'],
              data: data.map((m) {
                double teamUsage = (m['team_usage_breakdown'] ?? []).fold<double>(0, (s, u) => s + (u['used_fund'] ?? 0));
                double teamAllocated = (m['total_allocated_to_team'] ?? 0).toDouble();
                double effectiveDeduction = teamAllocated > teamUsage ? teamAllocated : teamUsage;
                double managerBalance = (m['total_received'] ?? 0) - (m['manager_own_usage'] ?? 0) - effectiveDeduction;

                return [
                  m['manager_name'],
                  formatCurrency((m['total_received'] ?? 0).toDouble(), symbol: currencySymbol),
                  formatCurrency((m['manager_own_usage'] ?? 0).toDouble(), symbol: currencySymbol),
                  formatCurrency(teamUsage, symbol: currencySymbol),
                  formatCurrency(managerBalance, symbol: currencySymbol),
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            ),
            pw.SizedBox(height: 30),
            pw.Text("Detailed Team Breakdown", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 10),
            ...data.map((m) {
              final team = List<dynamic>.from(m['team_usage_breakdown'] ?? []);
              if (team.isEmpty) return pw.SizedBox();
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                   pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 5),
                    child: pw.Text("Manager: ${m['manager_name']}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.blue)),
                  ),
                  pw.TableHelper.fromTextArray(
                    headers: ['User Name', 'Allocated', 'Used', 'Balance'],
                    data: team.map((u) => [
                      u['name'],
                      formatCurrency((u['allocated_fund'] ?? 0).toDouble(), symbol: currencySymbol),
                      formatCurrency((u['used_fund'] ?? 0).toDouble(), symbol: currencySymbol),
                      formatCurrency((u['balance'] ?? 0).toDouble(), symbol: currencySymbol),
                    ]).toList(),
                    cellStyle: const pw.TextStyle(fontSize: 8),
                    headerDecoration: const pw.BoxDecoration(color: PdfColors.cyan100),
                  ),
                  pw.SizedBox(height: 15),
                ],
              );
            }),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await saveAndShare("Allocation_Usage_Report.pdf", bytes);
  }

  static Future<void> generateUserPDF(dynamic user) async {
    final pdf = pw.Document();
    final docId = 'USR-${user['id'].toString().padLeft(4, '0')}';
    final date = user['created_at'] != null
        ? DateFormat('dd-MM-yyyy').format(DateTime.parse(user['created_at'].toString()))
        : DateFormat('dd-MM-yyyy').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader("User Profile", docId, date, status: user['status']),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Attribute', 'Access Details'],
                data: [
                  ['Full Name', user['full_name'] ?? '-'],
                  ['Email', user['email'] ?? '-'],
                  ['Role', user['role'] ?? '-'],
                  ['Mobile', user['mobile_number'] ?? '-'],
                  ['Assigned Manager', user['manager_name'] ?? 'Unassigned'],
                  ['Registered On', date],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
                headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF4F46E5)),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.Spacer(),
              _buildFooter(context),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final userName = (user['full_name'] ?? 'User').toString().replaceAll(' ', '_');
    await saveAndShare("User_$userName.pdf", bytes);
  }

  static Future<void> generateManagerReportPDF(dynamic manager, {String currencySymbol = '₹'}) async {
    final pdf = pw.Document();
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final managerName = manager['manager_name'] ?? 'Unknown';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader("Manager Allocation Report", "MGR-${manager['manager_id']}", date),
        footer: (context) => _buildFooter(context),
        build: (context) {
          final team = List<dynamic>.from(manager['team_usage_breakdown'] ?? []);
          return [
            pw.Text("Manager Overview", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: ['Label', 'Value'],
              data: [
                ['Manager Name', managerName],
                ['Total Allocated', formatCurrency((manager['total_received'] ?? 0).toDouble(), symbol: currencySymbol)],
                ['Own Usage', formatCurrency((manager['manager_own_usage'] ?? 0).toDouble(), symbol: currencySymbol)],
                ['Team Utilization', formatCurrency(
                  (manager['team_usage_breakdown'] as List? ?? []).fold<double>(0, (s, u) => s + (u['used_fund'] ?? 0)),
                  symbol: currencySymbol
                )],
                ['Current Balance', formatCurrency(
                  (manager['total_received'] ?? 0) - (manager['manager_own_usage'] ?? 0) - 
                  (() {
                    double teamUsage = (manager['team_usage_breakdown'] as List? ?? []).fold<double>(0, (s, u) => s + (u['used_fund'] ?? 0));
                    double teamAllocated = (manager['total_allocated_to_team'] ?? 0).toDouble();
                    return teamAllocated > teamUsage ? teamAllocated : teamUsage;
                  })(),
                  symbol: currencySymbol
                )],
              ],
              cellStyle: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 30),
            pw.Text("Team Breakdown (${team.length} Members)", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 10),
            if (team.isEmpty)
              pw.Text("No team members assigned.", style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10))
            else
              pw.TableHelper.fromTextArray(
                headers: ['User Name', 'Allocated', 'Used', 'Balance'],
                data: team.map((u) => [
                  u['name'],
                  formatCurrency((u['allocated_fund'] ?? 0).toDouble(), symbol: currencySymbol),
                  formatCurrency((u['used_fund'] ?? 0).toDouble(), symbol: currencySymbol),
                  formatCurrency((u['balance'] ?? 0).toDouble(), symbol: currencySymbol),
                ]).toList(),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
              ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await saveAndShare("Report_${managerName.replaceAll(' ', '_')}.pdf", bytes);
  }

  static Future<void> generateReportPDF(List<dynamic> items, String title, String totalLabel, String totalValue) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(title, "RPT-GEN", DateFormat('dd-MM-yyyy').format(DateTime.now())),
          _buildTable(
            ['Description', 'Amount'],
            items.map((item) => [
              (item is Map ? (item['description'] ?? item['title'] ?? "N/A") : (item.description ?? item.title ?? "N/A")).toString(),
              formatCurrency((item is Map ? (item['amount'] ?? item['total'] ?? 0) : (item.amount ?? item.total ?? 0)).toDouble())
            ]).toList().cast<List<String>>(),
          ),
          _buildTotal(totalLabel, totalValue),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    final bytes = await pdf.save();
    await saveAndShare("${title.replaceAll(' ', '_')}.pdf", bytes);
  }

  static Future<void> generateDetailedReportPDF({
    required String title,
    required List<String> headers,
    required List<List<String>> data,
    required Map<String, String> summaries,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader(title, "RPT-DET", DateFormat('dd-MM-yyyy').format(DateTime.now())),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: data.map((row) => row.map((cell) => cell.replaceAll('₹', 'Rs. ')).toList()).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8),
            headerDecoration: const pw.BoxDecoration(color: primaryBlue),
            cellStyle: const pw.TextStyle(fontSize: 7),
            cellPadding: const pw.EdgeInsets.all(5),
            oddRowDecoration: const pw.BoxDecoration(color: bgLight),
          ),
          _buildTotals(summaries.map((k, v) => MapEntry(k, v.replaceAll('₹', 'Rs. ')))),
        ],
      ),
    );

    final bytes = await pdf.save();
    await saveAndShare("${title.replaceAll(' ', '_')}.pdf", bytes);
  }

  static Future<void> generateExcel({
    required String title, 
    required List<String> headers, 
    required List<List<dynamic>> data,
    Map<String, String>? summaries,
  }) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Header styling
    CellStyle headerStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#1E3A8A'),
    );

    for (int i = 0; i < headers.length; i++) {
       var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
       cell.value = TextCellValue(headers[i]);
       cell.cellStyle = headerStyle;
    }

    for (int row = 0; row < data.length; row++) {
      for (int col = 0; col < data[row].length; col++) {
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1));
        var value = data[row][col];
        if (value is double || value is int) {
          cell.value = DoubleCellValue(value.toDouble());
        } else if (value is DateTime) {
          cell.value = TextCellValue(DateFormat('dd-MM-yyyy').format(value));
        } else {
          cell.value = TextCellValue(value?.toString() ?? '-');
        }
      }
    }

    if (summaries != null && summaries.isNotEmpty) {
      int summaryStartRow = data.length + 2;
      CellStyle summaryLabelStyle = CellStyle(bold: true);
      CellStyle summaryValueStyle = CellStyle(bold: true, fontColorHex: ExcelColor.fromHexString('#1E3A8A'));

      int i = 0;
      summaries.forEach((label, value) {
        var labelCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: headers.length - 2, rowIndex: summaryStartRow + i));
        labelCell.value = TextCellValue(label);
        labelCell.cellStyle = summaryLabelStyle;

        var valueCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: summaryStartRow + i));
        valueCell.value = TextCellValue(value);
        valueCell.cellStyle = summaryValueStyle;
        i++;
      });
    }

    final bytes = excel.encode();
    if (bytes != null) {
      final fileName = "${title.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx";
      await saveAndShare(fileName, bytes, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    }
  }

  static pw.Widget _buildTotal(String label, String value) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      padding: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text("$label: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: primaryBlue)),
          pw.Text(value.replaceAll('₹', 'Rs. '), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: primaryBlue)),
        ],
      ),
    );
  }
}
