import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, Local IP for Real Device
  static const String baseUrl = 'https://node.jnanagni.in/api/v1'; 
  
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));
  final _storage = const FlutterSecureStorage();

  ApiService() {
    // Add interceptor to inject token automatically
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // --- AUTH ---
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['data']['token'];
        // Save Token
        await _storage.write(key: 'jwt_token', value: token);
        // Save Login Time for 6-hour check
        await _storage.write(key: 'login_time', value: DateTime.now().toIso8601String());
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _dio.get('/auth/me');

      if (response.statusCode == 200) {
        // Based on your Next.js code, the user object is nested in data.data.user
        // Adjust this depending on your exact backend response structure.
        // If your Node response is { success: true, data: { user: {...} } }
        return response.data['data']['user']; 
      }
      return null;
    } catch (e) {
      print("Error fetching profile: $e");
      return null;
    }
  }

  // Check if session is valid (< 6 hours)
  Future<bool> isSessionValid() async {
    final token = await _storage.read(key: 'jwt_token');
    final timeStr = await _storage.read(key: 'login_time');
    
    if (token == null || timeStr == null) return false;

    final loginTime = DateTime.parse(timeStr);
    final difference = DateTime.now().difference(loginTime);

    if (difference.inHours >= 6) {
      await logout(); // Expired
      return false;
    }
    return true;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  // --- DATA ---
  Future<Map<String, dynamic>?> scanUser(String userId) async {
    try {
      // Endpoint updated as requested
      final response = await _dio.get('/users/scan/$userId');
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}