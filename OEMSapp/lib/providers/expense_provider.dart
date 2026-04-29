import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_model.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';

final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ExpenseNotifier(apiService);
});

class ExpenseState {
  final List<ExpenseModel> expenses;
  final bool isLoading;
  final String? error;

  ExpenseState({this.expenses = const [], this.isLoading = false, this.error});
}

class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final ApiService _apiService;

  ExpenseNotifier(this._apiService) : super(ExpenseState());

  Future<void> fetchExpenses() async {
    state = ExpenseState(isLoading: true, expenses: state.expenses);
    try {
      final response = await _apiService.get(ApiConstants.expenses);
      if (!mounted) return;
      final List<dynamic> data = response.data['expenses'];
      final expenses = data.map((e) => ExpenseModel.fromJson(Map<String, dynamic>.from(e))).toList();
      state = ExpenseState(expenses: expenses, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = ExpenseState(error: e.toString(), isLoading: false, expenses: state.expenses);
    }
  }

  Future<bool> createExpense(Map<String, dynamic> data, List<String> filePaths) async {
    state = ExpenseState(isLoading: true, expenses: state.expenses);
    try {
      final formData = FormData.fromMap(data);
      for (var path in filePaths) {
        formData.files.add(MapEntry(
          'vouchers',
          await MultipartFile.fromFile(path),
        ));
      }
      await _apiService.post(ApiConstants.expenses, data: formData);
      if (!mounted) return true;
      await fetchExpenses();
      return true;
    } catch (e) {
      if (mounted) {
        state = ExpenseState(error: e.toString(), isLoading: false, expenses: state.expenses);
      }
      return false;
    }
  }

  Future<bool> deleteDocument(int expenseId, int docId) async {
    try {
      await _apiService.delete("/expenses/$expenseId/documents/$docId");
      if (!mounted) return true;
      await fetchExpenses();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateExpenseStatus(int id, String status) async {
    try {
      await _apiService.put("/expenses/$id/status", data: {'status': status});
      if (!mounted) return true;
      await fetchExpenses();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> approveExpense(int id) async {
    try {
      await _apiService.put("/expenses/$id/approve");
      if (!mounted) return true;
      await fetchExpenses();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectExpense(int id, String reason) async {
    try {
      await _apiService.put("/expenses/$id/reject", data: {'rejection_reason': reason});
      if (!mounted) return true;
      await fetchExpenses();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<ExpenseDocument>> fetchExpenseDocuments(int id) async {
    try {
      final response = await _apiService.get("/expenses/$id");
      // Backend returns { expense: { ... }, documents: [ ... ] }
      if (response.data['documents'] != null) {
        final List<dynamic> docsData = response.data['documents'];
        return docsData.map((d) => ExpenseDocument.fromJson(Map<String, dynamic>.from(d))).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<ExpenseModel?> fetchExpenseById(int id) async {
    try {
      final response = await _apiService.get("/expenses/$id");
      // Backend returns { expense: { ... }, documents: [ ... ] }
      if (response.data['expense'] != null) {
        final expenseData = Map<String, dynamic>.from(response.data['expense']);
        if (response.data['documents'] != null) {
          expenseData['documents'] = response.data['documents'];
        }
        return ExpenseModel.fromJson(expenseData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateExpense(int id, Map<String, dynamic> data, [List<String>? filePaths]) async {
    try {
      final formData = FormData.fromMap(data);
      if (filePaths != null) {
        for (var path in filePaths) {
          formData.files.add(MapEntry(
            'vouchers',
            await MultipartFile.fromFile(path),
          ));
        }
      }
      await _apiService.put("/expenses/$id", data: formData);
      if (!mounted) return true;
      await fetchExpenses();
      return true;
    } catch (e) {
      if (mounted) {
        state = ExpenseState(error: e.toString(), isLoading: false, expenses: state.expenses);
      }
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      await _apiService.delete("/expenses/$id");
      if (!mounted) return true;
      await fetchExpenses();
      return true;
    } catch (e) {
      if (mounted) {
        state = ExpenseState(error: e.toString(), isLoading: false, expenses: state.expenses);
      }
      return false;
    }
  }
}
