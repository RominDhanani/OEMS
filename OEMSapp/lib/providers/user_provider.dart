import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';
import './auth_provider.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserNotifier(apiService, ref);
});

class UserState {
  final List<UserModel> users;

  final List<UserModel> managers;
  final bool isLoading;
  final String? error;

  UserState({
    this.users = const [],

    this.managers = const [],
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    List<UserModel>? users,

    List<UserModel>? managers,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      users: users ?? this.users,

      managers: managers ?? this.managers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final ApiService _apiService;
  final Ref _ref;

  UserNotifier(this._apiService, this._ref) : super(UserState());

  Future<void> fetchAllUsers() async {
    state = state.copyWith(isLoading: true);
    final userRole = _ref.read(authProvider).user?.role;
    
    try {
      // Branch based on role: CEO -> allUsers, MANAGER -> getTeamUsers
      final endpoint = userRole == 'CEO' ? ApiConstants.allUsers : ApiConstants.getTeamUsers;
      final response = await _apiService.get(endpoint);
      if (!mounted) return;
      final List<dynamic> data = response.data['users'];
      final users = data.map((u) => UserModel.fromJson(Map<String, dynamic>.from(u))).toList();
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: e.toString(), isLoading: false);
      }
    }
  }



  Future<void> fetchManagers() async {
    try {
      final response = await _apiService.get(ApiConstants.getManagers);
      if (!mounted) return;
      final List<dynamic> data = response.data['managers'];
      final managers = data.map((u) => UserModel.fromJson(Map<String, dynamic>.from(u))).toList();
      state = state.copyWith(managers: managers);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: e.toString());
      }
    }
  }

  Future<bool> approveUser(int id, String action) async {
    try {
      await _apiService.put("${ApiConstants.approveUser}$id/approve", data: {'action': action});
      if (!mounted) return true;
      await fetchAllUsers();
      if (!mounted) return true;
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: e.toString());
      }
      return false;
    }
  }

  Future<bool> assignManager(int userId, int? managerId) async {
    try {
      await _apiService.put("${ApiConstants.assignManager}$userId/assign-manager", data: {'manager_id': managerId});
      if (!mounted) return true;
      await fetchAllUsers();
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: e.toString());
      }
      return false;
    }
  }
}
