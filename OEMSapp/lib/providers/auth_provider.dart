import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import './expense_provider.dart';
import './fund_provider.dart';
import './user_provider.dart';
import './expansion_provider.dart';
import '../services/socket_service.dart';


final authServiceProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthService(apiService);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => AuthState(status: AuthStatus.initial);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(AuthState.initial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = AuthState(status: AuthStatus.loading);
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (!mounted) return;
      if (isLoggedIn) {
        final user = await _authService.getProfile();
        if (!mounted) return;
        if (user != null) {
          if (user.role.toUpperCase() == 'CEO') {
            await logout();
            state = AuthState(status: AuthStatus.error, errorMessage: "CEO access is restricted to the Web platform. Please use the Web portal.");
          } else {
            state = AuthState(status: AuthStatus.authenticated, user: user);
          }
        } else {
          state = AuthState(status: AuthStatus.unauthenticated);
        }
      } else {
        state = AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      if (!mounted) return;
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      final user = await _authService.login(email, password);
      if (!mounted) return;
      if (user != null) {
        if (user.role.toUpperCase() == 'CEO') {
          await logout();
          state = AuthState(status: AuthStatus.error, errorMessage: "CEO access is restricted to the Web platform. Please use the Web portal.");
        } else {
          state = AuthState(status: AuthStatus.authenticated, user: user);
        }
      } else {
        state = AuthState(status: AuthStatus.error, errorMessage: "Invalid credentials");
      }
    } catch (e) {
      if (!mounted) return;
      String message = "Login failed. Please check your credentials.";
      if (e is DioException && e.message != null) message = e.message!;
      state = AuthState(status: AuthStatus.error, errorMessage: message);
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      final success = await _authService.register(data);
      if (!mounted) return;
      if (success) {
        state = AuthState(status: AuthStatus.unauthenticated);
      } else {
        state = AuthState(status: AuthStatus.error, errorMessage: "Registration failed");
      }
    } catch (e) {
      if (!mounted) return;
      String message = "Registration failed";
      if (e is DioException && e.message != null) message = e.message!;
      state = AuthState(status: AuthStatus.error, errorMessage: message);
    }
  }

  Future<void> logout() async {
    try {
      // 1. Disconnect socket
      _ref.read(socketServiceProvider).disconnect();
      
      // 2. Clear backend session
      await _authService.logout();
    } catch (e) {
      // Continue even if backend logout fails
    } finally {
      if (mounted) {
        // 3. Mark as unauthenticated
        state = AuthState(status: AuthStatus.unauthenticated);
        
        // 4. Invalidate providers to clear all cached data/loading states
        _ref.invalidate(expenseProvider);
        _ref.invalidate(fundProvider);
        _ref.invalidate(userProvider);
        _ref.invalidate(expansionProvider);
      }
    }
  }

  Future<bool> requestRegistrationOtp(String email) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      final success = await _authService.requestRegistrationOtp(email);
      if (!mounted) return success;
      state = AuthState(status: AuthStatus.unauthenticated);
      return success;
    } catch (e) {
      if (!mounted) return false;
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
      return false;
    }
  }

  Future<String?> verifyRegistrationOtp(String email, String otp) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      final token = await _authService.verifyRegistrationOtp(email, otp);
      if (!mounted) return token;
      state = AuthState(status: AuthStatus.unauthenticated);
      return token;
    } catch (e) {
      if (!mounted) return null;
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
      return null;
    }
  }

  Future<void> loginWithOtp(String email, String otp) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      final user = await _authService.loginWithOtp(email, otp);
      if (!mounted) return;
      if (user != null) {
        if (user.role.toUpperCase() == 'CEO') {
          await logout();
          state = AuthState(status: AuthStatus.error, errorMessage: "CEO access is restricted to the Web platform. Please use the Web portal.");
        } else {
          state = AuthState(status: AuthStatus.authenticated, user: user);
        }
      } else {
        state = AuthState(status: AuthStatus.error, errorMessage: "Invalid or expired OTP");
      }
    } catch (e) {
      if (!mounted) return;
      String message = "OTP Login failed";
      if (e is DioException && e.message != null) message = e.message!;
      state = AuthState(status: AuthStatus.error, errorMessage: message);
    }
  }

  Future<bool> requestLoginOtp(String email) async {
    state = AuthState(status: AuthStatus.loading, user: state.user);
    try {
      final success = await _authService.requestLoginOtp(email);
      if (!mounted) return success;
      state = AuthState(status: AuthStatus.unauthenticated);
      return success;
    } catch (e) {
      if (!mounted) return false;
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> reviewUser(int id, String action) async {
    try {
      final success = await _authService.approveUser(id, action);
      return success;
    } catch (e) {
      if (mounted) {
        state = AuthState(status: AuthStatus.error, errorMessage: e.toString(), user: state.user);
      }
      return false;
    }
  }
  
  Future<bool> assignManager(int userId, int managerId) async {
    try {
      return await _authService.assignManager(userId, managerId);
    } catch (e) {
      if (mounted) {
        state = AuthState(status: AuthStatus.error, errorMessage: e.toString(), user: state.user);
      }
      return false;
    }
  }

  Future<List<UserModel>> getManagersList() async {
    try {
      return await _authService.getManagersList();
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      return await _authService.getAllUsers();
    } catch (e) {
      return [];
    }
  }
}
