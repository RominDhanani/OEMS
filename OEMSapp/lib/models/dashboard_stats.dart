class DashboardStats {
  final List<dynamic>? ownExpenses;
  final List<dynamic>? teamExpenses;
  final List<dynamic>? expenses;
  final List<dynamic>? allocatedFunds;
  final List<dynamic>? receivedFunds;
  final int? pendingApprovals;
  final int? pendingUsers;
  final List<dynamic>? expansionFunds;
  final int? pendingExpansionRequests;

  DashboardStats({
    this.ownExpenses,
    this.teamExpenses,
    this.expenses,
    this.allocatedFunds,
    this.receivedFunds,
    this.pendingApprovals,
    this.pendingUsers,
    this.expansionFunds,
    this.pendingExpansionRequests,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      ownExpenses: json['ownExpenses'],
      teamExpenses: json['teamExpenses'],
      expenses: json['expenses'],
      allocatedFunds: json['allocatedFunds'],
      receivedFunds: json['receivedFunds'],
      pendingApprovals: json['pendingApprovals'],
      pendingUsers: json['pendingUsers'],
      expansionFunds: json['expansionFunds'],
      pendingExpansionRequests: json['pendingExpansionRequests'],
    );
  }
}
