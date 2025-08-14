import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Replace with your actual NetSuite domain and endpoints
  static const String _baseUrl = 'https://your-netsuite-domain.app.netsuite.com';
  static const String _loginEndpoint = '/app/login/rest';
  static const String _registerEndpoint = '/app/register/rest';
  static const String _resetPasswordEndpoint = '/app/reset-password/rest';
  
  // NetSuite API credentials (store these securely)
  static const String _consumerKey = 'your_consumer_key';

  static Future<Map<String, String>> _getHeaders({String? token}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Register new user with NetSuite
  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    required String dateOfBirth,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_registerEndpoint'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'dateOfBirth': dateOfBirth,
          'role': role,
          'consumerKey': _consumerKey,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Save user data locally if registration successful
        await _saveUserData(data);
        
        return {
          'success': true,
          'message': 'Registration successful',
          'data': data,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Authenticate user with NetSuite
  static Future<Map<String, dynamic>> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_loginEndpoint'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'consumerKey': _consumerKey,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save authentication token and user data
        await _saveAuthToken(data['token']);
        await _saveUserData(data['user']);
        
        return {
          'success': true,
          'message': 'Sign in successful',
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Invalid credentials',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Send password reset request to NetSuite
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_resetPasswordEndpoint'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'consumerKey': _consumerKey,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset link sent to your email',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to send reset link',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get current authentication token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    if (token == null) return false;
    
    // Check if token is still valid (optional: implement token expiry check)
    final loginTime = await getLoginTimestamp();
    if (loginTime != null) {
      final now = DateTime.now();
      final loginDateTime = DateTime.parse(loginTime);
      final difference = now.difference(loginDateTime);
      
      // Token expires after 24 hours (adjust as needed)
      if (difference.inHours > 24) {
        await signOut();
        return false;
      }
    }
    
    return true;
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  // Get login timestamp
  static Future<String?> getLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('login_timestamp');
  }

  // Save authentication token
  static Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('login_timestamp', DateTime.now().toIso8601String());
  }

  // Save user data locally
  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  // Sign out user
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('login_timestamp');
    await prefs.setBool('guest_mode', false);
  }

  // Make authenticated API calls to NetSuite
  static Future<Map<String, dynamic>> makeAuthenticatedRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
  }) async {
    final token = await getAuthToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'User not authenticated',
      };
    }

    try {
      late http.Response response;
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders(token: token);

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          return {
            'success': false,
            'message': 'Unsupported HTTP method',
          };
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else if (response.statusCode == 401) {
        // Token expired, sign out user
        await signOut();
        return {
          'success': false,
          'message': 'Session expired, please sign in again',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Request failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Refresh authentication token (if supported by NetSuite)
  static Future<bool> refreshToken() async {
    final token = await getAuthToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/app/refresh-token/rest'),
        headers: await _getHeaders(token: token),
        body: jsonEncode({
          'consumerKey': _consumerKey,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveAuthToken(data['token']);
        return true;
      }
    } catch (e) {
      print('Token refresh failed: $e');
    }

    return false;
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  // Validate password strength
  static Map<String, dynamic> validatePassword(String password) {
    final result = {
      'isValid': false,
      'errors': <String>[],
    };

    if (password.length < 8) {
      (result['errors'] as List<String>).add('Password must be at least 8 characters long');
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      (result['errors'] as List<String>).add('Password must contain at least one uppercase letter');
    }
    
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      (result['errors'] as List<String>).add('Password must contain at least one lowercase letter');
    }
    
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      (result['errors'] as List<String>).add('Password must contain at least one number');
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      (result['errors'] as List<String>).add('Password must contain at least one special character');
    }

    result['isValid'] = (result['errors'] as List).isEmpty;
    return result;
  }
}