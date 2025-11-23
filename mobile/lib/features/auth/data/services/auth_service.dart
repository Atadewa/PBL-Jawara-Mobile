import '../models/login_request.dart';
import '../models/login_response.dart' as login_models;
import '../models/register_request.dart';
import '../models/register_response.dart' as register_models;
import '../../../../core/config/api_config.dart';

/// Authentication service for handling API calls
class AuthService {
  // Base URL diambil dari ApiConfig
  // Untuk mengubah base URL, edit file: lib/core/config/api_config.dart
  static const String _baseUrl = ApiConfig.baseUrl;

  /// Login user
  ///
  /// TODO: When implementing real API:
  /// 1. Set ApiConfig.useDummyData = false di api_config.dart
  /// 2. Update ApiConfig.baseUrl dengan URL production
  /// 3. Add proper error handling for network errors
  /// 4. Add authentication token storage (e.g., using shared_preferences)
  /// 5. Remove the dummy success response and parse actual API response
  Future<login_models.LoginResponse> login(LoginRequest request) async {
    try {
      // TODO: Uncomment and modify when real API is ready
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/auth/login'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(request.toJson()),
      // );
      //
      // if (response.statusCode == 200) {
      //   return LoginResponse.fromJson(jsonDecode(response.body));
      // } else {
      //   throw Exception('Login failed');
      // }

      // DUMMY RESPONSE - Always returns success
      await Future.delayed(
        const Duration(seconds: 2),
      ); // Simulate network delay

      return login_models.LoginResponse(
        success: true,
        message: 'Login berhasil!',
        token: 'dummy_token_123456',
        user: login_models.UserData(
          id: '1',
          username: 'user123',
          email: 'user@example.com',
          fullName: 'User Test',
          role: 'warga',
        ),
      );
    } catch (e) {
      return login_models.LoginResponse(
        success: false,
        message: 'Login gagal: ${e.toString()}',
      );
    }
  }

  /// Register new user
  ///
  /// TODO: When implementing real API:
  /// 1. Set ApiConfig.useDummyData = false di api_config.dart
  /// 2. Update ApiConfig.baseUrl dengan URL production
  /// 3. Add proper error handling for network errors
  /// 4. Add validation for duplicate username/email
  /// 5. Remove the dummy success response and parse actual API response
  Future<register_models.RegisterResponse> register(
    RegisterRequest request,
  ) async {
    try {
      // TODO: Uncomment and modify when real API is ready
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/auth/register'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(request.toJson()),
      // );
      //
      // if (response.statusCode == 200 || response.statusCode == 201) {
      //   return RegisterResponse.fromJson(jsonDecode(response.body));
      // } else {
      //   throw Exception('Registration failed');
      // }

      // DUMMY RESPONSE - Always returns success
      await Future.delayed(
        const Duration(seconds: 2),
      ); // Simulate network delay

      return register_models.RegisterResponse(
        success: true,
        message: 'Registrasi berhasil!',
        token: 'dummy_token_789012',
        user: register_models.UserData(
          id: '2',
          username: request.username,
          email: request.email,
          fullName: request.fullName,
          phoneNumber: request.phoneNumber,
          role: request.role ?? 'warga',
        ),
      );
    } catch (e) {
      return register_models.RegisterResponse(
        success: false,
        message: 'Registrasi gagal: ${e.toString()}',
      );
    }
  }

  /// Logout user
  ///
  /// TODO: When implementing real API:
  /// 1. Call logout endpoint if needed
  /// 2. Clear stored authentication token
  /// 3. Clear any cached user data
  Future<void> logout() async {
    // TODO: Implement logout logic
    // Example:
    // await SharedPreferences.getInstance().then((prefs) {
    //   prefs.remove('auth_token');
    //   prefs.remove('user_data');
    // });

    await Future.delayed(const Duration(milliseconds: 500));
  }
}
