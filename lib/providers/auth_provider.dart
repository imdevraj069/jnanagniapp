import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // Check if user has admin/staff privileges
  bool get isStaff {
    if (_user == null) return false;
    final List<dynamic> specialRoles = _user!['specialRoles'] ?? ['None'];
    final String role = _user!['role'] ?? 'student';
    
    // Check against your Node.js valid special roles
    const allowedRoles = ['admin', 'category_lead', 'event_coordinator', 'volunteer', 'finance_team'];
    
    // Allow if they have a special role OR if they are faculty/admin in primary role
    return specialRoles.any((r) => allowedRoles.contains(r)) || role == 'admin';
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post(ApiConstants.login, {
        'email': email,
        'password': password
      });

      if (response['success'] == true && response['data'] != null) {
        final userData = response['data']['user'];
        
        // --- SECURITY CHECK ---
        // Validate role before allowing full login
        final List<dynamic> specialRoles = userData['specialRoles'] ?? [];
        final allowedRoles = ['admin', 'category_lead', 'event_coordinator', 'volunteer', 'finance_team'];
        
        bool hasAccess = specialRoles.any((r) => allowedRoles.contains(r)) || userData['role'] == 'admin';

        if (!hasAccess) {
          _isLoading = false;
          notifyListeners();
          return false; // Reject Login
        }

        final token = response['data']['token'];
        await _apiService.saveToken(token);
        _user = userData;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Login Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    try {
      final response = await _apiService.get(ApiConstants.me);
      if (response['success'] == true) {
        _user = response['data'];
        notifyListeners();
      }
    } catch (e) {
      await logout();
    }
  }
}