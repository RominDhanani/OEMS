import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';
import '../../models/fund_model.dart';
import '../../models/expansion_model.dart';
import '../status_badge.dart';

class PremiumReportCard extends StatelessWidget {
  final dynamic item;
  final String formattedAmount;
  final VoidCallback onTap;

  const PremiumReportCard({
    super.key,
    required this.item,
    required this.formattedAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String title = "";
    String subtitle = "";
    String status = "";
    IconData icon = Icons.receipt_long_rounded;

    if (item is ExpenseModel) {
      title = "#${item.id} - ${item.title}";
      subtitle = "${item.category} • ${DateFormat('dd-MM-yyyy').format(item.expenseDate.toLocal())}";
      status = item.status;
      icon = _getExpenseIcon(item.category);
    } else if (item is FundModel) {
      title = "#${item.id} - Fund: ${item.toUserName}";
      subtitle = "From ${item.fromUserName} • ${item.paymentMode}";
      status = item.status;
      icon = Icons.account_balance_wallet_rounded;
    } else if (item is ExpansionModel) {
      title = "#${item.id} - Expansion: ${item.managerName}";
      subtitle = item.justification;
      status = item.status;
      icon = Icons.trending_up_rounded;
    } else if (item is Map) {
      // Category report mode
      title = item['category'];
      subtitle = "${item['count']} Records";
      status = "COMPLETED";
      icon = _getExpenseIcon(item['category']);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.06)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: theme.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedAmount,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        color: _getAmountColor(item, theme),
                        fontSize: 18,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    StatusBadge(status: status),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getAmountColor(dynamic item, ThemeData theme) {
    if (item is FundModel) return const Color(0xFF10B981); // Success Green
    return theme.colorScheme.onSurface;
  }

  IconData _getExpenseIcon(String category) {
    category = category.toUpperCase();
    if (category.contains('TRAVEL')) return Icons.flight_takeoff_rounded;
    if (category.contains('FOOD')) return Icons.restaurant_rounded;
    if (category.contains('OFFICE')) return Icons.business_center_rounded;
    if (category.contains('ELECTRONICS')) return Icons.devices_rounded;
    if (category.contains('SOFTWARE')) return Icons.code_rounded;
    return Icons.receipt_long_rounded;
  }
}
