import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expansion_model.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/report_generator.dart';
import 'expense_provider.dart';

final expansionProvider = StateNotifierProvider<ExpansionNotifier, ExpansionState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ExpansionNotifier(apiService, ref);
});

class ExpansionState {
  final List<ExpansionModel> expansions;
  final bool isLoading;
  final String? error;

  ExpansionState({this.expansions = const [], this.isLoading = false, this.error});

  ExpansionState copyWith({
    List<ExpansionModel>? expansions,
    bool? isLoading,
    String? error,
  }) {
    return ExpansionState(
      expansions: expansions ?? this.expansions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ExpansionNotifier extends StateNotifier<ExpansionState> {
  final ApiService _apiService;
  final Ref _ref;

  ExpansionNotifier(this._apiService, this._ref) : super(ExpansionState());

  Future<void> fetchExpansions() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.get(ApiConstants.expansionRequests);
      if (!mounted) return;
      final List<dynamic> data = response.data['funds'];
      final expansions = data.map((e) => ExpansionModel.fromJson(Map<String, dynamic>.from(e))).toList();
      state = state.copyWith(expansions: expansions, isLoading: false);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: e.toString(), isLoading: false);
      }
    }
  }

  Future<bool> requestExpansion(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      await _apiService.post(ApiConstants.expansionRequests, data: data);
      if (!mounted) return true;
      await fetchExpansions();
      _ref.read(expenseProvider.notifier).fetchExpenses();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
      return false;
    }
  }

  Future<bool> reviewExpansion(int id, String action, {double? approvedAmount, String? rejectionReason}) async {
    state = state.copyWith(isLoading: true);
    try {
      final reviewData = {
        'action': action,
        if (approvedAmount != null) 'approved_amount': approvedAmount,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      };
      await _apiService.put("${ApiConstants.expansionRequests}/$id/review", data: reviewData);
      if (!mounted) return true;
      await fetchExpansions();
      _ref.read(expenseProvider.notifier).fetchExpenses();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
      return false;
    }
  }

  Future<bool> deleteExpansion(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final request = state.expansions.firstWhere((e) => e.id == id);
      final match = RegExp(r'(?:\(ID:\s*|Expense\s*#)(\d+)').firstMatch(request.justification);
      
      if (match != null) {
        final expenseId = int.parse(match.group(1)!);
        await _ref.read(expenseProvider.notifier).updateExpenseStatus(expenseId, 'RECEIPT_APPROVED');
      }

      await _apiService.delete("${ApiConstants.expansionRequests}/$id");
      if (!mounted) return true;
      await fetchExpansions();
      _ref.read(expenseProvider.notifier).fetchExpenses();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
      return false;
    }
  }

  Future<ExpansionModel?> fetchExpansionById(int id) async {
    try {
      final response = await _apiService.get("${ApiConstants.expansionRequests}/$id");
      if (response.data['request'] != null) {
        return ExpansionModel.fromJson(response.data['request']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateExpansion(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      await _apiService.put("${ApiConstants.expansionRequests}/$id", data: data);
      if (!mounted) return true;
      await fetchExpansions();
      _ref.read(expenseProvider.notifier).fetchExpenses();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
      return false;
    }
  }

  Future<void> downloadExpansionStatement(int id) async {
    try {
      final expansion = state.expansions.firstWhere((e) => e.id == id);
      // Use the generic report generator to create a PDF for this expansion
      await ReportGenerator.generateFundPDF({
        'id': expansion.id,
        'amount': expansion.requestedAmount,
        'from_user_name': expansion.managerName,
        'to_user_name': 'CEO',
        'description': expansion.justification,
        'status': expansion.status,
        'created_at': expansion.requestedAt.toIso8601String(),
        'payment_mode': 'EXPANSION',
      });
    } catch (e) {
      // Ignore errors for individual report generation
    }
  }
}
