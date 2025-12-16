import 'package:dio/dio.dart';
import '../../../../core/auth/backend_api_client.dart';
import '../models/aspirasi_model.dart';

/// API service for aspiration endpoints
/// Communicates with backend /aspirations routes
class AspirationApiService {
  final BackendApiClient _client = BackendApiClient();

  /// GET /aspirations - list all aspirations (scoped by backend based on roles)
  Future<List<AspirationModel>> list() async {
    try {
      final response = await _client.get('/aspirations');

      // Handle { data: [...] } wrapper
      final responseData = response.data;
      final List<dynamic> items;

      if (responseData is Map && responseData.containsKey('data')) {
        items = (responseData['data'] as List?) ?? [];
      } else if (responseData is List) {
        items = responseData;
      } else {
        throw Exception('Invalid response format');
      }

      return items
          .map((json) => AspirationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// GET /aspirations/:id - get detail of a single aspiration
  Future<AspirationModel> getById(int id) async {
    try {
      final response = await _client.get('/aspirations/$id');

      // Handle { data: {...} } wrapper
      final responseData = response.data;
      final Map<String, dynamic> item;

      if (responseData is Map && responseData.containsKey('data')) {
        item = responseData['data'] as Map<String, dynamic>;
      } else if (responseData is Map) {
        item = responseData as Map<String, dynamic>;
      } else {
        throw Exception('Invalid response format');
      }

      return AspirationModel.fromJson(item);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// POST /aspirations - create new aspiration (warga-only)
  Future<AspirationModel> create({
    required String title,
    required String description,
    String? category,
  }) async {
    try {
      final response = await _client.post(
        '/aspirations',
        data: {
          'title': title,
          'description': description,
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );

      // Handle { data: {...} } wrapper
      final responseData = response.data;
      final Map<String, dynamic> item;

      if (responseData is Map && responseData.containsKey('data')) {
        item = responseData['data'] as Map<String, dynamic>;
      } else if (responseData is Map) {
        item = responseData as Map<String, dynamic>;
      } else {
        throw Exception('Invalid response format');
      }

      return AspirationModel.fromJson(item);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// PATCH /aspirations/:id - update aspiration content (warga-only, own aspiration)
  Future<AspirationModel> updateMy({
    required int id,
    String? title,
    String? description,
    String? category,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (category != null) data['category'] = category;

      final response = await _client.dio.patch('/aspirations/$id', data: data);

      // Handle { data: {...} } wrapper
      final responseData = response.data;
      final Map<String, dynamic> item;

      if (responseData is Map && responseData.containsKey('data')) {
        item = responseData['data'] as Map<String, dynamic>;
      } else if (responseData is Map) {
        item = responseData as Map<String, dynamic>;
      } else {
        throw Exception('Invalid response format');
      }

      return AspirationModel.fromJson(item);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// DELETE /aspirations/:id - delete aspiration (warga-only, own aspiration)
  Future<void> deleteMy(int id) async {
    try {
      await _client.delete('/aspirations/$id');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// PATCH /aspirations/:id/status - update status (moderator-only)
  Future<AspirationModel> updateStatus({
    required int id,
    required String status,
    String? decisionNote,
  }) async {
    try {
      final response = await _client.dio.patch(
        '/aspirations/$id/status',
        data: {
          'status': status,
          if (decisionNote != null && decisionNote.isNotEmpty)
            'decision_note': decisionNote,
        },
      );

      // Handle { data: {...} } wrapper
      final responseData = response.data;
      final Map<String, dynamic> item;

      if (responseData is Map && responseData.containsKey('data')) {
        item = responseData['data'] as Map<String, dynamic>;
      } else if (responseData is Map) {
        item = responseData as Map<String, dynamic>;
      } else {
        throw Exception('Invalid response format');
      }

      return AspirationModel.fromJson(item);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      throw UnauthorizedException(
        e.response?.data?['message'] ?? 'Unauthorized',
      );
    } else if (e.response?.statusCode == 403) {
      throw ForbiddenException(e.response?.data?['message'] ?? 'Forbidden');
    } else if (e.response?.statusCode == 404) {
      throw NotFoundException(e.response?.data?['message'] ?? 'Not found');
    } else {
      throw ApiException(
        e.response?.data?['message'] ?? e.message ?? 'Server error',
      );
    }
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}
