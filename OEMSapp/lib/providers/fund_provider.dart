import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fund_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/report_generator.dart';
import 'expense_provider.dart';
import 'auth_provider.dart';

final fundProvider = StateNotifierProvider<FundNotifier, FundState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return FundNotifier(apiService, ref);
});

class FundState {
  final List<FundModel> funds;
  final List<UserModel> users;
  final List<dynamic> allocationUsage;
  final bool isLoading;
  final String? error;

  FundState({
    this.funds = const [], 
    this.users = const [], 
    this.allocationUsage = const [],
    this.isLoading = false, 
    this.error
  });

  FundState copyWith({
    List<FundModel>? funds,
    List<UserModel>? users,
    List<dynamic>? allocationUsage,
    bool? isLoading,
    String? error,
  }) {
    return FundState(
      funds: funds ?? this.funds,
      users: users ?? this.users,
      allocationUsage: allocationUsage ?? this.allocationUsage,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class FundNotifier extends StateNotifier<FundState> {
  final ApiService _apiService;
  final Ref _ref;

  FundNotifier(this._apiService, this._ref) : super(FundState());

  Future<void> fetchUsers({String? role}) async {
    final userRole = role ?? _ref.read(authProvider).user?.role;

    // SECURITY GUARD: Regular users are not authorized to call user-listing endpoints.
    // Calling these as a USER triggers a 403, which the ApiService interceptor handles by logging out.
    if (userRole == null || userRole == 'USER') {
      state = state.copyWith(users: [], isLoading: false);
      return;
    }

    try {
      // All non-USER roles now use getTeamUsers since CEO is removed from mobile
      final endpoint = ApiConstants.getTeamUsers;
      final response = await _apiService.get(endpoint);
      if (!mounted) return;
      final List<dynamic> data = response.data['users'];
      final users = data.map((u) => UserModel.fromJson(Map<String, dynamic>.from(u))).toList();
      state = FundState(funds: state.funds, users: users, allocationUsage: state.allocationUsage, isLoading: false);
    } catch (e) {
      if (mounted) {
        state = FundState(error: e.toString(), isLoading: false, funds: state.funds, users: state.users, allocationUsage: state.allocationUsage);
      }
    }
  }

  Future<bool> allocateFund(Map<String, dynamic> data, {String? filePath}) async {
    state = FundState(isLoading: true, funds: state.funds, users: state.users, allocationUsage: state.allocationUsage);
    try {
      if (filePath != null) {
        final formData = FormData.fromMap({
          ...data,
          if (data['expansion_id'] != null) 'expansion_id': data['expansion_id'],
          'cheque_image': await MultipartFile.fromFile(filePath),
        });
        await _apiService.post(ApiConstants.operationalFunds, data: formData);
      } else {
        await _apiService.post(ApiConstants.operationalFunds, data: data);
      }
      if (!mounted) return true;
      await fetchOperationalFunds();
      _ref.read(expenseProvider.notifier).fetchExpenses();
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: e.toString(), isLoading: false);
      }
      return false;
    }
  }

  Future<void> fetchAllocationUsage() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.get(ApiConstants.allocationUsageReport);
      if (!mounted) return;
      if (response.data['report'] != null) {
        final List<dynamic> report = response.data['report'];
        final processedReport = report.map((manager) {
          final balance = double.tryParse(manager['manager_balance']?.toString() ?? '0') ?? 0.0;
          final teamUsage = double.tryParse(manager['calculated_team_usage']?.toString() ?? '0') ?? 0.0;
          return {
            ...manager,
            'manager_balance': balance,
            'calculated_team_usage': teamUsage,
          };
        }).toList();

        state = FundState(allocationUsage: processedReport, isLoading: false, funds: state.funds, users: state.users);
      } else {
        state = FundState(error: "Failed to fetch usage", isLoading: false, funds: state.funds, users: state.users, allocationUsage: state.allocationUsage);
      }
    } catch (e) {
      if (mounted) {
        state = FundState(error: e.toString(), isLoading: false, funds: state.funds, users: state.users, allocationUsage: state.allocationUsage);
      }
    }
  }

  Future<void> fetchOperationalFunds() async {
    state = FundState(isLoading: true, funds: state.funds, users: state.users, allocationUsage: state.allocationUsage);
    try {
      final response = await _apiService.get(ApiConstants.operationalFunds);
      if (!mounted) return;
      final List<dynamic> data = response.data['funds'];
      final funds = data.map((f) => FundModel.fromJson(Map<String, dynamic>.from(f))).toList();
      state = FundState(funds: funds, isLoading: false, users: state.users, allocationUsage: state.allocationUsage);
    } catch (e) {
      if (mounted) {
        state = FundState(error: e.toString(), isLoading: false, funds: state.funds, users: state.users, allocationUsage: state.allocationUsage);
      }
    }
  }

  Future<FundModel?> fetchFundById(int id) async {
    try {
      final response = await _apiService.get("${ApiConstants.operationalFunds}/$id");
      if (response.data['fund'] != null) {
        return FundModel.fromJson(Map<String, dynamic>.from(response.data['fund']));
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching fund by id: $e");
      return null;
    }
  }

  Future<bool> confirmReceipt(int fundId) async {

    try {
      await _apiService.put("${ApiConstants.operationalFunds}/$fundId/receive");
      if (!mounted) return true;
      await fetchOperationalFunds();
      _ref.read(expenseProvider.notifier).fetchExpenses();
      return true;
    } catch (e) {
      if (mounted) {
        state = FundState(error: e.toString(), isLoading: false, funds: state.funds, users: state.users, allocationUsage: state.allocationUsage);
      }
      return false;
    }
  }

  Future<bool> updateFund(int id, Map<String, dynamic> data) async {
    try {
      await _apiService.put("${ApiConstants.operationalFunds}/$id", data: data);
      if (!mounted) return true;
      await fetchOperationalFunds();
      _ref.read(expenseProvider.notifier).fetchExpenses();
      return true;
    } catch (e) {
      if (mounted) {
        state = FundState(error: e.toString(), isLoading: false, funds: state.funds, users: state.users, allocationUsage: state.allocationUsage);
      }
      return false;
    }
  }

  Future<bool> deleteFund(int id) async {
    try {
      await _apiService.delete("${ApiConstants.operationalFunds}/$id");
      if (!mounted) return true;
      await fetchOperationalFunds();
      _ref.read(expenseProvider.notifier).fetchExpenses();
      return true;
    } catch (e) {
      if (mounted) {
        state = FundState(error: e.toString(), isLoading: false, funds: state.funds, users: state.users, allocationUsage: state.allocationUsage);
      }
      return false;
    }
  }

  /// User requests fund from Manager (POST /api/funds/request)
  Future<bool> requestFund(Map<String, dynamic> data) async {
    try {
      await _apiService.post(ApiConstants.requestFund, data: data);
      if (!mounted) return true;
      await fetchOperationalFunds();
      return true;
    } catch (e) {
      if (mounted) {
        state = FundState(error: e.toString(), isLoading: false, funds: state.funds, users: state.users, allocationUsage: state.allocationUsage);
      }
      return false;
    }
  }

  /// Manager approves a pending fund request (PUT /api/funds/operational/:id/approve)
  Future<bool> approveFundRequest(int id) async {
    try {
      await _apiService.put("${ApiConstants.operationalFunds}/$id/approve");
      if (!mounted) return true;
      await fetchOperationalFunds();
      return true;
    } catch (e) {
      if (mounted) {
        state = FundState(error: e.toString(), isLoading: false, funds: state.funds, users: state.users, allocationUsage: state.allocationUsage);
      }
      return false;
    }
  }

  /// Manager rejects a pending fund request (PUT /api/funds/operational/:id/reject)
  Future<bool> rejectFundRequest(int id, String reason) async {
    try {
      await _apiService.put("${ApiConstants.operationalFunds}/$id/reject", data: {'rejection_reason': reason});
      if (!mounted) return true;
      await fetchOperationalFunds();
      return true;
    } catch (e) {
      if (mounted) {
        state = FundState(error: e.toString(), isLoading: false, funds: state.funds, users: state.users, allocationUsage: state.allocationUsage);
      }
      return false;
    }
  }

  /// Manager allocates an approved fund request (PUT /api/funds/operational/:id/allocate)
  Future<bool> allocateFundRequest(int id) async {
    try {
      await _apiService.put("${ApiConstants.operationalFunds}/$id/allocate");
      if (!mounted) return true;
      await fetchOperationalFunds();
      _ref.read(expenseProvider.notifier).fetchExpenses();
      return true;
    } catch (e) {
      if (mounted) {
        state = FundState(error: e.toString(), isLoading: false, funds: state.funds, users: state.users, allocationUsage: state.allocationUsage);
      }
      return false;
    }
  }

  Future<void> downloadFundStatement(int id) async {
    try {
      final fund = state.funds.firstWhere((f) => f.id == id);
      await ReportGenerator.generateFundPDF(fund);
    } catch (e) {
      // Ignore errors for individual report generation
    }
  }
}
