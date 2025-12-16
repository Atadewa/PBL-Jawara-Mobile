import 'package:dio/dio.dart';
import '../../../../core/auth/backend_api_client.dart';
import '../models/user_context_model.dart';

/// Service to fetch user context from backend
class UserContextService {
  final BackendApiClient _apiClient = BackendApiClient();

  /// Fetch user context from /auth/me endpoint
  Future<UserContextModel> fetchMe() async {
    try {
      final response = await _apiClient.get('/auth/me');

      if (response.statusCode == 200 && response.data != null) {
        return UserContextModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch user context: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final message = e.response?.data?['message'] as String?;
        if (message != null && message.contains('waiting approval')) {
          throw WaitingApprovalException(message);
        }
        throw Exception(
          'Access denied: ${e.response?.data?['message'] ?? 'Forbidden'}',
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user context: $e');
    }
  }
}

/// Custom exception for waiting approval status
class WaitingApprovalException implements Exception {
  final String message;
  WaitingApprovalException(this.message);

  @override
  String toString() => message;
}

/// Custom exception for unauthorized access
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}
