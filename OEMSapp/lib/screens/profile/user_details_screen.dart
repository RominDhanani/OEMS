import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/expense_provider.dart';
import '../../providers/fund_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/user_model.dart';
import '../../models/expense_model.dart';
import '../../models/fund_model.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/premium/animated_stat_card.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../expenses/expense_details_screen.dart';
import '../funds/fund_details_screen.dart';

class UserDetailsScreen extends ConsumerWidget {
  final UserModel user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final expenseState = ref.watch(expenseProvider);
    final fundState = ref.watch(fundProvider);

    // Filter data for this specific user
    final userExpenses = expenseState.expenses.where((e) => e.userId == user.id).toList();
    final userReceivedFunds = fundState.funds.where((f) => f.toUserId == user.id).toList();
    
    final totalSpent = userExpenses
        .where((e) => ['COMPLETED', 'FUND_ALLOCATED', 'RECEIPT_APPROVED'].contains(e.status.toUpperCase()))
        .fold(0.0, (sum, e) => sum + e.amount);
    
    final totalFunds = userReceivedFunds
        .where((f) => ['ALLOCATED', 'RECEIVED', 'COMPLETED'].contains(f.status.toUpperCase()))
        .fold(0.0, (sum, f) => sum + f.amount);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          user.fullName.substring(0, 1).toUpperCase(),
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.fullName,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        user.role,
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel(theme, "Financial Pulse"),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedStatCard(
                          title: "Total Funds",
                          value: settingsNotifier.formatCurrency(totalFunds),
                          icon: Icons.account_balance_wallet_rounded,
                          color: AppTheme.accentIndigo,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AnimatedStatCard(
                          title: "Total Spent",
                          value: settingsNotifier.formatCurrency(totalSpent),
                          icon: Icons.receipt_long_rounded,
                          color: AppTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AnimatedStatCard(
                    title: "Current Balance",
                    value: settingsNotifier.formatCurrency(totalFunds - totalSpent),
                    icon: Icons.money_rounded,
                    color: (totalFunds - totalSpent) >= 0 ? AppTheme.successGreen : Colors.red,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionLabel(theme, "Identity Details"),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.email_outlined, "Email", user.email, theme),
                        const Divider(),
                        _buildDetailRow(Icons.phone_outlined, "Mobile", user.mobileNumber ?? "Not provided", theme),
                        const Divider(),
                        _buildDetailRow(Icons.person_pin_outlined, "Manager", user.managerName ?? "Unassigned", theme),
                        const Divider(),
                        _buildDetailRow(Icons.calendar_today_outlined, "Joined", DateFormat('dd-MM-yyyy').format(user.createdAt.toLocal()), theme),
                        const Divider(),
                        _buildDetailRow(Icons.info_outline, "Status", user.status, theme, isStatus: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionLabel(theme, "Activity Timeline"),
                  const SizedBox(height: 16),
                  _buildActivityList(userExpenses, userReceivedFunds, theme, settingsNotifier),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface.withOpacity(0.5), letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ThemeData theme, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.primaryColor.withOpacity(0.7)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.bold)),
          const Spacer(),
          isStatus ? StatusBadge(status: value) : Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildActivityList(List<ExpenseModel> expenses, List<FundModel> funds, ThemeData theme, SettingsNotifier settings) {
    final allActivity = [...expenses, ...funds];
    allActivity.sort((a, b) {
      final dateA = a is ExpenseModel ? a.expenseDate : (a as FundModel).createdAt;
      final dateB = b is ExpenseModel ? b.expenseDate : (b as FundModel).createdAt;
      return dateB.compareTo(dateA);
    });

    if (allActivity.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text("No activity recorded for this user.", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4))),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allActivity.length,
      itemBuilder: (context, index) {
        final item = allActivity[index];
        final isExpense = item is ExpenseModel;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
          ),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => isExpense 
                    ? ExpenseDetailsScreen(expense: item) 
                    : FundDetailsScreen(fund: item as FundModel)
                ),
              );
            },
            leading: CircleAvatar(
              backgroundColor: (isExpense ? AppTheme.successGreen : AppTheme.accentIndigo).withOpacity(0.1),
              child: Icon(
                isExpense ? Icons.receipt_rounded : Icons.payments_rounded,
                color: isExpense ? AppTheme.successGreen : AppTheme.accentIndigo,
                size: 20,
              ),
            ),
            title: Text(
              isExpense ? item.title : "Fund Allocation",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat('dd-MM-yyyy').format((isExpense ? item.expenseDate : (item as FundModel).createdAt).toLocal()),
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  settings.formatCurrency(isExpense ? item.amount : (item as FundModel).amount),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isExpense ? AppTheme.successGreen : AppTheme.accentIndigo,
                  ),
                ),
                StatusBadge(status: (item as dynamic).status),
              ],
            ),
          ),
        );
      },
    );
  }
}
