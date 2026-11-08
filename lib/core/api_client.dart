import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  static const String tokenKey = 'mdhp_jwt_token';
  static const String userKey = 'mdhp_cached_user';

  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }
    if (Platform.isAndroid) {
      // PHYSICAL DEVICE (your SM M356B): use 'http://127.0.0.1:8000/api/v1'
      // ONLY IF you ran `adb reverse tcp:8000 tcp:8000` (start_backend.bat does
      // this automatically) so the device's localhost forwards to your PC.
      //
      // If both phone and PC are on the same Wi-Fi without adb reverse, use
      // your PC's LAN IP instead, e.g. 'http://192.168.1.50:8000/api/v1'.
      //
      // EMULATOR only: 10.0.2.2 aliases the host PC's loopback
      // ('http://10.0.2.2:8000/api/v1'); 127.0.0.1 on an emulator refers to
      // the emulator itself, not the PC.
      return 'http://127.0.0.1:8000/api/v1';
    }
    // iOS simulator and desktop: localhost is the host machine.
    return 'http://127.0.0.1:8000/api/v1';
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: defaultBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.read(key: tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired or invalid
            await secureStorage.delete(key: tokenKey);
            await secureStorage.delete(key: userKey);
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> saveToken(String token) async {
    await secureStorage.write(key: tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await secureStorage.read(key: tokenKey);
  }

  Future<void> clearAuth() async {
    await secureStorage.delete(key: tokenKey);
    await secureStorage.delete(key: userKey);
  }
}
