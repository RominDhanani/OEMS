import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConstants {
  // Individual defines for more flexibility
  static const String _apiIp = String.fromEnvironment('API_IP', defaultValue: '192.168.0.196');
  static const String _apiPort = String.fromEnvironment('API_PORT', defaultValue: '5000');

  static String getBaseUrl(String? customIp) {
    // 1. Prioritize Provided Custom IP
    if (customIp != null && customIp.isNotEmpty) {
      if (customIp.contains(':')) {
        // If it already has a port, use it directly
        return "http://$customIp/api";
      }
      return "http://$customIp:$_apiPort/api";
    }

    // 2. Prioritize Environment Variable
    if (_apiIp.isNotEmpty) {
      return "http://$_apiIp:$_apiPort/api";
    }

    // 3. Web Handling
    if (kIsWeb) {
      return "http://localhost:5000/api";
    }

    // 4. Platform Specific Fallbacks
    try {
      if (Platform.isAndroid) {
        return "http://192.168.0.196:5000/api";
      }
      if (Platform.isIOS) {
        return "http://localhost:5000/api"; 
      }
    } catch (e) {
      // Fallback
    }

    return "http://localhost:5000/api";
  }

  static String get baseUrl => getBaseUrl(null);

  static String get storageUrl => baseUrl.replaceAll('/api', '/uploads');

  // Auth Endpoints
  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String profile = "/auth/me";
  static const String updateProfile = "/auth/profile";
  static const String requestRegistrationOtp = "/auth/request-registration-otp";
  static const String verifyRegistrationOtp = "/auth/verify-registration-otp";
  static const String requestLoginOtp = "/auth/request-login-otp";
  static const String loginOtp = "/auth/login-otp";
  static const String forgotPassword = "/auth/forgot-password";
  static const String resetPassword = "/auth/reset-password";
  static const String changePassword = "/auth/change-password";
  static const String deleteProfileImage = "/auth/profile-image";
  
  // User Endpoints
  static const String pendingUsers = "/users/pending";
  static const String allUsers = "/users";
  static const String approveUser = "/users/"; // + id + /approve
  static const String assignManager = "/users/"; // + id + /assign-manager
  static const String getManagers = "/users/managers";
  static const String getTeamUsers = "/users/users";
  
  // Expense Endpoints
  static const String expenses = "/expenses";
  static const String expenseStatus = "/expenses"; // + id + /status
  static const String expenseDocuments = "/expenses"; // + id + /documents
  
  // Fund Endpoints
  static const String operationalFunds = "/funds/operational";
  static const String requestFund = "/funds/operational"; // Same as operationalFunds
  static const String expansionFunds = "/funds/expansion";
  static const String expansionRequests = "/funds/expansion";
  static const String updateFundStatus = "/funds/operational"; // + id + /receive for receipt
  
  // Reports
  static const String dashboardStats = "/reports/dashboard";
  static const String expenseReports = "/reports/expenses";
  static const String fundReports = "/reports/funds";
  static const String expansionReports = "/reports/expansion";
  static const String allocationUsageReport = "/reports/allocation-usage";

  // Notifications
  static const String notifications = "/notifications";
  static const String markNotificationRead = "/notifications"; // + id + /read
  static const String markAllNotificationsRead = "/notifications/read-all";

  // Sessions
  static const String sessions = "/auth/sessions";
  static const String revokeAllOtherSessions = "/auth/sessions/revoke-all-others";

  // Shared Constants
  static const List<String> expenseCategories = [
    'Travel',
    'Meals & Entertainment',
    'Office Supplies',
    'Accommodation',
    'Transportation',
    'Communication',
    'Equipment',
    'Training',
    'Other',
  ];
}
