import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final serverIp = ref.watch(settingsProvider.select((s) => s.serverIp));
  return ApiService(ref, serverIp);
});

class ApiService {
  final Ref _ref;
  final Dio _dio;
  final _storage = const FlutterSecureStorage();
  
  ApiService(this._ref, String? serverIp) : _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.getBaseUrl(serverIp),
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  )) {
    debugPrint('ApiService initialized with baseUrl: ${ApiConstants.getBaseUrl(serverIp)}');
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        String errorMessage = "An unexpected error occurred";
        
        // 1. Check for specific server-provided error messages in the response body
        if (e.response?.data != null && e.response?.data is Map) {
          final data = e.response?.data as Map;
          errorMessage = data['message'] ?? data['error'] ?? errorMessage;
        }

        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout || 
            e.type == DioExceptionType.sendTimeout) {
          errorMessage = "Connection timed out. Please check your network or server IP.";
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = "Could not connect to server. Attempting to auto-discover...";
          _ref.read(settingsProvider.notifier).discoverServer();
        } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          // 2. ONLY logout if it's NOT a login-related request (which naturally returns 401 on wrong pass)
          final path = e.requestOptions.path;
          final isAuthPath = path.contains('/auth/login') || path.contains('/auth/register') || path.contains('/auth/verify');
          
          if (!isAuthPath) {
            errorMessage = "Session expired. Please log in again.";
            _ref.read(authProvider.notifier).logout();
          }
        } else if (e.response?.statusCode == 500) {
          errorMessage = "Internal server error. Please try again later.";
        }

        return handler.next(e.copyWith(message: errorMessage));
      },
    ));
  }

  Dio get dio => _dio;

  // Generic methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
