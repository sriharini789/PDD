import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;
  Map<String, dynamic>? _user;
  bool _initialized = false;

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5001/api/auth';
    } else {
      return 'http://127.0.0.1:5001/api/auth';
    }
  }

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _token != null;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userJson = prefs.getString('auth_user');
    if (userJson != null) {
      try {
        _user = jsonDecode(userJson);
      } catch (e) {
        _user = null;
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<Map<String, dynamic>> signup(String fullName, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message'], 'token': data['verificationToken']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Signup failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _token = data['token'];
        _user = data['user'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('auth_user', jsonEncode(_user));
        
        notifyListeners();
        return {'success': true, 'user': _user};
      } else if (response.statusCode == 403) {
        // Unverified email
        return {
          'success': false,
          'unverified': true,
          'message': data['message'] ?? 'Please verify your email',
          'verificationToken': data['verificationToken']
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Verification failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'], 'resetToken': data['resetToken']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Forgot password failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Password reset failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network connection error: $e'};
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
    notifyListeners();
  }
}

final authService = AuthService();
