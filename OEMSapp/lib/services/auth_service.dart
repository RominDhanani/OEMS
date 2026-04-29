import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import '../core/constants/api_constants.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
class AuthService {
  final ApiService _apiService;
  final _storage = const FlutterSecureStorage();

  AuthService(this._apiService);

  Future<UserModel?> login(String email, String password) async {
    try {
      String deviceInfo = 'Unknown Device';
      try {
        final DeviceInfoPlugin plugin = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          final androidInfo = await plugin.androidInfo;
          deviceInfo = '${androidInfo.manufacturer} ${androidInfo.model} (Android ${androidInfo.version.release})';
        } else if (Platform.isIOS) {
          final iosInfo = await plugin.iosInfo;
          deviceInfo = '${iosInfo.name} (iOS ${iosInfo.systemVersion})';
        }
      } catch (e) {
        // Fallback silently if device info fails
      }

      final response = await _apiService.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
        'device_info': deviceInfo,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final userJson = response.data['user'];
        
        await _storage.write(key: 'token', value: token);
        return UserModel.fromJson(Map<String, dynamic>.from(userJson));
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<UserModel?> getProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.profile);
      if (response.statusCode == 200 && response.data['user'] != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(response.data['user']));
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<bool> register(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(ApiConstants.register, data: data);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }

  Future<String?> getCurrentToken() async {
    return await _storage.read(key: 'token');
  }

  Future<bool> requestRegistrationOtp(String email) async {
    try {
      final response = await _apiService.post(ApiConstants.requestRegistrationOtp, data: {'email': email});
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> verifyRegistrationOtp(String email, String otp) async {
    try {
      final response = await _apiService.post(ApiConstants.verifyRegistrationOtp, data: {
        'email': email,
        'otp': otp,
      });
      if (response.statusCode == 200) {
        return response.data['verificationToken'];
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<bool> requestLoginOtp(String email) async {
    try {
      final response = await _apiService.post(ApiConstants.requestLoginOtp, data: {'email': email});
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> loginWithOtp(String email, String otp) async {
    try {
      final response = await _apiService.post(ApiConstants.loginOtp, data: {
        'email': email,
        'otp': otp,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final userJson = response.data['user'];
        await _storage.write(key: 'token', value: token);
        return UserModel.fromJson(Map<String, dynamic>.from(userJson));
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<bool> updateProfile(Map<String, dynamic> data, {String? imagePath}) async {
    try {
      final Map<String, dynamic> formDataMap = {...data};
      if (imagePath != null) {
        formDataMap['profile_image'] = await MultipartFile.fromFile(imagePath);
      }
      
      final formData = FormData.fromMap(formDataMap);
      await _apiService.put(ApiConstants.updateProfile, data: formData);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _apiService.post(ApiConstants.forgotPassword, data: {'email': email});
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await _apiService.post('${ApiConstants.resetPassword}/$token', data: {
        'password': newPassword,
      });
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changePassword(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put(ApiConstants.changePassword, data: data);
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteProfileImage() async {
    try {
      final response = await _apiService.delete(ApiConstants.deleteProfileImage);
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  // --- Session Management ---

  Future<List<dynamic>> getSessions() async {
    try {
      final response = await _apiService.get(ApiConstants.sessions);
      if (response.statusCode == 200) {
        // Backend returns the sessions array directly, not nested under a key
        if (response.data is List) {
          return response.data;
        }
        return response.data['sessions'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> revokeSession(int sessionId) async {
    try {
      final response = await _apiService.delete('${ApiConstants.sessions}/$sessionId');
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> revokeAllOtherSessions() async {
    try {
      final response = await _apiService.delete(ApiConstants.revokeAllOtherSessions);
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  // --- Admin User Management ---

  Future<List<UserModel>> getPendingUsers() async {
    try {
      final response = await _apiService.get(ApiConstants.pendingUsers);
      final List<dynamic> data = response.data['users'];
      return data.map((u) => UserModel.fromJson(Map<String, dynamic>.from(u))).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _apiService.get(ApiConstants.allUsers);
      final List<dynamic> data = response.data['users'];
      return data.map((u) => UserModel.fromJson(Map<String, dynamic>.from(u))).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> approveUser(int id, String action) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.approveUser}$id/approve',
        data: {'action': action},
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> assignManager(int userId, int managerId) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.assignManager}$userId/assign-manager',
        data: {'manager_id': managerId},
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getManagersList() async {
    try {
      final response = await _apiService.get('/users/managers');
      final List<dynamic> data = response.data['managers'];
      return data.map((u) => UserModel.fromJson(Map<String, dynamic>.from(u))).toList();
    } catch (e) {
      rethrow;
    }
  }
}
