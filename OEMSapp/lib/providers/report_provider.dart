import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_stats.dart';
import '../models/expense_model.dart';
import '../models/fund_model.dart';
import '../models/expansion_model.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';

class ReportState {
  final List<dynamic> data;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? totals;
  final DashboardStats? dashboardStats;

  ReportState({
    this.data = const [],
    this.isLoading = false,
    this.error,
    this.totals,
    this.dashboardStats,
  });

  ReportState copyWith({
    List<dynamic>? data,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? totals,
    DashboardStats? dashboardStats,
  }) {
    return ReportState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totals: totals ?? this.totals,
      dashboardStats: dashboardStats ?? this.dashboardStats,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ApiService _apiService;

  ReportNotifier(this._apiService) : super(ReportState());

  Future<void> fetchDashboardStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.get(ApiConstants.dashboardStats);
      if (!mounted) return;
      if (response.data['stats'] != null) {
        final stats = DashboardStats.fromJson(Map<String, dynamic>.from(response.data['stats']));
        state = state.copyWith(dashboardStats: stats, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchExpenseReports({
    String? startDate,
    String? endDate,
    String? category,
    String? department,
    String? status,
    String? scope,
    String? type,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final queryParams = {
        if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
        if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
        if (category != null && category != 'All') 'category': category,
        if (department != null && department != 'All') 'department': department,
        if (status != null && status != 'All') 'status': status,
        if (scope != null && scope != 'All') 'scope': scope.toLowerCase(),
        if (type != null) 'type': type,
      };

      final response = await _apiService.get(ApiConstants.expenseReports, queryParameters: queryParams);
      if (!mounted) return;
      
      if (type == 'category') {
        final List<dynamic> data = response.data['data'] ?? [];
        state = state.copyWith(data: data, isLoading: false);
      } else {
        final List<dynamic> rawData = response.data['data'] ?? [];
        final expenses = rawData.map((e) => ExpenseModel.fromJson(Map<String, dynamic>.from(e))).toList();
        state = state.copyWith(data: expenses, isLoading: false);
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchFundReports({
    String? startDate,
    String? endDate,
    String? status,
    String? scope,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final queryParams = {
        if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
        if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
        if (status != null && status != 'All') 'status': status,
        if (scope != null && scope != 'All') 'scope': scope.toLowerCase(),
      };

      final response = await _apiService.get(ApiConstants.fundReports, queryParameters: queryParams);
      if (!mounted) return;
      final List<dynamic> rawData = response.data['funds'] ?? [];
      final funds = rawData.map((f) => FundModel.fromJson(Map<String, dynamic>.from(f))).toList();
      state = state.copyWith(data: funds, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchExpansionReports({
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final queryParams = {
        if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
        if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
        if (status != null && status != 'All') 'status': status,
      };

      final response = await _apiService.get(ApiConstants.expansionReports, queryParameters: queryParams);
      if (!mounted) return;
      final List<dynamic> rawData = response.data['funds'] ?? [];
      final expansions = rawData.map((e) => ExpansionModel.fromJson(Map<String, dynamic>.from(e))).toList();
      
      // Backend returns totals for expansion reports
      final totals = response.data['totals'];
      
      state = state.copyWith(data: expansions, isLoading: false, totals: totals);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearReports() {
    state = ReportState();
  }

  Future<List<ExpenseModel>> fetchExpensesDirect({
    String? startDate,
    String? endDate,
    String? category,
    String? department,
    String? status,
    String? scope,
  }) async {
    try {
      final queryParams = {
        if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
        if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
        if (category != null && category != 'All') 'category': category,
        if (department != null && department != 'All') 'department': department,
        if (status != null && status != 'All') 'status': status,
        if (scope != null && scope != 'All') 'scope': scope.toLowerCase(),
      };

      final response = await _apiService.get(ApiConstants.expenseReports, queryParameters: queryParams);
      final List<dynamic> rawData = response.data['data'] ?? [];
      return rawData.map((e) => ExpenseModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      return [];
    }
  }
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(ref.watch(apiServiceProvider));
});
